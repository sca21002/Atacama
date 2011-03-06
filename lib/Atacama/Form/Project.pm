package Atacama::Form::Project;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

has '+item_class' => ( default =>'Project' );

has_field 'name' => (
    type => 'Text',
    label => 'Projektname'
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
has_field 'submit' => ( type => 'Submit', value => 'Starten' );

no HTML::FormHandler::Moose;
1;
