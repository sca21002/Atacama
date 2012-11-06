package Atacama::Controller::Titel;
use Moose;
use namespace::autoclean;
use Atacama::Form::Titel;

use Data::Dumper;
BEGIN {extends 'Catalyst::Controller'; }
use Encode;

=head1 NAME

Atacama::Controller::Titel - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Atacama::Controller::Titel in Titel.');
}

sub titel : Chained('/') PathPart('titel') CaptureArgs(0) {
    my ($self, $c) = @_;
    
    $c->stash->{titel} = $c->model('AtacamaDB::Titel');
}

sub titel_single : Chained('titel') PathPart('') CaptureArgs(1) {
    my ($self, $c, $order_id) = @_;

    $c->stash->{order_id} = $order_id;
    my $order = $c->model('AtacamaDB::Order')->find($order_id)
        || $c->detach('not_found');
    $c->stash->{titel_single} = $order->find_or_new_related('titel', {} );
}

sub json : Chained('titel') {
    my ($self, $c) = @_;
    
    # $c->log->debug('JSON params ' . Dumper($c->req->query_params));
    $c->stash->{signatur} =  $c->req->query_params->{signatur};
    $c->forward('get_title');
    # $c->log->debug('nach get_title');
    my $json_data = $c->stash->{titel_data}; 
    # $c->log->debug('json_data ' . encode('utf8',Dumper($json_data)));
    # $c->log->debug('Autor: ' . encode('utf8',$json_data->[0]{autor_avs}));
    $c->stash(
        json_data => $json_data,
        current_view => 'JSON'
    );
}

sub edit : Chained('titel_single') {
    my ($self, $c) = @_;
    my $titel_single = $c->stash->{titel_single};
    my $form = Atacama::Form::Titel->new;
    $c->stash( template => 'titel/edit.tt', form => $form );
    $form->process(item => $titel_single, params => $c->req->params );
    return unless $form->validated;
    #$c->flash( message => 'Book created' );
    # Redirect the user back to the list page
    $c->response->redirect(
        $c->uri_for_action('/order/edit', [ $c->stash->{order_id} ])
    );
}

sub get_title : Private {
    
    my ($self, $c) = @_;
    
    
    # $c->log->debug('In get_title');
    my $signatur = $c->stash->{signatur};
    my $mediennr = $c->stash->{mediennr};
    my $titel = $c->stash->{titel};
    return unless $mediennr || $signatur;

    my @titel;
	my $buch;
	if ( $mediennr ) {
		$buch = $c->model('SisisDB::D01buch')->search({
			d01gsi => $mediennr
		})->first;
	} else {
		$buch = $c->model('SisisDB::D01buch')->search({
			d01ort => $signatur
		})->first;
	}
    
    foreach my $titel_sisis (@{$buch->get_titel}) {
        my $titel_new = $titel->get_new_result_as_href({});
        # $c->log->debug('titel_sisis : ' . Dumper($titel_sisis));
        my $source_titel = $c->model('AtacamaDB')->source('Titel');
        %$titel_new = map {
            $_ =>
            decode('utf8',$titel_sisis->{ $source_titel->column_info($_)->{sisis} || $_ })
        } keys %$titel_new;
        $titel_new->{library_id} = $titel_new->{library_id} != 5
            ? $titel_new->{library_id}
            : $titel_new->{signatur} =~ /^W 01/
            ?   103
            : $titel_new->{signatur} =~ /^W 02/
            ?   102
            : ''
            ;
            
        $titel_new->{titel_isbd} = $titel->new($titel_new)->titel_isbd;
        push @titel, $titel_new;
    }
    # $c->log->debug(Dumper(\@titel));   
    $c->stash( 
        titel_data => \@titel,
    );
    return;
}

# Das ist reichlich verworren!!!
#
#sub get_title_by_bvnr : Private {
#    
#    my ($self, $c) = @_;
#    
#    
#    # $c->log->debug('In get_title_by_bvnr');
#    my $bvnr = $c->stash->{bvnr};
#    my $titel = $c->stash->{titel};
#    return unless $bvnr;
#
#    my $titel_verbund = $c->model('SisisDB::TitelVerbund')->search({
#        verbundid => $bvnr,
#    })->first;
#    my $titel_sisis = $titel_verbund->get_titel;
#    my $titel_new = $titel->get_new_result_as_href({});
#    # $c->log->debug('titel_sisis : ' . Dumper($titel_sisis));
#    my $source_titel = $c->model('AtacamaDB')->source('Titel');
#    %$titel_new = map {
#        $_ =>  decode('iso-8859-1', $titel_sisis->{ $source_titel->column_info($_)->{sisis} || $_ })
#    } keys %$titel_new;
#    $titel_new->{library_id} = $titel_new->{library_id} != 5
#        ? $titel_new->{library_id}
#        : $titel_new->{signatur} =~ /^W 01/
#        ?   103
#        : $titel_new->{signatur} =~ /^W 02/
#        ?   102
#        : ''
#        ;
#            
#    $titel_new->{titel_isbd} = $titel->new($titel_new)->titel_isbd;
#    $titel_new->{bvnr} = $bvnr;
#    $c->stash( 
#        titel_data => $titel_new,
#    );
#    return;
#}


sub get_title_by_katkey : Private {
    
    my ($self, $c) = @_;
    
    # $c->log->debug('In get_title_by_katkey');
    my $katkey = $c->stash->{katkey};
    my $signatur = $c->stash->{signatur};
    my $titel = $c->stash->{titel};
    return unless $katkey;
    return unless $signatur;
    
    my $where = '= ' . $katkey;
    my $titel_buch_key = $c->model('SisisDB::TitelBuchKey')->search(
        { katkey => \$where },
    )->first;
    my $titel_sisis = $titel_buch_key->get_titel;
    my $titel_new = $titel->get_new_result_as_href({});
    $c->log->debug('titel_sisis : ' . Dumper($titel_sisis));
    my $source_titel = $c->model('AtacamaDB')->source('Titel');
    %$titel_new = map {
        decode('utf8', $_ =>  $titel_sisis->{ $source_titel->column_info($_)->{sisis} || $_ })
    } keys %$titel_new;
    
    my $buch = $c->model('SisisDB::D01buch')->search(
        { d01ort => $signatur },
    )->first;
    if ($buch) { 
        $titel_new->{signatur} = $signatur;
        $titel_new->{library_id} = $buch->d01zweig == 9
            ?   0 
            : $buch->d01zweig != 5
            ? $buch->d01zweig
            : $signatur =~ /^W 01/
            ?   103
            : $signatur =~ /^W 02/
            ?   102
            : ''
            ;
        $titel_new->{mediennr} = $buch->d01gsi;
    }
    $titel_new->{titel_isbd} = $titel->new($titel_new)->titel_isbd;
    $c->stash( 
        titel_data => $titel_new,
    );
    return;
}

sub not_found : Local {
    my ($self, $c) = @_;
    $c->response->status(404);
    $c->stash->{error_msg} = "Titel nicht gefunden!";
    $c->detach('/order/list');
}

    
=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
