#!/usr/bin/perl

use strict;

my @files = @ARGV;

my $MAX_A_FRAC = 0.9;

foreach my $f (@files)
{
    # Open input
    die "Can't read $f\n" unless (open(IN,$f));

    # Open outputs
    my $outpolya = $f; $outpolya =~ s/\.(\w+)$/.contam.polya\.$1/g;
    die "Can't write to $outpolya\n" unless (open(OUTPOLYA,">$outpolya"));
    my $outadapters = $f; $outadapters =~ s/\.(\w+)$/.contam.adapters\.$1/g;
    die "Can't write to $outadapters\n" unless (open(OUTADAPTERS,">$outadapters"));
    my $outnoc = $f; $outnoc =~ s/\.(\w+)$/.nocontam\.$1/g;
    die "Can't write to $outnoc\n" unless (open(OUTNOC,">$outnoc"));

    my $linecount_within = 1;
    my $linecount_global = 1;
    my $seq_so_far = '';
    my $seq_line = '';
    while (my $line = <IN>)
    {
	$seq_so_far .= $line;
	
	if ($linecount_within == 1)
	{
	    # Double check the format
	    print STDERR "Incorrect FASTQ file $f\nLine ${linecount_global}: $line\nMod4 lines should start with \@\n"
		unless ($line =~ /^\@/);
	}
	elsif ($linecount_within == 2)
	{
	    $seq_line = $line;
	}
	elsif ($linecount_within == 4)
	{
	    if ($seq_line =~ /^GATC[AG]GAAGAGCTCG/i) # Solexa adapter sequence
	    {
		print OUTADAPTERS $seq_so_far;
	    }
	    else
	    {
		if (aFrac($seq_line) > $MAX_A_FRAC)
		{
		    print OUTPOLYA $seq_so_far;
		}
		else
		{
		    print OUTNOC $seq_so_far;
		}
	    }
	    
	    # Reset our linecount
	    $seq_so_far = '';
	    $seq_line = '';
	    $linecount_within = 0;
	}

	# Increment
	$linecount_within++;
	$linecount_global++;
    }
    
    close (OUTPOLYA);
    close (OUTADAPTERS);
    close (OUTNOC);
    close (IN);
}


sub aFrac
{
    my ($seq) = @_;

    chomp $seq;
    $seq = uc($seq);

    my $len = length($seq);
    my $nA = scalar(grep {($_ eq 'A') || ($_ eq 'N')} split(//, $seq));

    my $frac = ($len==0) ? 0 : ($nA/$len);

    print STDERR join("\t", $seq, $len, $nA, $frac)."\n" if ($frac > $MAX_A_FRAC);
    return $frac;
}
