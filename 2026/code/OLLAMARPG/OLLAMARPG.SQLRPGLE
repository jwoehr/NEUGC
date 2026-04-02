**free

ctl-opt dftactgrp(*no) option(*srcstmt : *nodebugio);


dcl-f  OLLAMADSPF  workstn
                   infds(dspf_info)  indds(dspf_inds)
                   sfile(PROMPTSFL : rrn1);

dcl-ds  dspf_info;
    keyPressed    char(1)  pos(369);
end-ds;

dcl-ds  dspf_inds;
    sfl_dsp      ind  pos(1);
    sfl_dspCtl   ind  pos(2);
    sfl_end      ind  pos(3);
    pos_prot     ind  pos(21);
    pos_srvr     ind  pos(22);
    pos_port     ind  pos(23);
    pos_modl     ind  pos(24);
    chg_prot     ind  pos(31);
    chg_srvr     ind  pos(32);
    chg_port     ind  pos(33);
    chg_modl     ind  pos(34);
end-ds;
dcl-s  rrn1      uns(5);

dcl-ds PSDS PSDS;
    pgmName       *PROC;
end-ds;

dcl-c  F3       x'33';
dcl-c  F4       x'34';
dcl-c  F6       x'36';
dcl-c  F9       x'39';
dcl-c  F12      x'3C';
dcl-c  ENTER    x'F1';

// These *GLOBAL* variables exist to provide the actual length of the
// SQL global variables that they represent (they will be represented
// in the DSPF with varying different lengths).
dcl-s protocol  varchar(10);
dcl-s server    varchar(1000);
dcl-s port      int(10);
dcl-s model     varchar(1000);

Exec SQL SET OPTION
    COMMIT=*NONE,
    DATFMT=*ISO,
    NAMING=*SYS;

fetchConfig();
dou keyPressed = F3;

    RUN_URL = %trim(protocol) + '://';
    if %len(%trim(server)) > 50;
        RUN_URL = %trim(RUN_URL) + %subst(server : 1 : 50) + '[...]';
    else;
        RUN_URL = %trim(RUN_URL) + %trim(server);
    endif;
    RUN_URL = %trim(RUN_URL) + ':' + %char(port);
    RUN_MODL = model;

    write MSGSFLC;
    exfmt RUNSCRN;
    ClearProgramMessages(1);


    if keyPressed = F3;
        iter;

    elseif keyPressed = F4;
        editConfig();

    elseif keyPressed = ENTER;
        RESPONSE = callOllama( PROMPT );

    endif;

enddo;


*inlr=*on;



//------------------------------------------------------------------------------
// Fetch config
// Sets the *GLOBAL* variables for protocol, port, server, and model
//------------------------------------------------------------------------------
dcl-proc fetchConfig;

    Exec SQL
        SET :protocol = ( VALUES dbsdk_v1.ollama_getProtocol() );

    Exec SQL
        SET :server = ( VALUES dbsdk_v1.OLLAMA_GetServer() );

    Exec SQL
        SET :port = ( VALUES dbsdk_v1.OLLAMA_GetPort() );

    Exec SQL
        SET :model = ( VALUES dbsdk_v1.OLLAMA_GetModel() );

    return;
end-proc fetchConfig;



//------------------------------------------------------------------------------
// Edit config
//------------------------------------------------------------------------------
dcl-proc editConfig;

    dcl-s done ind;
    dcl-s rtnShort varchar(227);
    dcl-s rtnLong  varchar(1000);

    CFG_PROT = protocol;
    CFG_SRVR = server;
    CFG_SRVRH = server;
    CFG_PORT = %char(port);
    CFG_MODL = model;
    CFG_MODLH = model;

    dou done;

        write MSGSFLC;
        exfmt CFGSCRN;

        ClearProgramMessages(2);
        clear pos_prot;
        clear pos_srvr;
        clear pos_port;
        clear pos_modl;


        if keyPressed = F12;
            done = *on;

        elseif keyPressed = F3;
            // F3 isn't supposed to be allowed (it should only be used
            // to exit the program)...but I always press F3 when I mean
            // to use F12, so I will just pretend like I pressed F12
            keyPressed = F12;
            done = *on;

        elseif keyPressed = F4;
            select;
                when CURFLD = 'CFG_PROT';
                    pos_prot = *ON;
                    promptField('protocol' : CFG_PROT : rtnShort : rtnLong);
                    CFG_PROT = rtnShort;
                    protocol = rtnLong;
                when CURFLD = 'CFG_SRVR';
                    pos_srvr = *ON;
                    promptField('server' : CFG_SRVR : rtnShort : rtnLong);
                    CFG_SRVR = rtnShort;
                    CFG_SRVRH = rtnLong;
                    server = rtnLong;
                when CURFLD = 'CFG_PORT';
                    pos_port = *ON;
                    promptField('port' : CFG_PORT : rtnShort : rtnLong);
                    CFG_PORT = rtnShort;
                    port = %int(rtnLong);
                when CURFLD = 'CFG_MODL';
                    pos_modl = *ON;
                    promptField('model' : CFG_MODL : rtnShort : rtnLong);
                    CFG_MODL = rtnShort;
                    CFG_MODLH = rtnLong;
                    model = rtnLong;
            endsl;

        elseif keyPressed = F6;
            setMyDefaults();
            SendProgramMessage('User defaults have been updated.');

        elseif keyPressed = ENTER;
            done = *ON;

            // Check to see if the user changed the server or model.
            // If so, update the hidden (long) fields to match the display field.
            if chg_srvr;
                CFG_SRVRH = CFG_SRVR;
            endif;
            if chg_modl;
                CFG_MODLH = CFG_MODL;
            endif;

            // Now update the global variables
            protocol = CFG_PROT;
            server = CFG_SRVRH;
            model = CFG_MODLH;
            monitor;
                port = %int(CFG_PORT);
                setForJob();
                // SendProgramMessage('Job defaults have been set.');
            on-error;
                SendProgramMessage('Port number is not valid');
                pos_port = *ON;
                done = *OFF;
            endmon;


        endif;

    enddo;

    return;
end-proc editConfig;



//------------------------------------------------------------------------------
// Sets the OLLAMA default values for the current user
//------------------------------------------------------------------------------
dcl-proc setMyDefaults;

    Exec SQL
        CALL OLLAMA_SetProtocolForMe( protocol => TRIM(:protocol) );

    Exec SQL
        CALL OLLAMA_SetServerForMe( hostname => TRIM(:server) );

    Exec SQL
        CALL OLLAMA_SetPortForMe( port => :port );

    Exec SQL
        CALL OLLAMA_SetModelForMe( model => TRIM(:model) );

    return;
end-proc setMyDefaults;


//------------------------------------------------------------------------------
// Sets the OLLAMA current values for the job (override user defaults)
//------------------------------------------------------------------------------
dcl-proc setForJob;

    Exec SQL
        CALL dbsdk_v1.OLLAMA_SetProtocolForJob( protocol => TRIM(:protocol) );

    Exec SQL
        CALL dbsdk_v1.OLLAMA_SetServerForJob( hostname => TRIM(:server) );

    Exec SQL
        CALL dbsdk_v1.OLLAMA_SetPortForJob( port => :port );

    Exec SQL
        CALL dbsdk_v1.OLLAMA_SetModelForJob( model => TRIM(:model) );

    SendProgramMessage('Job defaults have been set.');

    return;
end-proc setForJob;



//------------------------------------------------------------------------------
// Prompt
//------------------------------------------------------------------------------
dcl-proc promptField;
    dcl-pi *n;
        in_field    char(10) const;
        in_curVal   varchar(227) const;
        out_short   varchar(227);
        out_long    varchar(1000);
    end-pi;

    dcl-s done ind;
    dcl-s cursorsDeclared ind static;
    dcl-ds promptValues   qualified dim(*auto : 1000);
        text   varchar(1000);
    end-ds;

    if not cursorsDeclared;
        exsr declareCursors;
        cursorsDeclared = *ON;
    endif;

    if in_field = 'protocol';
        out_short = in_curVal;
        out_long = protocol;
    elseif in_field = 'port';
        out_short = in_curVal;
        out_long = %char(port);
    elseif in_field = 'server';
        out_short = in_curVal;
        out_long = server;
    elseif in_field = 'model';
        out_short = in_curVal;
        out_long = model;
    endif;

    P_FIELD = in_field;
    exsr loadPromptValues;
    exsr clearSubfile;
    exsr loadSubfile;

    dou done;
        write PROMPTKEYS;
        exfmt PROMPTCTL;

        if keyPressed = F3;
            keyPressed = F12;
            done = *ON;

        elseif keyPressed = F12;
            done = *ON;

        elseif keyPressed = ENTER;
            dou %eof(OLLAMADSPF);
                readc PROMPTSFL;
                if %eof(OLLAMADSPF) or P_SELECT <> '1';
                    iter;
                endif;

                done = *ON;
                out_short = P_TEXT;
                out_long = P_VALUE;
                leave;

            enddo;
        endif;

    enddo;

    return;

    //--------------------------------------------------------------------------
    begsr loadPromptValues;

        if in_field = 'protocol';
            Exec SQL OPEN ollamarpg_protocol;
            Exec SQL FETCH ollamarpg_protocol
                     FOR 1000 ROWS
                     INTO :promptValues;
            Exec SQL CLOSE ollamarpg_protocol;

        elseif in_field = 'port';
            Exec SQL OPEN ollamarpg_port;
            Exec SQL FETCH ollamarpg_port
                     FOR 1000 ROWS
                     INTO :promptValues;
            Exec SQL CLOSE ollamarpg_port;

        elseif in_field = 'server';
            Exec SQL OPEN ollamarpg_server;
            Exec SQL FETCH ollamarpg_server
                     FOR 1000 ROWS
                     INTO :promptValues;
            Exec SQL CLOSE ollamarpg_server;

        elseif in_field = 'model';
            Exec SQL OPEN ollamarpg_model;
            Exec SQL FETCH ollamarpg_model
                     FOR 1000 ROWS
                     INTO :promptValues;
            Exec SQL CLOSE ollamarpg_model;

        endif;

    endsr;

    //--------------------------------------------------------------------------
    begsr clearSubfile;
        sfl_dsp = *OFF;
        sfl_dspCtl = *OFF;
        write PROMPTCTL;
        sfl_dsp = *ON;
        sfl_dspCtl = *ON;
    endsr;

    //--------------------------------------------------------------------------
    begsr loadSubfile;
        for rrn1 = 1 to %elem(promptValues);
            clear PROMPTSFL;
            P_VALUE = promptValues(rrn1).text;
            P_TEXT = promptValues(rrn1).text;
            if %len(%trim(P_VALUE)) > %len(P_TEXT);
                %subst(P_TEXT : %len(P_TEXT)-3) = '...';
            endif;
            write PROMPTSFL;
        endfor;
        P_RCDNBR = 1;
    endsr;

    //--------------------------------------------------------------------------
    begsr declareCursors;
        Exec SQL
        DECLARE ollamarpg_protocol CURSOR FOR
            SELECT ollama_protocol
            FROM ollama_config_protocol;

        Exec SQL
        DECLARE ollamarpg_port CURSOR FOR
            SELECT CHAR(ollama_port)
            FROM ollama_config_port;

        Exec SQL
        DECLARE ollamarpg_server CURSOR FOR
            SELECT ollama_server
            FROM ollama_config_server;

        Exec SQL
        DECLARE ollamarpg_model CURSOR FOR
            SELECT ollama_model
            FROM ollama_config_model;
    endsr;

end-proc promptField;




//------------------------------------------------------------------------------
// Calls the Ollama prompt
//------------------------------------------------------------------------------
dcl-proc callOllama;
    dcl-pi *n  varchar(1000);
        in_prompt  varchar(500) const;
    end-pi;

    dcl-s ollamaResponse SQLTYPE(CLOB : 16000000);
    dcl-s prompt    varchar(1000);
    dcl-s rtnVal    varchar(1000);

    // Begin sanity check
    dcl-s protocol  varchar(16);
    dcl-s server    varchar(1000);
    dcl-s port      int(10);
    dcl-s model     varchar(1000);

    Exec SQL SET :protocol = (
        VALUES dbsdk_v1.ollama_getProtocol()
    );
    Exec SQL SET :server = (
        VALUES dbsdk_v1.ollama_getServer()
    );
    Exec SQL SET :port = (
        VALUES dbsdk_v1.ollama_getPort()
    );
    Exec SQL SET :model = (
        VALUES dbsdk_v1.ollama_getModel()
    );
    // End sanity check


    Exec SQL
        SET :prompt = (
            VALUES JSON_OBJECT(
                KEY 'role'      VALUE 'user',
                KEY 'content'   VALUE TRIM(:in_prompt)
            )
        );

    Exec SQL
        SET :ollamaResponse = (
            VALUES dbsdk_v1.ollama_generate( prompt => :prompt)
        );

    if sqlcode <> 0;
        SendProgramMessage('SQL Error: ' + %char(sqlcode));
    endif;

    rtnVal = ollamaResponse_DATA;
    return rtnVal;
end-proc callOllama;



//------------------------------------------------------------------------------
// Sends an informational message to the display
//------------------------------------------------------------------------------
dcl-proc  SendProgramMessage;
    dcl-pi  *n;
        in_message  varchar(80) const;
    end-pi;

    dcl-pr  SendMessage  extpgm('QMHSNDPM');
        msgId            char(7)  const;
        msgFile          char(20) const;
        msgData          char(80) const;
        msgLength        int(10)  const;
        msgType          char(10) const;
        stackEntry       char(10) const;
        stackCounter     int(10)  const;
        msgKey           char(4);
        errorDs          likeds(errorDs);
    end-pr;

    dcl-ds  errorDs;
        bytesProvided    int(10) inz(16);
        bytesAvailable   int(10);
        exceptionId      char(7);
    end-ds;
    dcl-s msgKey   char(4);

    SendMessage( 'CPF9898'
               : 'QCPFMSG   QSYS'
               : in_message
               : %len(in_message)
               : '*INFO'
               : pgmName
               : 0
               : msgKey
               : errorDS
               );

end-proc  SendProgramMessage;


//------------------------------------------------------------------------------
// Clears informational messages from the display
//------------------------------------------------------------------------------
dcl-proc  ClearProgramMessages;
    dcl-pi *n;
        in_stackEntry   int(10) const;
    end-pi;

    dcl-pr  RemoveMessage  extpgm('QMHRMVPM');
        stackEntry       char(10) const;
        stackCount       int(10)  const;
        msgKey           char(4)  const;
        toRemove         char(10) const;
        errorDs          likeds(errorDs);
    end-pr;

    dcl-ds  errorDs;
        bytesProvided    int(10) inz(16);
        bytesAvailable   int(10);
        exceptionId      char(7);
    end-ds;
    dcl-s msgKey   char(4);

    RemoveMessage( '*'
                 : in_stackEntry
                 : ' '
                 : '*ALL'
                 : errorDS
                 );

    return;
end-proc  ClearProgramMessages;
