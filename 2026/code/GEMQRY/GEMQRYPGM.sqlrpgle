**FREE
// ==============================================================================
// Program: GEMQRYPGM
// Description: SQLRPGLE wrapper for GEMINI_QUERY using data area for API key
// 
// CRTSQLRPGI OBJ(JWOEHR/GEMQRYPGM) +
//  SRCSTMF('/home/jwoehr/work/AI/GEMQRYPGM.sqlrpgle') +
//  COMMIT(*NONE) OBJTYPE(*PGM) CVTCCSID(*JOB)
// 
// Setup: CRTDTAARA DTAARA(YOURLIB/GEMINIKEY) TYPE(*CHAR) LEN(100)
//        Then use CHGDTAARA to set the value with exact case from SQL:
//        CALL QSYS2.QCMDEXC('CHGDTAARA DTAARA(YOURLIB/GEMINIKEY) VALUE(''your-key'')')
// 
// Parameters:
//   pModel   - Gemini model name (optional, default: 'gemini-2.5-flash')
//   pContent - JSON content for the query (optional)
//   pResult  - Returned result from Gemini API
// ==============================================================================

CTL-OPT DFTACTGRP(*NO) ACTGRP(*CALLER) OPTION(*SRCSTMT:*NODEBUGIO);

// Parameter definitions
DCL-PI *N EXTPGM('GEMQRYPGM');
  pModel    CHAR(100) CONST OPTIONS(*NOPASS);
  pContent  CHAR(5000) CONST OPTIONS(*NOPASS);
  pResult   CHAR(5000) OPTIONS(*NOPASS);
END-PI;

// Data area for API key - change QTEMP/GEMINIKEY to your library/data area
DCL-S apiKeyDtaAra CHAR(100) DTAARA('GEMINIKEY');

// SQL host variables
DCL-S hModel    VARCHAR(100);
DCL-S hKey      VARCHAR(100);
DCL-S hContent  VARCHAR(5000);
DCL-S hResult   VARCHAR(5000);

// Initialize
hModel = 'gemini-2.5-flash';
hContent = '{"contents":[{"parts":[{"text":"What is IBM i?"}]}]}';

// Get parameters
IF %PARMS() >= 1;
  hModel = %TRIMR(pModel);
ENDIF;

IF %PARMS() >= 2;
  hContent = %TRIMR(pContent);
ENDIF;

// Read API key from data area (preserves case)
MONITOR;
  IN apiKeyDtaAra;
  hKey = %TRIMR(apiKeyDtaAra);
  
  // Validate that API key was successfully retrieved
  IF %LEN(%TRIM(hKey)) = 0;
    DSPLY 'Error: API key not found in data area';
    *INLR = *ON;
    RETURN;
  ENDIF;
ON-ERROR;
  DSPLY 'Error: Unable to read API key data area';
  *INLR = *ON;
  RETURN;
ENDMON;

// Call the GEMINI_QUERY function
EXEC SQL
  SET :hResult = GEMINI_QUERY(
    MODEL => TRIM(:hModel),
    KEY => TRIM(:hKey),
    CONTENT => TRIM(:hContent)
  );

// Return result
IF %PARMS() >= 3;
  pResult = hResult;
ENDIF;

// Display status
IF SQLCODE = 0;
  DSPLY 'Success';
ELSE;
  DSPLY ('Error: ' + SQLSTATE);
ENDIF;

*INLR = *ON;
RETURN;