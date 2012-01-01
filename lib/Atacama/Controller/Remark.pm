package Atacama::Controller::Remark;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use JSON;


BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::Remark - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub remarks : Chained('/order/order') PathPart('remarks') CaptureArgs(0) {
    my ($self, $c) = @_;
}

sub json : Chained('remarks') PathPart('json') Args(0) {
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
        ? { -desc => [ qw/date/ ] }
        :  $data->{sidx} . " " . $data->{sord}
        ;

    my $remark_rs = $order->remarks->search(undef,
        {
            page => $page,
            rows => $entries_per_page,
            order_by => $order_by,
        }
    );

    my $response;
    $response->{page} = $page;
    $response->{total} = $remark_rs->pager->last_page;
    $response->{records} = $remark_rs->pager->total_entries;
    my @rows; 
    while (my $remark = $remark_rs->next) {
        my $row->{id} = $remark->remark_id;
        $row->{cell} = [
            $remark->date->strftime('%d.%m.%Y %T'),
            $remark->login,
            $remark->status->name,
            $remark->content,
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
