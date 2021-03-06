/* -----------------------------------------------------------------------
   Macro   :    cxlib_options
   Version :    $version$
   Author  :    Magnus Mengelbier, Limelogic AB
   -----------------------------------------------------------------------
   Description

    Utility macro to enable or disable cxLib options

   -----------------------------------------------------------------------
   Parameters

      options     List of options to enable or disable. An option name 
                  with a leading dash/minus implies option is disabled

   -----------------------------------------------------------------------
   License
    
    GNU Public License v3
   ----------------------------------------------------------------------- */


%macro cxlib_options( options = ) ;

    %put %str(NO)TE:  Macro cxlib_options ;
    %put %str(NO)TE:  Version $version$ ;


    %global CXLIB_OPTIONS ;


    data _null_ ;
        
        length opt $ 256 opt_enabled opt_disabled opt_string cxlib_opt  $ 4096 ;

        param = compbl(strip( symget('options') ));

        * --  split options into enabled and disabled  -- ;
        i = 1 ;
        opt = scan( param, i, " " );

        do while ( not missing( opt ) );

            select ( substr( strip(opt), 1, 1 ) );
                when( '-' )   call catx( " ", opt_disabled, upcase( compress( opt, ' -' ) ) );
                otherwise     call catx( " ", opt_enabled, upcase( compress( opt, ' +' ) ) );
            end;

            i = i + 1 ;
            opt = scan( param, i, " " );
        end;

        * --  get current options and those that will be enabled from macro parameter options  -- ;
        opt_string = upcase( catx( " ", compbl(strip( symget('CXLIB_OPTIONS') )), opt_enabled ) );

 
        * --  process options -- ;
        call missing( cxlib_opt );

        i = 1 ;
        opt = scan( opt_string, i, " " );

        do while ( not missing( opt ) );

            if ( indexw( cxlib_opt, opt, " " ) = 0 ) and 
               ( indexw( opt_disabled, opt, " " ) = 0 ) then 
               call catx( " ", cxlib_opt, opt );

            i = i + 1 ;
            opt = scan( opt_string, i, " " );
        end;

        * --  update CXLIB_OPTIONS  -- ;
        call symput( 'CXLIB_OPTIONS', strip(cxlib_opt) );

    run;


%mend;
