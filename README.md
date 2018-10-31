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
   generic, Sparc, Linux-x86, AX8052, and STM32 platforms are supported.

- xmt_cm :
   utilities to automate configuration management functions.   
   sccs, rcs, cvs, subversion and git are supported.

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

## License

The XMT collection is offered under the terms of the Apache License version 2.0.
See the file [LICENSE](LICENSE) for details.

## Getting Started

Download the XMT collection onto a local file system and set a $XMT environment variable in your .bashrc or .cshrc file to point to it.  
Then add the following line to your .bashrc: source $XMT/.bashrc  
Or add the following line to your .cshrc:    source $XMT/.cshrc  

Those files each source subordinate cshrc or bashrc files from each package in the collection.
Comment out those you don't want, source the ones you do.  
Customize as desired.

---------
Copyright &copy; 1997-1999 Neumann & Associates Inc.   
Copyright &copy; 2007-2018 Visionary Research Inc.   


