package Odin::Worker::Child;

use strict;
use warnings;

use base qw( Odin::Worker );

use Carp;


__PACKAGE__->mk_group_accessors( simple => qw( peer_ip peer_port ) );


sub _init {
    my ( $self, $args ) = @_;

    unless ( $args && $args->{client_socket} ){
        print( "Child Worker cannot instantiate without the peer socket..\n" );
        croak "Invalid call to " . ref( $self ) . "->new(): need the peer socket.";
    }

    $self->peer_ip( $args->{ip} );
    $self->peer_port( $args->{port} );
}


sub _run {
    my $self = shift();

    $self->update_process_name( 'Serving client [' . $self->peer_ip() . ":" . $self->peer_port() . "]" );

    $self->_handle_client();

    exit(0);
}


sub _install_signal_handlers {

    $SIG{'INT'} = \&_exit_handler;
    $SIG{__DIE__} = \&_exit_handler;
    $SIG{'HUP'} = \&_exit_handler;
}


sub _exit_handler {
    # Basic safety measures
    $SIG{'INT'} = $SIG{'HUP'} = $SIG{__DIE__} = 'IGNORE';

    print( "[Odin::Child] Entered the Exit Handler.\n" );

    __PACKAGE__->protocol_stack()->shutdown();

    print( "[Odin::Child] Exit..\n");

    exit(0);
}


=head2 instantiate_stack

    $child->instantiate_stack( CLIENT_SOCKET );


=head2 handle_client

    $child->handle_client();

B<Description:>

Method for starting up the actual client-server communication.
No logic is kept here.

All the logic is pertained inside the ProtocolStack* classes, accessed through
our $self->protocol_stack() object.


=cut
sub _handle_client {
    my $self = shift();

    print "Handle client started.\n";
}


1;
