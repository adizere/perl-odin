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
        'Class::Accessor::Grouped' => '0.1',
        'Exporter' => '5.65',
        'JSON' => '2.53',
        'Internals' => '1.1',
    },
    add_to_cleanup      => [ 'Odin-*' ],
);

$builder->create_build_script();
