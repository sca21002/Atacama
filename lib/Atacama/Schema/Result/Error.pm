package Atacama::Schema::Result::Error;

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

Atacama::Schema::Result::Error

=cut

__PACKAGE__->table("error");

=head1 ACCESSORS

=head2 error_time

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 jobid

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 message

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 funcid

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "error_time",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0,
    inflate_datetime => 1,
  },
  "jobid",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
  "message",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "funcid",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-03-26 01:12:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IyCU9fdrM56KE5G/KFODbg


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
    "function",
    "Atacama::Schema::Result::Funcmap",
    { "foreign.funcid" => "self.funcid" },
    { join_type => 'left' }
);

__PACKAGE__->meta->make_immutable;
1;
