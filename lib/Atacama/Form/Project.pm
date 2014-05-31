package Atacama::Form::Project;

# ABSTRACT: Form to edit a project 

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

has '+item_class' => ( default =>'Project' );

has_field 'name' => (
    type => 'Text',
    label => 'Projektname',
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
has_field 'projectkeys' => ( type => 'Repeatable' );
has_field 'projectkeys.projectkey_id' => ( type => 'PrimaryKey' );
has_field 'projectkeys.sorting';
has_field 'projectkeys.pkey';
has_field 'projectkeys.info';
has_field 'submit' => ( type => 'Submit', value => 'Speichern' );

no HTML::FormHandler::Moose;

1; # Magic true value required at end of module

__END__