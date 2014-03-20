package Aca::Controller::Play;
use Moose;
use namespace::autoclean;

use List::MoreUtils qw/all/;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Bett::Controller::Play - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

use List::MoreUtils qw/any/;

#=head2 index
#
#=cut
#
#sub index :Path :Args(0) {
#    my ( $self, $c ) = @_;
#    $c->stash( config => $c->config );
#    $c->stash( template => 'exchange.tt2' );
#}

=cut

=head2 setup

Gameover if all answers defined.

=cut

sub setup :Chained('/') :PathPart('play') :CaptureArgs(1) {
	my ($self, $c, $mycourse) = @_;
        my $player = $c->session->{player_id};
	my $league = $c->session->{league};
	my $exercise = $c->session->{exercise};
	my $standing = $c->model("DB::Play")
		->search({ player => $player,
		exercise => $exercise,
		league => $league });
	my $word_bank = $c->model("DB::Word")
		->search({ exercise => 'base' });
	my $play = $c->model("DB::Play")
		->search({ player => $player,
		exercise => "base",
		league => $league });
	my @word;
	while ( my $word = $word_bank->next ) {
		my $head = $word->head;
		my $my_answer;
		if ( my $my_word = $play->find({ word => $head }) ) {
			$my_answer = $my_word->answer;
		}
		if ( $my_answer and $my_answer ne $word->answer ) {
			push @word, $word;
		}
	}
	@word = $c->model("DB::Word")
		->search({ exercise => 'base' }) unless @word;
	if ( $standing->count == @word ) {
		$c->stash(gameover => 1);
		$c->detach('exchange');
	}
	$c->stash(word => \@word);
	$c->stash(standing => $standing);
	$c->stash(course => $mycourse);
	$c->stash(player => $player);
	$c->stash(exercise => $exercise);
	$c->stash(league => $league);
}

=head2 try

Course, question, answer and Questioner's course and answer. Errors from haskell's Questioner: expectedcourse contains  unknown words and theanswer shows Questioner unhandles it.

=cut

sub try :Chained('setup') :PathPart('') :CaptureArgs(0) {
	my ( $self, $c ) = @_;
	my $ex = $c->stash->{exercise};
	if ( $c->request->params ) {
		my $course = $c->stash->{course};
		my $in_play = $c->request->params;
		delete $in_play->{course};
		delete $in_play->{shift};
		delete $in_play->{Submit};
		$c->stash({ in_play => $in_play });
		my @heads = keys %$in_play;
		my $tries = $c->model('DB::Try')->search({
			league => $c->stash->{league},
			exercise => $c->stash->{exercise},
			player => $c->stash->{player},
			});
		my $last_try = $tries->get_column('try')->max() + 1;
		for my $word ( @heads ) {
			my $answer = $in_play->{$word};
			$tries->create({
					try => $last_try,
					word => $word,
					answer => $answer
				}) if $answer;
		}
		$c->stash({tries => $tries, try => $last_try});
	}
}

=head2 update

TODO standings not checked for dupes in in_play

=cut

sub update :Chained('try') :PathPart('') :CaptureArgs(0) {
	my ( $self, $c ) = @_;
	my $player = $c->stash->{ player };
	my $exercise= $c->stash->{exercise };
	my $league= $c->stash->{ league };
	my $standing = $c->stash->{standing};
	my $tries = $c->stash->{tries};
	my $last_try = $c->stash->{last_try};
	my $in_play = $c->stash->{in_play};
	my $words = $c->stash->{word};
	my (%dupes, %values, %value_dupes, $error_msg);
	for ( keys %$in_play ) {
		my $value = $in_play->{$_};
		$values{$value}++ if $value;
	}
	my @values = values %values;
	if ( any { $values{$_} > 1 } keys %values ) {
		my @overvalued = grep { $values{$_} > 1 } keys %values;
		for my $value ( @overvalued ) {
			my $value_dupe = $value_dupes{$value};
			for my $key ( keys %$in_play ) {
				if ( $in_play->{$key} eq $value ) {
					$dupes{$key} = $value;
					push @$value_dupe, $key;
				}
			}
			$value_dupes{$value} = $value_dupe;
		}
		for my $value ( keys %value_dupes ) {
			my $keys = $value_dupes{$value};
			my $first_word = shift @$keys;
			for my $dupe ( @$keys ) {
				$error_msg .= "<br> You gave '$first_word' and '$dupe' the same \
translation, '$value'. Choose a different translation for one of them. </br> ";
			}
			$error_msg .= "<br/>";
		}
	}
	for my $word ( %$in_play ) {
		my $answer = $in_play->{$word};
		next unless $answer;
		my $existing_words = $standing->search({ answer => $answer });
		while ( my $standing = $existing_words->next ) {
			my $word_in_standing = $standing->word;
			$dupes{ $word } = $answer;
			$dupes{ $word_in_standing } = $answer;
			push @{ $value_dupes{$answer} }, $word;
			push @{ $value_dupes{$answer} }, $word_in_standing;
			$error_msg .= "<br> Previously, you gave '$word_in_standing' the same \
translation as '$word', namely, '$answer'. Choose a different translation for one \
of them. </br> ";
		}
		if ( $value_dupes{$answer} ) {
			$existing_words->delete unless $existing_words == 0;
		}
		else {
			$standing->create({ word => $word, answer => $answer,
			try => $c->stash->{try} });
		}
	}
	my $progress = $standing->count;
		$c->stash({ progress => $progress });
		$c->stash(dupes => \%dupes);
		$c->stash({error_msg => $error_msg});
		$c->stash({ word => $words });
}

=head2 exchange

GAME OVER, or loop back to REPL.

=cut

sub exchange :Chained('update') :PathPart('') :Args(0) {
	my ( $self, $c ) = @_;
	if ( $c->stash->{gameover} ) {
		$c->stash->{ template } = 'over.tt2';
		return;
	}
	my $standing = $c->stash->{standing};
	my $answers;
	$standing->reset;
	while ( my $play = $standing->next ) {
		$answers->{$play->word} = $play->answer if $play->answer;
	}
	$c->stash({ answers => $answers });
	$c->stash->{ template } = 'play.tt2';
}

=head1 AUTHOR

Dr Bean

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
