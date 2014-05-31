package Atacama::Model::SisisDB;

# ABSTRACT: Model for Sisis database

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'UBR::Sisis::Schema',
);

1; # Magic true value required at end of module

__END__

=head1 SYNOPSIS

See L<Atacama>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<UBR::Sisis::Schema>
