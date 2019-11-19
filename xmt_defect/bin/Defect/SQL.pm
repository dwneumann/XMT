#!/usr/local/bin/perl -w
#************************************************************************
#*   $Version:$
#*   Package	: xmt_defect
#*   Purpose	: fake SQL class.  All defectsrv.pl really wants out of it 
#*                is a prettyprinter.  So until a real SQL class
#*                comes along, we'll just fake it.
#*
#*   Copyright (c) 1998	Neumann & Associates Information Systems Inc.
#*   			legal.info@neumann-associates.com
#*   Licensed under the Apache License, Version 2.0 (the "License");
#*   you may not use this file except in compliance with the License.
#*   You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#*   
#*   Unless required by applicable law or agreed to in writing, software
#*   distributed under the License is distributed on an "AS IS" BASIS,
#*   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#*   See the License for the specific language governing permissions and
#*   limitations under the License. 
#************************************************************************

package Local::SQL;
$VERSION = do { local $^W=0; my $r='$Version:$'; sprintf("%d", $r);};

sub version {
    return $VERSION;
}

sub new {
    my ($class,$str) = @_;
    my $self = {};

    ($self->{buf} = $str) =~ s/\n/ /g;
    bless $self, $class;
    return $self;
}

# stub DESTROY so the autoloader won't search for it.
sub DESTROY { }

#************************************************************************
# method add_clause($conj, $fqfn, $opname, $val) adds the additional
# query qualifier  "$fqfn $opname $val" to the query represented by the object.
# $fqfn is a fully qualified field name of the form 'Table.field'.
# Nested queries are represented by a fqfn of the form 
# 't1.f1=t2.f2->t3.f3' which translate into
#	...where t1.f1 IN (select f2 from t2 where t3.f3 <op> <value>)
# or
# 't1.f1!=t2.f2->t3.f3' which translate into
#	...where t1.f1 NOT IN (select f2 from t2 where t3.f3 <op> <value>)
#
# $opname is one of: eq, eq.n, gt, gte, lt, lte, in, in.n, rx, rx.n
# $val is a valid rhs for the comparison.  Ensuring that the value is 
# properly quoted is the caller's responsibility.
# $conj is one of: "AND" or "OR".  
# All argument values are assumed to be validated by the caller.
#************************************************************************
%ops = ( 'eq'	=> '='	,
	 'eq.n'	=> '<>'	,
	 'gt'	=> '>'	,
	 'gte'	=> '>='	,
	 'lt'	=> '<'	,
	 'lte'	=> '<='	,
	 'in'	=> 'IN'	,
	 'in.n'	=> 'NOT IN',
	 'rx'	=> '~*'	,
	 'rx.n'	=> '!~*',
);
sub add_clause
{
    my ($self, $conj, $fqfn, $opname, $val) = @_;
    my ($t, @tables);
    my ($t1, $t2, $t3, $f1, $f2, $f3);

    return undef if ( $fqfn !~ /^([^\.]+)\.([^\.]+)$/ &&
      $fqfn !~ /^([^\.]+)\.([^\.]+)(!?=)([^\.]+)\.([^\.]+)->([^\.]+)\.([^\.]+)$/ );
    ($t1, $f1, $in, $t2, $f2, $t3, $f3) = ($1, $2, $3, $4, $5, $6, $7);
    $op = $ops{$opname};
    if ( !defined $t2 )
    {
	$qual = "$t1.$f1 $op $val";
    }
    else
    {
	$qual = "$t1.$f1 " . ($in =~ /!/ ? "NOT IN" : "IN") .
	" (select $f2 from $t2 where $t3.$f3 $op $val)";
    }

    $self->{buf} =~ /(.*?\bfrom\b)(.*?)(\bwhere\b.*)/i  || return undef;
    ($stmt, $tbls, $where) = ($1, $2, $3);
    $tbls .= ", $t1" if $tbls !~ /\b$t1\b/i;
    $self->{buf} = "$stmt $tbls $where " . lc( $conj ) . " $qual";
    $self->{buf} =~ s/from\s+,/from /i;
    $self->{buf} =~ s/where\s+(and|or)\b/where /i;
    return $self->{buf};
}

sub prettyprint {
    my ($self) = @_;
    my ($buf, $kw);

    ($buf=$self->{buf}) =~ s/[\n\s]+/ /g;
    foreach $kw ( qw{select where and or} )
    {
	$buf =~ s/\b($kw)\b/"\n".' 'x(length('select')-length($1)).$1.' '/gme;
    }
    $buf =~ s/^[\n\s]+//;
    return $buf;
}

1;
