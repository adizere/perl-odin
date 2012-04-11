package Odin::ProtocolStack::Child::ChildLogic;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Child::ChildLogic

=head1 DESCRIPTION

ChildLogic layer assures that all interaction scenarios with an identified and
authenticated client are satisfied.

=cut

use base qw( Odin::ProtocolStack::ChildProtocolLayer );


sub _init {
    my ( $self, $args ) = @_;

    $self->instantiante_stack() if ( $args->{complete_stack} );

    return $self;
}


sub run {

}


1;
