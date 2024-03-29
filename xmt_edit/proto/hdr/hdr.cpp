{
#************************************************************************
#   Package	: xmt_edit
#   Purpose	: Perl block which, when eval'ed, prints the desired
# 		file header for C++ files.
#
#   Copyright (c) 1998	Neumann & Associates Information Systems Inc.
#   			legal.info@neumann-associates.com
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#   
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License. 
#************************************************************************

$copyright =~ s/\n*$//;
$copyright =~ s/\n/\n*   /g; 
($hfile = $filename) =~ s/\.[^\.]*$/.hpp/;
print 
qq{/************************************************************************
*   \@file       ${filename}
*   \@brief      <synopsis>
*
*   $copyright
* ***********************************************************************/

#define __${filename_}
#define __${filename_}_VERSION   "$cm->{rev}";

// includes ...
#include "$hfile"

$module->{name}::$module->{name}()	// constructor(s)
{
}

$module->{name}::~$module->{name}()	// destructor
{
}

};

}
