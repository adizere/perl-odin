package Odin::ProtocolStack::Message::JSONEncoded;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Message::JSONEncoded

=head1 DESCRIPTION

This class defines the Messages as sent and received in the form of the JSON-encoded
data.

The format defined by B<Odin::ProtocolStack::Message> is respected here, and no
other properties are set. This means that a message is characterized by 4 attributes:
    - resource
    - operation
    - metadata
    - data

These attributes can be whatever type of data that supported by JSON Encoding:
strings, hashref, arrayref - basically, any primitive perl data type.

=cut

use base qw( Odin::ProtocolStack::Message );


use Carp;
use JSON;


# Needed for encoding / decoding
my $encoder = undef;


=head1 Inherited class members

=head2 message_separator

The messages_separator is defined as the character '\n'.

=cut
__PACKAGE__->message_separator( '\n' ); # newline is escaped by JSON encoding, so it's safe to use


=head2 resource, operation, metadata, data

This members define the content of the message.
Initially empty.

=head1 Inherited implemented methods

=head2 init

Called from super class, new() method.

=cut
sub init {
    my $self = shift();

    $encoder = JSON->new->allow_nonref;

    return $self;
}


=head2 serialize

Uses the JSON module to serialize the properties of the calling object.
Returns a string.

=cut
sub serialize {
    my $self = shift();

    $self->serialized_message() && return $self->serialized_message();

    my $res;
    foreach my $attribute ( qw( resource operation metadata data ) ){
        $res->{$attribute} = $self->$attribute();
    }

    return $self->serialized_message( $encoder->encode( $res ) );
}


=head2 deserialize

Uses the JSON module to deserialize the serialized_message property of the calling object.
Sets the corresponding properties as they were encoded inside serialized_message.

=cut
sub deserialize {
    my $self = shift();

    $self->serialized_message() || croak "serialized_message is not set for this object. Cannot deserialize an empty message.";

    my $res = $encoder->decode( $self->serialized_message() );
        foreach my $attribute ( qw( resource operation metadata data ) ){
        $self->$attribute( $res->{$attribute} );
    }
}

1;
