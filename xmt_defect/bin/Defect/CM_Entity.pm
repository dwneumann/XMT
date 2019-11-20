#!/usr/local/bin/perl -w
#************************************************************************
#*   $Version:$
#*   Package	: xmt_defect
#*   Purpose	: CM_Entity class.  Used by defectDB.pl.
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

package Defect::CM_Entity;
use lib $ENV{XMTDEFECT}.'/bin'; # specifies where to find local classes
use Defect::Defect;
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
# new($oid): instantiate a new CM_Entity object. If
# $oid is supplied, the object is associated with the
# DefectDB CM_Entities record with the same oid.. The DefectDB is accessed
# through DBI connection $DefectDB::dbh. Returns true if the object
# is successfully instantiated, and undef otherwise.
#************************************************************************
sub new 
{
    my ($class, $oid) = @_;
    my $self = {};

    $self->{dbh}	= $DefectDB::dbh if defined($DefectDB::dbh);
    $self->{oid}	= $oid	if defined($oid);
    $self->{defect}	= 0;
    $self->{filename}	= "";
    $self->{revision}	= "";

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
    my ($stmt, $sth, $defect);

    # validate the defect ID specified
    $defect = new Defect::Defect($self->{defect}) || return undefErr;

    if (defined($self->{oid}))
    {
	$stmt = "update CM_Entities set
		    defect	= $self->{defect},
		    filename	= '$self->{filename}',
		    revision	= '$self->{revision}'
		    where oid	= $self->{oid} ";
    }
    else
    {
	$stmt = "insert into CM_Entities 
		    values (
		    '$self->{defect}',
		    '$self->{filename}',
		    '$self->{revision}')";
    }
    $sth = $self->{dbh}->prepare($stmt) or return undefErr;
    $sth->execute or return undefErr;
    _fetch($self) or return undefErr; # needed to retrieve oid
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
	$stmt = "delete from CM_Entity where oid = $self->{oid}";
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
    
    $stmt = "select oid,* from CM_Entities 
	    where defect = $self->{defect} 
	    and filename = $self->{filename}";
    $sth = $self->{dbh}->prepare($stmt) or return undefErr;
    $sth->execute or return undefErr;
    $rc = $sth->bind_columns(undef, 
		    \$self->{defect},
		    \$self->{filename},
		    \$self->{revision});
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

