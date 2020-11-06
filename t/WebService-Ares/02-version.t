use strict;
use warnings;

use Test::More 'tests' => 2;
use Test::NoWarnings;
use WebService::Ares;

# Test.
is($WebService::Ares::VERSION, 0.04, 'Version.');
