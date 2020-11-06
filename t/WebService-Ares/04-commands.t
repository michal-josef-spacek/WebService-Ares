use strict;
use warnings;

use Test::More 'tests' => 2;
use Test::NoWarnings;
use WebService::Ares;

# Test.
my $obj = WebService::Ares->new;
my @ret = $obj->commands;
is_deeply(
	\@ret,
	[
		'rzp',
		'standard',
	],
	'Get commands.',
);
