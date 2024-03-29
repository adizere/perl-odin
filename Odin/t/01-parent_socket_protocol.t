use strict;
use warnings;

use Test::More 'no_plan';

###
# Parent
my $class_name = 'Odin::ProtocolStack::Parent::Socket';
use_ok( $class_name );
can_ok( $class_name, 'new' );
can_ok( $class_name, 'shutdown' );

my $socket_proto = $class_name->new();
isa_ok( $socket_proto, $class_name );
can_ok( $socket_proto, 'accept' );


# making sure accept() doesn't croak
if ( my $pid = fork() ) {
    # parent

    use Odin::Conf qw( $conf );

    # fire up a Client to connect..
    my $sock = IO::Socket::SSL->new(
        PeerAddr => 'localhost',
        PeerPort => $conf->{socket}->{port},
        Proto    => 'tcp',
    );
    ok( defined $sock, 'Client connection through localhost.' );

    sleep( 1 );
    kill INT => $pid;

} else {
    # child
    while( 1 ) {
        my $client = $socket_proto->accept();
    }
}
