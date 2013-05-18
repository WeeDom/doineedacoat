package doineedacoat::Model::GetWeather;

use warnings;
use strict;

use Exporter;


## this should get and return info from all sources.
## no parsing - leave that to the modules for each individual source
sub get_weather_data {
    my ($self,$source,$ua,$args) = @_;
    $ua->get();
}

1
;
