requires 'perl', '5.008001';

requires 'DBIx::FixtureLoader';
requires 'Test::Fixture::DBI';
requires 'Teng::Schema::Loader';
requires 'Class::Accessor::Lite';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

