use Test::More tests => 10;

BEGIN {
    # all classes loaded ok
    foreach( qw(
        Odin

        Odin::Worker
        Odin::Worker::Parent
        Odin::Worker::Child

        Odin::ProtocolStack::ProtocolLayer
        Odin::ProtocolStack::ParentProtocolLayer
        Odin::ProtocolStack::ChildProtocolLayer
        Odin::ProtocolStack::Parent::SocketProtocol

        Odin::Conf

        Odin::Logger
    )){
        use_ok( $_ ) || BAIL_OUT "Error loading $_!\n";
    }
}

diag( "Testing Odin $Odin::VERSION, Perl $], $^X" );
