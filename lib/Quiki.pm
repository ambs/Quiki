package Quiki;

use feature ':5.10';

use Quiki::Formatter;
use Quiki::Meta;
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

    my %conf = ( name => 'MyQuiki' );
    Quiki->new(%conf)->run;

=head1 EXPORT FUNCTIONS

=head2 new

Creates a new Quiki object.

=head2 run

Runs de Quiki.

=cut


sub new {
    my ($class, %args) = @_;
    my $self;

    # XXX
    my %conf = (
                name  => 'defaultName',
                index => 'index', # index node
               );
    $self = {%conf, %args};

    $self->{SCRIPT_NAME} = $ENV{SCRIPT_NAME};

    return bless $self, $class;
}

sub run {
    my $self = shift;

    # XXX -- É diferente fazê-lo aqui ou globalmente?
    use CGI qw/:standard *div/;
    use CGI::Session;

    $self->{sid} = cookie("QuikiSID") || undef;
    $self->{session} = new CGI::Session(undef, $self->{sid}, undef);

    # XXX
    my $node   = param('node')   || $self->{index};
    my $action = param('action') || '';

    # XXX -- temos de proteger mais coisas, possivelmente
    $node =~ s/\s/_/g;

    # XXX
    if ($action eq 'login') {
        my $username = param('username') || '';
        my $password = param('password') || '';
        if ($username and $password) {
            $self->_auth($username,$password) and
              $self->{session}->param('authenticated',1) and
                $self->{session}->param('username',$username) and
				  $self->{session}->param('msg',"Login successfull! Welcome $username");
        }
    }

    # XXX
    if ($action eq 'logout') {
        $self->{session}->param('authenticated') and
          $self->{session}->param('authenticated',0) and
            $self->{session}->param('username','') and
              $self->{session}->param('msg','Logout successfull!');
    }

    # XXX
    ($action eq 'create') and (-f "data/content/$node") and ($action = '');
    if( ($action eq 'create') or !-f "data/content/$node") {
   	`echo 'edit me' > data/content/$node`;
   	`chmod 777 data/content/$node`;
	$self->{session}->param('msg',"New node \"$node\" created.");
    }

    # XXX
    if ($action eq 'save' && param("submit") eq "save") {
   	my $text = param('text') // '';
   	open F, ">data/content/$node" or die "can't open file";
   	print F $text;
   	close F;
	$self->{session}->param('msg',"Content for \"$node\" updated.");
    }

    # XXX
    my $content = `cat data/content/$node`;

    my $cookie = cookie('QuikiSID' => $self->{session}->id);
    print header(-charset=>'UTF-8',-cookie=>$cookie);
    print start_html(-title => "$self->{name}::$node",
                     -style =>
                     {
                      code => " \@import \"css/quiki.css\";\n \@import \"css/local.css\"; \@import \"css/gritter.css\"; "
                     },
                     -script=> [{ -type=>'JAVASCRIPT',
                                  -src=>'js/jquery.js'
                                },
                                { -type=>'JAVASCRIPT',
                                  -src=>'js/jquery.gritter.js'
                                }]
                    );

    # XXX - show message if we have one
    if ($self->{session}->param('msg')) {
        $self->_show_msg($self->{session}->param('msg'));
        $self->{session}->param('msg','');
    }

    print start_div({-class=>"quiki_nav_bar"});
    print h3(a({href=>"$self->{SCRIPT_NAME}?node=$self->{index}"},
               "$self->{name}::$node"));


    # XXX - print and calc trace
    my @trace;
    $self->{session}->param('trace') and @trace=@{$self->{session}->param('trace')};
    push @trace, $node unless $trace[-1] eq $node;
    @trace > 5 and shift @trace;
    $self->{session}->param('trace',\@trace);
    print 'Trace: ', join(' » ', map { a({-href=>"$self->{SCRIPT_NAME}?node=$_"}, $_); } @trace);

    print end_div, # end nav_bar <div>
      start_div({-class=>"quiki_body"});

    if ($action eq 'edit') {
        print start_form(-method=>'post'),
          textarea(-name => 'text',
                   -default => $content,
                   -class => 'quiki_widetextarea',
                   -rows => 15, -columns => 80),
                     hidden(-name => 'node', -value => $node, -override => 1),
                       hidden(-name => 'action', -value => 'save', -override => 10);
        #submit('submit', 'save'),
        #end_form;
    }
    elsif ($action eq 'index') {
        opendir(DIR,'data/content/');
        while((my $f = readdir(DIR))){
            unless ($f=~/^\./) { print a({-href=>"$self->{SCRIPT_NAME}?node=$f"}, $f), br;  }
        }
        closedir(DIR);
    }
    else {
        print Quiki::Formatter::format($self, $content);
    }
    print end_div; # end quiki_body <div>

   # handle meta data
   $self->{meta} = Quiki::Meta::get($node);
   if ($action eq 'save') {
      $self->{meta}->{last_update_by} = $self->{session}->param('username');
      $self->{meta}->{last_updated_in} = `date`;
      Quiki::Meta::set($node, $self->{meta});
   }
   print "Last edited by ",$self->{meta}->{last_update_by},', in ',$self->{meta}->{last_updated_in} unless($action eq 'edit');

    $self->_render_menu_bar($node, $action);

    print end_html;
}

sub _auth {
    my ($self, $username, $password) = @_;

    use Apache::Htpasswd;

    # XXX - mais cedo ou mais tarde passar para DBD::SQLite para ter mais info por user
    my $passwd = new Apache::Htpasswd("./passwd");
    $passwd->htCheckPassword($username, $password);
}

sub _show_msg {
    my ($self, $string) = @_;
print<<"HTML";
<script type="text/javascript">
    \$(document).ready(function(){
            \$.gritter.add({
                title: 'Info!',
                text: '$string',
            });
    });
</script>
HTML
}

sub _render_menu_bar {
    my ($self, $node, $action) = @_;

    print( start_div({-class=>"quiki_menu_bar"}),
           start_div({-class=>"quiki_menu_bar_left"}));

    given($action) {
        when(!/edit/) {
            if ($self->{session}->param('authenticated')) {
                print start_form(-method=>'post'),
                  hidden('node',$node),
                    hidden(-name => 'action', -value => 'edit', -override => 1),
                      submit(-name => 'submit', -value => 'edit', -override => 1),
                        end_form;
                print start_form(-method=>'post'),
                  '&nbsp;&nbsp;&nbsp;&nbsp;',
                    submit('submit', 'new node'),
                      '&nbsp;&nbsp;',
                        textfield(-name=>'node', -value=>'<name>', -size=>8, -override => 1),
                          hidden(-name => 'action', -value => 'create', -override => 1),
                            end_form;
            }
        }
        when(/edit/) {
            print submit(-name => 'submit', -value => 'cancel', -override => 1),
              submit(-name => 'submit', -value => 'save', -override => 1),
                end_form;
        }
    }
    print( end_div,  # end menu_bar_left <div>
           start_div({-class=>"quiki_menu_bar_right"}));
    if ($self->{session}->param('authenticated')) {
        print start_form(-method=>'post'),
          submit('submit', 'logout'),
            hidden(-name => 'action', -value => 'logout', -override => 1),
              end_form;
    }
    else {
        print start_form(-method=>'post'),
          "Username: ", textfield('username','',6),
            " Password: ", password_field('password','',6),
              hidden(-name => 'action', -value => 'login', -override => 1),
                submit('submit', 'login'),
                  end_form;
    }
    print start_form(-method=>'post'),
      hidden(-name => 'action', -value => 'index', -override => 1),
        submit(-name => 'submit', -value => 'index', -override => 1),
          end_form;
    print end_div, # end menu_bar_right <div>
      start_div({-style=>'clear: both;'}),
        end_div; # end empty <div>
    end_div; # end menu_bar <div>
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
