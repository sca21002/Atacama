use utf8;
package Atacama::Schema::Result::Resolution;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Resolution

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

=head1 TABLE: C<resolutions>

=cut

__PACKAGE__->table("resolutions");

=head1 ACCESSORS

=head2 resolution_id

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_auto_increment: 1
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
  "resolution_id",
  {
    data_type => "tinyint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "value",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "info",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</resolution_id>

=back

=cut

__PACKAGE__->set_primary_key("resolution_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<resolution_resolutions>

=over 4

=item * L</value>

=back

=cut

__PACKAGE__->add_unique_constraint("resolution_resolutions", ["value"]);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-03-18 17:18:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DAbSCu11lQnw+kMaBZrgdw


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->has_many(
    "scanparameters",
    "Atacama::Schema::Result::Scanparameter",
    { "foreign.resolution_id" => "self.resolution_id" }
);


__PACKAGE__->meta->make_immutable;
1;
