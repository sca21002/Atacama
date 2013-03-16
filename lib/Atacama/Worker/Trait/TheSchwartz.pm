package Atacama::Worker::Trait::TheSchwartz;
use Moose::Role;
use TheSchwartz::Job;


has 'thesschwartz_job' => (
    is => 'rw',
    isa => 'TheSchwartz::Job',
    handles => [qw( arg completed)],
    required => 1,
);


no Moose::Role;

1;
