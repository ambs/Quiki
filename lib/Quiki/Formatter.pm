package Quiki::Formatter;

use CGI ':standard';

# Formatter (format)
#------------------------------------------------------------
# Receives a string. Splits in empty lines (LaTeX like).
# Note that lines with spaces are not empty.
# Each chunk is processed by _format_chunk.
sub format {
    my $string = shift;

    my @chunks = split /^$/m, $string;

    my $html = join("\n\n", map { _format_chunk($_) } @chunks);
    return $html . "\n";
}

# _format_chunk
#------------------------------------------------------------
# Receives a chunk string. Analyzes it and calls the correct
# formatter.
sub _format_chunk {
    my $chunk = shift;

    $chunk = _format_paragraph($chunk);

    return $chunk;
}

# _format_paragraph
#------------------------------------------------------------
# formats a paragraph and inline formats.
sub _format_paragraph {
    my $chunk = shift;
    $chunk =~ s/\n$//;
    $chunk =~ s/^\n//;

    $chunk = _protect($chunk);

    my @inline = (
                  ## [[http://foo]] -- same as http://foo ?
                  qr/\[\[(\w+:\/\/[^\]|]+)\]\]/            => sub { a({-href=>$1}, $1) },
                  ## [[nodo]]
                  qr/\[\[([^\]|]+)\]\]/                    => sub { a({-href=>$1}, $1) },
                  ## [[protocol://foo|descricao]]
                  qr/\[\[(\w+:\/\/[^\]|]+)\|([^\]|]+)\]\]/ => sub { a({-href=>$1}, $2) },
                  ## [[nodo|descricao]]
                  qr/\[\[([^\]|]+)\|([^\]|]+)\]\]/         => sub { a({-href=>$1}, $2) },
                  ## ** foo **
                  qr/\*\* ((?:[^*]|\*[^*])+) \*\*/x        => sub { b($1) },
                  ## // foo //
                  qr/\/\/ ((?:[^\/]|\/[^\/])+) \/\//x      => sub { i($1) },
                 );

    while (@inline) {
        my $re = shift @inline;
        my $code = shift @inline;
        $chunk =~ s/$re/ $code->() /eg;
    }

    return p($chunk);
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
