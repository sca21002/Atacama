package UBR::Sisis::Schema::Result::TitelVerbund;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

#__PACKAGE__->load_components(qw/EncodeColumns/);
#__PACKAGE__->decode_columns('latin-1');

__PACKAGE__->table('sisis.titel_verbund');

__PACKAGE__->add_columns(
    'katkey',                          # Katkey        aus titel_daten
    {data_type  => 'INTEGER', default_value => undef, is_nullable => 1, },
    'verbundid',                       # Verbund ID
    {data_type  => 'VARCHAR', default_value => undef, is_nullable => 1, size => 25,  },
);

sub get_titel {
    my $self = shift;
    
    my %titel = $self->get_columns;
    
    my $schema = $self->result_source->schema;
    my $where = '= ' . $self->katkey;
    my $titel_buch_key = $schema->resultset('TitelBuchKey')->search(
        { katkey => \$where },
    )->first;
    my $titel_href = $titel_buch_key->get_titel_dup_daten();
    $where = '= ' . $titel_buch_key->mcopyno;
    my $buch = $schema->resultset('D01buch')->search(
        { d01mcopyno => \$where },
        { result_class => 'DBIx::Class::ResultClass::HashRefInflator' }
    )->first;
    return { %titel, %$titel_href, %$buch };
}

1;
