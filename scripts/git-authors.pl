#!/usr/bin/perl
use strict;
use warnings;

my $cmd = q(git --no-pager log --format='%H %aN <%aE>' --no-merges --shortstat );

open(GITOUT, "-|", $cmd . join(" ", @ARGV));

my ($commit, $author);

my $total_commits = 0;
my $commits = {};
my $inserts = {};
my $deletes = {};

while($_ = <GITOUT>) {
    chomp;

    if (/^([0-9a-f]{40}) (.+)$/) {
        $commit = $1;
        $author = $2;
        $total_commits++;
    }
    elsif (/(\d+) insert.* (\d+) delet*/) {

        ($commits->{$author} ||= 0) += 1;
        ($inserts->{$author} ||= 0) += ($1||0);
        ($deletes->{$author} ||= 0) += ($2||0);
    }
}

my @authors = sort {
    $commits->{$b} <=> $commits->{$a} ||
    ($inserts->{$b} + $deletes->{$b}) <=> ($inserts->{$a} + $deletes->{$a})
} keys %$commits;

printf "%8s %8s %8s %8s\n", "commits%", "commits", "+++", "---";
for my $author (@authors) {
    printf "%7.2f%% %8d %8s %8s  %s\n", 100*$commits->{$author}/$total_commits, $commits->{$author}, "+".$inserts->{$author}, "-".$deletes->{$author}, $author;
}

