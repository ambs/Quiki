package Quiki::Pages;

use warnings;
use strict;

use File::Slurp 'slurp';
use Text::Patch;
use Text::Diff;

sub unlock {
    my ($class, $node) = @_;
    unlink "data/locks/$node" if -f "data/locks/$node";
}

sub locked {
    my ($class, $node, $user) = @_;
    if (-f "data/locks/$node") {
        if (-M "data/locks/$node" < 0.01) {
            if ($user) {
                return (slurp("data/locks/$node") eq $user);
            }
            else {
                return 1;
            }
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

sub lock {
    my ($class, $node, $user) = @_;

    open LOCK, "> data/locks/$node" or die;
    print LOCK $user;
    close LOCK;
}

sub save {
    my ($class, $node, $contents) = @_;

    my $file = "data/content/$node";

    if (-f $file) {
        ## XXX Save previous version
    }

    #if (defined($contents)) {
    open O, "> $file" or die $!;
    print O $contents;
    close O;
    #}
    #else {
    #    unlink "data/contents/$node"
    #}

}

sub load {
    my ($class, $node) = @_;
    return slurp "data/content/$node";
}

sub check_in {
    my ($class, $Quiki, $node, $contents) = @_;

    # XXX nasty check, needed for diff
    $contents .= "\n" unless ($contents =~ m/\n$/);

    my $rev = $Quiki->{meta}{rev};

    if ($rev > 0) {
        my $current = slurp "data/content/$node";
        my $diff = diff(\$contents, \$current, { STYLE=>'Unified' });

        open F, ">data/revs/$node.$rev" or die $!;
        print F $diff;
        close F;
    }

    my $file = "data/content/$node";

    if (-f $file) {
        ## XXX Save previous version
    }

    #if (defined($contents)) {
    $Quiki->{meta}{rev}++;
    open O, "> $file" or die $!;
    print O $contents;
    close O;
    #}
    #else {
    #    unlink "data/contents/$node"
    #}
}

sub check_out {
    my ($class, $Quiki, $node, $rev) = @_;
print STDERR "VOU MOSTRAR $rev, ULTIMA ".$Quiki->{meta}{rev};

    my $cur_rev  = $Quiki->{meta}{rev};
    my $content = slurp "data/content/$node";

    while ($rev < $cur_rev--) {
        my $patch = slurp "data/revs/$node.$cur_rev";

        $content = patch($content, $patch, {STYLE=>'Unified'});
    }

    return $content;
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

=head2 lock

=head2 unlock

=head2 locked

=head2 check_in

=head2 check_out

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

