package Odin::Worker::Parent;

use strict;
use warnings;

use base qw( Odin::Worker );

use Odin::Worker::Child;
use Odin::ProtocolStack::Parent::SocketProtocol;


sub _init {
    my $self = shift();

    $self->protocol_stack(
        Odin::ProtocolStack::Parent::SocketProtocol->new()
    );
}


sub _install_signal_handlers {

}


sub _run {
    my $self = shift();

    while(1){
        warn "Entered Parent main loop.";
    }
}


sub dispatch_new_child {
    my $self = shift();

    my $child = Odin::Worker::Child->new( { socket_protocol => $self->protocol_stack() } );
}

1;
