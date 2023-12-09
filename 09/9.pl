#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use List::Util qw(all zip reduce);

open my $f, '<', "./in" or die $@;

sub p1 {
  my ($p2) = @_;
  my $sum = 0;
  while (<$f>) {
    my @n = split / /;
    @n = reverse @n if $p2;
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
  p1 "yes yes yes";
}

p1;
seek $f, 0, 0;
p2;

close $f;
