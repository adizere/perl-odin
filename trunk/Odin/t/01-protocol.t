use strict;
use warnings;

use Test::More 'no_plan';

###
# Parent
my $class_name = 'Odin::ProtocolStack::Parent::SocketProtocol';
use_ok( $class_name );
can_ok( $class_name, 'new' );
can_ok( $class_name, 'shutdown' );

my $socket_proto = $class_name->new();
isa_ok( $socket_proto, $class_name );
can_ok( $socket_proto, 'accept' );
