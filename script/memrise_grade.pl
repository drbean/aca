#!/usr/bin/perl 

# Created: 04/20/2017 09:49:53 PM
# Last Edit: 2017 May 01, 06:14:30 PM
# $Id$

=head1 NAME

memrise_grade.pl - competitive scoring 2~5 from memrise points

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use strict;
use warnings;

=head1 SYNOPSIS

memrise_grade.pl -l GL00036 -r 2 

=cut

use strict;
use warnings;
use IO::All;
use YAML::XS qw/LoadFile Dump/;
use Cwd; use File::Basename;
use List::Util qw/max/;

use Pod::Usage;

use Grades;
use Grades::Groupwork;

package Script;

use Moose;
with 'MooseX::Getopt';

has 'man'  => ( is => 'ro', isa => 'Bool' );
has 'help' => ( is => 'ro', isa => 'Bool' );
has 'league' => (
    traits => ['Getopt'], is => 'ro', isa => 'Str', required => 0,
    cmd_aliases => 'l',);
has 'round' => (
    traits => ['Getopt'], is => 'ro', isa => 'Int', required => 0,
    cmd_aliases => 'r',);

package main;


=head1 DESCRIPTION

The differences between test and base in $round/g1.yaml, curved so players with zero difference or with undefined base scores get 2, the player with biggest difference gets 5 and the player at the median point gets 4.

=cut

my $script = Script->new_with_options;
my $id = $script->league;
my $round = $script->round;
my $man = $script->man;
my $help = $script->help;

pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

my $dir = $id or basename( getcwd );
my $l = League->new( leagues => "/home/drbean/$ENV{SEMESTER}", id => $dir );
my $g = Grades->new({ league => $l });
my %m = map { $_->{id} => $_ } @{ $l->members };

my ($gr, $bean_format) = LoadFile "/home/drbean/$ENV{SEMESTER}/$dir/exam/$round/g1.yaml";
my ( %inc, %base_report, %test_report );
my @names = map { $m{$_}->{name} } keys %m;
my %ids = map { $_ => $gr->{id}->{$_} } @names;
for my $player ( values %ids ) {
    if ( defined $gr->{base}->{$player} and defined $gr->{test}->{$player} and
            $gr->{test}->{$player} > 0 ) {
        $inc{$player} = $gr->{test}->{$player} - $gr->{base}->{$player};
    }
    elsif ( defined $gr->{base}->{$player} ) { $inc{$player} = 0 }
    else { $inc{$player} = 0 }
}
$gr->{raw_increase} = \%inc;
my @valid_scores = grep {$_ != 0} values %inc;
my $median = (sort {$a<=>$b} @valid_scores)[ @valid_scores/2 ];
# my $median = (sort {$a<=>$b} grep {$_ != 0} values %inc)[ (keys %m)/2 ];
# my $median = (sort {$a<=>$b} values %inc)[ (keys %m)/2 ];
my $max_points = max values %inc;
my $check = sub {
    my $name = shift();
    my $id = $ids{$name};
    my $max_points = shift();
    if ( defined $gr->{base}->{$id} ) {
        if ( $gr->{raw_increase}->{$id} > $median ) {
            $gr->{grade}->{$name} =  sprintf( "%.2f", 4 + 1 *
                ($gr->{raw_increase}->{$id} - $median) /
                    ($max_points - $median) );
        }
        elsif ( $gr->{raw_increase}->{$id} <= $median ) {
            $gr->{grade}->{$name} = sprintf( "%.2f", 2 + 2 *
                $gr->{raw_increase}->{$id} / $median );
        }
        else {
            die "No card.id, no report.grade.id?\n";
        }
    }
};
$gr->{grade}->{$_} = $check->($_, $max_points) for @names;
my %numerical_grade = map { $_ => $gr->{grade}->{$m{$_}->{name}} } keys %m;


print Dump $gr;
print Dump \%numerical_grade;


=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2017 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of memrise_grade.pl

# vim: set ts=8 sts=4 sw=4 noet:


