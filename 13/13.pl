#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use File::Slurp qw(read_file);
use List::Util qw(all min);
use IO::Handle;
use Text::Levenshtein qw(distance);

open my $f, '<', './in';
our $PT2 = 0;

sub chk {
  my @cur = @_;

  for my $n (0..@cur-1) {
    my $l1 = join "", reverse @cur[0..$n];
    my $l2 = join "", @cur[$n+1..@cur-1];

    last if length $l1 < 1 or length $l2 < 1;
    if (length $l1 < length $l2) {
      ($l1, $l2) = ($l2, $l1);
    }

    my $filled = $l2 . substr $l1, length $l2;

    if ($PT2) {
      if (distance($l1, $filled) == 1) {
        print ".";
        stdout->flush();

        return $n+1
      }
    } else {
      if ($l1 =~ /^$l2/) {
        return $n+1
      }
    }
  }

  return 0;
}

sub p1 {
  my $sum = 0;
  while (not eof $f) {
    my (@vmap, @hmap);

    while (<$f>) {
      chomp;
      s/\./,/g;
      last if /^$/;
      push @hmap, $_;
    }

    for my $n (0..length($hmap[0]) - 1) {
      push @vmap, join("", map { substr $hmap[$_], $n, 1 } (0..@hmap-1));
    }

    $sum += 100 * chk @hmap;
    $sum += chk @vmap;
  }

  print "\n" if $PT2;
  say $PT2 ? "p2: " : "p1: ", $sum
}

sub p2 {
  $PT2 = "well, yes";
  p1;
}

p1;
seek $f, 0, 0;
p2;

close $f;
