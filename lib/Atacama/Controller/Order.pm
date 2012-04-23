package Atacama::Controller::Order;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use JSON;
use utf8;

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

    # $c->log->debug('LIST: ');
    # $c->log->debug('Filter stash: ' . $c->session->{order}{list}{filters});
    $c->log->debug(Dumper($c->user->login));
    $c->log->debug($c->user->name);
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
   
    # $c->log->debug('filters: ' . Dumper($data->{filters}));
    my $filters = $data->{filters};
    # $filters = decode_json $filters if $filters; ging nicht mit utf8??    
    $filters = from_json $filters if $filters;   

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
            $order->titel && $order->titel->titel_isbd
                || $order->title =~ /\S/ && 'alt: ' . $order->title ,
            $order->orders_projects->get_projects_as_string,
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


sub put : Chained('orders') {
    my ($self, $c) = @_;
    
    $c->log->debug(Dumper($c->req->params));
    my $order_params = $self->list_to_hash($c, $c->req->params);
    $c->stash->{signatur} = $order_params->{titel}{signatur};
    $c->stash->{mediennr} = $order_params->{titel}{mediennr};
    
    $c->log->debug('order_params' . Dumper ($order_params));
    
    $c->stash->{titel} = $c->model('AtacamaDB::Titel');
    $c->forward('/titel/get_title');
    my $titel = $c->stash->{titel_data};
    
         
	# TODO: abfangen, wenn titel_data undefined!
    #$c->log->debug('titel_data ' . Dumper($titel));
    if (scalar @$titel == 1) {
        delete $titel->[0]->{titel_isbd};
        delete $titel->[0]->{order_id};
        $order_params->{titel} = { %{$order_params->{titel}}, %{$titel->[0]} };
        my $order = $c->model('AtacamaDB::Order')->create_order(
           $order_params,
        );

        # my $titel_new = $order->create_related('titel', {});
        # $order->titel->save($titel->[0]);
        $c->stash->{order} = $order;
    }
    $c->forward('save');
    $c->res->redirect(
        $c->uri_for_action('/order/edit', [ $c->stash->{order}->order_id ] )
    );
}

sub add : Chained('orders') {
    my ($self, $c) = @_;
    $c->forward('save');
    $c->res->redirect(
        $c->uri_for_action('/order/edit', [ $c->stash->{order}->order_id ] )
    );
}

# both adding and editing happens here
# no need to duplicate functionality
sub save : Private {
    my ($self, $c) = @_;

    my $order = $c->stash->{order}
        ||= $c->model('AtacamaDB::Order')->create_order({});
    if ($c->req->method eq 'POST') {
        $c->log->debug(Dumper($c->req->params));
        # $c->log->debug('Method: ' .Dumper($c->req->method));
        my $order_params = $self->list_to_hash($c, $c->req->params);
        $c->log->debug('Orderparams: ' . Dumper($order_params));
        # $c->log->debug('BVNr: ' . $order_params->{titel}{bvnr});
        # $c->log->debug($order->titel ? $order->titel->bvnr || '' : 'kein Titel');
        #if ( $order_params->{titel}{bvnr}  and not ( $order->titel && $order->titel->bvnr eq  $order_params->{titel}{bvnr}  )   ) {
        #    # $c->log->debug('Titel holen');
        #    $c->stash->{bvnr} = $order_params->{titel}{bvnr};
        #    $c->stash->{titel} = $c->model('AtacamaDB::Titel');
        #    $c->forward('/titel/get_title_by_bvnr');
        #    $order_params->{titel} = {  %{$order_params->{titel}}, %{$c->stash->{titel_data}} };
        #    delete $order_params->{titel}{order_id};
        #}
        
        if ( $order_params->{titel}{katkey}  and not ( $order->titel && $order->titel->katkey eq  $order_params->{titel}{katkey}  )   ) {
            $c->log->debug('Titel holen');
            $c->stash->{katkey} = $order_params->{titel}{katkey};
            $c->stash->{signatur} = $order_params->{titel}{signatur};
            $c->stash->{titel} = $c->model('AtacamaDB::Titel');
            $c->forward('/titel/get_title_by_katkey');
            $c->log->debug('order->titel ' . Dumper($order_params->{titel}));
            $c->log->debug('titel_data ' . Dumper($c->stash->{titel_data}));
            $order_params->{titel} = {  %{$order_params->{titel}}, %{$c->stash->{titel_data}} };
            delete $order_params->{titel}{order_id};
            $c->log->debug('order_params ' . Dumper($order_params->{titel}));
        }
        if ( exists $order_params->{remark} ) {
            if ( $order_params->{remark} ) {
                $order_params->{remarks} = [{
                    login => $c->user->login,
                    status_id => defined $order_params->{status_id}
                                 ? $order_params->{status_id}
                                 : $order->status_id,
                    content => $order_params->{remark},
                }];
            }
            delete $order_params->{remark};                            
        }
        $order->save($order_params);
    }
    #$c->log->debug(Dumper($order->properties));
    $c->stash(
        %{$order->properties},      
        umlaute => 'ÄÜÖäüÖß',
        template => 'order/edit.tt', 
        json_url_remarks => $c->uri_for_action('remark/json', [$order->order_id]),  
    );
    
}

sub delete : Chained('order') {
    my ($self, $c) = @_;
    
    my $order = $c->stash->{order};
    $order->delete();
    $c->res->redirect($c->uri_for_action('/order/list'));
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

sub print_patchcode_t : Chained('order') {
    my ($self, $c)  = @_;
    
    my $order = $c->stash->{order};
	$c->stash->{orders2print} = [ $order ];
    
    $c->stash->{template} = 'order/print_patchcode_t.tt'; 
    if ($c->forward( 'Atacama::View::PDF')) {
         $c->response->content_type('application/pdf');
         $c->response->header('Content-Disposition', 'attachment; filename='
            . $order->order_id . 'pdf');
    }
}

sub print_patchcode_t_all : Chained('orders') PathPart('print_patchcode') Args(0){ 
    my ($self, $c)  = @_;
    
    my $orders_rs = $c->stash->{orders};
    my $page = $c->req->query_params->{page} || 1;
    
    $orders_rs = $orders_rs->search(
        {
            'orders_projects.project_id' => { 'IN' => [3, 26, 40] },
            status_id => 1,
        },
        {
            join => 'orders_projects', 
            page => $page,
            rows => 100,
            order_by => 'order_id',
        }
    );
    $c->stash->{orders2print} = [ $orders_rs->all ];
    
    $c->stash->{template} = 'order/print_patchcode.tt'; 
    if ($c->forward( 'Atacama::View::PDF' )) {
         $c->response->content_type('application/pdf');
         $c->response->header('Content-Disposition', 'attachment; filename='
            . 'test' . 'pdf');
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
    $order_params{'ocr'} ||= 0; # Needed for ocr checkbox, since an unchecked
                                # checkbox does not return a parameter
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
