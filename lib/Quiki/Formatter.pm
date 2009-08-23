package Quiki::Formatter;

use CGI ':standard';

sub format {
    my $string = shift;

    my @chunks = split /^$/m, $string;

    my $html = join("\n\n", map { _format_chunk($_) } @chunks);
    return $html . "\n";
}

sub _format_chunk {
    my $chunk = shift;

    $chunk = _format_paragraph($chunk);

    return $chunk;
}

sub _format_paragraph {
    my $chunk = shift;
    $chunk =~ s/\n$//;
    $chunk =~ s/^\n//;
    return p($chunk);
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
