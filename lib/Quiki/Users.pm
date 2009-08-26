package Quiki::Users;

use DBI;
use Digest::MD5 'md5_hex';

sub auth {
    my ($class, $username, $password) = @_;

    my $database = DBI->connect("dbi:SQLite:dbname=data/users.sqlite","","");
    my $sth = $dbh->prepare("SELECT password FROM auth WHERE username = ?");
    $sth->execute($username);

    my @row = $sth->fetchrow_array;
    if (@row) {
        return (md5_hex($password) eq $row[0]);
    }
    else {
        return 0;
    }
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

