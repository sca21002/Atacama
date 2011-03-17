package Atacama::Controller::Job;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use JSON;
use Try::Tiny;
use Atacama::Helper::TheSchwartz::Scoreboard;
use Data::Page;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::Job - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Atacama::Controller::Job in Job.');
}

sub jobs : Chained('/login/required') PathPart('job') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{jobs} = $c->model('TheSchwartzDB');
}

sub list : Chained('jobs')  PathPart('list') Args(0) {
    my ($self, $c) = @_;

    $c->stash(
        json_url => $c->uri_for_action('job/json'),
        template => 'job/list.tt'
    ); 
}


sub json : Chained('jobs') PathPart('json') Args(0) {
    my ($self, $c) = @_;

    my $data = $c->req->params;
    my $page = Data::Page->new();
    $page->current_page( $data->{page} || 1 );
    $page->entries_per_page( $data->{rows} || 10 );
    my $sidx = $data->{sidx} || 'pid';
    my $sord = $data->{sord} || 'asc';
    
    my $scoreboard;
    try {
        $scoreboard = Atacama::Helper::TheSchwartz::Scoreboard->new(
            dir => $c->config->{'Atacama::Controller::Job'}{score_dir},
        );
    }
    catch {
        $c->error('scoreboard nicht gefunden');
        $c->detach;       
    };

    $page->total_entries( scalar @{$scoreboard->jobs} );
    my $response;
    $response->{page} = $page->current_page;
    $response->{total} = $page->last_page;
    $response->{records} = $page->total_entries;
    my @rows;
    foreach my $job (
        @{ $scoreboard->jobs }[ $page->first-1 .. $page->last -1 ] # array-slice
    ) {
        my $row->{id} = $job->pid;
        $row->{cell} = [
            $job->pid,
            $job->order_id,
            $job->funcname,
            $job->started->strftime('%d.%m.%Y %T'),
            $job->done->strftime('%d.%m.%Y %T'),
            $job->runtime,
            $job->copy_files,
            $job->digifooter,
            $job->mets,
            $job->csv,
            $job->source_format,
            $job->source_pdf_name,
            $job->additional_args,
        ];
        push @rows, $row;
    }
    $response->{rows} = \@rows;    

    $c->stash(
        %$response,
        current_view => 'JSON'
    );    
    
}

sub worker : Chained('jobs') PathPart('') CaptureArgs(1) {
    my ($self, $c, $worker) = @_;
    
    my $class = 'Atacama::Worker::' . ucfirst $worker;
    Class::MOP::load_class($class);
}

sub add : Chained('worker') PathPart('add') Args(0) {
    my ($self, $c) = @_;
    
    my $jobs = $c->stash->{jobs};
    $c->log->debug($c->log->debug(Dumper($c->req->params)));
    my $job = TheSchwartz::Job->new (
        funcname => 'Atacama::Worker::Remedi',
        arg => $c->req->params,
    );
    $jobs->insert($job);    
    $c->res->redirect(
        $c->uri_for_action('/order/edit', [$c->req->params->{order_id}] )
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
