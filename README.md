# NAME

DBIx::Fixture::Admin - facilitate data management by the fixtures

# SYNOPSIS

    use DBIx::Fixture::Admin;

    use DBI;
    my $dbh = DBI->connect("DBI:mysql:sample", "root", "");

    my $admin = DBIx::Fixture::Admin->new(
        +{
            fixture_path => "./fixture/",
            driver       => "mysql",
            load_opt     => "update",
            dbh          => $dbh,
        },
    );

    $admin->load_all(); # load all fixture
    $admin->create(tables => ["sample"]); # create sample table fixture
    $admin->load(tables => ["sample"]); # load sample table fixture

# DESCRIPTION

DBIx::Fixture::Admin is facilitate data management by the fixtures

# LICENSE

Copyright (C) meru\_akimbo.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

meru\_akimbo <merukatoruayu0@gmail.com>
