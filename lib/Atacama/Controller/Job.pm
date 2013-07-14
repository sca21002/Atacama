use utf8;
package Atacama::Controller::Job;
use Modern::Perl;
use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Atacama::Controller::Job - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub jobs : Chained('/base') PathPart('job') CaptureArgs(0) {
    my ($self, $c) = @_;
    
}

=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
