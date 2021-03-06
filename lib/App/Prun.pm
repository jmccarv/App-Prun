use strict;
use warnings;
package App::Prun;

use Moo;
use Storable qw( freeze );  # to support testing
use namespace::clean;

use 5.010;

has pm => ( is => 'ro', required => 1 );
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

    my $rc = system($cmd);
    $self->pm->finish($rc >> 8);
}

sub done { shift->pm->wait_all_children }

sub _test_dump {
    $Storable::forgive_me = 1;
    print freeze(shift);
    exit 255;
}

# ABSTRACT: Provides the prun script as a command line interface to L<Parallel::ForkManager>.
1;

__END__

=pod

=head1 SYNOPSYS

    for nr in `seq 1..100`; do echo "echo command #$nr" | prun

    prun command_file_to_run_in_parallel

=head1 DESCRIPTION

B<prun> allows you to utilize multiple CPUs
for some workloads from the shell more easily.

prun takes a list of commands (stdin and/or from file(s)) and run the commands
in parallel.

prun is a CLI front end to L<Parallel::ForkManager>. It runs commands in
parallel up to a maximum number of processes at once.

=over

=item * prun --help

=item * L<Parallel::ForkManager>

=back

=head1 EXAMPLES

There are also examples available from the command line B<--help>.

Run tkprof against all .trc files in the current directory, run 32
of them at a time.

  for F in *.trc; do echo "tkprof $F ${F%trc}txt"; done | prun -p 32

Run all commands in a file (command_file), one command per line. Run
the default number of processes in parallel ($def_processes).
Ignore any failed processes, but do report to STDOUT any that fail.

  prun -r command_file

Test with the dummy_load script included in the contrib/ directory 
of this distribution:

  for F in `seq 1 100`; do echo "contrib/dummy_load"; done | prun

=head1 SEE ALSO

=over

=item L<App::Prun::Scaled>

=item L<Parallel::ForkManager>

=item L<Parallel::ForkManager::Scaled>

=back

=head1 REPOSITORY

The mercurial repository for this module may be found here:

  https://bitbucket.org/jmccarv/app-prun

clone it:

  hg clone https://bitbucket.org/jmccarv/app-prun

=cut
