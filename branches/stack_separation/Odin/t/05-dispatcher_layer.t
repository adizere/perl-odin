use strict;
use warnings;

use Test::More 'no_plan';


my $class_name = 'Odin::ProtocolStack::Layer::Dispatcher';

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


my $dispatcher_layer = $class_name->new();
isa_ok( $dispatcher_layer, $class_name );
