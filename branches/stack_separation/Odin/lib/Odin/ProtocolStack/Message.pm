package Odin::ProtocolStack::Message;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Message

=head1 DESCRIPTION

Abstract class providing basic functionalities needed by the classes that inherit
from here.

Objects read and sent on the socket will be instances of subclasses of this class.

=cut

use base qw( Odin::ProtocolStack::ProtocolClass );


use Attribute::Abstract;


=head1 SYNOPSIS

Messages can be instantiated in multiple ways:

1. Using data that was received on the socked, which is serialized:

    use Odin::ProtocolStack::Message::JSONEncoded;

    # assume that $msg_raw holds serialized, received data
    my $msg = Odin::ProtocolStack::Message::JSONEncoded->new(
        {
            serialized_message => $msg_raw,
        }
    );

    # Now deserialize
    $msg->deserialize();

    # and use ..
    print $msg->resource(), $msg->operation(), $msg->metadata(), $msg->data();

2. When creating a new message, preparing it to be sent ..

    use Odin::ProtocolStack::Message::JSONEncoded;

    my $msg = Odin::ProtocolStack::Message::JSONEncoded->new(
        {
            operation => $msg_raw,
        }
    );

=head1 Inheritable class members

=head2 message_separator

Separator character that is sent on the socket between consecutive messages.

Set/Get at the class level:

    # New package that defines a Message, inherits from Odin::ProtocolStack::Message
    package XMLSerializedExample;

    use base 'Odin::ProtocolStack::Message';

    __PACKAGE__->message_separator( '%' ); # XML reserved character, will never be part of a message

=cut
__PACKAGE__->mk_group_accessors( inherited => 'message_separator' );


=head2 resource, operation, metadata, data

This members define the content of the message.

Set/Get at the object level:

    use XMLSerializedExample;

    my $msg = XMLSerializedExample->new();
    $msg->resource( 'account' );
    $msg->operation( 'delete' );
    $msg->metadata( 'No longer needed' );
    $msg->data( '<account id="45"\>' );

    # Now the message can be sent on the socket..

B<Odin::ProtocolStack::Message> inherits from B<Class::Accessor::Grouped>, thus all
subclasses of this class will also be sublasses of B<Class::Accessor::Grouped>,
other members should be added through the mechanism provide by this package, e.g:

    # create accessors for various attributes of a subclass
    __PACKAGE__->mk_group_accessors(simple => qw( username password ));

=cut
__PACKAGE__->mk_group_accessors( simple => qw( resource operation metadata data ) );


=head2 serialized_message

The message in its serialized form.

Set/Get at the object level.

B<Warning>: If you set this property for an object that any subsequent call
to I<serialize()> will return the value manually set by you.

=cut
__PACKAGE__->mk_group_accessors( simple => 'serialized_message' );


=head1 Inheritable methods

=head2 new

Basic constructor.
Calls init(@_) for specific message initialization.

=cut
sub new {
    my $class = shift();
    my $args = shift();

    my $self = {};
    bless $self, $class;

    # initial values were provided
    if ( defined $args && ref( $args ) eq 'HASH' ){
        foreach my $attr ( qw( serialized_message resource operation metadata data ) ) {
            $self->$attr( defined $args->{$attr} ? $args->{$attr} : "" );
        }
    } else {
        # no initial values sent, set everything to empy string
        foreach my $attr ( qw( serialized_message resource operation metadata data ) ) {
            $self->$attr( "" );
        }
    }

    $self->init( $args );

    return $self;
}


=head2 init

Abstract method - for specific object initialization.

B<Parameters:>
All the paramters sent to new() are passed down to this method.

It is I<mandatory> that this method is implemented in all subclases, otherwise
object construction fails.

=cut
sub init: Abstract;


=head2 serialize

Abstract method - subclasses should provide through this method the specific
serialization (encoding) of the contained data.

B<Parameters:>
None.

B<Returns:>
The serialized data.

=cut
sub serialize: Abstract;


=head2 deserialize

Abstract method - subclasses should provide through this method the specific
deserialization (decoding) of the serialized_data.

B<Parameters:>
None.

B<Returns:>
The serialized data.

=cut
sub deserialize: Abstract;


=head1 CAVEATS

The method I<serialize()> will simply return the I<serialized_message> property as long this
is set. So, if you meddle with that property and then modify the one of the other
attributes (i.e. I<resource>, I<operation>, I<metadata>, I<data>), the call to I<serialize()>
will not return what you think it does.

# TODO
This is also a TODO.

=cut

1;
