use utf8;
package Atacama::Schema::Result::OrderProject;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::OrderProject

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<orders_projects>

=cut

__PACKAGE__->table("orders_projects");

=head1 ACCESSORS

=head2 ordersprojects_id

  data_type: 'mediumint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 order_id

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 project_id

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "ordersprojects_id",
  {
    data_type => "mediumint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "order_id",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "project_id",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</ordersprojects_id>

=back

=cut

__PACKAGE__->set_primary_key("ordersprojects_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<order_id>

=over 4

=item * L</order_id>

=item * L</project_id>

=back

=cut

__PACKAGE__->add_unique_constraint("order_id", ["order_id", "project_id"]);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-03-18 22:23:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:E2POOp4vYFODyh28+4tk1w


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
    "ord",
    "Atacama::Schema::Result::Order",
    { "foreign.order_id" => "self.order_id" }
);

__PACKAGE__->belongs_to(
    "project",
    "Atacama::Schema::Result::Project",
    { "foreign.project_id" => "self.project_id" }
);

__PACKAGE__->has_many(
    "projectvalues",
    "Atacama::Schema::Result::Projectvalue",
    { "foreign.ordersprojects_id" => "self.ordersprojects_id" }
);

use Data::Dumper;

sub projectoptions {
    my $self = shift;
    
    return unless $self->project;
   
    my @projectoptions;
    my @projectkeys = $self->project->projectkeys;
    foreach my $projectkey (@projectkeys) {
        my %projectoption;
        $projectoption{projectkey_id} = $projectkey->projectkey_id;
        $projectoption{pkey} = $projectkey->pkey;
        my $projectvalue = $self->search_related(
            'projectvalues',
            { projectkey_id => $projectkey->projectkey_id }
        )->single;
        $projectoption{value} = $projectvalue->value if $projectvalue;
        push  @projectoptions, \%projectoption;       
    }
    return \@projectoptions;
}

sub save_projectoptions {
    my $self = shift;
    my $params = shift;
    
    my @projectkeys = $self->project->projectkeys;
    my $projectkeys_info;
    foreach my $projectkey (@projectkeys) {
        $projectkeys_info->{$projectkey->projectkey_id} = 1;     
    }
    die "projectoptions should be an array, but I found a " . (ref $params)
        unless ref $params eq 'ARRAY';
        
     
    foreach my $projectoption (@$params) {
      	
        die "no projectkey_id" unless  exists $projectoption->{projectkey_id};
        my $projectkey_id = $projectoption->{projectkey_id};
        die "projectkey_id" . Dumper($projectkey_id) . "don't belong to this project " . Dumper($params)        
            unless exists $projectkeys_info->{$projectkey_id};
        die "no value" unless  exists $projectoption->{value};
     
     
           my $rs = $self->search_related(
            'projectvalues',
            { projectkey_id => $projectkey_id }
        );
        my $row = $rs->single;
        if ($row) { 
            $row->update({value => $projectoption->{value}});
        }
        else {
            if ($projectoption->{value}) {
                $rs->create({value => $projectoption->{value}});   
            }
        }
    }    
} 

__PACKAGE__->meta->make_immutable;
1;
