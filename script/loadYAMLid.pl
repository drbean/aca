#!/usr/bin/perl

=head1 NAME

loadYAMLid.pl -- Load a number of sublists from a YAML wordlist file

=head1 SYNOPSIS

loadYAMLid.pl data/wordlist.yaml -x sport -s fitness-theory,activities,weight-training

=head1 DESCRIPTION

Cut and paste from YAML into word table

In order:
  - exercise
  - head
  - answer
  - sublist


=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 COPYRIGHT


This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use strict;
use warnings;
use lib 'lib';
use Scalar::Util qw/looks_like_number/;
use YAML qw/LoadFile DumpFile/;
use IO::All;
use Getopt::Long;
use Pod::Usage;

my $man = 0;
my $help = 0;
my $exercise = "";
my @sublist = ();

GetOptions ( 'help|?' => \$help, man => \$man
	, "s=s@" => \@sublist
	, "x=s" => \$exercise) or pod2usage(2);
@sublist = split(/,/,join(',',@sublist));
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

use Aca;
use Aca::Schema;
use Aca::Model::DB;

my $config = LoadFile "aca.yaml";
my $connect_info = Aca::Model::DB->config->{connect_info};
my $schema = Aca::Schema->connect( $connect_info );
my $w = $schema->resultset('Word');

my $textfile = shift @ARGV;
my $list = LoadFile $textfile;
my @ids = @sublist;
for my $sublist_name ( @ids ) {
	my @vocab;
	my $field = $list->{field};
	push @vocab, $field;
	my $exercise_field = 0;
	my $head_field = 1;
	my $answer_field = 2;
	my $sublist_field = 3;
	my $sublist = $list->{$sublist_name};
	for my $word ( keys %$sublist ) {
		push @vocab, [$exercise, $word, $sublist->{$word}, $sublist_name ]
	}
	uptodatepopulate("Alternative", \@vocab);
	warn "$sublist_name sublist missing" unless @vocab > 1;
}

sub uptodatepopulate
{
	my $class = $schema->resultset(shift);
	my $entries = shift;
	my $columns = shift @$entries;
	foreach my $row ( @$entries )
	{
		my %hash;
		@hash{@$columns} = @$row;
		$class->update_or_create(\%hash);
	}
}


