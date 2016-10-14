package App::Prun;

use Moo;
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

1;
