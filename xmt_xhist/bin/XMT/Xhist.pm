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
    cc	=> {
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
# class method new($f, $$bufp) 
# instantiates a new Xhist object for filename $f & contents $bufp.
# Returns the handle to the object.
#************************************************************************/
sub new
{
    my ($f, $bufp) = @_;
    my $self = {};

    $self->{fname}	= $f  if defined($f);
    ($self->{fext}	= $self->{fname}) =~ s/.*\.([^\.]*)/$1/;
    $self->{fnum}	= crc16($self->{fname});	# calculate hash of fname
    $self->{fnum}++  while ( grep /$self->{fnum}/, values %filemap ); # handle collisions
    $filemap{$self->{fname}} = $self->{fnum};	# add name & hash to filemap
    $self->{lnum}	= 0;
    $self->{buf}	= $$bufp;
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
    my $f = shift;
    open(my $FH, ">>", $f) or die "$f: $!\n";
    foreach (sort keys %filemap) 
    {
	print $FH "$_\t= $filemap{$_}\n";
    }
}

#************************************************************************
# instance method source returns instrumented buffer
#************************************************************************
sub source
{
    my $self = shift;
    return $self->{buf};
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
	return $self->{buf};
    }

    # add import XMT.Xhist 
    my $repl = '"$& $startmk import XMT.Xhist; $endmk\n"';
    $self->{buf} =~ s:.*^import\s+.*?\n:$repl:eems;

    # add Xhist.init() call after  <XHIST INIT> comment
    # put the function call between <XHIST> markers to allow for uninstrumentation
    my $ptn = '/\*\s*<XHIST INIT>\s*\*/';
    my $v	= '$' . 'Version' . ':$';
    my $mf	= '$' . 'XhistMap' . ':$';
    my $tf	= $self->{fname};
    $repl 	= '"$& $startmk Xhist.init(\"$tf\", \"$mf\", \"$v\"); $endmk"';
    $self->{buf} =~ s:$ptn:$repl:ees;

    local @indent_fifo	= [""];	# FIFO stack of function indentation levels
    my @lines	 = split /\n/, $self->{buf};
    $self->{lnum} = 0;
    $self->{buf} = '';
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
	    $self->{buf} .= "$_\t/*<DEBUG ON>*/\n";
	    next;
	}

	# "xhist debug FALSE" inside a comment disables tracing 
	$regex = interpolate( $templates->{$self->{fext}}{xh_dbg_F}, $self->{fext} );
	if ( /$regex/ )
	{
	    $xh_debug = 0;
	    $self->{buf} .= "$_\t/*<DEBUG OFF>*/\n";
	    next;
	}

	# "xhist instrument TRUE" inside a comment enables instrumentation
	$regex = interpolate( $templates->{$self->{fext}}{xh_inst_T}, $self->{fext} );
	if ( /$regex/ )
	{
	    $xh_instrument = 1;
	    $self->{buf} .= $_ . ($xh_debug ? "\t/*<INSTRUMENT ON>*/" : '') . "\n";
	    next;
	}

	# "xhist instrument FALSE" inside a comment disables instrumentation
	$regex = interpolate( $templates->{$self->{fext}}{xh_inst_F}, $self->{fext} );
	if ( /$regex/ )
	{
	    $xh_instrument = 0;
	    $self->{buf} .= $_ . ($xh_debug ? "\t/*<INSTRUMENT OFF>*/" : '') . "\n";
	    next;
	}

	$regex = interpolate( $templates->{$self->{fext}}{func_begin}, $self->{fext} );
	if ( /$regex/ )
	{
	    unshift @indent_fifo, $1;	# push new indent onto stack
	    $tokens->{$self->{fext}}{indent} = $indent_fifo[0];	
	    $in_func++;
	    $self->{buf} .= $_ . ($xh_debug ? "\t/*<FUNC START>*/" : '') . "\n";
	    next;
	}

	$regex = interpolate( $templates->{$self->{fext}}{func_end}, $self->{fext} );
	if ( /$regex/ )
	{
	    shift @indent_fifo;		# pop indent off of stack
	    $tokens->{$self->{fext}}{indent} = $indent_fifo[0];	
	    $in_func--; 
	    $self->{buf} .= $_ . ($xh_debug ? "\t/*<FUNC END>*/" : '') . "\n"; 
	    next;
	}

	$regex = interpolate( $templates->{$self->{fext}}{declaration}, $self->{fext} );
	if ( /$regex/ )
	{
	    $self->{buf} .= $_ . ($xh_debug ? "\t/*<DECL>*/" : '') . "\n";
	    next;
	}

	$regex = interpolate( $templates->{$self->{fext}}{for_stmt}, $self->{fext} );
	if ( /$regex/ )
	{
	    $self->{buf} .= $_ . ($xh_debug ? "\t/*<FOR>*/" : '') . "\n";
	    next;
	}

	$regex = interpolate( $templates->{$self->{fext}}{rtn_stmt}, $self->{fext} );
	if ( /$regex/ )
	{
	    if ( $in_func )
	    {
		$self->{buf} .= $_ . ($xh_debug ? "\t/*<RETURN>*/" : '') . "\n";
	    }
	    else
	    {
		$self->{buf} .= $_ . ($xh_debug ? "\t/*<RETURN OUTSIDE FUNC>*/" : '') . "\n";
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
		$self->{buf} .= $_ . ($xh_debug ? "\t/*<STMT>*/" : '');
		(my $repl = $templates->{$self->{fext}}{trace_stmt}) =~ s/FNUM/$self->{fnum}/g;
		$repl =~ s/LNUM/$self->{lnum}/g;
		if ($xh_instrument == 1)
		{
		    eval {$self->{buf} .= $repl};
		}
		$self->{buf} .= "\n";
	    }
	    else
	    {
		$self->{buf} .= $_ . ($xh_debug ? "\t/*<STMT OUTSIDE FUNC>*/" : '') . "\n";
	    }
	    next;
	}
	else	# matches nothing; just output original line
	{
	    $self->{buf} .= "$_\n";	
	}
    }
    return $self->{buf};
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
    my $startmk = interpolate( $templates->{$self->{fext}}{xh_startmk}, $self->{fext} );
    my $endmk = interpolate( $templates->{$self->{fext}}{xh_endmk}, $self->{fext} );
    $startmk =~ s/\\//g;
    $endmk =~ s/\\//g;

    # if we don't grok this filetype, return gracefully.
    if (!defined $tokens->{$self->{fext}})
    {
	return $self->{buf};
    }

    $self->{buf} =~ s:$startmk(.*)?$endmk ::esg;
    $self->{buf} =~ s:\t/*<DEBUG ON>*/::g;
    $self->{buf} =~ s:\t/*<DEBUG OFF>*/::g;
    $self->{buf} =~ s:\t/*<INSTRUMENT ON>*/::g;
    $self->{buf} =~ s:\t/*<INSTRUMENT OFF>*/::g;
    $self->{buf} =~ s:\t/*<FUNC START>*/::g;
    $self->{buf} =~ s:\t/*<FUNC END>*/::g;
    $self->{buf} =~ s:\t/*<DECL>*/::g;
    $self->{buf} =~ s:\t/*<FOR>*/::g;
    $self->{buf} =~ s:"\t/*<RETURN>*/::g;
    $self->{buf} =~ s:\t/*<RETURN OUTSIDE FUNC>*/::g;
    $self->{buf} =~ s:"\t/*<STMT>*/::g;
    $self->{buf} =~ s:\t/*<STMT OUTSIDE FUNC>*/::g;
    ($ptn = $templates->{$self->{fext}}{trace_stmt}) =~ s/.NUM/\\d+/g;
    $self->{buf} =~ s:.*^import\s+.*?\n:$&import XMT.Xhist;\n:ms;
    $self->{buf} =~ s:.*^import\s+.*?\n:$&import XMT.Xhist;\n:ms;

    $ptn =~ s/\(/\\(/g;
    $ptn =~ s/\)/\\(/g;
    $self->{buf} =~ s:$ptn::g;
    return $self->{buf};
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
