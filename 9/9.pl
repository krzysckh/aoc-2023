#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use List::Util qw(all zip reduce);

open my $f, '<', "./in" or die $@;

sub p1 {
  my $sum = 0;
  while (<$f>) {
    my @n = split / /;
    my @lasts;
    while (1) {
      push @lasts, $n[-1];
      my @pairs = zip \@n, [map { $_ } @n[1..@n-1]];
      pop @pairs;
      @n = map { $_->[1] - $_->[0] } @pairs;
      last if all { $_ == 0 } @n;
    }

    $sum += reduce { $a + $b } @lasts;
  }

  say "p1: $sum";
}

sub p2 {
  my $sum = 0;
  while (<$f>) {
    my @n = split / /;
    my @firsts;
    while (1) {
      push @firsts, $n[0];
      my @pairs = zip [map { $_ } @n[1..@n-1]], \@n;
      pop @pairs;
      @n = map { $_->[1] - $_->[0] } @pairs;
      last if all { $_ == 0 } @n;
    }

    $sum += reduce { $a + $b } @firsts;
  }

  say "p2: $sum";
}

p1;
seek $f, 0, 0;
p2;

close $f;
