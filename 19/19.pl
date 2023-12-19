#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use Data::Printer;

open my $f, '<', './in';

sub p1 {
  my ($sum, %rules);
  while (<$f>) {
    last if /^$/;
    my @cur;
    my ($nam, $opt) = /^(.*)\{(.*)\}$/;
    my @opts = split ",", $opt;

    for (@opts) {
      if (my ($v, $op, $val, $then) = /(.*)([<>])(.*):(.*)/) {
        push @cur, "\$$v $op $val ? \"$then\" : undef"
      } else {
        push @cur, "\"$_\""
      }
    }
    $rules{$nam} = \@cur;
  }

  while (<$f>) {
    my ($x, $m, $a, $s) = /\{x=(.*),m=(.*),a=(.*),s=(.*)\}/;
    my $cur = "in";
    while (1) {
      my @e = @{$rules{$cur}};
      for my $c (@e) {
        $_ = eval $c;
        if (defined $_) {
          $cur = $_;
          last;
        }
      }

      if ($cur eq "A") {
        $sum += $x + $m + $a + $s;
        last;
      }
      last if $cur eq "R";
    }
  }

  say "p1: $sum";
}

sub p2 {
}

p1;
seek $f, 0, 0;
p2;

close $f;
