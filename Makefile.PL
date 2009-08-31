use strict;
use warnings;

use 5.010000;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Quiki',
    AUTHOR              => q{Alberto Simoes and Nuno Carvalho <ambs@cpan.org and smash@cpan.org>},
    VERSION_FROM        => 'lib/Quiki.pm',
    ABSTRACT_FROM       => 'lib/Quiki.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    EXE_FILES => [ 'script/quiki_create' ],
    PL_FILES  => { 'script/quiki_create.PL' => 'script/quiki_create' },
    PREREQ_PM => {
                  'CGI'            => 0,
                  'CGI::Session'   => 0,
                  'Test::More'     => 0,
                  'URI::Escape'    => 0,
                  'YAML::Any'      => 0,
                  'File::Slurp'    => 0,
                  'MIME::Base64'   => 0,
                  'DBD::SQLite'    => 0,
                  'Digest::MD5'    => 0,
                  'DBI'            => 0,
                  'Regexp::Common' => '2.122',
                  'Email::Sender'  => 0,
                  'Text::Password::Pronounceable' => '0.28',
                  'Text::Patch'    => 0,
                  'Text::Diff'     => 0,
                  'Email::Simple::Creator' => 0,
                  'HTML::Template::Pro' => 0,

    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Quiki-*' },
);
