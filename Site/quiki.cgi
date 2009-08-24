#!/usr/bin/perl

use lib '### CHANGE ME ###';

use Quiki;

my %conf = (
           'name' => 'MyQuiki'
            );

Quiki->new(%conf)->run;
