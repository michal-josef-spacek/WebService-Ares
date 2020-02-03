use strict;
use warnings;

use Test::More 'tests' => 3;
use Test::NoWarnings;

BEGIN {

	# Test.
	use_ok('WebService::Ares::Standard');
}

# Test.
require_ok('WebService::Ares::Standard');
