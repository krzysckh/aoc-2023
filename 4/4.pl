#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use Class::Struct;

open my $f, '<', "./in" or die $@;

sub intersect {
  my @a = @{shift @_};
  my @b = @{shift @_};

  grep { $a = $_; grep { $a eq $_ } @b } @a;
}

sub p1 {
  my $sum = 0;
  while (<$f>) {
    my ($id, $w, $y) = /^Card\s+(\d+):\s+(.*)\s+\|\s+(.*)/g;
    my @inter = intersect[split /\s+/, $w], [split /\s+/, $y];
    my $n = @inter > 0;
    $n *= 2 for 2..@inter;
    $sum += $n;
  }

  say "p1: $sum"
}

sub p2 {
  struct(
    Card => {
      id => '$',
      winning => '@',
      n => '$'
    }
  );
  my ($sum, @cards);

  while (<$f>) {
    my ($id, $w, $y) = /^Card\s+(\d+):\s+(.*)\s+\|\s+(.*)/g;
    push @cards, Card->new(id => $id, n => 1,
      winning => [intersect [split /\s+/, $w], [split /\s+/, $y]]);
  }

  for my $cur (0..@cards - 1) {
    $cards[$cur + $_]->n($cards[$cur + $_]->n + $cards[$cur]->n)
      for 1..@{$cards[$cur]->winning};
  }

  $sum += $_->n for @cards;
  say "p2: $sum"
}

p1;
seek $f, 0, 0;
p2;

close $f;
