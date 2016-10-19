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

App::Prun - Provides the prun and sprun scripts as command line interfaces to L<Parallel::ForkManager> and L<Parallel::ForkManager::Scaled> respectively.

=head1 VERSION

Version 0.01

=head1 SYNOPSYS

    for nr in `seq 1..100`; do echo "echo command #$nr" | prun
    for nr in `seq 1..100`; do echo "echo command #$nr" | sprun

    prun command_file_to_run_in_parallel
    sprun command_file_to_run_in_parallel

=head1 DESCRIPTION

The provided B<prun> and B<sprun> scripts allow you to utilize multiple CPUs
for some workloads from the shell more easily.

They take a list of commands (stdin and/or from file(s)) and run the commands
in parallel.

=head2 prun

prun is a CLI front end to L<Parallel::ForkManager>. It runs commands in
parallel up to a maximum number of processes at once.

=over

=item * prun --help

=item * L<Parallel::ForkManager>

=back

=head2 sprun

sprun is a CLI front end to L<Paralell::ForkManager::Scaled>. It runs commands
in parallel while trying to keep the CPUs at a specified level of activity by
constantly adjusting the number of running processes.

=over

=item * sprun --help

=item * L<Parallel::ForkManager::Scaled>

=back

=head1 EXAMPLES

There are also examples available from the command line B<--help>.

=head2 prun

Run tkprof against all .trc files in the current directory, run 32
of them at a time.

  for F in *.trc; do echo "tkprof $F ${F%trc}txt"; done | prun -p 32

Run all commands in a file (command_file), one line at a time.  Run
the default number of processes in parallel ($def_processes).
Ignore any failed processes, but do report to STDOUT any that fail.

  prun -e -r command_file

=head2 sprun

Run tkprof against all .trc files in the current directory
while attempting to keep the system 75% idle, don't adjust the
number of processes unless idle time goes below 74 or above 76, and
re-evaluate after each process exits (update frequency = 0).

  for F in *.trc; do echo "tkprof $F ${F%trc}txt"; done | sprun -t 75 -T 2 -u 0

Run all commands in a file (command_file), one line at a time.  Manually
bound the minimum and maximum number of processes to run and start with 4.
Keep the CPU 100% busy (0% idle) and re-evaluate at most every 3 seconds.
Ignore any failed processes, but do report to STDOUT any that fail.

  sprun -e -r -m 2 -M 8 -i 4 -u 3 command_file

=head1 NOTES

sprun will be installed whether you have its required 
L<Parallel::ForkManager::Scaled> module installed or not. This is intentional
as I didn't want to make L<App::Prun> depend on L<Parallel::ForkManager::Scaled>
since some users may only care about prun / L<Parallel::ForkManager>.

This also means you will have to manually install 
L<Parallel::ForkManager::Scaled> if you want sprun to work. I may
reconsider this approach in a future release.

=head1 AUTHOR

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
