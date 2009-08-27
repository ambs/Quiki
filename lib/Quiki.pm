package Quiki;

use feature ':5.10';

use Quiki::Formatter;
use Quiki::Meta;
use Quiki::Users;
use Quiki::Pages;

use warnings;
use strict;

=head1 NAME

Quiki - A lightweight Wiki in Perl

=head1 VERSION

Version 0.01_1

=cut

our $VERSION = '0.01_1';


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
        print STDERR "LOGIN ";
        my $username = param('username') || '';
        my $password = param('password') || '';
        if ($username and $password) {
            Quiki::Users->auth($username,$password) and
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
        Quiki::Pages -> save($node, "Edit me!");
	$self->{session}->param('msg',"New node \"$node\" created.");
    }

    # XXX
    if ($action eq 'save' && param("submit") eq "Save") {
   	my $text = param('text') // '';
        Quiki::Pages->save($node, $text);
	$self->{session}->param('msg',"Content for \"$node\" updated.");
    }

    # XXX
    my $content = Quiki::Pages->load($node);

    my $cookie = cookie('QuikiSID' => $self->{session}->id);
    print header(-charset=>'UTF-8',-cookie=>$cookie);
    print start_html(-title => "$self->{name}::$node",
                     -style =>
                     {
                      code => join("\n",
                                   '@import "css/quiki.css";',
                                   '@import "css/local.css";',
                                   '@import "css/gritter.css";',
                                   '@import "css/textarea.css";')
                     },
                     -script=> [{ -type=>'JAVASCRIPT',
                                  -src=>'js/jquery.js'
                                },
                                { -type=>'JAVASCRIPT',
                                  -src=>'js/jquery.gritter.js'
                                },
                                { -type=>'JAVASCRIPT',
                                  -src=>'js/jquery.floatbox.js'
                                },
                                { -type=>'JAVASCRIPT',
                                  -src=>'js/jquery.textarearesizer.js'
                                },]
                    );


    print start_div({-class=>"quiki_nav_bar"});
    print h3({-id => 'quiki_name'}, $self->{name});
    print h3({-id => 'quiki_nodename'},
             a({href=>"$self->{SCRIPT_NAME}?node=$self->{index}"}, $node));


    # XXX - print and calc trace
    my @trace;
    $self->{session}->param('trace') and @trace=@{$self->{session}->param('trace')};
    push @trace, $node unless $trace[-1] eq $node;
    @trace > 5 and shift @trace;
    $self->{session}->param('trace',\@trace);
    print div({-id=>'quiki_breadcumbs'},
              'Your path: ',
              join(' » ', map { a({-href=>"$self->{SCRIPT_NAME}?node=$_"}, $_); } @trace)
             );

    print end_div; # end nav_bar <div>

    # XXX - show message if we have one
    if ($self->{session}->param('msg')) {
        $self->_show_msg($self->{session}->param('msg'));
        $self->{session}->param('msg','');
    }

    ($action eq 'login_page') and print _login_box();
    ($action eq "register_page") and print _register_box();

    print start_div({-class=>"quiki_body"});

    my $preview = 0;
    if ($action eq 'save' && param("submit") eq "Preview") {
        $preview = 1;
        $action = 'edit';
    }

    if ($action eq 'edit') {
        if ($preview) {
            my $text = param('text') // '';
            print start_div({-class=>"quiki_preview"}),
              h4('Preview'),
                hr,
                  Quiki::Formatter::format($self, $text),
                      hr,
                        end_div; # end quicki_preview <div>
        }

        print script({-type=>'text/javascript'},
                     q!$(document).ready(function() { $('textarea.resizable:not(.processed)').TextAreaResizer(); });!);
        print start_form(-method=>'post'),
          textarea(-name => 'text',
                   -default => $content,
                   -class => 'resizable',
                   -rows => 15, -columns => 80),
                     hidden(-name => 'node', -value => $node, -override => 1),
                       hidden(-name => 'action', -value => 'save', -override => 10);
        #submit('submit', 'save'),
        #end_form;
    }
    elsif ($action eq 'index') {
        opendir(DIR,'data/content/');
        while((my $f = readdir(DIR))){
            unless ($f=~/^\./) {
                print a({-href=>"$self->{SCRIPT_NAME}?node=$f"}, $f), br;
            }
        }
        closedir(DIR);
    }
    else {
        print Quiki::Formatter::format($self, $content);
    }

    # handle meta data
    $self->{meta} = Quiki::Meta::get($node);
    if ($action eq 'save') {
        $self->{meta}->{last_update_by} = $self->{session}->param('username');
        $self->{meta}->{last_updated_in} = `date`; # XXX
        Quiki::Meta::set($node, $self->{meta});
    }

    unless ($action eq 'edit') {
        print div({-class=>"quiki_meta"},
                  "Last edited by ",$self->{meta}{last_update_by},', in ',$self->{meta}{last_updated_in})
    }


    print end_div; # end quiki_body <div>


    $self->_render_menu_bar($node, $action);

    print end_html;
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
<noscript><b>Info! $string</b></noscript>
HTML
}


sub _render_menu_bar {
    my ($self, $node, $action) = @_;

    print( start_div({-class=>"quiki_menu_bar"}),
           start_div({-class=>"quiki_menu_bar_left"}));

    given ($action) {
        when (!/edit/) {
            if ($self->{session}->param('authenticated')) {
                print start_form(-method=>'post'),
                  hidden('node',$node),
                    hidden(-name => 'action', -value => 'edit', -override => 1),
                      submit(-name => 'submit', -value => 'Edit this page', -override => 1),
                        end_form;
                print '&nbsp;&nbsp;|&nbsp;&nbsp;';
                print start_form(-method=>'post'),
                    submit('submit', 'Create new page'),
                      '&nbsp;',
                        textfield(-name=>'node', -value=>'<name>', -size=>8, -override => 1),
                          hidden(-name => 'action', -value => 'create', -override => 1),
                            end_form;
            }
        }
        when (/edit/) {
            print submit(-name => 'submit', -value => 'Cancel', -override => 1),
              '&nbsp;&nbsp;|&nbsp;&nbsp;',
                submit(-name => 'submit', -value => 'Preview', -override => 1),
              '&nbsp;&nbsp;|&nbsp;&nbsp;',
                submit(-name => 'submit', -value => 'Save', -override => 1),
                  end_form;
        }
    }
    print( end_div,  # end menu_bar_left <div>
           start_div({-class=>"quiki_menu_bar_right"}));

    ## Index button
    print start_form(-method=>'post'),
      hidden(-name => 'action', -value => 'index', -override => 1),
        submit(-name => 'submit', -value => 'Index', -override => 1),
          end_form,
            "&nbsp;&nbsp;|&nbsp;&nbsp;";

    ## Login+Sigup/Logout buttons
    if ($self->{session}->param('authenticated')) {
        print start_form(-method=>'post'),
          submit('submit', 'Log out'),
            hidden(-name => 'action', -value => 'logout', -override => 1),
              end_form;
    }
    else {
        print start_form(-method=>'post'),
          hidden(-name => 'action', -value => 'register_page', -override => 1),
            submit('submit', 'Sign up'),
              end_form;
        print "&nbsp;&nbsp;|&nbsp;&nbsp;";
        print start_form(-method=>'post'),
          submit('submit', 'Log in'),
            hidden(-name => 'node', -value => $node, -override => 1),
              hidden(-name => 'action', -value => 'login_page', -override => 1),
                end_form;
    }


    print end_div, # end menu_bar_right <div>
      start_div({-style=>'clear: both;'}),
        end_div. # end empty <div>
          end_div; # end menu_bar <div>
}

sub _register_box {
    return "";
}

sub _login_box {
    my $box = div({-class => 'floatbox_head'}, "Login");
    $box .= div({-class => 'floatbox_body'},
                form({-method => "post"},
                     "Username: ", textfield(-name => "username"), br,
                     "Password: ", textfield(-name => "password"), br, br,
                     hidden(-name=>'action', -value=>'login', -override => 1),
                     submit(-name=>'submit', -value=>'Log in')));

    my $noscript = noscript(form({-method => "post"},
                                 "Username: ", textfield(-name => "username"),
                                 "Password: ", password_field(-name => "password"),
                                 hidden(-name=>'action', -value=>'login', -override => 1),
                                 submit(-name=>'submit', -value=>'Log in')));

    return script({-type=>"text/javascript"},
                  "\$(document).ready(function(){ \$.floatbox({ content: \"$box\" }); });") .
                    $noscript;
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
