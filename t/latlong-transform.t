#! /usr/bin/perl

## test connection to metoffice

use warnings;
use strict;
use Test::More;
use Data::Dumper;

BEGIN {
	use lib "/home/weedom/doineedacoat/lib/doineedacoat";
	use_ok("Model::Metoffice::LatLongTransform");	
};

my $transformer = doineedacoat::Model::Metoffice::LatLongTransform->new();
#print "did I create a transformer?\n";
is(
	ref $transformer, "doineedacoat::Model::Metoffice::LatLongTransform",
	"created a transformer?"
);

## lat/long now comes from google maps api
## we'll just have to, sorta, trust google to come up with something
## reliable. heh.

# TR11 2AN : lat=50.15717&lng=-5.073215

my $lat = 50.15717;
my $lng = -5.073215;

my $site_details = $transformer->get_nearest_site_details($lat,$lng);

is($site_details->{nearest_site_name}, "Falmouth", "Was the nearest location Falmouth?");
## actually, 351434 (Falmouth Bay) would do just as nicely
is($site_details->{nearest_site_id}, 322185, "Was the nearest location id 322185?");

done_testing();

