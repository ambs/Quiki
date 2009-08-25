#!/usr/bin/perl

# use lib '/home/smash/playground/Quiki.cron/lib';

use Quiki;

my $conf = do 'quiki.conf';

Quiki->new(%$conf)->run;
