package Odin::Const;

use strict;
use warnings;

=head1 NAME

Odin::Const - Constants definitions

=cut

use base qw( Odin Exporter );

use Internals qw( SetReadOnly );

our $const = {
    socket_send_timeout => 1.0,             # floating seconds, waiting time (when the out buffer is full)

    socket_retrieve_timeout => 0.1,         # floating seconds
    socket_retrieve_poll_timer => 30,       # how many seconds we poll for content

    message_header_separator => "\n",       # the newline char - separates messages headers from actual messages
};


SetReadOnly( $const );


our @EXPORT_OK = qw( $const );


1;
