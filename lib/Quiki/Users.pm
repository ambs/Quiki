package Quiki::Users;

use Apache::Htpasswd;

sub auth {
    my ($class, $username, $password) = @_;

    # XXX - mais cedo ou mais tarde passar para DBD::SQLite para ter mais info por user
    my $passwd = new Apache::Htpasswd("./passwd");
    $passwd->htCheckPassword($username, $password);
}

'\o/';


=head1 NAME

Quiki::Users - Quiki users manager

=head1 SYNOPSIS

  use Quiki::Users;

  # authenticate user
  Quiki::Users -> auth($username, $passwod);

=head1 DESCRIPTION

Handles Quiki users and permissions.

=head2 auth

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

