#!/usr/bin/env perl

# Pragmas.
use strict;
use warnings;

# Modules.
use Data::Printer;
use WebService::Ares;

# Arguments.
if (@ARGV < 1) {
        print STDERR "Usage: $0 ic\n";
        exit 1;
}
my $ic = $ARGV[0];

# Object.
my $obj = WebService::Ares->new;

# Get data.
my $data_hr = $obj->get('standard', {'ic' => $ic});

# Print data.
p $data_hr;

# Output:
# TODO