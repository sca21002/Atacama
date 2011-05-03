package Atacama::Controller::Titel;
use Moose;
use namespace::autoclean;
use Data::Dumper;
BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::Titel - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Atacama::Controller::Titel in Titel.');
}

sub titel : Chained('/') PathPart('titel') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{titel} = $c->model('AtacamaDB::Titel');
}

sub json : Chained('titel') {
    my ($self, $c) = @_;
    
    my $json_data;
    my $titel = $c->stash->{titel};
    # $c->log->debug(Dumper($c->req->query_params));
   
    my $buch = $c->model('SisisDB::D01buch')->search({
        d01ort => $c->req->query_params->{signatur}
    })->first;
    foreach my $titel_sisis (@{$buch->get_titel}) {
        my $titel_new = $titel->get_new_result_as_href({});
        # $c->log->debug(Dumper($titel_sisis));
        my $source_titel = $c->model('AtacamaDB')->source('Titel');
        %$titel_new = map {
            $_ =>
            $titel_sisis->{ $source_titel->column_info($_)->{sisis} || $_ }
        } keys %$titel_new;
        $titel_new->{library_id} = $titel_new->{library_id} != 5
            ? $titel_new->{library_id}
            : $titel_new->{signatur} =~ /^W 01/
            ?   103
            : $titel_new->{signatur} =~ /^W 02/
            ?   102
            : ''
            ;
            
        $titel_new->{titel_isbd} = $titel->new($titel_new)->titel_isbd;
        push @$json_data, $titel_new;
    }
    $c->log->debug(Dumper($json_data));   
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
