package Odin::Worker::Child;

use strict;
use warnings;

use base qw( Odin::Worker );


sub _init {
    my ( $self, $args ) = @_;
    unless( $args && $args->{client_socket} ){
        warn "Child Worker cannot instantiate without the peer socket.";
        die "Invalid call to " . ref( $self ) . "->new(): need the peer socket.";
    }

    $self->instantiate_stack( $args->{client_socket} );
}


=head2 instantiate_stack

    $child->instantiate_stack( CLIENT_SOCKET );

B<Description:>

Create all the protocols used by this Child and link them together.

The protocols used by a Child are from ProtocolStack::Child::*, in the following
order (top-down, the last one representing the lowest level of abstractisation, as
seen by a Child):

    1. ChildLogic
    2. Authentication
    3. Messaging
    4. Socket

B<Arguments:>

The socket returned by an accept() call, resulting in a new peer connected to
our server.

=cut
sub instantiate_stack {
    my $self = shift();
    my $client_socket = shift();

    my $cl_proto = Odin::ProtocolStack::Child::ChildLogic->new();
    my $auth_proto = Odin::ProtocolStack::Child::Authentication->new();
    my $mess_proto = Odin::ProtocolStack::Child::Messaging->new();
    my $socket_proto = Odin::ProtocolStack::Child::Socket->new( $client_socket );

    # link the layers
    $socket_proto->upper_layer( $mess_proto );
    $mess_proto->lower_layer( $socket_proto );

    $mess_proto->upper_layer( $auth_proto );
    $auth_proto->lower_layer( $mess_proto );

    $auth_proto->upper_layer( $cl_proto );
    $cl_proto->lower_layer( $auth_proto );

    $self->protocol_stack( $cl_proto );
}

1;
