package doineedacoat::Model::Metoffice;

use warnings;
use strict;

use Exporter;
use Mojo::UserAgent;
use Try::Tiny;
use Data::Dumper;
use YAML qw/LoadFile/;
#use doineedacoat::Model::PostcodeTransform;

our $SOURCES_FILE = "/home/weedom/doineedacoat/lib/doineedacoat/Model/sources";

#our @EXPORT = qw/new/;

our @ISA = qw//;

sub new {
	my $class = shift;
	my $metoffice= {
			connection => _connection(),
			connection_info => _get_metoffice_info()
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

sub _connection {
	my $self = shift;
	my $ua = Mojo::UserAgent->new();
	return $ua;
	
}

sub _get_metoffice_info {
	my $sources;
	
	$sources = LoadFile("/home/weedom/doineedacoat/lib/doineedacoat/Model/sources");
	
	return $sources->{metoffice};
}

sub get_weather_data {
	my ($self, $lat, $lng) = @_;
	
	## transform lat,lng into site_id
	
	my $res = $self->connection->get('http://datapoint.metoffice.gov.uk/public/data/val/wxfcs/all/json/3840?res=3hourly'
		. "&key=" .$self->{connection_info}{key});


	return $res;
}

1;
