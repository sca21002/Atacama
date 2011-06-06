package Atacama::Form::Titel;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

has '+item_class' => ( default =>'Titel' );

has_field 'autor_avs' => (
    type => 'Text',
    label => 'Verfasser',
    size =>  80,
);
has_field 'titel_avs' => (
    type => 'TextArea',
    label => 'Titel',
    cols => 60,
    rows => 3,
);
has_field 'zusatz' => (
    type => 'Text',
    label => 'Zusatz',
    size =>  80,
);
has_field 'verlagsort' => (
    type => 'Text',
    label => 'Verlagsort',
    size =>  80,
);
has_field 'verlag' => (
    type => 'Text',
    label => 'Verlag',
    size =>  80,
);
has_field 'erschjahr' => (
    type => 'Text',
    label => 'Jahr',
    size =>  40,
);
has_field 'bandangabe' => (
    type => 'Text',
    label => 'Band',
    size =>  80,
);
has_field 'autor_uw' => (
    type => 'Text',
    label => 'Verfasser(Artikel)',
    size =>  80,
);
has_field 'titel_uw' => (
    type => 'Text',
    label => 'Titel(Artikel)',
    size =>  80,
);
has_field 'submit' => ( type => 'Submit', value => 'Speichern' );

no HTML::FormHandler::Moose;
1;
