use utf8;
package Aca::Schema::Result::Play;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Aca::Schema::Result::Play

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 TABLE: C<play>

=cut

__PACKAGE__->table("play");

=head1 ACCESSORS

=head2 word

  data_type: 'text'
  is_nullable: 0

=head2 answer

  data_type: 'text'
  is_nullable: 1

=head2 player

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 league

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 try

  data_type: 'integer'
  is_nullable: 1

=head2 score

  data_type: 'integer'
  is_nullable: 1

=head2 questionchance

  data_type: 'integer'
  is_nullable: 1

=head2 answerchance

  data_type: 'integer'
  is_nullable: 1

=head2 exercise

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "word",
  { data_type => "text", is_nullable => 0 },
  "answer",
  { data_type => "text", is_nullable => 1 },
  "player",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "league",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "try",
  { data_type => "integer", is_nullable => 1 },
  "score",
  { data_type => "integer", is_nullable => 1 },
  "questionchance",
  { data_type => "integer", is_nullable => 1 },
  "answerchance",
  { data_type => "integer", is_nullable => 1 },
  "exercise",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</player>

=item * L</league>

=item * L</word>

=item * L</exercise>

=back

=cut

__PACKAGE__->set_primary_key("player", "league", "word", "exercise");

=head1 RELATIONS

=head2 member

Type: belongs_to

Related object: L<Aca::Schema::Result::Member>

=cut

__PACKAGE__->belongs_to(
  "member",
  "Aca::Schema::Result::Member",
  { league => "player", player => "league" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-10-20 15:29:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jMWTjMCfxDelmyHAi/UB0Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
