use utf8;
package Aca::Schema::Result::Word;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Aca::Schema::Result::Word

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

=head1 TABLE: C<word>

=cut

__PACKAGE__->table("word");

=head1 ACCESSORS

=head2 exercise

  data_type: 'text'
  is_nullable: 0

=head2 head

  data_type: 'text'
  is_nullable: 0

=head2 answer

  data_type: 'text'
  is_nullable: 1

=head2 sublist

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "exercise",
  { data_type => "text", is_nullable => 0 },
  "head",
  { data_type => "text", is_nullable => 0 },
  "answer",
  { data_type => "text", is_nullable => 1 },
  "sublist",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</head>

=item * L</exercise>

=back

=cut

__PACKAGE__->set_primary_key("head", "exercise");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-10-20 15:38:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JDwkFpwgkrQrimcd6ETE1Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
