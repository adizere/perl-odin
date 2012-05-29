use Test::More tests => 14;

use strict;
use warnings;


BEGIN {
    # all classes load ok

    foreach( qw(
        Odin
        Odin::ProtocolStack

        Odin::ProtocolStack::ProtocolClass
        Odin::ProtocolStack::Layer
        Odin::ProtocolStack::Resource
        Odin::ProtocolStack::Message

        Odin::ProtocolStack::Layer::Socket

        Odin::ProtocolStack::Layer::Messaging

        Odin::ProtocolStack::Layer::Authentication
        Odin::ProtocolStack::Layer::Authentication::Authorization
        Odin::ProtocolStack::Layer::Authentication::Registration

        Odin::ProtocolStack::Layer::Dispatcher

        Odin::ProtocolStack::Message::JSONEncoded;

        Odin::Const
    )){
        use_ok( $_ ) || BAIL_OUT "Error loading $_!\n";
    }
}

diag( "Testing Odin $Odin::VERSION, Perl $], $^X" );
