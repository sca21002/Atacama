use utf8;
package Atacama::Schema::Result::Projectvalue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Projectvalue

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

=head1 TABLE: C<projectvalues>

=cut

__PACKAGE__->table("projectvalues");

=head1 ACCESSORS

=head2 projectkey_id

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 ordersprojects_id

  data_type: 'mediumint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 value

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 info

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "projectkey_id",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "ordersprojects_id",
  {
    data_type => "mediumint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "value",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "info",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</projectkey_id>

=item * L</ordersprojects_id>

=back

=cut

__PACKAGE__->set_primary_key("projectkey_id", "ordersprojects_id");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-03-18 22:10:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Vo32ShLjWxXw7fXgPpTKmQ


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
    "projectkey",
    "Atacama::Schema::Result::Projectkey",
    { "projectkey_id" => "projectkey_id"}
);

__PACKAGE__->belongs_to(
    "ordersproject",
    "Atacama::Schema::Result::OrderProject",
    { "ordersprojects_id" => "ordersprojects_id"}
);


__PACKAGE__->meta->make_immutable;
1;
