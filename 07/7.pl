#!/usr/bin/perl

use strict;
no warnings; # lol
use feature qw(say);

use List::Util qw(max any);

use Class::Struct;
use constant {
  FIVE_K    => 6,
  FOUR_K    => 5,
  FULL_H    => 4,
  THREE_K   => 3,
  TWO_PAIR  => 2,
  ONE_PAIR  => 1,
  HIGH_CARD => 0
};

use Data::Printer;

struct(
  Hand => {
    cards => '@',
    pts => '$',
    vals => '%',
    rank => '$',
    orig => '$',
    T => '$'
  }
);

my %card2val = (
  A => 12, K => 11, Q => 10, J => 9, T => 8,
  9 => 7,  8 => 6,  7 => 5,  6 => 4, 5 => 3,
  4 => 2,  3 => 1,  2 => 0,
);

my %card2val2 = (
  A => 12, K => 11, Q => 10, T => 9, 9 => 8,
  8 => 7,  7 => 6,  6 => 5,  5 => 4, 4 => 3,
  3 => 2,  2 => 1,  J => 0,
);

open my $f, '<', "./in" or die $@;

sub gett {
  my ($hand) = @_;

  my @v = values %{$hand->vals};
  if ($v[0] == 5) { return FIVE_K }
  if (grep { /4/ } @v) { return FOUR_K }
  if (grep({ /3/ } @v) and grep({ /2/ } @v)) { return FULL_H }
  if (grep { /3/ } @v) { return THREE_K }
  if (grep({ /2/ } @v) > 1) { return TWO_PAIR }
  if (grep { /2/ } @v) { return ONE_PAIR }
  return HIGH_CARD;
}

# WARNING: ugly
sub gett2 {
  my ($hand) = @_;

  my $nj = $hand->vals->{0};
  $nj = 0 if not defined $nj;

  delete $hand->vals->{0};
  my @v = values %{$hand->vals};

  if ($v[0] == 5 or (max(@v) + $nj) == 5) { return FIVE_K }
  if (grep { /4/ } @v or any { $_ == 4 } map { $_ + max(@v) } 1..$nj) {
    return FOUR_K }

  if ($nj == 0) {
    if (grep({ /3/ } @v) and grep({ /2/ } @v)) { return FULL_H }
    if (grep { /3/ } @v) { return THREE_K }
    if (grep({ /2/ } @v) > 1) { return TWO_PAIR }
    if (grep { /2/ } @v) { return ONE_PAIR }
    return HIGH_CARD;
  }

  if (any { $_ == 3 } map { $_ + max(@v) } 1..$nj) {
    my $nj_now = $nj - (3 - max(@v));
    my @tmp = ();
    my $first = 1;
    for (@v) {
      if (max(@v) == $_ and $first) {
        $first = 0
      } else {
        push @tmp, $_
      }
    }
    if (1 == @tmp) {
      return FULL_H;
    } else {
      return FULL_H if any { $_ == 2 } map { max(@tmp) + $_ } 1..$nj_now;
    }

    return THREE_K;
  }

  return TWO_PAIR if $nj > 1;
  return ONE_PAIR
}

sub k_sort_fn {
  my ($a, $b) = @_;
  my $f = $a->T <=> $b->T;

  return $f if $f;

  for (0..4) {
    my $v = $a->cards->[$_] <=> $b->cards->[$_];
    return $v if $v;
  }

  die "what";
}

sub p1 {
  my ($p2) = @_;
  my @hands;
  while (<$f>) {
    my ($hv, $pts) = /(.{5}) (\d+)/;
    my $hand = Hand->new(
      orig => $hv,
      pts => $pts,
      cards => [map { $p2 ? $card2val2{$_} : $card2val{$_} } split //, $hv]
    );
    my %vals;
    map { $vals{$_}++ } @{$hand->cards};
    while (my ($k, $v) = each %vals) {
      $hand->vals($k, $v);
    }

    $hand->T($p2 ? gett2 $hand : gett $hand);
    push @hands, $hand;
  }

  @hands = sort { k_sort_fn $a, $b } @hands;
  my $sum;
  $sum += (1 + $_) * $hands[$_]->pts for 0..@hands - 1;

  say $p2 ? "p2: " : "p1: ", $sum;
}

sub p2 {
  p1 "hmmmm......";
}

p1;
seek $f, 0, 0;
p2;

close $f;
