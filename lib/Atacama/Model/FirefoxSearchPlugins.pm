package Atacama::Model::FirefoxSearchPlugins;

# ABSTRACT: Model for Firefox search plugins

use strict;
use base 'Catalyst::Model::File';

__PACKAGE__->config(
    root_dir => Atacama->path_to(qw(root base firefoxsearchplugins)),
);

1; # Magic true value required at end of module

__END__

=head1 SYNOPSIS

See L<Atacama>

=head1 DESCRIPTION

L<Catalyst::Model::File> Model storing files under
