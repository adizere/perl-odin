use strict;
use warnings;

use Test::More tests => 9;


my $class_name = 'Odin::ProtocolStack::Layer';

use_ok( $class_name );

# inheritance
isa_ok( $class_name, 'Odin::ProtocolStack::ProtocolClass' );

# object attributes
can_ok( $class_name, 'upper_layer' );
can_ok( $class_name, 'lower_layer' );
can_ok( $class_name, 'protocol_stack' );

# class / object methods
can_ok( $class_name, 'new' );
can_ok( $class_name, 'retrieve' );
can_ok( $class_name, 'send' );
can_ok( $class_name, 'shutdown' );
