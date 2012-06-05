package Odin::ProtocolStack::Layer;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Layer

=head1 DESCRIPTION

Abstract class that holds the basic methods needed by the all protocol layers defined in
this framework.

=cut

use base qw( Odin::ProtocolStack::ProtocolClass );


use Carp;
use Attribute::Abstract;


__PACKAGE__->mk_group_accessors( simple => qw( upper_layer lower_layer protocol_stack ) );



sub new {
    my $class = shift();

    my $self = {};
    bless $self, $class;

    $self->on_init( @_ );

    return $self;
}


sub retrieve {
    my $self = shift();

    if ( $self->lower_layer() ) {
        return $self->on_retrieve( $self->lower_layer()->retrieve() );
    } else {
        return $self->on_retrieve();
    }
}


sub send {
    my $self = shift();
    my $data = shift();

    unless( $data ) {
        croak "No data was passed to " . __PACKAGE__ . "->send().";
    }

    if ( $self->lower_layer() ) {
        return $self->lower_layer()->send( $self->on_send( $data ) );
    } else {
        return $self->on_send( $data );
    }
}


sub shutdown {
    my $self = shift();

    $self->on_shutdown();

    # shutdown - domino-effect from lower to upper classes
    $self->lower_layer() && $self->lower_layer()->shutdown();
}


sub on_init : Abstract;

sub on_shutdown : Abstract;

sub on_retrieve : Abstract;

sub on_send : Abstract;


1;
