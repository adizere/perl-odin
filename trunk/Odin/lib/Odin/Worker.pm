package Odin::Worker;

use strict;
use warnings;

=head1 NAME

Odin::Worker - Basic worker

=head1 DESCRIPTION

Base class that defines the interface implemented by the module workers.

A Worker is the basic logical element that runs.
It can be defined by either one of:

- Odin::Worker::Parent
- Odin::Worker::Child

=cut

use base qw( Odin Class::Accessor::Grouped );

__PACKAGE__->mk_group_accessors( inherited => qw( protocol_stack ) );


sub new {
    my $class = shift();

    my $self = {};
    bless $self, $class;

    $self->_init( @_ );

    return $self;
}


sub start {
    my $self = shift();

    $self->_install_signal_handlers();
    $self->_run();
}


=head1 STUB METHODS

These should be overwritten in each subclasses, based on what behaviour is needed.

=head2 _init

Called when a new object is created, from the constructor (new()).

=cut
sub _init {
    return;
}

=head2 _install_signal_handlers

First method called from start(), just before _run().

Workers usually run() until they are told to stop explicitely by the use
of signaling.

=cut
sub _install_signal_handlers {
    return;
}

=head2 _run

Called from start().

Basically, it should never return unless a signal is caught.

=cut
sub _run {
    return;
}

1;
