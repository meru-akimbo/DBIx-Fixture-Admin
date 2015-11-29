package DBIx::Fixture::Admin;
use 5.008001;
use strict;
use warnings;

use DBIx::FixtureLoader;
use Test::Fixture::DBI::Util qw/make_fixture_yaml/;
use Teng::Schema::Loader;
use File::Basename qw/basename/;
use List::Util qw/any/;
use Set::Functional qw/difference/;
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

    my @tables = @{$args->{tables}};
    my @ignore_tables = $self->ignore_tables;
    my @target_tables = difference(\@tables, \@ignore_tables);

    return unless scalar @target_tables;

    my $loader   = $self->_make_loader;
    my $load_opt = exists $self->conf->{load_opt} ? $self->conf->{load_all} : undef;

    for my $fixture (@target_tables) {
        $loader->load_fixture($self->conf->{fixture_path} . $fixture . ".yaml")                 unless $load_opt;
        $loader->load_fixture($self->conf->{fixture_path} . $fixture . ".yaml", $load_opt => 1) if $load_opt;
    }
}

sub load_all {
    my ($self,) = @_;
    $self->load(tables => [$self->target_tables]);
}

sub create {
    my $v = Data::Validator->new(
        tables => +{ isa => 'ArrayRef[Str]' }
    )->with(qw/Method/);
    my($self, $args) = $v->validate(@_);

    my $schema = Teng::Schema::Loader->dump(
        dbh => $self->dbh,
    )->schema;

    my $sql_maker = SQL::Maker->new(driver => $self->conf->{driver});
    my @shema_tables = keys %{$schema->{tables}};

    my @tables = @{$args->{tables}};
    my @ignore_tables = $self->ignore_tables;
    my @target_tables = difference(\@tables, \@ignore_tables);

    return unless scalar @target_tables;

    my @create_tables = difference(\@target_tables, [keys %{$schema->{tables}}]);
    for my $table_name (@create_tables) {
        my $table   = $schema->{tables}->{$table_name};
        my @columns = $table->columns;
        my $pk      = $table->primary_key->field_names;
        my ($sql)   = $sql_maker->select($table => \@columns);

        make_fixture_yaml( $self->dbh, $table, $pk, $sql, $self->conf->{fixture_path} . $table_name . ".yaml");
    }
}

sub ignore_tables {
    my ($self,) = @_;

    return unless exists $self->conf->{ignore_tables};
    return @{$self->conf->{ignore_tables}};
}

sub fixtures {
    my ($self,) = @_;
    return glob($self->conf->{fixture_path} . '*.yaml');
}

sub target_fixtures {
    my ($self,) = @_;

    my @fixtures = $self->fixtures;
    my %table2fixture
        = map {
            my $tmp = basename($_);
            $tmp =~ s/\.yaml$//;
            $tmp => basename($_);
        } @fixtures;

    my @tables = $self->_difference_ignore_tables([keys %table2fixture]);
    my @target_fixtures = map { $table2fixture{$_} } @tables;

    return @target_fixtures;
}

sub target_tables {
    my ($self,) = @_;

    my @target_fixtures = $self->target_fixtures;
    my @target_tables = map {
        my $tmp = $_;
        $tmp =~ s/\.yaml$//;
        $tmp
    } @target_fixtures;

    return @target_tables;
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

