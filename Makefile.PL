# Pragmas.
use strict;
use warnings;

# Modules.
use inc::Module::Install;

# Definition.
abstract 'TODO';
author 'Michal Špaček <skim@cpan.org>';
license 'bsd';
name 'Ares';
readme_from 'Ares.pm';
requires 'Class::Utils' => 0.05;
requires 'Encode' => 0;
requires 'Error::Pure' => 0.16;
requires 'Exporter' => 0;
requires 'HTTP::Request' => 0;
requires 'LWP::UserAgent' => 0;
requires 'Readonly' => 0;
requires 'XML::Parser' => 0;
requires 'perl' => '5.6.2';
resources 'bugtracker' => 'https://rt.cpan.org/Public/Dist/Display.html'.
	'?Name=Ares';
resources 'homepage' => 'https://github.com/tupinek/Ares';
resources 'repository' => 'git://github.com/tupinek/Ares';
test_requires 'English' => 0;
test_requires 'Error::Pure' => 0.11;
test_requires 'File::Object' => 0.05;
test_requires 'Test::More' => 0;
test_requires 'Test::NoWarnings' => 0;
test_requires 'Test::Pod' => 0;
test_requires 'Test::Pod::Coverage' => 0;
tests_recursive;
version '0.01';

# Run.
WriteAll();
