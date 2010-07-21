package Quiki;

use feature ':5.10';

use Data::Dumper;

use Quiki::Formatter;
use Quiki::Meta;
use Quiki::Users;
use Quiki::Pages;

use CGI qw/:standard *div/;
use CGI::Session;
use HTML::Template::Pro;
use File::MMagic;
use File::Slurp 'slurp';
use Pod::Html;

use warnings;
use strict;

=head1 NAME

Quiki - A lightweight Wiki in Perl

=head1 VERSION

Version 0.05

=cut

our $VERSION = '0.05';


=head1 SYNOPSIS

    use Quiki;

    my %conf = ( name => 'MyQuiki' );
    Quiki->new(%conf)->run;

=head1 EXPORT FUNCTIONS

=head2 new

Creates a new Quiki object.

=head2 run

Runs the Quiki.

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
    $self->{SERVER_NAME} = $ENV{SERVER_NAME};

    $self->{DOCROOT} = $ENV{SCRIPT_NAME};
    $self->{DOCROOT} =~ s!/[^/]+$!/!;

    $self->{QUIKI_ID} = $self->{name} . '_' . slurp 'data/quiki_id';
    return bless $self, $class;
}

sub run {
    my $self = shift;

    $self->{sid} = cookie($self->{QUIKI_ID}) || undef;
    $self->{session} = new CGI::Session(undef, $self->{sid}, undef);

    # XXX
    my $node   = param('node')   || $self->{index};
    my $action = param('action') || '';

    # XXX -- temos de proteger mais coisas, possivelmente
    #        E era giro termos filename e displayname
    $node =~ s/\s/_/g;

    $self->{meta} = Quiki::Meta::get($node);
    $self->{node} = $node;

    if ($action eq 'update_perms') {
        my $username = param('edit_user');
        if (param("admin_action") eq "Delete") {
            if ($username eq "admin") {
                $self->{session}->param('msg', "Admin account can not be deleted.");
            } else {
                Quiki::Users->delete($username);
                $self->{session}->param('msg', "User '$username' deleted.");
            }
        }
        if (param("admin_action") eq "Save") {
            my $perm = param("perms");
            if ($username eq "admin") {
                $self->{session}->param('msg', "Admin account righs can not be changed.");
            } else {
                Quiki::Users->update($username, perm_group => $perm);
                $self->{session}->param('msg', "Permission rights changed for user '$username'.");
            }
        }
        $action = 'admin_page';
    }

    if ($action eq 'save_profile' && param('submit') =~ /^Save/) {
        if (param("new_password1") && (param("new_password1") ne param("new_password2"))) {
            $self->{session}->param('msg', "Passwords do not match. Try again!");
            $action = 'profile_page';
        }
        else {
            my %data;
            $data{password} = param("new_password1") if param("new_password1");
            $data{email}    = param("email")         if param("email");
            Quiki::Users->update($self->{session}->param("username"), %data);
            $self->{session}->param('msg', "Profile Saved.");
        }
    }

    # XXX
    if ($action eq "upload") {
        my $count = 0;
        for (1..3) {
            if (param("filename$_") && param("name$_")) {
                my $id = param("name$_");
                my $path = "data/attach/$node";
                -f $path or (mkdir $path and chown 0777, $path);
                open OUT, ">", "$path/$id" or die "Can't create out file: $!";
                my $filename = param("filename$_");
                my ($buffer, $bytesread);
                while ($bytesread = read($filename, $buffer, 1024)) {
                    print OUT $buffer
                }
                close OUT;
                $count++;
                if (param("description$_")) {
                    open OUT, ">", "$path/_desc_$id" or die "Can't create out file: $!";
                    print OUT param("description$_");
                    close OUT;
                }
            }
        }
        $self->{session}->param('msg', "$count file(s) uploaded.");
    }

    # XXX
    if ($action eq 'register' && param('submit') eq "Register") {
        my $username = param('username') || '';
        my $email    = param('email')    || '';
        if ($username and $email and $email =~ m/\@/) { # XXX -- fix regexp :D
            if (Quiki::Users->exists($username)) {
                $self->{session}->param('msg',
                                        "User name already in use. Please try again!");
                $action = 'register_page';
            }
            else {
                Quiki::Users->create($self, $username, $email);
                $self->{session}->param('msg',
                                        "You are registered! You should receive an e-mail with your password soon.");
            }
        }
        else {
            $self->{session}->param('msg',
                                    "Sign up failed! Perhaps you forgot to fill in the form?");
            $action = 'register_page';
        }
    }

    # XXX
    if ($action eq 'login') {
        my $username = param('username') || '';
        my $password = param('password') || '';
        if ($username and $password and Quiki::Users->auth($username,$password)) {
            $self->{session}->param('authenticated',1) and
              $self->{session}->param('username',$username) and
                $self->{session}->param('msg',"Login successfull! Welcome $username!");
        }
        else {
            $self->{session}->param('msg',"Login failed!");
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
        Quiki::Pages->check_in($self, $node, "Edit me!");
	$self->{session}->param('msg',"New node \"$node\" created.");
    }

    if ($action eq "edit" && Quiki::Pages->locked($node, $self->{sid})) {
        $action = "";
        $self->{session}->param('msg',"Sorry but someone else is currently editing this node!");
    } else {
        Quiki::Pages->lock($node, $self->{sid});
    }

    # XXX
    if ($action eq 'save' && param("submit_opt") eq "Save") {
        if (Quiki::Pages->locked_for_user($node, $self->{sid})) {
            my $text = param('text') // '';
            Quiki::Pages->check_in($self, $node, $text);
            Quiki::Pages->unlock($node);
            $self->{session}->param('msg',"Content for \"$node\" updated.");
        } else {
            $self->{session}->param('msg',"You took too much time! You lost your lock.");
        }
    }

    # XXX
    my $content;
    $self->{rev} = param('rev') || $self->{meta}{rev};
	# sanity check revision number
	if (!($self->{rev} =~ m/\d+/) || $self->{rev}<0 || $self->{rev}>$self->{meta}{rev}) {
    	$self->{rev} = $self->{meta}{rev};
		$self->{session}->param('msg','Revision requested not found.');
	}
    if ($action eq 'rollback') {
        $content = Quiki::Pages->check_out($self,$node,$self->{rev});
        Quiki::Pages->check_in($self, $node, $content);
        $self->{rev} = $self->{meta}{rev};
    }
    else {
    	$content = Quiki::Pages->check_out($self,$node,$self->{rev});
    }


    my $cookie = cookie($self->{QUIKI_ID} => $self->{session}->id);
    print header(-charset=>'UTF-8',-cookie=>$cookie);

    # Calculate breadcumbs
    my @trace;
    @trace = @{$self->{session}->param('trace')} if $self->{session}->param('trace');
    push @trace, $node unless @trace;
    if ($trace[-1] ne $node) {
        push @trace, $node;
        @trace > 5 and shift @trace;
    }
    $self->{session}->param('trace',\@trace);
    my $breadcumbs = join(' » ', map { a({-href=>"$self->{SCRIPT_NAME}?node=$_"}, $_); } @trace);


    my $preview = 0;
    if ($action eq 'save' && param("submit_opt") eq "Preview") {
        $preview = 1;
        $action = 'edit';
    }
    if ($action eq 'save' && param("submit_opt") eq "Cancel") {
        Quiki::Pages->unlock($node);
    }

    my $username = ($self->{session}->param('authenticated')?
                    $self->{session}->param('username'):"guest");
    ## XXX - Later, join these functions to query database only once
    my $email    = Quiki::Users->email($username);
    my $urole    = Quiki::Users->role($username);
    my $theme    = $self->{theme} || 'default';

    my $template = HTML::Template::Pro->new(filename => "themes/$theme/wrapper.tmpl",
                                            global_vars => 1);
    $template->param(WIKINAME    => $self->{name},
                     USERNAME    => $username,
                     WIKINODE    => $node,
                     WIKISCRIPT  => $self->{SCRIPT_NAME},
                     MAINNODE    => $self->{index},
                     ACTION      => $action,
                     AUTHENTICATED => $self->{session}->param('authenticated'),
                     LAST_REV    => (($self->{rev} || 0) == ($self->{meta}{rev} || 0)),
                     REV         => $self->{rev},
                     BREADCUMBS  => $breadcumbs,
                     SERVERNAME  => $self->{SERVER_NAME},
                     DOCROOT     => $self->{DOCROOT},
                     OPENSITE    => $self->{opensite} // 1,
                     USER_ROLE   => $urole,
                     PREVIEW     => $preview,
                    );

    if ($action eq 'profile_page') {
        $template->param(EMAIL       => $email,
                         GRAVATAR    => Quiki::Users->gravatar($username));
    }

    if ($action eq 'edit') { # && 
#        ($preview || !Quiki::Pages->locked($node, $self->{sid}))) {
        if ($preview) {
            my $text = param('text') // '';
            $template->param(CONTENT=>Quiki::Formatter::format($self, $text));
            $template->param(TEXT=>$text);
        }
        else {
            $template->param(TEXT=>$content);
        }

        if (-d "data/attach/$node") {
            my @attachs;
            opendir DIR, "data/attach/$node";
            my $mm = new File::MMagic;
            my %desc;
            for my $f (sort { lc($a) cmp lc($b)  } readdir(DIR)) {
                next if $f =~ /^\.\.?$/;
                my $filename = "data/attach/$node/$f";
                if ($f =~ m!_desc_(.*)!) { $desc{$1} = slurp $filename }
                else {
                    ## XXX - TODO - Put this elsewhere
                    my $mime = $mm->checktype_filename( $filename );
                    my $mimeimg;
                    given ($mime) {
                        when (/image/) { $mimeimg = "mime_image.png"   }
                        when (/pdf/)   { $mimeimg = "mime_pdf.png"     }
                        when (/zip/)   { $mimeimg = "mime_zip.png"     }
                        default        { $mimeimg = "mime_default.png" }
                    }
                    push @attachs, { ID      => $f,
                                     MIME    => $mime,
                                     SIZE    => sprintf("%.0f",((stat($filename))[7] / 1024)),
                                     MIMEIMG => $mimeimg };
                }
            }
            for (@attachs) {
                $_->{DESC} = $desc{$_->{ID}}
            }
            $template->param(ATTACHS => \@attachs);
        }
    }
    elsif ($action eq 'history') {

        my @revs;
        for (my $i=$self->{meta}{rev} ; $i>0 ; $i--) {
            my $entry = { VERSION => $i };
            if ($i != $self->{meta}{rev}) {
                $entry->{AUTHOR} = $self->{meta}{revs}{$i}{last_update_by};
                $entry->{DATE} =  $self->{meta}{revs}{$i}{last_updated_in};
                $entry->{GRAVATAR} = Quiki::Users->gravatar($self->{meta}{revs}{$i}{last_update_by});
            }
            else {
                $entry->{AUTHOR} = $self->{meta}{last_update_by};
                $entry->{DATE} =  $self->{meta}{last_updated_in};
                $entry->{GRAVATAR} = Quiki::Users->gravatar($self->{meta}{last_update_by});
            }
            push @revs, $entry;
        }
        $template->param(REVISIONS => \@revs);
    }
    elsif ($action eq 'admin_page') {
        my $users = Quiki::Users->list;
        $template->param(USERS => $users);
    }
    elsif ($action eq 'index') {
        opendir DIR, 'data/content/';
        my @pages;
        for my $f (sort { lc($a) cmp lc($b) } readdir(DIR)) {
            unless ($f=~/^\./) {
                my $meta = Quiki::Meta::get($f);
                push @pages, 
                  { URL => "$self->{SCRIPT_NAME}?node=$f",
                    NAME => $f,
                    AUTHOR => $meta->{last_update_by},
                    DATE => $meta->{last_updated_in},
                    GRAVATAR => Quiki::Users->gravatar($meta->{last_update_by}),
                  }
              }
        }
        closedir DIR;
        $template->param(PAGES=>\@pages);
    }
    elsif ($action eq 'diff') {
        my $source = param('source') || 1;
        my $target = param('target') || 1;
        $template->param(CONTENT=>Quiki::Pages->calc_diff($self,$node,$source,$target));
    }
    else {
        $template->param(CONTENT=>Quiki::Formatter::format($self, $content));
    }


    # handle meta data
    if ($action eq 'save' or $action eq 'rollback') {
        $self->{meta}{last_update_by} = $self->{session}->param('username');
        $self->{meta}{last_updated_in} = `date`; # XXX -- more legible?
        chomp $self->{meta}->{last_updated_in};
    }

    unless ($action eq 'edit') {
        my $L_META;
        if ($self->{meta}{last_update_by}) {
            my $url = Quiki::Users->gravatar($self->{meta}{last_update_by});
            $L_META = img({-src => $url, -width => '24', -style => 'vertical-align: middle'});
            $L_META .= sprintf("&nbsp;Last edited by %s, in %s",
                               $self->{meta}{last_update_by},
                               $self->{meta}{last_updated_in} || "");
        }
        else {
            $L_META = "";
        }
        my $R_META = sprintf("Revision: %s", $self->{meta}{rev} || "");

        $template->param(L_META=>$L_META);
        $template->param(R_META=>$R_META);
    }

    if ($self->{session}->param('msg')) {
        $template->param(MSG=>$self->{session}->param('msg'));
        $self->{session}->param('msg','');
    }

    # save meta data
    Quiki::Meta::set($node, $self->{meta});
    $template->output(print_to => \*STDOUT);
}

=head1 QUIKI CONFIGURATION FILE

After a Quiki wiki is deployed with C<< quiki_create >> a
C<< quiki.conf >> file can be edited to configure Quiki behavior. While
later versions might offer a web interface to configure them, at
present you need to use a text editor and change the file.  Note that
it is a Perl file. Therefore it should parse correctly by Perl. You
can check it using C<< perl -c quiki.conf >>.

Quiki configuration file supports the following keys:

=over 4

=item name

The display name for your wiki

=item theme

The theme to be used. Note that at the time we are writing this only
the C<< default >> theme exists

=item index

The name of the main quiki page. It defaults to C<< index >>.

=item opensite

This is a boolean value. By default it is true (1), meaning the
register button will be available to everybody visiting your
Quiki. Turn it off setting it to false (0).

At the current moment there isn't any other way to register. Therefore
you should turn registering off only after all users have an account,
or you need to turn it off manually everytime a new user has to
register.

=back


=head1 QUIKI SYNTAX

Quiki wiki syntax is very similar to other wiki, and especially
similar with dokuwiki syntax.

=over 4

=item *

To force a paragraph give a blank line;

=item *

To refer to another node use: C<[[NodeName]]> or C<[[NodeName|Node Description]]>;

=item *

To link the Internet use just the URL and it should be highlighted

=item *

You can also create named links with: C<[[URL|URL Description]]>

=item * Basic formatting:

=over 4

=item *

Bolds: C<**bold**>;

=item *

Italics: C<//italic//>;

=item *

Underlines: C<__underline__>;

=item *

Typewriter: C<< ''typewriter'' >>;

=back

=item *

Six levels of headings:

=over 4

=item *

Stronger: C<====== title ======>

=item *

Weaker: C<= title =>

=back

=item *

Hard rules are obtained with ten or more dashes: C<--------------->

=item *

Code/verbatim zones are blocks with all lines indented three spaces.

=item * Lists:

=over 4

=item *

Ordered lists as a dash C<->

=item *

Unordered lists as an asterisk C<*>

=item *

Each item with two spaces before the mark

=item *

Deeper levels have multiples of two spaces indentation

=back

=item *

Tables:

=over 4

=item *

Table headers separated by a carret character ^. Note that no space should exist in the beginning of the line.

=item *

Table rows separated by a pipe character |. Note that no space should exist in the beginning of the line.

=item *

Each cell (not header) will be formatted accordingly with the ascii alignment:

=over 4

=item *

put the content at the left without spaces, to get left alignment: C<< |foo | >>

=item *

put the content at the right without spaces, to get right alignment: C<< | foo| >>

=item *

put the content at the center, with spaces both sides, to get center alignment: C<< | foo | >>

=back

=back

=back

=head1 QUIKI DEPLOYMENT

=over 4

=item 1

Install the Quiki Perl module

    $ cpan Quiki

=item 2

Use the quiki_create Perl script

    $ mkdir /var/www/html/myquiki
    $ quiki_create /var/www/html/myquiki

=item 3

Configure your Apache accordingly.

Sample VirtualHost for Apache2:

      <VirtualHost *:80>
         ServerName quiki.server.com
         DocumentRoot /var/www/html/myquiki
         ServerAdmin admin@quiki.server.com
         DirectoryIndex index.html
       
         <Directory /var/www/html/myquiki>
            Options +ExecCGI
            AddHandler cgi-script .cgi
         </Directory>
      </VirtualHost>

=back

=head1 AUTHOR

=over 4

=item * Alberto Simoes, C<< <ambs at cpan.org> >>

=item * Nuno Carvalho, C<< <smash at cpan.org >>

=back

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

Thank you Luis 'Houser' Fernandes for the default theme layout design.

=head1 COPYRIGHT & LICENSE

Copyright 2009-2010 Alberto Simoes and Nuno Carvalho.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

42; # End of Quiki

