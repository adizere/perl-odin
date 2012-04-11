use strict;
use warnings;

use Test::More 'no_plan';

###
# Child Protocols

my $base_class_name = 'Odin::ProtocolStack::ChildProtocolLayer';
use_ok( $base_class_name );
can_ok( $base_class_name, 'new' );
can_ok( $base_class_name, 'shutdown' );

can_ok( $base_class_name, 'to_client' );
can_ok( $base_class_name, 'from_client' );

foreach my $layer ( qw(
        Odin::ProtocolStack::Child::Socket
        Odin::ProtocolStack::Child::Messaging
        Odin::ProtocolStack::Child::Authentication
        Odin::ProtocolStack::Child::ChildLogic
    ) ){

    use_ok( $layer );

    isa_ok( $layer, $base_class_name );

    can_ok( $layer, 'new' );
    can_ok( $layer, '_init' );
    can_ok( $layer, 'shutdown' );

    my $socket_proto = $layer->new();
    isa_ok( $socket_proto, $layer );
}

##
# Each protocol layer ..

# Socket .. no specific methods..

# Messaging..
my $msg_layer = Odin::ProtocolStack::Child::Messaging->new();
can_ok( $msg_layer, 'serialize' );
can_ok( $msg_layer, 'deserialize' );
can_ok( $msg_layer, 'valid_inbound_data' );
can_ok( $msg_layer, 'valid_outbound_data' );


my $auth_layer = Odin::ProtocolStack::Child::Authentication->new();
can_ok( $auth_layer, 'get_credentials' );
can_ok( $auth_layer, 'valid_credentials' );
can_ok( $auth_layer, 'register_client' );

my $child_logic_layer = Odin::ProtocolStack::Child::ChildLogic->new();
can_ok( $child_logic_layer, 'run' );
