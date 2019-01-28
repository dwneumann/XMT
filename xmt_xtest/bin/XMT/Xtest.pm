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
# class method new(\%opts)
# instantiates a new Xtest object with options specified.
# Returns the handle to the object or undef on error.
#************************************************************************/
sub new
{
    my ($opts) = @_;
    my $self = {};

    $self->{srcfn}	= $opts->{fname}  or carp "input filename undefined" & return undef;
    $self->{srcbuf}	= $opts->{srcbuf} or carp "input stream undefined"   & return undef;
    $self->{iut}	= $opts->{iut} 		if defined $opts->{iut};
    $self->{testfile}	= $opts->{test} 	if defined $opts->{test};
    $self->{verbose}	= (defined $opts->{verbose} ? 1 : 0);
    $self->{testfile}	= undef;
    $self->{iut}	= undef;
    $self->{exp} 	= undef;
    bless $self;
    return $self;
}
 
#************************************************************************
# stub DESTROY so the autoloader won't search for it.
#************************************************************************
sub DESTROY { }

#************************************************************************/
# class method loadtest()
# reads test file & initializes expect session in preparationfor runtest()
# Returns undef on error.
#************************************************************************/
sub loadtest
{
    my $self = shift;		

    # parse the test file or die trying
    push @{$self->{cmds}}, _parsetestfile($self->{testfile}) or return undef;

    # instantiate an Expect session and prepare it for run
    $self->{exp} = new Expect();
    $Expect::Multiline_Matching = 0;
    $self->{exp}->log_stdout(0);
    $self->{exp}->raw_pty(1);
    $self->{exp}->restart_timeout_upon_receive(1);
    $self->{exp}->exp_internal(1)		if defined $opts->{debug};
    $self->{exp}->debug(2)			if defined $opts->{debug};
    $self->{exp}->spawn($self->{iut});
}
 
#************************************************************************
# instance method runtest executes the test sequence on the iut.
# returns scalar PASS/FAIL result.
#************************************************************************
sub runtest
{
    my $self = shift;		# visible inside eval blocks
    local @nested_cmds; 	# visible inside eval blocks

    # test file has been parsed into a sequence of blocks to be eval'd.
    # now iterate through the sequence & execute them.
    local ($fn, $seqnum, $buf);	#local copies ...
    while ($s = shift @{$self->{cmds}})
    {
	($fn, $seqnum, $buf)	= ($s->{fn}, $s->{seqnum},  $s->{srcbuf});
	$fn =~ s:(.*/)([^/]*$):$2:;	# for verbose messages chop long filepaths.

	# strip comments; if there's nothing left, go on to the next block.
	$s->{srcbuf} =~ s/#.*$//mg;
	next if ( $s->{srcbuf} =~ m/^[\s\n]*$/ );

	# if buf looks like an include stmt, parse nested file & add to cmd sequence
	if ( $s->{srcbuf} =~ m:INCLUDE\s*\(: )
	{
	    $s->{srcbuf} =~ s/INCLUDE\s*/push \@nested_cmds, _parsetestfile/g;
	    eval $s->{srcbuf} or return $Xtest::FAIL;
	    unshift @{$self->{cmds}}, @nested_cmds;
	}

	# if buf looks like a SEND block, extract cmd string then eval it.
	elsif ( $s->{srcbuf} =~ m:SEND\s*\(: )
	{
	    printf("%s: %2d: %s\n", $fn, $seqnum, $buf) if (defined $self->{verbose});
	    $s->{srcbuf} =~ s/SEND\s*/\$self->{exp}->send/g; 
	    eval $s->{srcbuf}; 
	}

	# if buf looks like a EXPECT block, extract pattern then eval it.
	elsif ( $s->{srcbuf} =~ m:EXPECT\s*\(: )
	{
	    $self->{exp}->clear_accum();
	    printf("%s: %2d: %s\n", $fn, $seqnum, $buf) if (defined $self->{verbose});
	    $s->{srcbuf} =~ s/EXPECT\s*\(\s*/\$self->{exp}->expect(\$Xtest::timeout, -re, /g; 
	    eval $s->{srcbuf};

	    #if we did't get what we expected that's a FAIL
	    if ( ! $self->{exp}->match() )
	    {
		my $rc = $self->{exp}->error();		# useful for debugging
		my $before = $self->{exp}->before();	# useful for debugging
		printf("%s: %2d: %s\n", $fn, $seqnum, $Xtest::FAIL) if (defined $self->{verbose});
		$self->{exp}->hard_close();
		return $Xtest::FAIL;
	    }
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

    $contents =~ s/#.*$//mg;	# strip out comments
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

#************************************************************************/
# instance method instrument()
# instruments srcbuf for xtest whitebox testing.
# Returns undef on error.
#************************************************************************/
sub instrument
{
    my $self = shift;

    # do try/catch block code injection.
    # note we inject indentation and a newline AFTER the end delimiter 
    # that must be removed during uninstrumentation
    my $ptn = '(try\s+\{.*?)(\s*)(\}\s*catch\s+\()(\S*Exception)?(.*?\{)';
    my $repl = <<'__END__';
"$1$2/*<XTEST>*/ 
$2    \{
$2        boolean forceException = false; 
$2        if(forceException) 
$2        \{
$2              throw new $4 (\"forceException\");
$2        \}
$2    \}
$2/*</XTEST>*/$2$3$4$5"
__END__

    $repl =~ s/\n//g;
    $self->{srcbuf} =~ s:$ptn:$repl:eesg;

    # do if-then block code injection
    # note we inject one space AFTER the end delimiter 
    # that must be removed during uninstrumentation
    $self->{srcbuf} =~ s:if\s+\(\s*:$&/*<XTEST>*/ !XMT.Xhist.forceFail && /*</XTEST>*/ :sg;

    return $self->{srcbuf};
}

#************************************************************************/
# instance method uninstrument()
# Uninstruments the source code referred to by the object.
# Returns the uninstrumented source buffer.
#************************************************************************/
sub uninstrument
{
    my $self = shift;

    # remove everything from strt delimiter to end delimiter 
    # PLUS the whitespace characters added after the end delimiter
    $self->{srcbuf} =~ s:/\*<XTEST>\*/(.*?)/\*</XTEST>\*/\s*::sg;
    return $self->{srcbuf};
}

1;  # ensure class eval returns true;
