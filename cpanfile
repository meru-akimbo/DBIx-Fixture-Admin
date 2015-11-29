requires 'perl', '5.008001';

requires 'DBIx::FixtureLoader';
requires 'Test::Fixture::DBI';
requires 'Teng::Schema::Loader';
requires 'Class::Accessor::Lite';
requires 'Set::Functional';
requires 'Data::Validator';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::mysqld';
    requires 'DBIx::Sunny';
};

