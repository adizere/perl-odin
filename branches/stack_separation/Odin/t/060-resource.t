use strict;
use warnings;

use Test::More tests => 15;
use Test::MockModule;
use Test::Exception;

use Odin::ProtocolStack::Configuration;

# load the configuration first
my $proper_conf_file = $ENV{ODIN_HOME} . "conf/protocol_conf.json";
my $conf_obj = Odin::ProtocolStack::Configuration->new();
my $conf = $conf_obj->conf( $proper_conf_file );
is ( ref $conf, 'HASH', "Successfully retrieved the configuration from the file." );


my $class_name = 'Odin::ProtocolStack::Resource';

use_ok( $class_name );

# inheritance
isa_ok( $class_name, 'Odin::ProtocolStack::ProtocolClass' );

# class / object methods
can_ok( $class_name, 'new' );
can_ok( $class_name, 'resource_name' );
can_ok( $class_name, 'protocol_stack' );

my $dispatcher_layer = $class_name->new(
    {
        protocol_stack => 'stack'
    }
);
isa_ok( $dispatcher_layer, $class_name );
is( $dispatcher_layer->protocol_stack(), 'stack', 'Object creation and attribute initialization' );

$dispatcher_layer = $class_name->new();
isa_ok( $dispatcher_layer, $class_name );


# Mock a subclass of this, instantiate it and test it
{
    my $subclass_name = 'Odin::ProtocolStack::Resource::ResourceSubclass';
    # make it look as it was already loaded
    my $subclass_mod_name = $subclass_name;
    $subclass_mod_name =~ s~::~/~g;
    $subclass_mod_name .= ".pm";
    $INC{ $subclass_mod_name } = 1;
    no strict 'refs';
    push @{"$subclass_name\::ISA"}, $conf->{resource_superclass};

    use_ok( $subclass_name );

    my $module = new Test::MockModule( $subclass_name );
    $module->mock( 'new', sub { return bless {}, $subclass_name } );
    $module->mock( 'resource_name', 'subclass' );
    $module->mock( 'operation1', sub { return $_[1]; } );

    my $instance = $subclass_name->new();

    isa_ok( $instance, $subclass_name );
    is( $instance->resource_name(), 'subclass', "Instance creation of subclasses of Resource" );

    my $expected_result = {
        Foo => 1,
    };

    dies_ok {
        $instance->run( 'operation1' );
    } 'Requesting an operation without passing any message.';

    my $result = $instance->run( 'operation1', $expected_result );
    is( $result, $expected_result, 'Operation running should return the first argument.' );

    dies_ok {
        $instance->run( 'undefined_operation', $expected_result );
    } 'Requesting an unsupported operation';
}
