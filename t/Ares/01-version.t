# Modules.
use Ares;
use Test::More 'tests' => 1;

# Debug message.
print "Testing: version.\n";

# Test.
is($Ares::VERSION, '0.01');
