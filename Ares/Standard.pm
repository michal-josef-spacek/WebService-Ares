#------------------------------------------------------------------------------
package Ares::Standard;
#------------------------------------------------------------------------------

# Pragmas.
use base qw(Exporter);
use strict;
use warnings;

# Modules.
use Error::Simple::Multiple qw(err);
use Readonly;
use XML::Parser;

# Constants.
Readonly::Array our @EXPORT_OK => qw(parse);
Readonly::Scalar my $EMPTY_STR => q{};

# Version.
our $VERSION = 0.01;

#------------------------------------------------------------------------------
sub parse {
#------------------------------------------------------------------------------
# Function for schema parsing.

	my $file_path = shift;

	# Check to filepath.
	if (! -r $file_path) {
		err "Cannot exist file '$file_path'.";
	}

	# XML::Parser object.
	my $data_hr = {};
	my $parser = XML::Parser->new(
		'Handlers' => {
			'Start' => \&_xml_tag_start,
			'End' => \&_xml_tag_end,
			'Char' => \&_xml_char,
		},
		'Non-Expat-Options' => {
			'data' => $data_hr,
			'stack' => [],
		},
	);

	# Parse.
	if (! $parser->parsefile($file_path)) {
		err "Cannot parse file '$file_path'.";
	}

	# Return structure.
	return $data_hr;
}

#------------------------------------------------------------------------------
# Private subroutines..
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
sub _check_stack {
#------------------------------------------------------------------------------
# Parsed data stack check function.

	my ($expat, $tag) = @_;
	my $stack_ar = $expat->{'Non-Expat-Options'}->{'stack'};
	foreach my $i (reverse (0 .. $#{$stack_ar})) {
		if ($stack_ar->[$i]->{'tag'} eq $tag) {
			return $stack_ar->[$i]->{'attr'};
		}
	}
	return;
}

#------------------------------------------------------------------------------
sub _odpoved {
#------------------------------------------------------------------------------
# Process 'are:Odpoved' element.

	my $expat = shift;
}

#------------------------------------------------------------------------------
sub _peek_stack {
#------------------------------------------------------------------------------
# Parsed data stack peek function.

	my $expat = shift;
	if (defined $expat->{'Non-Expat-Options'}->{'stack'}->[-1]) {
		my $tmp_hr = $expat->{'Non-Expat-Options'}->{'stack'}->[-1];
		return ($tmp_hr->{'tag'}, $tmp_hr->{'attr'});
	} else {
		return ($EMPTY_STR, {});
	}
}

#------------------------------------------------------------------------------
sub _pop_stack {
#------------------------------------------------------------------------------
# Parsed data stack pop function.

	my $expat = shift;
	my $tmp_hr = pop @{$expat->{'Non-Expat-Options'}->{'stack'}};
	return ($tmp_hr->{'tag'}, $tmp_hr->{'attr'});
}

#------------------------------------------------------------------------------
sub _push_stack {
#------------------------------------------------------------------------------
# Parsed data stack push function.

	my ($expat, $tag, $attr) = @_;
	my $tmp_hr = {};
	$tmp_hr->{'tag'}  = $tag;
	$tmp_hr->{'attr'} = $attr;
	push @{$expat->{'Non-Expat-Options'}->{'stack'}}, $tmp_hr;
	return;
}

#------------------------------------------------------------------------------
sub _xml_char {
#------------------------------------------------------------------------------
# Characters handler.

	my ($expat, $text) = @_;

	# Drop empty strings.
	if ($text =~ m/^\s*$/sm) {
		return;
	}

	return;
}

#------------------------------------------------------------------------------
sub _xml_tag_end {
#------------------------------------------------------------------------------
# End tags handler.

	my ($expat, $tag_name) = @_;
	_pop_stack($expat);
	return;
}

#------------------------------------------------------------------------------
sub _xml_tag_start {
#------------------------------------------------------------------------------
# Start tags handler.

	my ($expat, $tag_name, @params) = @_;
	foreach ($tag_name) {
		m/^are:Odpoved/ms      && do {
			_odpoved($expat, @params);      last;
		};
		m/^are:Zaznam/ms       && do {
			_zaznam($expat, @params);       last;
		};
		err "Unexpected element '$tag_name'.";
		_push_stack($expat, $tag_name, {});
	}
	return;
}

#------------------------------------------------------------------------------
sub _zaznam {
#------------------------------------------------------------------------------
# Process 'are:Zaznam' element.

	my $expat = shift;
}

1;
