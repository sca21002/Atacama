package Atacama::Form::Remedi;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has_field 'copy_files' => (
    type => 'Checkbox', default => 1, label => 'Dateien kopieren' 
);
has_field 'digifooter' => (
    type => 'Checkbox', default => 1, label => 'Digifooter'
);
has_field 'mets' => (
    type => 'Checkbox', default => 1, label => 'METS'
);
has_field 'csv' => (
    type => 'Checkbox', default => 1, label => 'CSV'
);
has_field 'submit' => ( type => 'Submit', value => 'Starten' );

no HTML::FormHandler::Moose;
1;
