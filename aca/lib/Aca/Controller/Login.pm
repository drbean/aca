package Aca::Controller::Login;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Aca::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
	my $name = $c->request->params->{name};
	my $id = $c->request->params->{id};
	my $password = lc $c->request->params->{password};
	my $exercise = $c->request->params->{exercise};
	if ($id && $password) {
		if ($c->authenticate({ id => $id,
				  password => $password  } )) {
			$c->session->{player_id} = $id;
			my $officialrole = 1;
			if ( $c->check_user_roles($officialrole) ) {
				$c->stash->{id}   = $id;
				$c->stash->{name} = $name;
				$c->stash->{leagues} =
				  [ $c->model('dicDB::League')->search( {} ) ];
				my $jigsawroles = $c->model('dicDB::Jigsawrole');
				my $oldrole = $jigsawroles->search( { player => $id } )->next;
				if ($oldrole) {
					$c->stash->{oldrole} = $oldrole->role;
				}
				$c->stash->{jigsawroles} =
				  [ $jigsawroles->get_column('role')->func('DISTINCT') ];
				$c->stash->{exercise} = $exercise;
				$c->stash->{template} = 'official.tt2';
				return;
			}
			my @memberships = $c->model("dicDB::Member")->search
				({player => $id});
			my @leagues;
			push @leagues, $_->league for @memberships;
			if ( @leagues > 1 ) {
				$c->stash->{id} = $id;
				$c->stash->{username} = $name;
				$c->stash->{leagues} = \@leagues;
				$c->session->{exercise} = $exercise if $exercise;
				$c->stash(exercise => $exercise);
				$c->stash->{template} = 'membership.tt2';
				return;
			}
			else {
				my $league = $leagues[0]->id;
				$c->session->{league} = $league;
				$exercise = $c->forward( 'get_exercise', [ $league ] ) unless $exercise;
				$c->session->{exercise} = $exercise if $exercise;
				$c->response->redirect($c->uri_for( "/play"));
			}
		} else {
			$c->stash(error_msg =>
				"Bad id or password.");
		}
	} else {
		$c->stash(error_msg =>
			"Empty id or password.")
		unless ($c->user_exists);
		$c->stash(exercise => $exercise);
	}
	$c->stash(template => 'login.tt2');
}

=head2 official

Set league official is organizing. Use session player_id to authenticate the participant.

=cut

sub official : Local {
	my ($self, $c) = @_;
	my $league = $c->request->params->{league} || "";
	my $jigsawrole = $c->request->params->{jigsawrole} || "";
	my $password = lc $c->request->params->{password} || "";
	my $exercise = $c->request->params->{exercise};
	my $username = $c->session->{player_id};
	if ( $c->authenticate( {id =>$username, password=>$password} ) ) {
		# my $officialrole = "official";
		my $officialrole = 1;
		if ( $c->check_user_roles($officialrole) ) {
			$c->session->{league} = $league;
			$exercise = $c->forward( 'get_exercise', [ $league ] ) unless $exercise;
			$c->session->{exercise} = $exercise if $exercise;
			$c->model('dicDB::Jigsawrole')->update_or_create(
				{	league => $league, player => $username,
					role => $jigsawrole } ) if $jigsawrole;
			$c->response->redirect($c->uri_for("/play"), 303);
			return;
		}
		else {
		# Set an error message
		$c->stash->{error_msg} = "Bad username or password?";
		$c->stash(exercise => $exercise);
		$c->stash->{template} = 'login.tt2';
		}
	}
	$c->response->header( 'Cache-Control' => 'no-cache' );
	$c->stash->{template} = 'login.tt2';
}


=head2 membership

Set league multi-membership player is participating in.

=cut

sub membership :Local {
	my ($self, $c) = @_;
	my $league = $c->request->params->{league} || '';
	my $password = $c->request->params->{password} || '';
	my $exercise = $c->request->params->{exercise};
	$c->session->{league} = $league;
	$exercise = $c->forward( 'get_exercise', [ $league ] ) unless $exercise;
	$c->session->{exercise} = $exercise if $exercise;
	if ( $exercise ) {
		$c->response->redirect(
			$c->uri_for( "/play" ));
	}
	else {
		$c->stash(exercise => $exercise);
		$c->stash->{template} = 'login.tt2';
		return;
	}
}


=head2 get_exercise

DB::Exercise code used by both membership, login actions

=cut

sub get_exercise :Private {
	my ($self, $c, $league) = @_;
	#my $leaguegenre = $c->model("DB::Leaguegenre")->search({league => $league})->next;
	#my $genre = $leaguegenre->get_column('genre');
	#my $exercises = $c->model("DB::Exercise")->search({ genre =>
	#		$genre });
	#my $exercise = $exercises->next;
	#if ( $exercise ) { return $exercise->id; }
	my $exercise = 'base';
	if ( $exercise ) { return $exercise; }
	else { return '' }
}


#=head2 gameRedirect
#
#End of chain. Game or game list, depending on whether exercise session key set.
#
#=cut
#
#sub gameRedirect :Chained('index') :PathPart('') :Args(0) {
#	my ($self, $c) = @_;
#       # if ( defined $c->session->{exercise} ) {
#		my $exercise = $c->session->{exercise};
#		$c->response->redirect(
#			$c->uri_for("/game/$exercise"), 303 );
#	# }
#	#else {
#	#	$c->response->redirect( $c->uri_for("/game/list"),
#	#		303 );
#	#}
#	#return;
#}
   

=head2 logout

Logout logic

=cut

sub logout :Global {
	my ($self, $c) = @_;
	$c->logout;
	$c->response->redirect($c->uri_for('/'));
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
