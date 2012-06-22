package Odin::ProtocolStack::Configuration;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Configuration - JSON style configuration file loader for parameters that
define the stack.

=head1 SYNOPSIS

    use Odin::ProtocolStack::Configuration;

    my $conf_path = "./conf/protocol_conf.json";

    # Followin 2 statements are equivalent
    my $conf_a = Odin::ProtocolStack::Configuration->new( $conf_path )->conf();
    my $conf_b = Odin::ProtocolStack::Configuration->new()->conf( $conf_path );

    print "The first layer (lowest) is: " . $conf_a->{layers}->{0}->{class};
    print "The second layer is: " . $conf_b->{layers}->{1}->{class};

=cut

use base qw ( Odin::ProtocolStack::ProtocolClass Exporter );


use Carp;
use Config::JSON;

=head1 DESCRIPTION

Various configuration parameters are kept in a JSON structure, loaded and parsed
from an external file.

This module provides access to these parameters through the method B<conf>.

The OO interface might seem an overkill as just 1 method is needed in this class,
but this class should normally only be used from inside the ProtocolStack classes,
so you shouldn't really bother about the stuff that reside here.

The bare minimum anyone would need to know about this is class is that it needs
the path to a JSON file and it returns the de-serialized content of that file.
For an example file see I<conf/protocol_conf.json>.

=head2 isa

Odin::ProtocolStack::ProtocolClass
Exporter

=cut


__PACKAGE__->mk_group_accessors( simple => qw( _path _conf ) );


=head1 METHODS

=over 4

=item new

    my $conf_obj = Odin::ProtocolStack::Configuration->new();
    my $conf_obj = Odin::ProtocolStack::Configuration->new( PATH );

Instantiates the class, returning a new object.

=cut
sub new {
    my $class = shift();

    my $self = {};
    bless $self, $class;

    $self->_path( shift() || '' );

    return $self;
}


=item conf

    my $conf = $conf_obj->conf();
    my $conf = $conf_obj->conf( PATH );

Returns the de-serialized content of the file provided through the PATH parameter.
The PATH parametrer can either be specified in the C<new> or the C<conf> methods,
there's no difference betweent the 2 possibilities.

=back
=cut
sub conf {
    my $self = shift();

    # already have it
    $self->_conf() && return $self->conf();

    # a path was provided
    if ( my $path = shift() ) {
        $self->_path( $path );
    }

    $self->_path() || croak "Need the path to the configuration file.";
    -r $self->_path() || croak "The configuration file at " . $self->_path() . " is not readable.";

    $self->_conf( Config::JSON->new( pathToFile => $self->_path() )->config() );

    return $self->_conf();
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
