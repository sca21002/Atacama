use utf8;
package Atacama::Form::Remedi;

# ABSTRACT: Form to edit parameters for a job preparing files for the ingest

use Atacama::Types qw(ArrayRef Bool Dir Path File);
use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
use List::Util qw(first);
use Log::Log4perl qw(:levels);
use Path::Tiny;
use MooseX::AttributeShortcuts;

has 'remedi_configdir' => (
    is => 'ro',
    required => 1,
    isa => Dir,
    coerce => 1,
);

has 'remedi_configfiles' => (
    traits  => ['Array'],                         
    is => 'lazy',
    isa => ArrayRef[File],
    handles => {
        all_remedi_configfiles => 'elements',         
    },
);
has 'source_pdf_files' => (
    traits  => ['Array'],
    is => 'lazy',
    isa => ArrayRef[File],
    handles => {
        all_source_pdf_files   => 'elements',
        count_source_pdf_files => 'count',        
    },            
);

has 'is_thesis_workflow' => (
    is => 'lazy',
    isa => Bool,
);

has 'order' => (
    is => 'ro',
    required => 1,
    isa => 'DBIx::Class::Row'
);

has_field 'log_level' => (
    type => 'Select',
    label => 'Log level',
    options => [ 
        map { +{ value => $_, label => Log::Log4perl::Level::to_level($_) } }  
            ($OFF, $FATAL, $ERROR, $WARN, $INFO, $DEBUG, $TRACE, $ALL)
    ],
    default => $INFO,
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

has_field 'jpeg2000_list' => (
    type => 'Text',
    label => 'Liste der Dateien für JPEG2000',
    size => 15,
);

has_field 'does_copy_files' => (
    type => 'Checkbox', default => 1, label => 'Dateien kopieren' 
);

has_field 'does_digifooter' => (
    type => 'Checkbox', label => 'Digifooter'
);

has_field 'does_mets' => (
    type => 'Checkbox', default => 1, label => 'METS'
);

has_field 'does_csv' => (
    type => 'Checkbox', default => 1, label => 'CSV'
);

has_field 'does_thesis_workflow' => (
    type => 'Checkbox', default => 1, label => 'Diss'
);

has_field 'submit' => ( type => 'Submit', value => 'Starten' );

sub _build_is_thesis_workflow {
    my $self = shift;
    
    my @projects = $self->order->projects->all;
    return ( 
        first { 
            $_->id == 3 or  $_->id == 26 or $_->id == 30 or $_->id == 40 
        } @projects ) ? 1 : 0;
}

sub _build_source_pdf_files {
    my $self = shift;
    
    my @pdffiles = $self->order->pdffiles;
    my @pdf_values
        = map { path($_->filepath, $_->filename) } @pdffiles;
    return \@pdf_values;
}

sub _build_remedi_configfiles {
    my $self = shift;
    
    my $dir = path($self->remedi_configdir);
    my @files = grep { $_->basename =~ /^remedi_de-.*\.conf$/ } $dir->children;
    return \@files; 
}

sub options_remedi_configfile {
    my $self = shift;
    
    my @list = $self->all_remedi_configfiles;
    my @values = map { {value => $_, label => $_ }  } @list;
    return \@values;
}

sub default_does_digifooter { !(shift)->is_thesis_workflow }

sub default_does_thesis_workflow { (shift)->is_thesis_workflow }

sub default_remedi_configfile {
    my $self = shift;
      
    my $library = $self->order->titel->library->name;
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
        : ( $library eq 'Caritas-Bibliothek' )
        ? first { $_->basename eq 'remedi_de-Frei26-355.conf' } @list
        : $self->is_thesis_workflow
        ? first { $_->basename eq 'remedi_de-355_diss.conf' } @list
        : first { $_->basename eq 'remedi_de-355.conf' } @list
        ;

    $default =  first { $_->basename eq  'remedi_de-355_diss.conf' } @list
	if $self->is_thesis_workflow;

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

1; # Magic true value required at end of module

__END__
