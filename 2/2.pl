#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw(max);

use feature 'say';

open my $f, '<', "./in" or die $@;

sub p1 {
  my ($p2) = @_;
  my $sum = 0;
  while (<$f>) {
    my %max = (red => 0, green => 0, blue => 0);
    my $id = [/^Game (\d+)/g]->[0];
    s/^Game .*: //;

    $max{$_->[1]} = max $max{$_->[1]}, $_->[0] for map { [/(\d+)\s(.*)/g] } split /,|;\s?/;

    if (not $p2) {
      $sum += $id if $max{red} <= 12 && $max{green} <= 13 && $max{blue} <= 14;
    } else {
      $sum += $max{red} * $max{green} * $max{blue};
    }
  }

  say $p2 ? "p2" : "p1", ": $sum"
}

sub p2 {
  p1 1
}

p1;
seek $f, 0, 0;
p2;

close $f;
