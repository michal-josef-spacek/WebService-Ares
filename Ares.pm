package Ares;

# Pragmas.
use strict;
use warnings;

# Modules.
use Class::Utils qw(set_params);
use Error::Simple::Multiple qw(err);
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
