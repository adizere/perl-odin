package Odin::ProtocolStack::ProtocolLayer;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::ProtocolLayer

=head1 DESCRIPTION

Interface that holds the basic methods needed by the all protocol layers defined in
this framework.

=cut

use base qw( Odin Class::Accessor::Grouped );


sub new {
    my $class = shift();

    my $self = {};
    bless $self, $class;

    $self->_init( @_ );

    return $self;
}


sub _init {
    return;
}


sub shutdown {
    return;
}

1;
