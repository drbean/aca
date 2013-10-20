use utf8;
package Aca::Schema::Result::Member;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Aca::Schema::Result::Member

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

=head1 TABLE: C<member>

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

=head1 PRIMARY KEY

=over 4

=item * L</player>

=item * L</league>

=back

=cut

__PACKAGE__->set_primary_key("player", "league");

=head1 RELATIONS

=head2 league

Type: belongs_to

Related object: L<Aca::Schema::Result::League>

=cut

__PACKAGE__->belongs_to(
  "league",
  "Aca::Schema::Result::League",
  { id => "league" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 player

Type: belongs_to

Related object: L<Aca::Schema::Result::Player>

=cut

__PACKAGE__->belongs_to(
  "player",
  "Aca::Schema::Result::Player",
  { id => "player" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 plays

Type: has_many

Related object: L<Aca::Schema::Result::Play>

=cut

__PACKAGE__->has_many(
  "plays",
  "Aca::Schema::Result::Play",
  {
    "foreign.league" => "self.player",
    "foreign.player" => "self.league",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-10-20 12:35:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4/veRyzsumydCX8/9iUHzg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
