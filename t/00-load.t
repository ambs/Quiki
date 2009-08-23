#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Quiki' );
}

diag( "Testing Quiki $Quiki::VERSION, Perl $], $^X" );
