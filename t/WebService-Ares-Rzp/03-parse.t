use strict;
use warnings;

use English;
use Error::Pure::Utils qw(clean);
use File::Object;
use Perl6::Slurp qw(slurp);
use Test::More 'tests' => 3;
use Test::NoWarnings;
use Unicode::UTF8 qw(decode_utf8);
use WebService::Ares::Rzp qw(parse);

# Data directory.
my $data_dir = File::Object->new->up->dir('data')->dir('rzp')->set;

# Test.
my $ret_hr = parse(scalar slurp($data_dir->file('pribor_20201106.xml')->s));
is_deeply(
	$ret_hr,
	{
		'person' => {
			'date_of_birth' => '1980-09-10',
			'given_name' => 'Jan',
			'family_name' => decode_utf8('Malík'),
			'role' => 'S',
		},
		'date_change' => '2018-11-14',
	},
	'Get information from pribor_20201106.xml file.',
);

# Test.
eval {
	parse('foo');
};
is($EVAL_ERROR, "Cannot parse XML string.\n", 'Cannot parse XML string.');
clean()
