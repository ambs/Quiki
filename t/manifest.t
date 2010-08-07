#!/usr/bin/perl

use strict;
use warnings;

use Test::CheckManifest;
ok_manifest({filter => [qr/\.git/,
                        qr/testsite/,
                        qr/Makefile.old/,
                        qr'/TODO$',
                        qr'script/quiki_create$',
                        qr/extra_files/,
                        qr/~$/]});
