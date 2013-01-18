#!/usr/bin/env perl

use strict;
use warnings;

use IO::Socket::SSL;
use Socket;


my $socket = new IO::Socket::SSL(
        Listen => 10,
        ReuseAddr => 1,
        LocalPort => '55555',
        Timeout => 100,
        Blocking => 0,
        SSL_cipher_list => '-LOW:-MEDIUM:HIGH',
        SSL_cert_file => "/projects/captain-awesome/SSS/resources/ca/certs/aws.server.crt",
        SSL_key_file => "/projects/captain-awesome/SSS/resources/ca/private/aws.server.key",
        SSL_ca_file => "/projects/captain-awesome/SSS/resources/ca/certs/aws.ca.crt",
        SSL_verify_mode => 0x01,
);

if ( ! $socket ) {
    die "Error creating listening socket. Error:\n" . IO::Socket::SSL::errstr;
}

my ( $client, $peer_addr, $peer_port );

while( ( $client, $peer_addr, $peer_port ) = _accept() ) {

    printf( "Got a connection from: " . $peer_addr . ":" . $peer_port . "\n" );
    _fork_for_client( $client, $peer_addr, $peer_port );

    # the parent doesn't need to keep the client socket open
    $client->close( SSL_no_shutdown => 1 ) if $client;
}



sub _accept {

ACCEPT:
    my $client_socket = $socket->accept();

    if ( ! $client_socket ) {

        printf( "Accept returned with no socket: %s.\n", $! );

        sleep( 1 );

        goto ACCEPT;
    }

    my $ip = inet_ntoa( $client_socket->peeraddr() );
    my $port = $client_socket->peerport();

    printf( "Got a connection from: " . $ip . ":" . $port . "\n" );

    return ( $client_socket, $ip, $port );
}


sub _fork_for_client {
    my ( $client_socket, $caddr, $cport ) = @_;

    printf("Forking for port: %d", $cport);

FORK:
    my $pid = fork();

    if ( ! defined $pid ) {
        printf( "Fatal: Could not fork()! Retrying in " . 1 . "seconds\n" );

        # sleep, maybe some resources will become available and we can fork eventually
        sleep( 1 );

        # give it another try, avoid deep recursion through goto
        goto FORK;
    } elsif ( $pid ) {
        printf( "Spawned child handling process with PID: $pid\n" );
        return 1;
    }

    printf("[%d] Child area.. sleeping 5 seconds.\n", $$);
    sleep(5);
    printf("[%d] Done", $$);
    exit(1);
}
