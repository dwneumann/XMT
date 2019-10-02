#!/usr/bin/env perl 
#************************************************************************
# usage: backup.pl --level=n --src=path --dest=path
# backup the specified directory tree to a zipped tar file in the specified directory 
# & log output to /var/logs/backup.log
# eg:   backup.pl  --level=0 --src=/cygdrive/c/CentralRepos --dest=/cygdrive/d/Backups
# Note: compressing on the fly, expect performance over 1Gbps network ~ 15GB/hr 
#
#    Copyright 2018 Visionary Research Inc.   All rights reserved.
#    			legal@visionary-research.com
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
# explicitly set timezone otherwise Winodws task scheduler uses UTC
$ENV{'TZ'}	= "America/Vancouver";
tzset();

##   there's nothing configurable below this line. Leave it alone.
die "$usage" if defined $opt_u || !defined $src;
my $level	= defined $level ? $level : 0;
my $dest	= defined $dest ? $dest : "/d/Backups";
my ($basename, $path, $sfx)	= fileparse($src);
my $label	=strftime("%F", localtime) . ".$basename";
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
my $tarargs="--create --file=$archive --blocking-factor=512 --gzip --checkpoint=40000 --checkpoint-action=exec=/bin/date --totals ";

# use a find command to generate the manifest of files to be backed up 
# because it is WAY faster than using --incremental
# with the bonus of producing an easily grep'd manifest of what's in the backup.
if ( $level eq 0 )
{
	system("find $src -type f -print > $manifest");
	$tarargs="$tarargs $src";
}
else
{
	system("find $src -type f -newer $last_level0 -print > $manifest");
	$tarargs="$tarargs --files-from $manifest ";
}

my $timenow = strftime("%X", localtime);
print $LOG " \n";
print $LOG "level $level tar of $archive started at $timenow \n";
print $LOG "/bin/tar $tarargs \n";

system("/bin/tar $tarargs >>$logfile 2>&1");

my $timenow = strftime("%X", localtime);
print $LOG "level $level tar of $archive   ended at $timenow \n";


