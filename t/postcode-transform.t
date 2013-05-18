#! /usr/bin/perl

## test connection to metoffice

use warnings;
use strict;
use Test::More;
use Data::Dumper;

BEGIN {
	use lib "/home/weedom/doineedacoat/lib/doineedacoat";
	use_ok("Model::PostcodeTransform");	
};

my $transformer = doineedacoat::Model::PostcodeTransform->new();
#print "did I create a transformer?\n";
is(
	ref $transformer, "doineedacoat::Model::PostcodeTransform",
	"created a transformer?"
);

my ($lat,$lng) = @{$transformer->transform("TR12 2QW")};

is($lat, "50.2646347279094", "Did we get the correct latitude?");
is($lng, "-5.04277408947324", "Did we get the correct longitude?");

my $nearest_location_name = $transformer->get_nearest_site_name($lat,$lng);
my $nearest_location_id = $transformer->get_nearest_site_id($lat,$lng);

is($nearest_location_name, "Truro", "Was the nearest location Falmouth?");
is($nearest_location_id, 351434, "Was the nearest location id 351434?");

done_testing();

