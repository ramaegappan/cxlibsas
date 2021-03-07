/* -----------------------------------------------------------------------
Macro   :    cxlib_throw
Version :    $version$
Author  :    Magnus Mengelbier, Limelogic AB
Project :    https://github.com/limelogic/cxlibsas
-----------------------------------------------------------------------
Description

Utility macro within error management to "throw" or trigger an error.

The current implementation relies on SAS standard error management
using SYSCC and SYSMSG 

SYSCC and SYSMSG will only be updated if no prior warning or error
condition exists as not to step on a previous error.

-----------------------------------------------------------------------
Parameters

code
    Numeric error code that is greater than 8 

message 
    Message string to describe the error

-----------------------------------------------------------------------
License

GNU Public License v3
----------------------------------------------------------------------- */


%macro cxlib_throw( code = , message = );


    %global CXLIB_OPTIONS ;

    %local tfinit_work_path ;


    %* ---  debug header  --- ;
    %if ( %sysfunc(indexw( DEBUG, %upcase(&CXLIB_OPTIONS), %str( ) )) ) %then %do;

        %put %str(NO)TE:  Macro cxlib_throw ;
        %put %str(NO)TE:  Version $version$ ;

    %end;

    %* ---  update SYSCC and SYSMSG  --- ;
    %if ( &syscc = 0 ) %then %do;
        %let syscc = &code ;
        %let sysmsg = &message ;
    %end;


    %* ---  add error to the log  --- ;
    %put %str(ER)ROR: &message (CODE=&code);

%mend;
