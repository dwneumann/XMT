#!/bin/perl -w
#************************************************************************
#   $Version:$
#   Package	: XMT_util
#   Synopsis	: renum.pl <n>
#   Purpose	: sequentially renumbers field <n> (one-based) of each 
#   		  input line & prints the resulting output on stdout.
#
#   Copyright 2017 Visionary Research Inc.  All rights reserved.
#************************************************************************

use Getopt::Long;
use Env;

($pgmname = $0) =~ s{.*/}{};
$usage		= "usage: $pgmname <n>\n";
die "$usage" if $#ARGV != 0;
$fieldnum = $ARGV[0];
$fieldnum = $fieldnum-1; # convert to zero-based

while (<STDIN>)
{
    @line = split( /\s+/, $_);			# split line by whitespace
    $oldnum = $line[$fieldnum];
    if (!defined $newnum)
    {
	$newnum = $oldnum;
    }
    else
    {
	$newnum++;
    }
#    $_ = join(' ', @line[0 .. $fieldnum-1]) . "\t" . $newnum 
#    		. "\t" . join(' ', @line[$fieldnum+1 .. $#line]);
    $_ =~ s/(.*\s+)$oldnum(\s+.*)$/$1$newnum$2/;
    print $_ ;
}
