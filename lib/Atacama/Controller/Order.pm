use utf8;
package Atacama::Controller::Order;
use Modern::Perl;
use Moose;
use namespace::autoclean;
use JSON;


BEGIN {extends 'Catalyst::Controller'; }

# ABSTRACT: Controller for listing and editing orders

=head1 NAME

Atacama::Controller::Order - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub orders : Chained('/base') PathPart('order') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{order_rs} = $c->model('AtacamaDB::Order');
}

sub list : Chained('orders') PathPart('list') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        projects => [
            $c->model('AtacamaDB::Project')->search(
                { active => 1 },
                { order_by => 'name' },
            )->all
        ],       
        status => [ 
            $c->model('AtacamaDB::Status')->search(
                { active => 1 },
                { order_by => 'sort' },
            )->all ],
        json_url => $c->uri_for_action('order/json'),
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
   
    my $filters = $data->{filters};
    $filters = from_json $filters if $filters;   

    my $orders_rs = $c->stash->{order_rs}->filter($filters);
    $orders_rs = $orders_rs->search(
        $search,
        {
            prefetch => [
                'status',
                'titel',
                { orders_projects => {project => 'projectkeys'} },
            ],
            page => $page,
            rows => $entries_per_page,
            order_by => {"-$sord" => "me.$sidx"},
        }
    );

    $c->session(
        order => {
            list => {        
                filters => $data->{filters},        
                search =>  $search,
                sidx => $sidx, 
                sord => $sord,
            }
        }
    );
   
    my $response;
    $response->{page} = $page;
    $response->{total} = $orders_rs->pager->last_page;
    $response->{records} = $orders_rs->pager->total_entries;
    my @rows; 
    while (my $order = $orders_rs->next) {
        my $row->{id} = $order->order_id;
        $row->{cell} = [
            $order->order_id,
            $order->titel && $order->titel->titel_isbd
                || $order->title
                    && $order->title =~ /\S/ && 'alt: ' . $order->title
                || '(kein Titel)' ,
            $order->orders_projects->get_projects_as_string,
            $order->status && $order->status->name,
        ];
        push @rows, $row;
    }
    $response->{rows} = \@rows;    

    $c->stash(
        %$response,
        current_view => 'JSON'
    );
}


sub order : Chained('orders') PathPart('') CaptureArgs(1) {
    my ($self, $c, $order_id) = @_;

    my $filters = $c->session->{order}{list}{filters};
    $filters = from_json $filters if $filters;   
    my $order_rs = $c->stash->{order_rs}->filter($filters);
    
    my $order = $order_rs->find($order_id) || $c->detach('not_found');
    
    $c->stash(
        order_rs     => $order_rs,
        order        => $order,
        orders_count => $order_rs->count,
    );
}

sub edit : Chained('order') {
    my ($self, $c) = @_;
    $c->forward('navigate') if $c->req->params->{navigate};
    $c->forward('save');
}

sub navigate : Private {
    my ($self, $c) = @_;
    
    my ($search, $sidx, $sord)                    
        = @{ $c->session->{order}{list} }{ qw(search sidx sord) };  # hash-slice
    $sidx ||= 'order_id';
    $sord ||= 'asc';
    
    my $order_rs = $c->stash->{order_rs};
    my $order     = $c->stash->{order};   
    my $navigate = $c->req->params->{navigate};
    my $resp = $c->response;
    my $attrib = { sidx => $sidx, sord => $sord }; 
    
    if (my $order = $order_rs->navigate($navigate, $order, $attrib)) {
        $resp->redirect($c->uri_for_action('/order/edit', [$order->order_id]));
    } else { $c->detach('not_found') }
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
        my $order_params = $self->list_to_hash($c, $c->req->params);
        if ( $order_params->{titel}{katkey}  and not ( $order->titel && $order->titel->katkey eq  $order_params->{titel}{katkey}  )   ) {
            $c->log->debug('Titel holen');
            $c->stash->{katkey} = $order_params->{titel}{katkey};
            $c->stash->{signatur} = $order_params->{titel}{signatur};
            $c->stash->{titel} = $c->model('AtacamaDB::Titel');
            $c->forward('/titel/get_title_by_katkey');
            $order_params->{titel} = {  %{$order_params->{titel}}, %{$c->stash->{titel_data}} };
            delete $order_params->{titel}{order_id};
        }
        if ( $order_params->{remark} or  $order->status_id != $order_params->{status_id}  ) 
        {
            $order_params->{remarks} = [{
                login => $c->stash->{user},
                status_id => $order_params->{status_id},
                content => $order_params->{remark},
            }];
            delete $order_params->{remark};                            
        }
        $c->log->debug('STATUS: ' . $order->status_id . ' <=> ' . $order_params->{status_id});
        $order->save($order_params);
    }
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
    
    my $orders_rs = $c->stash->{order_rs};
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
        # $c->log->debug("key: " . $key . " value: " . Dumper($value));
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
