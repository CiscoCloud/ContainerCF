#!/usr/bin/env perl

use Test::Most;
use Test::Files;
use File::Spec;
use File::Path qw(make_path);
use File::Copy qw(copy);

## Setup
my $expectations_dir = '/tmp/test-expectations';
make_path('/var/vcap/data/jobs/tests');
make_path('/root/job');
make_path($expectations_dir);
copy('./components/cf-control/tests/fixtures/template_me_please', '/var/vcap/');
copy('./components/cf-control/tests/fixtures/template_me_please', '/var/vcap/data/jobs/tests/');
copy('./components/cf-control/tests/fixtures/expected_job.toml', $expectations_dir);
copy('./components/cf-control/tests/fixtures/expected.tmpl', $expectations_dir);
copy('./components/cf-control/tests/fixtures/expected.toml', $expectations_dir);
copy('./components/cf-control/scripts/job/placeholders.yml', '/root/job/');


## Preconditions
is ((-d '/etc/confd'), undef, '/etc/confd does not exist');

## Execute scripts
`./components/cf-control/scripts/job/template_all_the_things.pl`;

## Postconditions
my $template_dir = '/etc/confd/templates';
my $control_dir = '/etc/confd/conf.d';

# Templates
dir_only_contains_ok(
  $template_dir,
  ['template_me_please.tmpl', 'data_jobs_tests_template_me_please.tmpl'],
  "$template_dir contains expected templates"
);

compare_ok("$template_dir/template_me_please.tmpl", "$expectations_dir/expected.tmpl", 'Non-job template has correct contents');
compare_ok("$template_dir/data_jobs_tests_template_me_please.tmpl", "$expectations_dir/expected.tmpl", 'Job template has correct contents');

# Control files
dir_only_contains_ok(
  $control_dir,
  ['template_me_please.toml', 'data_jobs_tests_template_me_please.toml'],
  "$control_dir contains expected control files"
);

compare_ok("$control_dir/template_me_please.toml", "$expectations_dir/expected.toml", 'Non-job control file has correct contents');
compare_ok("$control_dir/data_jobs_tests_template_me_please.toml", "$expectations_dir/expected_job.toml", 'Job control file has correct contents');

done_testing();
