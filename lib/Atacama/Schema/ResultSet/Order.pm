package Atacama::Schema::ResultSet::Order;
use strict;
use warnings;

use base qw/DBIx::Class::ResultSet/;
use Carp;
use Data::Dumper;
use feature qw(switch);

sub create_order {
    my ($self, $order_id) = @_;    
    
    $self->create({
        order_id        => $order_id || $self->next_order_id,
        creation_date   => DateTime->now(
            locale      => 'de_DE',
            time_zone   => 'Europe/Berlin',
        ),       
    });   
    
}

sub next_order_id {
    my $self = shift;    
    
    my ($order_last) 
        = $self->search(
            { order_id => { 'like', 'ubr%' },},
            { order_by => 'order_id DESC'}
          )->slice(0,1);
    my $order_id = $order_last->order_id;
    $order_id++;
    return $order_id++;
}




sub filter {
    my ($self, $filters) = @_;

    my @and_cond;
    my @join_attr;
  
    foreach my $rule ( @{ $filters->{rules} } ) {
        my $data = $rule->{data};
        given ( $rule->{field} ) {
            when (/order_id/) {
                push @and_cond, { 'me.order_id' => { like => "%$data%" } };
            };    
            when (/titel_isbd/) {
                push @join_attr, 'titel';
                my @tokens = split /\s+/, $data;
                my @search_fields = qw(
                    autor_uw titel_uw autor_avs titel_avs zusatz verlagsort
                    verlag erschjahr 
                );            
                @search_fields = _cross(\@search_fields, \@tokens);
                push @and_cond, @search_fields;
            };    
            when (/status_id/) {
                push @and_cond, { status_id => $data } ;
            
            };
            when (/project_id/) {
                push @join_attr, 'orders_projects';
                push @and_cond, { 'orders_projects.project_id' => $data };
            };
        }    
    }
    return $self->search( { -and => \@and_cond }, { join => \@join_attr } );
}


sub _cross {
    my $columns = shift || [];
    my $tokens  = shift || [];
    map {s/%/\\%/g} @$tokens;
    
    my @result;
    foreach my $token (@$tokens) {
        push @result, [ map +{ $_ => {like => "%$token%"} }, @$columns ];    
    }
    return @result;
}

1;