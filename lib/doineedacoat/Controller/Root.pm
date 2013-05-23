package doineedacoat::Controller::Root;
use Moose;
use namespace::autoclean;
use doineedacoat::Model::Metoffice;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

doineedacoat::Controller::Root - Root Controller for doineedacoat

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    if(keys $c->request->parameters) {
        my $metoffice = doineedacoat::Model::Metoffice->new();
        warn "created a metoffice thingy";
        my $doineedacoat = $metoffice->get_weather_data(
            $c->request->parameters->{lat},
            $c->request->parameters->{lng},
            $c->request->parameters->{length_of_stay}
        );

        $c->stash(
            doineedacoat => $doineedacoat,
            #forecast => $forecast,
            template => 'doineedacoat-response.tt'
        );    
    }
    else{
        $c->stash(template => 'doineedacoat.tt'); 
    }
    

}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Weedom,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
