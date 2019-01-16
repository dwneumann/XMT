#!/usr/local/bin/perl -w
#************************************************************************
#*   $Version:$
#*   Package	: xmt_wbtest
#*   Purpose	: Xtest class (invoked by wbtest)
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
local %filemap = ();	

$Xtest::errstr	= "";
my $timeout	= 60;		# timeout in seconds for each command-response

#************************************************************************/
# class method new($f, $$bufp) 
# instantiates a new Xtest object with options specified.
# Returns the handle to the object.
#************************************************************************/
sub new
{
    my ($opts) = @_;
    my $self = {};

    $self->{iut}	= $opts->{iut}   or $Xtest::errstr = "iut undefined" && return undef;
    $self->{testfile}	= $opts->{test}  or $Xtest::errstr = "test undefined" && return undef;
    _loadtest($self)	or return undef;


    # instantiate an Expect session
    $self->{exp} = new Expect;
    $self->{exp}->exp_internal(1)		if defined $opt->{verbose};
    $self->{exp}->debug(2)			if defined $opt->{debug};
    $self->{exp}->log_stdout(0);
    $self->{exp}->raw_pty(1);
    $self->{exp}->restart_timeout_upon_receive(1);

    bless $self;
    return $self;
}
 
#************************************************************************
# stub DESTROY so the autoloader won't search for it.
#************************************************************************
sub DESTROY { }

#************************************************************************
# private method recursively reads nested test files
#************************************************************************
sub _loadtest
{
    my $self = shift;

    # push test file name, line# & contents onto stack 
    my (@tests, @lines, $fh, $testfn, $linenum);
    push @tests {'fn'	=>$opt{test},
		 'line'	=> 0,
		 'buf'	=> path($opt{test})->slurp
		}	or die "$opt{test}: $!\n";
    while ( @tests )
    {
	open $fh, "<", \$tests[0]{fn}	or die "cannot open string as file\n";
	while (<$fh>)			# read lines as if they were read from file
	{
	    if ( /^\s*#/ )			# ignore lines beginning with hash 
	    {
		$tests[0]{line}++;
	    }
	    elsif ( /^include\s+(.*)/)	# push included file contents onto top of stack
	    {
		$tests[0]{line}++;
		unshift @tests, {	'fn'	=> $1,
				    'line'	=> 0,
				    'buf'	=> path($1)->slurp
				}	or die "$1: $!\n";
	    }
	    else
	    {
		push @lines {	'fn'	=> $tests[0]{fn},
				    'line'	=> $tests[0]{line},
				    'buf'	=> $_
			    };
	    }
	}
	close $fh;
    }
}

sub run
{
    # test file has been read & nested includes have been processed.
    # now itewrate through the sequential list of commands
    while ( @lines )			# send/expect cmd sequence to/from the iut
    {
	my ($fn, $line, $buf) = shift @lines;
	my ($cmd, $restofline) =~ /\s*(\S+)\s+(.*)/ $buf;
	if ( $cmd =~ /send/i )
	{
	    $session->send(eval $restofline); 
	}
	elsif ( $cmd =~ /expect/i )
	{
	    # get the lines returned by the iut 
	    $session->clear_accum();
	    $session->expect($timeout, -re, $restofline); 
	    if ( !defined $session->match() )
	    {
		printf($resfh "FAIL : %s:%d (%s)\n", $fn, $line, $restofline);
	    }
	}

    }
    # terminate the test gracefully
    $session->soft_close();
}

1;
