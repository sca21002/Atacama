#!/usr/bin/perl
use Modern::Perl;

use FindBin;
use lib "$FindBin::Bin/../../lib";
use Config::ZOMG;
use UBR::Sisis::Schema;

binmode(STDOUT, ":utf8");

my $config = Config::ZOMG->new(
    name => 'Atacama',
    path => File::Spec->catfile($FindBin::Bin,'..','..'),
);
my $config_hash = $config->load;
my @connect = @{$config_hash->{'Model::SisisDB'}{connect_info}};  

say Dumper(@connect);

my $schema_sisis = UBR::Sisis::Schema->connect(
    @{$config_hash->{'Model::SisisDB'}{connect_info}}  
);

my $signatur = '167/ST 250 P30 D582';
my $buch_rs
    = $schema_sisis
        ->resultset('D01buch')->search({d01ort => { 'like' => $signatur }},
);
