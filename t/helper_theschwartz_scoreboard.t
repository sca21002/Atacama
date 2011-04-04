use strict;
use warnings;
use Test::More;
use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin, 'lib'),
        File::Spec->catfile($FindBin::Bin, '..', 'lib');

use_ok('Atacama::Helper::TheSchwartz::Scoreboard');

ok(my $score_dir = File::Spec->catfile($FindBin::Bin, 'var', 'theschwartz')); 

ok(my $scoreboard = Atacama::Helper::TheSchwartz::Scoreboard->new(
    dir => $score_dir,
));

is($scoreboard->dir, $score_dir, 'score_dir');
my $expected = [
    File::Spec->catfile($score_dir, 'scoreboard.15796')
];
is_deeply($scoreboard->files,$expected,'score_files');
ok(my $jobs = $scoreboard->jobs);
ok(my $job = $jobs->[0]);
is($job->pid,'15796','pid');
is($job->started->strftime('%d.%m.%Y %T'),'07.03.2011 17:04:17','started');
$expected = {
    configfile
        => '/home/atacama/Remedi-0.04/lib/Remedi/config/remedi_de-155-355.yml',
    digifooter => '',
    copy_files =>1,
    csv => 1,
    source_format => 'PDF',
    order_id => 'ubr07296',
    mets => 1,
    source_pdf_name
        => '/rzblx8_DATA3/digitalisierung/auftraege/ubr07296/ubr07296.pdf',
    add_param => 'Zusatz',    
};
is_deeply($jobs->[0]->arg_hashref,$expected,'arg_hashref');
is($job->done,'2011-03-07T17:05:15','done');
is($job->runtime,'0:00:58','runtime');
is($job->configfile,
   File::Spec->catfile(qw(/ home atacama Remedi-0.04 lib Remedi config remedi_de-155-355.yml)),
   'configfile'
);
is($job->digifooter ? 1 : 0 ,0,'digifooter');
is($job->copy_files,1,'copy_files');
is($job->csv,1,'csv');
is($job->source_format,'PDF','source_format');
is($job->order_id,'ubr07296','order_id');
is($job->mets,1,'mets');
is($job->source_pdf_name,
    '/rzblx8_DATA3/digitalisierung/auftraege/ubr07296/ubr07296.pdf',
    'source_pdf_name'
);
is($job->additional_args,'add_param=Zusatz','additional_args');
done_testing();
