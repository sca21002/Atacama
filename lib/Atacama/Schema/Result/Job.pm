package Atacama::Schema::Result::Job;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components( qw( DateTime::Epoch TimeStamp) );

=head1 NAME

Atacama::Schema::Result::Job

=cut

__PACKAGE__->table("job");

=head1 ACCESSORS

=head2 jobid

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 funcid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 arg

  data_type: 'mediumblob'
  is_nullable: 1

=head2 uniqkey

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 insert_time

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 run_after

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 grabbed_until

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 priority

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 coalesce

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "jobid",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "funcid",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "arg",
  { data_type => "mediumblob", is_nullable => 1 },
  "uniqkey",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "insert_time",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1,
    inflate_datetime => 1,
  },
  "run_after",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0,
    inflate_datetime => 1,
  },
  "grabbed_until",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0,
    inflate_datetime => 1,
  },
  "priority",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "coalesce",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("jobid");
__PACKAGE__->add_unique_constraint("funcid_2", ["funcid", "uniqkey"]);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-03-26 01:12:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:138u/fEKECt8f5PL+vEXsQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
    "function",
    "Atacama::Schema::Result::Funcmap",
    { "foreign.funcid" => "self.funcid" },
    { join_type => 'left' }
);

__PACKAGE__->meta->make_immutable;
1;
