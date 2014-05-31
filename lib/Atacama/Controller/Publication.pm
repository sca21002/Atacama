package Atacama::Controller::Publication;

# ABSTRACT: Controller Publication
 
use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

sub publications : Chained('/base') PathPart('publication') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{publications} = $c->model('AtacamaDB::Publication');
}

sub json : Chained('publications') {
    my ($self, $c) = @_;
    
    my $json_data;
    my $publications = $c->stash->{publications};
    
    $c->log->debug(Dumper($c->req->query_params));
    $json_data = $publications->get_new_result_as_href({
        platform_id => $c->req->query_params->{platform_id},                                            
    });
    $c->stash(
        json_data => $json_data,
        current_view => 'JSON',
    );
}

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

__END__

