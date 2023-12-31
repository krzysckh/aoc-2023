#!/usr/bin/perl

use strict;
no warnings;
use feature 'say';

use Class::Struct;
use List::Util qw(all);
use Math::Utils qw(lcm);

open my $f, '<', "./in" or die $@;

sub p1 {
  my ($ctr, $cur) = (0, "AAA");
  my %map;

  my @instr = grep { not /\s/ } split //, <$f>;
  <$f>; # \n

  $map{$1} = [$2, $3] while <$f> =~ /(\w+) = \((\w+), (\w+)\)/;

  while (1) {
    $cur = $instr[$ctr++ % @instr] eq "L" ? $map{$cur}->[0] : $map{$cur}->[1];
    last if $cur eq "ZZZ";
  }

  say "p1: $ctr";
}

sub p2 {
  my (%map, @start, @lengths, @instr, $ctr);

  @instr = grep { not /\s/ } split //, <$f>;
  <$f>; # \n

  $map{$1} = [$2, $3] while <$f> =~ /(\w+) = \((\w+), (\w+)\)/;
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
