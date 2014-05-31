use utf8;
package Atacama::Types::Atacama;
use strict;
use warnings;
use List::Util qw(first);
use List::MoreUtils qw(all);
use Data::Dumper;

# ABSTRACT: Types library for Atacama specific types 

use MooseX::Types -declare => [ qw(
    ArrayRef_of_Dir
    Order_id
    TheSchwartz_Job

) ];

use MooseX::Types::Moose qw(
    ArrayRef
    Str
);

class_type TheSchwartz_Job, { class => 'Atacama::Helper::TheSchwartz::Job' };

subtype Order_id,
  as Str,
  where { / \A [a-z] [_a-z0-9]* \z /x },
  message { "'$_' is not a valid order_id" }
;

subtype ArrayRef_of_Dir, 
    as ArrayRef['Path::Tiny'], 
    where {  
        all { $_->is_dir } @$_ 
    }, 
    message { 
        sprintf( "Directory '%s' does not exist", first { !$_->is_dir } @$_ )  
    }
;

coerce ArrayRef_of_Dir,
    from ArrayRef[Str],
    via { [ map { Path::Tiny::path($_) } @$_ ] };


1; # Magic true value required at end of module
