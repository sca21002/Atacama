package Atacama::Controller::PDFfile;

# ABSTRACT: Controller PDFfile

use Moose;
use namespace::autoclean;
use Data::Dumper;
use JSON;


BEGIN {extends 'Catalyst::Controller'; }

sub pdffiles : Chained('/order/order') PathPart('pdffiles') CaptureArgs(0) {
    my ($self, $c) = @_;
}


sub list : Chained('pdffiles')  PathPart('list') Args(0) {
    my ($self, $c) = @_;

    my $order = $c->stash->{order};
    $c->stash(
        json_url => $c->uri_for_action('pdffile/json', [$order->order_id]),
        template => 'pdffile/list.tt'
    ); 
}


sub json : Chained('pdffiles') PathPart('json') Args(0) {
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

    my $pdffile_rs = $order->pdffiles->search(undef,
        {
            page => $page,
            rows => $entries_per_page,
            order_by => $order_by,
        }
    );

    my $response;
    $response->{page} = $page;
    $response->{total} = $pdffile_rs->pager->last_page;
    $response->{records} = $pdffile_rs->pager->total_entries;
    my @rows; 
    while (my $pdffile = $pdffile_rs->next) {
        my $row->{id} = $pdffile->filepath . $pdffile->filename;
        $row->{cell} = [
            $pdffile->filename,
            $pdffile->filepath,
            $pdffile->pages,
            sprintf("%.1f MB", $pdffile->filesize / 1024 / 1024),
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