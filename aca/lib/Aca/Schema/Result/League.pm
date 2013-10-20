use utf8;
package Aca::Schema::Result::League;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Aca::Schema::Result::League

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

=head1 TABLE: C<league>

=cut

__PACKAGE__->table("league");

=head1 ACCESSORS

=head2 id

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 1

=head2 field

  data_type: 'text'
  is_nullable: 1

=head2 genre

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 1 },
  "field",
  { data_type => "text", is_nullable => 1 },
  "genre",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 members

Type: has_many

Related object: L<Aca::Schema::Result::Member>

=cut

__PACKAGE__->has_many(
  "members",
  "Aca::Schema::Result::Member",
  { "foreign.league" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 players

Type: many_to_many

Composing rels: L</members> -> player

=cut

__PACKAGE__->many_to_many("players", "members", "player");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-10-20 12:35:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NnsQ5Y2u98pJRLKkxKZFqA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
