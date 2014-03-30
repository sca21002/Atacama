use utf8;
package Atacama::Schema::Result::Project;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Project

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

=head1 TABLE: C<projects>

=cut

__PACKAGE__->table("projects");

=head1 ACCESSORS

=head2 project_id

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 projectgroup_id

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 active

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "project_id",
  {
    data_type => "smallint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "projectgroup_id",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "active",
  { data_type => "tinyint", default_value => 1, is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</project_id>

=back

=cut

__PACKAGE__->set_primary_key("project_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<project_projects>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("project_projects", ["name"]);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2014-05-29 15:19:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Tzd7IakA6YsAZRRIO6/TWw


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->has_many(
    "orders_projects",
    "Atacama::Schema::Result::OrderProject",
    { "foreign.project_id" => "self.project_id" }
);

__PACKAGE__->has_many(
    "projectkeys",
    "Atacama::Schema::Result::Projectkey",
    { "foreign.project_id" => "self.project_id" }
);

__PACKAGE__->many_to_many(
    "orders",
    "orders_projects",
    "ord"
);



__PACKAGE__->meta->make_immutable;
1;
