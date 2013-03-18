use utf8;
package Atacama::Schema::Result::Scanoptionname;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Scanoptionname

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

=head1 TABLE: C<scanoptionnames>

=cut

__PACKAGE__->table("scanoptionnames");

=head1 ACCESSORS

=head2 value_id

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 scanoptionkey_id

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "value_id",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "scanoptionkey_id",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</value_id>

=item * L</scanoptionkey_id>

=back

=cut

__PACKAGE__->set_primary_key("value_id", "scanoptionkey_id");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-03-18 17:18:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:99aPN3VZQWVa7TGff/ohpA


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->has_many(
    "scanoptionvalues",
    "Atacama::Schema::Result::Scanoptionvalue",
    {
        "foreign.value_id" => "self.value_id",
        "foreign.scanoptionkey_id" => "self.scanoptionkey_id",
    }
);

__PACKAGE__->belongs_to(
    "scanoptionkey",
    "Atacama::Schema::Result::Scanoptionkey",
    { "scanoptionkey_id" => "scanoptionkey_id" }
);   

__PACKAGE__->meta->make_immutable;
1;
