#!/usr/bin/perl

use MIME::Base64;
use strict;

open T, "script/quiki_create.template" or die $!;
while(<T>) { print $_ }
close T;

open L, "Site.lst" or die;
while(<L>) {
    chomp;
    next unless $_;
    my ($name,$props) = split /\s+/;
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
        open I, "Site/".$name or die $!;
        print encode_base64(<I>);
        close I;
    } else {
        open I, "Site/".$name or die $!;
        while(<I>) { print $_ };
        close I;
    }
}
close L;

