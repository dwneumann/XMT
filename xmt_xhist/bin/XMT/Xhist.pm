#!/usr/local/bin/perl -w
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

# $tokens is a hash of language-specific tokens to be interpolated at time of pattern matching
our $tokens = {
    c		=> {
	identifier    	=> q:[a-zA-Z0-9_]+:	,
	operator	=> q:[-+<>=!\^\(]:	,
	cmt_start	=> q:/\*:		,
	cmt_end		=> q:\*/:		,
	indent		=> ""			,	# this changes dynamically
    },
    h		=> {
	identifier    	=> q:[a-zA-Z0-9_]+:	,
	operator	=> q:[-+<>=!\^\(]:	,
	cmt_start	=> q:/\*:		,
	cmt_end		=> q:\*/:		,
	indent		=> ""			,	# this changes dynamically
    },
    cc	=> {
	identifier    	=> q:[a-zA-Z0-9_]+:	,
	operator	=> q:[-+<>=!\^\(]:	,
	cmt_start	=> q:/\*:		,
	cmt_end		=> q:\*/:		,
	indent		=> ""			,	# this changes dynamically
    },
    cpp	=> {
	identifier    	=> q:[a-zA-Z0-9_]+:	,
	operator	=> q:[-+<>=!\^\(]:	,
	cmt_start	=> q:/\*:		,
	cmt_end		=> q:\*/:		,
	indent		=> ""			,	# this changes dynamically
    },
    hh	=> {
	identifier    	=> q:[a-zA-Z0-9_]+:	,
	operator	=> q:[-+<>=!\^\(]:	,
	cmt_start	=> q:/\*:		,
	cmt_end		=> q:\*/:		,
	indent		=> ""			,	# this changes dynamically
    },
    hpp	=> {
	identifier    	=> q:[a-zA-Z0-9_]+:	,
	operator	=> q:[-+<>=!\^\(]:	,
	cmt_start	=> q:/\*:		,
	cmt_end		=> q:\*/:		,
	indent		=> ""			,	# this changes dynamically
    },
    java	=> {
	identifier    	=> q:[a-zA-Z0-9_]+:	,
	operator	=> q:[-+<>=!\^\(]:	,
	cmt_start	=> q:/\*:		,
	cmt_end		=> q:\*/:		,
	indent		=> ""			,	# this changes dynamically
    },
};

# $templates are language-specific patterns that are interpolated with tokens 
# at time of parsing.  This allows tokens to dynamically change (e.g. $indent)
our $templates = {
    c	=> {
	func_begin	=> q:^(\s*)\{\s*$:,
	func_end	=> q:^[% indent %]\}\s*$:,
	declaration	=> q:^\s*[% identifier %]\**\s+\(?\**[% identifier %].*[,;]:,
	for_stmt	=> q:\s+for\s+\(.*;.*:,
	rtn_stmt	=> q:\s+return\s*\(*.*\)*\s*;:,
	executable	=> q:[% operator %].*;:,
	xh_dbg_T	=> q:[% cmt_start %]\s+xhist\s+debug\s+TRUE\s*[% cmt_end %]:,
	xh_dbg_F	=> q:[% cmt_start %]\s+xhist\s+debug\s+FALSE\s*[% cmt_end %]:,
	xh_inst_T	=> q:[% cmt_start %]\s+xhist\s+instrument\s+TRUE\s*[% cmt_end %]:,
	xh_inst_F	=> q:[% cmt_start %]\s+xhist\s+instrument\s+FALSE\s*[% cmt_end %]:,
	xh_startmk	=> q:[% cmt_start %]<XHIST>[% cmt_end %]:,
	xh_endmk	=> q:[% cmt_start %]</XHIST>[% cmt_end %]:,
	trace_stmt	=> q: _XH_ADD( FNUM, LNUM );:,
    },
    h	=> {
	func_begin	=> q:^(\s*)\{\s*$:,
	func_end	=> q:^[% indent %]\}\s*$:,
	declaration	=> q:^\s*[% identifier %]\**\s+\(?\**[% identifier %].*[,;]:,
	for_stmt	=> q:\s+for\s+\(.*;.*:,
	rtn_stmt	=> q:\s+return\s*\(*.*\)*\s*;:,
	executable	=> q:[% operator %].*;:,
	xh_dbg_T	=> q:[% cmt_start %]\s+xhist\s+debug\s+TRUE\s*[% cmt_end %]:,
	xh_dbg_F	=> q:[% cmt_start %]\s+xhist\s+debug\s+FALSE\s*[% cmt_end %]:,
	xh_inst_T	=> q:[% cmt_start %]\s+xhist\s+instrument\s+TRUE\s*[% cmt_end %]:,
	xh_inst_F	=> q:[% cmt_start %]\s+xhist\s+instrument\s+FALSE\s*[% cmt_end %]:,
	xh_startmk	=> q:[% cmt_start %]<XHIST>[% cmt_end %]:,
	xh_endmk	=> q:[% cmt_start %]</XHIST>[% cmt_end %]:,
	trace_stmt	=> q: _XH_ADD( FNUM, LNUM );:,
    },
    cc	=> {
	func_begin	=> q:^(\s*)(public|private|protected).*\{\s*:,
	func_end	=> q:^[% indent %]\}\s*$:,
	declaration	=> q:^\s*[% identifier %]\**\s+\(?\**[% identifier %].*[,;]:,
	for_stmt	=> q:\s+for\s+\(.*;.*:,
	rtn_stmt	=> q:\s+return\s*\(*.*\)*\s*;:,
	executable	=> q:[% operator %].*;:,
	xh_dbg_T	=> q:[% cmt_start %]\s+xhist\s+debug\s+TRUE\s*[% cmt_end %]:,
	xh_dbg_F	=> q:[% cmt_start %]\s+xhist\s+debug\s+FALSE\s*[% cmt_end %]:,
	xh_inst_T	=> q:[% cmt_start %]\s+xhist\s+instrument\s+TRUE\s*[% cmt_end %]:,
	xh_inst_F	=> q:[% cmt_start %]\s+xhist\s+instrument\s+FALSE\s*[% cmt_end %]:,
	xh_startmk	=> q:[% cmt_start %]<XHIST>[% cmt_end %]:,
	xh_endmk	=> q:[% cmt_start %]</XHIST>[% cmt_end %]:,
	trace_stmt	=> q: Xhist.add( FNUM, LNUM );:,
    },
    cpp	=> {
	func_begin	=> q:^(\s*)(public|private|protected).*\{\s*:,
	func_end	=> q:^[% indent %]\}\s*$:,
	declaration	=> q:^\s*[% identifier %]\**\s+\(?\**[% identifier %].*[,;]:,
	for_stmt	=> q:\s+for\s+\(.*;.*:,
	rtn_stmt	=> q:\s+return\s*\(*.*\)*\s*;:,
	executable	=> q:[% operator %].*;:,
	xh_dbg_T	=> q:[% cmt_start %]\s+xhist\s+debug\s+TRUE\s*[% cmt_end %]:,
	xh_dbg_F	=> q:[% cmt_start %]\s+xhist\s+debug\s+FALSE\s*[% cmt_end %]:,
	xh_inst_T	=> q:[% cmt_start %]\s+xhist\s+instrument\s+TRUE\s*[% cmt_end %]:,
	xh_inst_F	=> q:[% cmt_start %]\s+xhist\s+instrument\s+FALSE\s*[% cmt_end %]:,
	xh_startmk	=> q:[% cmt_start %]<XHIST>[% cmt_end %]:,
	xh_endmk	=> q:[% cmt_start %]</XHIST>[% cmt_end %]:,
	trace_stmt	=> q: Xhist.add( FNUM, LNUM );:,
    },
    hh	=> {
	func_begin	=> q:^(\s*)(public|private|protected).*\{\s*:,
	func_end	=> q:^[% indent %]\}\s*$:,
	declaration	=> q:^\s*[% identifier %]\**\s+\(?\**[% identifier %].*[,;]:,
	for_stmt	=> q:\s+for\s+\(.*;.*:,
	rtn_stmt	=> q:\s+return\s*\(*.*\)*\s*;:,
	executable	=> q:[% operator %].*;:,
	xh_dbg_T	=> q:[% cmt_start %]\s+xhist\s+debug\s+TRUE\s*[% cmt_end %]:,
	xh_dbg_F	=> q:[% cmt_start %]\s+xhist\s+debug\s+FALSE\s*[% cmt_end %]:,
	xh_inst_T	=> q:[% cmt_start %]\s+xhist\s+instrument\s+TRUE\s*[% cmt_end %]:,
	xh_inst_F	=> q:[% cmt_start %]\s+xhist\s+instrument\s+FALSE\s*[% cmt_end %]:,
	xh_startmk	=> q:[% cmt_start %]<XHIST>[% cmt_end %]:,
	xh_endmk	=> q:[% cmt_start %]</XHIST>[% cmt_end %]:,
	trace_stmt	=> q: Xhist.add( FNUM, LNUM );:,
    },
    hpp	=> {
	func_begin	=> q:^(\s*)(public|private|protected).*\{\s*:,
	func_end	=> q:^[% indent %]\}\s*$:,
	declaration	=> q:^\s*[% identifier %]\**\s+\(?\**[% identifier %].*[,;]:,
	for_stmt	=> q:\s+for\s+\(.*;.*:,
	rtn_stmt	=> q:\s+return\s*\(*.*\)*\s*;:,
	executable	=> q:[% operator %].*;:,
	xh_dbg_T	=> q:[% cmt_start %]\s+xhist\s+debug\s+TRUE\s*[% cmt_end %]:,
	xh_dbg_F	=> q:[% cmt_start %]\s+xhist\s+debug\s+FALSE\s*[% cmt_end %]:,
	xh_inst_T	=> q:[% cmt_start %]\s+xhist\s+instrument\s+TRUE\s*[% cmt_end %]:,
	xh_inst_F	=> q:[% cmt_start %]\s+xhist\s+instrument\s+FALSE\s*[% cmt_end %]:,
	xh_startmk	=> q:[% cmt_start %]<XHIST>[% cmt_end %]:,
	xh_endmk	=> q:[% cmt_start %]</XHIST>[% cmt_end %]:,
	trace_stmt	=> q: Xhist.add( FNUM, LNUM );:,
    },
    java	=> {
	func_begin	=> q:^(\s*)(public|private|protected).*\{\s*:,
	func_end	=> q:^[% indent %]\}\s*$:,
	declaration	=> q:^\s*[% identifier %]\**\s+\(?\**[% identifier %].*[,;]:,
	for_stmt	=> q:\s+for\s+\(.*;.*:,
	rtn_stmt	=> q:\s+return\s*\(*.*\)*\s*;:,
	executable	=> q:[% operator %].*;:,
	xh_dbg_T	=> q:[% cmt_start %]\s+xhist\s+debug\s+TRUE\s*[% cmt_end %]:,
	xh_dbg_F	=> q:[% cmt_start %]\s+xhist\s+debug\s+FALSE\s*[% cmt_end %]:,
	xh_inst_T	=> q:[% cmt_start %]\s+xhist\s+instrument\s+TRUE\s*[% cmt_end %]:,
	xh_inst_F	=> q:[% cmt_start %]\s+xhist\s+instrument\s+FALSE\s*[% cmt_end %]:,
	xh_startmk	=> q:[% cmt_start %]<XHIST>[% cmt_end %]:,
	xh_endmk	=> q:[% cmt_start %]</XHIST>[% cmt_end %]:,
	trace_stmt	=> q: Xhist.add( FNUM, LNUM );:,
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
    $self->{srcbuf}	= $opts->{srcbuf} or carp "input stream undefined"   & return undef;
    $self->{mapfn}	= $opts->{map} if (defined $opts->{map} || defined $opts->{xhist_map});
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
    my $startmk = interpolate( $templates->{$self->{fext}}{xh_startmk}, $self->{fext} );
    my $endmk = interpolate( $templates->{$self->{fext}}{xh_endmk}, $self->{fext} );
    $startmk =~ s/\\//g;
    $endmk =~ s/\\//g;

    # if we don't grok this filetype, return gracefully.
    if (!defined $tokens->{$self->{fext}})
    {
	return $self->{srcbuf};
    }

    # add import XMT.Xhist 
    my $repl = '"$&$startmk import XMT.Xhist; $endmk"';
    $self->{srcbuf} =~ s:.*^import\s+.*?\n:$repl:eems;

    # add Xhist.init() call after  <XHIST INIT> comment
    # put the function call between <XHIST> markers to allow for uninstrumentation
    my $ptn = '/\*\s*<XHIST INIT>\s*\*/';
    my $v	= '$' . 'Version' . ':$';
    my $mf	= '$' . 'XhistMap' . ':$';
    my $tf	= $self->{srcfn};
    $repl 	= '"$&$startmk Xhist.init(\"$tf\", \"$mf\", \"$v\"); $endmk"';
    $self->{srcbuf} =~ s:$ptn:$repl:ees;

    local @indent_fifo	= [""];	# FIFO stack of function indentation levels
    my @lines	 = split /\n/, $self->{srcbuf};
    $self->{lnum} = 0;
    $self->{srcbuf} = '';
    while (scalar @lines > 0)
    {
	$_ = shift @lines;
	$self->{lnum}++;

	# append instrumentation to line ...
	# "xhist debug TRUE" inside a comment enables tracing 
	$regex = interpolate( $templates->{$self->{fext}}{xh_dbg_T}, $self->{fext} );
	if ( /$regex/ )
	{
	    $xh_debug = 1;
	    $self->{srcbuf} .= "$_\t$startmk <DEBUG ON> $endmk\n";
	    next;
	}

	# "xhist debug FALSE" inside a comment disables tracing 
	$regex = interpolate( $templates->{$self->{fext}}{xh_dbg_F}, $self->{fext} );
	if ( /$regex/ )
	{
	    $xh_debug = 0;
	    $self->{srcbuf} .= "$_\t$startmk <DEBUG OFF> $endmk\n";
	    next;
	}

	# "xhist instrument TRUE" inside a comment enables instrumentation
	$regex = interpolate( $templates->{$self->{fext}}{xh_inst_T}, $self->{fext} );
	if ( /$regex/ )
	{
	    $xh_instrument = 1;
	    $self->{srcbuf} .= $_ . ($xh_debug ? "\t$startmk <INSTRUMENT ON> $endmk" : '') . "\n";
	    next;
	}

	# "xhist instrument FALSE" inside a comment disables instrumentation
	$regex = interpolate( $templates->{$self->{fext}}{xh_inst_F}, $self->{fext} );
	if ( /$regex/ )
	{
	    $xh_instrument = 0;
	    $self->{srcbuf} .= $_ . ($xh_debug ? "\t$startmk <INSTRUMENT OFF> $endmk" : '') . "\n";
	    next;
	}

	$regex = interpolate( $templates->{$self->{fext}}{func_begin}, $self->{fext} );
	if ( /$regex/ )
	{
	    unshift @indent_fifo, $1;	# push new indent onto stack
	    $tokens->{$self->{fext}}{indent} = $indent_fifo[0];	
	    $in_func++;
	    $self->{srcbuf} .= $_ . ($xh_debug ? "\t$startmk <FUNC START> $endmk" : '') . "\n";
	    next;
	}

	$regex = interpolate( $templates->{$self->{fext}}{func_end}, $self->{fext} );
	if ( /$regex/ )
	{
	    shift @indent_fifo;		# pop indent off of stack
	    $tokens->{$self->{fext}}{indent} = $indent_fifo[0];	
	    $in_func--; 
	    $self->{srcbuf} .= $_ . ($xh_debug ? "\t$startmk <FUNC END> $endmk" : '') . "\n"; 
	    next;
	}

	$regex = interpolate( $templates->{$self->{fext}}{declaration}, $self->{fext} );
	if ( /$regex/ )
	{
	    $self->{srcbuf} .= $_ . ($xh_debug ? "\t$startmk <DECL> $endmk" : '') . "\n";
	    next;
	}

	$regex = interpolate( $templates->{$self->{fext}}{for_stmt}, $self->{fext} );
	if ( /$regex/ )
	{
	    $self->{srcbuf} .= $_ . ($xh_debug ? "\t$startmk <FOR> $endmk" : '') . "\n";
	    next;
	}

	$regex = interpolate( $templates->{$self->{fext}}{rtn_stmt}, $self->{fext} );
	if ( /$regex/ )
	{
	    if ( $in_func )
	    {
		$self->{srcbuf} .= $_ . ($xh_debug ? "\t$startmk <RETURN> $endmk" : '') . "\n";
	    }
	    else
	    {
		$self->{srcbuf} .= $_ . ($xh_debug ? "\t/$startmk<RETURN OUTSIDE FUNC> $endmk" : '') . "\n";
	    }
	    next;
	}

	# a line containing an operator and terminating with a semicolon indicates 
	# an executable statement. this is where we append trace statements.
	# anything else is passed through unaltered.
	$regex = interpolate( $templates->{$self->{fext}}{executable}, $self->{fext} );
	if ( /$regex/ )
	{
	    if ( $in_func )
	    {
		$self->{srcbuf} .= $_ . ($xh_debug ? "\t$startmk <STMT> $endmk" : '');
		(my $repl = $templates->{$self->{fext}}{trace_stmt}) =~ s/FNUM/$self->{fnum}/g;
		$repl =~ s/LNUM/$self->{lnum}/g;
		if ($xh_instrument == 1)
		{
		    eval {$self->{srcbuf} .= $startmk . $repl . $endmk }; 
		}
		$self->{srcbuf} .= "\n";
	    }
	    else
	    {
		$self->{srcbuf} .= $_ . ($xh_debug ? "\t$startmk <STMT OUTSIDE FUNC> $endmk" : '') . "\n";
	    }
	    next;
	}
	else	# matches nothing; just output original line
	{
	    $self->{srcbuf} .= "$_\n";	
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
    return $self->{srcbuf} if (!defined $tokens->{$self->{fext}});

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

    foreach my $key (keys %{$tokens->{$ext}})
    {
        $output =~ s/\[% $key %\]/$tokens->{$ext}{$key}/g;
    }
    return $output;
}

1;
