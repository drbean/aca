use utf8;
package Aca::Schema::Result::Leaguegenre;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Aca::Schema::Result::Leaguegenre

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

=head1 TABLE: C<leaguegenre>

=cut

__PACKAGE__->table("leaguegenre");

=head1 ACCESSORS

=head2 league

  data_type: 'text'
  is_nullable: 0

=head2 genre

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "league",
  { data_type => "text", is_nullable => 0 },
  "genre",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</league>

=item * L</genre>

=back

=cut

__PACKAGE__->set_primary_key("league", "genre");

=head1 RELATIONS

=head2 league

Type: has_one

Related object: L<Aca::Schema::Result::League>

=cut

__PACKAGE__->has_one(
  "league",
  "Aca::Schema::Result::League",
  { "foreign.league" => "self.league" },
  { cascade_copy => 0, cascade_delete => 0 },
);

# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-10-20 12:35:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NnsQ5Y2u98pJRLKkxKZFqA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
