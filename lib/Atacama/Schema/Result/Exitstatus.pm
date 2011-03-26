package Atacama::Schema::Result::Exitstatus;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';


=head1 NAME

Atacama::Schema::Result::Exitstatus

=cut

__PACKAGE__->table("exitstatus");

=head1 ACCESSORS

=head2 jobid

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 funcid

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 status

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 completion_time

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 delete_after

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "jobid",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
  "funcid",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "status",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "completion_time",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "delete_after",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("jobid");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-03-26 01:12:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rQn/lbRtuxOejkok4bDsTg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
