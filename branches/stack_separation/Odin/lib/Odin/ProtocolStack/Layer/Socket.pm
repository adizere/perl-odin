package Odin::ProtocolStack::Layer::Socket;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Layer::Socket

=head1 DESCRIPTION

The socket layer inside the stack is at the lowest level.
Handles reading (/ writing) from (/to) a given socket that is set at object
creation time.

=cut

use base qw( Odin::ProtocolStack::Layer );


use Carp;
use Time::HiRes; # for sleep in floating seconds

# some package constants ..
use constant {

    SOCKET_SEND_TIMEOUT => 1.0,         # floating value, waiting time (when the out buffer is full) between syswrites
    SOCKET_RETRIEVE_TIMEOUT => 0.01,    # floating value, waiting time between sysreads
    SOCKET_RETRIEVE_POLL_TIMER => 2,   # how many seconds we poll for content

    MESSAGE_HEADER_SEPARATOR => "\n",   # the newline char - separates messages headers from actual messages
};


=head2 isa

Odin::ProtocolStack::Layer


=head2 Inherited object members

=over 5

=item C<upper_layer>

The Layer that sits on top of the Socket is the Messaging.

=item C<lower_layer>

Socket is the lowest, undef.

=item C<protocol_stack>

Object that mediates the access to the whole stack of layers, should be an
Odin::ProtocolStack

=back


=head2 Private object members

=over 5

=item C<_socket>

Socket on which the communication is made.
The socket needs to be passed to the constructor.

=back
=cut
__PACKAGE__->mk_group_accessors( simple => qw( _socket ) );



=head2 Overridden object methods

I<These are private and are called from the superclass, shouldn't be called from
the outside.>

=over 5

=item C<on_init>

Sets the socket.

=cut
sub on_init {
    my $self = shift();
    my $args = shift();

    unless( ref $args eq 'HASH' ) {
        croak "Socket layer initialization needs the parameters in a HASHREF form.";
    }

    my $_socket = $args->{peer_socket} || undef;

    # The actual socket that sits behind this layer
    unless( $_socket ){
        croak "Socket Layer initialization needs the socket for communication.";
    }
    $self->_socket( $_socket );

    return $self;
}


=item C<on_send>

Called from send(), writing to the socket is done here.
The message passed as parameter to send is mandatory and it should be an instance
of the Odin::ProtocolStack::Message class or subclass, serialized.

Returns the number of bytes of the message that was sent.

=cut
sub on_send {
    my $self = shift();
    my $msg = shift();

    my $message_actual_len = length( $msg );

    return 0 unless ( $msg && $message_actual_len > 0 );

    # preparing the message: prepend the length and separation character
    substr( $msg, 0, 0, sprintf( '%d%s', $message_actual_len, MESSAGE_HEADER_SEPARATOR ) );

    my $socket = $self->_socket();

    # Start putting data on the socket
    my $sent = 0;
    my $to_send = length( $msg );
    {
        $sent = syswrite $socket, $msg;
        # EAGAIN or EWOULDBLOCK could pop out here, so make sure $sent doesn't remain 'undef'
        $sent ||= 0;

        my $last_sent = $sent;

        # continue sending
        while( $sent < $to_send ) {
            # let it breathe for a sec.
            sleep( SOCKET_SEND_TIMEOUT );

            # chop the part which was sent
            $msg = unpack( "x$last_sent a$to_send", $msg );

            $last_sent = syswrite $socket, $msg;

            # if client closes without saying anything we get stuck here; check for broken pipe
            if ( $! && $!{EPIPE} ) {
                croak "Broken pipe error received while sending: " . $! . "; Cannot continue.";
            }

            # same case as in the initial syswrite..
            $last_sent ||= 0;
            $sent += $last_sent;
        }
    }

    return $message_actual_len;
}


=item C<on_retrieve>

Called from retrieve(), reading from the socket is done here, in a non-blocking
manner. Maximum time that it polls for data is specified as a package level constant: SOCKET_RETRIEVE_POLL_TIMER.
Two possible return values:

* An empty string - the polling time was reached without any complete message arriving.
* The serialized messaged sent from the peer.

TODO: Make the maximum polling time dynamically adjustable.

=cut
sub on_retrieve {
    my $self = shift();

    my $socket = $self->_socket();
    my $separator = MESSAGE_HEADER_SEPARATOR;

    my $max_time = time() + SOCKET_RETRIEVE_POLL_TIMER;
    my $now;

    # geting the length ..
    my $total_length = '';
    while( 1 ) {
        my $char;
        my $status = sysread( $socket, $char, 1 );
        if ( defined $status && $status > 0) {
            if ( $char eq $separator) {
                last;
            }
            $total_length .= $char;

        } elsif ( ! defined $status && $! ) {
            croak "Error reading from socket: $!";
        }

        # check if timer didn't expired
        $now = time();
        if ( $now > $max_time ){
            # timed-out .. exit
            return '';
        }

        sleep( SOCKET_RETRIEVE_TIMEOUT );
    }

    unless( $total_length =~ /^\d+$/ && $total_length > 0 ) {
        carp "Invalid length received.";
        return '';
    }

    # geting the data ..
    my $got_length = 0;
    my ( $last_got, $got ) = ( '', '' );

    while ( $got_length < $total_length ) {
        my $status = sysread( $socket, $last_got, $total_length - $got_length );

        if ( defined $status && $status > 0 ) {
            $got_length += $status;
            $got .= $last_got;

        } elsif ( ! defined $status && $! ) {
            croak "Error reading from socket: $!";
        }

        $now = time();
        if ( $now > $max_time ){
            # timed-out .. exit
            return '';
        }

        sleep( SOCKET_RETRIEVE_TIMEOUT );
    }

    return $got;
}


=item C<on_shutdown>

Called from shutdown(): closes the socket.

=back
=cut
sub on_shutdown {
    my $self = shift();

    close ( $self->_socket() );
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
