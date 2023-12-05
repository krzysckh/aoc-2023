#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use Class::Struct;
use List::Util qw(min max);

open my $f, '<', "./in" or die $@;

use Data::Printer;

struct(
  Mapping => {
    from => '$',
    to => '$',
    diff => '$'
  }
);

struct(
  Map => {
    name => '$',
    mappings => '@',
  }
);

sub apply_mapping {
  my ($map, $n) = @_;

  for (@{$map->mappings}) {
    if ($n >= $_->from && $n <= $_->to) {
      return $n + $_->diff;
    }
  }

  return $n;
}

sub p1 {
  my @seeds = split / /, [<$f> =~ /seeds: (.*)/]->[0];
  my @maps;
  <$f>; # \n

  while (<$f>) {
    my $map = Map->new;
    $map->name([/(.*) map:/]->[0]);

    while (<$f>) {
      last if /^$/;
      my ($dr, $sr, $r) = /(\d+) (\d+) (\d+)/;
      my $mapping = Mapping->new(
        from => $sr,
        to => $sr + $r - 1,
        diff => $dr - $sr
      );
      push @{$map->mappings}, $mapping;
    }

    push @maps, $map;
  }

  my @soil = map { apply_mapping $maps[0], $_ } @seeds;
  my @fert = map { apply_mapping $maps[1], $_ } @soil;
  my @watr = map { apply_mapping $maps[2], $_ } @fert;
  my @ligh = map { apply_mapping $maps[3], $_ } @watr;
  my @temp = map { apply_mapping $maps[4], $_ } @ligh;
  my @humi = map { apply_mapping $maps[5], $_ } @temp;
  my @loca = map { apply_mapping $maps[6], $_ } @humi;

  say "p1: " . min @loca;
}

sub p2 {
  my @pairs = [<$f> =~ /seeds: (.*)/]->[0] =~ /(\d+ \d+)/g;
  my @seed_ranges;
  for (@pairs) {
    my ($f, $n) = split / /, $_;
    push @seed_ranges, [$f, $f + $n - 1];
  }
  my @maps;
  <$f>; # \n

  while (<$f>) {
    my $map = Map->new;
    $map->name([/(.*) map:/]->[0]);

    while (<$f>) {
      last if /^$/;
      my ($dr, $sr, $r) = /(\d+) (\d+) (\d+)/;
      my $mapping = Mapping->new(
        from => $dr,
        to => $dr + $r - 1,
        diff => -$dr + $sr
      );
      push @{$map->mappings}, $mapping;
    }

    push @maps, $map;
  }

  find: for (0..max(map { $_->[1] } @seed_ranges)) {
    if ($_ % 10000 == 0) {
      say "$_...";
    }
    my $loc = $_;
    my $hum   = apply_mapping($maps[6], $loc);
    my $temp  = apply_mapping($maps[5], $hum);
    my $light = apply_mapping($maps[4], $temp);
    my $water = apply_mapping($maps[3], $light);
    my $fert  = apply_mapping($maps[2], $water);
    my $soil  = apply_mapping($maps[1], $fert);
    my $seed  = apply_mapping($maps[0], $soil);
    for (@seed_ranges) {
      if ($seed >= $_->[0] && $seed <= $_->[1]) {
        say "p2: $loc";
        die;
      }
    }
  }
  say "oki"
}

p1;
seek $f, 0, 0;
p2;

close $f;
