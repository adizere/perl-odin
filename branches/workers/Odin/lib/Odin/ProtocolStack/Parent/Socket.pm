package Odin::ProtocolStack::Parent::Socket;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Parent::Socket

=head1 DESCRIPTION

Socket-level protocol interface for interaction with between a client and the Parent
workers.

=cut

use base qw( Odin::ProtocolStack::ParentProtocolLayer );

use Odin::Conf qw( $conf );
use Odin::Logger qw( log CRIT );

use IO::Socket::SSL;
use Carp;
use Socket;


__PACKAGE__->mk_group_accessors( simple => qw( socket ) );


sub _init {
    my $self = shift();

    # instantiate the socket
    $self->socket(
        IO::Socket::SSL->new(
            Listen => $conf->{socket}->{listen_queue},
            ReuseAddr => $conf->{socket}->{reuse_address},
            LocalPort => $conf->{socket}->{port},
            Timeout => $conf->{socket}->{timeout},
            Blocking => $conf->{socket}->{blocking},
            SSL_cipher_list => '-LOW:-MEDIUM:HIGH',
            SSL_key_file => $conf->{server}->{pk_file},
            SSL_cert_file => $conf->{server}->{cert_file},
            SSL_ca_file => $conf->{CA}->{root_dir} . $conf->{CA}->{cert_file},
            SSL_verify_mode => $conf->{socket}->{verify_mode},
        )
    );

    unless( $self->socket() ) {
        log( CRIT, "Error creating socket: " . $! );

        if ( $!{EACCES} && $conf->{socket}->{port} eq '443' ) {
            log( CRIT, "Error: Listening on 443 needs root priviledges." );
        }
        croak IO::Socket::SSL::errstr;
    }
}


sub accept {
    my $self = shift();

    my $client_socket;

    while( 1 ){
        $client_socket = $self->socket()->accept();
        last if $client_socket;
        sleep( $conf->{server}->{accept_timeout} );
    }

    return {
        socket => $client_socket,
        ip => inet_ntoa( $client_socket->peeraddr() ),
        port => $client_socket->peerport(),
    };
}


sub shutdown {
    my $self = shift();

    $self->socket() && $self->socket()->close();
}

1;
