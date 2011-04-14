package Atacama::Controller::Order;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use JSON;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::Order - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Atacama::Controller::Order in Order.');
}

sub orders : Chained('/login/required') PathPart('order') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{orders} = $c->model('AtacamaDB::Order');
}

sub list : Chained('orders') PathPart('list') Args(0) {
    my ( $self, $c ) = @_;

    $c->log->debug('LIST: ');
    $c->log->debug('Filter stash: ' . $c->session->{order}{list}{filters});

    $c->stash(
        projects => [
            $c->model('AtacamaDB::Project')->search(
                undef,
                {order_by => 'name'}
            )->all
        ],       
        status => [ $c->model('AtacamaDB::Status')->search({})->all ],
        json_url => $c->uri_for_action('order/json'),
        template => 'order/list.tt',
        filters => $c->session->{order}{list}{filters},
    ); 
}

sub json : Chained('orders') PathPart('json') Args(0) {
    my ($self, $c) = @_;

    my $data = $c->req->params;
    
    my $page = $data->{page} || 1;
    my $entries_per_page = $data->{rows} || 10;
    my $sidx = $data->{sidx} || 'order_id';
    my $sord = $data->{sord} || 'asc';
    
    my $search = $data->{searchField} && $data->{searchString} 
        ? { $data->{searchField} => $data->{searchString} }
        : {}
        ; 
   
    $c->log->debug('filters: ' . Dumper($data->{filters}));
    my $filters = $data->{filters};
    $filters = decode_json $filters if $filters;    

    $c->session->{order}{list}{filters} = $data->{filters};

       
    my $orders_rs = $c->stash->{orders};
    $orders_rs = $orders_rs->filter($filters);
    $orders_rs = $orders_rs->search(
        $search,
        {
            page => $page,
            rows => $entries_per_page,
            order_by => "$sidx $sord",
        }
    );
   
    my $response;
    $response->{page} = $page;
    $response->{total} = $orders_rs->pager->last_page;
    $response->{records} = $orders_rs->pager->total_entries;
    my @rows; 
    my $i = $orders_rs->pager->first;
    while (my $order = $orders_rs->next) {
        my $row->{id} = $order->order_id;
        $row->{cell} = [
            $order->order_id,
            $order->titel && $order->titel->titel_isbd,
            join(' -- ', map {$_->name} $order->projects->all),
            $order->status && $order->status->name,
        ];
        push @rows, $row;
        $i++
    }
    $response->{rows} = \@rows;    

    $c->stash(
        %$response,
        current_view => 'JSON'
    );
}


sub order : Chained('orders') PathPart('') CaptureArgs(1) {
    my ($self, $c, $order_id) = @_;

    my $order = $c->stash->{order} = $c->stash->{orders}->find($order_id)
        || $c->detach('not_found');
}

sub edit : Chained('order') {
    my ($self, $c) = @_;
    $c->forward('save');
}

sub add : Chained('orders') {
    my ($self, $c) = @_;
    $c->forward('save');
}

# both adding and editing happens here
# no need to duplicate functionality
sub save : Private {
    my ($self, $c) = @_;

    my $order = $c->stash->{order} || $c->model('AtacamaDB::Order')->new_result({});
    if ($c->req->method eq 'POST') {
        $c->log->debug(Dumper($c->req->params));
        my $order_params = $self->list_to_hash($c, $c->req->params);
        # $c->log->debug(Dumper($order_params));
        $order->save($order_params);
    }
    #$c->log->debug(Dumper($order->properties));
    $c->stash(
        %{$order->properties},      
        template => 'order/edit.tt',   
    );
}

sub print : Chained('order') {
    my ($self, $c)  = @_;
    
    my $order = $c->stash->{order};
    
    $c->stash->{template} = 'order/print.tt'; 
    if ($c->forward( 'Atacama::View::PDF')) {
         $c->response->content_type('application/pdf');
         $c->response->header('Content-Disposition', 'attachment; filename='
            . $order->order_id . 'pdf');
    }
}




sub not_found : Local {
    my ($self, $c) = @_;
    $c->response->status(404);
    $c->stash->{error_msg} = "Auftrag nicht gefunden!";
    $c->detach('list');
}

sub list_to_hash {
    my ($self, $c, $params) = @_;
  
    my %order_params;
    while (my($key,$value) = each %$params) {
        $c->log->debug("key: " . $key . " value: " . Dumper($value));
        $value =~ s/^\s+//;
        $value =~ s/\s+$//;
        # $c->log->debug("key/value:" . $key . ": " . $value);
        next unless ($key);
        next if $key =~ /save/i;
        if ($key =~ /^([a-z_]+)\.(\d+)\.([a-z_]+)\.(\d+)\.([a-z_]+|DELETED)$/) {
            $order_params{$1}[$2]{$3}[$4]{$5} = $value;
            next;
        }
        if ($key =~ /^([a-z_]+)\.(\d+)\.([a-z_]+|DELETED)$/) {
            $order_params{$1}[$2]{$3} = $value;
            next;
        }
        if ($key =~ /^([a-z_]+)\.([a-z_]+)$/) {
            $order_params{$1}{$2} = $value;
            next;
        }
        if ($key =~ /^([a-z_]+)$/) {
            $order_params{$1} = $value;
            next;
        }
    }    
    return \%order_params;
}

=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
