package Bett::Schema::Result::Member;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

Bett::Schema::Result::Member

=cut

__PACKAGE__->table("member");

=head1 ACCESSORS

=head2 league

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 player

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "league",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "player",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("player", "league");

=head1 RELATIONS

=head2 player

Type: belongs_to

Related object: L<Bett::Schema::Result::Player>

=cut

__PACKAGE__->belongs_to(
  "player",
  "Bett::Schema::Result::Player",
  { id => "player" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 league

Type: belongs_to

Related object: L<Bett::Schema::Result::League>

=cut

__PACKAGE__->belongs_to(
  "league",
  "Bett::Schema::Result::League",
  { id => "league" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

#=head2 questions
#
#Type: has_many
#
#Related object: L<Bett::Schema::Result::Question>
#
#=cut
#
#__PACKAGE__->has_many(
#  "questions",
#  "Bett::Schema::Result::Question",
#  {	"foreign.player" => "self.player",
#  	"foreign.league" => "self.league"
#  },
#  { cascade_copy => 0, cascade_delete => 0 },
#);
#
=head2 plays

Type: has_many

Related object: L<Bett::Schema::Result::Play>

=cut

__PACKAGE__->has_many(
  "plays",
  "Bett::Schema::Result::Play",
  { "foreign.player" => "self.player" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-08-14 12:32:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RxfiCB/KCjfk9jeBxYHg3w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
