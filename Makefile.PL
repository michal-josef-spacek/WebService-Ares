# Pragmas.
use strict;
use warnings;

# Modules.
use ExtUtils::MakeMaker;

# Definition.
WriteMakefile(
	'AUTHOR' => 'Michal Špaček <skim@cpan.org>',
	'NAME' => 'Ares',
	'PREREQ_PM' => {
		'Class::Utils' => 0.01,
		'Encode' => 0,
		'Error::Pure' => 0.01,
		'Exporter' => 0,
		'HTTP::Request' => 0,
		'LWP::UserAgent' => 0,
		'Readonly' => 0,
		'XML::Parser' => 0,
	},
	'VERSION' => 0.01,
	'test' => {
		'TESTS' => 't/Ares/*.t '.
			't/Ares::Standard/*.t',
	},
);
