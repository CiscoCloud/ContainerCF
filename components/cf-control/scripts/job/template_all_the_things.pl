#!/usr/bin/env perl

use strict;
use warnings;

use Path::Tiny qw(path);
use File::Path qw(make_path);
use YAML::Tiny;

my %placeholders = %{ YAML::Tiny->read( '/root/job/placeholders.yml' )->[0] };

make_path('/etc/confd/templates');
make_path('/etc/confd/conf.d');

sub replace_placeholders {
  my $source_file_data = $_[0];

  my @keys = ();
  while (my ($placeholder, $replacement) = each %placeholders) {
    if ($source_file_data =~ s/$placeholder/$replacement/g) {
      push @keys, $replacement =~ /(".*")/;
    }
  }

  @keys = sort @keys;

  return ($source_file_data, \@keys);
}

sub write_template_file {
  my $confd_filename = $_[0];
  my $template_file_data = $_[1];

  path('/etc/confd/templates/' . $confd_filename . '.tmpl')->spew_utf8($template_file_data);
}

sub write_control_file {
  my $source_file = $_[0];
  my $confd_filename = $_[1];
  my $keys = $_[2];

  my $template_file = $confd_filename . '.tmpl';
  my $vcap_gid = getgrnam('vcap');
  $keys = join(', ', @$keys);

  (my $toml = qq{[template]
  src = "$template_file"
  dest = "$source_file"
  gid = $vcap_gid
  keys = [ $keys ]
  }) =~ s/^ {2}//gm;

  if ($source_file =~ /^\/var\/vcap\/data\/jobs/) {
    my $job = (split '/', $source_file)[5];
    my $reload_cmd = "reload_cmd = \"until /var/vcap/bosh/bin/monit restart $job; do echo 'Waiting to restart $job...'; sleep 2; done\"\n";
    $toml = $toml . $reload_cmd;
  }

  path("/etc/confd/conf.d/$confd_filename.toml")->spew_utf8($toml);
}

chdir ('/var/vcap/');
my @files = `ag PLACEHOLDER-f622194a --ignore *.log --ignore-case --files-with-matches`;

foreach my $source_file_relative_path (@files) {
  chomp($source_file_relative_path);

  my $source_file = path('/var/vcap/' . $source_file_relative_path);
  my $source_file_data = $source_file->slurp_utf8;

  my @template_details = replace_placeholders($source_file_data);
  my ($template_file_data, @keys) = ($template_details[0], $template_details[1]);

  (my $confd_filename = $source_file_relative_path) =~ s|/|_|g;
  write_template_file($confd_filename, $template_file_data);
  write_control_file($source_file, $confd_filename, @keys);
}
