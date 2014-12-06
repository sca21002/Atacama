package Atacama::Controller::Jobfile;

# ABSTRACT: Controller Jobfile

use Moose;
use namespace::autoclean;
use Data::Dumper;
use JSON;


BEGIN {extends 'Catalyst::Controller'; }

sub jobfiles : Chained('/order/order') PathPart('jobfiles') CaptureArgs(0) {
    my ($self, $c) = @_;
}


sub list : Chained('jobfiles')  PathPart('list') Args(0) {
    my ($self, $c) = @_;

    my $order = $c->stash->{order};
    $c->stash(
        json_url => $c->uri_for_action('jobfile/json', [$order->order_id]),
        template => 'jobfile/list.tt'
    ); 
}


sub json : Chained('jobfiles') PathPart('json') Args(0) {
    my ($self, $c) = @_;

    my $data = $c->req->params;
    $c->log->debug(Dumper($data));

    my $page = $data->{page} || 1;
    my $entries_per_page = $data->{rows} || 10;

    my $order = $c->stash->{order};
    my $order_by =
        $data->{sidx} eq 'id'
            || !exists($data->{sidx})
            || !exists($data->{sord})
        ? { -asc => [ qw/filename/ ] }
        :  $data->{sidx} . " " . $data->{sord}
        ;

    my $jobfile_rs = $order->jobfiles->search(undef,
        {
            page => $page,
            rows => $entries_per_page,
            order_by => $order_by,
        }
    );

    my $response;
    $response->{page} = $page;
    $response->{total} = $jobfile_rs->pager->last_page;
    $response->{records} = $jobfile_rs->pager->total_entries;
    my @rows; 
    while (my $jobfile = $jobfile_rs->next) {
        my $row->{id} = $jobfile->filepath . $jobfile->filename;
        $row->{cell} = [
            $jobfile->filename,
            $jobfile->volume
                || sprintf(
                       "DATA%d",
                       $jobfile->filepath =~ m#^/[^/]*DATA(\d)/#
                   )
                || ' ',
            sprintf("%.1f MB", $jobfile->filesize / 1024 / 1024),    
        ];
        push @rows, $row;
    }
    $response->{rows} = \@rows;
    
    $c->stash(
        %$response,
        current_view => 'JSON'
    );
    #$c->response->body(encode_json($response));
}

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

__END__
