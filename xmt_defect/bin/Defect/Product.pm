#!/usr/local/bin/perl -w
#************************************************************************
#*   $Version:$
#*   Package	: xmt_defect
#*   Purpose	: StateMachines class.  Used by defectDB.pl.
#*                This class is closely related to the Defect database
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

package Defect::Product;
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
# new($oid): instantiate a new
# Product object. If $oid is supplied, the object is associated with
# the DefectDB record with the same oid.  The DefectDB is accessed through
# DBI connection $DefectDB::dbh. Returns true if the object is
# successfully instantiated, and undef otherwise.
#************************************************************************
sub new 
{
    my ($class, $oid) = @_;
    my $self = {};

    $self->{dbh}	= $DefectDB::dbh if defined($DefectDB::dbh);
    $self->{oid}	= $oid	 	if defined($oid);
    $self->{name}	= "";
    $self->{revision}	= "";
    $self->{os}		= "";
    $self->{arch}	= "";
    $self->{config}	= "";

    if (defined($oid))
    {
	_fetch($self) or return undefErr;
    }
    bless $self, $class;
    return $self;
}

#************************************************************************
# update: update the record in the Defect database with the values
# of the object.  If the object has not been instantiated in the
# database yet, the record is inserted rather than updated.
#************************************************************************
sub update
{
    my ($self) = @_;
    my ($stmt, $sth);

    if (defined($self->{oid}))
    {
	$stmt = "update Products set
		    name	= '$self->{name}',
		    revision	= '$self->{revision}',
		    os		= '$self->{os}',
		    arch	= '$self->{arch}',
		    config	= '$self->{config}'
		    where oid	= $self->{oid} ";
    }
    else
    {
	$stmt = "insert into Products 
		    values (
			'$self->{name}',
			'$self->{revision}',
			'$self->{os}',
			'$self->{arch}',
			'$self->{config}'
		    )";
    }
    $sth = $self->{dbh}->prepare($stmt) or return undefErr;
    $sth->execute or return undefErr;
    _fetch($self) or return undefErr;
}

#************************************************************************
# delete: delete the record in the Defect database associated 
# with the object.
#************************************************************************
sub delete
{
    my ($self) = @_;
    my ($stmt, $sth);

    if (defined($self->{oid}))
    {
	$stmt = "delete from StateMachines where oid = $self->{oid}";
	$sth = $self->{dbh}->prepare($stmt) or return undefErr;
	$sth->execute or return undefErr;
    }
}

#************************************************************************
# _fetch: fetch values from the database & populate fields of the
# associated object
#************************************************************************
sub _fetch
{
    my ($self) = @_;
    my ($stmt, $sth, $rc);
    
    $stmt = "select oid,* from Products 
	    where name	= '$self->{name}'
	    and revision= '$self->{revision}'
	    and os	= '$self->{os}'
	    and arch	= '$self->{arch}'
	    and config	= '$self->{config}' ";
    $sth = $self->{dbh}->prepare($stmt) or return undefErr;
    $sth->execute or return undefErr;
    $rc = $sth->bind_columns(undef, 
	    \$self->{name},
	    \$self->{revision},
	    \$self->{os},
	    \$self->{arch},
	    \$self->{config} );
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

