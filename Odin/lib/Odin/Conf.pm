package Odin::Conf;

use strict;
use warnings;

=head1 NAME

Odin::Conf - JSON style configuration file loader

=head1 DESCRIPTION

Various configuration paramateres are kept in a JSON structure, loaded and parsed
from an external file.

This module exports these parameters in a hashref named $conf.

For accessing the underlying Config::JSON structure the $json_config is also
exported; this allows the dynamical modification of the parameters.

=cut

use base qw ( Odin Exporter );

use Odin::Constants qw( CONFIGURATION_FPATH );

use Config::JSON;
use Cwd;

our @EXPORT_OK = qw( $json_config $conf );


our $json_config = Config::JSON->new( pathToFile => $ENV{ODIN_HOME} . CONFIGURATION_FPATH );
our $conf = $json_config->config();


1;
