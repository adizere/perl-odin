use Test::More tests => 14;

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

        Odin::ProtocolStack::Parent::Socket

        Odin::ProtocolStack::Child::Socket
        Odin::ProtocolStack::Child::Messaging
        Odin::ProtocolStack::Child::Authentication
        Odin::ProtocolStack::Child::ChildLogic

        Odin::Conf

        Odin::Logger
    )){
        use_ok( $_ ) || BAIL_OUT "Error loading $_!\n";
    }
}

diag( "Testing Odin $Odin::VERSION, Perl $], $^X" );
