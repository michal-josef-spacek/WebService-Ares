package WebService::Ares::Standard;

# Pragmas.
use base qw(Exporter);
use strict;
use warnings;

# Modules.
use Encode qw(encode_utf8);
use English;
use Error::Pure qw(err);
use Readonly;
use XML::Parser;

# Constants.
Readonly::Array our @EXPORT_OK => qw(parse);
Readonly::Scalar my $EMPTY_STR => q{};

# Version.
our $VERSION = 0.01;

# Parse XML string.
sub parse {
	my $xml = shift;

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
	eval {
		$parser->parse($xml);
	};
	if ($EVAL_ERROR) {
		my $err = $EVAL_ERROR;
		$err =~ s/^\n+//msg;
		chomp $err;
		err 'Cannot parse XML string.',
			'XML::Parser error', $err;
	}

	# Return structure.
	return $data_hr;
}

# Parsed data stack check function.
sub _check_stack {
	my ($expat, $tag) = @_;
	my $stack_ar = $expat->{'Non-Expat-Options'}->{'stack'};
	foreach my $i (reverse (0 .. $#{$stack_ar})) {
		if ($stack_ar->[$i]->{'tag'} eq $tag) {
			return $stack_ar->[$i]->{'attr'};
		}
	}
	return;
}

# Parsed data stack peek function.
sub _peek_stack {
	my $expat = shift;
	if (defined $expat->{'Non-Expat-Options'}->{'stack'}->[-1]) {
		my $tmp_hr = $expat->{'Non-Expat-Options'}->{'stack'}->[-1];
		return ($tmp_hr->{'tag'}, $tmp_hr->{'attr'});
	} else {
		return ($EMPTY_STR, {});
	}
}

# Parsed data stack pop function.
sub _pop_stack {
	my $expat = shift;
	my $tmp_hr = pop @{$expat->{'Non-Expat-Options'}->{'stack'}};
	return ($tmp_hr->{'tag'}, $tmp_hr->{'attr'});
}

# Parsed data stack push function.
sub _push_stack {
	my ($expat, $tag, $attr) = @_;
	my $tmp_hr = {};
	$tmp_hr->{'tag'}  = $tag;
	$tmp_hr->{'attr'} = $attr;
	push @{$expat->{'Non-Expat-Options'}->{'stack'}}, $tmp_hr;
	return;
}

# Characters handler.
sub _xml_char {
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

# End tags handler.
sub _xml_tag_end {
	my ($expat, $tag_name) = @_;
	_pop_stack($expat);
	return;
}

# Start tags handler.
sub _xml_tag_start {
	my ($expat, $tag_name, @params) = @_;
	_push_stack($expat, $tag_name, {});
	return;
}

# Save common data.
sub _save {
	my ($expat, $text, $key) = @_;

	# Data.	
	my $data_hr = $expat->{'Non-Expat-Options'}->{'data'};

	# Save text.
	$data_hr->{$key} = $text;

	return;
}

# Save address data.
sub _save_address {
	my ($expat, $text, $key) = @_;

	# Data.	
	my $data_hr = $expat->{'Non-Expat-Options'}->{'data'};

	# Save text.
	$data_hr->{'address'}->{$key} = $text;

	return;
}

1;
