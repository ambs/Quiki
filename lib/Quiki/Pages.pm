package Quiki::Pages;

sub save {
    my ($class, $node, $contents) = @_;

    if (!-f "data/content/$node") {
        `echo "x" > data/content/$node`;
        `chmod 777 data/content/$node`;
    }
    open O, "> data/content/$node" or die $!;
    print O $contents;
    close O;

}

sub load {
    my ($class, $node) = @_;
    return `cat data/content/$node`;
}


'\o/';


=head1 NAME

Quiki::Users - Quiki pages manager

=head1 SYNOPSIS

  use Quiki::Users;

  # authenticate user
  my $contents = Quiki::Pages -> load($node);

  Quiki::Pages -> save($node, $contents);

=head1 DESCRIPTION

Handles Quiki pages

=head2 load

=head2 save

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

