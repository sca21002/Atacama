package Atacama::LDAP::Backend;

use parent Catalyst::Authentication::Store::LDAP::Backend;

BEGIN { __PACKAGE__->mk_accessors(qw(user_model)); }

1;
