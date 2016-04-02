package Aca::Controller::Delete;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }
use Net::FTP;
use IO::All;

=head1 NAME

Aca::Controller::Delete - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Aca::Controller::Delete in Delete.');
}



=head2 choose

=cut

sub delete :Path :Args(0) {
	my ($self, $c) = @_;
	my $id = $c->session->{player_id};
	my $league   = $c->session->{league};
	my $exercise = $c->session->{exercise};
	my $words = $c->model("DB::Word")->search({
		exercise =>  $exercise});
	my $base = $c->model("DB::Play")->search({
		league => $league, exercise => $exercise . "_base", player => $id });
	my $limit = $c->config->{limit};
	$c->stash({limit => $limit});
	my $removable = $c->request->params;
	delete $removable->{shift};
	delete $removable->{Submit};
	my $quit = delete $removable->{quit};
	for my $word ( keys %$removable )  {
		$base->search({ word => $word })->delete;
	}
	$base->reset;
	my $pre_total = $base->count;
	my %revised;
	while (my $one = $base->next ) {
		$revised{$one->word} = $one->answer;
	}
	$c->stash->{player}   = $id;
	$c->stash->{exercise}   = $exercise;
	$c->stash->{league}   = $league;
	$c->stash->{pre_total}   = $pre_total;
	$c->stash->{attempted}   = \%revised;
	$c->stash->{words}  = $words;
	$base->reset;
	$c->stash->{template}	= "delete.tt2";
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
