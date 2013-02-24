package Atacama::Controller::Project;
use Moose;
use namespace::autoclean;
use Atacama::Form::Project;
use Data::Dumper;


BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::Project - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Atacama::Controller::Project in Project.');
}

sub projects : Chained('/base') PathPart('project') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{projects} = $c->model('AtacamaDB::Project');
}

sub project : Chained('projects') PathPart('') CaptureArgs(1) {
    my ($self, $c, $project_id) = @_;

    my $project = $c->stash->{project}
        = $c->stash->{projects}->find($project_id) || $c->detach('not_found');
}

sub list : Chained('projects') PathPart('list') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        json_url => $c->uri_for_action('project/json'),
        template => 'project/list.tt'
    ); 
}


sub json : Chained('projects') PathPart('json') Args(0) {
    my ($self, $c) = @_;

    my $data = $c->req->params;
    $c->log->debug(Dumper($data));
    
    my $page = $data->{page} || 1;
    my $entries_per_page = $data->{rows} || 10;
    my $sidx = $data->{sidx} || 'project_id';
    my $sord = $data->{sord} || 'asc';
    
    my $search = $data->{searchField} && $data->{searchString} 
        ? { $data->{searchField} => $data->{searchString} }
        : {}
        ; 
   
    my $projects_rs = $c->stash->{projects};
 
    $projects_rs = $projects_rs->search(
        $search,
        {
            page => $page,
            rows => $entries_per_page,
            order_by => "$sidx $sord",
        }
    );
   
    my $response;
    $response->{page} = $page;
    $response->{total} = $projects_rs->pager->last_page;
    $response->{records} = $projects_rs->pager->total_entries;
    my @rows; 
    while (my $project = $projects_rs->next) {
        my $row->{id} = $project->project_id;
        $row->{cell} = [
            $project->project_id,
            $project->name,
        ];
        push @rows, $row;
    }
    $response->{rows} = \@rows;    

    $c->stash(
        %$response,
        current_view => 'JSON'
    );
}

sub edit : Chained('project') {
    my ($self, $c) = @_;
    $c->forward('save');
}

sub add : Chained('projects') {
    my ($self, $c) = @_;
    $c->forward('save');
}

# both adding and editing happens here
# no need to duplicate functionality
sub save : Private {
    my ($self, $c) = @_;

    my $project = $c->stash->{project}
        || $c->model('AtacamaDB::Project')->new_result({});
    my $form = Atacama::Form::Project->new;
    $c->stash( template => 'project/edit.tt', form => $form );
    $form->process(item => $project, params => $c->req->params );
    return unless $form->validated;
    #$c->flash( message => 'Book created' );
    # Redirect the user back to the list page
    $c->response->redirect($c->uri_for_action('/project/list'));
}


=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
