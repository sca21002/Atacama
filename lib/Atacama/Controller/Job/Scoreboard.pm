package Atacama::Controller::Job::Scoreboard;

# ABSTRACT: Controller for the scoreboard of the job queue

use Moose;
use namespace::autoclean;
use Data::Dumper;
use JSON;
use Path::Tiny;
use Try::Tiny;
use Atacama::Helper::TheSchwartz::Scoreboard;
use Data::Page;

BEGIN {extends 'Catalyst::Controller'; }

sub scoreboard : Chained('/job/jobs') PathPart('scoreboard') CaptureArgs(0) {
    my ($self, $c) = @_;    

    my $scoreboard;
    try {
        my $score_dir = $c->config->{'Atacama::Controller::Job'}{scoreboard_dir};
        $c->log->debug("Scoreboard_dir: $score_dir"); 
        $scoreboard = Atacama::Helper::TheSchwartz::Scoreboard->new(
            dir => path($score_dir, 'theschwartz'),
        );
    }
    catch {
        $c->error("Scoreboard nicht gefunden: $_");
        $c->detach('not_found');       
    };    
    $c->stash(scoreboard => $scoreboard);    
}

sub list : Chained('scoreboard')  PathPart('list') Args(0) {
    my ($self, $c) = @_;

    $c->stash(
        json_url => $c->uri_for_action('job/scoreboard/json'),
        template => 'job/scoreboard/list.tt'
    ); 
}

sub json : Chained('scoreboard') PathPart('json') Args(0) {
    my ($self, $c) = @_;

    my $data = $c->req->params;
    my $page = Data::Page->new();
    $page->current_page( $data->{page} || 1 );
    $page->entries_per_page( $data->{rows} || 10 );
    my $sidx = $data->{sidx} || 'pid';
    my $sord = $data->{sord} || 'asc';
    
    my $scoreboard = $c->stash->{scoreboard};

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
            $job->started->set_time_zone('Europe/Berlin')
                ->strftime('%d.%m.%Y %T'),
            $job->done ? $job->done->set_time_zone('Europe/Berlin')
                ->strftime('%d.%m.%Y %T') : '(running)',
            $job->runtime,
        ];
        push @rows, $row;
    }
    $response->{rows} = \@rows;    

    $c->stash(
        %$response,
        current_view => 'JSON'
    );    
}

sub job : Chained('scoreboard') PathPart('') CaptureArgs(1) {
    my ($self, $c, $pid) = @_;

    my $scoreboard = $c->stash->{scoreboard};
    my ($job) = grep { $_->pid eq $pid } @{$scoreboard->jobs}
    	or $c->detach('not_found');
    $c->stash(job => $job);
}

sub show : Chained('job') PathPart('show') Args(0) {
    my ($self, $c) = @_;

    $c->stash(template => 'job/scoreboard/show.tt');     
}

sub not_found : Local {
    my ($self, $c) = @_;
    $c->response->status(404);
    $c->stash->{error_msg} = "Job nicht gefunden!";
    $c->detach('list');
}

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

__END__
