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
	my $word = $c->model("DB::Word")
		->search({ exercise => $exercise });
	$c->stash(word => $word);
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
		my $play = $c->request->params;
		delete $play->{course};
		delete $play->{shift};
		delete $play->{Submit};
		$c->stash({ play => $play });
		my @heads = keys %$play;
		my $tries = $c->model('DB::Try')->search({
			league => $c->stash->{league},
			exercise => $c->stash->{exercise},
			player => $c->stash->{player},
			});
		my $last_try = $tries->get_column('try')->max() + 1;
		for my $word ( @heads ) {
			my $answer = $play->{$word};
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

=cut

sub update :Chained('try') :PathPart('') :CaptureArgs(0) {
	my ( $self, $c ) = @_;
	my $player = $c->stash->{ player };
	my $exercise= $c->stash->{exercise };
	my $league= $c->stash->{ league };
	my $standing = $c->stash->{standing};
	my $tries = $c->stash->{tries};
	my $last_try = $c->stash->{last_try};
	my $play = $c->stash->{play};
	my $words = $c->stash->{word};
	$words->reset;
	while ( my $word = $words->next ) {
		my $head = $word->head;
		my $answer = $play->{$head};
		if ( $answer ) {
			my $dupe_rs = $tries->search( { answer => $answer },
			   { select => [ "word", { max => 'try' } ] , group_by => ['word', 'answer'] } );
			if (  $dupe_rs != 0 ) {
				my ($dupes, $error_msg);
				while ( my $dupe = $dupe_rs->next ) {
					my $dupe_word = $dupe->word;
					next if $dupe_word eq $head;
					my $superseding_try = $tries->search({
						word => $dupe_word })->get_column('try')->max;
					my $answer_try = $tries->search({
						word => $dupe_word, answer => $answer})->get_column('try')->max;
					if ( $dupe->try <= $superseding_try ) {
						$standing->find_or_create({ word => $head, answer => $answer,
						try => $c->stash->{try} });
						next;
					}
					$error_msg .= "<br> You gave '$head' and '$dupe_word' the same \
translation, '$answer'. Choose a different translation for one of them. </br> ";
					$dupes->{ $dupe_word } = $answer;
				}
				$dupes->{ $head } = $answer;
				$c->stash(dupes => $dupes);
				$c->stash({error_msg => $error_msg});
				my $dupe_standing = $standing->search({ answer => $answer });
				$dupe_standing->delete;
			}
			else {
				$standing->find_or_create({ word => $head, answer => $answer,
				try => $c->stash->{try} });
			}
		}
	}
	my $progress = $standing->count;
	$c->stash({ progress => $progress });
	$words->reset;
	$c->stash({ word => $words });
	my $gameover;
	# $gameover =1 if all { defined $_->answer } @standing;
	if ( $gameover ) {
		$c->stash(gameover => $gameover);
		$c->detach('exchange');
	}
}

=head2 exchange

GAME OVER, or loop back to REPL.

=cut

sub exchange :Chained('update') :PathPart('') :Args(0) {
	my ( $self, $c ) = @_;
	my $course = $c->stash->{course};
	my $win = $c->config->{$course}->{win};
	$c->stash->{win} = $win;
	my $standing = $c->stash->{standing};
	my $answers;
	$standing->reset;
	while ( my $play = $standing->next ) {
		$answers->{$play->word} = $play->answer if $play->answer;
	}
	$c->stash({ answers => $answers });
	$c->stash->{ template } = 'over.tt2';
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
