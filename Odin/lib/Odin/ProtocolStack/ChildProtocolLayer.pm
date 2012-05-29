package Odin::ProtocolStack::ChildProtocolLayer;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::ChildProtocolLayer

=head1 DESCRIPTION

Protocol layers interface defined here. All layers in the protocol used by
a Child inherit from here.

=cut

use base qw( Odin::ProtocolStack::ProtocolLayer );


__PACKAGE__->mk_group_accessors( inherited => qw( upper_layer lower_layer ) );


sub to_client {
    my $self = shift();

    $self->_to_client();

    $self->lower_layer() && $self->lower_layer()->to_client();
}


sub from_client {
    my $self = shift();

    $self->_from_client();

    $self->upper_layer() && $self->upper_layer()->from_client();
}


sub shutdown {
    my $self = shift();

    $self->_shutdown();

    # shutdown domino-effect from upper to lower classes
    $self->lower_layer() && $self->lower_layer()->shutdown();
}


# overwritable functions that provide specific behaviour
sub _to_client {
    return;
}


sub _from_client {
    return;
}


sub _shutdown {
    return;
}


1;
