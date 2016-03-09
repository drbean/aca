package Bett::Schema::Result::Genre;

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

Bett::Schema::Result::Genre

=cut

__PACKAGE__->table("genre");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 value

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "tinyint", is_auto_increment => 1, is_nullable => 0 },
  "value",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 leaguegenres

Type: has_many

Related object: L<Bett::Schema::Result::Leaguegenre>

=cut

__PACKAGE__->has_many(
  "leaguegenres",
  "Bett::Schema::Result::Leaguegenre",
  { "foreign.genre" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 questions

Type: has_many

Related object: L<Bett::Schema::Result::Question>

=cut

__PACKAGE__->has_many(
  "questions",
  "Bett::Schema::Result::Question",
  { "foreign.genre" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-08-14 06:56:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sB+RbgpRSPdhJSglQmhE2g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
