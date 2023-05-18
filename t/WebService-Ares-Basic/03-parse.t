use strict;
use warnings;

use English;
use Error::Pure::Utils qw(clean);
use File::Object;
use Perl6::Slurp qw(slurp);
use Test::More 'tests' => 3;
use Test::NoWarnings;
use WebService::Ares::Basic qw(parse);

# Data directory.
my $data_dir = File::Object->new->up->dir('data')->dir('basic')->set;

# Test.
my $ret_hr = parse(scalar slurp($data_dir->file('alza_27082440.xml')->s));
is_deeply(
	$ret_hr,
	{
		'addr_id' => 25958895,
		'dic' => 'CZ27082440',
		'ico' => '27082440',
		'name' => 'Alza.cz a.s.',
	},
	'Get information from alza_27082440.xml file.',
);

# Test.
eval {
	parse('foo');
};
is($EVAL_ERROR, "Cannot parse XML string.\n", 'Cannot parse XML string.');
clean()
