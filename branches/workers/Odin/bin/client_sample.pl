#!/usr/bin/env perl

use strict;
use warnings;

use IO::Socket::SSL;
use POSIX qw( :sys_wait_h );

my $server = "79.125.12.158";
my $sleep_time = 20;


my $count = 20;

while( $count > 0 ){


    my $pid = fork();

    if ($pid){
        printf("Spawned $pid\n");
    } else {

        my $sock = IO::Socket::SSL->new(
                PeerAddr => $server,
                PeerPort => '4566',
                Proto    => 'tcp',
                SSL_startHandshake => 1,
                SSL_cert_file => 'cert.crt',
                SSL_key_file => 'cert.key',
                Blocking => 0,
            );

        unless( $sock ) {
            warn "Socket creation error: " . $! . "; " . IO::Socket::SSL::errstr();
            exit;
        }


        printf("[%d] Connected to $server. Sleeping $sleep_time seconds.\n", $$);
        sleep( $sleep_time );
        printf("[%d] Done.\n", $$);

        exit(1);
    }

    $count--;
}


my $finished;
do {
    $finished = waitpid( -1, WNOHANG );

    # the OS might automatically reap childs if $finished < 0
    warn "[parent] Child $finished finished with status: $?"
        if ( $finished > 0 );
} while ( $finished > 0 );
