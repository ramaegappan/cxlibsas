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


%macro cxlib_throw( message = , code = &syscc );


    %global CXLIB_OPTIONS ;

    %local tfthrow_code 
           tfthrow_severity 
           tfthrow_message 
           tfthrow_calling
    ;


    %* ---  debug header  --- ;
    %if ( %sysfunc(indexw( DEBUG, %upcase(&CXLIB_OPTIONS), %str( ) )) ) %then %do;

        %put %str(NO)TE:  Macro cxlib_throw ;
        %put %str(NO)TE:  Version $version$ ;

    %end;


    %* ---  identify calling macro  --- ;
    %if ( %eval( %sysmexecdepth - 1 ) > 0 ) %then %do;
        %let tfthrow_calling = %sysmexecname( %eval( %sysmexecdepth - 1 ) ) ;
    %end; %else %do;
        %let tfthrow_calling = program;
    %end;


    %* ---  establish status code  --- ;
    %if ( &code ^= %str( ) ) %then %do;
        %* if we are provided a code ... use that ;

        %let tfthrow_code = &code;

    %end; %else %do;
        %* if we are not provided a code ... look at SYSCC ;

        %if ( &syscc ^= 0 ) %then %do; 
            %let tfthrow_code = &syscc;    
        %end; %else %do;
            %*  some default code if SYSCC = 0 ;
            %let tfthrow_code = 1024;
        %end;

    %end;


    %*  use SAS convention with SYSCC ... 8 or less it is a w.a.r.n.i.n.g  ;
    %if ( &tfthrow_code <= 8 ) %then %do; 
        %let tfthrow_severity = %str(Wa)rning;
    %end; %else %do;
        %let tfthrow_severity = %str(Er)ror;
    %end;


    %* ---  the status code  --- ;
    %if ( &message ^= %str( ) ) %then %do;
        %let tfthrow_message = &message;
    %end; %else %do;
        %let tfthrow_message = &tfthrow_severity occurred in macro &tfthrow_calling;
    %end;



    %* ---  update SYSCC and SYSMSG  --- ;
    %if ( &syscc = 0 ) %then %do;
        %let syscc = &tfthrow_code ;
        %let sysmsg = &tfthrow_message ;
    %end;


    %* ---  main log entry ;
    %put %upcase(&tfthrow_severity): &tfthrow_message (CODE=&tfthrow_code);

    %* ---  add information about the calling macro  --- ;
    %if ( &message ^= %str( ) ) %then %do;
        %* -- avoid duplicating information in the log ;
        %put %upcase(&tfthrow_severity): Thrown by macro &tfthrow_calling ;
    %end;


%mend;
