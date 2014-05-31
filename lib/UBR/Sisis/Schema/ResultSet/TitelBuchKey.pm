package UBR::Sisis::Schema::ResultSet::TitelBuchKey;

# ABSTRACT: Result set for TitelBuchKey

use Moose;
use MooseX::NonMoose;
extends 'DBIx::Class::ResultSet';
use namespace::autoclean;
use Hash::Flatten qw(flatten);
    
sub get_titles {
    my ($self, $cond) = @_;
    
    my $rs = $self->search(
        $cond,
        {
            prefetch => [ qw( d01buch titel_dupdaten titel_verbund ) ],
            result_class => 'DBIx::Class::ResultClass::HashRefInflator',
        },
    );
    my @titles;
    while (my $title = $rs->next) {
        my $title = flatten($title);
        my $title_new;
        @$title_new{ map { s/.*\.//r } keys %$title } = values %$title;
        $title_new->{bvnr} = delete $title_new->{verbundid} || 'BV000000000';
        push @titles, $title_new;
    }
    return @titles;
}

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

__END__
