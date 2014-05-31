use utf8;
package Atacama::Controller::FirefoxSearchPlugins;

# ABSTRACT: Controller FirefoxSearchPlugins

use Modern::Perl;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

sub firefoxsearchplugins
    :Chained('/base')
    :PathPart('firefoxsearchplugins')
    :CaptureArgs(0) {
}

sub list : Chained('firefoxsearchplugins') PathPart('list') Args(0)  {
    my ( $self, $c ) = @_;

    my $model = $c->model('FirefoxSearchPlugins')->change_dir('plugins');
    # _dump_paths($c);  
    my @files = map { $_->basename } $model->list(mode => 'files');	# remove path
    $c->stash(
        ffsearchplugins => \@files,
        template => 'firefoxsearchplugins/list.tt',
    );
}

sub get : Chained('firefoxsearchplugins') PathPart('get') Args(1) {
    my ( $self, $c, $filename ) = @_;

	$c->response->content_type('application/opensearchdescription+xml');
	$c->stash(
            no_wrapper => 1,      
            template   => 'firefoxsearchplugins/plugins/' . $filename,
        );
}


sub not_found : Local {
    my ($self, $c) = @_;
    $c->response->status(404);
    $c->stash->{error_msg} = "Plugin nicht gefunden!";
    $c->detach('list');
}

sub _dump_paths
{
    my ($c) = @_;

    my $indent = '.' x length($c->request->base);
    $c->log->debug('Paths:',
                   "\t\$c->request->uri:  " . $c->request->uri,
                   "\t\$c->request->base: " . $c->request->base,
                   "\t\$c->request->path: $indent" . $c->request->path
                  );
}

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

__END__