package Bett::Schema::Result::Leaguegenre;

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

Bett::Schema::Result::Leaguegenre

=cut

__PACKAGE__->table("leaguegenre");

=head1 ACCESSORS

=head2 league

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 genre

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "league",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "genre",
  { data_type => "tinyint", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("league");

=head1 RELATIONS

=head2 genre

Type: belongs_to

Related object: L<Bett::Schema::Result::Genre>

=cut

__PACKAGE__->belongs_to(
  "genre",
  "Bett::Schema::Result::Genre",
  { id => "genre" },
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


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-08-14 12:32:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nK+vmrKh0NK6mEoJl1iOQQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
