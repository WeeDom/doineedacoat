package doineedacoat::Model::Metoffice;

use warnings;
use strict;

use lib "/home/weedom/doineedacoat/lib/";
use Exporter;
use LWP::UserAgent;
use Try::Tiny;
use Data::Dumper;
use YAML qw/LoadFile/;
use JSON;
use Encode;
use List::Util qw/sum/;
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
	my ($self, $lat, $lng, $length_of_stay) = @_;

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
		my $doineedacoat = $self->_processForecast($forecast_hash, $length_of_stay);
		return $doineedacoat;
	}
	else {
		return $res->status_line;
	}    
}

sub _processForecast {
	my ($self, $forecast_hash, $length_of_stay) = @_;

	my $thresholds = {
		min_feels_like => 12,
		max_pp_probability => 30
	};
		
	my $params = $forecast_hash->{SiteRep}{Wx}{Param}; ## readable labels
	my $days = $forecast_hash->{SiteRep}{DV}{Location}{Period};
		
	my $humidity;
	my $pp_percentages;
	my $temperatures;
	my $feels_like_temperatures;
	my $wind_speed;
	
	my $hours_processed = 0;
	my $all_done_here = 0;
	foreach (@$days) {
		my $daily_report_array = $_->{Rep};
		foreach (@$daily_report_array) {
			$hours_processed += 3;
			my $report = $_;
			push @$humidity, $report->{H};
			push @$pp_percentages, $report->{Pp};
			push @$temperatures, $report->{T};
			push @$feels_like_temperatures, $report->{F};
			push @$wind_speed, $report->{S};			

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
	
	my $means = $self->_process_means(
		{
			humidity => $humidity,
			pp_percentages => $pp_percentages,
			temperatures => $temperatures,
			feels_like_temperatures => $feels_like_temperatures,
			wind => $wind_speed
		}
	);

	my $doineedacoat = 0;
	if (
		($means->{mean_feels_like_temperature} <= $thresholds->{min_feels_like})
		||
		$means->{mean_feels_like_temperature} <= $thresholds->{min_feels_like}
	) {
		$doineedacoat = 1;
		return $doineedacoat;
	}
	
	if($means->{mean_pp_percentage} >= $thresholds->{max_pp_probability}) {
		$doineedacoat = 1;
		return $doineedacoat;
	}
}

sub _process_means {
		my ($self, $args) = @_;
		
		my $mean_humidity = $self->_get_mean($args->{humidity});
		my $mean_temperature = $self->_get_mean($args->{temperatures});
		my $mean_feels_like_temperatures = $self->_get_mean($args->{feels_like_temperatures});
		my $mean_pp_percentage = $self->_get_mean($args->{pp_percentages});
		my $mean_wind = $self->_get_mean($args->{wind});
		
		return {
			mean_humidity => $mean_humidity,
			mean_pp_percentage => $mean_pp_percentage,
			mean_temperature => $mean_temperature,
			mean_feels_like_temperature => $mean_feels_like_temperatures,
			mean_wind => $mean_wind
		};
}

sub _get_mean {
	my ($self,$measurements) = @_;
	return sum(@{$measurements}) / @{$measurements};
}

sub _populate_site_list_db {
	my ($self) = @_;

    my $locations_hash = $self->_maybe_get_full_site_list();

    return 0;
}

sub _maybe_get_full_site_list {
    my ($self,$testing) = @_;
    if(! $testing && ! _update_required()) {
        return;
    }
	my $metoffice_details = _get_metoffice_info();
	
	my $res = $self->connection->get($self->{connection_info}->{url} . "val/wxfcs/all/json/sitelist"
	. "?key=" . $self->{connection_info}{key});

    my $locations_hash = JSON->new->utf8->decode(encode_utf8($res->decoded_content));

    return $locations_hash  
	
}

sub _update_required {
    return 1;
}

1;

