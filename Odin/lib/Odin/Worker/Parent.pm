package Odin::Worker::Parent;

use strict;
use warnings;

use base qw( Odin::Worker );


use Odin::Worker::Child;

use POSIX ":sys_wait_h";
use Socket;


use constant {
    FORK_FAIL_TIMEOUT => 1,
    CHILD_WAIT_TIMEOUT => 1,
};

sub _init {
    my ( $self, $socket ) = @_;

    unless( $socket ) {
        warn "Now socket provided for Parent.\n";
        exit;
    }

    $self->protocol_stack( $socket );

    # package level shortcut to the stack
    __PACKAGE__->protocol_stack( $self->protocol_stack() );
}


sub _run {
    my $self = shift();

    $self->update_process_name( 'Accepting clients' );

    while( 1 ){
        print( "Entered Parent main loop..\n");

        my $client = $self->_accept();
        print( "Got a connection from: " . $client->{ip} . ':' . $client->{port} . "\n");

        $self->dispatch_new_child( $client );

        $client->{socket}->close( SSL_no_shutdown => 1 ) if ( $client->{socket} );
    }
}


sub dispatch_new_child {
    my ( $self, $client ) = @_;

    # forking..
    my $pid;
    while( 1 ) {
        $pid = fork();

        if ( ! defined $pid ) {
            print( "fork() error: " . $! ."\n" );
            print( "Fatal: Could not fork()! Retrying in " . FORK_FAIL_TIMEOUT . "seconds..\n" );

            # sleep, maybe some resources will become available and we can fork eventually
            sleep( FORK_FAIL_TIMEOUT );

            # give it another try, avoid deep recursion through goto
            next;
        } else {
            # fork() ok
            last;
        }
    }
    if ( $pid > 0 ) {
        # Parent
        print( "New Child; PID: $pid..\n" );
        return;
    }

    # and dispatching..
    my $child = Odin::Worker::Child->new( {
        client_socket => $client->{socket},
        ip => $client->{ip},
        port => $client->{port},
    } )->start();
}


sub _install_signal_handlers {

    $SIG{'INT'} = \&_exit_handler;
    $SIG{__DIE__} = \&_exit_handler;
    $SIG{'CHLD'} = \&_sigchld_handler;
}


sub _exit_handler {
    # Basic safety measures
    $SIG{'INT'} = $SIG{'CHLD'} = $SIG{'HUP'} = 'IGNORE';

    print( "[Odin::Parent] Entered the Exit Handler.\n" );

    __PACKAGE__->protocol_stack()->shutdown( SSL_no_shutdown => 0, SSL_fast_shutdown => 0, SSL_ctx_free => 1 );

    my $count = kill HUP => -$$;

    print( "Kill count: " . $count . "\n" );

    sleep( CHILD_WAIT_TIMEOUT );

    my $finished;
    do {
        $finished = waitpid( -1, WNOHANG );

        # the OS might automatically reap childs if $finished < 0
        print( "[parent] Child $finished finished with status: $?" )
            if ( $finished > 0 );
    } while ( $finished > 0 );

    print( "[Odin::Parent] Exit..\n");
    exit(0);
}


sub _sigchld_handler {
    # don't overwrite the global $!
    local $!;

    while( (my $pid = waitpid(-1, WNOHANG)) > 0 && WIFEXITED( $? )) {
        print( sprintf("[parent] Child %u finished with exit status: %u\n", $pid, $? ) );
    }

    # re-set the handler
    $SIG{'CHLD'} = \&_sigchld_handler;
}


sub _accept {
    my $self = shift();

ACCEPT:
    my $client_socket = $self->protocol_stack()->accept();

    if ( ! $client_socket ) {

        printf( "Accept returned with no socket: %s.\n", $! );

        sleep( 1 );

        goto ACCEPT;
    }

    my $ip = inet_ntoa( $client_socket->peeraddr() );
    my $port = $client_socket->peerport();

    printf( "Got a connection from: " . $ip . ":" . $port . "\n" );

    return { 
        socket => $client_socket,
        ip => $ip, 
        port => $port 
    };
}

1;
