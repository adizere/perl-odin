use strict;
use warnings;

use Test::More tests => 4;

use Odin::Worker::Parent;
use Odin::Conf qw( $conf );
use Odin::Logger;
use POSIX qw(setsid);

Odin::Logger->disable(1);

my $parent = Odin::Worker::Parent->new();
isa_ok( $parent, 'Odin::Worker::Parent' );


if ( my $pid = fork() ) {

    # parent
    my $count = 3;
    while( $count-- > 0 ) {
        select undef, undef, undef, 0.030;

        # fire up a Client to connect..
        my $sock = IO::Socket::SSL->new(
            PeerAddr => 'localhost',
            PeerPort => $conf->{socket}->{port},
            Proto    => 'tcp',
        );
        ok( defined $sock, 'Client connection through localhost.' );

        $sock->close();
    }

    sleep( 1 );

    # stop the parent
    kill INT => $pid;

} else {
    # in the child process we fire up the main Server (Parent)
    setsid;
    $parent->start();
}
