package Ares;

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
	$self->{'agent'} = 'Ares/'.$VERSION;

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

# Get commands.
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

Ares - TODO

=head1 SYNOPSIS

 use Ares;
 TODO

=head1 METHODS

=over 8

=item C<new(%parameters)>

 Constructor.

=over 8

=item * C<agent>

 User agent setting.
 Default is 'Ares/$VERSION'.

=item * C<debug>

 Debug mode flag.
 Default is 0.

=back

=item C<commands()>

 TODO

=item C<get($command, $def_hr)>

TODO

=back

=head1 ERRORS

 Mine:
         TODO

=head1 DEPENDENCIES

L<Class::Utils(3pm)>,
L<Error::Pure(3pm)>,
L<HTTP::Request(3pm)>,
L<LWP::UserAgent(3pm)>.

=head1 SEE ALSO

L<Ares::Standard(3pm)>.

=head1 AUTHOR

Michal Špaček L<skim@cpan.org>

=head1 LICENSE AND COPYRIGHT

BSD license.

=head1 VERSION

0.01

=cut
