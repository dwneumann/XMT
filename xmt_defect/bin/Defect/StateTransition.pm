#!/usr/local/bin/perl -w
#************************************************************************
#*   $Version:$
#*   Package	: xmt_defect
#*   Purpose	: StateTransition class.  Used by defectDB.pl.
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

package Defect::StateTransition;
use lib $ENV{XMTDEFECT}.'/bin'; # specifies where to find local classes
use Defect::StateMachine;
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
# new($oid): instantiate a new StateTransition object. If
# $oid is supplied, the object is associated with the
# DefectDB record with the same oid. The DefectDB is accessed
# through DBI connection $DefectDB::dbh. Returns true if the object
# is successfully instantiated, and undef otherwise.
#************************************************************************
sub new 
{
    my ($class, $oid) = @_;
    my $self = {};

    $self->{dbh}	= $DefectDB::dbh if defined($DefectDB::dbh);
    $self->{oid}	= $oid	 if defined($oid);
    $self->{defect}	= 0;
    $self->{time}	= "";
    $self->{from}	= "";
    $self->{to}		= "";
    $self->{uname}	= "";
    $self->{remarks}	= "";

    if (defined($oid))
    {
	_fetch($self) or return undefErr;
    }
    bless $self, $class;
    return $self;
}

#************************************************************************
# update: update the record in the Defect database with the values of
# the object.  If the object has not been instantiated in the
# database yet, the record is inserted rather than updated. The
# StateMachine prefunction is executed to validate the transition,
# and if valid, the StateMachine postfunction is executed after the
# transition.
#************************************************************************
sub update
{
    my ($self) = @_;
    my ($stmt, $sth, $defect, $fsm, $uname);

    # validate the dependent records specified
    $defect = new Defect::Defect($self->{defect}) or return undefErr;
    $fsm = new Defect::StateMachine($self->{from}, $self->{to}) 
    	or return undefErr;
    $uname = new Defect::Person($self->{uname}) or return undefErr;

    # execute the pre-transition trigger if defined
    # a true return from that function indicates the transition is allowed
    if (defined($fsm->{prefunc}))
    {
        return if (!defined &{$fsm->{prefunc}} || ! &{$fsm->{prefunc}});
    }

    if (defined($self->{oid}))
    {
	$stmt = "update StateTransition set
		    defect	= '$self->{defect}',
		    time	= '$self->{time}',
		    from 	= '$self->{from}',
		    to		= '$self->{to}',
		    uname	= '$self->{uname}',
		    remarks	= '$self->{remarks}'
		    where oid = $self->{oid} ";
    }
    else
    {
	$stmt = "insert into StateTransition 
		    values (
		    '$self->{defect}',
		    '$self->{time}',
		    '$self->{from}',
		    '$self->{to}',
		    '$self->{uname}',
		    '$self->{remarks}')";
    }
    $sth = $self->{dbh}->prepare($stmt) or return undefErr;
    $sth->execute or return undefErr;
    _fetch($self) or return undefErr; # needed to retrieve oid

    # execute the post-transition trigger if defined
    if (defined($fsm->{postfunc}) && defined &{$fsm->{postfunc}})
    {
        &{$fsm->{postfunc}};
    }

    # send a notification to the specified email address if defined
    if (defined($fsm->{email}))
    {
	my $cmd;
	$cmd = sprintf("mailx -s 'Defect %s state changed' %s", 
		$self->{defect}, $fsm->{email}); 
	open( MAIL, "|$cmd" ) or warn("mailx: $!\n");
	printf(CMD "Defect ID\t: %s\n", $self->{defect});
	printf(CMD "Timestamp\t: %s\n", $self->{time});
	printf(CMD "Old state\t: %s\n", $self->{from});
	printf(CMD "New state\t: %s\n", $self->{to});
	printf(CMD "Initating user\t: %s\n", $self->{uname});
	printf(CMD "Remarks\t: %s\n", $self->{remarks});
	close(CMD);
    }
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
	$stmt = "delete from StateTransition
		    where oid = $self->{oid} ";
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
    
    $stmt = "select oid,* from StateTransition 
	    where defect = $self->{defect} and time = $self->{time}";
    $sth = $self->{dbh}->prepare($stmt) or return undefErr;
    $sth->execute or return undefErr;
    $rc = $sth->bind_columns(undef, 
		    \$self->{defect},
		    \$self->{time},
		    \$self->{from},
		    \$self->{to},
		    \$self->{uname},
		    \$self->{remarks});
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


