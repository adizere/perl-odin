package Odin::ProtocolStack::Layer::Dispatcher;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Layer::Dispatcher

=head1 SYNOPSIS

    use Odin::ProtocolStack::Layer::Dispatcher;

    my $layer = Odin::ProtocolStack::Layer::Dispatcher->new();

    # Register some resources where we can dispatch operations
    $layer->register_resource( RESOURCE1 );
    $layer->register_resource( RESOURCE2 );
    $layer->register_resource( RESOURCE3 );

    # Integrate this layer with the lower layers (Messagins, Socket) so that everything
    # will be in place

    # Retrieve messages from the socket and dispatch corresponing resources to handle them
    while(1) {
        $layer->retrieve();
    }

=cut

use base qw( Odin::ProtocolStack::Layer Exporter );


use Carp;

=head1 DESCRIPTION

The highest level of the stack.

Based on Messages received from the lower layers (through retrieve()), it dynamically
invokes the proper Resource class and corresponding method from that class, that
will handle the request from the peer.

Eg:
1. Received a Message $msg (inside C<on_retrieve>) with attributes:

    print $msg->resource(); # gives 'account'
    print $msg->operation(); # gives 'new'

2. Searches through the registered resources the one which has the NAME attributes
set to B<account>, and calls C<run()> on a new instance of that class, passing
as parameters the operation name B<new> and the whole message B<$msg>, that is:

    my $resource = GET_RESOURCE_BY_NAME( 'account' );
    # $resource now holds the name of a class, e.g. MyApplication::Resource::Accounts;
    my $instance = $resource->new();
    return $instance->run( 'new', $msg );
    # run effectively calls new, passing the message as parameter

=head2 isa

Odin::ProtocolStack::Layer

=head2 Inherited object members

=over 5

=item C<upper_layer>

By default the Dispatcher is at the highest level.

=item C<lower_layer>

Dispatcher relies on the Message layer, which properly deserializes the data received
on the Socket.

=item C<protocol_stack>

Object that mediates the access to the whole stack of layers, should be an
B<Odin::ProtocolStack>.

=back

=head2 Private object members

=over 5

=item C<resources_index>

A hashref.
Keeps all the registered resources. To register a resource see C<register_resource>
method from this class.

=back
=cut
__PACKAGE__->mk_group_accessors( simple => qw( resources_index ) );


=head2 Overridden object methods

I<These are private and are called from the superclass, shouldn't be called from
the outside.>

=over 5

=item C<on_init>

Initializes the index of registered resources to an empty hashref.

=cut
sub on_init {
    my $self = shift();
    my $args = shift();

    if ( $args && exists $args->{resources} ) {
        foreach( @{$args->{resources}} ) {
            $self->register_resource( $_ );
        }
    }

    $self->resources_index( {} );

    return $self;
}


=item C<on_retrieve>

Called from retrieve().
Expects as parameter an Message as it was received on the B<Messaging> layer
through C<on_retrieve>.

Searched the proper resource class, instantiates it, and calls the proper method,
as specified in the Message. See B<DESCRIPTION> above for a bit more detailed
view.

=cut
sub on_retrieve {
    my $self = shift();
    my $msg = shift();

    # empty message
    if ( length $msg->serialized_message() == 0 ){
        carp "Empty message received. Protocol closing.";
        $self->shutdown();

    } else {
        my $resource_name = $msg->resource();
        my $operation_name = $msg->operation();

        if ( $resource_name && $operation_name ) {

            # Is there any registered resource with this name?
            my $resource_class = $self->resources_index()->{$resource_name};
            unless ( $resource_class ) {
                croak "No resource is registered with this name: " . $resource_name;
            }

            return $resource_class->new(
                {
                    protocol_stack => $self->protocol_stack(),
                }
            )->run( $operation_name, $msg );

        } else {
            unless ( $resource_name ) {
                carp "Resource name missing from message.";
            }
            unless ( $operation_name ) {
                carp "Operation name missing from message.";
            }
        }
    }
}


=item C<on_send>

Called from send().
Usually send() will be called from an arbitrary resource, and that resource shall
need at a certain point to send something back to the peer.

Sending of a message first passes through here, before the message being passed
down to B<Messaging> and B<Socket> layers.

For now, the messages are simply C<return>ed, no specific behaviour being necessary.

=cut
sub on_send {
    my $self = shift();
    my $msg = shift();

    # Nothing to do here, for now..

    # Return what is to be send
    return $msg;
}


=item C<on_shutdown>

Called from shutdown(): no specific shutdown operations need to be done at this
layer, so it will do nothing.

=back
=cut
sub on_shutdown { return; }


=head1 METHODS

=over 4

=item C<register_resource>

    # assuming that the class Odin::ProtocolStack::Resource::SampleResource exists
    $dispatcher_layer->register_resource( 'Odin::ProtocolStack::Resource::SampleResource' );

Registers a new Resource class in the index of resources kept by the layer object.

A noteworthy aspect is the fact that any registered Resource has to inherit from
the class: B<Odin::ProtocolStack::Resource>. This is verified by this method, before
the class is registered. If the resource does not inherit properly, the method call
will croak.
Moreover, the Resource has to have set the attribute C<resource_name> (inherited from
the above mentioned mandatory superclass) to a string. This has the purpose of
simplifying the content of Messages passed around, making the dispatching action
more straightforward.

The C<resource_name> of a Resource is compared with the C<resource> attribute
of Messages. If the 2 strings are equal, that signifies that the message should
be dispatched to the corresponding Resource.

The effect is that inside Messages, instead of keeping the whole resource class
name, we just keep a symbolizing name, e.g.
* 'account' could stand out for 'Odin::ProtocolStack::Resource::Account'
OR
* 'Mouse' could correspond to 'MyApplication::Common::Resources:Mouse'

Again, note that both the above classes would need to C<use base>:
B<Odin::ProtocolStack::Resource>.

=back
=cut
sub register_resource {
    my $self = shift();
    my $resource_class = shift();

    unless( $resource_class ) {
        croak "Resource registration needs the class of the resource to register.";
    }

    eval "require $resource_class";
    if ( $@ ) {
        croak "Resource registration failed; could not find the class of the resource [$resource_class]: " . $@;
    }

    unless( ( defined $resource_class->resource_name() ) && ( length $resource_class->resource_name() > 0 ) ) {
        croak "Resource registration failed; The name attribute for this class - [$resource_class] - is not set.";
    }

    # all good, add it to the index
    $self->resources_index()->{$resource_class->resource_name()} = $resource_class;

    return $self;
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
