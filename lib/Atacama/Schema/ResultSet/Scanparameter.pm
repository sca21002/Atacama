package Atacama::Schema::ResultSet::Scanparameter;

# ABSTRACT: Result set for Scanparameter 

use strict;
use warnings;
use Data::Dumper;

use base qw/DBIx::Class::ResultSet/;
use Carp;

sub get_new_result_as_href {
	my $self = shift;
	my $args = shift;

	my $row = $self->new_result($args);
	my $href = { map { $_, $row->$_ || '' } $row->columns };
	$href->{scanoptions} = $row->scanoptions;
	my %rel = (
		scanners =>
		  { resultset => 'Scanner', columns => [ 'scanner_id', 'name' ] },
		formats =>
		  { resultset => 'Format', columns => [ 'format_id', 'name' ] },
		resolutions => {
			resultset => 'Resolution',
			columns   => [ 'resolution_id', 'value' ]
		},
	);
	while ( my ( $rel, $val ) = each %rel ) {
		$href->{$rel} = [
			$row->result_source->schema->resultset( $val->{resultset} )->search(
				{},
				{
					result_class => 'DBIx::Class::ResultClass::HashRefInflator',
					columns      => $val->{columns},
				}
			  )->all
		];
	}
	return $href;
}

sub save {
	my $self   = shift;
	my $params = shift;

	return unless ( $params and ref $params eq 'ARRAY' and @$params );
	my @primary_columns = $self->result_source->primary_columns;
	die "Funktion save nur fur einen Primaerschluessel implementiert"
	  if @primary_columns > 1;
	my $primary_key  = $primary_columns[0];
	my $columns_info = $self->result_source->columns_info;

	foreach my $param (@$params) {
		my $is_empty = 1;
		foreach my $val ( values %$param ) { $is_empty = 0 if $val }
		next if $is_empty;
		my $row;
		if (   exists $param->{$primary_key}
			&& defined $param->{$primary_key}
			&& $param->{$primary_key} ne '' )
		{
			$row = $self->find( $param->{$primary_key} );
			next unless $row;
		}
		if ( $row and $param->{DELETED} ) {
			$row->delete;
			next;
		}
		my %integer_type =
		  ( smallint => 1, tinyint => 1, integer => 1, mediumint => 1 );
		next unless (%$param);
		my $column;
		foreach my $key ( keys %$param ) {
			if ( exists $columns_info->{$key} ) {
				if ( $param->{$key} eq ''
					and
					exists $integer_type{ $columns_info->{$key}{data_type} } )
				{
					$param->{$key} = undef;
				}
				$column->{$key} = $param->{$key};
			}
			
		}
		if ($row) {
			warn 'Column: ' . Dumper($column);
			$row->update($column);
		}
		else {
			$self->create($column);
		}
		
		
		
		if (   exists $param->{$primary_key}
			&& defined $param->{$primary_key}
			&& $param->{$primary_key} ne '' )
		{
			$row = $self->find( $param->{$primary_key} );
			next unless $row;
		}
		
		
		foreach my $key ( keys %$param ) {
			if ( $key eq 'scanoptions' and $row ) {
				$row->save_scanoptions( $param->{$key} );
			}
		}
	}
}

1; # Magic true value required at end of module
