package Quiki;

use Quiki::Formatter;
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

    my %conf = (
               'name' => 'MyQuiki'
                );

    Quiki->new(%conf)->run;

=head1 EXPORT FUNCTIONS

=head2 new

=head2 run

=cut



sub new {
    my ($class, %args) = @_;
    my $self;

    # XXX
    # Make it local O:-)
    my %conf = (
                'name' => 'defaultName',
                'index' => 'index', # index node
               );
    $self = {%conf, %args};

    $self->{SCRIPT_NAME} = $ENV{SCRIPT_NAME};

    return bless $self, $class;
}

sub run {
    my $self = shift;

    use CGI qw/:standard/;
	use CGI::Session;

    my $sid = cookie("QuikiSID") || undef;
    my $session = new CGI::Session(undef, $sid, undef);

    # XXX
    my $node = param('node') || $self->{index};
    my $action = param('action') || '';

    # XXX
    $node =~ s/\s/_/g;

	# XXX
	if ($action eq 'login') {
		my $username = param('username') || '';
		my $password = param('password') || '';
		if ($username and $password) {
			$self->auth($username,$password) and $session->param('authenticated',1) and $session->param('username',$username);;
		}
		print redirect("$self->{SCRIPT_NAME}?node=$self->{index}");
	}

	# XXX
	if ($action eq 'logout') {
		$session->param('authenticated') and $session->param('authenticated',0) and  $session->param('username','');
	}

    # XXX
	($action eq 'create') and (-f "data/content/$node") and ($action = '');
    if( ($action eq 'create') or !-f "data/content/$node") {
   	`echo 'edit me' > data/content/$node`;
   	`chmod 777 data/content/$node`;
    }

    # XXX
    if ($action eq 'save') {
   	my $text = param('text') // '';
   	open F, "> data/content/$node" or die "can't open file";
   	print F $text;
   	close F;
    }

    # XXX
    my $content = `cat data/content/$node`;

	my $cookie = cookie('QuikiSID' => $session->id);
    print header(-charset=>'UTF-8',-cookie=>$cookie);
    print start_html("$self->{name}::$node");
    print h3(a({href=>"$self->{SCRIPT_NAME}?node=$self->{index}"},
               "$self->{name}::$node"));

    if ($action eq 'edit') {
        print start_form(-method=>'post'),
          textarea('text',$content,15,80),
            hidden('node',$node),
			  "<input type='hidden' name='action' value='save' />",
                hr,
                  submit('submit', 'save'),
                    end_form;
    }
    else {
   	print Quiki::Formatter::format($self, $content);
		if ($session->param('authenticated')) {
			print hr,
			  "Username: ",
				$session->param('username'),
			  start_form(-method=>'post'),
				hidden('node',$node),
				  hidden('action','edit'),
					submit('submit', 'edit'),
					  end_form;
			print start_form(-method=>'post'),
			  submit('submit', 'new node'),
				textfield('node','',10),
			  	  hidden('action','create'),
					end_form;
            print start_form(-method=>'post'),
              submit('submit', 'logout'),
                  hidden('action','logout'),
                    end_form;
		}
		else {
			print hr,
              start_form(-method=>'post'),
				"Username: ", textfield('username','',10),
				  " Password: ", password_field('password','',10),
					hidden('action','login'),
                      submit('submit', 'login'),
                        end_form;
		}
    }

	print end_html;
}

sub auth {
	my ($selt, $username, $password) = @_;

	use Apache::Htpasswd;

	my $passwd = new Apache::Htpasswd("./passwd");
    $passwd->htCheckPassword($username, $password);
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
