# NAME

prun - Provides the prun script as a command line interface to [Parallel::ForkManager](https://metacpan.org/pod/Parallel%3A%3AForkManager).

# VERSION

version 1.11

# DESCRIPTION

**prun** allows you to utilize multiple CPUs
for some workloads from the shell more easily.

prun takes a list of commands (stdin and/or from file(s)) and run the commands
in parallel.

prun is a CLI front end to [Parallel::ForkManager](https://metacpan.org/pod/Parallel%3A%3AForkManager). It runs commands in
parallel up to a maximum number of processes at once.

- prun --help
- [Parallel::ForkManager](https://metacpan.org/pod/Parallel%3A%3AForkManager)

# SYNOPSYS

    for nr in `seq 1..100`; do echo "echo command #$nr" | prun

    prun command_file_to_run_in_parallel

# EXAMPLES

There are also examples available from the command line **--help**.

Run tkprof against all .trc files in the current directory, run 32
of them at a time.

    for F in *.trc; do echo "tkprof $F ${F%trc}txt"; done | prun -p 32

Run all commands in a file (command\_file), one command per line. Run
the default number of processes in parallel ($def\_processes).
Ignore any failed processes, but do report to STDOUT any that fail.

    prun -r command_file

Test with the dummy\_load script included in the contrib/ directory
of this distribution:

    for F in `seq 1 100`; do echo "contrib/dummy_load"; done | prun

# SEE ALSO

- [App::Prun::Scaled](https://metacpan.org/pod/App%3A%3APrun%3A%3AScaled)
- [Parallel::ForkManager](https://metacpan.org/pod/Parallel%3A%3AForkManager)
- [Parallel::ForkManager::Scaled](https://metacpan.org/pod/Parallel%3A%3AForkManager%3A%3AScaled)

# REPOSITORY

The source repository for this module may be found at https://github.com/jmccarv/App-Prun.git

clone it:

    git clone https://github.com/jmccarv/App-Prun.git

# AUTHOR

Jason McCarver <slam@parasite.cc>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2022 by Jason McCarver.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
