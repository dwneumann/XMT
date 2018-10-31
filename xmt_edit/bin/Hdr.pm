#************************************************************************
#*   $Version:$
#*   Package	: xmt_edit
#*   Purpose	: 
#*
#*  Copyright (c) 1998	Neumann & Associates Information Systems Inc.
#*  			legal.info@neumann-associates.com
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

package Hdr;

BEGIN {
    require 5.003;
    use Exporter ();
    use Carp;
    use vars	qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    @ISA	= qw(Exporter);
    @EXPORT	= qw(hdr_c_func_kr	
		     hdr_c_func_ansi	hdr_cpp_func
		     hdr_c_synopsis	hdr_cpp_synopsis
		     hdr_c_html		hdr_cpp_html
		     hdr_comment 
		    );
    %EXPORT_TAGS= ();
    @EXPORT_OK	= qw();
}

#************************************************************************/
#  hdr_c_func_kr parses a K&R C function definition 
#  into predefined variables $::funcs, $::args, & $rtnvals
#************************************************************************/
sub hdr_c_func_kr 
{
    my $in	= $_[0];
    my $argbuf;
    my ($f, $a, $r);

    #********************************************************************
    # parse the input into recognizable pieces
    #********************************************************************
    study $in;
    #                 boolean   foo       ( a,  b )  int a, b; {...  
    if ( $in =~ /^\s*([^\(]+)\s+([^\(]+)(\([^\)]*\))([^{]*)/s )
    {
	$f = {};
	$f->{type}	= $1;
	$f->{name}	= $2;
	$f->{proto}	= "$1\t$2$3";
	push @::funcs, $f;
	$argbuf	= $4;
    }
    #                    foo      ( a,  b )  int a, b; {...  
    elsif ( $in =~ /^\s*([^\(]+)(\([^\)]*\))([^{]*)/s )
    {
	$f = {};
	$f->{type}	= "int";
	$f->{name}	= $1;
	$f->{proto}	= "int\t$1$2";
	push @::funcs, $f;
	$argbuf	= $3;
    }
    else
    {
	carp( "unrecognized function definition syntax" );
	return;
    }

    while ( $argbuf =~ /\s*([^,;]+)\s+([^,;]+)[,;](.*)/s )
    {
	$a = {};
	$a->{type}	= $1;
	$a->{name}	= $2;
	push @::args, $a;
	$argbuf	= $3;
    }

    $r = {};
    if ( $::funcs[0]->{type} =~ /void/ ) 
    { 
	$r->{val}	= "none";
	$r->{desc}	= "";
	push @::rtnvals, $r;
    }
    elsif ( $::funcs[0]->{type} =~ /bool(ean)?/i ) 
    { 
	$r->{val}	= "TRUE";
	$r->{desc}	= "function completed successfully";
	push @::rtnvals, $r;

	$r = {};
	$r->{val}	= "FALSE";
	$r->{desc}	= "an error occurred and has been pushed";
	push @::rtnvals, $r;
    }
    else
    { 
	$r->{val}	= "<value>";
	$r->{desc}	= "<description>";
	push @::rtnvals, $r;
    }
}

#************************************************************************/
#  hdr_c_func_ansi parses an ANSI C function definition 
#  into predefined variables $::funcs, $::args, & $rtnvals
#************************************************************************/
sub hdr_c_func_ansi
{
    my $in	= $_[0];
    my $argbuf;
    my ($f, $a, $r, $e);

    #********************************************************************
    # parse the following types of input into recognizable pieces:
    #   static boolean  foo( int a,  float b ) ...  
    #          boolean  foo( int a,  float b ) ...  
    #                   foo( int a,  float b )    ...
    #                   foo()
    #********************************************************************
    study $in;
    # <modifiers> <type> <name>( type1 arg1, type2 arg2 )
    if ( $in =~ /^\s*([^\(]+)\s+([^\(]+)(\([^)]*\))/s )
    {
	$f = {};
	$f->{type}	= $1;
	$f->{name}	= $2;
	($f->{proto}	= "$1\t$2$3") =~ tr/\n/ /s;
	push @::funcs, $f;
	($argbuf	= $3) =~ s/\((.*)\s*\)\s*/$1/s;
    }
    # <type> <name>( type1 arg1, type2 arg2 )
    elsif ( $in =~ /^\s*([^\(]+)(\([^)]*\))/s )
    {
	$f = {};
	$f->{type}	= "int";
	$f->{name}	= $1;
	($f->{proto}	= "int\t$1$2") =~ tr/\n/ /s;
	push @::funcs, $f;
	($argbuf	= $2) =~ s/\((.*)\s*\)\s*/$1/s;
    }
    else
    {
	carp( "unrecognized function definition syntax" );
	return;
    }

    while ( $argbuf =~ /\s*([^,]+)\s+([^,]+)(.*)/s )
    {
	$a = {};
	$a->{type}	= $1;
	$a->{name}	= $2;
	push @::args, $a;
	$argbuf	= $3;
    }

    $r = {};
    if ( $::funcs[0]->{type} =~ /void/ ) 
    { 
	$r->{val}	= "none";
	$r->{desc}	= "";
	push @::rtnvals, $r;
    }
    elsif ( $::funcs[0]->{type} =~ /bool(ean)?/i ) 
    { 
	$r->{val}	= "TRUE";
	$r->{desc}	= "function completed successfully";
	push @::rtnvals, $r;

	$r= {};
	$r->{val}	= "FALSE";
	$r->{desc}	= "an error occurred and has been pushed";
	push @::rtnvals, $r;
    }
    else
    { 
	$r->{val}	= "<value>";
	$r->{desc}	= "<description>";
	push @::rtnvals, $r;
    }

    $e = {};
    $e->{name}		= "<name>";
    $e->{desc}		= "<description>";
    push @::exceps, $e;
}

#************************************************************************/
#  hdr_cpp_func parses a ANSI C++ function definition 
#  into predefined variables $::funcs
#************************************************************************/
sub hdr_cpp_func
{
    my $in	= $_[0];
    my $argbuf;
    my ($f, $a, $r, $e);

    #********************************************************************
    # parse the following types of input into recognizable pieces:
    #  static boolean  foo  ( int a,  float b ) throw (Ex1, Ex2)
    #  boolean  foo( int a,  float b ) throw (Ex1, Ex2)
    #  boolean  foo( int a,  float b ) 
    #  boolean  foo()
    #  Foo::Foo( int a, float b ) throw (Ex1, Ex2)
    #  Foo::Foo()
    #  Foo::~Foo()
    #********************************************************************
    study $in;
    # [<modifiers>] <type> <name>(<args>) [throw (<args>)]
    if ( $in =~ 
       /^\s*([^\(:~]*\b)\s+([^\(]+)(\([^\)]*\))(\s*throw\s*\(([^\)]*)\))*/s )
    {
	$f = {};
	$f->{type}	= $1;
	$f->{name}	= $2;
	$argbuf		= $3;
	$exbuf		= $5;
	$f->{proto}	= "$f->{type}\t$f->{name}$argbuf";
	$f->{exceps}	= $exbuf;
	$argbuf	=~ s/\((.*)\s*\)\s*/$1/s;
	$f->{proto}	=~ tr/\n/ /s;
	$f->{proto}	=~ s/\)\s+throw.*/)/s;
	$f->{exceps}	=~ tr/\n/ /s;
	push @::funcs, $f;
    }
    # this form is for constructors & destructors:
    # <name>(<args>) [throw (<args>)]
    elsif ( $in =~ 
        /^(\s*)([\w:~&]+)(\([^\)]*\))(\s*throw\s*\(([^\)]*)\))*/s )
    {
	$f = {};
	$f->{type}	= $1;
	$f->{name}	= $2;
	$argbuf		= $3;
	$exbuf		= $5;
	$f->{proto}	= "$f->{type}\t$f->{name}$argbuf";
	$f->{exceps}	= $exbuf;
	$argbuf	=~ s/\((.*)\s*\)\s*/$1/s;
	$f->{proto}	=~ tr/\n/ /s;
	$f->{proto}	=~ s/\bthrow.*//s;
	$f->{exceps}	=~ tr/\n/ /s;
	push @::funcs, $f;
    }
    else
    {
	carp( "unrecognized function definition syntax" );
	return;
    }

    # separate the arglist into separate args by type & name
    while ( $argbuf =~ /\s*([^,]+)\s+([^,]+)(.*)/s )
    {
	$a = {};
	$a->{type}	= $1;
	$a->{name}	= $2;
	push @::args, $a;
	$argbuf	= $3;
    }

    # separate exception list into separate exceptions by type 
    while ( $exbuf =~ /\s*([\w]+)\W*(.*)/s )
    {
	$e = {};
	$e->{type}	= $1;
	$e->{desc}	= "<meaning>";
	push @::exceps, $e;
	$exbuf	= $2;
    }
}


#************************************************************************/
#  hdr_c_synopsis parses a NAIS standards-conformant C/C++ file
#  into predefined variables $::funcs 
#************************************************************************/
sub hdr_c_synopsis 
{
    my $in = $_[0];
    my $tmpfunc;

    #********************************************************************
    # collect the Synopsis lines from each function/method header block
    #********************************************************************
    study $in;
    while ( $in =~ /\n\s*\*\s+Synopsis:\s*\n\s*\*\s+([^\n]*)(.*)/s )
    {
	$tmpfunc = {};
	$tmpfunc->{ proto }	= "$1";
	push @::funcs, $tmpfunc;
	$in = "$2";
    }
}

sub hdr_cpp_synopsis 
{
    &hdr_c_synopsis( $_[0] );
}

#************************************************************************/
#  hdr_cpp_html parses an ANSI C or C++ file, storing all information 
#  it obtains into the data structures $::module,
#  $::public_funcs, $::protected_funcs, & $::private_funcs
#************************************************************************/
sub hdr_cpp_html
{
    my $in = $_[0];
    my ($incopy, $hdr, $interface, $specifier);
    my ($f, $a, $r, $s, $e, $t, $p);
    my (@args, @rtns, @exceps);

    study $in;

    #********************************************************************
    # generate printable "<" and ">" chars from \< & \> respectively.
    #********************************************************************
    $in =~ s/\\</\&lt/go;
    $in =~ s/\\>/\&gt/go;

    #********************************************************************
    # find & store the file version number & purpose
    #********************************************************************
    if ( $in =~ m{Entity\s+Id[\s:]*(.*)} )
    {
	$::module->{version} = $1;
    }
    if ( $in =~ m{Purpose[\s:]*\n(.*?)\n[\s\*]*\n}si )
    {
	($::module->{purpose} = $1) =~ s/^\s*\S*\s*/ /mg;
    }

    #********************************************************************
    # collect all files #include'd in the file into an array
    #********************************************************************
    $incopy = $in;
    while ( $incopy =~ m{\n\s*#include\s*"(.*?)"(.*)}s )
    {
	push( @::dependencies, $1 );
	$incopy = $2;
    }

    #********************************************************************
    # collect all DIAG_'s referenced in the file into an array
    #********************************************************************
    $incopy = $in;
    while ( $incopy =~ m{\b(DIAG_\w+)(.*)}s )
    {
	if ( $1 ne "DIAG_TRACE" )
	{
	    push( @::diagnostics, $1 );
	}
	$incopy = $2;
    }

    #********************************************************************
    # collect all signals caught by the code into an array
    #********************************************************************
    $incopy = $in;
    while ( $incopy =~ 
	m{\b(signal|sigset)\b\s*\(\s*(SIG\w+)\s*,\s*(\w+)(.*)}s )
    {
	if ( $2 ne "SIG_IGN" && $2 ne "SIG_DFL" )
	{
	    $s = {};
	    $s->{sig}  = $2;
	    $s->{disp} = $3;
	    push( @::signals, $s ) ;
	}
	$incopy = $4;
    }

    #********************************************************************
    # foreach interface type (public, protected, private),
    # collect all function/method header comment info into an array
    #********************************************************************
    $::srclang = "c";
    $::srclang = "cpp" if ( $in =~ m{(public:|protected:|private:)}m );
    foreach $interface ( qw{ public_funcs protected_funcs private_funcs } )
    {
	($specifier = $interface) =~ s/_funcs//;
	($incopy = $in) =~ s/.*\n$specifier\s*:\s*\n//s;
	 $incopy =~ s/(public:|protected:|private:).*//s;

	while ( $incopy =~ m{(/\*\*.*)\*/(.*)}s )
	{
	    $hdr = $1;
	    $incopy = $2;
	    @args	= ();
	    @rtns	= ();
	    @exceps	= ();

	    if ( $hdr =~ m{Synopsis[\s:]*\n\s*\S*\s*(.*?)\n\s*\S*\s*\n}mi )
	    {
		$f = {};
		$f->{proto} = $1;
		($f->{name} = $f->{proto}) =~ s/.*(\b\w+)\(.*/$1/;

		if ( $hdr =~ m{Purpose[\s:]*\n(.*?)\n[\s\*]*\n}si )
		{
		    ($f->{purpose} = $1) =~ s/^\s*\S*\s*/ /mg;
		}

		while ( $hdr =~ m{(Parameters)[\s:]*\n(.*?)\n[\s\*]*\n(.*)}si 
	      || $hdr =~ m{(Values\s+Returned)[\s:]*\n(.*?)\n[\s\*]*\n(.*)}si 
	      || $hdr =~ m{(Exceptions\s+Thrown)[\s:]*\n(.*?)\n[\s\*]*\n(.*)}si)
		{
		    $ptype = $1;
		    $p = $2;
		    $hdr = $3;
		    while ( $p !~ /^$/ && $p !~ /^none$/i )
		    {
			if ( $p =~ m{(.*?)\n(.*)}s )
			{
			    $t = $1;
			    $p = $2;
			    $t =~ s/^\s*\S*\s*//;
			}
			else 
			{ 
			    ($t = $p) =~ s/^\s*\S*\s*//; 
			    $p = "";
			}

			# at this point $t represents 1 single arg, 
			# return value, or exception
			if ( $ptype =~ /Parameters/i &&
			    $t =~ m{\s*(.*?)\s+(\S+)\s*:\s*\((.*?)\)\s*(.*)} )
			{
			    $a = {};
			    $a->{type}	= $1;
			    $a->{name}	= $2;
			    $a->{passed}= $3;
			    $a->{desc}	= $4;
			    push( @args, $a );
			}
			elsif ( $ptype =~ /Returned/i
			    && $t =~ m{\s*(\S+)\s*:\s*(.*)} )
			{
			    $r = {};
			    $r->{val}	= $1;
			    $r->{desc}	= $2;
			    push( @rtns, $r );
			}
			elsif ( $ptype =~ /Exceptions/i
			    && $t =~ m{\s*(\S+)\s*:\s*(.*)} )
			{
			    $e = {};
			    $e->{val}	= $1;
			    $e->{desc}	= $2;
			    push( @exceps, $e );
			}
		    }
		    $f->{args} = [ @args ]	if ( $ptype =~ /Parameters/i );
		    $f->{rtnvals} = [ @rtns ]	if ( $ptype =~ /Returned/i );
		    $f->{exceptions} = [ @exceps ] if ( $ptype =~ /Exceptions/i );
		}
		$interface =~ s/^/::/;
		push( @$interface, $f );
	    }
	}
	last if ( $::srclang eq "c" );
    }
}

sub hdr_c_html 
{
    &hdr_cpp_html( $_[0] );
}


#************************************************************************/
#  hdr_comment reformats the comment block read from stdin, preserving
#  per-line comment delimiters and indentation, but
#  reformatting the contents of the comment.  
#  The first line of the comment determines the indentation of the per-line
#  comment delimiter with respect to the beginning of the line, and the 
#  indentation of the comment text with respect to the delimiter.
#************************************************************************/
sub hdr_comment 
{
    my $in = $_[0];

    study $in;
    if ( $in =~ /^(\s*)([^\s]*)(\s*)([^\n]+)(.*)/s )
    {
	$::cmt->{delim_indent} = "$1";
	$::cmt->{delim_indent_length} = length("$::cmt->{delim_indent}");
	$::cmt->{delim} = "$2";
	$::cmt->{delim_length} = length("$::cmt->{delim}");
	$::cmt->{text_indent} = "$3";
	$::cmt->{text_indent_length} = length("$::cmt->{text_indent}");
	$::cmt->{text} = "$4";
	$in = "$5";

	while ( $in =~ /\n(\s*)([^\s]*)(\s*)([^\n]+)(.*)/s )
	{
	    $::cmt->{text} .= " $4";
	    $in = $5;
	}
    }
    $::cmt->{text} =~ s/\s*\n+\s*/ /g;
}

#************************************************************************/
#  hdr_java_func parses the Java method definition passed as arg0, 
#  building a structure containing all information gathered about the method 
#  and adding that structure to the predefined array $::module->{funcs}
#************************************************************************/
sub hdr_java_func
{
    my $in	= $_[0];
    my $buf;
    my ($f, $a, $r, $e, $arglist, $exclist);

    #********************************************************************
    # parse the input into recognizable pieces
    #********************************************************************
    study $in;
    #  [<modifiers>] <type> name ( [<args>] ) [throws <exception,exception>]
    #  $1            $2     $3     $4         $5
    if ( $in =~ /^\s*([^\(]*)\b\s*([^\s]+)\s+([^\(]+)\(([^\)]*)\)\s*([^{]*)/s )
    {
	$f = {};
	$f->{modifiers}	= $1;
	$f->{type}	= $2;
	$f->{name}	= $3;
	$arglist	= $4;
	($exclist	= $5) =~ s/throws\s+//;
	($f->{proto}	= "$f->{type}\t$f->{name}($arglist)") =~ tr/\n/ /s;
	@{$f->{args}}	= ();
	@{$f->{exceps}}	= ();
	@{$f->{rtnvals}}= ();
    }
    else
    {
	carp( "unrecognized function definition syntax" );
	return;
    }

    ($buf = $arglist) =~ s/\((.*)\s*\)\s*/$1/s;
    while ( $buf =~ /\s*([^,]+)\s+([^,]+)(.*)/s )
    {
	$a = {};
	$a->{type}	= $1;
	$a->{name}	= $2;
	push @{$f->{args}}, $a;
	$buf		= $3;
    }

    ($buf = $exclist) =~ s/\n/ /g;
    while ( $buf =~ /\s*([^,]+)(.*)/s )
    {
	$e = {};
	$e->{name}	= $1;
	$e->{desc}	= "<description>";
	push @{$f->{exceps}}, $e;
	$buf		= $2;
    }

    $r = {};
    if ( $f->{type} =~ /bool(ean)?/i ) 
    { 
	$r->{val}	= "TRUE";
	$r->{desc}	= "method completed successfully";
	push @{$f->{rtnvals}}, $r;

	$r= {};
	$r->{val}	= "FALSE";
	$r->{desc}	= "an error occurred and has been pushed";
	push @{$f->{rtnvals}}, $r;
    }
    elsif ( $f->{type} !~ /void/ ) 
    { 
	$r->{val}	= "<value>";
	$r->{desc}	= "<description>";
	push @{$f->{rtnvals}}, $r;
    }
    push @{$::module->{funcs}}, $f;
}

1;
