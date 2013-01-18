package Odin::Logger;

use strict;
use warnings;

=head1 NAME

Odin::Logger

=head1 DESCRIPTION

Interface to be used for logging through an external module.

TODO: Currently the logging facillity consists of "warn".

=cut

use base qw( Odin Class::Accessor::Grouped Exporter );


__PACKAGE__->mk_group_accessors( inherited => qw( log_header disable ) );
__PACKAGE__->log_header( undef );
__PACKAGE__->disable( 0 );


our @EXPORT_OK = qw( log TRACE DEBUG INFO WARN ERROR CRIT );

use constant {
    TRACE => 't',
    DEBUG => 'd',
    INFO => 'i',
    WARN => 'w',
    ERROR => 'e',
    CRIT => 'c'
};

# Stub ..

sub log {
    my ( $level, $message_string ) = @_;

    return unless ( $message_string );
    return if __PACKAGE__->disable();

    my $header = __PACKAGE__->log_header();

    # by default it's undef
    if ( defined $header ) {
        $message_string = $header . " " . $message_string . "\n";
    }

    warn "[$$][$level] $message_string ";

    return 1;
}

1;
