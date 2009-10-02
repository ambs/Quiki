#!/usr/bin/perl

use Test::More tests => 4;
use File::Slurp 'slurp';
use File::Path qw.make_path.;
use YAML::Any qw.LoadFile Dump.;


# setting up
make_path 'data/meta/';

# 1
use_ok("Quiki::Meta");

# 2
my $default = {'rev'=>0,'last_updated_in'=>'_','last_update_by'=>'_'};
my $r = Quiki::Meta::get('test');
is_deeply( $default, $r, 'default values' );

# 3
my $t = {'one'=>1,'two'=>2,'three'=>3};
Quiki::Meta::set('test',$t);

my $l = LoadFile("data/meta/test");
is_deeply( $t, $l, 'set values' );

# 4
$r = Quiki::Meta::get('test');
is_deeply( $t, $r, 'id' );

# clean up
unlink 'data/meta/test';
rmdir 'data/meta/';
rmdir 'data/';
