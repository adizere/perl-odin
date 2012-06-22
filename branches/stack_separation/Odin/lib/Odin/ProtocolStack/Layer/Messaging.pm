package Odin::ProtocolStack::Layer::Messaging;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Layer::Messaging

=head1 SYNOPSIS

This layer shall handle calling C<serialize> and C<deserialize> at proper moments
during the message exchanging phases between the two peers.

It needs to know what type of messages it will process - the class of messages - which
is specified at object initialization, through the constructor:

    use Odin::ProtocolStack::Layer::Messaging;

    my $layer = Odin::ProtocolStack::Layer::Messaging->new(
        'Oding::ProtocolStack::Message::JSONEncoded' # type of messages
    );

As for the other layers, this should only be used through and intermediary B<ProtocolStack> object,
and not independently from the other layers, but tied up with them (relations between the layers are
created and maintained inside B<ProtocolStack>).

=cut

use base qw( Odin::ProtocolStack::Layer );


use Carp;

=head1 DESCRIPTION

The Messaging layer assures the validity of messages sent between peers.

The messages are instances of one class inside the
Odin::ProtocolStack::Layer::Message::* namespace.

=head2 isa

Odin::ProtocolStack::Layer

=head2 Inherited object members

=over 5

=item C<upper_layer>

By default the Layer that sits on top of Messaging is the B<Dispatcher>.

=item C<lower_layer>

Messaging relies on retrieving and sending data through its lower layer: B<Socket>.

=item C<protocol_stack>

Object that mediates the access to the whole stack of layers, should be an
B<Odin::ProtocolStack>.

=back


=head2 Private object members

=over 5

=item C<message_class>

Specifies which is the type of messages that are sent/retrieved.

=back
=cut
__PACKAGE__->mk_group_accessors( simple => qw( message_class ) );


=head2 Overridden object methods

I<These are private and are called from the superclass, shouldn't be called from
the outside.>

=over 5

=item C<on_init>

Expects the type of messages: a string holding the name of a subclass of 'Odin::ProtocolStack::Message'.

=cut
sub on_init {
    my $self = shift();
    my $args = shift();

    unless( ref $args eq 'HASH' ) {
        croak "Messaging layer initialization needs the parameters in a HASHREF form.";
    }

    my $message_class = $args->{message_class} || undef;

    unless( $message_class ) {
        croak "Messaging layer initialization needs to know what type of messages are passed around: 'message_class' parameter";
    }

    eval "require $message_class";
    if ( $@ ) {
        croak "Messaging layer initialization failed; could not find the class of the messages [$message_class]: " . $@;
    }

    $self->message_class( $message_class );

    return $self;
}


=item C<on_send>

Called from send().
The message passed as parameter to send is mandatory and it should be an instance
of the Odin::ProtocolStack::Message subclass that was specified at layer creation
time (see C<on_init>).

Returns the provided message, in serialized form - the result of calling C<serialize>
on the corresponing message object.

The returned value should arrive at the lower layer (B<Socket>) which will put it
on network.

=cut
sub on_send {
    my $self = shift();
    my $msg = shift();

    unless ( $msg && ( ref $msg eq $self->message_class() ) ) {
        croak "Invalid type of message passed for send: [" . ref ( $msg ) . "] - it is not a [" . $self->message_class() . "]";
    }

    return $msg->serialize();
}


=item C<on_retrieve>

Called from retrieve().
Expects as parameter an raw serialized message as it was received on the socket layer
through C<on_retrieve>.

The serialized data will be deserialized by creating a new instance of a message
(of type C<message_class>, see C<on_init>) upon which is called C<deserialize>.


Returns an instance of C<message_class>.

=cut
sub on_retrieve {
    my $self = shift();
    my $serialized_data = shift();

    if ( ! $serialized_data || ( $serialized_data &&  length $serialized_data == 0 ) ) {
        return $self->message_class()->new();
    }

    my $msg = $self->message_class()->new(
        {
            serialized_message => $serialized_data,
        }
    );

    return $msg->deserialize();
}


=item C<on_shutdown>

Called from shutdown(): no specific shutdown operations need to be done at this
layer, so it will do nothing.

=back
=cut
sub on_shutdown { return; }


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
