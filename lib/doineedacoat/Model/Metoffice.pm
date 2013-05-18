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
	     
    my $json_string = decode_json($res->content);
    open LOG, ">/tmp/jsonout";
    
    warn Dumper {
		$json_string => $json_string
	};
	print LOG Dumper {
		$json_string => $json_string
	};
	close LOG;

	#return $forecast_hash;
	return 1
}


1;
