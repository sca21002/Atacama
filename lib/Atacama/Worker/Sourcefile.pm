package Atacama::Worker::Sourcefile;
use base 'TheSchwartz::Worker';
use Atacama::Worker::Job::Sourcefile;
use Carp;
use Data::Dumper;

sub work {
    my $class = shift;
    my $theschwartz_job = shift;
    
    croak("Falscher Aufruf von Atacama::Worker::Remedi::work()"
            . " mit Klasse: $class"
         ) unless $class eq 'Atacama::Worker::Sourcefile';
    croak("Falscher Aufruf von Atacama::Worker::Remedi::work()"
            . " mit Job: " . ref $theschwartz_job 
         ) unless ref $theschwartz_job eq 'TheSchwartz::Job';
    my $args;
    $args->{order_id} = $theschwartz_job->arg->{order_id}
        if $theschwartz_job->arg->{order_id};
    $args->{scanfile_formats} = $theschwartz_job->arg->{scanfile_formats}
        if $theschwartz_job->arg->{scanfile_formats};    
    $job = Atacama::Worker::Job::Sourcefile->new($args);
    $job->order->update({status_id => 23});
    $job->run;
    $theschwartz_job->completed();
    $job->order->update({status_id => 27});
    return 1;
};

1;
