package Odin::ProtocolStack::Layer::Authentication;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Layer::Authentication

=head1 DESCRIPTION

The Authentication Layer handles the identification of the peer with which
we are communicating.

It has 3 main purposes, that can be ignored if not needed:
1. Identify the peer, detect who he is.
2. Provide a method for a peer to B'register' with us, that is: provide some credentials
    that this layer (Authentication) will use it in future connections to achieve point 1.
    Done in Registration sub-layer.
3. Provide different / personalized access to different peers when requesting
    resource operations. This is achieved through the Authorization sub-layer.

Has 2 sub-layers, that are not mandatory for proper stack functioning:
* Registration
* Authorization

=cut

use base qw( Odin Class::Accessor );


1;
