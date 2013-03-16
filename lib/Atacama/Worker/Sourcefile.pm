package Atacama::Worker::Sourcefile;
use base 'TheSchwartz::Worker';
use Atacama::Worker::Job::Sourcefile;
use Carp;
use Data::Dumper;

my $log_file_name;
sub get_logfile_name { $log_file_name }

sub work {
    my $class = shift;
    my $theschwartz_job = shift;
    
    croak("Falscher Aufruf von Atacama::Worker::Remedi::work()"
            . " mit Klasse: $class"
         ) unless $class eq 'Atacama::Worker::Sourcefile';
    $job = Atacama::Worker::Job::Sourcefile
        ->with_traits(  qw(TheSchwartz)  )
        ->new( thesschwartz_job => $theschwartz_job );
    $log_file_name = $job->log_file_name;
    $job->order->update({status_id => 23});
    $job->run;
    $job->completed();
    $job->order->update({status_id => 27});
    return 1;
};

1;
