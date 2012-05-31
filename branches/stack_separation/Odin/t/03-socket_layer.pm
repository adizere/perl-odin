use strict;
use warnings;

use Test::More tests => 23;
use Test::Exception;
use Test::MockModule;
use Test::File;

use File::Temp ();


my $class_name = 'Odin::ProtocolStack::Layer::Socket';

use_ok( $class_name );

# inheritance
isa_ok( $class_name, 'Odin::ProtocolStack::Layer' );

# class / object methods
can_ok( $class_name, 'new' );
can_ok( $class_name, 'retrieve' );
can_ok( $class_name, 'send' );
can_ok( $class_name, 'shutdown' );


# inherited methods - should be overwritten
can_ok( $class_name, 'on_init' );
can_ok( $class_name, 'on_retrieve' );
can_ok( $class_name, 'on_send' );
can_ok( $class_name, 'on_shutdown' );


# inherited object attributes
can_ok( $class_name, 'upper_layer' );
can_ok( $class_name, 'lower_layer' );
can_ok( $class_name, 'protocol_stack' );

my $socket_layer;
dies_ok {
    my $socket_layer = $class_name->new();
} 'Socket initialization without the actual socket.';
is( $socket_layer, undef, 'Layer not initialized unless socket is passed to the constructor.' );


# Here go the send/retrieve tests
# We'll write/read to a file simulating a socket
{
    my $test_message = 'Foo Bar Ceausescu.'x10000;
    my $fname = File::Temp::tempnam( "/tmp/", "odin-socket-test-" . $$ );

    # Redirect STDOUT to the new temporary file
    open FH, '>', $fname or die "Can't open temporary file $fname: $!";

    # Create a mock of the socket that will be passed, writint unto STDOUT
    my $module = new Test::MockModule( 'IO::Socket::SSL' );
    $module->mock( 'new', sub { return bless \*FH, 'IO::Socket::SSL' } );

    my $ssl_mocked = IO::Socket::SSL->new();

    $socket_layer = $class_name->new(
        $ssl_mocked,
    );
    isa_ok( $socket_layer, $class_name );

    # send 3 messages
    foreach ( 0 .. 3 ) {
        $socket_layer->send( $test_message );
    }

    file_exists_ok( $fname );
    file_readable_ok( $fname );
    file_not_empty_ok( $fname );

    close FH;
    open FH, '<', $fname or die "Can't open temporary file $fname: $!";

    foreach( 0 .. 3 ) {
        my $recv = $socket_layer->retrieve();
        is( $recv, $test_message, "Sent and received ok" );
    }

    # tidy
    $socket_layer->shutdown(); # closes the FH
    unlink $test_message;
}
