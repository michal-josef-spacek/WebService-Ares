package WebService::Ares::Basic;

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
	if ($tag_name eq 'D:ICO') {
		_save($expat, $text, 'ico');
	} elsif ($tag_name eq 'D:DIC') {
		_save($expat, $text, 'dic');
	} elsif ($tag_name eq 'D:OF') {
		_save($expat, $text, 'name');
	} elsif ($tag_name eq 'U:KA') {
		_save($expat, $text, 'addr_id');
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

1;

__END__

=pod

=encoding utf8

=head1 NAME

WebService::Ares::Basic - Perl XML::Parser parser for ARES Basic XML file.

=head1 SYNOPSIS

 use WebService::Ares::Basic qw(parse);

 my $data_hr = parse($xml);

=head1 DESCRIPTION

 This module parses XML file from ARES system.
 Module parse these information from XML file:
 - addr_id
 - dic
 - ico
 - name

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

=for comment filename=parse_and_dump_basic.pl

 use strict;
 use warnings;

 use Data::Printer;
 use WebService::Ares::Basic qw(parse);

 # Fake XML.
 my $xml = <<'END';
 <?xml version="1.0" encoding="UTF-8"?>
 <are:Ares_odpovedi xmlns:are="http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/ares/ares_answer_basic/v_1.0.3" xmlns:D="http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/ares/ares_datatypes/v_1.0.3" xmlns:U="http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/uvis_datatypes/v_1.0.3" odpoved_datum_cas="2023-05-18T14:29:17" odpoved_pocet="1" odpoved_typ="Basic" vystup_format="XML" xslt="klient" validation_XSLT="http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/ares/ares_odpovedi.xsl" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/ares/ares_answer_basic/v_1.0.3 http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/ares/ares_answer_basic/v_1.0.3/ares_answer_basic_v_1.0.3.xsd" Id="ares">
 <are:Odpoved>
 <D:PID>0</D:PID>
 <D:VH>
 <D:K>1</D:K>
 </D:VH>
 <D:PZA>1</D:PZA>
 <D:UVOD>
 <D:ND>Výpis z dat Registru ARES - aktuální stav ke dni 2023-05-18</D:ND>
 <D:ADB>2023-05-18</D:ADB>
 <D:DVY>2023-05-18</D:DVY>
 <D:CAS>14:29:17</D:CAS>
 <D:Typ_odkazu>0</D:Typ_odkazu>
 </D:UVOD>
 <D:VBAS>
 <D:ICO zdroj="OR">27082440</D:ICO>
 <D:DIC zdroj="DPH">CZ27082440</D:DIC>
 <D:OF zdroj="OR">Alza.cz a.s.</D:OF>
 <D:DV>2003-08-26</D:DV>
 <D:PF zdroj="OR">
 <D:KPF>121</D:KPF>
 <D:NPF>Akciová společnost</D:NPF>
 </D:PF>
 <D:AD zdroj="ARES">
 <D:UC>Jankovcova 1522</D:UC>
 <D:PB>17000 Praha</D:PB>
 </D:AD>
 <D:AA zdroj="ARES">
 <D:IDA>213328764</D:IDA>
 <D:KS>203</D:KS>
 <D:NS>Česká republika</D:NS>
 <D:N>Praha</D:N>
 <D:NCO>Holešovice</D:NCO>
 <D:NMC>Praha 7</D:NMC>
 <D:NU>Jankovcova</D:NU>
 <D:CD>1522</D:CD>
 <D:TCD>1</D:TCD>
 <D:CO>53</D:CO>
 <D:PSC>17000</D:PSC>
 <D:AU>
 <U:KOL>19</U:KOL>
 <U:KK>19</U:KK>
 <U:KOK>3100</U:KOK>
 <U:KO>554782</U:KO>
 <U:KPO>78</U:KPO>
 <U:KN>78</U:KN>
 <U:KCO>490067</U:KCO>
 <U:KMC>500186</U:KMC>
 <U:PSC>17000</U:PSC>
 <U:KUL>449423</U:KUL>
 <U:CD>1522</U:CD>
 <U:TCD>1</U:TCD>
 <U:CO>53</U:CO>
 <U:KA>25958895</U:KA>
 <U:KOB>22148451</U:KOB>
 </D:AU>
 </D:AA>
 <D:PSU>NAAANANNNNNNNNNNNNNNPNNNANNNNN</D:PSU>
 <D:ROR>
 <D:SZ>
 <D:SD>
 <D:K>1</D:K>
 <D:T>Městský soud v Praze</D:T>
 </D:SD>
 <D:OV>B 8573</D:OV>
 </D:SZ>
 <D:SOR>
 <D:SSU>Aktivní</D:SSU>
 <D:KKZ>
 <D:K>0</D:K>
 </D:KKZ>
 <D:VY>
 <D:K>0</D:K>
 </D:VY>
 <D:ZAM>
 <D:K>0</D:K>
 </D:ZAM>
 <D:LI>
 <D:K>0</D:K>
 </D:LI>
 </D:SOR>
 </D:ROR>
 <D:RRZ>
 <D:ZU>
 <D:KZU>310007</D:KZU>
 <D:NZU>Úřad městské části Praha 7</D:NZU>
 </D:ZU>
 <D:FU>
 <D:KFU>7</D:KFU>
 <D:NFU>Praha 7</D:NFU>
 </D:FU>
 </D:RRZ>
 <D:KPP zdroj="RES">2000 - 2499 zaměstnanců</D:KPP>
 <D:Nace>
 <D:NACE zdroj="RES">26110</D:NACE>
 <D:NACE zdroj="RES">26300</D:NACE>
 <D:NACE zdroj="RES">27900</D:NACE>
 <D:NACE zdroj="RES">33140</D:NACE>
 <D:NACE zdroj="RES">461</D:NACE>
 <D:NACE zdroj="RES">46900</D:NACE>
 <D:NACE zdroj="RES">471</D:NACE>
 <D:NACE zdroj="RES">47250</D:NACE>
 <D:NACE zdroj="RES">47911</D:NACE>
 <D:NACE zdroj="RES">49410</D:NACE>
 <D:NACE zdroj="RES">56100</D:NACE>
 <D:NACE zdroj="RES">620</D:NACE>
 <D:NACE zdroj="RES">6492</D:NACE>
 <D:NACE zdroj="RES">731</D:NACE>
 </D:Nace>
 <D:PPI>
 <D:PP zdroj="OR">
 <D:T>
 výroba, instalace, opravy elektrických strojů a přístrojů, elektronických a telekomunikačních zařízení
 </D:T>
 <D:T>
 výroba, obchod a služby neuvedené v přílohách 1 až 3 živnostenského zákona, v oborech činnosti: 
 
 
 
 zprostředkování obchodu a služeb
 
 velkoobchod a maloobchod
 
 skladování, balení zboží, manipulace s nákladem a technické činnosti v dopravě
 
 zasilatelství a zastupování v celním řízení
 
 poskytování software, poradenství v oblasti informačních technologií, zpracování dat, hostingové a související činnosti a webové portály
 
 pronájem a půjčování věcí movitých
 
 reklamní činnost, marketing, mediální zastoupení
 </D:T>
 <D:T>
 poskytování nebo zprostředkování spotřebitelského úvěru
 </D:T>
 <D:T>
 zprostředkovatelská činnost v pojišťovnictví
 </D:T>
 <D:T>
 hostinská činnost
 </D:T>
 <D:T>
 silniční motorová doprava - nákladní provozovaná vozidly nebo jízdními soupravami o největší povolené hmotnosti nepřesahující 3,5 tuny, jsou-li určeny k přepravě zvířat nebo věcí
 </D:T>
 <D:T>
 prodej kvasného lihu, konzumního lihu a lihovin
 </D:T>
 </D:PP>
 <D:PP zdroj="RZP">
 <D:T>Hostinská činnost</D:T>
 <D:T>Silniční motorová doprava - nákladní vnitrostátní provozovaná vozidly nebo jízdními soupravami o největší povolené hmotnosti nepřesahující 3,5 tuny určenými k přepravě zvířat nebo věcí a nákladní mezinárodní provozovaná vozidly nebo jízdními soupravami o největší povolené hmotnosti nepřesahující 2,5 tuny určenými k přepravě zvířat nebo věcí</D:T>
 <D:T>Výroba, obchod a služby neuvedené v přílohách 1 až 3 živnostenského zákona</D:T>
 <D:T>Výroba, instalace, opravy elektrických strojů a přístrojů, elektronických a telekomunikačních zařízení</D:T>
 <D:T>Prodej kvasného lihu, konzumního lihu a lihovin</D:T>
 </D:PP>
 </D:PPI>
 <D:Obory_cinnosti>
 <D:Obor_cinnosti>
 <D:K>Z01047</D:K>
 <D:T>Zprostředkování obchodu a služeb</D:T>
 </D:Obor_cinnosti>
 <D:Obor_cinnosti>
 <D:K>Z01048</D:K>
 <D:T>Velkoobchod a maloobchod</D:T>
 </D:Obor_cinnosti>
 <D:Obor_cinnosti>
 <D:K>Z01052</D:K>
 <D:T>Skladování, balení zboží, manipulace s nákladem a technické činnosti v dopravě</D:T>
 </D:Obor_cinnosti>
 <D:Obor_cinnosti>
 <D:K>Z01053</D:K>
 <D:T>Zasilatelství a zastupování v celním řízení</D:T>
 </D:Obor_cinnosti>
 <D:Obor_cinnosti>
 <D:K>Z01056</D:K>
 <D:T>Poskytování software, poradenství v oblasti informačních technologií, zpracování dat, hostingové a související činnosti a webové portály</D:T>
 </D:Obor_cinnosti>
 <D:Obor_cinnosti>
 <D:K>Z01059</D:K>
 <D:T>Pronájem a půjčování věcí movitých</D:T>
 </D:Obor_cinnosti>
 <D:Obor_cinnosti>
 <D:K>Z01066</D:K>
 <D:T>Reklamní činnost, marketing, mediální zastoupení</D:T>
 </D:Obor_cinnosti>
 </D:Obory_cinnosti>
 </D:VBAS>
 </are:Odpoved>
 </are:Ares_odpovedi>
 END

 # Parse.
 my $data_hr = parse($xml);

 # Print.
 p $data_hr;

 # Output:
 # {
 #     addr_id   25958895,
 #     dic       "CZ27082440",
 #     ico       27082440,
 #     name      "Alza.cz a.s."
 # }

=head1 EXAMPLE2

=for comment filename=parse_and_dump_xml_file.pl

 use strict;
 use warnings;

 use Data::Printer;
 use Perl6::Slurp qw(slurp);
 use WebService::Ares::Basic qw(parse);

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

=item L<WebService::Ares::Rzp>

Perl XML::Parser parser for ARES RZP XML file.

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
