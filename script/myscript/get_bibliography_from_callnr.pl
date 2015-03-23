#!/usr/bin/env perl
use utf8;
use Path::Tiny;
use FindBin qw($Bin);
use lib path($Bin)->parent(2)->child('lib')->stringify; 
use Text::CSV_XS;
use Log::Log4perl qw(:easy);
use Modern::Perl;
use Atacama::Helper;
use Data::Dumper;
use UBR::Sisis::Schema;
use Encode;
use Getopt::Long;
use English qw( -no_match_vars );   # Avoids regex performance penalty
use Pod::Usage;

binmode(STDOUT, ":utf8");

my @keys = qw(signatur bvnr katkey titel_avs bandangabe erschjahr);

my $logfile = path($Bin)->parent(2)->child('get_bibliography_from_callnr.log');

### Logdatei initialisieren
Log::Log4perl->easy_init(
    { level   => $DEBUG,
      file    => ">" . $logfile,
    },
    { level   => $TRACE,
      file    => 'STDOUT',
    },
);

### get options

my ($csv_file_in, $csv_file_out, $opt_help, $opt_man);

GetOptions (
    "csv_in=s"  => \$csv_file_in,
    "csv_out=s" => \$csv_file_out,
    'help!'    => \$opt_help,
    'man!'     => \$opt_man,
) or pod2usage( "Try '$PROGRAM_NAME --help' for more information." );

pod2usage( -verbose => 1 ) if $opt_help;
pod2usage( -verbose => 2 ) if $opt_man;

pod2usage( -verbose => 1 ) unless $csv_file_in && $csv_file_out;

$csv_file_in   = path($csv_file_in);
$csv_file_out  = path($csv_file_out);

INFO('CSV file input:  ' . $csv_file_in);
INFO('CSV file output: ' . $csv_file_out);


LOGCROAK("CSV file '$csv_file_in' doesn't exist")
    unless $csv_file_in->is_file;
LOGCROAK("CSV file '$csv_file_out' does already exist")
    if $csv_file_out->is_file;

my $schema_atacama = Atacama::Helper::get_schema( path($Bin)->parent(2) );

my $config_dir = path($Bin)->parent(2)->stringify;
my $config_hash = Config::ZOMG->open(
    name => 'Atacama',
    path => $config_dir,
) or LOGCROAK "No config directory '$config_dir' found";

my @connect = @{$config_hash->{'Model::SisisDB'}{connect_info}};  
say Dumper(@connect);
my $storage_type = $config_hash->{'Model::SisisDB'}{storage_type};
say Dumper($storage_type);

UBR::Sisis::Schema->storage_type($storage_type);
my $schema_sisis = UBR::Sisis::Schema->connect(
    @{$config_hash->{'Model::SisisDB'}{connect_info}}  
);


my $csv = Text::CSV_XS->new ({ binary => 1 }) or
    LOGDIE("Cannot use CSV: " . Text::CSV->error_diag ());
$csv->sep_char(";");
TRACE("CSV-Datei: " . $csv_file_in);
open my $fh, "<:encoding(cp1252)", $csv_file_in->stringify
    or LOGDIE("$csv_file_in: $!");
my @rows;
while (my $row = $csv->getline ($fh)) {
    push @rows, $row;
}
$csv->eof or $csv->error_diag;
close $fh or LOGDIE("$csv_file_in: $!");

say join ' ', shift @rows;

my $csv_out = Text::CSV_XS->new ({ binary => 1 }) or
    die "Cannot use CSV: ".Text::CSV->error_diag ();

$csv_out->eol ("\r\n");
$csv_out->sep_char(";");
open $fh, ">:encoding(utf8)", $csv_file_out->stringify
    or die "$csv_file_out: $!";

$csv_out->print ($fh, [ "Dateiname", map { ucfirst $_ } @keys ] );

foreach my $row (@rows) {
    my $filename = $row->[0];
    my ($lfdnr) = $filename =~ /_(\d+)$/;
    
    my $signatur = $row->[1];
#    LOGCROAK("filename and call number doesn't match: $filename - $signatur") 
#        unless $signatur =~ /$lfdnr$/;
    my $buch_rs
        = $schema_sisis
            ->resultset('D01buch')->search({d01ort => $signatur },
    );
    
    unless ($buch_rs) {
        LOGCARP " $signatur got\n";
        next;
    }
   
    LOGCROAK "No hit for call number '$signatur'" unless $buch_rs->count;
    LOGCROAK "More than one hit for call number '$signatur'" if $buch_rs->count > 1;
     
    if (my $buch = $buch_rs->next) {
        my ($titel_sisis) = @{$buch->get_titel()}; 
        my $source_titel = $schema_atacama->source('Titel');
        my $titel_new = $schema_atacama->resultset('Titel')->get_new_result_as_href({});
            # $c->log->debug(Dumper($titel_sisis));
        %$titel_new = map {
                $_ =>
                decode('utf8',$titel_sisis->{ $source_titel->column_info($_)->{sisis} || $_ })
        } keys %$titel_new;
        say Dumper($titel_new);
        my $row = [ $filename, @{$titel_new}{@keys} ];
        say join " | ", @$row;
        $csv_out->print ($fh, $row);
    } else {
        LOGCROAK "No medium with call number '$signatur'";
    }
}

close $fh or die "$csv_file_out: $!"; 

=encoding utf-8

=head1 NAME
 
get_bibliography_from_callnr.pl - get bibliographic meta data from OPAC  

=head1 SYNOPSIS

get_bibliography_from_callnr.pl [options]  

 Options:
   --help         display this help and exit
   --man          display extensive help

   --csv_in       CSV file for input with filename and call number
   --csv_out      CSV file for output with bibliographic metadata

 Examples:
   get_bibliography_from_callnr.pl --csv_in ubr05510.csv --csv_out ubr05510_new.csv  
   get_bibliography_from_callnr.pl --help
   get_bibliography_from_callnr.pl --man 
   

=head1 DESCRIPTION
  
Get bibliographic meta data from OPAC  

For a set of call numbers bibliographic records are fetched from the local library catalogue
The call numbers are read from a CSV file which has filenames in the first and call numbers 
in the second column. The result is written to a new CSV file.

=head1 AUTHOR

Albert Schröder <albert.schroeder@ur.de>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


