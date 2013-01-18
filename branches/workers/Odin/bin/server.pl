#!/usr/bin/env perl

use strict;
use warnings;

use Odin::Worker::Parent;


my $pstack = Odin::ProtocolStack->new();


my $msg = Odin::Message->new();

$msg->header(
    {
        operation => 'bla bla',
    }
);

$msg->content(
    {
        data => 'this',
        metadata => {
            1 => 'that',
            2 => [
                'some', 'other', 'ones'
            ],
        }
    }
);


$pstack->write_message( $msg );

my $reply = $pstack->read_message();
