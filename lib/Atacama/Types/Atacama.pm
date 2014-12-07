use utf8;
package Atacama::Types::Atacama;

# ABSTRACT: Types library for Atacama specific types

use strict;
use warnings;
use Image::ExifTool qw(ImageInfo);
use List::Util qw(first);
use List::MoreUtils qw(all);
use Data::Dumper;
use Path::Tiny ();
use MooseX::Types -declare => [ qw(
    ArrayRef_of_Dir
    PDFFile
    Order_id
    TheSchwartz_Job
) ];

use MooseX::Types::Moose qw(
    ArrayRef
    Str
);

class_type TheSchwartz_Job, { class => 'Atacama::Helper::TheSchwartz::Job' };

subtype Order_id,
  as Str,
  where { / \A [a-z] [_a-z0-9]* \z /x },
  message { "'$_' is not a valid order_id" }
;

subtype ArrayRef_of_Dir, 
    as ArrayRef['Path::Tiny'], 
    where {  
        all { $_->is_dir } @$_ 
    }, 
    message { 
        sprintf( "Directory '%s' does not exist", first { !$_->is_dir } @$_ )  
    }
;

coerce ArrayRef_of_Dir,
    from ArrayRef[Str],
    via { [ map { Path::Tiny::path($_) } @$_ ] };


subtype PDFFile, as 'Path::Tiny',
    where { 
       $_->is_file
       && ImageInfo($_->stringify, 'FileType')->{FileType} eq 'PDF'
       && ImageInfo($_->stringify, 'PDFVersion')->{PDFVersion} <= 1.4
    }, 
    message {
        my ($type, $version); 
        !$_ 
        ? "PDF file is missing"
        : !$_->is_file 
        ? "PDF file '$_' does not exist"
        : ($type = ImageInfo($_->stringify, 'FileType')->{FileType}) ne 'PDF'
        ? "$_ should be a PDF but is a '$type'"
        : !(($version = ImageInfo($_->stringify, 'PDFVersion')->{PDFVersion}) <= 1.4)
        ? "PDF-Version of '$_' isn't <= Version 1.4"
        : "'$_' causes an unknown error"
    };

coerce PDFFile,
    from Str,
    via {
        return unless $_;
        Path::Tiny::path($_);        
    },
;

1; # Magic true value required at end of module
