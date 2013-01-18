package Odin::ProtocolStack;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack - Access the stack in a simple way

=head1 SYNOPSIS

    use Odin::ProtocolStack;

    # Need a socket to communicate unto
    my $socket = GET_SOCKET();

    my $pstack = Odin::ProtocolStack->new(
        {
            conf_path => './conf/protocol_conf.json'
            peer_socket => $socket,
        }
    );

    # Register some resources where we can dispatch operations
    $pstack->register_resource( RESOURCE1 );
    $pstack->register_resource( RESOURCE2 );
    $pstack->register_resource( RESOURCE3 );

    # Communication model is complete:
    # Retrieve messages from the socket and dispatch corresponding resources to handle them
    while( ! $pstack->closed() ) {
        $pstack->retrieve();
    }

    exit(0);

=cut

use base qw( Odin::ProtocolStack::ProtocolClass );


use Odin::ProtocolStack::Configuration;

use Carp;


=head1 DESCRIPTION

A stack of layers is loaded and assembled here.
Also, access to the layers from the exterior should be done only through this class.

Layers are defined in Odin::ProtocolStack::Layer::* namespace.

=head2 isa

Odin::ProtocolStack::ProtocolClass

=head2 Private object members

=over 5

=item C<closed>

Keeps the state of the stack. Can have two possible values:
* C<0>: meaning that it is not closed, i.e. the communication is active
* C<1>: was marked as closed, i.e. C<shutdown> was called, socket was closed.

=back
=cut

__PACKAGE__->mk_group_accessors( simple => qw( _layers _top_layer _conf closed ) );


=head1 METHODS

=over 4

=item C<new>

    my $stack = Odin::ProtocolStack->new( HASHREF_PARAMS );

Instantiates this class and creates a new object, fully initialializing and preparing
the communication.

HASHREF_PARAMS are the parameters that are needed such that the initialization can
be completed, the only mandatory one is B<conf_path>:

    {
        conf_path => './conf/protocol_conf.json',
        # other parameters
    }


=cut
sub new {
    my $class = shift();
    my $args = shift();

    my $self = {};
    bless $self, $class;

    $self->_layers( {} );
    $self->closed( 0 );

    unless( $args && $args->{conf_path} ) {
        croak "The Protocol Configuration file path was not specified.";
    }

    $self->_conf( Odin::ProtocolStack::Configuration->new()->conf( $args->{conf_path} ) );

    $self->_initialize( $args );

    return $self;
}


# don't need to document this.
sub _initialize {
    my $self = shift();
    my $args = shift();

    my $top_layer;

    my $conf = $self->_conf();

    foreach my $level ( sort keys %{$conf->{layers}} ) {
        eval "require $conf->{layers}->{$level}->{class};";
        if( $@) {
            croak "Could not find the layer defined by: " . $conf->{layers}->{$level}->{class};
        }

        my $params = {};

        # Create the layer, with the required parameters
        if ( $conf->{layers}->{$level}->{parameters} ) {
            foreach my $param_name ( keys %{$conf->{layers}->{$level}->{parameters}} ) {

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


=item C<send>

    use Odin::ProtocolStack::Message::JSONEncoded;

    my $message = Odin::ProtocolStack::Message::JSONEncoded->new(
        {
            data => 'no data',
            resource => "resourceX",
            operation => "operationY",
        }
    );
    $pstack->send( $message );

Passes a message through all the layers of the stack.

On the receiving end (in the peer), this message is extracted, the Resource having
the B<resource_name> attribute equal to C<resourceX> will be invoked with the
method name C<operationY>.

=cut
sub send {
    my $self = shift();

    # redirect the operation to the top-most layer..
    return $self->_top_layer()->send( shift() );
}

=item C<retrieve>

    $pstack->retrieve();

A slighlty missleading name.
Polls the underlying socket layer for messages which are passed through all the
subsequently higher layers.

By default, the top layer is C<Dispatcher> will uses the polled message to invoke
a Resource class, which should handle communicating the response to the client.

This methods croaks if the object was marked as B<closed>.
The object is marked as C<closed> as a result to a call to the C<shutdown> method.
C<shutdown> should be set from inside any Resource class, in particular cases when we want to
close the connection with the client, or the client hang up.
=cut
sub retrieve {
    my $self = shift();

    $self->closed() && croak "The stack was marked as closed.";

    return $self->_top_layer()->retrieve();
}


=item C<shutdown>

    $pstack->shutdown();
    print "Connection with the client was closed.";

    exit(0);

Calls shutdown on all the layer present in the stack, marking the stack object
as C<closed>.
=cut
sub shutdown {
    my $self = shift();

    $self->closed( 1 );

    return $self->_top_layer()->shutdown();
}


=item C<register_resource>

Supposing we have a class:
    package MyApp::Resources::Accounts;

    use Odin::ProtocolStack::Message::JSONEncoded;

    use base qw ( Odin::ProtocolStack::Resource );
    __PACKAGE__->resource_name( 'account' );

    sub add_account {
        my $self = shift();
        my $message = shift();

        my $account_name = $message->data()->{name};

        # do something with the name

        # send the response to the peer.
        my $response = Odin::ProtocolStack::Message::JSONEncoded->new(
            {
                resource => 'account',
                operation => 'add_account',
                metadata => 'ok',
            }
        );
        $self->protocol_stack()->send( $response );
        $self->protocol_stack()->shutdown();
    }

We can register this resource in our stack of layers

    $pstack->register_resource( 'MyApp::Resources::Accounts' );

Now the messages having:
* resource = 'account'
* operation = 'add_account'
will trigger the invoking of the sub C<add_account> defined above.

=back
=cut
sub register_resource {
    my $self = shift();

    return $self->_top_layer()->register_resource( shift() );
}


=head1 AUTHOR

Adi Seredinschi, C<< <adizere at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Adi Seredinschi.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
1;
