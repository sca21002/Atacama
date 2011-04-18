package Atacama::Form::Sourcefile;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has 'order' => (
    is => 'ro',
    required => 1,
    isa => 'DBIx::Class::Row'
);

has_field 'delete_scanfiles' => (
    type => 'Checkbox', default => 1,
    label => 'zuvor Scandateien in der Datenbank löschen' 
);

has_field 'submit' => ( type => 'Submit', value => 'Starten' );

no HTML::FormHandler::Moose;
1;
