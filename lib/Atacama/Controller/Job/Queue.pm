package Atacama::Controller::Job::Queue;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use Storable();
BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::Job::Queue - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Atacama::Controller::Job::Queue in Job::Queue.');
}

sub queue : Chained('/job/jobs') PathPart('queue') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{queue} = $c->model('AtacamaDB::Job');
}

sub list : Chained('queue') PathPart('list') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        json_url => $c->uri_for_action('job/queue/json'),
        template => 'job/queue/list.tt'
    ); 
}

sub json : Chained('queue') PathPart('json') Args(0) {
    my ($self, $c) = @_;

    my $data = $c->req->params;
    $c->log->debug(Dumper($data));
    
    my $page = $data->{page} || 1;
    my $entries_per_page = $data->{rows} || 10;
    my $sidx = $data->{sidx} || 'jobid';
    my $sord = $data->{sord} || 'asc';
    
    my $search = $data->{searchField} && $data->{searchString} 
        ? { $data->{searchField} => $data->{searchString} }
        : {}
        ; 
   
    my $queue_rs = $c->stash->{queue};
 
    $queue_rs = $queue_rs->search(
        $search,
        {
            page => $page,
            rows => $entries_per_page,
            order_by => "$sidx $sord",
        }
    );
   
    my $response;
    $response->{page} = $page;
    $response->{total} = $queue_rs->pager->last_page;
    $response->{records} = $queue_rs->pager->total_entries;
    my @rows; 
    while (my $job = $queue_rs->next) {
        my $arg = Storable::thaw($job->arg);
        $c->log->debug('Arg: ' . $arg);
        my $order_id = $arg->{order_id};
        my ($function) = reverse split /::/, $job->function->funcname;
        my $row->{id} = $job->jobid;
        $row->{cell} = [
            $job->jobid,
            $order_id,
            $function,
            $job->uniqkey,
            $job->insert_time->set_time_zone('Europe/Berlin')
                ->strftime('%d.%m.%Y %T'),
            $job->run_after->set_time_zone('Europe/Berlin')
                ->strftime('%d.%m.%Y %T'),
            $job->grabbed_until->set_time_zone('Europe/Berlin')
                ->strftime('%d.%m.%Y %T'),
            $job->priority,
            $job->coalesce
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
