/* -----------------------------------------------------------------------
Macro   :    cxlib_attribute
Version :    $version$
Author  :    Magnus Mengelbier, Limelogic AB
Project :    https://github.com/limelogic/cxlibsas
-----------------------------------------------------------------------
Description

Utility macro to get the value for a cxLib attribute

-----------------------------------------------------------------------
Parameters

name
    Attribute name/reference

return
    Macro variable to assign return value to


-----------------------------------------------------------------------
License

GNU Public License v3
----------------------------------------------------------------------- */


%macro cxlib_attribute( name = , return = );

    %global CXLIB_OPTIONS ;


    %local cxattr_return_scope 
           cxattr_chkvar 
    ;

    %* ---  debug header  --- ;
    %if ( %sysmexecdepth = 1 ) or ( %sysfunc(indexw( %upcase(&CXLIB_OPTIONS), DEBUG, %str( ) )) > 0 ) %then %do;

        %put %str(NO)TE:  Macro cxlib_attribute ;
        %put %str(NO)TE:  Version $version$ ;

        %cxlib_debug_details( subject = Macro parameters, select = name return, print = N );
    %end;


    %* ---  validate return variable exists  --- ;

    %let cxattr_return_scope = ;

    %if ( %sysmexecdepth > 1 ) %then %do;
        %* ---  called from a macro  --- ;

        %let cxattr_return_scope = %sysmexecname( %eval( %sysmexecdepth - 1 ) ) ;

        proc sql noprint;
            select distinct name into :cxattr_chkvar separated by " " 
                from dictionary.macros
                where strip(scope) = strip("&cxattr_return_scope") and
                      upcase(strip(name)) = upcase(strip("&return"))
            ;
        quit;

        %if ( &sqlobs ^= 1 ) %then %do;

            %cxlib_throw( message = The specified return variable does not exist, code = 10021 );
            %goto macro_exit ;

        %end;

    %end;

    %* ---  end of validate return variable exists  --- ;


    %* ---  assign return variable  --- ;

    data _null_ ;
        set _cxlib_.attr end = eof ;

        length return_value $ 2048 ;

        *  initialize as an empty string value ;
        if ( _n_ = 1 ) then 
            call missing( return_value );

        *  only use the first value found ;
        if not missing( return_value ) then 
            return;

        *  on match ... pick up the value ;
        if ( strip(lowcase(name)) = strip(lowcase(symget( 'name' ))) ) then 
            return_value = strip(value);

        *  assign the value ... we do this at the end to capture empty string as a return ;
        if eof then do;
            
            if missing(symget('cxattr_return_scope')) then 
                call symputx( symget('return'), return_value, 'G' );
            else
                call symputx( symget('return'), return_value, 'F' );

        end;

    run;

    %if ( &syscc ^= 0 ) %then %do;

        %cxlib_throw( message = Failed to retrieve value for attribute with specified name );
        %goto macro_exit ;

    %end;


    %* ---  end of assign return variable  --- ;


    %* ---  macro exit point  --- ;
    %macro_exit:


%mend;
