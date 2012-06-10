package Odin::ProtocolStack::Configuration;

use strict;
use warnings;

=head1 NAME

Odin::ProtocolStack::Configuration - JSON style configuration file loader for parameters that
define the stack.

=head1 DESCRIPTION

Various configuration parameters are kept in a JSON structure, loaded and parsed
from an external file.

This module exports these parameters in a hashref named $conf.

For accessing the underlying Config::JSON structure the $json_config is also
exported; this allows the dynamical modification of the parameters.

=cut

use base qw ( Odin Exporter );


# The path where we look for the json file
use constant {
    CONFIGURATION_FPATH => '/conf/protocol_conf.json',
};


use Config::JSON;

our @EXPORT_OK = qw( $json_conf $conf );


our $json_config = Config::JSON->new( pathToFile => $ENV{ODIN_HOME} . CONFIGURATION_FPATH );
our $conf = $json_config->config();


1;
