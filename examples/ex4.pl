#!/usr/bin/env perl

# Pragmas.
use strict;
use warnings;

# Modules.
use Data::Printer;
use WebService::Ares::Standard qw(parse);

# Fake XML.
my $xml = 'TODO';

# Parse.
my $data_hr = parse($xml);

# Print.
p $data_hr;

# Output:
# TODO