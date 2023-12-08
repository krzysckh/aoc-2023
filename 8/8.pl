#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use Class::Struct;
use List::Util qw(all);
use Math::Utils qw(lcm);

open my $f, '<', "./in" or die $@;

use Data::Printer;

sub p1 {
  my %map;
  my ($ctr, $cur) = (0, "AAA");

  my @instr = grep { not /\s/ } split //, <$f>;
  <$f>; # \n

  while (<$f>) {
    /(\w+) = \((\w+), (\w+)\)/;
    $map{$1} = [$2, $3];
  }

  while (1) {
    $cur = $instr[$ctr++ % @instr] eq "L" ? $map{$cur}->[0] : $map{$cur}->[1];
    last if $cur eq "ZZZ";
  }

  say "p1: $ctr";
}

sub p2 {
  my (%map, @start, @lengths, @instr);
  my $ctr = 0;

  @instr = grep { not /\s/ } split //, <$f>;
  <$f>; # \n

  while (<$f>) {
    /(\w+) = \((\w+), (\w+)\)/;
    $map{$1} = [$2, $3];
  }

  push @start, $_ for grep { /..A/ } keys %map;

  for (@start) {
    $ctr = 0;
    while (1) {
      $_ = $instr[$ctr++ % @instr] eq "L" ? $map{$_}->[0] : $map{$_}->[1];
      last if /..Z/
    }
    push @lengths, $ctr;
  }
  say "p2: ", lcm @lengths;
}

p1;
seek $f, 0, 0;
p2;

close $f;
