# Modules.
use Test::More 'tests' => 2;

BEGIN {
	print "Usage tests.\n";
	use_ok('Ares::Standard');
}
require_ok('Ares::Standard');
