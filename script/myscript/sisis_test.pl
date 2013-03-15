#!/usr/bin/perl
use Modern::Perl;

use FindBin;
use lib "$FindBin::Bin/../../lib";
use Config::ZOMG;
use UBR::Sisis::Schema;
use Data::Dumper;
use Carp;
use Encode;

binmode(STDOUT, ":utf8");

my $config = Config::ZOMG->new(
    name => 'Atacama',
    path => File::Spec->catfile($FindBin::Bin,'..','..'),
);
my $config_hash = $config->load;
say Dumper($config_hash);

my $connect = $config_hash->{'Model::SisisDB'}{connect_info};  

say Dumper($connect);

my $schema_sisis = UBR::Sisis::Schema->connect(
    @{$config_hash->{'Model::SisisDB'}{connect_info}}   
);

my $signatur = '999/Art.533';
my $buch_rs
    = $schema_sisis
        ->resultset('D01buch')->search({d01ort => { 'like' => $signatur }},
);

unless ($buch_rs) {
    carp "Kein Buch zur Signatur $signatur bekommen\n";
    next;
}

say "Treffer: " . $buch_rs->count;

while (my $buch = $buch_rs->next) {
    say Dumper(my $r = $buch->get_titel());
    say decode('utf8',$r->[0]{autor_avs});
}

