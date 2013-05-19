package doineedacoat::Model::Metoffice;

use warnings;
use strict;

use Exporter;
use LWP::UserAgent;
use Try::Tiny;
use Data::Dumper;
use YAML qw/LoadFile/;
use JSON;
use doineedacoat::Model::Metoffice::LatLongTransform;

our $SOURCES_FILE = "/home/weedom/doineedacoat/lib/doineedacoat/Model/sources";

our @ISA = qw//;

sub new {
	my $class = shift;
	my $transformer = doineedacoat::Model::Metoffice::LatLongTransform->new();
	my $metoffice= {
			connection => _connection(),
			connection_info => _get_metoffice_info(),
			transformer => $transformer
	};
	bless $metoffice,$class;
	return $metoffice;
}

## accessors
sub connection {
	my $self = shift;
	return $self->{connection};
}

sub key {
	my $self = shift;
	return $self->{connection_info}{key};
}

sub transformer {
	my $self = shift;
	return $self->{transformer};
}

sub _connection {
	my $self = shift;
	my $ua = LWP::UserAgent->new();
	return $ua;
	
}

## FIXME - this would be better if it was abstracted out, with a flag
## to retrieve the data for each particular source. Maybe?
sub _get_metoffice_info {
	my $sources;
	
	$sources = LoadFile("/home/weedom/doineedacoat/lib/doineedacoat/Model/sources");
	
	return $sources->{metoffice};
}

sub get_weather_data {
	my ($self, $lat,$lng) = @_;

	my $site_details = $self->transformer->get_nearest_site_details(
        $lat,
        $lng
    );

	my $metoffice_details = _get_metoffice_info;
	
	my $res = $self->connection->get($metoffice_details->{url}. "val/wxfcs/all/json/" .
		$site_details->{nearest_site_id} . "?res=3hourly"
		. "&key=" . $self->{connection_info}{key});
	
	if($res->is_success) {
		my $forecast_hash = decode_json($res->content);
		open LOG, ">/tmp/jsonout";
		print LOG $res->content;
		close LOG;
		$self->_processForecast($forecast_hash);
	}
	else {
		## FIXME: obviously do something more cleverer than this...
		die "Something tragic happened in Metoffice.pm";
	}    
}

sub _processForecast {
	my ($self, $forecast_hash, $length_of_stay) = @_;
	my $doineedacoat = 0;
	## set some thresholds
	my $min_feels_like = 13;
	my $max_pp_probability = 50;
	## data looks a bit like this:
	## labels:
	#Param' => [
	#{
	#'$' => 'Feels Like Temperature',
	#'name' => 'F',
	#'units' => 'C'
	#},
	#{
	#'$' => 'Wind Gust',
	#'name' => 'G',
	#'units' => 'mph'
	#},
	#{
	#'$' => 'Screen Relative Humidity',
	#'name' => 'H',
	#'units' => '%'
	#},
	#{
	#'$' => 'Temperature',
	#'name' => 'T',
	#'units' => 'C'
	#},
	#{
	#'$' => 'Visibility',
	#'name' => 'V',
	#'units' => ''
	#},
	#{
	#'$' => 'Wind Direction',
	#'name' => 'D',
	#'units' => 'compass'
	#},
	#{
	#'$' => 'Wind Speed',
	#'name' => 'S',
	#'units' => 'mph'
	#},
	#{
	#'$' => 'Max UV Index',
	#'name' => 'U',
	#'units' => ''
	#},
	#{
	#'$' => 'Weather Type',
	#'name' => 'W',
	#'units' => ''
	#},
	#{
	#'$' => 'Precipitation Probability',
	#'name' => 'Pp',
	#'units' => '%'
	#}
	#]
	#},
	#
	## data:
	#
	#{
	#'$' => '900',
	#'S' => '11',
	#'F' => '10',
	#'W' => '3',
	#'T' => '12',
	#'V' => 'VG',
	#'H' => '75',
	#'Pp' => '2',
	#'D' => 'NW',
	#'G' => '25',
	#'U' => '2'
	#},
	
	return $doineedacoat;
}



1;
