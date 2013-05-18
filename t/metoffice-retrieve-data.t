#! /usr/bin/perl

## test connection to metoffice

use warnings;
use strict;
use Test::More;
use Data::Dumper;
use YAML qw/LoadFile/;

BEGIN {
	use lib "/home/weedom/doineedacoat/lib/";
	use_ok("doineedacoat::Model::Metoffice");
};

my $metoffice = doineedacoat::Model::Metoffice->new();
my $conn = $metoffice->connection;
my $metoffice_details = $metoffice->_get_metoffice_info;
my $site_id = 322185;
	
is(ref $conn, "LWP::UserAgent", "connection Looks like a lwp::ua?");
my $res = $conn->get($metoffice_details->{url}. "val/wxfcs/all/xml/" . $site_id ."?res=3hourly"
    . "&key=" .$metoffice->{connection_info}{key});
is(ref $res, 'HTTP::Response', "got some sort of response?");
is($res->is_success, 1, "and it looked like a success");
#is();



done_testing();
