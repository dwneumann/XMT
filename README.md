# XMT : the Extensible Management Toolkit

## About the Project

The Extensible Management Toolkit (XMT) is a collection of independent packages
(mostly written in Perl and intended for use in a bash or csh commandline environment)
to automate or enhance software development and project management functions.
It has been in use and has evolved since the mid-1990's.

The following packages are included in the collection:
- xmt_build :
   utilities and vim mappings to automate cross-language, cross-platform software building.     
   C, C++, and Java languages are supported.     
   linux_x86, Sparc, Linux-x86, AX8052, and STM32 platforms are supported.

- xmt_cm :
   utilities to automate configuration management functions.     
   sccs, rcs, cvs, subversion, git and mercurialt are supported.

- xmt_defect :
   a database and utilities to automate defect tracking.

- xmt_doc :
   utilities to automate document generation from sources.

- xmt_edit :
   utilities and vim mappings to automate editing of source code in vim.     
   Many file types are supported.

- xmt_metrics :
   a database and utilities to automate collection of metrics from project actuals in a professionl services org.

- xmt_timesht :
   a database and utilities to automate timesheet generation against WBS codes in a professional services org.

- xmt_util :
   utilities and aliases to automate various interactive shell functions.

- xmt_xhist :
   a debugging tool for collecting execution history in embedded environments lacking semihosting capability.

- xmt_xtest :
   a Perl implementation of an expect-based test harness for whitebox testing.

## License

The XMT collection is offered under the terms of the Apache License version 2.0.
See the file [LICENSE](LICENSE) for details.

## Getting Started

Download the XMT collection onto a local file system and set a $XMT environment
variable in your .bashrc or .cshrc file to point to it.     

Then add the following line to your .bashrc: source $XMT/.bashrc     
Or add the following line to your .cshrc:    source $XMT/.cshrc     

Those files each source subordinate cshrc or bashrc files from each package
in the collection.  Comment out those you don't want, source the ones you
do.  Customize as desired.

## Streams & Branches
This repository adopts the following convention:     

- The develop branch is where active development occurs.  If you are a collaborator,
this is the branch you would clone and issue a pull request into.  

- The experimental branch is a release stream. Any release generated in this branch 
will be tagged as "rcX.Y.Z" (rc for "release candidate") and is deployable into 
a test environment. 

- The master branch is the stable mainline of deployable code.  
  No work gets done in the mainline and no releases get made from the mainline.  

- The stable branch is a release stream.  Any release generated in this branch 
will be tagged "vX.Y.Z" is deployable into a production environment. 
 
Client side keyword expansion (smudging) is done in the stable and experimental release
streams using xmt_cm/bin/git_filter.      
i.e. .git/config contains the lines:     
[filter "kw_expand"]       
   process = git_filter  --process --expand='stable|experimental'  


---------
Copyright &copy; 1997-1999 Neumann & Associates Inc.      
Copyright &copy; 2007-2018 Visionary Research Inc.        


