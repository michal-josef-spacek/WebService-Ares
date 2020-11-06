use strict;
use warnings;

use Test::More 'tests' => 2;
use Test::NoWarnings;
use WebService::Ares::Rzp;

# Test.
is($WebService::Ares::Rzp::VERSION, 0.04, 'Version.');
