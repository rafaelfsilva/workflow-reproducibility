#!/usr/bin/perl

use strict;

die "Please set GENOME_BIN" unless ($ENV{'GENOME_BIN'});

my $USAGE = "wrap_maqindex.pl \@args in.map chr21 chr21.rev out.map";

# Argumetns
die "$USAGE\n" unless (@ARGV >= 4);
my $outfile = pop(@ARGV);
my $rev = pop(@ARGV);
my $chr = pop(@ARGV);
my $infile = pop(@ARGV);

# Check that input exists
die "wrap_maqindex: input file ${infile} is 0 length\n" unless (-s $infile);

# Run
chomp(my $ARCH = `uname -m`);
my $exe = join("/", $ENV{'GENOME_BIN'},$ARCH,"maqindex");
my $cmd = join(" ", $exe,@ARGV, $infile, $chr, $rev);
print STDERR "${cmd}\n";
print STDERR `${cmd} 3>/dev/stdout 1>$outfile 2>&3`;

# Check that the output exists
die "wrap_maqindex: output file ${outfile} is 0 length\n" unless (-s $outfile);

