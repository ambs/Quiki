package Quiki::Users;

use Text::Password::Pronounceable;
use Email::Sender::Simple 'sendmail';
use Email::Simple;
use Email::Simple::Creator;

use strict;
use warnings;

use DBI;
use Digest::MD5 'md5_hex';

sub _connect {
    return DBI->connect("dbi:SQLite:dbname=data/users.sqlite","","");
}

sub update {
    my ($class, $username, %info) = @_;
    my @valid_fields = qw.password email.;

    $info{password} = md5_hex($info{password}) if exists($info{password});

    my @sql;
    for my $key (keys %info) {
        if ($key ~~ [@valid_fields]) {
            push @sql, "$key = '$info{$key}'"
        }
    }

    my $dbh = _connect;
    my $sth = $dbh->prepare("UPDATE auth SET ".join(", ",@sql)." WHERE username = ?");
    $sth->execute($username);
}

sub role {
    my ($class, $username) = @_;
    my $dbh = _connect;
    my $sth = $dbh->prepare("SELECT perm_group FROM auth WHERE username = ?;");
    $sth->execute($username);
    my @row = $sth->fetchrow_array;

    return @row ? $row[0] : undef ;
}

sub email {
    my ($class, $username) = @_;
    my $dbh = _connect;
    my $sth = $dbh->prepare("SELECT email FROM auth WHERE username = ?;");
    $sth->execute($username);
    my @row = $sth->fetchrow_array;

    return @row ? $row[0] : undef ;
}

sub create {
    my ($class, $quiki, $username, $email) = @_;
    my $password = Text::Password::Pronounceable->generate(6, 10);
    my $dbh = _connect;
    my $sth = $dbh->prepare("INSERT INTO auth VALUES (?,?,?,'user');");
    $sth->execute($username, md5_hex($password), $email);

    my $servername = "http://$quiki->{SERVER_NAME}$quiki->{SCRIPT_NAME}";

    my $from = "admin\@$quiki->{SERVER_NAME}";

    my $message = Email::Simple->create
      (
       header => [
                  To => $email,
                  From => $from,
                  Subject => "Your registration at $quiki->{name}",
                 ],
       body => <<"EOEMAIL");
Hello, $username.

Your password for $quiki->{name} at $servername is: $password
Thank you.
EOEMAIL
    sendmail($message);
}

sub exists {
    my ($class, $username) = @_;
    my $dbh = _connect;
    my $sth = $dbh->prepare("SELECT username FROM auth WHERE username = ?");
    $sth->execute($username);

    my @row = $sth->fetchrow_array;
    return (@row)?1:0;
}

sub auth {
    my ($class, $username, $password) = @_;

    my $dbh = _connect;
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
  if (Quiki::Users -> auth($username, $passwod)) { ... }

  # check user availability
  if (not Quiki::Users -> exists($username)) { ... }

=head1 DESCRIPTION

Handles Quiki users management and permissions.

=head2 auth

This function verifies an user credentials given an username and a password.

=head2 exists

This function verifies if a username already exists.

=head2 create

This function creates a new user given an username and an e-mail address.

=head2 email

This function retrieves the e-mail address for a given username.

=head2 role

This function retrieves the user role for a given username.

=head2 update

This function is used to update user's information.

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

