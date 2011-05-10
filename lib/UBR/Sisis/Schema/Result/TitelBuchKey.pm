package UBR::Sisis::Schema::Result::TitelBuchKey;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

#__PACKAGE__->load_components(qw/EncodeColumns/);
#__PACKAGE__->decode_columns('latin-1');

__PACKAGE__->table('sisis.titel_buch_key');

__PACKAGE__->add_columns(
    'katkey',                          # Katkey        aus titel_daten
    {data_type  => 'INTEGER', default_value => undef, is_nullable => 1, },
    'mcopyno',                         # Circulation-Key aus titel_daten  = d01buch.d01mcopyno
    {data_type  => 'INTEGER', default_value => undef, is_nullable => 1, },
    'seqnr',                           # Rangfolge der Titel innerhalb einer Bindeeinheit
    {data_type  => 'INTEGER', default_value => undef, is_nullable => 1, },
);

sub get_titel_dup_daten {
    my $self = shift;
    
    my $schema = $self->result_source->schema;
    my $where = '= ' . $self->katkey;
    return $schema->resultset('TitelDupdaten')->search(
        { katkey => \$where },
        { result_class => 'DBIx::Class::ResultClass::HashRefInflator' }
    )->first;
}    

sub get_bvnr {
    my $self = shift;
    
    my $schema = $self->result_source->schema;
    my $where = '= ' . $self->katkey;
    my $titel_buch_key =
        $schema->resultset('TitelVerbund')->search({katkey => \$where})->first;
    return $titel_buch_key->verbundid if $titel_buch_key;    
}

1;
