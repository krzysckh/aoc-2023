#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use File::Slurp qw(read_file);
use List::Util qw(all max min);
use Class::Struct;

struct (
  Galaxy => {
    id => '$',
    x  => '$',
    y  => '$',
  }
);

sub expand {
  my ($by, @v) = @_;
  my (@addx, @addy);
  my @ret;

  for (@v) {
    if (defined $addy[-1]) {
      push @addy, (all { $_ eq "." } @$_) ? $addy[-1] + $by : $addy[-1];
    } else {
      push @addy, (all { $_ eq "." } @$_) ? $by : 0;
    }
  }

  for (my $i = 0; $i < @v; ++$i) {
    push @addx, (all { $_ eq "." } map { $_->[$i] } @v) ?
      (defined $addx[-1] ? $addx[-1] : 0) + $by
      : (defined $addx[-1] ? $addx[-1] : 0)
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

  my $sum = 0;
  for (@pairs) {
    my @xs = ($_->[0]->x, $_->[1]->x);
    my @ys = ($_->[0]->y, $_->[1]->y);
    $sum += (max(@xs)-min(@xs)) + (max(@ys)-min(@ys));
  }

  say $p2 ? "p2: " : "p1: ", $sum
}

sub p2 {
  p1 "okay";
}

p1;
p2;
