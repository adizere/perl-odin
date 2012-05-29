use strict;
use warnings;

use Test::More 'no_plan';

my $base_class_name = "Odin::Worker";

use_ok( $base_class_name );

can_ok( $base_class_name, 'new' );
can_ok( $base_class_name, 'start' );

# testing the parent
use_ok( 'Odin::Worker::Parent' );
isa_ok( 'Odin::Worker::Parent', $base_class_name );

my $instance = Odin::Worker::Parent->new();
isa_ok( $instance, 'Odin::Worker::Parent' );
foreach my $method ( qw( start protocol_stack ) ) {
    can_ok( $instance, $method );
}

# now test the child..
use_ok( 'Odin::Worker::Child' );
isa_ok( 'Odin::Worker::Child', $base_class_name );

my $child_instance = Odin::Worker::Child->new( {
    client_socket => 'socket simple mock',
} );

