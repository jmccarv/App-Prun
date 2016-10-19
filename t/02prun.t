#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Script;
use Storable qw( thaw );
use Data::Dumper;
use App::Prun;
use Parallel::ForkManager;

plan tests => 13;

script_compiles( 'script/prun' );

my $stdout;
script_runs( ['script/prun', '--test-dump'], {exit => 255, stdout => \$stdout}, 'dump' );

my $obj;
ok (defined ($obj = thaw($stdout)), 'thaw return');

ok ($obj->pm->waitpid_blocking_sleep == 0, 'waitpid_blocking_sleep');
ok ($obj->pm->max_procs > 0, 'default --processes');
ok (!defined $obj->exit_on_failed_proc, 'default --exit-on-failure');
ok (!defined $obj->report_failed_procs, 'default --report-failed');

script_runs( [qw(script/prun --exit-on-failure --report-failed --processes=37 --test-dump)], {exit => 255, stdout => \$stdout}, 'dump' );
ok (defined ($obj = thaw($stdout)), 'thaw return');

#diag(Dumper($obj));
ok ($obj->pm->waitpid_blocking_sleep == 0, 'waitpid_blocking_sleep');
ok ($obj->pm->max_procs == 37, '--processes');
ok (defined $obj->exit_on_failed_proc, '--exit-on-failure');
ok (defined $obj->report_failed_procs, '--report-failed');
