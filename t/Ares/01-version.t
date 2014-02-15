# Pragmas.
use strict;
use warnings;

# Modules.
use Ares;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Ares::VERSION, 0.01, 'Version.');
