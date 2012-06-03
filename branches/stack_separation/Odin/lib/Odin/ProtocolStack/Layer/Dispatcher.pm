package Odin::ProtocolStack::Layer::Dispatcher;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Layer::Dispatcher

=head1 DESCRIPTION

The highest level of the stack.

Based on Messages received from the lower layers, if dynamically invokes the
proper Resource class and corresponding method from that class, that will handle
the request from the peer.

=cut

use base qw( Odin::ProtocolStack::Layer );


sub on_init {
    my $self = shift();

    return $self;
}


sub on_retrieve {
    my $self = shift();
    my $msg = shift();


    
}

1;
