package Quiki;

# vim: tabstop=4:softtabstop=4:shiftwidth=4:noexpandtab

use warnings;
use strict;

=head1 NAME

Quiki - A lightweight Wiki in Perl

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Quiki;

    Quiki( %conf );

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 Quiki

=cut

my %conf = (
            'name' => 'defaultName',
           );


sub new {
    my ($class, %args) = @_;
    my $self;

    # XXX
    $self = {%conf, %args};

    $self->{SCRIPT_NAME} = $ENV{SCRIPT_NAME};

    return bless $self, $class;
}

sub run {
    my $self = shift;
    use CGI qw/:standard/;

    # XXX
    my $node = param('node') || 'index';
    my $edit = param('edit') || 0;
    my $save = param('save') || 0;
    my $create = param('create') || 0;

    # XXX
    $node =~ s/\s/_/g;

    # XXX
    if ($create or !-f "data/content/$node") {
   	`echo 'edit me' > data/content/$node`;
   	`chmod 777 data/content/$node`;
    }

    # XXX
    if ($save) {
   	my $text = param('text') || '';
   	open F, "> data/content/$node" or die "can't open file";
   	print F $text;
   	close F;
    }

    # XXX
    my $content = `cat data/content/$node`;

    print header, start_html("$conf{'name'}::$node");
    print h3(a({href=>"http://nrc.homelinux.org/quiki/quiki.cgi?node=index"},
               "$conf{'name'}::$node"));

    if ($edit) {
        print start_form(-method=>'POST'),
          textarea('text',$content,10,50),
            hidden('node',$node),
              hidden('save','1'),
                hr,
                  submit('submit', 'save'),
                    end_form;
    }
    else {
   	print Quiki::Formatter::format($self, $content);
        print hr,
          start_form(-method=>'POST'),
            hidden('node',$node),
              hidden('edit','1'),
                submit('submit', 'edit'),
                  end_form;
        print start_form(-method=>'POST'),
          submit('submit', 'new node'),
            textfield('node','',10).
              hidden('create','1'),
                end_form;
    }
}

=head1 AUTHOR

Alberto Simoes and Nuno Carvalho, C<< <ambs at cpan.org and smash@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-quiki at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Quiki>.  I will be
notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Quiki


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Quiki>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Quiki>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Quiki>

=item * Search CPAN

L<http://search.cpan.org/dist/Quiki/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Alberto Simoes and Nuno Carvalho.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

42; # End of Quiki
