package WebService::Ares::Rzp;

use base qw(Exporter);
use strict;
use warnings;

use English;
use Error::Pure qw(err);
use Readonly;
use XML::Parser;

# Constants.
Readonly::Array our @EXPORT_OK => qw(parse);
Readonly::Scalar my $EMPTY_STR => q{};

our $VERSION = 0.04;

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
	}

	# Get actual tag name.
	my ($tag_name) = _peek_stack($expat);

	# Process data.
	if ($tag_name eq 'D:Role') {
		_save_person($expat, $text, 'role');
	} elsif ($tag_name eq 'D:J') {
		_save_person($expat, $text, 'given_name');
	} elsif ($tag_name eq 'D:P') {
		_save_person($expat, $text, 'family_name');
	} elsif ($tag_name eq 'D:DN') {
		_save_person($expat, $text, 'date_of_birth');
	} elsif ($tag_name eq 'D:TP') {
		_save_person($expat, $text, 'title');
	} elsif ($tag_name eq 'D:Datum_zmeny') {
		_save($expat, $text, 'date_change');
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

# Save person data.
sub _save_person {
	my ($expat, $text, $key) = @_;

	# Data.	
	my $data_hr = $expat->{'Non-Expat-Options'}->{'data'};

	# Save text.
	$data_hr->{'person'}->{$key} = $text;

	return;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

WebService::Ares::Rzp - Perl XML::Parser parser for ARES RZP XML file.

=head1 SYNOPSIS

 use WebService::Ares::Rzp qw(parse);

 my $data_hr = parse($xml);

=head1 DESCRIPTION

 This module parses XML file from ARES system.
 Module parse these information from XML file:
 - date_change
 - date_of_birth
 - given_name
 - family_name
 - role
 - title

=head1 SUBROUTINES

=over 8

=item C<parse($xml)>

 Parse XML string.
 Returns reference to hash with data.

=back

=head1 ERRORS

 parse():
         Cannot parse XML string.
                 XML::Parser error: %s

=head1 EXAMPLE1

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

=head1 EXAMPLE2

 use strict;
 use warnings;

 use Data::Printer;
 use Perl6::Slurp qw(slurp);
 use WebService::Ares::Rzp qw(parse);

 # Arguments.
 if (@ARGV < 1) {
         print STDERR "Usage: $0 xml_file\n";
         exit 1;
 }
 my $xml_file = $ARGV[0];

 # Get XML.
 my $xml = slurp($xml_file);

 # Parse.
 my $data_hr = parse($xml);

 # Print.
 p $data_hr;

 # Output like:
 # Usage: /tmp/WfgYq5ttuP xml_file

=head1 DEPENDENCIES

L<English>,
L<Error::Pure>,
L<Exporter>,
L<Readonly>,
L<XML::Parser>.

=head1 SEE ALSO

=over

=item L<WebService::Ares>

Perl class to communication with Ares service.

=item L<WebService::Ares::Standard>

Perl XML::Parser parser for ARES standard XML file.

=back

=head1 REPOSITORY

L<https://github.com/michal-josef-spacek/WebService-Ares>

=head1 AUTHOR

Michal Josef Špaček L<skim@cpan.org>

=head1 LICENSE AND COPYRIGHT

© Michal Josef Špaček 2009-2023

BSD 2-Clause License

=head1 VERSION

0.04

=cut
