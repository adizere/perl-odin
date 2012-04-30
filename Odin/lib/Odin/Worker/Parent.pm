package Odin::Worker::Parent;

use strict;
use warnings;

use base qw( Odin::Worker );

use Odin::Worker::Child;
use Odin::ProtocolStack::Parent::Socket;


sub _init {
    my $self = shift();

    $self->protocol_stack(
        Odin::ProtocolStack::Parent::Socket->new()
    );
}


sub _install_signal_handlers {

}


sub _run {
    my $self = shift();

    while(1){
        warn "Entered Parent main loop.";

        my $client = $self->protocol_stack()->accept();
        warn "Got a connection from: " . $client->{ip} . ':' . $client->{port};

        $self->dispatch_new_child( $client->{socket} );
    }
}


sub dispatch_new_child {
    my ( $self, $socket ) = shift();

    my $child = Odin::Worker::Child->new( {
        client_socket => $self->protocol_stack(),
    } );
}

1;
