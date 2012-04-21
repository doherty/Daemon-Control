#!/usr/bin/perl
use warnings;
use strict;
use File::Spec;
use Test::More;
use Daemon::Control;

my $run_dir = File::Spec->catdir(qw( / var run daemons ));
my $daemon  = new_ok('Daemon::Control', [{
    name        => 'php-fcgi',
    program     => '/usr/bin/php-cgi',
    program_args=> [-b => File::Spec->catfile($run_dir, 'php-fcgi.sock' )],
    fork        => 2,
    user        => 'www-data',
    group       => 'www-data',
    run_dir     => $run_dir,
    pid_file    => 'php-fcgi.pid', # will be relative to run_dir
    stdout_file => '/var/log/php-fcgi.log',
    stderr_file => '/var/log/php-fcgi.log',
    scan_name   => qr/php-cgi/,

    lsb_start   => '$nginx',
    lsb_stop    => '$nginx',
    lsb_sdesc   => 'Starts PHP under FCGI',
    lsb_desc    => 'Starts PHP under FCGI',
}]);

ok(File::Spec->file_name_is_absolute( $daemon->run_dir ), 'run_dir better be absolute');

ok(File::Spec->file_name_is_absolute( $daemon->pid_file ), 'pid_file was absolutized');
is $daemon->pid_file => File::Spec->catfile(qw( / var run daemons php-fcgi.pid )),
    'pid_file is correct, and in the run_dir';

ok(File::Spec->file_name_is_absolute( $daemon->stdout_file ), 'stdout_file was already absolute');
is $daemon->stdout_file => '/var/log/php-fcgi.log', q/stdout_file wasn't touched/;

ok(File::Spec->file_name_is_absolute( $daemon->stderr_file ), 'stderr_file was already absolute');
is $daemon->stderr_file => '/var/log/php-fcgi.log', q/stderr_file wasn't touched/;

isa_ok $daemon->scan_name, 'Regexp';

done_testing;
