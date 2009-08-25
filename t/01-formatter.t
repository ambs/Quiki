#!/usr/bin/perl

use Test::More tests => 33;

use_ok("Quiki::Formatter");

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
one paragraph.

two paragraphs.
EOI
<p>one paragraph.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
one paragraph.





two paragraphs.
EOI
<p>one paragraph.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
one paragraph < other paragraph.

two paragraphs.
EOI
<p>one paragraph &lt; other paragraph.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
one paragraph with a [[link]].

two paragraphs.
EOI
<p>one paragraph with a <a href="quiki?node=link">link</a>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
one paragraph with [[more]] than a [[link]].

two paragraphs.
EOI
<p>one paragraph with <a href="quiki?node=more">more</a> than a <a href="quiki?node=link">link</a>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
one paragraph with [[http://www.google.com|an external link]].

two paragraphs.
EOI
<p>one paragraph with <a href="http://www.google.com">an external link</a>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
one paragraph with a [[named link|link]].

two paragraphs.
EOI
<p>one paragraph with a <a href="quiki?node=named%20link">link</a>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
one paragraph with a **bold**.

two paragraphs.
EOI
<p>one paragraph with a <b>bold</b>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
one paragraph with a **bold * with \*\* stars**.

two paragraphs.
EOI
<p>one paragraph with a <b>bold * with ** stars</b>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
one paragraph with an //italic//.

two paragraphs.
EOI
<p>one paragraph with an <i>italic</i>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
one paragraph with an //italic / with \/\/ slashes//.

two paragraphs.
EOI
<p>one paragraph with an <i>italic / with // slashes</i>.</p>

<p>two paragraphs.</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
foo /\/ bar \** zbr \/\/ ugh \*\*.
EOI
<p>foo // bar ** zbr // ugh **.</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
foo \\ bar \[[ zbr \]] ugh \*\*.
EOI
<p>foo \ bar [[ zbr ]] ugh **.</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
foo ''bar'' \'' zbr \'' ugh.
EOI
<p>foo <tt>bar</tt> '' zbr '' ugh.</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
will //**bold and italic**// work?
EOI
<p>will <i><b>bold and italic</b></i> work?</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
will **//bold and italic//** work?
EOI
<p>will <b><i>bold and italic</i></b> work?</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
will **//__bold and italic and underline__//** work?
EOI
<p>will <b><i><u>bold and italic and underline</u></i></b> work?</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
will __underline__ work? __foo _ bar__
EOI
<p>will <u>underline</u> work? <u>foo _ bar</u></p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
will [[link|Links **with** formatting //work//]]?
EOI
<p>will <a href="quiki?node=link">Links <b>with</b> formatting <i>work</i></a>?</p>
EOO

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
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

is(Quiki::Formatter::format({SCRIPT_NAME=>'quiki'},<<'EOI'), <<'EOO');
------------

---------------------

---------------------------------
EOI
<hr/>

<hr/>

<hr/>
EOO


is(Quiki::Formatter::format({},<<'EOI'), <<'EOO');
foo

   bar
   zbr

xpto
EOI
<p>foo</p>

<pre>bar
zbr
</pre>

<p>xpto</p>
EOO


is(Quiki::Formatter::format({},<<'EOI'), <<'EOO');
foo

   bar
   zbr
xpto
EOI
<p>foo</p>

<pre>bar
zbr
</pre>

<p>xpto</p>
EOO

is(Quiki::Formatter::format({},<<'EOI'), <<'EOO');
foo

   bar
   zbr
     xpto
xpto
EOI
<p>foo</p>

<pre>bar
zbr
  xpto
</pre>

<p>xpto</p>
EOO


is(Quiki::Formatter::format({},<<'EOI'), <<'EOO');
foo

     bar
   zbr
     xpto
xpto
EOI
<p>foo</p>

<pre>  bar
zbr
  xpto
</pre>

<p>xpto</p>
EOO


is(Quiki::Formatter::format({},<<'EOI'), <<'EOO');
  * one
  * two
EOI
<ul>
<li> one</li>
<li> two</li>
</ul>

EOO

is(Quiki::Formatter::format({},<<'EOI'), <<'EOO');
  - one
  - two
EOI
<ol>
<li> one</li>
<li> two</li>
</ol>

EOO

is(Quiki::Formatter::format({},<<'EOI'), <<'EOO');
  * one
    * one dot one
    * one dot two
  * two
EOI
<ul>
<li> one<ul>
<li> one dot one</li>
<li> one dot two</li>
</ul>
</li>
<li> two</li>
</ul>

EOO

is(Quiki::Formatter::format({},<<'EOI'), <<'EOO');
  - one
    - one dot one
    - one dot two
  - two
    * two dot one
    * two dot two
EOI
<ol>
<li> one<ol>
<li> one dot one</li>
<li> one dot two</li>
</ol>
</li>
<li> two<ul>
<li> two dot one</li>
<li> two dot two</li>
</ul>
</li>
</ol>

EOO

is(Quiki::Formatter::format({},<<'EOI'), <<'EOO');
  - a
    - b
      - c
        - d
EOI
<ol>
<li> a<ol>
<li> b<ol>
<li> c<ol>
<li> d</li>
</ol>
</li>
</ol>
</li>
</ol>
</li>
</ol>

EOO

is(Quiki::Formatter::format({},<<'EOI'), <<'EOO');
  - a
    * b
      - c
        * d
EOI
<ol>
<li> a<ul>
<li> b<ol>
<li> c<ul>
<li> d</li>
</ul>
</li>
</ol>
</li>
</ul>
</li>
</ol>

EOO


is(Quiki::Formatter::format({},<<'EOI'), <<'EOO');
  - a
  * b
EOI
<ol>
<li> a</li>
</ol>
<ul>
<li> b</li>
</ul>

EOO
