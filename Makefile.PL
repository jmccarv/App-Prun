#!/usr/bin/env perl

use inc::Module::Install;

name     'App::Prun';
all_from 'lib/App/Prun.pm';
repository 'https://bitbucket.org/jmccarv/perl-app-prun';
no_index directory => '.hg';

requires 'Moo';
requires 'Parallel::ForkManager';
requires 'namespace::clean';

recommends 'Parallel::ForkManager::Scaled';

test_requires 'Test::More';

install_script glob('script/*');
auto_install;
WriteAll;
