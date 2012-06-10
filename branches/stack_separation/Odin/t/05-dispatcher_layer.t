use strict;
use warnings;

use Test::More tests => 23;
use Test::Exception;
use Test::MockModule;
use Test::Deep;

use Odin::ProtocolStack::Configuration qw( $conf );


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


# register some resources..
dies_ok {
    $dispatcher_layer->register_resource( 'Odin::ProtocolStack::Resource' );
} 'Invalid registration of an abstract class - the resource superclass.';

dies_ok {
    $dispatcher_layer->register_resource( 'Odin::ProtocolStack::NonExistentUnknownResourceTest' );
} 'Invalid registration of a non-existent class';

dies_ok {
    $dispatcher_layer->register_resource( 'Odin::ProtocolStack::Configuration' );
} 'Invalid registration of a class that does not inherit from the proper superclass';

{
    # Mock a proper resource
    my $resource_class_name = 'Odin::ProtocolStack::Resource::SimpleResource';
    my $resource_mod_name = $resource_class_name;
    $resource_mod_name =~ s~::~/~g;
    $resource_mod_name .= ".pm";
    $INC{ $resource_mod_name } = 1;

    use_ok( $resource_class_name );

    my $module = new Test::MockModule( $resource_class_name );
    $module->mock( 'new', sub { return bless {}, $resource_class_name } );
    $module->mock( 'resource_name', 'test_name' );
    $module->mock( 'test_operation', sub { return $_[1]; } );

    # make sure the ->isa() verification goes through.. version 1
    #$module->mock( 'isa', sub { if ( $_[1] eq $conf->{resource_superclass} ) { return 1; } return 0; } );

    # make sure the ->isa() verification goes through.. version 2
    # make it inherit from the default resources superclass
    no strict 'refs';

    push @{"$resource_class_name\::ISA"}, $conf->{resource_superclass};

    $dispatcher_layer->register_resource( $resource_class_name );

    # Now that the resource is in place, test the on_retrieve
    # mock the lower layer ..
    my $lower_layer_name = 'Odin::ProtocolStack::Layer::Messaging';
    my $message_class = 'Odin::ProtocolStack::Message::JSONEncoded';
    use_ok( $lower_layer_name );
    use_ok( $message_class );
    my $will_retrieve = $message_class->new(
        {
            resource => 'Foo',
            operation => 'Bar',
            metadata => 'Aqua',
            data => 'Devel',
            serialized_message => 'serializedF',
        });

    my $module2 = new Test::MockModule( $lower_layer_name );
    $module2->mock( 'new', sub { return bless {}, $lower_layer_name } );
    $module2->mock( 'on_retrieve', sub { return $will_retrieve } );

    $dispatcher_layer->lower_layer( $lower_layer_name->new() );

    throws_ok {
        $dispatcher_layer->retrieve();
    } qr/no resource.*name: Foo/i, 'No resource registered with the Dispatcher for name "Foo"';

    # change the resource
    $will_retrieve->resource( 'Bar' );
    throws_ok {
        $dispatcher_layer->retrieve();
    } qr /name: Bar/, 'No resource registered with the Dispatcher for name "Bar"';

    # now a good one.. the one we just defined & registered earlier, with the name 'test_name'
    # and the operation 'test_operation'
    $will_retrieve->resource( 'test_name' );
    $will_retrieve->operation( 'test_operation' );
    my $res = $dispatcher_layer->retrieve(); # should return $_[1], which is the Message
    cmp_deeply( $res, $will_retrieve, 'Dispatching to a mocked resource.' );
}
