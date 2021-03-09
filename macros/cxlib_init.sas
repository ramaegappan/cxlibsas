/* -----------------------------------------------------------------------
Macro   :    cxlib_init
Version :    $version$
Author  :    Magnus Mengelbier, Limelogic AB
Project :    https://github.com/limelogic/cxlibsas
-----------------------------------------------------------------------
Description

Utility macro to initialize cxLib in the current SAS session

-----------------------------------------------------------------------
Parameters

resetcc
    Reset SYSCC and SYSMSG to 

options
    Default options

verbose 
    Enable verbose messages during processing

-----------------------------------------------------------------------
License

GNU Public License v3
----------------------------------------------------------------------- */


%macro cxlib_init( resetcc = Y, options = , verbose = Y);

    %global CXLIB_OPTIONS ;

    %local 
        cxinit_verbose
        cxinit_work_path 
    ;

    %* ---  determine message level  --- ;
    %if ( ( %upcase(&verbose) = Y ) or ( %sysfunc(indexw( %upcase(&CXLIB_OPTIONS), DEBUG, %str( ) )) > 0 )) %then %do;
        %let cxinit_verbose = Y;
    %end;



    %* ---  debug header  --- ;
    %if ( %sysmexecdepth = 1 ) or ( %upcase(&cxinit_verbose) = Y ) %then %do;

        %put %str(NO)TE:  Macro cxlib_init ;
        %put %str(NO)TE:  Version $version$ ;

        %cxlib_debug_details( subject = Macro parameters, select = resetcc options verbose, print = N );
    %end;


    %* ---  parameter checks   --- ;

    %if ( ( &resetcc = %str( ) ) or ( %sysfunc(indexw( Y N, %upcase(&resetcc), %str( ) )) = 0 ) ) %then %do;
        %*  resetcc is not valid value ;
        %cxlib_throw( code = 12001, message = The value for option RESETCC is not valid );
        %goto macro_exit ;
    %end;

    %if ( %sysfunc(indexw( Y N, %upcase(&verbose), %str( ) )) = 0 ) %then %do;
        %*  verbose is not valid value ;
        %cxlib_throw( code = 12001, message = The value for option VERBOSE is not valid );
        %goto macro_exit ;
    %end;

    %* ---  end of parameter checks   --- ;


    %* ---  reset conidition code  --- ;

    %if ( %upcase(&resetcc) = Y ) %then %do;
        %if ( %upcase(cxinit_verbose) = Y ) %then %do;
            %put %str(NO)TE: SYSCC and SYSMSG reset to no %str(Er)ror or %str(Wa)rning state ;
        %end;

        %let syscc = 0;
        %let sysmsg = ;
    %end;

    %* ---  end of reset conidition code  --- ;


    %* ---  set up cxlib library  --- ;

    %if ( %sysfunc(libref(_CXLIB_)) < 0 ) %then %do; 
       %*  there is an issue with the library assignment ... just clear it ;
       %let rc = %sysfunc(libname( _cxlib_ ));
    %end;


    %if ( %sysfunc(libref(_CXLIB_)) > 0 ) %then %do; 

        %let cxinit_work_path = %sysfunc(pathname(work))/_cxlib ;

        %if ( %sysfunc(fileexist(&cxinit_work_path)) = 0 ) %then %do;

            %* create library path as it does not exist ;
            %if ( %sysfunc(dcreate( _cxlib, %sysfunc(pathname(WORK)) )) = %str( ) ) %then %do;
                %cxlib_throw( code = 12001, message = Could not create cxLib worker library directory  );
                %goto macro_exit ;
            %end;
        %end;

        %if ( %sysfunc(libname( _CXLIB_, &cxinit_work_path )) ^= 0 ) %then %do;

            %cxlib_throw( code = 1100, message = Could not assign liibname _CXLIB_ );
            %goto macro_exit ;

        %end;

    %end;
     
    %if ( &syscc > 0 ) %then %do;

        %cxlib_throw( message = Could not initialize cxLib worker library &cxinit_work_path );
        %goto macro_exit ;

    %end;

    %* ---  end of set up cxlib library  --- ;


    %* ---  init attribute store  --- ;

    %if ( %sysfunc(exist( _cxlib_.attr )) = 0 ) %then %do;

        proc sql noprint;
            create table _cxlib_.attr (
                name         char(256),
                value        char(1024)
            );
        quit;

    %end;

    %if ( &syscc > 0 ) %then %do;

        %cxlib_throw( message = Could not initialize cxLib attribute data set );
        %goto macro_exit ;

    %end;

    %* ---  end of init attribute store  --- ;



    %* ---  set up cxlib worker library  --- ;
    %* note:  this library is a transient work area for temporary data sets only  ;

    %if ( %sysfunc(libref(_CXWRK_)) < 0 ) %then %do; 
       %*  there is an issue with the library assignment ... just clear it ;
       %let rc = %sysfunc(libname( _CXWRK_ ));
    %end;


    %if ( %sysfunc(libref(_CXWRK_)) > 0 ) %then %do; 

        %let cxinit_work_path = %sysfunc(pathname(work))/_cxwork ;

        %if ( %sysfunc(fileexist(&cxinit_work_path)) = 0 ) %then %do;

            %* create library path as it does not exist ;
            %if ( %sysfunc(dcreate( _cxwork, %sysfunc(pathname(WORK)) )) = %str( ) ) %then %do;
                %cxlib_throw( code = 12001, message = Could not create cxLib worker library directory  );
                %goto macro_exit ;
            %end;
        %end;

        %if ( %sysfunc(libname( _CXWRK_, &cxinit_work_path )) ^= 0 ) %then %do;

            %cxlib_throw( code = 1100, message = Could not assign liibname _CXWRK_ );
            %goto macro_exit ;

        %end;

    %end;
     
    %if ( &syscc > 0 ) %then %do;

        %cxlib_throw( message = Could not initialize cxLib worker library &cxinit_work_path );
        %goto macro_exit ;

    %end;

    %* ---  end of set up cxlib worker library  --- ;



    %* ---  initialise cxlib options  --- ;
    %cxlib_options( options = &options ) ;

    %if ( &syscc > 0 ) %then %do;

        %cxlib_throw( message = Could not initialize cxLib options );
        %goto macro_exit ;

    %end;
    



    %* ---  macro exit point  --- ;
    %macro_exit:



%mend;
