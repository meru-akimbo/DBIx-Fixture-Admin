package DBIx::Fixture::Admin;
use 5.008001;
use strict;
use warnings;

use DBIx::FixtureLoader;
use Test::Fixture::DBI::Util qw/make_fixture_yaml/;
use Teng::Schema::Loader;
use File::Basename qw/basename/;
use List::Util qw/any/;
use Set::Functional qw/difference intersection/;
use Data::Validator;

use Class::Accessor::Lite (
    new => 1,
    ro  => [ qw(conf dbh) ],
);

our $VERSION = "0.01";

sub load {
    my $v = Data::Validator->new(
        tables => +{ isa => 'ArrayRef[Str]' }
    )->with(qw/Method/);
    my($self, $args) = $v->validate(@_);

    my @tables = intersection($args->{tables}, [$self->tables]);

    return unless scalar @tables;

    my $loader   = $self->_make_loader;
    my $load_opt = exists $self->conf->{load_opt} ? $self->conf->{load_all} : undef;

    for my $fixture (@tables) {
        $loader->load_fixture($self->conf->{fixture_path} . $fixture . ".yaml")                 unless $load_opt;
        $loader->load_fixture($self->conf->{fixture_path} . $fixture . ".yaml", $load_opt => 1) if $load_opt;
    }
}

sub load_all {
    my ($self,) = @_;
    $self->load(tables => [$self->tables]);
}

sub create {
    my $v = Data::Validator->new(
        tables => +{ isa => 'ArrayRef[Str]' }
    )->with(qw/Method/);
    my($self, $args) = $v->validate(@_);

    for my $data ($self->_build_create_data($args->{tables})) {
        $self->_make_fixture_yaml($data);
    }
}

sub ignore_tables {
    my ($self,) = @_;

    return unless exists $self->conf->{ignore_tables};
    return @{$self->conf->{ignore_tables}};
}

sub fixtures {
    my ($self,) = @_;

    my @all_fixtures = $self->_all_fixtures;
    my %table2fixture
        = map {
            my $tmp = basename($_);
            $tmp =~ s/\.yaml$//;
            $tmp => basename($_);
        } @all_fixtures;

    my @tables = $self->_difference_ignore_tables([keys %table2fixture]);
    my @fixtures = map { $table2fixture{$_} } @tables;

    return @fixtures;
}

sub tables {
    my ($self,) = @_;

    my @fixtures = $self->fixtures;
    my @tables = map {
        my $tmp = basename($_);
        $tmp =~ s/\.yaml$//;
        $tmp
    } @fixtures;

    return @tables;
}

sub _all_fixtures {
    my ($self,) = @_;
    return glob($self->conf->{fixture_path} . '*.yaml');
}

sub _difference_ignore_tables {
    my $v = Data::Validator->new(
        tables => 'ArrayRef[Str]'
    )->with(qw/Method StrictSequenced/);
    my($self, $args) = $v->validate(@_);

    my @tables        = @{$args->{tables}};
    my @ignore_tables = $self->ignore_tables;
    my @difference_tables;
    for my $table (@tables) {
        push @difference_tables, $table
            unless any { $table =~ m/^${_}$/ } @ignore_tables;
    }

    return @difference_tables;
}

sub _make_loader {
    my ($self,) = @_;
    return DBIx::FixtureLoader->new(dbh => $self->dbh);
}

sub _build_create_data {
    my $v = Data::Validator->new(
        tables => +{ isa => 'ArrayRef[Str]' }
    )->with(qw/Method StrictSequenced/);
    my($self, $args) = $v->validate(@_);
    my @tables = difference($args->{tables}, [$self->ignore_tables]);
    return unless scalar @tables;

    my $schema = Teng::Schema::Loader->load(
        dbh => $self->dbh,
        namespace => 'Hoge',
    )->schema;

    my @shema_tables = keys %{$schema->{tables}};

    my $sql_maker = SQL::Maker->new(driver => $self->conf->{driver});
    my @data;
    for my $table (@tables) {
        my $table_data   = $schema->{tables}->{$table};
        my $columns = $table_data->columns;
        my ($sql)   = $sql_maker->select($table => $columns);

        push @data, +{ table => $table, columns => $columns, sql => $sql };
    }

    return @data;
}

sub _make_fixture_yaml {
    my $v = Data::Validator->new(
        table   => 'Str',
        columns => 'ArrayRef[Str]',
        sql     => 'Str',
    )->with(qw/Method/);
    my($self, $args) = $v->validate(@_);

    my %tmp_args = %$args;
    make_fixture_yaml(
        $self->dbh,
        $tmp_args{table},
        $tmp_args{columns},
        $tmp_args{sql},
        $self->conf->{fixture_path} . $tmp_args{table} . ".yaml"
    );
}

1;
__END__

=encoding utf-8

=head1 NAME

DBIx::Fixture::Admin - It's new $module

=head1 SYNOPSIS

    use DBIx::Fixture::Admin;

=head1 DESCRIPTION

DBIx::Fixture::Admin is ...

=head1 LICENSE

Copyright (C) meru_akimbo.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

meru_akimbo E<lt>merukatoruayu0@gmail.comE<gt>

=cut

