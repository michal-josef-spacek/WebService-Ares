use strict;
use warnings;

use Test::More 'tests' => 2;
use Test::NoWarnings;
use WebService::Ares::Standard;

# Test.
is($WebService::Ares::Standard::VERSION, 0.04, 'Version.');
