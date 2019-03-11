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

# $tokens is a hash of language-independent lexical tokens interpolated in pattern matching
# tokens /*<XHIST>*/ and /*</XHIST>*/	delimit instrumentation added to code.
# /* xhist debug TRUE|FALSE */ 		turns on/off debug output
# /* xhist instrument TRUE|FALSE */ 	turns on/off instrumentation
our %tokens = (
	identifier    	=> q:[a-zA-Z0-9_\.]+:	,
	operator	=> q:[-+<>=!\^\(,\)]:	,
	xh_st  		=> q:/*<XHIST>*/:  	, # for use in replacement ptn
	xh_end		=> q:/*</XHIST>*/: 	, # for use in replacement ptn
	xh_stq 		=> q:\/\*<XHIST>\*\/:	, # escaped for use in search ptn
	xh_endq 	=> q:\/\*<\/XHIST>\*\/:	, # escaped for use in search ptn
	xh_dbg_T	=> q:\/\*\s+xhist\s+debug\s+TRUE\s*\*\/:,
	xh_dbg_F	=> q:\/\*\s+xhist\s+debug\s+FALSE\s*\*\/:,
	xh_inst_T	=> q:\/\*\s+xhist\s+instrument\s+TRUE\s*\*\/:,
	xh_inst_F	=> q:\/\*\s+xhist\s+instrument\s+FALSE\s*\*\/:,
);

# $templates are language-specific that we insert into code during instrumenting
# at time of parsing.  
our %templates = (
    c	=> {
	trace_stmt	=> q: _XH_ADD( FNUM, LNUM );:,
	write_stmt	=> q: xhist_write:,
	init_stmt	=> q: xhist_init:,
    },
    cc	=> {
	trace_stmt	=> q/ Xhist:add( FNUM, LNUM );/,
	write_stmt	=> q/ Xhist:write/,
	init_stmt	=> q/ Xhist:init/,
    },
    cpp	=> {
	trace_stmt	=> q/ Xhist:add( FNUM, LNUM );/,
	write_stmt	=> q/ Xhist:write/,
	init_stmt	=> q/ Xhist:init/,
    },
    java	=> {
	trace_stmt	=> q/ Xhist.add( FNUM, LNUM );/,
	write_stmt	=> q/ Xhist.write/,
	init_stmt	=> q/ Xhist.init/,
    },
);

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
    my $nesting_level	= 0;	# increment each time we encounter a nested block
    $dbg		= 0;		# TRUE if lexer debugging enabled 
    $instr		= 1;		# TRUE if instrumention enabled
    my $regex;

    # if we don't grok this filetype, return gracefully.
    return $self->{srcbuf} if (!defined $templates{$self->{fext}});

    # refuse to instrument source that's already instrumented.
    return $self->{srcbuf} if $self->{srcbuf} =~ m:$tokens{xh_stq}.*$tokens{xh_endq}:;

    # alas, java has no concept of conditional compilation so we unconditionally
    # add "import XMT.Xhist;" (this is a no-op for languages other than java).
    # we put all instrumentation between <XHIST> markers to allow for uninstrumentation
    my $repl = '"$&\n$tokens{xh_st} import XMT.Xhist; $tokens{xh_end}\n"';
    $self->{srcbuf} =~ s:\n(package|import)\s+.*?\n:$repl:ees;
    my $ptn = '/\*\s*<XHIST INIT>\s*\*/';
    my $v	= '$' . 'Version' . ':$';
    my $mf	= '$' . 'XhistMap' . ':$';
    my $tf	= $self->{srcfn};
    my $init_stmt = interpolate( $templates{$self->{fext}}{init_stmt}, $self->{fext} );
    $repl = '"$&$tokens{xh_st} $init_stmt(\"$tf\", \"$mf\", \"$v\"); $tokens{xh_end}"';
    $self->{srcbuf} =~ s:$ptn:$repl:ees;

    # add Xhist.write() call after  <XHIST WRITE> comment
    my $ptn = '/\*\s*<XHIST WRITE>\s*\*/';
    my $write_stmt = interpolate( $templates{$self->{fext}}{write_stmt}, $self->{fext} );
    $repl 	= '"$&$tokens{xh_st} $write_stmt(); $tokens{xh_end}"';
    $self->{srcbuf} =~ s:$ptn:$repl:ees;

    # now process srcbuf, matching templates
    my $srccpy = $self->{srcbuf};	# working copy of srcbuf
    $self->{srcbuf} = '';		# empty ready for reconstructing
    $self->{lnum} = 1;			# keep track of line numbers 
    # iterate through srccpy, instrumenting executable statements inside code blocks
    while ($srccpy ne '')	
    {
	# scan for either a block comment or inline comment or braces or a semicolon.
	# if none found, append entire buffer to srcbuf & return.
	my $block = '';
	my ($prematch, $matched, $postmatch) = $srccpy =~ m:(.*?)(/\*|//|{|}|;)(.*):s;
	if (!defined $matched) # nothing found. Just append to srcbuf & return.
	{
	    $self->{srcbuf} .= $srccpy;
	    $self->{lnum} += ($srccpy =~ tr/\n//);	# increment lnum by # of newlines in block
	    return $self->{srcbuf};
	}

	if ($matched eq "//") # the thing matched was an inline comment 
	{
	    my ($cmt, $rest) = $postmatch =~ m:(.*?)(\n.*):s;	# swallow everything up to "\n"
	    $block = $prematch . $matched . $cmt;
	    $srccpy = $rest; 
	    $self->{srcbuf} .= $block;			# append the processed block to srcbuf
	    $self->{lnum} += ($block =~ tr/\n//);	# increment lnum by # of newlines found
	    next;
	}

	if ($matched eq "/*") # the thing matched was a comment block
	{
	    my ($cmt, $rest) = $postmatch =~ m:(.*?\*/)(.*):s;	# swallow everything up to "*/"
	    $block = $prematch . $matched . $cmt;
	    $srccpy = $rest; 

	    # "xhist debug TRUE" inside comment delimiters enables debug output 
	    if ( $block =~ /$tokens{xh_dbg_T}/s )
	    {
		$dbg = 1;
		$block .= "\t<DEBUG ON>" if $dbg;
	    }

	    # "xhist debug FALSE" inside comment delimiters disables debug output 
	    if ( $block =~ /$tokens{xh_dbg_F}/s )
	    {
		$dbg = 0;
	    }

	    # "xhist instrument TRUE" inside comment delimiters enables instrumentation
	    if ( $block =~ /$tokens{xh_inst_T}/s )
	    {
		$instr = 1;
		$block .= "\t<INSTRUMENT ON>" if $dbg;
	    }

	    # "xhist instrument FALSE" inside comment delimiters disables instrumentation
	    if ( $block =~ /$tokens{xh_inst_F}/s )
	    {
		$instr = 0;
		$block .= "\t<INSTRUMENT OFF>" if $dbg;
	    }
	    $self->{srcbuf} .= $block;			# append the processed block to srcbuf
	    $self->{lnum} += ($block =~ tr/\n//);	# increment lnum by # of newlines found
	    next;
	}

	if ($matched eq "{") # the thing matched was an opening brace and we are not inside a comment
	{
	    $block = $prematch . $matched;
	    $srccpy = $postmatch; 
	    $self->{srcbuf} .= $block;
	    $self->{lnum} += ($block =~ tr/\n//);	# increment lnum by # of newlines found
	    $nesting_level++;
	    next;
	}

	if ($matched eq "}") # the thing matched was a closing brace and we are not inside a comment
	{
	    $block = $prematch . $matched;
	    $srccpy = $postmatch; 
	    $self->{srcbuf} .= $block;
	    $self->{lnum} += ($block =~ tr/\n//);	# increment lnum by # of newlines found
	    $nesting_level--;
	    next;
	}

	if ($matched eq ";") # the thing matched was a semicolon and we are not in a comment
	{
	    $block = $prematch . $matched;
	    $srccpy = $postmatch; 

	    # return, throw, continue, next, break & exit handled identically
	    $regex = interpolate( q:\s+(return|throw|continue|next|break|exit)\b: );
	    $regex2 = interpolate( q:[% identifier %]\.exit\(: );
	    if ( $block =~ /$regex/s || $block =~ /$regex2/s )
	    {
		$block .= "\t<NOT REACHED>"	if ($dbg);
		$self->{srcbuf} .= $block;
		$self->{lnum} += ($block =~ tr/\n//);	# increment lnum by # of newlines found
		next;
	    }

	    # a for statement looks like for ( ... ;
	    $regex = interpolate( q:\s+for\s+\(.*?;: );
	    if ( $block =~ /$regex/s )
	    {
		my ($stmt, $rest) = $postmatch =~ m:(.*?)([\n\s]*\{.*):s; # swallow everything up to brace
		$block .= $stmt;
		$srccpy = $rest; 
		$block .= "\t<FOR>"	if ($dbg);
		$self->{srcbuf} .= $block;
		$self->{lnum} += ($block =~ tr/\n//);	# increment lnum by # of newlines found
		next;
	    }

	    # a declaration looks like two identifers in a row followed by a semicolon
	    # or like a constructor call   = new ...
	    $regex = interpolate( q:\n\s*[% identifier %]\**\s+[% identifier %].*?;: );
	    my $regex2 = interpolate( q:\s*=\s*new\s+[% identifier %]: );
	    if ( $block =~ /$regex/s || $block =~ /$regex2/s )
	    {
		$block .= "\t<DECLARATION>"	if ($dbg);
		$self->{srcbuf} .= $block;
		$self->{lnum} += ($block =~ tr/\n//);	# increment lnum by # of newlines found
		next;
	    }

	    # GOT TO HERE ---------
	    # a function call looks like identifier( ... );
	    $regex = interpolate( q:\s*[% identifier %]\(.*\);: );
	    if ( $block =~ /$regex/s )
	    {
		$block .= "\t<FUNC CALL>"	if ($dbg);
		$self->{srcbuf} .= $block;
		$self->{lnum} += ($block =~ tr/\n//);	# increment lnum by # of newlines found
		if ( $instr && $nesting_level > 0 )
		{
		    (my $repl = $templates{$self->{fext}}{trace_stmt}) =~ s/FNUM/$self->{fnum}/g;
		    $repl =~ s/LNUM/$self->{lnum}/g;
		    eval {$self->{srcbuf} .= $xtokens{h_st} . $repl . $tokens{xh_end} }; 
		}
		next;
	    }

	    # an executable stmt looks like identifier operator ... semicolon 
	    # this is where we append trace statements.  
	    $regex = interpolate( q:[% identifier %]\s*[% operator %].*?;: );
	    if ( $block =~ /$regex/s )
	    {
		$block .= "\t<STMT>"	if ($dbg);
		$self->{srcbuf} .= $block;
		$self->{lnum} += ($block =~ tr/\n//);	# increment lnum by # of newlines found
		if ( $instr && $nesting_level > 0 )
		{
		    (my $repl = $templates{$self->{fext}}{trace_stmt}) =~ s/FNUM/$self->{fnum}/g;
		    $repl =~ s/LNUM/$self->{lnum}/g;
		    eval {$self->{srcbuf} .= $xtokens{h_st} . $repl . $tokens{xh_end} }; 
		}
		next;
	    }

	    # matched no known pattern; leave uninstrumented 
	    {
		$self->{srcbuf} .= $block;
		$self->{lnum} += ($block =~ tr/\n//);	# increment lnum by # of newlines found
	    }
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
    return $self->{srcbuf} if (!defined $templates{$self->{fext}});

    $self->{srcbuf} =~ s:$tokens{xh_stq}(.*?)$tokens{xh_endq}::sg;
    return $self->{srcbuf};
}

#************************************************************************/
# private function interpolate returns $ptn with all token values interpolated 
#************************************************************************/
sub interpolate
{
    my ($ptn) = @_;
    my $output = $ptn;

    foreach my $key (keys %tokens)
    {
        $output =~ s/\[% $key %\]/$tokens{$key}/g;
    }
    return $output;
}

1;
