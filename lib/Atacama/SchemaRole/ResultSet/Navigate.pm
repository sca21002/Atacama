package Atacama::SchemaRole::ResultSet::Navigate;
use Moose::Role;
use Safe::Isa;
use Regexp::Common qw (number);
use Modern::Perl;

# ABSTRACT: Atacama::SchemaRole::ResultSet::Navigate

sub navigate {
    my ($self, $move, $row, $attrib) = @_;
    
    if    ( $move eq 'first') { return $self->first }
    elsif ( $move eq 'next' ) { return $self->seek_next($row, $attrib) || $row }
    elsif ( $move eq 'prev' ) { return $self->seek_prev($row, $attrib) || $row }
    elsif ( $move eq 'last' ) { return $self->seek_last($attrib) }
    elsif ( $move =~ /^$RE{num}{int}$/ ) { return $self->seek_index($move) }
    else                       { return }
}

sub seek_next {
    my ($self, $row, $attrib) = @_;
    
    unless ( $row->$_isa('DBIx::Class::Row') ) { 
        $self->throw_exception(
            "First parameter of seek_next isn't a row object"
        );
    };

    my $sidx = $attrib->{sidx} || 'order_id';
    my $sord = $attrib->{sord} || 'asc';
    
    $self->search(
        { "me.$sidx" => { '>', $row->$sidx     } },                  
        { order_by   => {"-$sord" => "me.$sidx"} },
    )->first;                  
}

sub seek_prev {
    my ($self, $row, $attrib) = @_;
    
    unless ( $row->$_isa('DBIx::Class::Row') ) { 
        $self->throw_exception(
            "First parameter of seek_prev isn't a row object"
        );
    };

    my $sidx = $attrib->{sidx} || 'order_id';
    my $sord = $attrib->{sord} || 'asc';
    
    $self->search(
        { "me.$sidx" => { '<', $row->$sidx } },                  
        { order_by => { '-' . ($sord eq 'desc' ? 'asc':'desc') => "me.$sidx"}  }
    )->first;
}
 
sub seek_last {
    my ($self, $attrib) = @_;

    my $sidx = $attrib->{sidx} || 'order_id';
    my $sord = $attrib->{sord} || 'asc'; 
   
    $self->search(
        {},
        { order_by => {'-' . ($sord eq 'desc' ? 'asc':'desc') => "me.$sidx"}  }
    )->first;
}

sub seek_index {
    my ($self, $index) = @_;

    my $count = $self->count;
    $index += 0;          
    $index = 1 if $index < 1;
    $index = $count if $index > $count;
    $self->search({})->slice($index-1, $index-1)->first;
}


1;