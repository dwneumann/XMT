#!/usr/local/bin/perl -w
#************************************************************************
#*   $Version:$
#*   Package	: xmt_xtest
#*   Purpose	: Xtest class (invoked by xtest)
#*
#   Copyright (c) 2018  Visionary Research Inc.
#                       legal@visionary-research.com
#*  Licensed under the Apache License, Version 2.0 (the "License");
#*  you may not use this file except in compliance with the License.
#*  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#*  
#*  Unless required by applicable law or agreed to in writing, software
#*  distributed under the License is distributed on an "AS IS" BASIS,
#*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#*  See the License for the specific language governing permissions and
#*  limitations under the License. 
#************************************************************************/

package XMT::Xtest;
use Expect;
use Path::Tiny qw(path);
use Carp;
use Digest::CRC qw(crc16);

sub version 
{
    local $^W=0; 
    my @v = split(/\s+/,'$Version:$'); 
    my $s=sprintf("%f", $v[1]);
    $s=~ s/0+$//;
    return $s;
}
$VERSION = &version;

$Xtest::PASS	= "PASS";	# scalar value to return upon test pass
$Xtest::FAIL	= "FAIL";	# scalar value to return upon test fail
$Xtest::timeout	= 30;		# timeout in seconds for each command-response

#************************************************************************/
# class method new($f, $$bufp) 
# instantiates a new Xtest object with options specified.
# Returns the handle to the object or undef on error.
#************************************************************************/
sub new
{
    my ($opts) = @_;
    my $self = {};

    if ( !defined $opts->{iut} )  { carp( "iut undefined");  return undef; }
    if ( !defined $opts->{test} ) { carp( "test undefined"); return undef; }
    $self->{testfile}	= $opts->{test}  or carp( "test undefined") && return undef;
    $self->{iut} = $opts->{iut};

    # parse the test file or die trying
    push @{$self->{cmds}}, _parsetestfile($self->{testfile}) or return undef;

    # instantiate an Expect session and prepare it for run
    $self->{exp} = new Expect();
    $self->{exp}->log_stdout(1);
    $self->{exp}->raw_pty(1);
    $self->{exp}->restart_timeout_upon_receive(1);
    $self->{exp}->log_file($opts->{log}, "w")	if defined $opts->{log};
    $self->{exp}->exp_internal(1)		if defined $opts->{log};
    $self->{exp}->debug(2)			if defined $opts->{log};
    $self->{exp}->spawn($self->{iut});

    bless $self;
    return $self;
}
 
#************************************************************************
# stub DESTROY so the autoloader won't search for it.
#************************************************************************
sub DESTROY { }

#************************************************************************
# instance method runs the test sequence on the iut.
# returns scalar PASS/FAIL result.
#************************************************************************
sub run
{
    my $self = shift;

    # test file has been parsed into a sequence of blocks to be eval'd.
    # now iterate through the sequence & execute them.
    my ($fn, $seqnum, $buf);
    while ($s = shift @{$self->{cmds}})
    {
	($fn, $seqnum, $buf)	= ($s->{fn}, $s->{seqnum},  $s->{buf});

	# if cmd looks like a Perl comment, ignore the line ...
	next if ( $s->{buf} =~ m/^\s*#/ );

	# if cmd looks like an include stmt, parse nested file & add to cmd sequence
	if ( $s->{buf} =~ m/^\s*INCLUDE\s+"?(\S+)"?/i )
	{
	    my @nested_cmds = _parsetestfile($1)	or return $Xtest::FAIL;
	    unshift @{$self->{cmds}}, @nested_cmds;
	    my %new_cmd = ( 'fn'=>$fn, 'seqnum'=>$s->{seqnum}, 'buf'=>"# " . $1 );
	    unshift @{$self->{cmds}}, \%new_cmd;
	    next;
	}

	# if cmd looks like a SEND block, extract cmd string then eval it.
	if ( $s->{buf} =~ m:SEND\s*\(\s*"(\S+)"\s*\)\s*;:i )
	{
	    #$s->{buf} =~ s/SEND\s*\(/\$self->{exp}->send(/; 
	    $s->{buf} = $1; 
	    $self->{exp}->send($s->{buf}); 
	    next;
	}

	# if cmd looks like a EXPECT block, extract pattern then eval it.
	if ( $s->{buf} =~ m:EXPECT\s*\(\s*\/(.*)\/\s*\):i )
	{
	    $self->{exp}->clear_accum();
	    #$s->{buf} =~ s/EXPECT\s*\(/\$self->{exp}->expect($Xtest::timeout, -re, /; 
	    $s->{buf} = "/$1/s";
	    $self->{exp}->expect($Xtest::timeout, -re, $s->{buf} );

	    #if we did't get what we expected that's a FAIL
	    if ( ! $self->{exp}->match() )
	    {
		my $rc = $self->{exp}->error();		# useful for debugging
		my $before = $self->{exp}->before();	# useful for debugging
		carp "$fn:\tcommand #seqnum:\t$Xtest::FAIL";
		$self->{exp}->log_file(undef);
		$self->{exp}->hard_close();
		return $Xtest::FAIL;
	    }
	    next;
	}
    }
    # terminate the test gracefully
    $self->{exp}->hard_close();
    return $Xtest::PASS;
}

#************************************************************************
# private method _parsetests reads a test file into an array of hashes.
# Each hash entry contains the filename, line #, and a block  { ... } which 
# is to be evaluated as a single expect send/receive pair.
#************************************************************************
sub _parsetestfile
{
    my ($fn) = @_;
    my $contents;
    $contents = path($fn)->slurp or carp "$fn: $!\n" && return undef;
    my @array;

    my @seqs = $contents =~ /( \{ (?: [^{}]* | (?0) )* \} )/xg; # split into closures
    # push file name, seq# & contents onto stack 
    my $i = 1;	# 1-based line/sequence # counting for reporting errors to user
    foreach $buf (@seqs)
    {
	my %seq = ('fn' =>$fn, 'seqnum'=>$i, 'buf'=>$buf);
	push @array, \%seq;
	$i++;
    }
    return @array;
}

1;  # ensure class eval returns true;
