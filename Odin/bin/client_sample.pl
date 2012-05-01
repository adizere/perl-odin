#!/usr/bin/env perl

use strict;
use warnings;

use IO::Socket::SSL;


my $sock = IO::Socket::SSL->new(
        PeerAddr => 'localhost',
        PeerPort => '443',
        Proto    => 'tcp',
    );

unless( $sock ) {
    warn "Socket creation error: " . $! . "; " . IO::Socket::SSL::errstr();
    exit;
}
