#!/usr/bin/perl

use strict;
use warnings;

open my $f, '<', "./in" or die $@;

sub p1 {
  my $sum = 0;
  $sum += 0 + /^.*?(\d).*(\d).*$/g ? $1 . $2 : [/(\d)/g]->[0] x 2 while <$f>;

  print "p1: $sum\n"
}

sub p2 {
  my $sum = 0;
  my %dig = (
    one => 1, two => 2, three => 3, four => 4, five => 5, six => 6, seven => 7,
    eight => 8, nine => 9, 0 => 0, 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5,
    6 => 6, 7 => 7, 8 => 8, 9 => 9
  );

  my $r = "(?:(?:one)|(?:two)|(?:three)|(?:four)|(?:five)|(?:six)|(?:seven)|(?:eight)|(?:nine))";

  $sum += 0 + /^.*?(\d|$r).*(\d|$r).*$/g ? $dig{$1} . $dig{$2} : [/(\d|$r)/g]->[0] x 2 while <$f>;
  print "p2: $sum\n"
}

p1;
seek $f, 0, 0;
p2;

close $f;
