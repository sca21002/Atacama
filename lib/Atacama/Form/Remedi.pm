package Atacama::Form::Remedi;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
use List::Util qw(first);

has 'remedi_configdir' => (
    is => 'ro',
    required => 1,
    isa => 'Str',
);

has 'remedi_configfiles' => (
    traits  => ['Array'],                         
    is => 'ro',
    lazy_build => 1,
    isa => 'ArrayRef[Path::Class::File]',
    handles => {
        all_remedi_configfiles => 'elements',         
    },
);
has 'source_pdf_files' => (
    traits  => ['Array'],
    is => 'ro',
    lazy_build => 1,
    isa => 'ArrayRef[Path::Class::File]',
    handles => {
        all_source_pdf_files   => 'elements',
        count_source_pdf_files => 'count',        
    },            
);
has 'order' => (
    is => 'ro',
    required => 1,
    isa => 'DBIx::Class::Row'
);

has_field 'remedi_configfile' => (
    type => 'Select', label => 'Config-Datei',
    empty_select => '-- Select --',
);
has_field 'source_pdf_file' => (
    type => 'Select', label => 'PDF-Datei',
    empty_select => '-- Select --',
);
has_field 'source_format' => (
    type => 'Select', label => 'Format der Quelldateien',
    empty_select => '-- Select --',
    options => [
        {value => 'PDF',  label => 'PDF' },
        {value => 'TIFF', label => 'TIFF'},
    ],
);
has_field 'does_copy_files' => (
    type => 'Checkbox', default => 1, label => 'Dateien kopieren' 
);
has_field 'does_digifooter' => (
    type => 'Checkbox', default => 1, label => 'Digifooter'
);
has_field 'does_mets' => (
    type => 'Checkbox', default => 1, label => 'METS'
);
has_field 'does_csv' => (
    type => 'Checkbox', default => 1, label => 'CSV'
);
has_field 'submit' => ( type => 'Submit', value => 'Starten' );

sub _build_source_pdf_files {
    my $self = shift;
    
    my @pdffiles = $self->order->pdffiles;
    my @pdf_values
        = map { Path::Class::File->new($_->filepath, $_->filename) } @pdffiles;
    return \@pdf_values;
}

sub _build_remedi_configfiles {
    my $self = shift;
    
    my $dir = Path::Class::Dir->new($self->remedi_configdir);
    my @files = grep { $_->basename =~ /^remedi_de-.*\.conf$/ } $dir->children;
    return \@files; 
}

sub options_remedi_configfile {
    my $self = shift;
    
    my @list = $self->all_remedi_configfiles;
    my @values = map { {value => $_, label => $_ }  } @list;
    return \@values;
}

sub default_remedi_configfile {
    my $self = shift;
      
    my $library = $self->order->titel->library->name;
    my @projects = $self->order->projects->all;
    my @list = $self->all_remedi_configfiles;
    my $default = ( $library eq 'Staatliche Bibliothek Regensburg' )
        ? first { $_->basename eq  'remedi_de-155-355.conf' } @list
        : ( $library eq 'Südost-Institut' )
        ? first { $_->basename eq 'remedi_de-M135-355.conf' } @list
        : ( $library eq 'Osteuropa-Institut' )
        ? first { $_->basename eq 'remedi_de-M357-355.conf' } @list
        : ( $library eq 'Handwerkskammer Niederbayern-Oberpfalz' )
        ? first { $_->basename eq 'remedi_de-355_hwkno.conf' } @list 
        : ( $library eq 'Johannes-Turmair-Gymnasium' ) 
        ? first { $_->basename eq 'remedi_de-Str1-355.conf' } @list    
        : ( $library eq 'Siebenbürgische Bibliothek' )
        ? first { $_->basename eq 'remedi_de-Gun1-355.conf' } @list
        : ( $library eq 'Johannes-Künzig-Institut für Ostdeutsche Volkskunde' )
        ? first { $_->basename eq 'remedi_de-Frei131-355.conf' } @list
        : ( $library eq 'Deutsche Nationalbibliothek' )
        ? first { $_->basename eq 'remedi_de-101-355.conf' } @list
        : ( $library eq 'Bundesinstitut für die Kultur und Geschichte der Deutschen im östlichen Europa' )
        ? first { $_->basename eq 'remedi_de-715-355.conf' } @list
        : first { $_->basename eq 'remedi_de-355.conf' } @list
        ;
    return $default; 
}

sub options_source_pdf_file {
    my $self = shift;
    
    my @list = $self->all_source_pdf_files;
    my @values = map { {value => $_, label => $_ }  } @list;
    return \@values;
}

sub default_source_pdf_file {
    my $self = shift;
    
    return $self->source_pdf_files->[0]->stringify
        if $self->count_source_pdf_files == 1;
    return;
}

sub default_source_format {
    my $self = shift;
    
    return 'PDF' if $self->count_source_pdf_files > 0;
    return;
}

no HTML::FormHandler::Moose;
1;
