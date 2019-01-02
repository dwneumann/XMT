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
my %filemap = ();
my %lexers  = (
    c		=> instrument_c,
    java	=> instrument_java,
    );


#************************************************************************/
# class method new($f, $$bufp) 
# instantiates a new Xhist object for filename $f & contents $bufp.
# Returns the object handle to the instrumented source object.
#************************************************************************/
sub new
{
    my ($f, $bufp) = @_;
    my $self = {};

    $self->{fname}	= $f  if defined($f);
    ($self->{fext}	= $self->{fname}) =~ s/.*\.([^\.]*)/$1/;
    $self->{fnum}	= crc16($self->{fname});	# calculate hash of fname
    $self->{fnum}++  while ( grep $self->{fnum}, values %filemap ); # handle collisions
    $filemap{$self->{fname}} = $self->{fnum};	# add name & hash to filemap
    $self->{lnum}	= 0;
    $self->{buf}	= $$bufp;
    bless $self;

    # if there is a lexer for this filetype, call it now.
    if (defined $lexers{$self->{fext}})
    {
        &{$lexers{$self->{fext}}}($self);
    }
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
#  instance method instrument_c instruments a C file 
#************************************************************************/
sub instrument_c
{
    my $self = shift;

    ##  language syntax is captured here...
    local $identifier    	= qr([a-zA-Z0-9_]+)				;
    local $operator		= qr([-+<>=!\^\(])				;
    local $func_start		= qr(^\{\s*$)					;
    local $func_end		= qr(^\}\s*$)					;
    local $declaration		= qr(^\s*$identifier\**\s+\(?\**$identifier.*[,;]$);
    local $for_stmt		= qr(\s+for\s+\(.*;.*$)				;
    local $rtn_stmt		= qr(\s+return\s*\(*.*\)*\s*;)			;
    local $executable_stmt	= qr($operator.*;)				;
    local $xh_debug_true	= qr(/\*\s+xhist\s+debug\s+TRUE\s*\*\/)		;
    local $xh_debug_false	= qr(/\*\s+xhist\s+debug\s+FALSE\s*\*\/)	;
    local $xh_instrument_true	= qr(/\*\s+xhist\s+instrument\s+TRUE\s*\*\/)	;
    local $xh_instrument_false	= qr(/\*\s+xhist\s+instrument\s+FALSE\s*\*\/)	;
    local $trace_stmt		= '	_XH_ADD( FNUM, LNUM );'			; 

    $self->{buf} = <<__END__ . $self->{buf};
#ifdef XHIST
#include "xhist.h"
#endif 
__END__

    $self->_instrument();
}

#************************************************************************/
#  instance method instrument_c instruments a java file 
#************************************************************************/
sub instrument_java
{
    my $self = shift;

    ##  language syntax is captured here...
    local $identifier    	= qr([a-zA-Z0-9_]+)				;
    local $operator		= qr([-+<>=!\^\(])				;
    local $func_start		= qr(^(public|private|protected).*\{\s*$)	;
    local $func_end		= qr(^\}\s*$)					;
    local $declaration		= qr(^\s*$identifier\**\s+\(?\**$identifier.*[,;]$);
    local $for_stmt		= qr(\s+for\s+\(.*;.*$)				;
    local $rtn_stmt		= qr(\s+return\s*\(*.*\)*\s*;)			;
    local $executable_stmt	= qr($operator.*;)				;
    local $xh_debug_true	= qr(/\*\s+xhist\s+debug\s+TRUE\s*\*\/)		;
    local $xh_debug_false	= qr(/\*\s+xhist\s+debug\s+FALSE\s*\*\/)	;
    local $xh_instrument_true	= qr(/\*\s+xhist\s+instrument\s+TRUE\s*\*\/)	;
    local $xh_instrument_false	= qr(/\*\s+xhist\s+instrument\s+FALSE\s*\*\/)	;
    local $trace_stmt		= '	Xhist.add( FNUM, LNUM );'		; 

    $self->{buf} = <<__END__ . $self->{buf};
import Xhist.*;
__END__

    $self->_instrument();
}

#************************************************************************/
#  language-independent instrumenter instance method invoked from instrument_*
#************************************************************************/
sub _instrument
{
    my $self = shift;
    my $in_func		= 0;	# TRUE if inside a routine     
    my $xh_debug	= 0;	# TRUE if debugging lexer 
    my $xh_instrument	= 1;	# TRUE if instrumenting should occur

    my @lines	 = split /\n/, $self->{buf};
    $self->{lnum} = 0;
    $self->{buf} = '';
    while (scalar @lines > 0)
    {
	$_ = shift @lines;
	$self->{lnum}++;

	# append instrumentation to line ...
	# "xhist debug TRUE" inside a comment enables tracing 
	if ( m:${xh_debug_true}: )
	{
	    $xh_debug = 1;
	    $self->{buf} .= "$_\t/*<DEBUG ON>*/\n";
	}

	# "xhist debug FALSE" inside a comment disables tracing 
	elsif ( m:${xh_debug_false}: )
	{
	    $xh_debug = 0;
	    $self->{buf} .= "$_\t/*<DEBUG OFF>*/\n";
	}

	# "xhist instrument TRUE" inside a comment enables instrumentation
	elsif ( m:${xh_instrument_true}: )
	{
	    $xh_instrument = 1;
	    $self->{buf} .= $_ . ($xh_debug ? "\t/*<INSTRUMENT ON>*/" : '') . "\n";
	}

	# "xhist instrument FALSE" inside a comment disables instrumentation
	elsif ( m:${xh_instrument_false}: )
	{
	    $xh_instrument = 0;
	    $self->{buf} .= $_ . ($xh_debug ? "\t/*<INSTRUMENT OFF>*/" : '') . "\n";
	}

	elsif ( m:${func_start}: )
	{
	    $in_func = 1;
	    $self->{buf} .= $_ . ($xh_debug ? "\t/*<FUNC START>*/" : '') . "\n";
	}

	elsif ( m:${func_end}: )
	{
	    $in_func = 0;
	    $self->{buf} .= $_ . ($xh_debug ? "\t/*<FUNC END>*/" : '') . "\n";
	}

	elsif ( m:${declaration}: )
	{
	    $self->{buf} .= $_ . ($xh_debug ? "\t/*<DECL>*/" : '') . "\n";
	}

	elsif ( m:${for_stmt}: )
	{
	    $self->{buf} .= $_ . ($xh_debug ? "\t/*<FOR>*/" : '') . "\n";
	}

	elsif ( m:${rtn_stmt}: )
	{
	    if ( $in_func )
	    {
	    $self->{buf} .= $_ . ($xh_debug ? "\t/*<RETURN>*/" : '') . "\n";
	    }
	    else
	    {
		$self->{buf} .= $_ . ($xh_debug ? "\t/*<RETURN OUTSIDE FUNC>*/" : '') . "\n";
	    }
	}

	# a line containing an operator and terminating with a semicolon indicates 
	# an executable statement. this is where we append trace statements.
	# anything else is passed through unaltered.
	elsif ( m:${executable_stmt}: )
	{
	    if ( $in_func )
	    {
		$self->{buf} .= $_ . ($xh_debug ? "\t/*<STMT>*/" : '');
		(my $repl = $trace_stmt) =~ s/FNUM/$self->{fnum}/g;
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
	}
	else	# matches nothing; just output original line
	{
	    $self->{buf} .= "$_ \n";	
	}
    }
}

1;
