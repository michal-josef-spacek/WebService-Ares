# Pragmas.
use strict;
use warnings;

# Modules.
use WebService::Ares;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($WebService::Ares::VERSION, 0.01, 'Version.');
