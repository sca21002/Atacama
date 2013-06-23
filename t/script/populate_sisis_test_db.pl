#!/usr/bin/env perl
use utf8;
use Modern::Perl;
use Path::Class;
use FindBin qw($Bin);
use lib dir($Bin)->parent->subdir('lib')->stringify,
        dir($Bin)->parent->parent->subdir('lib')->stringify;

use Atacama::Helper;
use SisisTestSchema;
use Data::Dumper;

my $schema_source =  Atacama::Helper::get_schema(
    dir($Bin)->parent->parent, 'Model::SisisDB', 'UBR::Sisis::Schema');

my $schema_target = SisisTestSchema->init_schema(populate => 1);

my @shelfmarks = ( '999/Art.533', '237/TA 6225-2/7' ); 

foreach my $shelfmark (@shelfmarks) {

    my $book_source =  $schema_source->resultset('D01buch')->search(
         { d01ort => $shelfmark },
    )->first;

    my $book_target = $schema_target->resultset('D01buch')->create(
        {$book_source->get_columns}
    );

    foreach my $key_source ( $book_source->titel_buch_keys ) {
    
        my $book_row = $book_target->create_related(
            'titel_buch_keys', {$key_source->get_columns}
        );

        foreach my $rel ( qw( titel_verbund titel_dupdaten ) ) { 
            my $row_related = $key_source->$rel;
            $book_row->create_related( $rel, {$row_related->get_columns} )
                if $row_related;
        }

    }
}
