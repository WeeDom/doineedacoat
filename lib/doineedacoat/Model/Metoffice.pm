package doineedacoat::Model::Metoffice;

use warnings;
use strict;

use Exporter;
use Mojo::UserAgent;
use Try::Tiny;
use Data::Dumper;
use YAML qw/LoadFile/;
use doineedacoat::Model::Metoffice::LatLongTransform;


our $SOURCES_FILE = "/home/weedom/doineedacoat/lib/doineedacoat/Model/sources";

#our @EXPORT = qw/new/;

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
	my $ua = Mojo::UserAgent->new();
	return $ua;
	
}

sub _get_metoffice_info {
	my $sources;
	
	$sources = LoadFile("/home/weedom/doineedacoat/lib/doineedacoat/Model/sources");
	
	return $sources->{metoffice};
}

sub get_weather_data {
	my ($self, $site_id) = @_;

	my $metoffice_details = _get_metoffice_info;
	
	my $res = $self->connection->get($metoffice_details->{url}. "val/wxfcs/all/xml/" . $site_id ."?res=3hourly"
		. "&key=" .$self->{connection_info}{key});
	warn Dumper {
		 resContent => $res->content
	};

	return $res;
}

1;
