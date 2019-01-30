#!/usr/bin/env perl
#************************************************************************
#*   $Version:$
#*   Package	: xmt_defect
#*   Purpose	: Defects class.  Used by defectDB.pl.
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

package Defect::Defect;
use lib $ENV{XMTDEFECT}.'/bin'; # specifies where to find local classes
use Defect::Severity;
use Defect::FaultClassification;
use Defect::Product;
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
# new($oid): instantiate a new Defect object.
# If $oid is supplied, the object is associated with the DefectDB
# record with the same oid. The DefectDB is accessed
# through DBI connection $DefectDB::dbh. Returns true if the object
# is successfully instantiated, and undef otherwise.
#************************************************************************
sub new 
{
    my ($class, $oid) = @_;
    my $self = {};

    $self->{dbh}	= $DefectDB::dbh if defined($DefectDB::dbh);
    $self->{oid}	= $oid	 if defined($oid);
    $self->{id}		= 0;
    $self->{severity}	= 0;	# must be set to valid severity 
    $self->{fc}		= 0;	# must be set to valid FaultClassification oid
    $self->{product}	= 0;	# must be set to valid Product oid
    $self->{subject}	= "";

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
    my ($stmt, $sth, $sev, $fc, $prod);

    # validate the dependent objects
    $sev  = new Defect::Severity($self->{severity})	 or return undefErr;
    $fc	  = new Defect::FaultClassification($self->{fc}) or return undefErr;
    $prod = new Defect::Product($self->{product})	 or return undefErr;

    if (defined($self->{oid}))
    {
	$stmt = "update Defects set
		    id		= '$self->{id}',
		    severity	= '$sev->{sev}',
		    fc		=  $fc->{oid},
		    product	=  $product->{oid},
		    subject	= '$self->{subject}'
		    where oid = $self->{oid} ";
    }
    else
    {
	$stmt = "insert into Defects 
		    values (
		    '$self->{id}',
		    '$sev->{sev}',
		     $fc->{oid},
		     $product->{oid},
		    '$self->{subject}'
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
	$stmt = "delete from Defects where oid = $self->{oid}";
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
    
    $stmt = "select oid,* from Defects 
	    where id = '$self->{id}'";
    $sth = $self->{dbh}->prepare($stmt) or return undefErr;
    $sth->execute or return undefErr;
    $rc = $sth->bind_columns(undef, 
		\$self->{id},
		\$self->{severity}->{sev},
		\$self->{fc}->{oid},
		\$self->{product}->{oid},
		\$self->{subject} );
    $sth->fetch or return undefErr;
}

#************************************************************************
# stub DESTROY so the autoloader won't search for it.
#************************************************************************
sub DESTROY { }

sub undefErr
{
    carp("$DBI::errstr") if $DBI::errstr;
    return undefErr;
}

1;

