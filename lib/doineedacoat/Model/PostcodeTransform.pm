package doineedacoat::Model::PostcodeTransform;

use warnings;
use strict;

use Exporter;
use Try::Tiny;
use Data::Dumper;
use XML::Hash;

#our @ISA = qw/doineedacoat::Model::PostcodeTransform/;

our @EXPORT = qw/new/;

our $POSTCODE_SOURCE = "/home/weedom/doineedacoat/lib/doineedacoat/Model/uk.pc.ll.csv";

sub new {
	my $class = shift;
	my $transformer = {};
	bless $transformer,$class;
	return $transformer;
}

sub transform {
    my ($self,$postcode) = @_;
    warn "requested postcode: $postcode";
    my $pcode_hash;
    
    
    open(POSTCODES,"<$POSTCODE_SOURCE") or die "Couldn't open the file";
    
    while(<POSTCODES>) {
        my ($pcode,$lat,$lng) = split(/,/);
        chomp($pcode,$lat,$lng);
        $pcode_hash->{$pcode} = [$lat,$lng];
    }
    close POSTCODES;
    
    my $lat_lng_array_ref = $pcode_hash->{(split/ /,$postcode)[0]};
    
    return $lat_lng_array_ref;
}

sub get_nearest_site_name {
    my ($self,$lat,$lng) = @_;
    my $xml_to_hash = new XML::Hash;
    my $xml_string;
    
    {
        my $linebreak = $/;
        $/ = undef;
        open(LOCATIONS_XML, "</home/weedom/doineedacoat/lib/doineedacoat/Model/metoffice-fullsites.xml");
        $xml_string = <LOCATIONS_XML>;
        close LOCATIONS_XML;
        $/ = $linebreak;
    }
    
    my $locations_hash = $xml_to_hash->fromXMLStringtoHash($xml_string);
    
    my $locations_array = $locations_hash->{Locations}{Location};
    my $proximity_hash;
    my $site_to_name_hash;
    foreach my $location (@$locations_array) {
        my $x = abs($lng - $location->{longitude})*0.36 + abs($lat - $location->{latitude});
        $proximity_hash->{$location->{id}} = $x;
        #$proximity_hash->{name} = $location->{name};
        $site_to_name_hash->{$location->{id}} = $location->{name};
    }
    
    my $nearest_site_id = (sort {$proximity_hash->{$a} <=> $proximity_hash->{$b}} keys %$proximity_hash)[0];
    
    
    
    warn Dumper {
        nearest_site_id => $nearest_site_id,
        nearest_site_name => $site_to_name_hash->{$nearest_site_id}
    };
    
}

sub get_nearest_site_id {
    my ($self,$lat,$lng) = @_;
}

1
;
