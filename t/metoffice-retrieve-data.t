#! /usr/bin/perl

## test connection to metoffice

use warnings;
use strict;
use Test::More;
use Data::Dumper;

BEGIN {
	use lib "/home/weedom/doineedacoat/lib/doineedacoat";
	use_ok("Model::Metoffice");	
};

my $metoffice = doineedacoat::Model::Metoffice->new();
my $data = $metoffice->get_weather_data("TR11 2AN");
#ok();

done_testing();
