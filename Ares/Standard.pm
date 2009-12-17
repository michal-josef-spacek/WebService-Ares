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
use Encode qw(encode_utf8);

# Constants.
Readonly::Array our @EXPORT_OK => qw(parse parse_file);
Readonly::Scalar my $EMPTY_STR => q{};

# Version.
our $VERSION = 0.01;

#------------------------------------------------------------------------------
sub parse {
#------------------------------------------------------------------------------
# Parse XML string.

	my $xml = shift;

	# XML::Parser object.
	my ($data_hr, $parser) = _init();

	# Parse.
	$parser->parse($xml);

	# Return structure.
	return $data_hr;
}

#------------------------------------------------------------------------------
sub parse_file {
#------------------------------------------------------------------------------
# Parse XML file.

	my $file_path = shift;

	# Check to filepath.
	if (! -r $file_path) {
		err "Cannot exist file '$file_path'.";
	}

	# XML::Parser object.
	my ($data_hr, $parser) = _init();

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
sub _init {
#------------------------------------------------------------------------------
# Initialization.

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
	return ($data_hr, $parser);
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

	# Encode.
	} else {
		$text = encode_utf8($text);
	}

	# Get actual tag name.
	my ($tag_name) = _peek_stack($expat);

	# Process data.
	if ($tag_name eq 'are:ICO') {
		_save($expat, $text, 'ic');
	} elsif ($tag_name eq 'are:Obchodni_firma') {
		_save($expat, $text, 'firm');		
	} elsif ($tag_name eq 'are:Datum_vzniku') {
		_save($expat, $text, 'create_date');
	} elsif ($tag_name eq 'dtt:Nazev_ulice') {
		_save_address($expat, $text, 'street');
	} elsif ($tag_name eq 'dtt:PSC') {
		_save_address($expat, $text, 'psc');
	} elsif ($tag_name eq 'dtt:Cislo_domovni') {
		_save_address($expat, $text, 'num');
	} elsif ($tag_name eq 'dtt:Cislo_orientacni') {
		_save_address($expat, $text, 'num2');
	} elsif ($tag_name eq 'dtt:Nazev_obce') {
		_save_address($expat, $text, 'town');
	} elsif ($tag_name eq 'dtt:Nazev_casti_obce') {
		_save_address($expat, $text, 'town_part');
	} elsif ($tag_name eq 'dtt:Nazev_mestske_casti') {
		_save_address($expat, $text, 'town_urban');
	} elsif ($tag_name eq 'dtt:Nazev_okresu') {
		_save_address($expat, $text, 'district');
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
	_push_stack($expat, $tag_name, {});
	return;
}

#------------------------------------------------------------------------------
# Concrete subroutines.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
sub _save {
#------------------------------------------------------------------------------
# Save common data.

	my ($expat, $text, $key) = @_;

	# Data.	
	my $data_hr = $expat->{'Non-Expat-Options'}->{'data'};

	# Save text.
	$data_hr->{$key} = $text;

	return;
}

#------------------------------------------------------------------------------
sub _save_address {
#------------------------------------------------------------------------------
# Save address data.

	my ($expat, $text, $key) = @_;

	# Data.	
	my $data_hr = $expat->{'Non-Expat-Options'}->{'data'};

	# Save text.
	$data_hr->{'address'}->{$key} = $text;

	return;
}

1;
