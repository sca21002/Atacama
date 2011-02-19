package Atacama::Schema::Result::Project;

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

Atacama::Schema::Result::Project

=cut

__PACKAGE__->table("projects");

=head1 ACCESSORS

=head2 project_id

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

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
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "description",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("project_id");
__PACKAGE__->add_unique_constraint("project_projects", ["name"]);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-12-26 23:49:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:K1xFN8aKkVaDptr2fDArxQ


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
