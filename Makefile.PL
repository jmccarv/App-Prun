#!/usr/bin/env perl

use inc::Module::Install;

name     'App-Prun';
all_from 'lib/App/Prun.pm';
repository 'https://bitbucket.org/jmccarv/perl-app-prun';
no_index directory => '.hg';

requires 'File::Spec';
requires 'Getopt::Long';
requires 'Moo';
requires 'Parallel::ForkManager';
requires 'Storable';
requires 'namespace::clean';

recommends 'Parallel::ForkManager::Scaled' => '0.13';

test_requires 'Test::More';
test_requires 'Test::Script';

install_script glob('script/*');
auto_install;
WriteAll;
