#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Config::ZOMG;
use feature qw(say);
use UBR::Sisis::Schema;
use Atacama::Schema;
use Data::Dumper;
use Carp;

binmode(STDOUT, ":utf8");

my $config = Config::ZOMG->new(
    name => 'Atacama',
    path => File::Spec->catfile($FindBin::Bin,'..','..'),
);
my $config_hash = $config->load;
my @connect = @{$config_hash->{'Model::SisisDB'}{connect_info}};  

say Dumper(@connect);
my $storage_type = $config_hash->{'Model::SisisDB'}{storage_type};
say Dumper($storage_type);

UBR::Sisis::Schema->storage_type($storage_type);
my $schema_sisis = UBR::Sisis::Schema->connect(
    @{$config_hash->{'Model::SisisDB'}{connect_info}}  
);

@connect = @{$config_hash->{'Model::AtacamaDB'}{connect_info}};  

my $schema_atacama = Atacama::Schema->connect(
    @{ $config_hash->{'Model::AtacamaDB'}{connect_info} }  
);



#my $signatur = '167/ST 250 P30 D582';
my $signatur = '999/Art.533';
my $buch_rs
    = $schema_sisis
        ->resultset('D01buch')->search({d01ort => $signatur },
);

unless ($buch_rs) {
    carp "Kein Buch zur Signatur $signatur bekommen\n";
    next;
}

if ($buch_rs->all > 1) {
    carp "Mehr als ein Buch zu $signatur gefunden!\n";
    next;
}

# print Dumper(my $hash_ref = $buch_rs->next);

my $buch = $buch_rs->first;
unless ($buch) {
    carp "Kein Buch zur Signatur $signatur bekommen\n";
    next;
    
}
say $buch->d01gsi;

my @titel = $buch->get_titel;

say Dumper(@titel);

#my @titel_katalog = $buch->get_titel;
#foreach my $titel_katalog (@titel_katalog)  {
#    print "Katkey: ",$titel_katalog->katkey,"\n";
#}
#if ( @titel_katalog == 0) {
#    print "Keine Titel zur Signatur " . $signatur . " gefunden!\n";
#    next;    
#}
#elsif (@titel_katalog > 1) {
#    print $signatur, " ist eine Bindeeinheit!\n";
#}
#else {
#    my $titel_katalog = $titel_katalog[0];
#    my $titel_dup_daten = $titel_katalog->get_titel_dup_daten;
#    my %titel_daten = $titel_dup_daten->get_columns;
#    $titel_daten{mediennr} = $buch->d01gsi;
#    $titel_daten{signatur} = $buch->d01ort;
#    $titel_daten{bvnr}     = $titel_katalog->get_bvnr;
#    my $zweigstelle
#        = $schema_atacama
#            ->resultset('Branch')
#            ->find($buch->d01zweig);
#    if ($zweigstelle) {
#        $titel_daten{library_id} = $zweigstelle->library_id != 5
#            ? $zweigstelle->library_id
#                : $titel_daten{signatur} =~ /^W 01/
#            ?   103
#                : $titel_daten{signatur} =~ /^W 02/
#            ?   102
#                : ''
#            ;
#        unless ( $titel_daten{library_id} ) {
#            print "Keine Bibliothek gefunden zu Zweigstelle "
#                . $zweigstelle->name
#                . ' mit sisis_zweig: '
#                . $zweigstelle->sisis_zweig;  
#        }
#    } else {
#        print "Keine Zweigstelle zu " . $buch->d01zweig . " gefunden\n";   
#    }
#    while (my($key,$val) =  each %titel_daten) {
#        if ($val) { 
#            print "$key: $val\n";
#        }
#    }
#    #if ($titel->update_map_data(\%titel_daten)) {
#    #    print $titel->order_id, "upgedatet\n";
#    #}
#    #else {
#    #    carp "Update von " . $titel->order_id . "gescheiter!\n";
#    #}
#
#}
