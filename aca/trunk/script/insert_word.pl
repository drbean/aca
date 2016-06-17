#!perl

use strict;
use warnings;
use lib 'lib';
use FindBin '$Bin';
use Pod::Usage;

use YAML qw/LoadFile/;
use Aca::Model::DB;
use Aca::Schema;

package Script;

use Moose;
with 'MooseX::Getopt';

has 'man'  => ( is => 'ro', isa => 'Bool' );
has 'help' => ( is => 'ro', isa => 'Bool' );
has 'base' => (
    traits => ['Getopt'], is => 'ro', isa => 'Str', required => 0,
    cmd_aliases => 'b',);
has 'test' => (
    traits => ['Getopt'], is => 'ro', isa => 'Str', required => 0,
    cmd_aliases => 't',);
has 'yaml' => (
    traits => ['Getopt'], is => 'ro', isa => 'Str', required => 0,
    cmd_aliases => 'y',);

package main;

my $config = LoadFile "aca.yaml";
my $connect_info = Aca::Model::DB->config->{connect_info};
my $schema = Aca::Schema->connect( $connect_info );

my $script = Script->new_with_options;
my $base = $script->base;
my $test = $script->test;
my $yaml = $script->yaml;
my $man = $script->man;
my $help = $script->help;

pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

my $word_bank = $schema->resultset("Word")
	->search({ exercise => $base });

my $translation = LoadFile $yaml;

my @translation_array = map { {head => $_, answer => $translation->{$_}} } keys %$translation;

my $pop_array = [ [qw/ head answer /] ];
my $pop_hash;

$DB::single=1;

$word_bank->create( $_ ) for @translation_array;

=head1 NAME

test_word.pl - create oxercise rows in word table for test exercise

=head1 SYNOPSIS

perl script/test_word.pl -b base -t test -l FLA0027

=head1 DESCRIPTION

INSERT INTO play (word, answer, player, league, try, exercise) VALUES (?, ?, ?, ?. ?)

player, league, word, exercise are PRIMARY KEY. 

Words which players attempted but got wrong on the 'base' pre-test are inserted in the 'play' table for the 'test' exercise.
Actually DELETE and INSERT. So it can be used to remove and add words. So be careful.

Players who did not do the base pre-test get to do all the words in the pre-test (and will be given the mininum score, 3/5 by grade_aca.pl).

This memoizing of the wrong pre-test words may not be necessary if the test is run with fastcgi.pl.

=head1 AUTHOR

Dr Bean, C<drbean at (@) cpan dot, yes a dot, org>

=head1 COPYRIGHT


This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
