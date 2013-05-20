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
		
	my $params = $forecast_hash->{SiteRep}{Wx}{Param}; ## readable labels
	my $days = $forecast_hash->{SiteRep}{DV}{Location}{Period};
		
	my @humidity;
	my @pp_precentages;
	my @temperatures;
	my @feels_like_temperatures;
	my @wind_speed;
	
	my $hours_processed = 0;
	my $all_done_here = 0;
	foreach (@$days) {
		my $daily_report_array = $_->{Rep};
		foreach (@$daily_report_array) {
			$hours_processed += 3;
			my $report = $_;
			push @humidity, $report->{H};
			push @pp_precentages, $report->{Pp};
			push @temperatures, $report->{T};
			push @feels_like_temperatures, $report->{F};
			push @wind_speed, $report->{Pp};			

			if ($hours_processed >= $length_of_stay) {
				$all_done_here = 1;
				last;
			}
			else {
				next;
			}
		}
		last if $all_done_here;
	}
	## TODO - call another sub to process the means and generate a score
	## NEARLY THERE!!
	warn Dumper {
		humidity => \@humidity,
		pp_precentages => \@pp_precentages,
		temperatures => \@temperatures,
		feels_like_temperatures => \@feels_like_temperatures,
		wind => \@wind_speed
	};
	return $doineedacoat;
}



1;
