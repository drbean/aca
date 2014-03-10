package Aca::Controller::Report;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }
use Net::FTP;
use IO::All;

=head1 NAME

Aca::Controller::Report - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Aca::Controller::Report in Report.');
}



=head2 grade

=cut

sub grade :Path :Args(0) {
	my ( $self, $c ) = @_;
	my $id = $c->session->{player_id};
	my $league   = $c->session->{league};
	my $exercise = "base";
	my $words = $c->model("DB::Word")->search({
		exercise => "base" });
	my $base = $c->model("DB::Play")->search({
		league => $league, exercise => "base", player => $id });
	my $word_total= $words->count;
	my $pre_total= $base->count;
	$words->reset;
	my $pre_correct = 0;
	my (%answers, %wrong, %flash, %right, %passed);
	while ( my $word = $words->next ) {
		my $head = $word->head;
		next if $head eq 'shift';
		my $pre = $base->find({word => $head});
		my $answer = $word->answer;
		$answers{$head} = $answer;
# $DB::single=1 if $head eq "vary";
		if ( $pre and $pre->answer eq $answer ) {
			$pre_correct++;
			$right{$head} = "Right";
		}
		elsif ( $pre ) {
			$wrong{$head} = $pre->answer;
			$flash{$head} = $answer;
		}
		else {
			$passed{$head} = "Unattempted";
		}

	}
	$words->reset;
	my $pre_incorrect = $pre_total - $pre_correct;
	my $unattempted = $word_total - $pre_total - 1;
	$c->stash->{player}   = $id;
	$c->stash->{exercise}   = $exercise;
	$c->stash->{league}   = $league;
	$c->stash->{answers}   = \%answers;
	$c->stash->{wrong}   = \%wrong;
	$c->stash->{right}   = \%right;
	$c->stash->{passed}   = \%passed;
	$c->stash->{pre_total}   = $pre_total;
	$c->stash->{pre_correct}   = $pre_correct;
	$c->stash->{pre_incorrect}   = $pre_incorrect;
	$c->stash->{unattempted}   = $unattempted;
	$c->stash->{template}	= "grade.tt2";
	my $flash; $flash .= "$_\t$flash{$_}\n" for sort keys %flash;
	$c->forward('ftp', [$flash, $id]);
}

=head2 ftp

    $self->forward('ftp')

Private method used by report action to put flashcards on http://web.nuu.edu.tw/~greg/tech/$player.txt

=cut

sub ftp : Private {
    my ($self, $c, $flash, $id) = @_;
    my $ftp = Net::FTP->new('web.nuu.edu.tw');
    $ftp->login('greg', '6y6t6y6t');
    $ftp->binary;
    my $config = $c->config;
    my $leaguedirs = $config->{leagues};
    my %leaguesByGenre;
    my @genres = qw/conversation business friends customs media multimedia college literature       +intercultural/;
    $leaguesByGenre{$_} = $config->{ $_ } for @genres;
    my %leaguegenre = map { my $genre = $_ ;  my $leagues = $leaguesByGenre{$genre};
                        map { $_ => $genre } @$leagues } @genres;
    my $tourid = $c->stash->{tournament};
    my $genre = $leaguegenre{$tourid};
    $ftp->cwd("/public_html/tech/flash");
    my $deck = "$leaguedirs/FLA0027/flash/$id.txt";
    io($deck)->print
        ( $flash );
    $ftp->put($deck, "$id.txt");
	#$c->response->redirect
    #    ("http://web.nuu.edu.tw/~greg/tech/flash/$id.txt");
}

=encoding utf8

=head1 AUTHOR

Dr Bean

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
