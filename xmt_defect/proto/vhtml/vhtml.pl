

sub defect_error
{
#************************************************************************
#*  $Version:$
#*  Package	: defect
#*  Synopsis	:
#*  Purpose	: Perl block which, when eval'ed, 
#*		  serves the virtual path 'defect_error'.
#*
#*  Copyright (c) Neumann & Associates 1998
#************************************************************************

my $qr = \$Defect::q;
my $err  = defined $$qr->param('defect_err') ? $$qr->param('defect_err') : 'unknown';
my $event_verb = ucfirst $Defect::event;
$event_verb =~ s/_.*//;
my %msgs = (
    "session expired"	=> {
	reason  => "your session key has expired.
		    This is most likely because too much time has
		    elapsed since you logged in, or because you tried
		    to bookmark (hotlist) a page which is access-controlled.",
	fix     => "returning to the 
		    <A HREF=\"defect_home.html\">Defect Database 
		    home page</A>, and logging in again."
			   },
    "no query"  	=> {
	reason  => "a <I>query</I> was not supplied.",
	fix     => "clicking your browser's <B>Back</B> button to 
		    return to the previous page, then loading, constructing,
		    or typing a <I>Query</I>, and selecting the
		    <I>$event_verb</I> operation again."
			   },
    "no query template"  	=> {
	reason  => "a <I>Query Template</I> was not selected.",
	fix     => "clicking your browser's <B>Back</B> button to 
		    return to the previous page, clicking on one of the
		    templates listed in the <I>Query Templates</I>
		    list, and selecting the <I>$event_verb</I>
		    operation again."
			   },
    "not a query"  	=> {
	reason  => "your <I>query</I> is not permitted.",
	fix     => "clicking your browser's <B>Back</B> button to 
		    return to the previous page, then loading,
		    constructing, or typing a <I>select</I> statement,
		    and then selecting the <I>$event_verb</I> operation
		    again."
			   },
    "unknown"	=> {
	reason  => "of an unspecified error.",
	fix     => "clicking your browser's <B>Back</B> button to 
		    return to the previous page, verifying that you
		    have correctly specified all required information,
		    and selecting the <I>$event_verb</I> operation again."
			   },
	   );

print
    $$qr->start_html( -title=>"DDB Error",
		    -target=>'defect_mainframe' ), "\n" ,
    $$qr->h3( "Error" ), "\n",

    "Your requested operation failed because ";

print $msgs{$err}{reason};

print " <P>
    If you wish to re-attempt the operation, you may do so by ";

print $msgs{$err}{fix};

print " <HR>",
    $$qr->end_html;
}



sub defect_login
{
#************************************************************************
#*  $Version:$
#*  Package	: defect
#*  Synopsis	:
#*  Purpose	: Perl block which, when eval'ed, 
#*		  serves the virtual path 'defect_login'
#*
#*  Copyright (c) Neumann & Associates 1998
#************************************************************************

my $qr = \$Defect::q;

print
    $$qr->start_html( -title=>"XMT Defect Database Login",
		    -target=>'defect_mainframe' ), 
    "<H1>DDB Login</H1>
    <P>",
    $$qr->start_form(-action=>'./defectsrv.pl' ), 
    "<TABLE>
    <TR>
	<TD>username:
	<TD>", $$qr->textfield( -name=>'uname',
		-size=>16, -maxsize=>1024, -override=>1 ),
    "<TR>
	<TD>password:
	<TD>", $$qr->password_field( -name=>'passwd',
		-size=>16, -maxsize=>1024, -override=>1 ),
    "<TR>
	<TD> </TD>
	<TD> ",
	$$qr->hidden( 'ev', 'submit_login'),
	"\n",
	$$qr->submit( '-name'=>'submit', 
		    '-value'=>'      Login      ' ), 
    "</TABLE>
    <P>",
    $$qr->end_form;
    $$qr->end_html;
print "\n";
}



sub defect_login_failed
{
#************************************************************************
#*  $Version:$
#*  Package	: defect
#*  Synopsis	:
#*  Purpose	: Perl block which, when eval'ed, 
#*		  serves the virtual path 'defect_login_failed'
#*
#*  Copyright (c) Neumann & Associates 1998
#************************************************************************

my $qr = \$Defect::q;

print
    $$qr->start_html( -title=>"DDB Login Failed",
		    -target=>'defect_mainframe' ), "\n" ,
    $$qr->h3( "Login Failed" ), "\n",

    "<FONT SIZE=2>
    Your attempt to login to the <I>Defect Database</I> failed.  If you
    are authorized to access the DDB, remember that your DDB login name
    and password are not necessarily the same as your computer login name
    and password.  You may re-attempt your login by selecting the
    <I>Login</I> link at left.
    <P>
    If you have not received authorization for DDB access, you may
    submit a request for access by selecting the <I>Register</I> link
    at left.
    <HR>
    </FONT>\n";
    $$qr->end_html;
}



sub defect_search
{
#************************************************************************
#*  $Version:$
#*  Package	: defect
#*  Synopsis	:
#*  Purpose	: Perl block which, when eval'ed, 
#*		  serves the virtual path 'defect_search'
#*
#*  Copyright (c) Neumann & Associates 1998
#************************************************************************

my $qr = \$Defect::q;
my (@queries, @reports, $query, $qtmpl, $qrpt);

push( @queries, map {s{.*/}{};$_} grep {-f $_} glob("../proto/queries/*"));
push( @queries, '&nbsp'x50 ); # add blank element of known width

push( @reports, map {s{.*/}{};$_} grep {-f $_} glob("../proto/reports/*"));
push( @reports, '&nbsp'x50 ); # add blank element of known width

$query	= ( defined $$qr->param('query') ? $$qr->param('query') : '' );
$qtmpl	= ( defined $$qr->param('query_tmpl') ? $$qr->param('query_tmpl') : '' );
$qrpt	= ( defined $$qr->param('report_fmt') ? $$qr->param('report_fmt') : '' );

#************************************************************************
# field_labels keys of the form 
# 't1.f1'  generate query constraints of the form 
#	...where t1.f1 <op> <value>
#
# field_labels keys of the form 
# 't1.f1=t2.f2->t3.f3' generate query constraints of the form
#	...where t1.f1 IN (select f2 from t2 where t3.f3 <op> <value>)
#
# field_labels keys of the form 
# 't1.f1!=t2.f2->t3.f3' generate query constraints of the form
#	...where t1.f1 NOT IN (select f2 from t2 where t3.f3 <op> <value>)
#************************************************************************
my %field_labels = # will appear sorted by value
(
    'Defects.def_product=Products.oid->Products.prd_name'
		=> 'product name',
    'Defects.def_product=Products.oid->Products.prd_rev'
		=> 'product revision',
    'Defects.def_product=Products.oid->Products.prd_config'
		=> 'product configuration',
    'Defects.def_product=Products.oid->Products.prd_os'
		=> 'product OS',
    'Defects.def_product=Products.oid->Products.prd_arch'
		=> 'product hardware architecture',
    'Defects.oid'
		=> 'defect ID',
    'Defects.def_severity'
		=> 'defect severity',
    'Defects.def_synopsis'
		=> 'defect synopsis',
    'Defects.def_fc=FaultClassifications.oid->FaultClassifications.fc_phase'
		=> 'defect classification phase',
    'Defects.def_fc=FaultClassifications.oid->FaultClassifications.fc_type'
		=> 'defect classification type',
    'Defects.def_fc=FaultClassifications.oid->FaultClassifications.fc_reason'
		=> 'defect classification reason',
    'StateTransitions.st_from'
		=>'state left',
    'StateTransitions.st_to'
		=> 'state entered',
    'StateTransitions.st_time'
		=> 'transition request date/time',
    'StateTransitions.st_to'
		=>'transition initiator name',
    'StateTransitions.st_remarks'
		=> 'transition remarks',
    'CM_Entities.cm_filename'
		=> 'CM Entity filename',
    'CM_Entities.cm_revision'
		=> 'CM Entity revision',
    'CM_Entities.cm_defect'
		=> 'CM Entity\'s associated defect',
);

my %operator_labels = # will appear sorted alphabetically by key
(
    'lt'	=> 'is less than',
    'lte'	=> 'is less than or equal to',
    'eq'	=> 'is equal to',
    'eq.n'	=> 'is not equal to',
    'gt'	=> 'is greater than',
    'gte'	=> 'is greater than or equal to',
    'in'	=> 'is in the set',
    'in.n'	=> 'is not in the set',
    'rx'	=> 'matches pattern',
    'rx.n'	=> 'does not match pattern',
);

my %event_labels =  # will appear sorted by value
(
    'load_query'	=> 'Load query template',
    'add_and_clause' 	=> 'Add additional constraint (AND)',
    'add_or_clause' 	=> 'Add alternate constraint (OR)',
    'search'		=> 'Execute query',
);

print
    $$qr->start_html( -title=>"DDB Search",
		    -target=>'defect_mainframe' ), 
    $$qr->start_form(-action=>'./defectsrv.pl' ), 
    "<TABLE>
    <TR>
	<TD ALIGN=CENTER VALIGN=BOTTOM> <B>Query Templates</B>
	<TD>", '&nbsp;'x3,
	"<TD ALIGN=CENTER VALIGN=BOTTOM> <B>Constructing Queries</B>
    <TR>
	<TD ALIGN=CENTER ROWSPAN=3>", 
	    $$qr->scrolling_list( -name=>'query_tmpl', 
		-default=>[$qtmpl], '-values'=>[@queries], 
		-size=>7, -override=>1 ), 
       "<TD ALIGN=CENTER COLSPAN=2>", $$qr->popup_menu( -name=>'field_name',
	    '-values'=>[ sort {$field_labels{$a} cmp $field_labels{$b}} 
			keys %field_labels ],
	    -default=>'Defects.oid', 
	    -labels=>\%field_labels),
    "<TR>
	<TD ALIGN=CENTER COLSPAN=2>", $$qr->popup_menu( -name=>'field_opr',
	    '-values'=>[ sort keys %operator_labels ],
	    -default=>'eq', -labels=>\%operator_labels),
    "<TR>
	<TD ALIGN=CENTER COLSPAN=2>", $$qr->textfield( -name=>'field_value',
			    -size=>27, -maxsize=>1024, -override=>1 ),
    "<TR>
	<TD VALIGN=TOP><FONT SIZE=2> <I>Select a predefined query
	    template to load, <B>or</B></I></FONT>
	<TD> <!-- horizontal spacer>
	<TD VALIGN=TOP><FONT SIZE=2> <I>Construct a query by repeatedly
	    adding search constraints.  For each constraint, select the
	    field to search on, select an operator, and enter a value to
	    compare against.  Constants, expressions and nested sub-queries
	    are permitted.  (Surround text values with 'quotes').</I></FONT>
    <TR><TD>&nbsp;<!--vertical spacer>
    <TR>
	<TD ALIGN=CENTER COLSPAN=3>", $$qr->textarea( -name=>'query',
		-default=>"$query", -columns=>52, -rows=>4, -override=>1 ),
    "<TR>
	<TD COLSPAN=3><FONT SIZE=2>
	    <I>Queries, whether loaded from templates, constructed through
	    the addition of constraints, or typed in SQL directly, may be
	    edited as desired before executing the query.</I></FONT>
    <TR><TD>&nbsp;<!--vertical spacer>
    <TR>
	<TD ALIGN=CENTER VALIGN=BOTTOM> <B>Report Formats</B>
	<TD ALIGN=CENTER VALIGN=BOTTOM COLSPAN=2> 
		<B>Select & Submit Operation</B>
    <TR>
	<TD ALIGN=CENTER ROWSPAN=2>", $$qr->scrolling_list( 
		-name=>'report_fmt', '-values'=>[@reports], -size=>4,
		-default=>[$qrpt], -override=>1 ), 
	"<TD ALIGN=CENTER COLSPAN=2>", $$qr->popup_menu( -name=>'ev',
	    '-values'=>[ sort {$event_labels{$a} cmp $event_labels{$b}}
			 keys %event_labels ],
	    -default=>'search', -labels=>\%event_labels),
    "<TR>
	<TD ALIGN=CENTER COLSPAN=2>", 
	    $$qr->submit( '-name'=>'submit', 
			'-value'=>'      Submit      ' ), 
    "<TR>
	<TD><FONT SIZE=2><I>Select a report format.  All records
	    returned by the specified query will be formatted using the
	    selected report format.</I></FONT>
	<TD> <!-- horizontal spacer>
	<TD ALIGN=CENTER><FONT SIZE=2> <I>Select the operation to perform, and
	    submit it.</I></FONT>
    </TABLE>
    <P> ",
    $$qr->end_form,
    "</FONT>\n",
    $$qr->end_html;

print "\n";
}


return 1;
