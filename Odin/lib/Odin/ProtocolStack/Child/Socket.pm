package Odin::ProtocolStack::Child::Socket;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Child::Socket

=head1 DESCRIPTION

Socket-level protocol for interaction between a client and the Child
workers.

At the socket level, only basic send & receive methods are needed, those methods
follow the Base class specification, and therefore are named:
- _to_client, for sending
- _from_client, for receiving

=cut

use base qw( Odin::ProtocolStack::ChildProtocolLayer );


1;
