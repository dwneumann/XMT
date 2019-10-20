#!/usr/bin/env perl
#************************************************************************
#*   $Version:$
#*   Package	: xmt_metrics
#*   Synopsis	: metricsDB.pl
#*   Purpose	: A library of functions to access the metrics database.
#*		  Invoked by the commandline and CGI interfaces.
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
#************************************************************************

package MetricsDB;
use strict 'vars';
use Env;
use Carp;
use DBI;
use lib $ENV{XMTMETRICS}.'/bin'; # specifies where to find local classes
use Metrics::Task;
use Metrics::Assignment;

@::query_results = ();

#************************************************************************
# GENERIC ROUTINES ...
#************************************************************************
#************************************************************************
# connect($dbname, $unm, $pswd): Connect to the named database and
# authenticate the user-supplied username and password against those
# stored in the database.  Return 1 if they match, & 0 otherwise.
#************************************************************************
sub connect
{
    my ($dbname, $unm, $pswd) = @_;
    my ($stmt, @results);

    $MetricsDB::dbh	= DBI->connect( "dbi:Pg:$dbname", '', '', ) || 
		  dbdie( "$dbname : $DBI::errstr" );

#    $stmt = "select pers_passwd from Persons where pers_uname='$unm'";
#    &query( $stmt, \@results );
#    if ( $#results < 0 || crypt( $pswd, $results[0]{pers_passwd} ) 
#	ne $results[0]{pers_passwd} )
#    {
#	return 0;
#    }
    return 1;
}


#************************************************************************
# query($stmt): execute the query <$stmt> and place the results into 
# the array @::query_results.  Each element of that array is a hash
# of column names and column values for a single row.
#************************************************************************
sub query
{
    my ($stmt) = @_;
    my ($hashref);
    $MetricsDB::sth = $MetricsDB::dbh->prepare( $stmt) || dbdie( "$DBI::errstr" );
    $MetricsDB::sth->execute || dbdie( "$DBI::errstr" );
    while ( $hashref = $MetricsDB::sth->fetchrow_hashref )
    {
	push( @::query_results, $hashref );
    }

    #********************************************************************
    # finish the statement but do not undef $sth. 
    # The caller will reference the underlying data structures.
    #********************************************************************
    $MetricsDB::sth->finish; 
}

#************************************************************************
# loadquery($fn): Returns the contents of file $fn into a buffer 
# If no $fn is specified the default is $XMTMETRICS/proto/queries/default
#************************************************************************
sub loadquery
{
    my ($fn, $buf) = @_;
    my (@selections, $s);

    $fn = sprintf("%s/proto/queries/default", $ENV{'XMTMETRICS'}) 
    	if !defined($fn);
    open( TMPL, "<$fn" ) || dbdie( "$fn: $!" );
    undef $/;
    $buf = <TMPL>;
    close( TMPL ) || dbdie ( "$fn: $!" );
    return $buf;
}

#************************************************************************
# format_report($fn): Format the query results
# @::query_results according to the Perl block contained in
# the file $fn. 
# If no $fn is specified the default is $XMTMETRICS/proto/reports/default
#************************************************************************
sub format_report
{
    my ($fn, $buf) = @_;

    $fn = sprintf("%s/proto/reports/default", $ENV{'XMTMETRICS'}) 
    	if !defined($fn);

    # debugging is easier if we copy the eval block into this
    # namespace as a subroutine with the name &$fn (with all
    # characters that would be illegal in an identifier replaced with
    # underscores).  So, if such a subroutine exists, we call it,
    # rather than evaling the file.
    my $func;
    ($func = $fn) =~ s{.*/}{};
    $func  =~ s/[^\w]/_/g;
    if ( defined &$func )
    {
	&$func();
    }
    else
    {
	open( TMPL, "<$fn" ) || MetricsDB::dbdie( "$fn: $!" );
	undef $/;
	$buf = <TMPL>;
	close( TMPL ) || MetricsDB::dbdie( "$fn: $!" );
	eval $buf;
    }
}

#************************************************************************
# dbdie($msg): disconnect from the dbms, display msg, & exit
#************************************************************************
sub dbdie
{
    my ($msg) = @_;
    $MetricsDB::dbh->disconnect	if ( defined $MetricsDB::dbh );
    undef $MetricsDB::dbh;
    undef $MetricsDB::sth;
    confess( $msg . "\n" ) if ( defined $msg && $msg !~ /^\s*$/ );
    exists $ENV{'MOD_PERL'} ? Apache::exit() : exit 0;
}

1;
