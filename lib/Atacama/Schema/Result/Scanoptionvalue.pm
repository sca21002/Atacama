use utf8;
package Atacama::Schema::Result::Scanoptionvalue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Scanoptionvalue

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

=head1 TABLE: C<scanoptionvalues>

=cut

__PACKAGE__->table("scanoptionvalues");

=head1 ACCESSORS

=head2 scanoptionkey_id

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 scanparameter_id

  data_type: 'mediumint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 value_id

  data_type: 'tinyint'
  is_nullable: 1

=head2 info

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "scanoptionkey_id",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
  "scanparameter_id",
  { data_type => "mediumint", extra => { unsigned => 1 }, is_nullable => 0 },
  "value_id",
  { data_type => "tinyint", is_nullable => 1 },
  "info",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</scanoptionkey_id>

=item * L</scanparameter_id>

=back

=cut

__PACKAGE__->set_primary_key("scanoptionkey_id", "scanparameter_id");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-03-18 17:18:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:464/s7bf0cBGJntNN5ie8Q


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
    "scanoptionkey",
    "Atacama::Schema::Result::Scanoptionkey",
    { "scanoptionkey_id" => "scanoptionkey_id"}
);

__PACKAGE__->belongs_to(
    "scanparameter",
    "Atacama::Schema::Result::Scanparameter",
    { "scanparameter_id" => "scanparameter_id"}
);

__PACKAGE__->belongs_to(
    "scanoptionname",
    "Atacama::Schema::Result::Scanoptionname",
    {
        "value_id" => "value_id",
        "scanoptionkey_id" => "scanoptionkey_id"
    }
);

__PACKAGE__->meta->make_immutable;
1;
