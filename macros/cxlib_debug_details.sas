/* -----------------------------------------------------------------------
Macro   :    cxlib_debug_details
Version :    $version$
Author  :    Magnus Mengelbier, Limelogic AB
Project :    https://github.com/limelogic/cxlibsas
-----------------------------------------------------------------------
Description

Convenience macro to provide a simple debug details view

-----------------------------------------------------------------------
Parameters

subject
    Simple subject line to provide some form of context

select
    Space delimited list of macro variables to include. Empty includes
    all local variables 

print
    Force printing debug details in the log

-----------------------------------------------------------------------
License

GNU Public License v3
----------------------------------------------------------------------- */


%macro cxlib_debug_details( subject = , select = , print = N );

    %global CXLIB_OPTIONS ;

    %local cxdebug_caller
           cxdebug_linelength;

    %* ---  determine message level  --- ;
    %if ( %sysmexecdepth = 1 ) or 
          ( ( %upcase(&print) = N ) and ( %sysfunc(indexw( %upcase(&CXLIB_OPTIONS), DEBUG, %str( ) )) = 0 ) )  %then %do;
        %*  nothing to do ... ;
        %goto macro_exit;
    %end;


    %* ---  determine name of calling macro (our scope)  --- ;
    %let cxdebug_caller = %sysmexecname( %eval( %sysmexecdepth - 1 ) ) ;


    %* --- get the log line length  --- ;
    %let cxdebug_linelength = %sysfunc(getoption(linesize));

    data _null_ ;
        set sashelp.vmacro  end = eof;
        where ( upcase(strip(scope)) = strip(upcase(symget('cxdebug_caller'))) 
    %if ( &select ^= %str() ) %then %do;
                and
                ( indexw( strip(compbl(upcase(symget('select')))), upcase(strip(name)), " " ) > 0 )
    %end;
        );

        length str_raw $ 1024 str $ &cxdebug_linelength ;

        max_length = input( symget('cxdebug_linelength'), 8. ) ;

        if ( _n_ = 1 ) then do ;
            str = substr( catx( "  ", "(DEBUG) ---", "Debug details", repeat( "-", 200) ), 1, max_length);
            put " " /
                str /
    %if ( &subject ^= %str( ) ) %then %do;
                "(DEBUG)  &subject" /
    %end;
                "(DEBUG)" ;

            call missing(str) ;
        end;

        if not missing(value) then 
            str_raw = "(DEBUG)  " || catx( " = ", upcase(name), value );
        else 
            str_raw = "(DEBUG)  " || catx( " = ", upcase(name), "[no value]" );

        if ( length(strip(str_raw)) <= max_length ) then 
            str = substr( strip(str_raw), 1, min( length(strip(str_raw)), max_length ) );
        else
            str = catx( " ", substr( strip(str_raw), 1, min( length(strip(str_raw)), max_length - 6 ) ), "[...]" );

        put str;

        if ( eof ) then do ;
            str = substr( catx( "  ", "(DEBUG) ---", "End of debug details", repeat( "-", 200) ), 1, max_length);

            put "(DEBUG)" /
                str /
                " " / ".";

            call missing(str) ;
        end;

    run;



    %* ---  macro exit point  --- ;
    %macro_exit:

%mend;
