#!/usr/bin/env perl
use strict;
use warnings;

my $seconds = shift @ARGV;
die "usage: $0 SECONDS COMMAND [ARG ...]\n" unless defined $seconds && @ARGV;

$SIG{ALRM} = sub { exit 124 };
alarm $seconds;
system @ARGV;
exit($? == -1 ? 127 : $? >> 8);
