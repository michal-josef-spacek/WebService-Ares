use strict;
use warnings;

use Test::More 'tests' => 2;
use Test::NoWarnings;
use WebService::Ares::Basic;

# Test.
is($WebService::Ares::Basic::VERSION, 0.04, 'Version.');
