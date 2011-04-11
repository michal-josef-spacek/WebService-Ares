# Modules.
use ExtUtils::MakeMaker;

# Definition.
WriteMakefile(
	'NAME' => 'Ares',
	'PREREQ_PM' => {
		'Class::Utils' => 0.01,
		'Error::Simple::Multiple' => 0.05,
		'Readonly' => 0,
	},
	'VERSION' => 0.01,
	'test' => {
		'TESTS' => 't/Ares/*.t '.
			't/Ares::Standard/*.t',
	},
);
