package Quiki::Formatter::HTML;

use CGI qw/:standard/;
use URI::Escape;
use Regexp::Common qw/URI/;

# Formatter (format)
#------------------------------------------------------------
# Receives a string. Splits in empty lines (LaTeX like).
# Note that lines with spaces are not empty.
# Each chunk is processed by _format_chunk.
sub format {
    my ($Quiki, $string) = @_;

    $string =~ s/\r//g;

    my @chunks = split /^$(?:\n^$)*/m, $string;

    my $html = join("\n\n", map { _format_chunk($Quiki, $_) } @chunks);
    return $html . "\n";
}

sub _tds {
    my ($Quiki, $content) = @_;

    if ($content =~ /^\S/) {
        return td({-style=>"text-align: left"}, _inlines($Quiki, $content));
    }

    if ($content =~ /\S$/) {
        return td({-style=>"text-align: right"}, _inlines($Quiki, $content));
    }

    return td({-style=>"text-align: center"}, _inlines($Quiki, $content));
}

sub _format_table {
    my ($Quiki, $chunk) = @_;

    my @c = split /\n/, $chunk;
    my $table = "<table>\n";

    while (@c && $c[0] =~ /^(\^|\|)/) {
        $c[0] =~ s/^(.)//;
        if ($1 eq "^") {
            $table .= Tr(th([map { _inlines($Quiki, $_) }  split /\^/, $c[0]])) . "\n";
        } else {
            $table .= Tr(join(" ",map { _tds($Quiki, $_) } split /\|(?![^\[]+\]\])/, $c[0])) . "\n";
        }
        shift @c;
    }
    $table .= "</table>\n";

    $chunk = $table . (@c ?
                       _format_chunk($Quiki, join("\n", @c)) :
                       "");
}

sub _format_list {
    my ($Quiki, $chunk) = @_;
    my @level = ();
    my $openitem = 0;
    my $list;
    my @c = split /\n/, $chunk;

    while (@c && $c[0] =~ /^((?:\s{2})+)([*-])(.*)$/) {
        my $level = length($1)/2 - 1;
        my $type  = $2;
        my $item  = $3;
        if ($level > $#level) {
            push @level, $type;
            $list .= ($type eq "*")?"<ul>":"<ol>";
            $openitem = 0;
            $list .= "\n";
        }
        elsif ($level < $#level) {
            $list .= "</li>\n" if $openitem;

            my $ctype = pop @level;
            $list .= ($ctype eq "*")?"</ul>":"</ol>";
            $list .= "\n";
        }
        else {
            $list .= "</li>\n" if $openitem;
            if ($type ne $level[-1]) {
                my $ctype = pop @level;
                $list .= ($ctype eq "*")?"</ul>":"</ol>";
                $list .= "\n";
                push @level, $type;
                $list .= ($type eq "*")?"<ul>":"<ol>";
                $list .= "\n";
            }
            $list .= "<li>"._unbackslash(_inlines($Quiki, $item));
            $openitem = 1;
            shift @c;
        }
    }
    while (@level) {
        my $ctype = pop @level;
        $list .= "</li>\n";
        $list .= ($ctype eq "*")?"</ul>":"</ol>";
        $list .= "\n";
    }

    return (@c)?($list . "\n\n" . _format_chunk($Quiki, join("\n", @c))):$list;
}

# _format_chunk
#------------------------------------------------------------
# Receives a chunk string. Analyzes it and calls the correct
# formatter.
sub _format_chunk {
    my ($Quiki, $chunk) = @_;
    $chunk =~ s/\n$//;
	$chunk =~ s/\n\s{1,2}\n/\n\n/g;
    $chunk =~ s/^\n//;
    $chunk = _protect($chunk);

    if ($chunk =~ /^(\^|\|)/) {
        $chunk = _format_table($Quiki, $chunk);
        $chunk = _unbackslash($chunk);
    }
    elsif ($chunk =~ /^\s{2}[*-]/) {
        $chunk = _format_list($Quiki, $chunk);
        $chunk = _unbackslash($chunk);
    }
    elsif ($chunk =~ /^\s{3}/) {
        $chunk = _format_verbatim($chunk);

    }
    else {
        if ($chunk =~ /^ -{10,} \s* (\n|$) /x) {
            $chunk =~ s/^ -+ \s* //x;
            $chunk = $chunk ? ('<hr/>' . _format_chunk($Quiki, $chunk)) : '<hr/>';
        }
        elsif ($chunk =~ /^(={1,6}) ((?:\\=|[^=]|\/[^=])+) \1\s*($|\n)/x) {
            my ($delim, $title) = ($1, $2);
            $chunk =~ s/.*($|\n)//;

            my $l = length($delim);
            $title = h6(_inlines($Quiki, $title)) if $l == 1;
            $title = h5(_inlines($Quiki, $title)) if $l == 2;
            $title = h4(_inlines($Quiki, $title)) if $l == 3;
            $title = h3(_inlines($Quiki, $title)) if $l == 4;
            $title = h2(_inlines($Quiki, $title)) if $l == 5;
            $title = h1(_inlines($Quiki, $title)) if $l == 6;

            $chunk = $chunk ? ($title . "\n\n"  . _format_chunk($Quiki, $chunk)) : $title;
        }
        else {
            $chunk = p(_inlines($Quiki, $chunk));
        }
        $chunk = _unbackslash($chunk);
    }
    return $chunk;
}

sub _expand_entities {
    my $string = shift;
    for ($string) {
        s/--/&mdash;/g;
        s/\(c\)/&copy;/g;
        s/\(r\)/&reg;/g;
        s/&lt;-&gt;/&harr;/g;
        s/&lt;=&gt;/&hArr;/g;
        s/-&gt;/&rarr;/g;
        s/&lt;-/&larr;/g;
        s/=&gt;/&rArr;/g;
        s/&lt;=/&lArr;/g;

    }
    return $string;
}

sub _format_verbatim {
    my $chunk = shift;
    my $pre;
    my @c = split /\n/, $chunk;

    while (@c && $c[0] =~ /^\s{3}(.*)/) {
        $pre .= $1 . "\n";
        shift @c;
    }

    $pre = pre($pre);

    return $pre . ( @c ? ("\n\n" . _format_chunk($Quiki, join("\n", @c))) : "");
}

our %SAVES;
our $SAVES;

sub _inlines {
    my ($Quiki, $chunk) = @_;

    my $script = $Quiki->{SCRIPT_NAME};

    sub _saveit {
        my $text = shift;
        $SAVES++;
        $SAVES{"#$SAVES"} = $text;
        return "#$SAVES";
    }
    sub _loadit { $SAVES{$_[0]} }

    my @inline =
      (
       ## [[http://foo]] -- same as http://foo ?
       qr/\[\[(\w+:\/\/[^\]|]+)\]\]/            => sub { _saveit(a({-href=>$1}, $1)) },
       ## [[nodo]]
       qr/\[\[([^\]|]+)\]\]/                    => sub {
           _saveit(a({-href=>"$script?node=".uri_escape($1) }, $1))
       },
       ## [[protocol://foo|descricao]]
       qr/\[\[(\w+:\/\/[^\]|]+)\|([^\]|]+)\]\]/ => sub {
           _saveit(a({-href=>$1}, _inlines($Quiki, $2)))
       },
       ## [[nodo|descricao]]
       qr/\[\[([^\]|]+)\|([^\]|]+)\]\]/         => sub {
           _saveit(a({-href=>"$script?node=".uri_escape($1) }, _inlines($Quiki, $2)))
       },

       ## ** foo **
       qr/\*\* ((?:\\\*|[^*]|\*[^*])+) \*\*/x   => sub { b(_inlines($Quiki, $1)) },
       ## __ foo __
       qr/__ ((?:\\_|[^_]|_[^_])+) __/x         => sub { u(_inlines($Quiki, $1)) },
       ## // foo //
       qr/\/\/ ((?:\\\/|[^\/]|\/[^\/])+) \/\//x => sub { i(_inlines($Quiki, $1)) },
       ## '' foo ''
       qr/'' ((?:\\'|[^']|'[^'])+) ''/x => sub { tt(_inlines($Quiki, $1)) },

       ## {{wiki: foo | desc }}
       qr/\{\{(\s*)wiki:([^}|]+)\|([^}]+?)(\s*)\}\}/        => sub {
           my $align = (length($1) && length($4))?"center":
             (length($1)?"right":
              (length($4)?"left":""));
           _inline_doc($Quiki, $2,$3, $align)
       },
       ## {{wiki: foo  }}
       qr/\{\{(\s*)wiki:([^}]+?)(\s*)\}\}/                  => sub {
           my $align = (length($1) && length($3))?"center":
             (length($1)?"right":
              (length($3)?"left":""));
           _inline_doc($Quiki, $2,$2, $align) },

       ## {{ foo | desc  }}
       qr/\{\{(\s*)([^}|]+)\|([^}]+?)(\s*)\}\}/        => sub {
           my $align = (length($1) && length($4))?"center":
             (length($1)?"right":
              (length($4)?"left":""));
           _inline_pic($Quiki, $2, $3, $align);
       },
       ## {{ foo  }}
       qr/\{\{(\s*)([^}]+?)(\s*)\}\}/       => sub {
           my $align = (length($1) && length($3))?"center":
             (length($1)?"right":
              (length($3)?"left":""));
           _inline_pic($Quiki, $2, $2, $align);
       },

       ## urls que nao sigam aspas
       qr/(?<!")$RE{URI}{-keep}/                => sub { a({-href=>$1}, $1) },

       ## savits
       qr/(\#\d+)/              => sub { _loadit($1) },

      );

    while (@inline) {
        my $re   = shift @inline;
        my $code = shift @inline;
        $chunk =~ s/(?<!\\) $re/ $code->() /xeg;
    }

    return _expand_entities($chunk);
}

sub _inline_pic {
    my ($quiki, $url, $desc, $align) = @_;

    if ($align eq "right") {
        return img({-alt=>$desc, -title=>$desc,
                    -src=>$url, -style=>"float: right"})
    }

    if ($align eq "left") {
        return img({-alt=>$desc, -title=>$desc,
                    -src=>$url, -style=>"float: left"})
    }

    if ($align eq "center") {
        return div({-style=>"text-align: center"},
                   img({-alt=>$desc, -title=>$desc,
                        -src=>$url}))
    }

    return img({-alt=>$desc, -title=>$desc, -src=>$url})
}

sub _inline_doc {
    my ($quiki, $id, $desc, $align) = @_;
    my $node = $quiki->{node};
    my $mm = new File::MMagic;
    my $mime = $mm->checktype_filename("data/attach/$node/$id");
    if ($mime =~ /^image/) {
        if ($align eq "right") {
            return img({-alt=>$desc, -src=>"data/attach/$node/$id", -style=>"float: right"})
        }

        if ($align eq "left") {
            return img({-alt=>$desc, -src=>"data/attach/$node/$id", -style=>"float: left"})
        }

        if ($align eq "center") {
            return div({-style=>"text-align: center"}, 
                       img({-alt=>$desc, -src=>"data/attach/$node/$id"}))
        }

        return img({-alt=>$desc, -src=>"data/attach/$node/$id"})
    }
    else {
        a({-href=>"data/attach/$node/$id", -target=>"_new"},
          img({-alt => "Attachment",
               -src => "images/mime_default.png"}), $desc)
    }
}

sub _unbackslash {
    my $string = shift;
    $string =~ s/\\(.)/$1/g;
    return $string;
}

sub _protect {
    my $string = shift;
    for ($string) {
        s/&/&amp;/g;
        s/>/&gt;/g;
        s/</&lt;/g;
    }
    return $string;
}

"false";

=encoding UTF-8

=head1 NAME

Quiki::Formatter::HTML - Quiki HTML formatter module

=head1 SYNOPSIS

  use Quiki::Formatter::HTML;
  my $html = Quiki::Formatter::HTML::format($string);

=head1 DESCRIPTION

Hides formatting subroutine.

=head1 EXPORTS

None. Use Quiki::Formatter::HTML::format.

=head2 format

Receives a string in Wiki syntax. Returns a string in HTML.

=head2 format_page

Receives a Wiki page. Returns it in HTML.

=head1 SEE ALSO

Quiki::Syntax, Quiki

=head1 AUTHOR

Alberto Simões, E<lt>ambs@cpan.orgE<gt>
Nuno Carvalho, E<lt>smash@cpan.orgE<gt>

=head1 COPYRIGHT & LICENSE

Copyright 2009-2010 Alberto Simoes and Nuno Carvalho.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
