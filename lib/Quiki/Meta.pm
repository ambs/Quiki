package Quiki::Meta;

use feature ':5.10';

use YAML::Any qw.LoadFile Dump.;

sub get {
    my $node = shift;

    unless (-f "data/meta/$node") {
        my $meta = {'last_update_by'=>'_','last_updated_in'=>'_','rev'=>0};
        set($node, $meta);
    }

    LoadFile "data/meta/$node";
}

sub set {
    my ($node, $meta) = @_;

    open(F, ">data/meta/$node") or die $!;
    print F Dump($meta);
    close(F);
}


=head1 NAME

Quiki::Meta - Quiki meta information handler

=head1 SYNOPSIS

  use Quiki::Meta;

  # get meta info
  $self->{meta} = Quiki::Meta::get($node);

  # set meta info
  Quiki::Meta::set($node, $self->{meta});

=head1 DESCRIPTION

Handles saving and retriving meta information for quiki nodes. Meta
information is stored in simple text files and uses the YAML format.

=head2 set

This function updates the meta information in the file for a given page.
It uses the meta information in the current Quicki object.

=head2 get

This function retrives the meta information from the file for a given
node.

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

"zero";
