package App::Prun;

use Moo;
use Storable qw( freeze );  # to support testing
#use Data::Dumper;
use namespace::clean;

our $VERSION = 0.1;

has pm    => ( is => 'ro', required => 1 );
has shell => ( is => 'ro', default => sub{ $ENV{SHELL} // '/bin/sh' } );
has report_failed_procs => ( is => 'ro', default => 1 );
has exit_on_failed_proc => ( is => 'ro', default => 0 );

sub BUILD {
    my $self = shift;
    $self->pm->run_on_finish(sub{ $self->on_finish_callback(@_) });
    $self->pm->set_waitpid_blocking_sleep(0);
}

sub on_finish_callback {
    my $self = shift;
    my ($pid, $rc, $id, $sig, $core, $ref) = @_;

    if ($rc) {
        print STDERR "[$pid] Command '$id' failed with exit code $rc\n"
            if $self->report_failed_procs;

        return unless $self->exit_on_failed_proc;

        $self->pm->wait_all_children;
        exit 1;
    }
}

sub run_command {
    my $self = shift;
    my $cmd = shift;

    chomp $cmd;
    
    # Skip blank lines and comments
    return if (/^\s*(#|$)/);

    $self->pm->start($cmd) and return;

    # In the child now

    my $fh;
    open $fh, '|-', $self->shell.' -'
        or die "Failed to execute shell ".$self->shell.": $!";

    print $fh $_,"\n";
    close $fh;
    $self->pm->finish($? >> 8);
}

sub done { shift->pm->wait_all_children }

sub _test_dump {
    #print Dumper(shift);
    $Storable::forgive_me = 1;
    print freeze(shift);
    exit 255;
}

1;

__END__

=pod

=head1 NAME

App::Prun - Provides the prun and sprun scripts as command line interfaces to Parallel::ForkManager and Parallel::ForkManager::Scaled respectively.

=head1 VERSION

Version 0.01

=head1 SYNOPSYS

    for nr in `seq 1..100`; do echo "echo command #$nr" | prun
    for nr in `seq 1..100`; do echo "echo command #$nr" | sprun

    prun command_file_to_run_in_parallel
    sprun command_file_to_run_in_parallel

=head1 DESCRIPTION

=head1 AUTHRO

Jason McCarver <slam@parasite.cc>

=head1 SEE ALSO

=over

=item L<Parallel::ForkManager>

=item L<Parallel::ForkManager::Scaled>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Jason McCarver

This is free software; you can redistribute it and/or modify it under the
same terms as the Perl 5 programming language system itself.

=cut
