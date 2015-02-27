#!/usr/bin/perl

use strict;

die "Please set GENOME_BIN" unless ($ENV{'GENOME_BIN'});

my $USAGE = "wrap_maq_fastq2bfq.pl a.fq a.bfq";

# Argumetns
die "$USAGE\n" unless (@ARGV == 2);
my ($infile, $outfile) = @ARGV;

# Check that input exists
die "wrap_maq_fastq2bfq: input file ${infile} is 0 length\n" unless (-s $infile);

# Run
chomp(my $ARCH = `uname -m`);
my $exe = join("/", $ENV{'GENOME_BIN'},$ARCH,"maq");
my $cmd = join(" ", $exe,"fastq2bfq",@ARGV);
print STDERR "${cmd}\n";
print STDERR `${cmd} 2>&1`;

# Check that the output exists
die "wrap_maq_fastq2bfq: output file ${outfile} is 0 length\n" unless (-s $outfile);

