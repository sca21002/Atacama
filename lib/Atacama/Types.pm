use utf8;
package Atacama::Types;
use strict; 
use warnings;

use parent 'MooseX::Types::Combine'; 
 
__PACKAGE__->provide_types_from( qw(
    MooseX::Types::DateTime                            
    MooseX::Types::Path::Tiny                             
    MooseX::Types::Moose
    Atacama::Types::Atacama
));

1;





