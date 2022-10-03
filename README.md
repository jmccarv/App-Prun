# NAME

App::Prun - Provides the prun script as a command line interface to [Parallel::ForkManager](https://metacpan.org/pod/Parallel%3A%3AForkManager).

# VERSION

version 1.09

# SYNOPSYS

    for nr in `seq 1..100`; do echo "echo command #$nr" | prun

    prun command_file_to_run_in_parallel

# SEE ALSO

- [prun](https://metacpan.org/pod/prun)
- \* prun --help

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

# POD ERRORS

Hey! **The above document had some coding errors, which are explained below:**

- Around line 25:

    Expected text after =item, not a bullet
