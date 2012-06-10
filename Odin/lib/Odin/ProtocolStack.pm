package Odin::ProtocolStack;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack

=head1 DESCRIPTION

A stack of layers is loaded and assembled here.
Also, access to the layers from the exterior should be done only through here.

Layers are defined in Odin::ProtocolStack::Layer::* namespace.

=cut

use base qw( Odin::ProtocolStack::ProtocolClass );


use Odin::ProtocolStack::Configuration qw ( $conf );

use Carp;


__PACKAGE__->mk_group_accessors( simple => qw( _layers _top_layer ) );


sub new {
    my $class = shift();
    my $args = shift();

    my $self = {};
    bless $self, $class;

    $self->_layers( {} );
    $self->_initialize( $args );

    return $self;
}



sub _initialize {
    my $self = shift();
    my $args = shift();

    my $top_layer;

    foreach my $level ( sort keys $conf->{layers} ) {
        eval "require $conf->{layers}->{$level}->{class};";
        if( $@) {
            croak "Could not find the layer defined by: " . $conf->{layers}->{$level}->{class};
        }

        my $params = {};

        # Create the layer, with the required parameters
        if ( $conf->{layers}->{$level}->{parameters} ) {
            foreach my $param_name ( keys $conf->{layers}->{$level}->{parameters} ) {

                my $param_value =
                    $conf->{layers}->{$level}->{parameters}->{$param_name}
                    || $args->{$param_name};

                unless ( $param_value ) {
                    croak "Layer " . $conf->{layers}->{$level}->{class} . " needs the parameter " . $param_name;
                }

                $params->{$param_name} = $param_value;
            }
        }

        my $layer = $conf->{layers}->{$level}->{class}->new( $params );

        # Now link the layers between them..
        # The lower layer was saved at the previous iteration..
        if ( $top_layer ) {
            $top_layer->upper_layer( $layer );
            $layer->lower_layer( $top_layer );
        }

        $self->_layers()->{$conf->{layers}->{$level}->{class}} = $layer;

        $top_layer = $layer;
    }

    $self->_top_layer( $top_layer );
}


sub send {
    my $self = shift();

    # redirect the operation to the top-most layer..
    return $self->_top_layer()->send( shift() );
}


sub retrieve {
    my $self = shift();

    return $self->_top_layer()->retrieve();
}


sub shutdown {
    my $self = shift();

    return $self->_top_layer()->shutdown();
}

1;
