#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use File::Slurp qw(read_file);
use List::MoreUtils qw(uniq);

# ugly...

sub N {
  my @A = @{shift @_};
  my @ns = map {($_) x length $_} join('', @A) =~ /(\d+)/g;

  for (my $i = 0; $i < @A; ++$i) {
    $A[$i] = shift @ns if $A[$i] =~ /\d/;
  }

  @A
}

sub S {
  my $v = shift @_;
  return 0 if not defined $v;
  $v =~ /[^0-9.]/
}

sub p1 {
  my @map;
  push @map, [map { N $_ } [split //, $_]] for split /\n/, read_file "in";
  my ($sum, $sz) = (0, scalar @map);

  for (my $i = 0; $i < $sz; ++$i) {
    my $had = 0;
    for (my $j = 0; $j < $sz; ++$j) {
      if ($map[$i][$j] =~ /\d/) {
        if (($j > 0 ? S $map[$i][$j-1] : 0)
            or (S $map[$i][$j+1])
            or ($i > 0 ? S $map[$i-1][$j] : 0)
            or (S $map[$i+1][$j])
            or ($i > 0 and $j > 0 ? S $map[$i-1][$j-1] : 0)
            or ($i > 0 ? S $map[$i-1][$j+1] : 0)
            or ($j > 0 ? S $map[$i+1][$j-1] : 0)
            or (S $map[$i+1][$j+1])) {

          if (not $had) {
            $had = 1;
            $sum += $map[$i][$j] 
          }
        }
      } else {
        $had = 0;
      }
    }
  }

  say "p1: ", $sum;
}

sub p2 {
  my @map;
  push @map, [map { N $_ } [split //, $_]] for split /\n/, read_file "in";
  my ($sum, $sz) = (0, scalar @map);

  for (my $i = 0; $i < $sz; ++$i) {
    for (my $j = 0; $j < $sz; ++$j) {
      if ($map[$i][$j] eq "*") {
        my @v = uniq grep /\d/,
                  (($j > 0 ? $map[$i][$j-1] : undef),
                   ($map[$i][$j+1]),
                   ($i > 0 ? $map[$i-1][$j] : undef),
                   ($map[$i+1][$j]),
                   ($map[$i+1][$j+1]),
                   ($j > 0 ? $map[$i+1][$j-1] : undef),
                   ($i > 0 ? $map[$i-1][$j+1] : undef),
                   ($i > 0 and $j > 0 ? $map[$i-1][$j-1] : undef));
        # bold assumption that there's no 2 equal numbers
        # in my case, it's true tho
        $sum += $v[0] * $v[1] if @v == 2
      }
    }
  }
  say "p2: $sum";
}

p1;
p2;
