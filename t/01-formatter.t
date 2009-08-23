#!/usr/bin/perl

use Test::More tests => 18;

use_ok("Quiki::Formatter");

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
one paragraph.

two paragraphs.
EOI
<p>one paragraph.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
one paragraph.





two paragraphs.
EOI
<p>one paragraph.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
one paragraph < other paragraph.

two paragraphs.
EOI
<p>one paragraph &lt; other paragraph.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
one paragraph with a [[link]].

two paragraphs.
EOI
<p>one paragraph with a <a href="link">link</a>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
one paragraph with [[more]] than a [[link]].

two paragraphs.
EOI
<p>one paragraph with <a href="more">more</a> than a <a href="link">link</a>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
one paragraph with [[http://www.google.com|an external link]].

two paragraphs.
EOI
<p>one paragraph with <a href="http://www.google.com">an external link</a>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
one paragraph with a [[named link|link]].

two paragraphs.
EOI
<p>one paragraph with a <a href="named link">link</a>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
one paragraph with a **bold**.

two paragraphs.
EOI
<p>one paragraph with a <b>bold</b>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
one paragraph with a **bold * with \*\* stars**.

two paragraphs.
EOI
<p>one paragraph with a <b>bold * with ** stars</b>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
one paragraph with an //italic//.

two paragraphs.
EOI
<p>one paragraph with an <i>italic</i>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
one paragraph with an //italic / with \/\/ slashes//.

two paragraphs.
EOI
<p>one paragraph with an <i>italic / with // slashes</i>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
foo /\/ bar \** zbr \/\/ ugh \*\*.
EOI
<p>foo // bar ** zbr // ugh **.</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
foo \\ bar \[[ zbr \]] ugh \*\*.
EOI
<p>foo \ bar [[ zbr ]] ugh **.</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
will //**bold and italic**// work?
EOI
<p>will <i><b>bold and italic</b></i> work?</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
will **//bold and italic//** work?
EOI
<p>will <b><i>bold and italic</i></b> work?</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
will [[link|Links **with** formatting //work//]]?
EOI
<p>will <a href="link">Links <b>with</b> formatting <i>work</i></a>?</p>
EOO

is(Quiki::Formatter::format(<<'EOI'), <<'EOO');
======foo======

=====bar=====




====zbr====

A paragraph.

===ugh===

==foo bar //or// zbr ugh==

=zbr !\= ugh=
EOI
<h1>foo</h1>

<h2>bar</h2>

<h3>zbr</h3>

<p>A paragraph.</p>

<h4>ugh</h4>

<h5>foo bar <i>or</i> zbr ugh</h5>

<h6>zbr != ugh</h6>
EOO

