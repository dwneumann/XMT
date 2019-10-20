#!/usr/bin/env perl
#************************************************************************
#   $Version:$
#   Package	: xmt_util
#   Synopsis	: mkapache <file> <file> ...
#   Purpose	: convert GNU GPL license reference to Apache in place
#
#************************************************************************

$apache = <<'__END__';
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. 
__END__

foreach $f (@ARGV)
{
    print STDERR "$f ...\n";
    rename "$f", "$f.BAK";
    my @lines = `cat $f.BAK`;
    open( OUTFILE, ">$f" ) or  die "$f: $!\n";

    foreach $_ (@lines)
    {
	next if /Exclusion of warranty governed by the .*/;

	if ( /(^\S*\s*)Rights & restrictions governed by the .*/ )
	{
	    my $delim = $1;
	    s/.*/$apache/;
	    s/^/$delim/gm;
	}
	print OUTFILE $_;
    }
    close OUTFILE;
}

