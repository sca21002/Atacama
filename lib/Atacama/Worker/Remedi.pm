package Atacama::Worker::Remedi;
use base 'TheSchwartz::Worker';
use Atacama::Worker::Job::Remedi;
use Carp;
use Data::Dumper;



sub work {
    my $class = shift;
    my $theschwartz_job = shift;
    
    croak("Falscher Aufruf von Atacama::Worker::Remedi::work()"
            . " mit Klasse: $class"
         ) unless $class eq 'Atacama::Worker::Remedi';
    croak("Falscher Aufruf von Atacama::Worker::Remedi::work()"
            . " mit Job: " . ref $theschwartz_job 
         ) unless ref $theschwartz_job eq 'TheSchwartz::Job';
    my %init_arg;
    foreach my $key (qw(
        order_id
        source_pdf
        resolution_correction
        source_format
        does_copy_files
        does_csv
        does_digifooter
        does_mets
        remedi_configfile
    )) {
        $init_arg{$key} = $theschwartz_job->arg->{$key}
            if $theschwartz_job->arg->{$key};
    }
    my $job = Atacama::Worker::Job::Remedi->new(%init_arg);
    $job->run;
    $theschwartz_job->completed();
    return 1;
}

1;
