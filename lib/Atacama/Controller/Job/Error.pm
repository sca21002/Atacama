package Atacama::Controller::Job::Error;
use Moose;
use namespace::autoclean;
use Data::Dumper;
BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::Job::Error - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub errors : Chained('/job/jobs') PathPart('error') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{errors} = $c->model('AtacamaDB::Error');
}

sub list : Chained('errors') PathPart('list') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        json_url => $c->uri_for_action('job/error/json'),
        template => 'job/error/list.tt'
    ); 
}

sub json : Chained('errors') PathPart('json') Args(0) {
    my ($self, $c) = @_;

    my $data = $c->req->params;
    $c->log->debug(Dumper($data));
    
    my $page = $data->{page} || 1;
    my $entries_per_page = $data->{rows} || 10;
    my $sidx = $data->{sidx} || 'job_id';
    my $sord = $data->{sord} || 'asc';
    
    my $search = $data->{searchField} && $data->{searchString} 
        ? { $data->{searchField} => $data->{searchString} }
        : {}
        ; 
   
    my $errors_rs = $c->stash->{errors};
 
    $errors_rs = $errors_rs->search(
        $search,
        {
            page => $page,
            rows => $entries_per_page,
            order_by => "$sidx $sord",
        }
    );
   
    my $response;
    $response->{page} = $page;
    $response->{total} = $errors_rs->pager->last_page;
    $response->{records} = $errors_rs->pager->total_entries;
    my @rows; 
    while (my $error = $errors_rs->next) {
        my ($function) = reverse split /::/, $error->function->funcname;
        my $row->{id} = $error->jobid;
        $row->{cell} = [
            $error->jobid,
            $function,
            $error->error_time->set_time_zone('Europe/Berlin')
                ->strftime('%d.%m.%Y %T'),
            $error->message,
        ];
        push @rows, $row;
    }
    $response->{rows} = \@rows;    

    $c->stash(
        %$response,
        current_view => 'JSON'
    );
}




=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
