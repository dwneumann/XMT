{
#************************************************************************
#   $Version:$
#   Package	: xmt_edit
#   Synopsis	:
#   Purpose	: Perl block which, when eval'ed, prints the desired
# 		file header for Java files.
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

$copyright  =~ s/\n*$//;
$copyright  =~ s/\n/\n *   /g; 
($pkgname   = $module->{pkg}) =~ s{/}{.}g;
$classname  = $module->{name};

print qq{/**
 * $copyright
 */

package $pkgname;

/**
 * The ${classname} class defines [short description].
 * <p>
 * [full description]
 * <p>
 * \@version	$cm->{rev}
 */
public	class		${classname}
	//extends	<superclass>
	//implements	<Interfaces>
	//throws	<Exceptions>
{
    public static final String id = "@(#) $module->{pkg}.${classname} $cm->{rev}";

    public	$classname() { }
    protected	void finalize() { }

    // public    class \& instance methods here ...

    // protected class \& instance methods here ...

    // private   class \& instance methods here ...

}
};

}
