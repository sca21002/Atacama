package Atacama::Controller::Ocrfile;

# ABSTRACT: Controller Ocrfile

use Moose;
use namespace::autoclean;
use Data::Dumper;
use JSON;


BEGIN {extends 'Catalyst::Controller'; }

sub ocrfiles : Chained('/order/order') PathPart('ocrfiles') CaptureArgs(0) {
    my ($self, $c) = @_;
}


sub list : Chained('ocrfiles')  PathPart('list') Args(0) {
    my ($self, $c) = @_;

    my $order = $c->stash->{order};
    $c->stash(
        json_url => $c->uri_for_action('ocrfile/json', [$order->order_id]),
        template => 'ocrfile/list.tt'
    ); 
}


sub json : Chained('ocrfiles') PathPart('json') Args(0) {
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

    my $ocrfile_rs = $order->ocrfiles->search(undef,
        {
            page => $page,
            rows => $entries_per_page,
            order_by => $order_by,
        }
    );

    my $response;
    $response->{page} = $page;
    $response->{total} = $ocrfile_rs->pager->last_page;
    $response->{records} = $ocrfile_rs->pager->total_entries;
    my @rows; 
    while (my $ocrfile = $ocrfile_rs->next) {
        my $row->{id} = $ocrfile->filepath . $ocrfile->filename;
        $row->{cell} = [
            $ocrfile->filename,
            $ocrfile->volume
                || sprintf(
                       "DATA%d",
                       $ocrfile->filepath =~ m#^/[^/]*DATA(\d)/#
                   )
                || ' ',
            sprintf("%.1f", $ocrfile->filesize / 1024 ),
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