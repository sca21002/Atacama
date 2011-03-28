package Atacama::Worker::Sourcefile;
use Carp;

sub work {
    my $class = shift;
    my $job = shift;

    croak('Falscher Aufruf von ',__PACKAGE__ ,"::work() mit Klasse: $class")
        unless $class eq __PACKAGE__;
    croak('Falscher Aufruf von ',__PACKAGE__ ,'::work():'
            . ' kein Objekt vom Typ TheSchwartz::Job')
        unless blessed($job) && $job->isa( 'TheSchwartz::Job' );
        
    $job->completed();
}
1;