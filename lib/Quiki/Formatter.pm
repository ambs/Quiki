package Quiki::Formatter;

use feature ':5.10';

use CGI qw/-nosticky :standard/;
use URI::Escape;

sub format_page {
    my ($Quiki, $string) = @_;

    return div({-class=>'quiki_body'}, Quiki::Formatter::format($Quiki,$string));
}


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
    $chunk =~ s/^\n//;
    $chunk = _protect($chunk);

    if ($chunk =~ /^\s{2}[*-]/) {
        $chunk = _format_list($Quiki, $chunk);

    } elsif ($chunk =~ /^\s{3}/) {
        $chunk = _format_verbatim($chunk);

    }
    else {
        if ($chunk =~ /^ -{10,} \s* $ /x) {
            $chunk = "<hr/>";
        }
        elsif ($chunk =~ /^(={1,6}) ((?:\\=|[^=]|\/[^=])+) \1\s*$/x) {
            given(length($1)) {
                when (1) { $chunk = h6(_inlines($Quiki, $2)) }
                when (2) { $chunk = h5(_inlines($Quiki, $2)) }
                when (3) { $chunk = h4(_inlines($Quiki, $2)) }
                when (4) { $chunk = h3(_inlines($Quiki, $2)) }
                when (5) { $chunk = h2(_inlines($Quiki, $2)) }
                when (6) { $chunk = h1(_inlines($Quiki, $2)) }
            }
        }
        else {
            $chunk = p(_inlines($Quiki, $chunk));
        }
        $chunk = _unbackslash($chunk);
    }
    return $chunk;
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

sub _inlines {
    my ($Quiki, $chunk) = @_;

    my $script = $Quiki->{SCRIPT_NAME};

    my @inline =
      (
       ## [[http://foo]] -- same as http://foo ?
       qr/\[\[(\w+:\/\/[^\]|]+)\]\]/            => sub { a({-href=>$1}, $1) },
       ## [[nodo]]
       qr/\[\[([^\]|]+)\]\]/                    => sub {
           a({-href=>"$script?node=".uri_escape($1) }, $1)
       },
       ## [[protocol://foo|descricao]]
       qr/\[\[(\w+:\/\/[^\]|]+)\|([^\]|]+)\]\]/ => sub {
           a({-href=>$1}, _inlines($Quiki, $2))
       },
       ## [[nodo|descricao]]
       qr/\[\[([^\]|]+)\|([^\]|]+)\]\]/         => sub {
           a({-href=>"$script?node=".uri_escape($1) }, _inlines($Quiki, $2))
       },
       ## ** foo **
       qr/\*\* ((?:\\\*|[^*]|\*[^*])+) \*\*/x   => sub { b(_inlines($Quiki, $1)) },
       ## __ foo __
       qr/__ ((?:\\_|[^_]|_[^_])+) __/x         => sub { u(_inlines($Quiki, $1)) },
       ## // foo //
       qr/\/\/ ((?:\\\/|[^\/]|\/[^\/])+) \/\//x => sub { i(_inlines($Quiki, $1)) },
      );

    while (@inline) {
        my $re   = shift @inline;
        my $code = shift @inline;
        $chunk =~ s/(?<!\\) $re/ $code->() /xeg;
    }
    return $chunk;
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

=head1 NAME

Quiki::Formatter - Quiki formatter module

=head1 SYNOPSIS

  use Quiki::Formatter;
  my $html = Quiki::Formatter::format($string);

=head1 DESCRIPTION

Hides formatting subroutine.

=head1 EXPORTS

None. Use Quiki::Formatter::format.

=head2 format

Receives a string in Wiki syntax. Returns a string in HTML.

=head2 format_page

Receives a Wiki page. Returns it in HTML.

=head1 SEE ALSO

Quiki, perl(1)

=head1 AUTHOR

Alberto Simões, E<lt>ambs@cpan.orgE<gt>
Nuno Carvalho, E<lt>smash@cpan.orgE<gt>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Alberto Simoes and Nuno Carvalho.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
