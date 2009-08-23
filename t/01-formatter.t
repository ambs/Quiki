#!/usr/bin/perl

use Test::More tests => 2;

use_ok("Quiki::Formatter");

is(Quiki::Formatter::format(<<"EOI"), <<"EOO");
one paragraph.

two paragraphs.
EOI
<p>one paragraph.</p>

<p>two paragraphs.</p>
EOO
