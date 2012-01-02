package Atacama::Schema::ResultSet::Remark;
use strict;
use warnings;

use base qw/DBIx::Class::ResultSet/;

sub save {
    my $self = shift;
    my $params = shift;
    
    return unless ($params and ref $params eq 'ARRAY' and @$params);
    my @primary_columns = $self->result_source->primary_columns;
    die "Funktion save nur fur einen Primaerschluessel implementiert"
        if @primary_columns > 1;
    my $primary_key = $primary_columns[0];
    my $columns_info = $self->result_source->columns_info;
    foreach my $param (@$params) {    
        my $is_empty = 1;
        foreach my $val (values %$param) {$is_empty = 0 if $val}                    
        next if $is_empty;
        my $row;
        if (exists $param->{$primary_key}
            && defined $param->{$primary_key}
            && $param->{$primary_key} ne ''
            ) {
            $row = $self->find($param->{$primary_key});
            next unless $row;
        }
        if ($row and $param->{DELETED}) {
            $row->delete;
            next;
        }
        my %integer_type = (smallint => 1,tinyint => 1,integer => 1,mediumint => 1); 
        next unless (%$param);
        my $column;
        foreach my $key (keys %$param) {
            if (exists $columns_info->{$key}) {
                if ($param->{$key} eq ''
                    and exists $integer_type{$columns_info->{$key}{data_type}}
                ){ $param->{$key} = undef; } 
                $column->{$key} = $param->{$key};        
            }
        }     
        if ($row) {
            $row->update($column);
        }
        else {
            $row = $self->create($column);        
        }
    }
}

1;