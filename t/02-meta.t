#!/usr/bin/perl

use Test::More tests => 3;
use File::Slurp 'slurp';
use File::Path qw.make_path.;

use_ok("Quiki::Meta");

make_path 'data/meta/';
my $t = {'one'=>1,'two'=>2,'three'=>3};
Quiki::Meta::set('test',$t);

is(slurp("data/meta/test"), <<'EOO');
---
one: 1
three: 3
two: 2
EOO
my $r = Quiki::Meta::get('test');

is_deeply( $t, $r, 'id' );

unlink 'data/meta/test';
rmdir 'data/meta/';
rmdir 'data/';
