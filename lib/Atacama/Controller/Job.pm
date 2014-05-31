use utf8;
package Atacama::Controller::Job;

# ABSTRACT: Controller Job

use Modern::Perl;
use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

sub jobs : Chained('/base') PathPart('job') CaptureArgs(0) {
    my ($self, $c) = @_;
    
}

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

__END__
