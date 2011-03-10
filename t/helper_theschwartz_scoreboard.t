use strict;
use warnings;
use Test::More;
use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin, 'lib'),
        File::Spec->catfile($FindBin::Bin, '..', 'lib');

use_ok('Atacama::Helper::TheSchwartz::Scoreboard');

ok(my $score_dir = File::Spec->catfile($FindBin::Bin, 'var', 'theschwartz1')); 

ok(my $scoreboard = Atacama::Helper::TheSchwartz::Scoreboard->new(
    dir => $score_dir,
));

is($scoreboard->dir, $score_dir, 'score_dir');
my $expected = [
    File::Spec->catfile($score_dir, 'scoreboard.15796')
];
is_deeply($scoreboard->files,$expected,'score_files');
ok(my $score_data = $scoreboard->data);
is($score_data->[0]->pid,'15796','pid');
is($score_data->[0]->started,'1299517457','started');
$expected = {
    configfile
        => '/home/atacama/Remedi-0.04/lib/Remedi/config/remedi_de-155-355.yml',
    digifooter => 1,
    copy_files =>1,
    csv => 1,
    source_format => 'PDF',
    order_id => 'ubr07296',
    mets => 1,
    source_pdf_name
        => '/rzblx8_DATA3/digitalisierung/auftraege/ubr07296/ubr07296.pdf',             
};
is_deeply($score_data->[0]->arg_hashref,$expected,'arg_hashref');
is($score_data->[0]->done,'1299517515','done');
is($score_data->[0]->runtime,'00:58','runtime');
done_testing();
