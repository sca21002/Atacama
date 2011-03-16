package UBR::Sisis::Schema::Result::TitelVerbund;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->table('sisis.titel_verbund');

__PACKAGE__->add_columns(
    'katkey',                          # Katkey        aus titel_daten
    {data_type  => 'INTEGER', default_value => undef, is_nullable => 1, },
    'verbundid',                       # Verbund ID
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 25,  },
);

1;
