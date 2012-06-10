package Odin::ProtocolStack::Resource;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Resource

=head1 SYNOPSIS

    package MyApplication::Resource::ResourceX;

    use base qw( Odin::ProtocolStack::Resource );

    use Odin::ProtocolStack::Message::JSONEncoded;

    __PACKAGE__->resource_name( 'resource_x' );

    # define some operations that can be done on this resource
    sub operation_y {
        my $self = shift();
        my $msg = shift();

        print "operation_y was invoked from the Dispatcher.";

        if ( $msg->metadata() eq 'FOO' ) {
            # ..
        } elsif ( $msg->metadata() eq 'BAR' ) {
            # ..
        } else {
            # ..
        }

        # reply to the peer, telling him that everythin is ok..
        $self->protocol_stack()->send(
            Odin::ProtocolStack::Message::JSONEncoded->new(
                {
                    resource => 'resource_x',
                    operation => 'operation_y'
                    metadata => 'Acknowledge'
                    data => '',
                }
            )
        );
    }

    # other operations
    1;

=cut

use base qw( Odin::ProtocolStack::ProtocolClass );


use Carp;

=head1 DESCRIPTION

Abstract class that represents the resources exposed and handled in the
client-server exchanged messages.

A Resource can represent anything about which the peer has knowledge of; more
precisely: all the actions (see C<operation> in B<Odin::ProtocolStack::Message>)
that the peer can request from us are done through methods inside Resource classes.

A Message is bound with a specific Resource using:
1. Message C<resource> corresponds to a C<<Resource->resource_name()>>.
2. Message C<operation> corresponds to a B<sub> inside the appropiate Resource.

=head2 isa

Odin::ProtocolStack::ProtocolClass

=head2 Inheritable object members

=over 5

=item C<protocol_stack>

A resource might need access to the protocol stack in order to interact
with the peer. This object should be set at construction time.

=back
=cut

__PACKAGE__->mk_group_accessors( simple => qw( protocol_stack ) );


=head2 Inheritable class members

=over 5

=item C<resource_name>

The name of the resource this class handles.
Used in order to make a correspondance between a Message C<resource> field and
a Resource class.

Should be a string.

=back
=cut
__PACKAGE__->mk_group_accessors( inherited => qw( resource_name ) );

# default name: not defined
__PACKAGE__->resource_name( undef );


=head1 METHODS

=over 4

=item new

    # from inside the protocol_stack
    my $res = MyApplication::Resource::ResourceX->new(
        {
            protocol_stack => $self,
        }
    );

Instantiates the class, creating a new object.
Can optionally receive a hashref argument, with the protocol stack object.

=cut
sub new {
    my $class = shift();
    my $args = shift();

    my $self = {};
    bless $self, $class;

    if ( $args->{protocol_stack} ) {
        $self->protocol_stack( $args->{protocol_stack} );
    }

    return $self;
}


=item run

    $resource->run(
        OPERATION_NAME
        MESSAGE
    );

After receiving a Message, the Dispatcher will search the proper Resource which
should handle that Message. The Resource that is found is instantiated and then
C<run()> is called on it.

Run simply takes the name of the C<operation> which has to be started, and the Message
that triggered this operation.
It will result in calling a method with the same name as the C<operation> name,
passing it the Message.

If no corresponding method is found, it croaks.

=back
=cut
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


=head1 AUTHOR

Adi Seredinschi, C<< <adizere at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Adi Seredinschi.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
