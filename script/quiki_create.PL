#!/usr/bin/perl

use MIME::Base64;
use strict;

my $out = shift;
open OUT, ">$out" or die $!;
select OUT;
open T, "script/quiki_create.template" or die $!;
while(<T>) { print $_ }
close T;

open L, "site.lst" or die;
while(<L>) {
    chomp;
    next unless $_;
    my ($name,$props) = split /\s+/;
    print STDERR " - codifying $name\n";
    my @props = split /,/,$props;
    my %props;
    @props{@props} = @props;

    print "!!" if ($props{replace});
    print "----$name----";
    print "BIN" if ($props{binary});
    print "\n";

    if ($props{binary}) {
        local $/;
        undef $/;
        open I, "site/".$name or die $!;
        print encode_base64(<I>);
        close I;
    } else {
        open I, "site/".$name or die $!;
        while(<I>) { print $_ };
        print "\n"; # just in case
        close I;
    }
}
close L;
close OUT;
