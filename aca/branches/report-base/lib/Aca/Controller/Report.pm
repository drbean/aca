package Aca::Controller::Report;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }
use Net::FTP;
use IO::All;
use List::MoreUtils qw/any/;

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
	my $exercise = $c->session->{exercise};
	my $word_bank = $c->model("DB::Word")->search({
		exercise =>  $exercise});
	my @heads = $word_bank->get_column('head')->func('DISTINCT');
	my $base = $c->model("DB::Play")->search({
		league => $league, exercise => $exercise . "_base", player => $id });
	my $word_total= @heads;
	my $pre_total= $base->count;
	my $pre_correct = 0;
	my (%answers, %wrong, %flash, %right, %passed);
	for my $head ( @heads ) {
		next if $head eq 'shift';
		next if $head eq 'first';
		my $pre = $base->find({word => $head});
		my @answers;
		my $words = $word_bank->search({ head => $head });
		while ( my $word = $words->next ) {
			push @answers, $word->answer;
		}
		$answers{$head} = join ', ', @answers;
		if ( $pre_total == 0 ) {
			$passed{$head} = "Unattempted";
			$flash{$head} = join ', ', @answers;
		}
		elsif ( $pre and any { $_ eq $pre->answer } @answers ) {
			$pre_correct++;
			$right{$head} = "Right";
		}
		elsif ( $pre ) {
			$wrong{$head} = $pre->answer;
			$flash{$head} = join ', ', @answers;
		}
		else {
			$passed{$head} = "Unattempted";
		}

	}
	$word_bank->reset;
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
    $ftp->login('greg', '');
    my $config = $c->config;
    my $leaguedirs = $config->{leagues};
	my $league = $c->session->{league};
    my %leaguesByGenre;
    my @genres = qw/conversation business call esp tech friends customs media multimedia college literature       intercultural/;
    $leaguesByGenre{$_} = $config->{ $_ } for @genres;
    my %leaguegenre = map { my $genre = $_ ;  my $leagues = $leaguesByGenre{$genre};
                        map { $_ => $genre } @$leagues } @genres;
    my $tourid = $c->stash->{league};
    my $genre = $leaguegenre{$tourid};
    $ftp->cwd("/public_html/tech/flash");
    my $deck = "$leaguedirs/$league/flash/$id.txt";
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
