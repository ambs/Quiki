#!/usr/bin/perl

$path = shift || '.';

(!-d $path) and warn "$path not found" and exit;

my $html_file=<<'EOF';
<META HTTP-EQUIV="Refresh" Content="0; URL=quiki.cgi">
EOF
print "Creating $path/index.html file.. ";
open F, ">$path/index.html";
print F $html_file;
close F;
print "ok!\n";

my $cgi_file=<<'EOF';
#!/usr/bin/perl

use lib '### CHANGE ME ###';

use Quiki;

my %conf = (
           'name' => 'MyQuiki'
            );

Quiki->new(%conf)->run;
EOF
print "Creating $path/quiki.cgi file.. ";
open F, ">$path/quiki.cgi";
print F $cgi_file;
close F;
chmod 0755, "$path/quiki.cgi";
print "ok!\n";

print "Creating index file.. ";
mkdir "$path/data";
mkdir "$path/data/content";
chmod 0777, "$path/data/content";
open F, ">$path/data/content/index";
print F "Edit me!";
close F;
chmod 0777, "$path/data/content/index";
print "ok!\n";

