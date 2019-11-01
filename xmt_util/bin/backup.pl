#!/usr/bin/env perl 
#************************************************************************
#   Package	: xmt_util
# usage: backup.pl --level=n --src=path --dest=path
# backup the specified directory tree to a zipped tar file in the specified directory 
# & log output to /var/logs/backup.log
# eg:   backup.pl  --level=0 --src=/home --dest=/HDD/Backups
# Note: compressing on the fly, expect performance over 1Gbps network ~ 15GB/hr 
#
#    Copyright 2018 Visionary Research Inc.   All rights reserved.
#    			legal@visionary-research.com
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

use strict;
use Getopt::Long;
use File::Basename;
use POSIX qw(strftime tzset);
use Env;

(my $pgmname = $0) =~ s{.*/}{};
my $usage		= "usage: $pgmname [-u] --level=n --src=path --dest=path \n";

our ($opt_u,  $src,  $dest,  $level);
GetOptions( "u" => \$opt_u, "src=s" => \$src, "dest=s" => \$dest, "level=s" => \$level ) 
	or die $usage;
my $logfile = "/var/log/backup.log";
open(my $LOG, ">>", $logfile) or die "$logfile: $!";
$ENV{'TZ'}	= "America/Vancouver";
tzset();
my $HDD = "/mnt/HDD";

##   there's nothing configurable below this line. Leave it alone.
die "$usage" if defined $opt_u || !defined $src;
my $level	= defined $level ? $level : 0;
my $dest	= defined $dest ? $dest : "$HDD/Backups";
my ($basename, $path, $sfx)	= fileparse($src);
my $hostname =`hostname`; chomp($hostname);
my $label	=strftime("%F", localtime) . ".$hostname.$basename";
my $last_level0 =`ls -t $dest/*$basename.0.tgz | sed '1q'`; chomp($last_level0);
if ( "$last_level0" eq "" )
{
    warn "no previous level 0 archive found.";
    $level=0; 
}

my $manifest="$dest/$label.$level.manifest";
my $archive="$dest/$label.$level.tgz";
# output a checkpoint statement to the log every 10GB
# 512 bytes/block * 512 blocks/record * 40000 records/checkpoint = 10GB checkpoints
my $tarargs=" --create --file=$archive --directory=$src ";
$tarargs .= " --gzip --seek --totals --one-file-system ";
$tarargs .= " --blocking-factor=512 --checkpoint=40000 --checkpoint-action='echo=checkpoint: %u x 10GB: %{%Y-%m-%d %H:%M:%S}t' ";
$tarargs .= " --exclude-backups --exclude-caches-all --exclude-from=$HDD/backup.excludes ";
if ( $level ne 0 )
{
	$tarargs="$tarargs --newer=$last_level0 ";
}

my $timenow = strftime("%X", localtime);
print $LOG " \n";
print $LOG "level $level tar of $archive started at $timenow \n";
print $LOG "/bin/tar $tarargs \n";

system("/bin/tar $tarargs . >>$logfile 2>&1");

my $timenow = strftime("%X", localtime);
print $LOG "level $level tar of $archive   ended at $timenow \n";

# now verify the backup by reading it & creating a manifest of what's in it.
# if there's a read error a message will appear at the tail of the manifest file.
# Pipe output through sed to delete directory entries, thus listing only actual files.
print $LOG "creating $manifest \n";
system("/bin/tar tvf $archive | sed '/^d/d' >$manifest 2>&1");
my $timenow = strftime("%X", localtime);
print $LOG "manifest completed at $timenow \n";

