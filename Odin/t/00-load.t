use Test::More tests => 4;

use strict;
use warnings;


BEGIN {
    # all classes loaded ok

    foreach( qw(
        Odin

        Odin::Worker
        Odin::Worker::Parent
        Odin::Worker::Child
    )){
        use_ok( $_ ) || BAIL_OUT "Error loading $_!\n";
    }
}

diag( "Testing Odin $Odin::VERSION, Perl $], $^X" );
