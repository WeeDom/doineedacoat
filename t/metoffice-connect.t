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

is(
	ref $metoffice, "doineedacoat::Model::Metoffice",
	"created a proper Metoffice object?"
);
my $connection = $metoffice->connection;
is(ref $metoffice->connection,"LWP::UserAgent", "Was metoffice->connection a LWP:ua?");
ok($metoffice->connection->get("www.metoffice.gov.uk"), "successfully-ish got the metoffice website (lwp::ua didn't return failure)");

done_testing();




