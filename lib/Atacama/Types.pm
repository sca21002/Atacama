package Atacama::Types;

use MooseX::Types -declare => [ qw(
    Order_id
) ];

use MooseX::Types::Moose qw(Str);

subtype Order_id,
  as Str,
  where { / \A [a-z] [_a-z0-9]* \z /x; };

1;