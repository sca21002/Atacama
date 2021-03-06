package Atacama::Schema::ResultSet::Order;

# ABSTRACT: Result set for Order

use Moose;
use namespace::autoclean;
use MooseX::NonMoose;
extends 'DBIx::Class::ResultSet';
    with 'Atacama::SchemaRole::ResultSet::Navigate';
use feature qw(switch); 
 
 
sub BUILDARGS { $_[2] }

sub create_order {
    my ($self, $vals) = @_;

    # warn "VALS: " . Dumper($vals);    
    die 'HASHREF expected' unless ref($vals) eq 'HASH'; 
    
    $vals->{order_id} ||=  $self->next_order_id;
    $vals->{creation_date} = DateTime->now(
            locale      => 'de_DE',
            time_zone   => 'Europe/Berlin',
    );       
    $self->create($vals);   
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
                push @and_cond, { 'me.status_id' => $data } ;
            
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

sub get_status_order_count {
    my $self = shift;
    my $params = shift;
    
    my $joins = [qw( status )];
    my $where;
        
        
    if ($params->{project_id}) {
        push @$joins, 'orders_projects'; 
        $where->{'orders_projects.project_id'} = $params->{project_id};  
    }
        
    return $self->search(
        $where,
        {
            join     => $joins,
            select   => [ 'status.name', { count => 'me.order_id'} ],
            as => [qw( status_name order_count ) ],
            group_by => 'status.status_id',
            result_class => 'DBIx::Class::ResultClass::HashRefInflator',
        }
    )->all;
}

1; # Magic true value required at end of module
