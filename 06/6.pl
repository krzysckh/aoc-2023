#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use Class::Struct;

open my $f, '<', "./in" or die $@;

sub p1 {
  my @times = <$f> =~ /\d+/g;
  my @distances = <$f> =~ /\d+/g;
  my $acc = 1;

  for (0..@times - 1) {
    my $max_time = shift @times;
    my $max_dist = shift @distances;
    my $sum = 0;
    for (my $time = $max_time; $time >= 0; $time--) {
      $sum++ if ($max_time - $time) * $time > $max_dist;
    }

    $acc *= $sum;
  }

  say "p1: $acc"
}

sub p2 {
  my $max_time = join '', <$f> =~ /\d+/g;
  my $max_dist = join '', <$f> =~ /\d+/g;

  my $sum = 0;
  for (my $time = $max_time; $time >= 0; $time--) {
    $sum++ if ($max_time - $time) * $time > $max_dist;
  }

  say "p2: $sum"
}

p1;
seek $f, 0, 0;
p2;

close $f;
