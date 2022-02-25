/*-----------------------------------------------------------------------------------------------------------------------------
Author     : Rama Egappan (rr31)
Date       : 25FEB2022
Description: SAS code PoC with SYSPARM paramenters
Program    : sas_sysparam_test.sas
Parameter  : "STUDYID=$STUDYID ,REPORTID=$REPORTID ,SUBJECTIDS=$SUBJECTIDS ,OUTPUTDIR=$OUTPUTDIR ,OUTPUTFILE=$OUTPUTFILE"
Example    : sas_sysparam_test.sas -sysparm "STUDYID=xxxxxxxx,REPORTID=yyyyyyy ,SUBJECTIDS=11223344,OUTPUTDIR=/home/<username>
              ,OUTPUTFILE=xxxxxxxx_11223344(test).pdf"
-------------------------------------------------------------------------------------------------------------------------------*/
OPTIONS MPRINT MLOGIC SYMBOLGEN;
%LET studyid=;
%LET reportid=;
%LET subjectids=;
%LET outputdir=;
%LET outputfile=;

DATA _NULL_;
     par1=INDEX(sysparm(), 'STUDYID=');
  IF par1 THEN CALL SYMPUTX('studyid', SCAN(SUBSTR(sysparm(), par1), 2, '=,'));
     par2=INDEX(sysparm(), 'REPORTID=');
  IF par2 THEN CALL SYMPUTX('reportid', SCAN(SUBSTR(sysparm(), par2), 2, '=,'));
     par3=INDEX(sysparm(), 'SUBJECTIDS=');
  IF par3 THEN CALL SYMPUTX('subjectids', SCAN(SUBSTR(sysparm(), par3), 2, '=,'));
     par4=INDEX(sysparm(),'OUTPUTDIR=');
  IF par4 THEN CALL SYMPUTX('outputdir', SCAN(SUBSTR(sysparm(), par4), 2, '=,'));
     par5=INDEX(sysparm(),'OUTPUTFILE=');
  IF par5 THEN CALL SYMPUTX('outputfile',DEQUOTE(SCAN(SUBSTR(sysparm(), par5), 2, '=,')));
RUN;

%PUT ****************************************************************************************;
%PUT &=studyid &=reportid &=subjectids &=outputdir &=outputfile;
%PUT ****************************************************************************************;

		/* +++ ODS - output to network*/
		ods listing close;
		ods escapechar='^';
		ODS PATH RESET;
		ods pdf style=custom file="&outputdir./&outputfile.";
		options  leftmargin=1in rightmargin=.5in orientation=landscape ls=max ps=max nocenter nodate nonumber ;
		ods pdf startpage=no;
		title   j=l "&OUTPUTFILE." j=c "Study: &studyid. Subject: &subjectids." j=r "Page ^{thispage} of ^{lastpage}";
			
		Footnote1 j=l "This is a Footnote.";
    
    PROC PRINT DATA=SASHELP.CARS;
    RUN;
 		ods _all_ close;
		ods listing;
		/* +++ STOP - once reaches to final loop*/
/**************************** END OF sas_sysparam_test.SAS *********************************************************************/
