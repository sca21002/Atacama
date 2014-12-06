#!/usr/bin/env perl
use utf8;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent(2)->child('lib')->stringify;
use Atacama::Helper;
use Modern::Perl;
use Log::Log4perl qw(:easy);

# TODO: use Getopt::Long::Descriptive;
# TODO: Use named parameters 

### intitialize easy logging
my $logfile = path($Bin)->parent(2)->child(qw(log set_status.log));
Log::Log4perl->easy_init(
    { level   => $INFO,
      file    => ">>" . $logfile,
    },
    { level   => $TRACE,
        file    => 'STDOUT',
    },
);
INFO('--------------------------------------------------------------------');
INFO('Parameter: ' . join(' ',@ARGV));

my ($jobname, $login, $status_id, $remarks) = @ARGV;

LOGDIE('Jobname muss angegeben werden') unless $jobname;
LOGDIE('status_id muss angegeben werden') unless $status_id;
LOGDIE('Bemerkung muss angegeben werden') unless $remarks;

$login = 'anonymous' unless $login;

my $schema = Atacama::Helper::get_schema(path($Bin)->parent(2));

my $order = $schema->resultset('Order')->find({ 
    order_id => $jobname,
});

LOGDIE("Job '$jobname' nicht in der Datenbank gefunden") unless $order;

# my $status_id =53;
$order->update({status_id => $status_id});
$order->add_to_remarks({
	status_id => $status_id, 
	login => $login,
	content => $remarks
});

INFO('Status fuer Job: ' .  $jobname . ' von ' . $login . ' geaendert: ' . $status_id . ' (' . $remarks . ')');


