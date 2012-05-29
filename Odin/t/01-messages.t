use strict;
use warnings;

use Test::More 'no_plan';
use Test::Deep;
use Test::Exception;


###
# Base Class
my $class_name = 'Odin::ProtocolStack::Message';

use_ok( $class_name );

can_ok( $class_name, 'new' );
can_ok( $class_name, 'message_separator' );

###
# Subclass of specific type
my $subclass_name = 'Odin::ProtocolStack::Message::JSONEncoded';

use_ok( $subclass_name );

can_ok( $subclass_name, 'new' );
can_ok( $subclass_name, 'message_separator' );

my $separator = $subclass_name->message_separator();
ok ( defined $separator && length $separator > 0, 'Message separator specified in subclass.' );

my $obj = $subclass_name->new();
isa_ok( $obj, $subclass_name );

# Initially empty attributes
foreach my $attribute ( qw( resource operation metadata data serialized_message ) ) {
    my $atr = $obj->$attribute();
    is( $atr, '', 'Initial empty attribute.' );

    my $attr_set_test = "test for " . $attribute;

    $obj->$attribute( $attr_set_test );
    $atr = $obj->$attribute();
    is( $atr, $attr_set_test, 'Attribute set test.' );
}


$obj = $subclass_name->new(
    {
        resource => 'test',
        operation => 'test',
        metadata => 'test',
        data => 'test',
        serialized_message => 'test',
    }
);
isa_ok( $obj, $subclass_name );

# Initially set attributes
foreach my $attribute ( qw( resource operation metadata data serialized_message ) ) {
    my $atr = $obj->$attribute();
    is( $atr, 'test', 'Initial set attribute.' );

    my $attr_set_test = "test for " . $attribute;

    $obj->$attribute( $attr_set_test );
    $atr = $obj->$attribute();
    is( $atr, $attr_set_test, 'Attribute set test.' );
}


# Serialization
my $data_t = {
            first => [ 'one', 'two', 'three' ],
            second => "data!",
};

$obj = $subclass_name->new(
    {
        resource => 'resource x',
        operation => 'operation y',
        metadata => 'medata m',
        data => $data_t,
    }
);
isa_ok( $obj, $subclass_name );

my $serialized_res = $obj->serialize();

$obj->data( 'empty' );
cmp_deeply( 'empty', $obj->data(), 'Deserialization ok' );

$obj->deserialize();
# Now the data should be back to initial hashref, kept in $data_t
cmp_deeply( $data_t, $obj->data(), 'Deserialization ok' );


# Now some exception in (de)serialization
$obj = $subclass_name->new(
    {
        resource => 'resource x',
        operation => 'operation y',
        metadata => 'medata m',
        data => $data_t,
    }
);

dies_ok{
    $obj->deserialize();
} 'Deserialization without initial serialized object.';


