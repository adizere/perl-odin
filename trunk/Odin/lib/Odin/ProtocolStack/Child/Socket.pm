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

use Carp;

__PACKAGE__->mk_group_accessors( simple => qw( _socket ) );


sub _init {
    my $self = shift();
    my $client_socket = shift();
    unless( $client_socket ){
        croak "Need the socket on which the communication is made!";
    }

    $self->_socket( $client_socket );
}

1;
