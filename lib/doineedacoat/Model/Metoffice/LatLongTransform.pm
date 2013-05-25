package doineedacoat::Model::Metoffice::LatLongTransform;

use warnings;
use strict;

use Exporter;
use Try::Tiny;
use Data::Dumper;
use JSON;
use Encode qw(encode_utf8);
use Math::Trig qw(great_circle_distance deg2rad);

sub new {
	my $class = shift;
	my $transformer = {};
	bless $transformer,$class;
	return $transformer;
}

sub get_nearest_site_details {
    my ($self,$lat,$lng) = @_;
    my $json_string;
    
    {
        my $linebreak = $/;
        $/ = undef;
        open(LOCATIONS_JSON, "</home/weedom/doineedacoat/lib/doineedacoat/Model/metoffice-fullsites.json");
        $json_string = encode_utf8( <LOCATIONS_JSON> );
        close LOCATIONS_JSON;
        $/ = $linebreak;
    }
    
    my $locations_hash = JSON->new->utf8->decode($json_string);
            
    my @locations_array = sort { $$a{latitude} cmp $$b{latitude} } @{$locations_hash->{Locations}{Location}};
    
    
    my $proximity_hash;
    my $site_to_name_hash;
 
    # 0.009 degrees difference in latitude =~ 1.001km north/south of current point
    my $max_north = ($lat + (0.09 * 5));
    my $max_south = ($lat - (0.09 * 5));

    ## get a chunk of the earth approximately 10km wide
    my @subset = grep { $_->{latitude} le $max_north && $_->{latitude} ge $max_south } @locations_array;
    
    ## now, look in that slice and find the nearest weather station
    foreach my $location (@subset) {
        my @requested = _NESW($lat, $lng);
        my @location = _NESW($location->{latitude}, $location->{longitude});
        my $x = great_circle_distance(@requested, @location, 6378);
        $proximity_hash->{$location->{id}} = $x;
        $site_to_name_hash->{$location->{id}} = $location->{name};
    }
    
    my $nearest_site_id = (sort {$proximity_hash->{$a} <=> $proximity_hash->{$b}} keys %$proximity_hash)[0];
    
    if (defined $nearest_site_id) {
        my $site_details =  {
            nearest_site_id => $nearest_site_id,
            nearest_site_name => $site_to_name_hash->{$nearest_site_id}
        };
        return $site_details;
    }
    else {
        ## FIXME: figure out how to do a properly handled die
        die "didn't get a site id";
    }   
}

sub _NESW { deg2rad($_[0]), deg2rad(90 - $_[1]) }

1
;
