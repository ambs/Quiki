package Quiki::Formatter;

use CGI ':standard';

sub format {
    my $string = shift;
    my $html = pre($string);
    return $html;
}


"false";

=head1 NAME

Quiki::Formatter - Quiki formatter module

=head1 SYNOPSIS

  use Quiki::Formatter;
  my $html = Quiki::Formatter::format($string);

=head1 DESCRIPTION

Hides formatting subroutine.

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
