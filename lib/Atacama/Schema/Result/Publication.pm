use utf8;
package Atacama::Schema::Result::Publication;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Publication

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<publications>

=cut

__PACKAGE__->table("publications");

=head1 ACCESSORS

=head2 publication_id

  data_type: 'mediumint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 order_id

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 platform_id

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 info

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "publication_id",
  {
    data_type => "mediumint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "order_id",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "platform_id",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "info",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</publication_id>

=back

=cut

__PACKAGE__->set_primary_key("publication_id");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-03-18 17:18:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:70PK3KYhLIM6mr61nfiGOQ


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
    "ord",
    "Atacama::Schema::Result::Order",
    { "foreign.order_id" => "self.order_id" }
);

__PACKAGE__->belongs_to(
    "platform",
    "Atacama::Schema::Result::Platform",
    { "platform_id" => "platform_id" }
);

__PACKAGE__->has_many(
    "platformoptionvalues",
    "Atacama::Schema::Result::Platformoptionvalue",
    { "foreign.publication_id" => "self.publication_id" }
);

use Data::Dumper;

sub publicationoptions {
    my $self = shift;
    
    return unless $self->platform;
    my @publicationoptions;
    my @platformoptionkeys = $self->platform->platformoptionkeys;
    foreach my $platformoptionkey (@platformoptionkeys) {
        my %publicationoption;
        $publicationoption{platformoptionkey_id} = $platformoptionkey->platformoptionkey_id;
        $publicationoption{pkey} = $platformoptionkey->pkey;
        my $platformoptionvalue = $self->search_related(
            'platformoptionvalues',
            { platformoptionkey_id => $platformoptionkey->platformoptionkey_id }
        )->single;
        $publicationoption{value} = $platformoptionvalue->value if $platformoptionvalue;
        push  @publicationoptions, \%publicationoption;       
    }
    return \@publicationoptions;
}

sub save_publicationoptions {
    my $self = shift;
    my $params = shift;
    

    my @platformoptionkeys = $self->platform->platformoptionkeys;
    my $platformoptionkeys_info;
    foreach my $platformoptionkey (@platformoptionkeys) {
        $platformoptionkeys_info->{$platformoptionkey->platformoptionkey_id} = 1;     
    }
   die "platformoptions should be an array, but I found a " . (ref $params)
        unless ref $params eq 'ARRAY';
    foreach my $platformoption (@$params) {
        die "no platformoptionkey_id" unless  exists $platformoption->{platformoptionkey_id};
        my $platformoptionkey_id = $platformoption->{platformoptionkey_id};
        die "platformoptionkey_id " . $platformoptionkey_id . " don't belong to this project"
            unless exists $platformoptionkeys_info->{$platformoptionkey_id};
        die "no value" unless  exists $platformoption->{value};
        my $rs = $self->search_related(
            'platformoptionvalues',
            { platformoptionkey_id => $platformoptionkey_id }
        );
        my $row = $rs->single;
        if ($row) { 
            $row->update({value => $platformoption->{value}});
        }
        else {
            if ($platformoption->{value}) {
                $rs->create({value => $platformoption->{value}});   
            }
        }
    }    
}

__PACKAGE__->meta->make_immutable;
1;
