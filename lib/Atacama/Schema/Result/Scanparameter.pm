package Atacama::Schema::Result::Scanparameter;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Atacama::Schema::Result::Scanparameter

=cut

__PACKAGE__->table("scanparameters");

=head1 ACCESSORS

=head2 scanparameter_id

  data_type: 'mediumint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 order_id

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 scanner_id

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 resolution_id

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 format_id

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 scope

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "scanparameter_id",
  {
    data_type => "mediumint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "order_id",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "scanner_id",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "resolution_id",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "format_id",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "scope",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("scanparameter_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-12-26 23:49:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VhwdNXjMZcrvFX6t2hvtsw


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
    "ord",
    "Atacama::Schema::Result::Order",
    { "foreign.order_id" => "self.order_id" }
);

__PACKAGE__->belongs_to(
    "scanner",
    "Atacama::Schema::Result::Scanner",
    { "scanner_id" => "scanner_id" }
);

__PACKAGE__->belongs_to(
    "format",
    "Atacama::Schema::Result::Format",
    { "format_id" => "format_id" }
);
__PACKAGE__->belongs_to(
    "resolution",
    "Atacama::Schema::Result::Resolution",
    { "resolution_id" => "resolution_id" }
);

__PACKAGE__->has_many(
    "scanoptionvalues",
    "Atacama::Schema::Result::Scanoptionvalue",
    { "foreign.scanparameter_id" => "self.scanparameter_id" }
);

use Data::Dumper;

sub scanoptions {
    my $self = shift;
    my $args = shift;
    
    my $with_options =
        !( $args && exists $args->{options} && !$args->{options} );  
    return unless $self->scanner;
    my @scanoptions;
    my @scanoptionkeys = $self->scanner->scanoptionkeys;
    foreach my $scanoptionkey (@scanoptionkeys) {
        my %scanoption;
        $scanoption{scanoptionkey_id} = $scanoptionkey->scanoptionkey_id;
        $scanoption{skey} = $scanoptionkey->skey;
        
        if ($with_options) {
            my @scanoptionnames = $scanoptionkey->search_related('scanoptionnames');
            my @options;
            foreach my $scanoptionname (@scanoptionnames) {
                push @options, {
                    value_id => $scanoptionname->value_id,
                    name     => $scanoptionname->name,
                };  
            }
            $scanoption{options} = \@options;
        }
        my $scanoptionvalue = $self->search_related(
            'scanoptionvalues',
            { scanoptionkey_id => $scanoptionkey->scanoptionkey_id }
        )->single;
        $scanoption{value_id} = $scanoptionvalue->value_id if $scanoptionvalue;
        push @scanoptions, \%scanoption;
    }
    return \@scanoptions;
}

sub scanoptions_without_options { (shift)->scanoptions({options => 0}) }
  
sub save_scanoptions {
    my $self = shift;
    my $params = shift;
    
    my @scanoptionkeys = $self->scanner->scanoptionkeys;
    my $scanoptionkeys_info;
    foreach my $scanoptionkey (@scanoptionkeys) {
        $scanoptionkeys_info->{$scanoptionkey->scanoptionkey_id} = 1;     
    }
    die "scanoptionkeys should be an array, but I found a " . (ref $params)
        unless ref $params eq 'ARRAY';
    foreach my $scanoption (@$params) {
        die "no scanoptionkey_id" unless  exists $scanoption->{scanoptionkey_id};
        my $scanoptionkey_id = $scanoption->{scanoptionkey_id};
        die "scanoptionkey_id " . $scanoptionkey_id . " don't belong to this scanner"
            unless exists $scanoptionkeys_info->{$scanoptionkey_id};
        die "no value_id" unless  exists $scanoption->{value_id};
        my $rs = $self->search_related(
            'scanoptionvalues',
            { scanoptionkey_id => $scanoptionkey_id }
        );
        my $row = $rs->single;
        if ($row) { 
            $row->update({value_id => $scanoption->{value_id}});
        }
        else {
            if ($scanoption->{value_id}) {
                $rs->create({value_id => $scanoption->{value_id}});   
            }
        }
    }    
}

__PACKAGE__->meta->make_immutable;
1;
