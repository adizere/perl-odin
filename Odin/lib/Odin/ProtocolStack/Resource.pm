package Odin::ProtocolStack::Resource;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Resource

=head1 DESCRIPTION

Abstract class that represents the resources exposed and handled in the
client-server exchanged messages.

=cut


use base qw( Odin::ProtocolStack::ProtocolClass );


use Carp;


__PACKAGE__->mk_group_accessors( inherited => qw( resource_name ) );

# default name: not defined
__PACKAGE__->resource_name( undef );


sub new {
    my $class = shift();

    my $self = {};
    bless $self, $class;

    return $self;
}


sub run {
    my $self = shift();
    my $op_name = shift();
    my $msg = shift();

    unless( $msg ) {
        croak "No message was passed to " . ref( $self ) . "->run()";
    }
    unless( $op_name && $self->can( $op_name ) ) {
        croak "The requested operation [$op_name] is not defined by " . ref( $self );
    }

    return $self->$op_name( $msg );
}


1;
