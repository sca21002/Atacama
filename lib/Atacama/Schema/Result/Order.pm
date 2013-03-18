use utf8;
package Atacama::Schema::Result::Order;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Atacama::Schema::Result::Order

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

=head1 TABLE: C<orders>

=cut

__PACKAGE__->table("orders");

=head1 ACCESSORS

=head2 order_id

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 25

=head2 creation_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 0

=head2 modification_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 status_id

  data_type: 'smallint'
  is_nullable: 1

=head2 documenttype_id

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 title

  data_type: 'text'
  is_nullable: 1

=head2 author

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 ocr

  data_type: 'tinyint'
  is_nullable: 1

=head2 control

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 pages

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 copyright_id

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "order_id",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 25 },
  "creation_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
  },
  "modification_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "status_id",
  { data_type => "smallint", is_nullable => 1 },
  "documenttype_id",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "title",
  { data_type => "text", is_nullable => 1 },
  "author",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "ocr",
  { data_type => "tinyint", is_nullable => 1 },
  "control",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "pages",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "copyright_id",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</order_id>

=back

=cut

__PACKAGE__->set_primary_key("order_id");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-03-18 17:18:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:O0+KFw5Yc2QBr+qxLlYvIw


__PACKAGE__->belongs_to(
    "status",
    "Atacama::Schema::Result::Status",
    { "foreign.status_id" => "self.status_id" },
    { join_type => 'left' }
);

__PACKAGE__->belongs_to(
    "documenttype",
    "Atacama::Schema::Result::Documenttype",
    { "foreign.documenttype_id" => "self.documenttype_id" },
    { join_type => 'left' }
);

__PACKAGE__->belongs_to(
    "copyright",
    "Atacama::Schema::Result::Copyright",
    { "foreign.copyright_id" => "self.copyright_id" },
    { join_type => 'left' }
);

__PACKAGE__->has_many(
    "orders_projects",
    "Atacama::Schema::Result::OrderProject",
    { "foreign.order_id" => "self.order_id" }
);  

__PACKAGE__->has_many(
    "scanparameters",
    "Atacama::Schema::Result::Scanparameter",
    { "foreign.order_id" => "self.order_id" }
);


__PACKAGE__->has_many(
    "publications",
    "Atacama::Schema::Result::Publication",
    { "foreign.order_id" => "self.order_id" }
);

__PACKAGE__->has_many(
    "scanfiles",
    "Atacama::Schema::Result::Scanfile",
    { "foreign.order_id" => "self.order_id" }
);

__PACKAGE__->has_many(
    "pdffiles",
    "Atacama::Schema::Result::Pdffile",
    { "foreign.order_id" => "self.order_id" }
);

__PACKAGE__->has_many(
    "ocrfiles",
    "Atacama::Schema::Result::Ocrfile",
    { "foreign.order_id" => "self.order_id" }
);

__PACKAGE__->has_many(
    "remarks",
    "Atacama::Schema::Result::Remark",
    { "foreign.order_id" => "self.order_id" }
);

__PACKAGE__->might_have(
    "titel",
    "Atacama::Schema::Result::Titel",
    { "foreign.order_id" => "self.order_id" }
);

__PACKAGE__->many_to_many(
    "projects",
    "orders_projects",
    "project"
);

use Data::Dumper;

sub save {
    my $self = shift;
    my $params = shift;


    return unless ($params or %$params);
    my %integer_type = (smallint => 1,tinyint => 1,integer => 1,mediumint => 1);
    my %column;
    my $columns_info = __PACKAGE__->columns_info;
    my $relationships_info;
    my @relationships = __PACKAGE__->relationships;
    foreach my $relationship (@relationships) {
        $relationships_info->{$relationship} = 1;     
    }
    foreach my $key (keys %$params) {
        if (exists $columns_info->{$key}) {
            if ($params->{$key} eq ''
                and exists $integer_type{$columns_info->{$key}{data_type}}
            ){ $params->{$key} = undef; } 
            $column{$key} = $params->{$key};        
        }
        elsif (exists $relationships_info->{$key}) {
            if (ref($params->{$key}) eq 'HASH') {
                # warn 'Order::Result key:' . $key;
                # warn 'KEY: ' . Dumper($self->$key);
                $self->create_related($key,{}) unless $self->$key;
                $self->$key->save($params->{$key})
            }
            elsif (ref $params->{$key} eq 'ARRAY') {
                $self->$key->save($params->{$key});
            }
        }
    }
    $self->update(\%column);
}


sub get_data_from_rels {
    my ($self, $rel) = @_;

    return unless $rel;
    my $data;
    my %options = (
        orders_projects => 'projectoptions',
        scanparameters => 'scanoptions',
        publications => 'publicationoptions',
    );
    
    my $rs = $self->$rel;
    while (my $row = $rs->next) {
        my $href = {$row->get_inflated_columns};
        my $option_val = $options{$rel};
        $href->{$option_val} = $row->$option_val;
        push @$data, $href;
    }
    return $data;
}

sub properties {
    my $self = shift;
    
    my $properties;
    my $order = {$self->get_inflated_columns};
    $order->{titel} = $self->titel && {$self->titel->get_inflated_columns};
    $order->{titel}{titel_isbd} = $self->titel && $self->titel->titel_isbd
        || $self->title =~ /\S/ && 'alt: ' . $self->title;
    foreach my $rel ('orders_projects', 'scanparameters',  'publications') {
        $order->{$rel} = $self->get_data_from_rels($rel);
    }
    $order->{scanfiles_count} = $self->scanfiles->count;
    $order->{pdffiles_count} = $self->pdffiles->count;
    $order->{ocrfiles_count} = $self->ocrfiles->count;
    $properties->{order_href} = $order;
    
    my %rel = (
        status => {
            resultset => 'Status',
            columns => ['status_id', 'name'],
        },
        documenttypes => {
            resultset => 'Documenttype',
            columns => ['documenttype_id', 'name'],
        },
        libraries => {
            resultset => 'Library',
            columns => ['library_id', 'name'],
        },
        scanners => {
            resultset => 'Scanner',
            columns => ['scanner_id', 'name'],
        },
        formats => {
            resultset => 'Format',
            columns => ['format_id', 'name'],
        },
        resolutions => {
            resultset => 'Resolution',
            columns => ['resolution_id', 'value'],
        },
        copyrights => {
            resultset => 'Copyright',
            columns => ['copyright_id', 'name'],
        },
        projects => {
            resultset => 'Project',
            columns => ['project_id', 'name'],
            order_by => 'name',
        },
        platforms => {
            resultset => 'Platform',
            columns => ['platform_id', 'name'],
        },
    );           
    while ( my($rel, $val) = each %rel ) {
        $properties->{$rel} = [
            $self->result_source->schema->resultset($val->{resultset})
                ->search({}, {
                    result_class => 'DBIx::Class::ResultClass::HashRefInflator',
                    columns => $val->{columns},
                    $val->{order_by} ? (order_by => $val->{order_by}) : (),
            })->all
        ];    
    }
    return $properties;    
}

# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;

1;
