{
#************************************************************************
#   $Version:$
#   Package	: xmt_edit
#   Synopsis	:
#   Purpose	: Perl block which, when eval'ed, prints the desired
# 		file header for C & C++ public interface files.
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
$copyright =~ s/\n/\n*  /g; 
print 
qq{/************************************************************************
*   Package	: $module->{pkg}
*   $cm->{rev}
*   $copyright
*
*   Purpose	: Public interface to the $module->{pkg}::$module->{name} module.
*************************************************************************/

#ifndef __${filename_}
#define __${filename_}

#ifdef EMBED_REVISION_STRINGS
static const char ${filename_}_id[] = "@(#) $module->{pkg}::${filename}\t$cm->{rev}";
#endif


#endif /* __${filename_}	*/
};

}
