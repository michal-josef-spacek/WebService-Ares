package WebService::Ares;

# Pragmas.
use strict;
use warnings;

# Modules.
use Class::Utils qw(set_params);
use Error::Pure qw(err);
use HTTP::Request;
use LWP::UserAgent;

# Version.
our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# User agent.
	$self->{'agent'} = 'WebService::Ares/'.$VERSION;

	# Debug.
	$self->{'debug'} = 0;

	# Params.
	set_params($self, @params);

	# Commands.
	$self->{'commands'} = {
		'standard' => {
			'attr' => [
				'ic',
			],
			'method' => 'GET',
			'url' => 'http://wwwinfo.mfcr.cz/cgi-bin/ares'.
				'/darv_std.cgi',
		},
	};

	# User agent.
	$self->{'ua'} = LWP::UserAgent->new;
	$self->{'ua'}->agent($self->{'agent'});

	# Object.
	return $self;
}

# Get web service commands.
sub commands {
	my $self = shift;
	return sort keys %{$self->{'commands'}};
}

# Get data.
sub get {
	my ($self, $command, $def_hr) = @_;

	# Command structure.
	my $c_hr = $self->{'commands'}->{$command};

	# Create url.
	my $url = $c_hr->{'url'};
	foreach my $key (keys %{$def_hr}) {
		# TODO Control
		# TODO Better create.
		if ($key eq 'ic') {
			$url .= '?ico='.$def_hr->{$key};
		}
	}

	# Get data.
	my $data = $self->_get_page($c_hr->{'method'}, $url);

	# Parse XML.
	my $data_hr;
	if ($command eq 'standard') {
		require Ares::Standard;
		$data_hr = Ares::Standard::parse($data);
	}

	# Result.
	return $data_hr;
}

# Get page.
sub _get_page {
	my ($self, $method, $url) = @_;

	# Debug.
	if ($self->{'debug'}) {
		print "Method: $method\n";
		print "URL: $url\n";
	}

	# Request.
	my $req;
	if ($method eq 'GET') {
		$req = HTTP::Request->new('GET' => $url);
	} else {
		err "Method '$method' is unimplemened.";
	}

	# Response.
	my $res = $self->{'ua'}->request($req);

	# Get page.
	if ($res->is_success) {
		return $res->content;
	} else {
		$self->{'error'} = $res->status_line;
		return;
	}
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

WebService::Ares - Perl class to communication with Ares service.

=head1 SYNOPSIS

 use WebService::Ares;
 my $obj = WebService::Ares->new(%parameters);
 my @commands = $obj->commands;
 my $data_hr = $obj->get($command, $def_hr);

=head1 DESCRIPTION

 What is it Ares?
 TODO

=head1 METHODS

=over 8

=item C<new(%parameters)>

 Constructor.

=over 8

=item * C<agent>

 User agent setting.
 Default is 'WebService::Ares/$VERSION'.

=item * C<debug>

 Debug mode flag.
 Default is 0.

=back

=item C<commands()>

 Get web service commands.
 Returns array of commands.

=item C<get($command, $def_hr)>

 Get data for command '$command' and definitition defined in $dev_hr reference of hash.
 Returns reference to hash with data.

=back

=head1 ERRORS

 get()
         Method '%s' is unimplemened.

=head1 EXAMPLE1

 # Pragmas.
 use strict;
 use warnings;

 # Modules.
 use WebService::Ares;

 # Object.
 my $obj = WebService::Ares->new;

 # Get data.
 # TODO

 # Print data.
 # TODO

 # Output:
 # TODO

=head1 EXAMPLE2

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

=head1 EXAMPLE3

 # Pragmas.
 use strict;
 use warnings;

 # Modules.
 use WebService::Ares;

 # Object.
 my $obj = WebService::Ares->new;

 # Get commands.
 my @commands = $obj->commands;

 # Print commands.
 print join "\n", @commands;
 print "\n";

 # Output:
 # standard

=head1 DEPENDENCIES

L<Ares::Standard>,
L<Class::Utils>,
L<Error::Pure>,
L<HTTP::Request>,
L<LWP::UserAgent>.

=head1 SEE ALSO

L<Ares::Standard>.

=head1 REPOSITORY

L<https://github.com/tupinek/WebService-Ares>

=head1 AUTHOR

Michal Špaček L<skim@cpan.org>

=head1 LICENSE AND COPYRIGHT

BSD license.

=head1 VERSION

0.01

=cut
