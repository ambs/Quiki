#!/usr/bin/perl

use Test::More tests => 6;

use_ok("Quiki::Formatter");

is(Quiki::Formatter::format(<<"EOI"), <<"EOO");
one paragraph.

two paragraphs.
EOI
<p>one paragraph.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<"EOI"), <<"EOO");
one paragraph with a [[link]].

two paragraphs.
EOI
<p>one paragraph with a <a href="link">link</a>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<"EOI"), <<"EOO");
one paragraph with [[more]] than a [[link]].

two paragraphs.
EOI
<p>one paragraph with <a href="more">more</a> than a <a href="link">link</a>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<"EOI"), <<"EOO");
one paragraph with [[http://www.google.com|an external link]].

two paragraphs.
EOI
<p>one paragraph with <a href="http://www.google.com">an external link</a>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<"EOI"), <<"EOO");
one paragraph with a [[named link|link]].

two paragraphs.
EOI
<p>one paragraph with a <a href="named link">link</a>.</p>

<p>two paragraphs.</p>
EOO
