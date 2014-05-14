#!perl

use strict;
use warnings;
use lib 'lib';
use FindBin '$Bin';
use Pod::Usage;

use YAML qw/LoadFile/;
use Aca::Model::DB;
use Aca::Schema;

use Grades;

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
has 'league' => (
    traits => ['Getopt'], is => 'ro', isa => 'Str', required => 0,
    cmd_aliases => 'l',);

package main;

my $config = LoadFile "aca.yaml";
my $connect_info = Aca::Model::DB->config->{connect_info};
my $schema = Aca::Schema->connect( $connect_info );

my $script = Script->new_with_options;
my $base = $script->base;
my $test = $script->test;
my $league_id = $script->league;
my $man = $script->man;
my $help = $script->help;

pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

my $league = League->new( id => $league_id );
my @members = map { $_->{id} } @{ $league->members };
my $play = $schema->resultset("Play")
	->search({
	exercise => $base,
	league => $league_id });
my $word_bank = $schema->resultset("Word")
	->search({ exercise => $base });

my $pop_array = [ [qw/ word answer player league try exercise /] ];

for my $player ( '193001' ) {
	my @word;
	$word_bank->reset;
	while ( my $word = $word_bank->next ) {
		my $head = $word->head;
		my $my_answer;
		my $standing = $play->search({ player => $player });
# $DB::single = 1 unless $standing->find({ word => $head });
		if ( my $my_word = $standing->find({ word => $head }) ) {
			$my_answer = $my_word->answer;
		}
		if ( $my_answer and $my_answer ne $word->answer ) {
			push @$pop_array, [ $head, undef, $player, $league_id, undef, $test ];
			push @$pop_hash, { head => $head, answer => undef, player => $player,
				league => $league_id, try => undef, exercise => $test };
		}
	}
}

$DB::single=1;

$schema->resultset("Play")->populate( $pop_array );

=head1 NAME

test_word.pl - create oxercise rows in word table for test exercise

=head1 SYNOPSIS

perl script/create_exercise.pl -t awl -g multimedia -i base -d 'Baseline for learning of Academic Word List sublists 1-3'

=head1 DESCRIPTION

INSERT INTO exercise (description, genre, id, type) VALUES (?, ?, ?, ?. ?)

Words which players attempted but got wrong on the 'base' pre-test are inserted in the 'play' table for the 'test' exercise.
Actually DELETE and INSERT. So it can be used to remove and add exercises. So be careful.

=head1 AUTHOR

Dr Bean, C<drbean at (@) cpan dot, yes a dot, org>

=head1 COPYRIGHT


This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
