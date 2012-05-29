package Odin::Worker::Parent;

use strict;
use warnings;

use base qw( Odin::Worker );

use Odin::Conf qw( $conf );
use Odin::Worker::Child;
use Odin::ProtocolStack::Parent::Socket;
use Odin::Logger qw( log TRACE INFO CRIT ERROR WARN );

use POSIX ":sys_wait_h";


sub _init {
    my $self = shift();

    $self->protocol_stack(
        Odin::ProtocolStack::Parent::Socket->new()
    );

    # package level shortcut to the stack
    __PACKAGE__->protocol_stack( $self->protocol_stack() );
}


sub _run {
    my $self = shift();

    $self->update_process_name( 'Accepting clients' );

    while( 1 ){
        log( TRACE, "Entered Parent main loop.");

        my $client = $self->protocol_stack()->accept();
        log( INFO, "Got a connection from: " . $client->{ip} . ':' . $client->{port} );

        $self->dispatch_new_child( $client );
    }
}


sub dispatch_new_child {
    my ( $self, $client ) = @_;

    # forking..
    my $pid;
    while( 1 ) {
        $pid = fork();

        if ( ! defined $pid ) {
            log( ERROR, "fork() error: " . $! );
            log( CRIT, "Fatal: Could not fork()! Retrying in " . $conf->{server}->{fork_fail_timeout} . "seconds." );

            # sleep, maybe some resources will become available and we can fork eventually
            sleep( $conf->{server}->{fork_fail_timeout} );

            # give it another try, avoid deep recursion through goto
            next;
        } else {
            # fork() ok
            last;
        }
    }
    if ( $pid > 0 ) {
        # Parent
        log( INFO, "New Child; PID: $pid." );
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

    log( WARN, "[Odin::Parent] Entered the Exit Handler" );

    __PACKAGE__->protocol_stack()->shutdown();

    my $count = kill HUP => -$$;

    log( WARN, "Kill count: " . $count );

    sleep( $conf->{server}->{child_wait_timeout} );

    my $finished;
    do {
        $finished = waitpid( -1, WNOHANG );

        # the OS might automatically reap childs if $finished < 0
        log( INFO, "[parent] Child $finished finished with status: $?" )
            if ( $finished > 0 );
    } while ( $finished > 0 );

    log( INFO, "[Odin::Parent] Exit.");
    exit(0);
}


sub _sigchld_handler {
    # don't overwrite the global $!
    local $!;

    while( (my $pid = waitpid(-1, WNOHANG)) > 0 && WIFEXITED( $? )) {
        log( INFO, sprintf("[parent] Child %u finished with exit status: %u\n", $pid, $? ) );
    }

    # re-set the handler
    $SIG{'CHLD'} = \&_sigchld_handler;
}

1;
