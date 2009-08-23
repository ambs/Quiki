#!/usr/bin/perl

use Test::More tests => 13;

use_ok("Quiki::Formatter");

is(Quiki::Formatter::format(<<"EOI"), <<"EOO");
one paragraph.

two paragraphs.
EOI
<p>one paragraph.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<"EOI"), <<"EOO");
one paragraph < other paragraph.

two paragraphs.
EOI
<p>one paragraph &lt; other paragraph.</p>

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

is(Quiki::Formatter::format(<<"EOI"), <<"EOO");
one paragraph with a **bold**.

two paragraphs.
EOI
<p>one paragraph with a <b>bold</b>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<"EOI"), <<"EOO");
one paragraph with a **bold * with * stars**.

two paragraphs.
EOI
<p>one paragraph with a <b>bold * with * stars</b>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<"EOI"), <<"EOO");
one paragraph with an //italic//.

two paragraphs.
EOI
<p>one paragraph with an <i>italic</i>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<"EOI"), <<"EOO");
one paragraph with an //italic / with / slashes//.

two paragraphs.
EOI
<p>one paragraph with an <i>italic / with / slashes</i>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<"EOO");
foo /\/ bar \** zbr \/\/ ugh \*\*.
EOI
<p>foo // bar ** zbr // ugh **.</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
foo \\ bar \[[ zbr \]] ugh \*\*.
EOI
<p>foo \ bar [[ zbr ]] ugh **.</p>
EOO
