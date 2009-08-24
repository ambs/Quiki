#!/usr/bin/perl -s

use File::Copy;

our ($force);

$path = shift || '.';

(!-d $path) and warn "$path not found" and exit;

print "Creating dirs:\n";
my @paths = qw!css data data/content images js!;

for my $p (@paths) {
    print " - $p...";
    if (!-d "$path/$p") {
        mkdir "$path/$p";
        print " created.\n";
    } else {
        print " skipped.\n";
    }
}

print "Creating files:\n";
create_files_from_data($path);

print "Copying needed files... ";
my @dirs_to_copy = qw!css js images!; # inside Site/
for my $d (@dirs_to_copy) {
	opendir(DIR, "Site/$d");
	while (defined($f = readdir(DIR))) {
		copy("Site/$d/$f", "$path/$d/$f");
	}
	closedir(DIR);
}
print "done.\n";

print "Setting up permissions... ";
chmod 0755, "$path/quiki.cgi";
chmod 0777, "$path/data/content";
chmod 0777, "$path/data/content/index";
print "done.\n";

sub create_files_from_data {
    my $path = shift;
    my $file = undef;
    while(<DATA>) {
        if (/^(!!|)----([^-]*)----\n$/) {
            if ($file) {
                print " created.\n";
                close $file;
            }
            my $f = $2;
            if ($force || !-f "$path/$f" || $1) {
                print " - $f...";
                open $file, ">$path/$f" or die;

            }
            else {
                print " - $f... skipped.\n";
                $file = undef;
            }
        }
        elsif ($file) {
            print {$file} $_;
        }
    }
    if ($file) {
        print " created.\n";
        close $file;
    }
}


=head1 NAME

quiki_create.pl - Deploys a Quiki!

=head1 SYNOPSIS

  quiki_create.pl /path/to/your/new/quiki/apache/dir

=head1 DESCRIPTION

Creates the needed files for a Quiki installation.

=head1 SEE ALSO

Quiki

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


__DATA__
----data/content/index----
Edit me!
!!----index.html----
<META HTTP-EQUIV="Refresh" Content="0; URL=quiki.cgi">
!!----quiki.cgi----
#!/usr/bin/perl

use lib '### CHANGE ME ###';

use Quiki;

my %conf = (
           'name' => 'MyQuiki'
            );

Quiki->new(%conf)->run;
----css/local.css----
/* Use this file for your own stylesheet */
!!----css/quiki.css----
/* Use local.css for your custom stylesheet */

.quiki_body {
  background-color: #ededed;
  padding: 5px;
}

.quiki_body pre {
  margin: 5px;
  padding: 3px;
  background-color: #dcdcdc;
  border: solid 1px #999999;
}
