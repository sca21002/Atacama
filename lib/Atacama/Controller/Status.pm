package Atacama::Controller::Status;

# ABSTRACT: Conroller for Status

use Moose;
use namespace::autoclean;
use Atacama::Form::Status;
use Data::Dumper;


BEGIN {extends 'Catalyst::Controller'; }

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Atacama::Controller::Status in Atacama.');
}

sub status_list : Chained('/base') PathPart('status') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{status_list} = $c->model('AtacamaDB::Status');
}

sub status : Chained('status_list') PathPart('') CaptureArgs(1) {
    my ($self, $c, $status_id) = @_;

    my $status = $c->stash->{status}
        = $c->stash->{status_list}->find($status_id) || $c->detach('not_found');
}

sub list : Chained('status_list') PathPart('list') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        json_url => $c->uri_for_action('status/json'),
        template => 'status/list.tt'
    ); 
}


sub json : Chained('status_list') PathPart('json') Args(0) {
    my ($self, $c) = @_;

    my $data = $c->req->params;
    $c->log->debug(Dumper($data));
    
    my $page = $data->{page} || 1;
    my $entries_per_page = $data->{rows} || 10;
    my $sidx = $data->{sidx} || 'status_id';
    my $sord = $data->{sord} || 'asc';
    
    my $search = $data->{searchField} && $data->{searchString} 
        ? { $data->{searchField} => $data->{searchString} }
        : {}
        ; 
   
    my $status_rs = $c->stash->{status_list};
 
    $status_rs = $status_rs->search(
        $search,
        {
            page => $page,
            rows => $entries_per_page,
            order_by => "$sidx $sord",
        }
    );
   
    my $response;
    $response->{page} = $page;
    $response->{total} = $status_rs->pager->last_page;
    $response->{records} = $status_rs->pager->total_entries;
    my @rows; 
    while (my $status = $status_rs->next) {
        my $row->{id} = $status->status_id;
        $row->{cell} = [
            $status->status_id,
            $status->active,
            $status->name,
        ];
        push @rows, $row;
    }
    $response->{rows} = \@rows;    

    $c->stash(
        %$response,
        current_view => 'JSON'
    );
}

sub edit : Chained('status') {
    my ($self, $c) = @_;
    $c->forward('save');
}

sub add : Chained('status_list') {
    my ($self, $c) = @_;
    $c->forward('save');
}

# both adding and editing happens here
# no need to duplicate functionality
sub save : Private {
    my ($self, $c) = @_;

    my $status = $c->stash->{status}
        || $c->model('AtacamaDB::Status')->new_result({});
    my $form = Atacama::Form::Status->new;
    $c->stash( template => 'status/edit.tt', form => $form );
    $form->process(item => $status, params => $c->req->params );
    return unless $form->validated;
    #$c->flash( message => 'Book created' );
    # Redirect the user back to the list page
    $c->response->redirect($c->uri_for_action('/status/list'));
}


__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

__END__