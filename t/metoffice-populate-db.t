#! /usr/bin/perl

## test that we can populate a db with metoffice full-site info.

use warnings;
use strict;
use Test::More;
use Data::Dumper;

BEGIN {
	use lib "/home/weedom/doineedacoat/lib/doineedacoat";
	use_ok("Model::Metoffice");	
};

my $metoffice = doineedacoat::Model::Metoffice->new();

is(
	ref $metoffice, "doineedacoat::Model::Metoffice",
	"created a proper Metoffice object?"
);
my $connection = $metoffice->connection;

is(ref $metoffice->connection,"LWP::UserAgent", "Was metoffice->connection a LWP:ua?");

ok($metoffice->connection->get("www.metoffice.gov.uk"),
    "got(ish) the metoffice website (lwp::ua didn't return failure)");

my $full_site_list = $metoffice->_maybe_get_full_site_list(1)->{Locations}; 

cmp_ok(
    scalar $full_site_list, 
    'gt',
    4000,
    "Got more than 4000 sites"
);

ok($metoffice->_populate_site_list_db(), "updated db");


done_testing();
