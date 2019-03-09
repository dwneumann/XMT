#!/usr/bin/env perl
#************************************************************************
#*   $Version:$
#*   Package	: xmt_xhist
#*   Purpose	: Xhist class (invoked by git_filter)
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

package XMT::Xhist;
use Carp;
use Digest::CRC qw(crc16);
use List::MoreUtils qw(natatime);

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

# $tokens is a hash of lexical tokens to be interpolated in pattern matching
our $tokens = {
	identifier    	=> q:[a-zA-Z0-9_]+:	,
	operator	=> q:[-+<>=!\^\(]:	,
	indent		=> ""			,	# this changes dynamically
};

# $templates are language-specific patterns that are interpolated with tokens 
# at time of parsing.  This allows tokens to dynamically change (e.g. $indent)
our $templates = {
    c	=> {
	func_begin	=> q:\n(\s*)\{.*?;:,
	func_end	=> q:\n[% indent %]\}\s*\n:,
	declaration	=> q:\n\s*[% identifier %]\**\s+\(?\**[% identifier %].*?;:,
	for_stmt	=> q:\s+for\s+\(.*?\{:,
	rtn_stmt	=> q:\s+return\s*\(.*?\)\s*;:,
	exe_stmt	=> q:[% operator %].*?;:,
	xh_dbg_T	=> q:\/\*\s+xhist\s+debug\s+TRUE\s*\*\/:,
	xh_dbg_F	=> q:\/\*\s+xhist\s+debug\s+FALSE\s*\*\/:,
	xh_inst_T	=> q:\/\*\s+xhist\s+instrument\s+TRUE\s*\*\/:,
	xh_inst_F	=> q:\/\*\s+xhist\s+instrument\s+FALSE\s*\*\/:,
	xh_startmk	=> q:\/\*<XHIST>\*\/:,
	xh_endmk	=> q:\/\*</XHIST>\*\/:,
	trace_stmt	=> q: _XH_ADD( FNUM, LNUM );:,
	write_stmt	=> q: xhist_write:,
	init_stmt	=> q: xhist_init:,
    },
    cc	=> {
	func_begin	=> q:\n(\s*)(public|private|protected).*?\{.*?;:,
	func_end	=> q:\n[% indent %]\}\s*\n:,
	declaration	=> q:\n\s*[% identifier %]\**\s+\(?\**[% identifier %].*?;:,
	for_stmt	=> q:\s+for\s+\(.*?;.*?;.*?\{:,
	rtn_stmt	=> q:\s+return\s*\(.*?\)\s*;:,
	exe_stmt	=> q:[% operator %].*?;:,
	xh_dbg_T	=> q:\/\*\s+xhist\s+debug\s+TRUE\s*\*\/:,
	xh_dbg_F	=> q:\/\*\s+xhist\s+debug\s+FALSE\s*\*\/:,
	xh_inst_T	=> q:\/\*\s+xhist\s+instrument\s+TRUE\s*\*\/:,
	xh_inst_F	=> q:\/\*\s+xhist\s+instrument\s+FALSE\s*\*\/:,
	xh_startmk	=> q:\/\*<XHIST>\*\/:,
	xh_endmk	=> q:\/\*</XHIST>\*\/:,
	trace_stmt	=> q/ Xhist:add( FNUM, LNUM );/,
	write_stmt	=> q/ Xhist:write/,
	init_stmt	=> q/ Xhist:init/,
    },
    cpp	=> {
	func_begin	=> q:\n(\s*)(public|private|protected).*?\{.*?;:,
	func_end	=> q:\n[% indent %]\}\s*\n:,
	declaration	=> q:\n\s*[% identifier %]\**\s+\(?\**[% identifier %].*?;:,
	for_stmt	=> q:\s+for\s+\(.*?;.*?;.*?\{:,
	rtn_stmt	=> q:\s+return\s*\(.*?\)\s*;:,
	exe_stmt	=> q:[% operator %].*?;:,
	xh_dbg_T	=> q:\/\*\s+xhist\s+debug\s+TRUE\s*\*\/:,
	xh_dbg_F	=> q:\/\*\s+xhist\s+debug\s+FALSE\s*\*\/:,
	xh_inst_T	=> q:\/\*\s+xhist\s+instrument\s+TRUE\s*\*\/:,
	xh_inst_F	=> q:\/\*\s+xhist\s+instrument\s+FALSE\s*\*\/:,
	xh_startmk	=> q:\/\*<XHIST>\*\/:,
	xh_endmk	=> q:\/\*</XHIST>\*\/:,
	trace_stmt	=> q/ Xhist.add( FNUM, LNUM );/,
	write_stmt	=> q/ Xhist:write/,
	init_stmt	=> q/ Xhist:init/,
    },
    java	=> {
	func_begin	=> q:\n(\s*)(public|private|protected).*?\{.*?;:,
	func_end	=> q:\n[% indent %]\}\s*\n:,
	declaration	=> q:\n\s*[% identifier %]\**\s+\(?\**[% identifier %].*?;:,
	for_stmt	=> q:\s+for\s+\(.*?;.*?;.*?\{:,
	rtn_stmt	=> q:\s+(return|throw)\s*\(*.?\)\s*;:,
	exe_stmt	=> q:[% operator %].*?;:,
	xh_dbg_T	=> q:\/\*\s+xhist\s+debug\s+TRUE\s*\*\/:,
	xh_dbg_F	=> q:\/\*\s+xhist\s+debug\s+FALSE\s*\*\/:,
	xh_inst_T	=> q:\/\*\s+xhist\s+instrument\s+TRUE\s*\*\/:,
	xh_inst_F	=> q:\/\*\s+xhist\s+instrument\s+FALSE\s*\*\/:,
	xh_startmk	=> q:\/\*<XHIST>\*\/:,
	xh_endmk	=> q:\/\*</XHIST>\*\/:,
	trace_stmt	=> q/ Xhist.add( FNUM, LNUM );/,
	write_stmt	=> q/ Xhist.write/,
	init_stmt	=> q/ Xhist.init/,
    },
};

## nothing below this line should be language-dependent.

#************************************************************************/
# class method new(\%opts)
# instantiates a new Xhist object with options specified.
# Returns the handle to the object or undef on error.
#************************************************************************/
sub new
{
    my ($opts) = @_;
    my $self = {};

    $self->{srcfn}	= $opts->{fname}  or carp "input filename undefined" & return undef;
    $self->{srcbuf}	= length($opts->{srcbuf}) > 0 ? $opts->{srcbuf} : "";
    $self->{mapfn}	= $opts->{xhist_map} if defined $opts->{xhist_map};
    $self->{fext}	= (defined($self->{srcfn}) ?
    			lc $self->{srcfn} =~ s/.*\.(.*?)$/$1/r : "c");
    $self->{fnum}	= crc16($self->{srcfn}) or carp "crc16 failed" & return undef;
    $self->{fnum}++  while ( grep /$self->{fnum}/, values %filemap ); # handle collisions
    $filemap{$self->{srcfn}} = $self->{fnum};	# add name & hash to filemap
    $self->{lnum}	= 0;
    bless $self;
    return $self;
}
 
#************************************************************************
# stub DESTROY so the autoloader won't search for it.
#************************************************************************
sub DESTROY { }

#************************************************************************
# class method printmap($f) writes filemap to specified file.
# If file already exists it is appended to.
#************************************************************************
sub printmap
{
    my $self = shift;
    if (defined $self->{mapfn})
    {
	open(my $FH, ">>", $self->{mapfn}) or die "$self->{mapfn}: $!\n";
	foreach (sort keys %filemap) 
	{
	    print $FH "$_\t= $filemap{$_}\n";
	}
    }
}

#************************************************************************
# instance method source returns instrumented buffer
#************************************************************************
sub source
{
    my $self = shift;
    return $self->{srcbuf};
}

#************************************************************************/
# instance method instrument() 
# Instruments the source code referred to by the object.
# Returns the instrumented source buffer.
#************************************************************************/
sub instrument
{
    my $self = shift;
    my $in_func		= 0;	# increment each time we encounter a nested routine
    my $xh_debug	= 0;	# TRUE if debugging lexer 
    my $xh_instrument	= 1;	# TRUE if instrumenting should occur
    my $regex;

    # if we don't grok this filetype, return gracefully.
    return $self->{srcbuf} if (!defined $templates->{$self->{fext}});

    # we interpolate the patterns /*<XHIST>*/ and /*</XHIST>*/ because they are comment-dependent.
    # we need a pair with slashes escaped for the search pattern 
    # and a pair without for the replacemt pattern
    my $xhstesc = interpolate( $templates->{$self->{fext}}{xh_startmk}, $self->{fext} );
    my $xhendesc = interpolate( $templates->{$self->{fext}}{xh_endmk}, $self->{fext} );
    (my $xhst  = $xhstesc)  =~ s/\\//g;
    (my $xhend = $xhendesc) =~ s/\\//g;

    # refuse to instrument source that's already instrumented.
    # Probably not what the user wanted anyway, and will certainly screw up unxhist.
    return $self->{srcbuf} if $self->{srcbuf} =~ m:$xhstesc.*$xhendesc:;

    # add import XMT.Xhist (this is a no-op for languages other than java) 
    my $repl = '"$&\n$xhst import XMT.Xhist; $xhend\n"';
    $self->{srcbuf} =~ s:\n(package|import)\s+.*?\n:$repl:ees;

    # add Xhist.init() call after  <XHIST INIT> comment
    # put the function call between <XHIST> markers to allow for uninstrumentation
    my $ptn = '/\*\s*<XHIST INIT>\s*\*/';
    my $v	= '$' . 'Version' . ':$';
    my $mf	= '$' . 'XhistMap' . ':$';
    my $tf	= $self->{srcfn};
    my $init_stmt = interpolate( $templates->{$self->{fext}}{init_stmt}, $self->{fext} );
    $repl = '"$&$xhst $init_stmt(\"$tf\", \"$mf\", \"$v\"); $xhend"';
    $self->{srcbuf} =~ s:$ptn:$repl:ees;

    # add Xhist.write() call after  <XHIST WRITE> comment
    # put the function call between <XHIST> markers to allow for uninstrumentation
    my $ptn = '/\*\s*<XHIST WRITE>\s*\*/';
    my $write_stmt = interpolate( $templates->{$self->{fext}}{write_stmt}, $self->{fext} );
    $repl 	= '"$&$xhst $write_stmt(); $xhend"';
    $self->{srcbuf} =~ s:$ptn:$repl:ees;

    # now process srcbuf one semicolon-terminated block at a time, matching templates
    local @indent_fifo	= [""];	# FIFO stack of function indentation levels

    # split srcbuf into semicolon-terminated blocks
    my @x = split /(;)/, $self->{srcbuf};	
    my @stmts;
    my $it = natatime 2, @x;
    while (my @pair = $it->())
    {
	push @stmts, join '', @pair;
    }

    # GOT TO HERE ---------
    $self->{lnum} = 1;
    $self->{srcbuf} = '';
    while (scalar @stmts > 0)
    {
	my $str = shift @stmts;

	# "xhist debug TRUE" inside comment delimiters enables debug output 
	$regex = interpolate( $templates->{$self->{fext}}{xh_dbg_T}, $self->{fext} );
	if ( $str =~ /$regex/ )
	{
	    $xh_debug = 1;
	    $str =~ s/${^MATCH}/$xhst <DEBUG ON> $xhend/g		if ($xh_debug);
	    $self->{srcbuf} .= $str;
	    $self->{lnum} += ($str =~ tr/\n//);	# increment lnum by # of newlines in stmt
	    next;
	}

	# "xhist debug FALSE" inside comment delimiters disables debug output 
	$regex = interpolate( $templates->{$self->{fext}}{xh_dbg_F}, $self->{fext} );
	if ( $str =~ /$regex/ )
	{
	    $xh_debug = 0;
	    $self->{srcbuf} .= $str;
	    $self->{lnum} += ($str =~ tr/\n//);	# increment lnum by # of newlines in stmt
	    next;
	}

	# "xhist instrument TRUE" inside comment delimiters enables instrumentation
	$regex = interpolate( $templates->{$self->{fext}}{xh_inst_T}, $self->{fext} );
	if ( $str =~ /$regex/ )
	{
	    $xh_instrument = 1;
	    $str =~ s/${^MATCH}/$xhst <INSTRUMENT ON> $xhend/g	if ($xh_debug);
	    $self->{srcbuf} .= $str;
	    $self->{lnum} += ($str =~ tr/\n//);	# increment lnum by # of newlines in stmt
	    next;
	}

	# "xhist instrument FALSE" inside comment delimiters disables instrumentation
	$regex = interpolate( $templates->{$self->{fext}}{xh_inst_F}, $self->{fext} );
	if ( $str =~ /$regex/ )
	{
	    $xh_instrument = 0;
	    $str =~ s/${^MATCH}/$xhst <INSTRUMENT OFF> $xhend/g	if ($xh_debug);
	    $self->{srcbuf} .= $str;
	    $self->{lnum} += ($str =~ tr/\n//);	# increment lnum by # of newlines in stmt
	    next;
	}

	$regex = interpolate( $templates->{$self->{fext}}{func_begin}, $self->{fext} );
	if ( $str =~ /$regex/ )
	{
	    unshift @indent_fifo, $1;	# push new indent onto stack
	    $tokens->{indent} = $indent_fifo[0];	
	    $in_func++;
	    $str =~ s/${^MATCH}/$xhst <FUNC START> $xhend/g	if ($xh_debug);
	    $self->{srcbuf} .= $str;
	    $self->{lnum} += ($str =~ tr/\n//);	# increment @stmts = split /(;)/, $self->{srcbuf}lnum by # of newlines in stmt
	    next;
	}

	$regex = interpolate( $templates->{$self->{fext}}{func_end}, $self->{fext} );
	if ( $str =~ /$regex/ )
	{
	    shift @indent_fifo;		# pop indent off of stack
	    unshift @indent_fifo, "" if ! @indent_fifo; # handle func_end without func_start
	    $tokens->{indent} = $indent_fifo[0];	
	    $in_func--; 
	    $str =~ s/${^MATCH}/$xhst <FUNC END> $xhend/g	if ($xh_debug);
	    $self->{srcbuf} .= $str;
	    $self->{lnum} += ($str =~ tr/\n//);	# increment lnum by # of newlines in stmt
	    next;
	}

	$regex = interpolate( $templates->{$self->{fext}}{declaration}, $self->{fext} );
	if ( $str =~ /$regex/ )
	{
	    $str =~ s/${^MATCH}/$xhst <DECLARATION> $xhend/g	if ($xh_debug);
	    $self->{srcbuf} .= $str;
	    $self->{lnum} += ($str =~ tr/\n//);	# increment lnum by # of newlines in stmt
	    next;
	}

	$regex = interpolate( $templates->{$self->{fext}}{for_stmt}, $self->{fext} );
	if ( $str =~ /$regex/ )
	{
	    $str =~ s/${^MATCH}/$xhst <FOR> $xhend/g	if ($xh_debug);
	    $self->{srcbuf} .= $str;
	    $self->{lnum} += ($str =~ tr/\n//);	# increment lnum by # of newlines in stmt
	    next;
	}

	$regex = interpolate( $templates->{$self->{fext}}{rtn_stmt}, $self->{fext} );
	if ( $str =~ /$regex/ )
	{
	    if ( $in_func )
	    {
		$str =~ s/${^MATCH}/$xhst <RETURN> $xhend/g	if ($xh_debug);
		$self->{srcbuf} .= $str;
		$self->{lnum} += ($str =~ tr/\n//);	# increment lnum by # of newlines in stmt
	    }
	    else
	    {
		$str =~ s/${^MATCH}/$xhst <RETURN OUTSIDE FUNC> $xhend/g	if ($xh_debug);
		$self->{srcbuf} .= $str;
		$self->{lnum} += ($str =~ tr/\n//);	# increment lnum by # of newlines in stmt
	    }
	}

	# a line containing an operator and terminating with a semicolon indicates 
	# an executable statement. this is where we append trace statements.
	# anything else is passed through unaltered.
	$regex = interpolate( $templates->{$self->{fext}}{exe_stmt}, $self->{fext} );
	if ( $str =~ /$regex/ )
	{
	    if ( $in_func )
	    {
		$str =~ s/${^MATCH}/$xhst <STMT> $xhend/g	if ($xh_debug);
		$self->{srcbuf} .= $str;
		$self->{lnum} += ($str =~ tr/\n//);	# increment lnum by # of newlines in stmt
		(my $repl = $templates->{$self->{fext}}{trace_stmt}) =~ s/FNUM/$self->{fnum}/g;
		$repl =~ s/LNUM/$self->{lnum}/g;
		if ($xh_instrument == 1)
		{
		    eval {$self->{srcbuf} .= $xhst . $repl . $xhend }; 
		}
		$self->{srcbuf} .= "\n";
	    }
	    else
	    {
		$str =~ s/${^MATCH}/$xhst <STMT OUTSIDE FUNC> $xhend/g	if ($xh_debug);
		$self->{srcbuf} .= $str;
		$self->{lnum} += ($str =~ tr/\n//);	# increment lnum by # of newlines in stmt
	    }
	    next;
	}
	else	# matches nothing; shift the buffer & try again
	{
	    $self->{srcbuf} .= $str;
	    $self->{lnum} += ($str =~ tr/\n//);	# increment lnum by # of newlines in stmt
	}
    }
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
    my $ptn;

    # if we don't grok this filetype, return unmodified srcbuf.
    return $self->{srcbuf} if (!defined $templates->{$self->{fext}});

    my $startmk = interpolate( $templates->{$self->{fext}}{xh_startmk}, $self->{fext} );
    my $endmk	= interpolate( $templates->{$self->{fext}}{xh_endmk}, $self->{fext} );
    $self->{srcbuf} =~ s:$startmk(.*?)$endmk::sg;
    return $self->{srcbuf};
}

#************************************************************************/
# private function interpolate returns $ptn with all token values interpolated 
#************************************************************************/
sub interpolate
{
    my ($ptn, $ext) = @_;
    my $output = $ptn;

    foreach my $key (keys %{$tokens})
    {
        $output =~ s/\[% $key %\]/$tokens->{$key}/g;
    }
    return $output;
}

1;
