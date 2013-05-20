#! /usr/bin/perl

use strict;
use warnings;
use Test::More;


use Catalyst::Test 'doineedacoat';
use doineedacoat::Controller::Site;

ok( request('/')->is_success, 'Request for /default should succeed' );
done_testing();
