use strict;
use warnings;

use Test::More 'no_plan';

my $base_class_name = "Odin::Worker";

use_ok( $base_class_name );

can_ok( $base_class_name, 'new' );
can_ok( $base_class_name, 'start' );

# testing the parent
foreach( qw( Odin::Worker::Parent Odin::Worker::Child ) ) {
    use_ok( $_ );
    isa_ok( $_, $base_class_name );

    my $instance = $_->new();
    isa_ok( $instance, $_ );
    foreach my $method ( qw( start protocol_stack ) ) {
        can_ok( $instance, $method );
    }
}

my $parent = Odin::Worker::Parent->new();
can_ok( $parent, 'dispatch_new_child' );
