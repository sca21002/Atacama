package Atacama::Controller::OrderProject;
use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::OrderProject - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Atacama::Controller::OrderProject in OrderProject.');
}

sub ordersprojects : Chained('/') PathPart('orderproject') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{ordersprojects} = $c->model('AtacamaDB::OrderProject');
}

sub json : Chained('ordersprojects') {
    my ($self, $c) = @_;
    
    my $json_data;
    my $ordersprojects = $c->stash->{ordersprojects};
    
    #$c->log->debug(Dumper($c->req->query_params));
    $json_data = $ordersprojects->get_new_result_as_href({
        project_id => $c->req->query_params->{project_id},                                            
    });
    #$c->log->debug(Dumper($json_data));    
    $c->stash(
        json_data => $json_data,
        current_view => 'JSON'
    );
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
