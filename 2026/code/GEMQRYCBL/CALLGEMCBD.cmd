             CMD        PROMPT('Call Gemini Query w/DTAARA')

             PARM       KWD(MODEL) TYPE(*CHAR) LEN(100) DFT('gemini-2.5-pro') +
                          PROMPT('Gemini model name')

             PARM       KWD(QUERY) TYPE(*CHAR) LEN(5000) DFT('What is IBM i?') +
                          PROMPT('Query text')