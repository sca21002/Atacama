package Atacama::Form::Status;

# ABSTRACT: Form to edit Status fields

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

has '+item_class' => ( default =>'Status' );

has_field 'name' => (
    type => 'Text',
    label => 'Status',
    required => 1,
);

has_field 'active' => (
    type => 'Boolean',
    label => 'Aktiv',
);

has_field 'description' => (
    type => 'TextArea',
    label => 'Beschreibung',
    cols => 60,
    rows => 3,
);

has_field 'submit' => ( type => 'Submit', value => 'Speichern' );

no HTML::FormHandler::Moose;

1; # Magic true value required at end of module

__END__