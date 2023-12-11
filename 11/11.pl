#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use File::Slurp qw(read_file);
use List::Util qw(all reduce);
use Class::Struct;

struct Galaxy => {
  id => '$',
  x  => '$',
  y  => '$',
};

sub expand {
  my ($by, @v) = @_;
  my (@addx, @addy, @ret);

  push @addy, (all { $_ eq "." } @$_) ? $addy[-1] + $by :
    $addy[-1] ? $addy[-1] : 0 for @v;

  for (my $i = 0; $i < @v; ++$i) {
    push @addx, (all { $_ eq "." } map { $_->[$i] } @v) ?
      ($addx[-1] ? $addx[-1] : 0) + $by
      : $addx[-1] ? $addx[-1] : 0
  }

  for my $y (0..@v-1) {
    for my $x (0..@{$v[0]}-1) {
      push @ret, Galaxy->new(
        id => 1+@ret,
        x => $x + $addx[$x],
        y => $y + $addy[$y]
      ) if $v[$y][$x] eq "#"
    }
  }

  @ret;
}

sub p1 {
  my ($p2) = @_;
  my $n = 1;
  my @galaxies = expand($p2 ? 999999 : 1,
    map { [split //] } split '\n', read_file "in");

  my @pairs;
  for my $i (0..@galaxies-1) {
    for my $j ($i..@galaxies-1) {
      push @pairs, [$galaxies[$i], $galaxies[$j]];
    }
  }


  say $p2 ? "p2: " : "p1: ", reduce { $a + $b }
    map { abs($_->[0]->x - $_->[1]->x) + abs($_->[0]->y - $_->[1]->y) } @pairs;
}

sub p2 {
  p1 "kiedy w radiu bedzie juz tylko radio maryja";
}

p1;
p2;
