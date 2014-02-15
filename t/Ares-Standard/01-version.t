# Pragmas.
use strict;
use warnings;

# Modules.
use Ares::Standard;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Ares::Standard::VERSION, 0.01, 'Version.');
