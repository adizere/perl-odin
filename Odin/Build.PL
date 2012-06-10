use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Odin',
    license             => 'perl',
    dist_author         => q{Adi Seredinschi <adizere@cpan.org>},
    dist_version_from   => 'lib/Odin.pm',
    build_requires => {
        'Test::More' => '0.9',
        'Test::Deep' => '0.1',
        'Test::Exception' => '0.3',
        'Test::File' => '1.3',
        'Test::MockModule' => '0.05',
        'Class::Accessor::Grouped' => '0.1',
        'Exporter' => '5.65',
        'JSON' => '2.53',
        'Attribute::Abstract' => '1.0',
        'IO::Socket::SSL' => '1.7',
        'JSON' => '2.53',
        'File::Temp' => '0.2',
    },
    add_to_cleanup      => [ 'Odin-*' ],
);

$builder->create_build_script();