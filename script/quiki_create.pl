#!/usr/bin/perl

$path = shift || '.';

(!-d $path) and warn "$path not found" and exit;

mkdir 'css';

my $file = undef;
while(<DATA>) {
    if (/^----([^-]*)----\n$/) {
        if ($file) {
            print "ok!\n";
            close $file;
        }
        open $file, ">$1" or die;
        print "Creating $1...";
    }
    elsif ($file) {
        print {$file} $_;
    }
}
if ($file) {
    print "ok!\n";
    close $file;
}

chmod 0755, "$path/quiki.cgi";

print "Creating index file.. ";
mkdir "$path/data";
mkdir "$path/data/content";
chmod 0777, "$path/data/content";
open F, ">$path/data/content/index";
print F "Edit me!";
close F;
chmod 0777, "$path/data/content/index";
print "ok!\n";

__DATA__
----index.html----
<META HTTP-EQUIV="Refresh" Content="0; URL=quiki.cgi">
----quiki.cgi----
#!/usr/bin/perl

use lib '### CHANGE ME ###';

use Quiki;

my %conf = (
           'name' => 'MyQuiki'
            );

Quiki->new(%conf)->run;
----css/quiki.css----
.quiki_body { 
  background-color: #ededed;
}

.quiki_body pre { 
  padding: 3px;
  background-color: #dcdcdc;
  border: solid 1px #999999;
}
