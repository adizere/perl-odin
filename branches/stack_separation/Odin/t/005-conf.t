use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;

use File::Temp ();


my $class_name = 'Odin::ProtocolStack::Configuration';
use_ok( $class_name );

can_ok( $class_name, 'new' );

my $obj = $class_name->new();

isa_ok( $obj, $class_name );
can_ok( $obj, 'conf' );

throws_ok {
    my $r = $obj->conf();
} qr/path to the configuration file/,'Retrieve configuration without the file path.';


my $temp_file = File::Temp::tempnam( "/tmp/", "odin-configuration-test-" . $$ );
throws_ok {
    my $r = $obj->conf( $temp_file );
} qr /not readable/, 'Retrieve configuration without a proper file path.';


# somekind of 'touch'
open( FH, ">", $temp_file ) && close( FH );

dies_ok {
    my $r = $obj->conf( $temp_file );
} 'Retrieve configuration without a proper file.';

unlink $temp_file;


my $proper_conf_file = $ENV{ODIN_HOME} . "conf/protocol_conf.json";
my $r = $obj->conf( $proper_conf_file );
is ( ref $r, 'HASH', "Successfully retrieved the configuration from the file." );
