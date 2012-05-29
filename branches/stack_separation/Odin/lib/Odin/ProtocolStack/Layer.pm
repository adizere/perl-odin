package Odin::ProtocolStack::Layer;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Layer

=head1 DESCRIPTION

Abstract class that holds the basic methods needed by the all protocol layers defined in
this framework.

=cut

use base qw( Odin::ProtocolStack::ProtocolClass );

use Attribute::Abstract;


sub new {
    my $class = shift();

    my $self = {};
    bless $self, $class;

    warn "Package: " . __PACKAGE__;

    $self->_init( @_ );



    return $self;
}


sub _init : Abstract;

sub shutdown : Abstract;

sub retrieve : Abstract;

sub sent : Abstract;

1;
