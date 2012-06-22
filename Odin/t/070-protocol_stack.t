use strict;
use warnings;

use Test::More tests => 18;
use Test::Exception;
use Test::MockModule;
use File::Temp ();


my $class_name = 'Odin::ProtocolStack';
my $message_class_name = 'Odin::ProtocolStack::Message::JSONEncoded';


use_ok( $class_name );
use_ok( $message_class_name );

# inheritance
isa_ok( $class_name, 'Odin::ProtocolStack::ProtocolClass' );

# class / object methods
can_ok( $class_name, 'new' );
can_ok( $class_name, '_layers' );
can_ok( $class_name, 'register_resource' );


my $stack;

dies_ok {
    $stack = $class_name->new();
} 'Initialization without all the parameters.';
is( $stack, undef, 'Improper object creation' );


my $conf_file = $ENV{ODIN_HOME} . "conf/protocol_conf.json";

dies_ok {
    $stack = $class_name->new(
        {
            conf_path => $conf_file,
        }
    );
} 'Improper initialization, without the parameters specified in the configuration file.';

$stack = $class_name->new(
    {
        peer_socket => 'not a socket, but should work anyhow',
        conf_path => $conf_file,
    },
);
isa_ok( $stack, $class_name );


can_ok( $stack, 'send' );
can_ok( $stack, 'retrieve' );
can_ok( $stack, 'shutdown' );

####
# Test the stack of layers as a whole
# 1. Socket layer - we'll use a file instead of an actual socket
my $fname = File::Temp::tempnam( "/tmp/", "odin-protocol_stack-test-" . $$ );
open FH, '>', $fname or die "Can't open temporary file $fname: $!";

# Create a mock of the socket that will be passed, writing unto the handler (effectively: in the file)
my $module = new Test::MockModule( 'IO::Socket::SSL' );
$module->mock( 'new', sub { return bless \*FH, 'IO::Socket::SSL' } );

my $ssl_mocked = IO::Socket::SSL->new();

$stack = $class_name->new(
    {
        peer_socket => $ssl_mocked,
        conf_path => $conf_file,
    },
);
isa_ok( $stack, $class_name );

my $message = $message_class_name->new(
    {
        data => 'developers!!!',
        resource => "resX",
        operation => "opX",
    }
);

# send 3 messages
foreach ( 0 .. 3 ) {
    $stack->send( $message );
}

# reset the handler..
close FH;
open FH, '<', $fname or die "Can't open temporary file $fname: $!";

# retrieve the previously sent messages
foreach( 0 .. 3 ) {
    throws_ok {
        my $recv = $stack->retrieve();
    } qr/No resource is registered with this name: resX/, 'Dispatcher should not find the requested resource (resX).';
}


unlink $fname;
