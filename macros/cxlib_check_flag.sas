/* -----------------------------------------------------------------------
Macro   :    cxlib_check_flag
Version :    $version$
Author  :    Magnus Mengelbier, Limelogic AB
Project :    https://github.com/limelogic/cxlibsas
-----------------------------------------------------------------------
Description

Utility macro to check a value as a boolean. For this implementation, a
boolean is either Y (Yes) or N (No) as well as T (True) or F (False)

-----------------------------------------------------------------------
Parameters

name
    Name as part of messages when silent disabled
 
value 
    Value to verify

return
    Macro variable to return full absolute path

silent
    Disable messaging

-----------------------------------------------------------------------
Returns

Returns a value of 1 if the value is valid. 0 otherwise.

-----------------------------------------------------------------------
License
GNU Public License v3
----------------------------------------------------------------------- */


%macro cxlib_check_flag( name = , value = , allowempty = n, return = , silent = n );

    %global CXLIB_OPTIONS ;

    %local 
        cxchk_flag 
        cxchk_flag_caller 
    ;


    %* ---  debug header  --- ;
    %if ( %sysfunc(indexw( %upcase(&CXLIB_OPTIONS), DEBUG, %str( ) )) > 0 ) %then %do;

        %put %str(NO)TE:  Macro cxlib_check_boolean ;
        %put %str(NO)TE:  Version $version$ ;

    %end;


    %* ---  initialize as not evaluated  --- ;
    %let cxchk_flag = -1 ;


    %* ---  dwetermine calling macro  --- ;
    %let cxchk_flag_caller = ;

    %if ( %sysmexecdepth > 1 ) %then %do;
        %let cxchk_flag_caller = in macro %str()%sysmexecname( %eval( %sysmexecdepth - 1 ) ;
    %end;



    %* ----------------------------- ;
    %* simple param checks  ;
    %* ----------------------------- ;


    %* ---  parameter RETURN  --- ;
    %if ( %superq(return) = %str() ) %then %do;
        %cxlib_throw( code = 12001, message = The parameter RETURN is not specified );
        %goto macro_exit;
    %end;

    %if ( %sysfunc(countw( &return, %str( ))) ^= 1 ) %then %do;
        %cxlib_throw( code = 12001, message = The value of parameter RETURN is not valid );
        %goto macro_exit;
    %end;

    %if ( %symexist( &return ) = 0 ) %then %do;
        %cxlib_throw( code = 12001, message = The macro variable specified with the parameter RETURN is not defined );
        %goto macro_exit;
    %end;
    %* ---  end of parameter RETURN  --- ;


    %* ---  parameter SILENT  --- ;
    %if ( %superq(silent) = %str() ) %then %do;
        %cxlib_throw( code = 12001, message = The parameter SILENT is not specified );
        %goto macro_exit;
    %end;

    %if ( %sysfunc(countw(&silent, %str( ))) ^= 1 ) or
        ( %sysfunc(indexw( Y N, %upcase(&silent), %str( ) )) = 0 ) %then %do;
        %cxlib_throw( code = 12001, message = The value of parameter SILENT is not valid );
        %goto macro_exit;
    %end;
    %* ---  end of parameter SILENT  --- ;



    %* ---  parameter ALLOWEMPTY  --- ;
    %if ( %superq(allowempty) = %str() ) %then %do;
        %cxlib_throw( code = 12001, message = The parameter ALLOWEMPTY is not specified );
        %goto macro_exit;
    %end;

    %if ( %sysfunc(countw(&allowempty, %str( ))) ^= 1 ) or
        ( %sysfunc(indexw( Y N, %upcase(&allowempty), %str( ) )) = 0 ) %then %do;
        %cxlib_throw( code = 12001, message = The value of parameter ALLOWEMPTY is not valid );
        %goto macro_exit;
    %end;
    %* ---  end of parameter ALLOWEMPTY  --- ;




    %* ---  parameter NAME  --- ;
    %if ( %upcase(&silent) = N ) or 
        ( %sysfunc(indexw( %upcase(&CXLIB_OPTIONS), DEBUG, %str( ) )) > 0 ) %then %do;
        %*  parameter NAME only used if not silent mode ;

        %if ( %superq(name) = %str() ) %then %do;
            %cxlib_throw( code = 12001, message = The parameter NAME is not specified and SILENT mode is disabled or DEBUG is enabled);
            %goto macro_exit;
        %end;

        %if ( %sysfunc(countw(&name, %str( ))) ^= 1 ) %then %do;
            %cxlib_throw( code = 12001, message = The value of parameter NAME is not valid and SILENT mode is disabled or DEBUG is enabled);
            %goto macro_exit;
        %end;

    %end;
    %* ---  end of parameter NAME  --- ;




    %* ----------------------------- ;
    %* check  ;
    %* ----------------------------- ;

    %* ---  default return  --- ;
    %let cxchk_flag = 1 ;

    %* ---  check for empty  --- ;
    %if ( %upcase(&allowempty) = N ) and
        ( %superq(value) = %str() ) %then %do;

        %let cxchk_flag = 0 ;

        %if ( %upcase(&silent) = N ) or 
            ( %sysfunc(indexw( %upcase(&CXLIB_OPTIONS), DEBUG, %str( ) )) > 0 ) %then %do;
            %cxlib_throw( code = 12001, message = The parameter %upcase(&name) is not specified &cxchk_flag_caller );
        %end;

        %goto macro_exit;
    %end;

    %if ( %upcase(&allowempty) = Y ) and
        ( %superq(value) = %str() ) %then %do;

        %let cxchk_flag = 1 ;
        %goto macro_exit;
    %end;
    %* ---  end of check for empty  --- ;


    %* ---  check for multiple values  --- ;
    %if ( %sysfunc(countw(&value, %str( ))) ^= 1 ) %then %do;

        %let cxchk_flag = 0 ;

        %if ( %upcase(&silent) = N ) or 
            ( %sysfunc(indexw( %upcase(&CXLIB_OPTIONS), DEBUG, %str( ) )) > 0 ) %then %do;
            %cxlib_throw( code = 12001, message = The value of parameter %upcase(&name) can only contain a single valid value  &cxchk_flag_caller);
        %end;

        %goto macro_exit;
    %end;
    %* ---  end of check for multiple values  --- ;


    %* ---  check for Y/N flag value --- ;
    %if ( %sysfunc(indexw( Y N, %upcase(&value), %str( ) )) = 0 ) %then %do;

        %let cxchk_flag = 0 ;

        %if ( %upcase(&silent) = N ) or 
            ( %sysfunc(indexw( %upcase(&CXLIB_OPTIONS), DEBUG, %str( ) )) > 0 ) %then %do;
            %cxlib_throw( code = 12001, message = The value of parameter %upcase(&name) is not valid &cxchk_flag_caller );
        %end;

        %goto macro_exit;
    %end;
    %* ---  end of check for empty  --- ;



    %* ---  macro exit point  --- ;
    %macro_exit:


    %* ---  return value assigned  --- ;
    %if ( &cxchk_flag > -1 ) %then %do;
        %let &return = &cxchk_flag ; 
    %end; 


%mend;
