package Atacama::Controller::Scanfile;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use JSON;


BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::Scanfile - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub scanfiles : Chained('/order/order') PathPart('scanfiles') CaptureArgs(0) {
    my ($self, $c) = @_;
}


sub list : Chained('scanfiles')  PathPart('list') Args(0) {
    my ($self, $c) = @_;

    my $order = $c->stash->{order};
    $c->stash(
        json_url => $c->uri_for_action('scanfile/json', [$order->order_id]),
        template => 'scanfile/list.tt'
    ); 
}


sub json : Chained('scanfiles') PathPart('json') Args(0) {
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
        :  $data->{sidx} eq 'imagesize'
        ? \('height_px * width_px ' . $data->{sord})
        :  $data->{sidx} eq 'papersize'
        ? \('height_px * width_px / resolution ' . $data->{sord})
        :  $data->{sidx} . " " . $data->{sord}
        ;

    my $scanfile_rs = $order->scanfiles->search(undef,
        {
            page => $page,
            rows => $entries_per_page,
            order_by => $order_by,
        }
    );

    my $response;
    $response->{page} = $page;
    $response->{total} = $scanfile_rs->pager->last_page;
    $response->{records} = $scanfile_rs->pager->total_entries;
    my @rows; 
    while (my $scanfile = $scanfile_rs->next) {
        my $row->{id} = $scanfile->filepath . $scanfile->filename;
        $row->{cell} = [
            $scanfile->filename,
            $scanfile->format,
            $scanfile->colortype,
            $scanfile->resolution,
            sprintf(
                "%d x % d",
                $scanfile->height_px,
                $scanfile->width_px,
            ),    
            sprintf(
                "%.1f x %.1f",
                $scanfile->height_px / $scanfile->resolution * 2.54,
                $scanfile->width_px / $scanfile->resolution * 2.54,
            ),
            sprintf("%.1f", $scanfile->filesize / 1024 / 1024),
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

=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
