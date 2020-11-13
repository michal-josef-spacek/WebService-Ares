#!/usr/bin/env perl

use strict;
use warnings;

use Data::Printer;
use WebService::Ares::Rzp qw(parse);

# Fake XML.
my $xml = <<'END';
# TODO
END

# Parse.
my $data_hr = parse($xml);

# Print.
p $data_hr;

# Output:
# TODO