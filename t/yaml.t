#! /usr/bin/perl

## check yaml ain't broke

use warnings;
use strict;
use Test::More;
use Data::Dumper;
use YAML qw/LoadFile/;

my $sources = LoadFile("/home/weedom/doineedacoat/lib/doineedacoat/Model/sources");
diag Dumper {
    sources => $sources
};
ok($sources,"sources was a thing");

done_testing();

