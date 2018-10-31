#!/bin/perl -w
#************************************************************************
#   $Version:$
#   Package	: xmt_util
#   Synopsis	:
#   Purpose	: 
#
#   Copyright 2018 Visionary Research Inc.  All rights reserved.
#************************************************************************

use Getopt::Long;
use Env;

($pgmname = $0) =~ s{.*/}{};
$usage		= "usage: $pgmname [-u]\n";
undef $opt_u;	# unnecessary, but it shuts up -w
GetOptions( "u" ) || die $usage;
die "$usage" if defined $opt_u;

local $/ = undef;
$contents	= <STDIN>;

$replacement = 'char csv_mode; 
  int main(int argc, char **argv)	
  { 
  csv_mode = (strcmp(argv[argc-1], "-csv") == 0 ? 1 : 0 );
';

$contents =~ s/^int main().*{/$replacement/sm;
print STDOUT $contents;
