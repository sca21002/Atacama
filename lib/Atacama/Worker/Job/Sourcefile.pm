use utf8;
package Atacama::Worker::Job::Sourcefile;

# ABSTRACT: Job for searching and collecting digitisation files

use Moose;
    extends 'Atacama::Worker::Job::Base';
use Atacama::Types qw(
    ArrayRef ArrayRef_of_Dir Bool Dir File HashRef RegexpRef Str
);
use List::Util qw(first);
use Carp;
use MooseX::AttributeShortcuts;
use Path::Tiny;
use Path::Iterator::Rule;
use Remedi::Imagefile;
use Remedi::RemediFile;
use Remedi::PDF::API2;
use Data::Dumper;
use MooseX::ClassAttribute;

has 'ext_reg' => (
    is => 'ro',
    isa => HashRef[RegexpRef],
    default => sub { +{ 
        TIFF => qr/(?i:\.tiff?$)/,
        JPEG => qr/(?i:\.jpg$)/,
        PDF  => qr/(?i:\.pdf$)/,
        XML  => qr/(?i:\.xml$)/,
    } },
);

has 'pdf_re'         => ( is => 'lazy', isa => RegexpRef );

has 'single_page_re' => ( is => 'lazy', isa => RegexpRef );

has 'rule'           => ( is => 'lazy', isa => 'Path::Iterator::Rule' );

has 'skip_dirs' => (
    is => 'ro',
    isa => ArrayRef[RegexpRef],
    default => sub { [qr/thumbnails/] },
);

class_has '+log_basename' => (
    default => 'sourcefile.log',                        
);

has '+log_config_basename' => (
    is => 'ro',
    isa => Str,
    default => 'log4perl_sourcefile.conf',
);

has 'scanfile_formats' => (
    is => 'ro',
    isa => ArrayRef[Str],
    default => sub { ['TIFF'] },
);    

has 'sourceformats' => ( is => 'lazy', isa => ArrayRef[Str] );

has  'sourcedirs' => (
    is => 'rw',
    isa => 'ArrayRef[Str]',
    default => sub { [                  
        '/rzblx8_DATA1/digitalisierung/auftraege/',
        '/rzblx8_DATA2/digitalisierung/auftraege/',
        '/rzblx8_DATA2/digitalisierung/auftraege/rdiss/',
        '/rzblx8_DATA2/digitalisierung/auftraege/rdiss_2/',
        '/rzblx8_DATA3/digitalisierung/auftraege/',
        '/mnt/rzblx9/data/digitalisierung/auftraege/',
        '/mnt/rzblx10b/data/digitalisierung/auftraege/',
    ] },
);

has  'sourcedirs' => (
    is => 'ro',
    isa => ArrayRef_of_Dir,
    builder => '_build_sourcedirs',
    lazy => 1,
    coerce => 1,
);


has 'sourcedir' => ( is => 'lazy', isa => Dir, coerce => 1 );

has 'sourcedir'  => ( is => 'lazy', isa => Dir, coerce => 1 );

sub _build_rule {
    my $self = shift;

    my $rule = Path::Iterator::Rule->new;
    $rule = $rule->skip_dirs( @{ $self->skip_dirs } );

    my @rules;
    foreach my $format ( @{ $self->sourceformats } ) {
        my $rule_part = Path::Iterator::Rule->new;
        $self->log->logdie("No regular expression defined for format '$format'")
            unless exists $self->ext_reg->{$format}; 
        if ($format eq 'PDF') {
            $rule_part->name($self->pdf_re);
            # exclude single-page PDFs
            my $rule_not = Path::Iterator::Rule->new;
            $rule_not->name($self->single_page_re);
            $rule_part->not($rule_not);
        } else {
            $rule_part->name($self->single_page_re);
        }
        $rule_part->name($self->ext_reg->{$format}); 
        push @rules, $rule_part;
    }
    return $rule->or(@rules);
}


sub _build_log {
    my $self = shift;
   
    Log::Log4perl->init($self->log_config_file->stringify);
    return Log::Log4perl->get_logger('Atacama::Worker::Job::Sourcefile');
}


sub _build_pdf_re {
    my $self = shift;

    my $order_id = $self->order_id;
    my $pdf_re = $self->atacama_config->{'Atacama::Worker::Sourcefile'}{pdf_re};
    $pdf_re =~ s/%order_id%/${order_id}/;
    return qr/${pdf_re}/;
}


sub _build_single_page_re {
   my $self = shift;

    my $order_id = $self->order_id;
    my $single_page_re 
       = $self->atacama_config->{'Atacama::Worker::Sourcefile'}{single_page_re};
    $single_page_re  =~ s/%order_id%/${order_id}/;
    return qr/${single_page_re}/;  
}


sub _build_sourcedir {
    my $self = shift;
    
    my $sourcedir = 
        first { $_->is_dir }
        map   { path( $_, $self->order_id ) } 
        @{$self->sourcedirs}
    ;
    $self->log->logcroak( 
        sprintf( 
            "Kein Unterverzeichnis %s in %s", 
            $self->order_id, join(' ', @{$self->sourcedirs})
        )
    ) unless $sourcedir;
    return $sourcedir;
}


sub _build_sourcedirs {
    (shift)->atacama_config->{'Atacama::Worker::Sourcefile'}{sourcedirs};
}

sub _build_sourceformats {
    my $self = shift;

    return [ @{$self->scanfile_formats}, 'PDF', 'XML' ];
}

sub save_scanfile {
    my $self = shift;
    my $scanfile = shift;
    my $clause;
    
    my $log = $self->log;
    $log->info('Scanfile: ' . $scanfile);
    my $atacama_schema = $self->atacama_schema;
    eval {
        my $image = Remedi::Imagefile->new(
            library_union_id => 'bvb',
            library_id => '355',
            regex_filestem_prefix => $self->order_id,
            regex_filestem_var => qr/_\d{1,5}/,		# TODO: should we make it more general 
            size_class_border  => 150 * 72 / 25.4, 
	    file => $scanfile,    
        );                       
        $clause->{filename}     = $image->basename;
        $clause->{filepath}     = $image->parent->stringify;
        $clause->{order_id}     = $image->order_id;
        $clause->{format}       = $image->format;
        $clause->{colortype}    = $image->colortype;
        $clause->{resolution}   = $image->resolution;
        $clause->{height_px}    = $image->height_px;
        $clause->{width_px}     = $image->width_px;
        $clause->{filesize}     = $image->size;
        $clause->{icc_profile}  = $image->icc_profile
            if $image->colortype eq 'color';
        $clause->{md5}          = $image->md5_checksum;
        $log->trace("Imagefile: " . Dumper($clause));
    };
    unless ($@) {
        $atacama_schema->resultset('Scanfile')->update_or_create($clause);
    } else {
        $log->warn("Konnte $scanfile nicht verarbeiten: $@");
        $atacama_schema->resultset('Scanfile')->update_or_create({
            filename => $scanfile->basename,
            filepath => $scanfile->parent->stringify,
            error    => $@,
        });
    }
}

sub save_pdffile{
    my $self = shift;
    my $pdffile = shift;
    my $clause;
    
    my $log = $self->log;
    $log->info("PDF-Datei: $pdffile");
    my $atacama_schema = $self->atacama_schema;
    eval {
        my $pdf = Remedi::PDF::API2->open(
            file => $pdffile,
        );
        $clause->{order_id} = $self->order_id;
        $clause->{filename} = $pdffile->basename;
        $clause->{filepath} = $pdffile->parent->stringify;
        $clause->{pages}    = $pdf->pages;
        $clause->{filesize} = $pdf->size;
        $clause->{pagelabels} = $pdf->pagelabels ? 1 : 0;
        $pdf->release();
        $log->trace("PDF-Datei: " . Dumper($clause));    
    };
    unless ($@) {
        $atacama_schema->resultset('Pdffile')->update_or_create($clause);
    } else {
        $log->warn("Konnte $pdffile nicht verarbeiten: $@");
        $atacama_schema->resultset('Pdffile')->update_or_create({
            filename => $pdffile->basename,
            filepath => $pdffile->parent->stringify,
            error    => $@,
        });
    }
}

sub save_ocrfile {
    my $self = shift;
    my $ocrfile = shift;
    my $clause;
    
    my $log = $self->log;
    $log->info("OCR-Datei: " . $ocrfile);
    my $atacama_schema = $self->atacama_schema;
    eval {
        $ocrfile = Remedi::RemediFile->new(
	    file => $ocrfile,
            regex_filestem_prefix => $self->order_id,
            regex_filestem_var    => qr/_\d{1,5}/, 
        );
        $clause->{order_id} = $self->order_id;
        $clause->{filename} = $ocrfile->basename;
        $clause->{filepath} = $ocrfile->parent->stringify;;
        $clause->{filesize} = -s $ocrfile;
        $clause->{format} = 'XML';
        $clause->{md5} = $ocrfile->md5_checksum;
        $log->trace("OCR-file: " . Dumper($clause));
    };
    unless ($@) {
        $atacama_schema->resultset('Ocrfile')->update_or_create($clause);
    } else {
        $log->warn("Konnte $ocrfile nicht verarbeiten: $@");
        $atacama_schema->resultset('Ocrfile')->update_or_create({
            filename => $ocrfile->basename,
            filepath => $ocrfile->parent->stringify,
            error    => $@,
        });
    }    
}


sub run {
    my $self = shift;

    my $log = $self->log;
    $log->info('Programm gestartet');

    $log->info('Gesuchte Formate: ' . join(' ', @{$self->sourceformats} ) ); 

    $log->trace(Dumper($self->pdf_re));
    $log->trace(Dumper($self->single_page_re));

    my $next = $self->rule->iter( 
        $self->sourcedir, 
        { 
            depthfirst => -1 # pre-order, depth-first search 
        }    
    );
    while ( my $file = $next->() ) {
        $file = path($file);
        if ($file =~ $self->ext_reg->{TIFF}) {
            $self->save_scanfile($file);        
        } elsif ( $file =~ $self->ext_reg->{JPEG} ) {
            $self->save_scanfile($file);   
        } elsif ( $file =~ $self->ext_reg->{XML} ) {
            $self->save_ocrfile($file);   
        } elsif ( $file =~ $self->ext_reg->{PDF} ) {
            $self->save_pdffile($file);   
        } else {
            $log->logdie("Kann $file nicht verarbeiten")
        } 
    }
}

1; # Magic true value required at end of module
