package Odin::ProtocolStack::Child::Messaging;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Child::Messaging

=head1 DESCRIPTION

Messaging-level protocol for interaction between a client and the Child
workers.

At the messaging level, specific encoding and serializing is performed,
messages need to go go through a basic validation process.

=cut

use base qw( Odin::ProtocolStack::ChildProtocolLayer );


sub serialize {

}

sub deserialize {

}

sub valid_inbound_data {

}

sub valid_outbound_data {

}

1;
