use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Quiki',
    AUTHOR              => q{Alberto Simoes and Nuno Carvalho <ambs@cpan.org and smash@cpan.org>},
    VERSION_FROM        => 'lib/Quiki.pm',
    ABSTRACT_FROM       => 'lib/Quiki.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
		'CGI' => 0,
        'CGI::Cookie' => 0,
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Quiki-*' },
);
