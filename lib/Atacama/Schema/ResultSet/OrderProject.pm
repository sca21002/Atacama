package Atacama::Schema::ResultSet::OrderProject;
use strict;
use warnings;

use base qw/DBIx::Class::ResultSet/;

sub get_new_result_as_href {
    my $self = shift;
    my $args = shift;

    my $row = $self->new_result($args);
    my $href = { map {$_, $row->$_ || ''} $row->columns };
    $href->{projectoptions} = $row->projectoptions;
    my %rel = (
        projects => {resultset => 'Project', columns => ['project_id', 'name']},
    );           
    while ( my($rel, $val) = each %rel ) {
        $href->{$rel} = [$row->result_source->schema->resultset($val->{resultset})
            ->search({},{
                result_class => 'DBIx::Class::ResultClass::HashRefInflator',
                columns => $val->{columns},
            })->all];    
    }    
    return $href;
}

sub get_projects_as_string {
    my $self = shift;
    
    my @projects_as_string;
    while ( my $order_project = $self->next ) { 
        my $project = $order_project->project;
        my $project_as_string = $project->name;
        my @projectkeys = $project->projectkeys->all;
        foreach my $projectkey (@projectkeys) {
            if ( $projectkey->premiumkey ) {
                my $projectvalue = $order_project->search_related(
                    'projectvalues',
                    { projectkey_id => $projectkey->projectkey_id }
                )->single;
                $project_as_string .= ' (' . $projectvalue->value . ')'
                    if $projectvalue && $projectvalue->value;
            }
        }
        push @projects_as_string, $project_as_string; 
    }
    return join ' -- ', @projects_as_string;
}

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
        my $projectoptions;
        foreach my $key (keys %$param) {
            if (exists $columns_info->{$key}) {
                if ($param->{$key} eq ''
                    and exists $integer_type{$columns_info->{$key}{data_type}}
                ){ $param->{$key} = undef; } 
                $column->{$key} = $param->{$key};        
            }
            elsif ($key eq 'projectoptions' ) {
            	
            	$projectoptions = $param->{$key};
                
            }
        }     
        if ($row) {
            $row->update($column);
        }
        else {
            $row = $self->create($column);        
        }
        
        $row->save_projectoptions($projectoptions) if $projectoptions;    
    }
}

1;