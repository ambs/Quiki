package Quiki::Attachments;
use File::MMagic;
use CGI qw/:standard/;
use File::Slurp 'slurp';

our $VERSION = 0.01;

sub save_attach {
    my ($self, $param, $out) = @_;
    open OUT, ">", $out or die "Can't create out file: $!";
    my $filename = param($param);
    my ($buffer, $bytesread);
    while ($bytesread = read($filename, $buffer, 1024)) {
        print OUT $buffer
    }
    close OUT;
}


sub list {
    my ($self, $node) = @_;
    my $folder = "data/attach/$node";
    my %desc;
    my @attachs;
    my $mm = new File::MMagic;
    opendir DIR, $folder;
    for my $f (sort { lc($a) cmp lc($b)  } readdir(DIR)) {
        next if $f =~ /^\.\.?$/;
        my $filename = "data/attach/$node/$f";
        if ($f =~ m!_desc_(.*)!)
          {
              $desc{$1} = slurp $filename
          }
        else
          {
              my $mime = $mm->checktype_filename( $filename );
              my $mimeimg = "mime_default.png";
              $mimeimg = "mime_image.png" if $mime =~ /image/;
              $mimeimg = "mime_pdf.png"   if $mime =~ /pdf/;
              $mimeimg = "mime_zip.png"   if $mime =~ /zip/;
              push @attachs, { ID      => $f,
                               MIME    => $mime,
                               SIZE    => sprintf("%.0f",((stat($filename))[7] / 1024)),
                               MIMEIMG => $mimeimg };
          }
    }
    for (@attachs) {
        $_->{DESC} = $desc{$_->{ID}}
    }
    return \@attachs;
}



"42";

=head1 NAME

Quiki::Attachments - Quiki attachments manager

=head1 SYNOPSIS

  Quiki::Attachments->list($node);

=head1 DESCRIPTION

This module handles the needed operations to maintain the page
attachments.

=head2 list

lists specific node attachments

=head2 save_attach

temporary function to save attachments. Should be replaced/bettened soon.

=head1 SEE ALSO

Quiki, perl(1)

=head1 AUTHOR

Alberto Simões, E<lt>ambs@cpan.orgE<gt>
Nuno Carvalho, E<lt>smash@cpan.orgE<gt>

=head1 COPYRIGHT & LICENSE

Copyright 2009-2010 Alberto Simoes and Nuno Carvalho.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

