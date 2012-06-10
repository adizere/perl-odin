use strict;
use warnings;

use Test::More tests => 33;
use Test::Exception;
use Test::MockModule;


my $class_name = 'Odin::ProtocolStack::Layer::Messaging';

use_ok( $class_name );

# inheritance
isa_ok( $class_name, 'Odin::ProtocolStack::Layer' );

# object attributes
can_ok( $class_name, 'upper_layer' );
can_ok( $class_name, 'lower_layer' );
can_ok( $class_name, 'protocol_stack' );

# class / object methods
can_ok( $class_name, 'new' );
can_ok( $class_name, 'retrieve' );
can_ok( $class_name, 'send' );
can_ok( $class_name, 'shutdown' );


# inherited methods - should be overriden
can_ok( $class_name, 'on_init' );
can_ok( $class_name, 'on_retrieve' );
can_ok( $class_name, 'on_send' );
can_ok( $class_name, 'on_shutdown' );


# Methods belonging to Messaging layer
can_ok( $class_name, 'message_class' );


# Object construction - no message class
my $msg_layer;
dies_ok {
    $msg_layer = $class_name->new();
} 'Messaging layer init. without the class of the messages.';

# bogus nonexisting message class
dies_ok {
    $msg_layer = $class_name->new(
        'Odin::ProtocolStack::Message::BogusFooClass',
    );
} 'Messaging layer init. with a bogus message class name.';

# existing but invalid message class
dies_ok {
    $msg_layer = $class_name->new(
        'Odin::ProtocolStack::Resource',
    );
} 'Messaging layer init. with an invalid message class name.';

# now in hashref form.. same invalid class
dies_ok {
    $msg_layer = $class_name->new(
        {
            message_class => 'Odin::ProtocolStack::Resource',
        }
    );
} 'Messaging layer init. with an invalid message class name.';

# valid message class & proper initialization
my $message_class = 'Odin::ProtocolStack::Message::JSONEncoded';
$msg_layer = $class_name->new(
    {
        message_class => $message_class,
    },
);
isa_ok( $msg_layer, $class_name );


# sending
throws_ok {
    $msg_layer->send( 'Test_message' );
} qr/Invalid type of message passed/, 'Trying to send raw data';

throws_ok {
    $msg_layer->send( bless {}, 'Odin::Const' );
} qr/Invalid type of message passed/, 'Trying to a message of invalid type.';

# valid sending now
use_ok( $message_class );
my $result = $msg_layer->send( $message_class->new() );
ok( length ( $result ) > 0, 'Message was successfully prepared.' );

my $serialized = $message_class->new()->serialize();
is( $result, $serialized, 'Message was serialized ok.' );


# simulate the retrieval, mock the lower (socket) layer
my $lower_layer_name = 'Odin::ProtocolStack::Layer::Socket';
use_ok( $lower_layer_name );

my $will_retrieve = $message_class->new(
    {
        resource => 'Foo',
        operation => 'Bar',
        metadata => 'Aqua',
        data => 'Devel',
    }
)->serialize();

my $module = new Test::MockModule( $lower_layer_name );
$module->mock( 'new', sub { return bless {}, $lower_layer_name } );
$module->mock( 'on_retrieve', sub { return $will_retrieve } ); # returns and empty serialized message

$msg_layer->lower_layer( $lower_layer_name->new() );
my $retrieved = $msg_layer->retrieve();
can_ok( $retrieved, 'resource' );
can_ok( $retrieved, 'operation' );
can_ok( $retrieved, 'metadata' );
can_ok( $retrieved, 'data' );
is( $retrieved->resource(), 'Foo', 'Retrieved result - resource ok' );
is( $retrieved->operation(), 'Bar', 'Retrieved result - operation ok' );
is( $retrieved->metadata(), 'Aqua', 'Retrieved result - metadata ok' );
is( $retrieved->data(), 'Devel', 'Retrieved result - data ok' );
