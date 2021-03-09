/* -----------------------------------------------------------------------
Macro   :    cxlib_attribute_set
Version :    $version$
Author  :    Magnus Mengelbier, Limelogic AB
Project :    https://github.com/limelogic/cxlibsas
-----------------------------------------------------------------------
Description

Utility macro to create/update a cxLib attribute value

-----------------------------------------------------------------------
Parameters

name
    Attribute name/reference

value
    Attribute value


-----------------------------------------------------------------------
License

GNU Public License v3
----------------------------------------------------------------------- */


%macro cxlib_attribute_set( name = , value = );

    %global CXLIB_OPTIONS ;

    %local cxattr_sighup ;

    %* ---  debug header  --- ;
    %if ( %sysmexecdepth = 1 ) or ( %sysfunc(indexw( %upcase(&CXLIB_OPTIONS), DEBUG, %str( ) )) > 0 ) %then %do;

        %put %str(NO)TE:  Macro cxlib_attribute_set ;
        %put %str(NO)TE:  Version $version$ ;

        %cxlib_debug_details( subject = Macro parameters, select = name value, print = N );
    %end;


    %* ---  verify attribute store exists  --- ;

    %if ( %sysfunc(exist( _cxlib_.attr )) = 0 ) %then %do;

        %cxlib_throw( message = The attribute data set does not exist, code = 10021 );
        %goto macro_exit ;

    %end;

    %* ---  end of verify attribute store exists  --- ;



    %* ---  get parameters in data set format  --- ;

    %let cxattr_sighup = 0 ;

    data _cxwrk_.cxattr_inputs;
        
        length name $ 256 value $ 1024 ;

        name = lowcase( strip(symget( 'name' )) );
        value = strip(symget( 'value' ))  ;

        *  simple check that name is characters, digits and specials ._/ ; 
        if not missing(compress( name, "._/", "ad")) then do;
            call symput( 'cxattr_sighup', '1' );
            stop;
        end;

        output;
    run;

    %if ( &syscc > 0 ) %then %do;

        %cxlib_throw( message = Could not read attribute macro inputs );
        %goto macro_exit ;

    %end;

    %if ( &cxattr_sighup = 1 ) %then %do;
        %*  attribute name invalid ;

        %cxlib_throw( message = The attribute name is not valid, code = 10024);
        %goto macro_exit ;

    %end;



    %* ---  update attribute store  --- ;
    proc sql noprint;

        delete from _cxlib_.attr 
            where lowcase(strip(name)) in ( select distinct name from _cxwrk_.cxattr_inputs )
        ;

        insert into _cxlib_.attr (name, value)
            select name, value from _cxwrk_.cxattr_inputs
        ;

    quit;


    %if ( &syscc > 0 ) %then %do;

        %cxlib_throw( message = Could not update attribute );
        %goto macro_exit ;

    %end;




    %* ---  macro exit point  --- ;
    %macro_exit:


    %if ( %sysfunc(indexw( %upcase(&CXLIB_OPTIONS), DEBUG, %str( ) )) = 0 ) and 
        ( %sysfunc(libref(_CXWRK_)) = 0 ) %then %do;

        proc datasets  library = _cxwrk_  nolist nodetails ;
            delete cxattr_: ;  run;
        quit;

    %end;


%mend;
