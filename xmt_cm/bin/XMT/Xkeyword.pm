#!/usr/local/bin/perl -w
#************************************************************************
#*   $Version:$
#*   Package	: xmt_cm
#*   Purpose	: Xkeyword class (invoked by git_filter)
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

package XMT::Xkeyword;
use Carp;
use POSIX qw(strftime);

sub version 
{
    local $^W=0; 
    my @v = split(/\s+/,'$Version:$'); 
    my $s=sprintf("%f", $v[1]);
    $s=~ s/0+$//;
    return $s;
}
$VERSION = &version;

%XMT::Xkeyword::kw =  ( 
	Branch		=> { code => '',	val => '' },
	Tag		=> { code => '',	val => '' },
	BuildNum	=> { code => '',	val => '' },
	BuildDate	=> { code => '',	val => '' },
	Version		=> { code => '',	val => '' },
	XhistMap	=> { code => '',	val => '' },
	CommitDate	=> { code => '%ci',	val => '' },
	CommitSubject	=> { code => '%s',	val => '' },
	Committer	=> { code => '%cn',	val => '' },
	CommitId	=> { code => '%H',	val => '' },
	AbbrevId	=> { code => '%h',	val => '' },
	Signer		=> { code => '%GS',	val => '' },
	SigStatus	=> { code => '%G?',	val => '' },
	);

#************************************************************************/
# class method new(\%opts)
# instantiates a new Xtest object with options specified.
# Returns the handle to the object or undef on error.
#************************************************************************/
sub new
{
    my ($opts) = @_;
    my $self = {};

    $self->{srcfn}	= $opts->{fname}  if defined $opts->{fname};
    $self->{srcbuf}	= $opts->{srcbuf} if defined $opts->{srcbuf};
    $self->{verbose}	= $opts->{verbose} if defined $opts->{verbose};
    $self->{binary}	= (defined $opts->{binary} ? 1 : 0);		# do binary files?
    if (defined $opts->{list}) 						# list values only?
    {
	# To handle either multiple --list options each followed by one keyword
	# or one --list option followed by a comma-separated list of keywords,
	# we merge all elements into one comma-separated list, then split the list.
	my @kws = split /,/, join(',', @{$opts->{list}}); 
	my %kw_specified;
	if (scalar(@kws) >= 1) # one or more keywords were explicitly specified
	{
	    %kw_specified = map { $_ => 1 } @kws;
	}
	else
	{
	    %kw_specified = map { $_ => 1 } keys %XMT::Xkeyword::kw;
	}
	$self->{list} = \%kw_specified;
    }

    bless $self;
    $self->_buildlist();	# populate keyword table with values
    return $self;
}
 
#************************************************************************
# stub DESTROY so the autoloader won't search for it.
#************************************************************************
sub DESTROY { }

#************************************************************************/
# instance method expand()
# smudges the source buffer by replacing canonical keywords with their expanded values.
# Returns the instrumented source buffer.
#************************************************************************/
sub expand
{
    my $self = shift;
    my $k;

    carp "no input stream" & return undef unless defined $self->{srcbuf};
    foreach $k ( keys %XMT::Xkeyword::kw )
    {
	$self->{srcbuf} =~ s/\$$k:\$/\$$k: $XMT::Xkeyword::kw{$k}{val} \$/g;
    }
    return $self->{srcbuf};
}

#************************************************************************/
# instance method unexpand()
# cleans the source buffer by replacing expanded keywords with their canonical values.
# Returns the uninstrumented source buffer.
#************************************************************************/
sub unexpand
{
    my $self = shift;
    my $k;

    carp "no input stream" & return undef unless defined $self->{srcbuf};
    foreach $k ( keys %XMT::Xkeyword::kw )
    {
	 $self->{srcbuf} =~ s/\$$k:.*?\$/\$$k:\$/g;
    }
    return $self->{srcbuf};
}

#************************************************************************/
# instance method printlist()
# prints the list of requested keyword values.
#************************************************************************/
sub printlist
{
    my $self = shift;

    foreach $k (sort keys %{$self->{list}})
    {
	printf STDOUT "%s%s\n", 
		(defined $self->{'verbose'} ? sprintf("%-18s", "\$$k:\$") : ""), 
		$XMT::Xkeyword::kw{$k}{val};
    }
}

#************************************************************************/
# private instance method _buildlist() builds the hash of keyword values.
#************************************************************************/
sub _buildlist
{
    my $self = shift;
    my %kw_specified;

    # merge all kw_list elements into one comma-separated list, 
    # then split the list, populating a hash with the specified keywords.
    if (defined $self->{kw_list})
    {
	my @kws = split /,/, join(',', @{$self->{kw_list}}); 
	if (scalar(@kws) >= 1) # one or more specified keywords
	{
	    %kw_specified = map { $_ => 1 } @kws;
	}
	else # list everything
	{
	    %kw_specified = map { $_ => 1 } keys %XMT::Xkeyword::kw;
	}
    }

    ## populate the keyword hash with values
    $XMT::Xkeyword::kw{'Branch'}{val}	= `git symbolic-ref --short -q HEAD`;
    $XMT::Xkeyword::kw{'Branch'}{val}	= 'detached' if $? != 0;
    chomp $XMT::Xkeyword::kw{'Branch'}{val};

    my ($k, $s);
    $s = `git describe --always --long`;
    die "git describe failed \n" if $? != 0;
    if ($s =~ m/(.*)-(.*?)-(.*?)/) 	
    {
	$XMT::Xkeyword::kw{'Tag'}{val}	= $1;
	$XMT::Xkeyword::kw{'BuildNum'}{val}= $2;
    }
    else
    {
	$XMT::Xkeyword::kw{'Tag'}{val}	= 'notag';
	$XMT::Xkeyword::kw{'BuildNum'}{val}= '0';
    }

    foreach $k (keys %XMT::Xkeyword::kw )
    {
	next if ( $XMT::Xkeyword::kw{$k}{code} eq ''); 
	($XMT::Xkeyword::kw{$k}{val} = 
	    `git log -n 1 --format="$XMT::Xkeyword::kw{$k}{code}"`) =~ s/\n.*//; 
    }

    ## construct Version string of the form  "<Tag>-<BuildNum> [<Branch>]"
    $XMT::Xkeyword::kw{'Version'}{val} = sprintf("%s-%d [%s]",
	    $XMT::Xkeyword::kw{'Tag'}{val}, 
	    $XMT::Xkeyword::kw{'BuildNum'}{val}, $kw{'Branch'}{val});
    ## construct BuildDate string of the form  "yyyy-mm-dd-hh-mm-ss"
    $XMT::Xkeyword::kw{'BuildDate'}{val} = strftime( "%Y-%m-%d.%H:%M", localtime );
    ## construct & store name for xhist_map file
    $XMT::Xkeyword::kw{'XhistMap'}{val} = sprintf("/tmp/%s-%s-%s.xmap",
	    $XMT::Xkeyword::kw{'Tag'}{val}	=~ s/[ :]/-/gr,
	    $XMT::Xkeyword::kw{'BuildNum'}{val}	=~ s/[ :]/-/gr,
	    $XMT::Xkeyword::kw{'Branch'}{val}	=~ s/[ :]/-/gr); 
}

1;  # ensure class eval returns true;
