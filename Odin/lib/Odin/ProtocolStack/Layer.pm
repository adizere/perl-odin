package Odin::ProtocolStack::Layer;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Layer

=head1 SYNOPSIS

    # Define a layer that identifies who are the peers we are talking to
    package MyApplication::Protocol::Layers::Authentication;

    use base qw( Odin::ProtocolStack::Layer );

    # Here we'll keep the name of the current connected peer
    __PACKAGE__->mk_group_accessors( simple => qw( username ) );

    # Overriden methods
    sub on_init {
        my $self = shift();

        return $self
    }

    sub on_send {
    # Do not interefere with other layer on sending: Just return the Message (second argument)
        return $_[1];
    }

    # We'll do the verification in here
    sub on_retrieve {
        my $self = shift();
        my $msg = shift();

        # Peer was previously authenticated.. let him pass
        if ( $self->username() ) {
            return $msg;
        }

        # Suppose the peer offers the credentials inside the Message
        # Note: For this to work, this layer should be somewhere above the Messaging layer
        my $user = $msg->metadata()->{username};
        my $pass = $msg->metadata()->{password};

        # Do authentication through an external method from other module
        my $result = authentify_user( $user, $pass );
        if ( ! $result ) {
            warn "Unknown user";

            # Deny further access
            $self->shutdown();
        }

        $self->username( $user );

        # all is good
        return $msg;
    }

    sub on_shutdown {
        my $self = shift();

        warn "User " . $self->usernam() . " will disconnect.";

        # Update a timestamp so we know when this user was last connected
        save_last_seen( $self->username() );

        return;
    }

    # done
    1;

=cut

use base qw( Odin::ProtocolStack::ProtocolClass );


use Carp;
use Attribute::Abstract;

=head1 DESCRIPTION

Abstract class that holds the basic methods needed by the all protocol layers defined in
this framework.

=head2 isa

Odin::ProtocolStack::ProtocolClass

=head2 Inheritable object members

=over 5

=item C<upper_layer>

The layer which sits on top of the current one.

=item C<lower_layer>

The layer upon which the current one resides. That is to say that all the services
provided by the lower_layer (and layers lower than that) are available in the
current layer.

=item C<protocol_stack>

The protocol_stack is an intermediary object that creates the relations between
all the layers that are in use: it essentially assembles them (sets the lower_layer
and upper_layer attributes for each of them). When a layer wants to access another
one, it will do it either through the lower_layer / upper_layer, or through this
member (safer through this member because the layers should be dynamically
assembled, so we can't know for sure if A always above B, or another C is between
them).

=back
=cut

__PACKAGE__->mk_group_accessors( simple => qw( upper_layer lower_layer protocol_stack ) );


=head1 METHODS

=over 4

=item new

Creates a new object of the specified type.
Calls C<on_init()> on the specific requested subclass.

=cut
sub new {
    my $class = shift();

    my $self = {};
    bless $self, $class;

    $self->on_init( @_ );

    return $self;
}


=item retrieve

    my $message = $layer->retrieve();

Calls in a cascading manner C<on_retrieve()> on subsequently upper layers, starting
with the lowest and ending with the current one.

Given a stack of 4 layers: A the highest, D the lowest layer:
A on top of B on top of C on top of D.

Calling B->retrieve() results in:
1. $result_D = D->on_retrieve();
2. $result_C = C->on_retrieve( $result_D );
3. return B->on_retrieve( $result_C );

So the calls progress from the lowest to the highest layer, each of them progressively
processing the initially received data.

=cut
sub retrieve {
    my $self = shift();

    if ( $self->lower_layer() ) {
        return $self->on_retrieve( $self->lower_layer()->retrieve() );
    } else {
        return $self->on_retrieve();
    }
}


=item send

    my $bytes_sent = $layer->send( $message );

Calls in a cascading manner C<on_send()> on subsequently lower layers. Initially
it requires a mandatory argument - the Message to be sent.

Given a stack of 4 layers: A the highest, D the lowest layer:
A on top of B on top of C on top of D; the Message M

Calling A->send( M ) could be outlined as:
1. $result_A = A->on_send( M );
2. $result_B = B->on_send( $result_A );
3. $result_C = C->on_send( $result_B );
5. return D->on_send( $result_C );

The calls progress from the highest (current one) to the lowest available layer,
each of the should progressively process/prepare the data, or ultimately send it.

=cut
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


=item shutdown

    $layer->shutdown();

Provides a mechanism of cleanly closing the connection with the peer.

Subsequently calls from the highest layer (current one) to the lowest one the
C<on_shutdown()> method (basically works in the same manner as send), except that
the return values from layer are ignored and are not passed around.

=back
=cut
sub shutdown {
    my $self = shift();

    $self->on_shutdown();

    # shutdown - domino-effect from upper to lower classes
    $self->lower_layer() && $self->lower_layer()->shutdown();
}


=head1 INHERITABLE METHODS

These are all abstract methods that have to be implemented in all subclasses.
They should not be, however, called directly.

=head2 on_init

Provide some basic initialization. This is called at object creation time.

=cut
sub on_init : Abstract;


=head2 on_shutdown

Provide the shutdown/cleaning operations.

=cut
sub on_shutdown : Abstract;


=head2 on_retrieve

Each layer will define through this method the specific behaviour that the layer
provides in regard with the data that is incoming from the peer.

=cut
sub on_retrieve : Abstract;


=head2 on_send

All layer must define in here the specific behaviour that is to be run whenever
data is sent to the peer.

=cut
sub on_send : Abstract;


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
