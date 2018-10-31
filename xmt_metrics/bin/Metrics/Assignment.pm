#!/usr/local/bin/perl -w
#************************************************************************
#*   $Version:$
#*   Package	: xmt_metrics
#*   Purpose	: Assignments class.  Used by metricsDB.pl.
#*                This class is closely related to the Metrics database
#*                schema.  Change that, and this class will probably also
#*		  need to be changed.
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

package Metrics::Assignment;
use Carp;
use DBI;

sub version 
{
    local $^W=0; 
    my @v = split(/\s+/,'$Version:$'); 
    my $s=sprintf("%f", $v[1]);
    $s=~ s/0+$//;
    return $s;
}
$VERSION = &version;

#************************************************************************
# new($oid): instantiate a new Assignment object.
# If $oid is supplied, the object is associated with the MetricsDB
# record with the same oid.  The MetricsDB is accessed
# through DBI connection $MetricsDB::dbh. Returns true if the object
# is successfully instantiated, and undef otherwise.
#************************************************************************
sub new 
{
    my ($class, $oid) = @_;
    my $self = {};

    $self->{dbh}	= $MetricsDB::dbh if defined($MetricsDB::dbh);
    $self->{oid}	= $oid	 if defined($oid);
    $self->{wbs}	= "";
    $self->{uname}	= "";
    $self->{est_effort}	= 0;
    $self->{act_effort}	= 0;
    $self->{est_size}	= 0;
    $self->{act_size}	= 0;
    $self->{est_start}	= "";
    $self->{est_end}	= "";
    $self->{act_start}	= "";
    $self->{act_end}	= "";
    $self->{est_prod}	= 0;
    $self->{act_prod}	= 0;
    $self->{efficiency}	= 0;
    $self->{remarks}	= "";

    if (defined($oid))
    {
        _fetch($self) or return undefErr;
    }
    bless $self, $class;
    return $self;
}

#************************************************************************
# update: update the record in the Metrics database with the values
# of the object.  If the object has not been instantiated in the
# database yet, the record is inserted rather than updated.
#************************************************************************
sub update
{
    my ($self) = @_;
    my ($stmt, $sth);

    if (defined($self->{oid}))
    {
	$stmt = "update Assignments
		    set wbs 		= '$self->{wbs}',
		    set uname		= '$self->{uname}',
		    set est_effort	=  $self->{est_effort},
		    set act_effort	=  $self->{act_effort},
		    set est_size	=  $self->{est_size},
		    set act_size	=  $self->{act_size},
		    set est_start	= '$self->{est_start}',
		    set est_end		= '$self->{est_end}',
		    set act_start	= '$self->{act_start}',
		    set act_end		= '$self->{act_end}',
		    set est_prod	=  $self->{est_prod},
		    set act_prod	=  $self->{act_prod},
		    set efficiency	=  $self->{efficiency},
		    set remarks		= '$self->{remarks}',
		    where oid = $self->{oid} ";
    }
    else
    {
	$stmt = "insert into Assignments 
		    values (
		    '$self->{wbs}', 
		    '$self->{uname}',
		     $self->{est_effort},
		     $self->{act_effort},
		     $self->{est_size},
		     $self->{act_size},
		    '$self->{est_start}',
		    '$self->{est_end}',
		    '$self->{act_start}',
		    '$self->{act_end}',
		     $self->{est_prod},
		     $self->{act_prod},
		     $self->{efficiency},
		    '$self->{remarks}'
		    )";
    }
    $sth = $self->{dbh}->prepare($stmt) or return undefErr;
    $sth->execute or return undefErr;
    _fetch($self) or return undefErr; # needed to retrieve oid
}

#************************************************************************
# delete: delete the record in the Metrics database associated 
# with the object.
#************************************************************************
sub delete
{
    my ($self) = @_;
    my ($stmt, $sth);

    $stmt = "delete from Assignments where oid = $self->{oid}";
    $sth = $self->{dbh}->prepare($stmt) or return undefErr;
    $sth->execute or return undefErr;
}

#************************************************************************
# _fetch: fetch values from the database & populate fields of the
# associated object
#************************************************************************
sub _fetch
{
    my ($self) = @_;
    my ($stmt, $sth, $rc);
    
    $stmt = "select oid,* from Assignments 
	    where wbs = '$self->{wbs}'";
    $sth = $self->{dbh}->prepare($stmt) or return undefErr;
    $sth->execute or return undefErr;
    $rc = $sth->bind_columns(undef, 
	    \$self->{oid}, 
	    \$self->{wbs}, 
	    \$self->{uname},
	    \$self->{est_effort},
	    \$self->{act_effort},
	    \$self->{est_size},
	    \$self->{act_size},
	    \$self->{est_start},
	    \$self->{est_end},
	    \$self->{act_start},
	    \$self->{act_end},
	    \$self->{est_prod},
	    \$self->{act_prod},
	    \$self->{efficiency},
	    \$self->{remarks} );
    $sth->fetch or return undefErr; 
}

#************************************************************************
# stub DESTROY so the autoloader won't search for it.
#************************************************************************
sub DESTROY { }

sub undefErr
{
    carp("$DBI::errstr") if $DBI::errstr;
    return undef;
}

1;
