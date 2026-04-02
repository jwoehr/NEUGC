**FREE
// ==============================================================================
// Program: GEMQRYUIP
// Description: Interactive screen program for Gemini Query
//              Allows user to enter model and query, then displays response
//              with paging capability
//
// Display File: GEMQRYUI
//
// Compilation:
//   1. Create display file:
//      CRTDSPF FILE(YOURLIB/GEMQRYUI) SRCSTMF('/path/to/GEMQRYUI.dspf')
//
//   2. Create program:
//      CRTSQLRPGI OBJ(YOURLIB/GEMQRYUIP) +
//        SRCSTMF('/path/to/GEMQRYUIP.sqlrpgle') +
//        COMMIT(*NONE) OBJTYPE(*PGM) CVTCCSID(*JOB)
//
// Prerequisites:
//   - GEMINI_QUERY SQL function must be created
//   - GEMINIKEY data area must exist with API key
//   - GEMQRYUI display file must be compiled
// ==============================================================================

CTL-OPT DFTACTGRP(*NO) ACTGRP(*NEW) OPTION(*SRCSTMT:*NODEBUGIO);

// Include SQL Communication Area for SQLWARN access
EXEC SQL INCLUDE SQLCA;

// Display file
DCL-F GEMQRYUI WORKSTN INDDS(Indicators);

// Indicator data structure
DCL-DS Indicators;
  Exit        IND POS(03);
  Cancel      IND POS(12);
  PageDown    IND POS(25);
  PageUp      IND POS(26);
END-DS;

// Data area for API key
DCL-S apiKeyDtaAra CHAR(100) DTAARA('GEMINIKEY');

// SQL host variables
DCL-S hModel    VARCHAR(100);
DCL-S hKey      VARCHAR(100);
DCL-S hContent  VARCHAR(5000);

// Working variables
DCL-S jsonQuery VARCHAR(5000);
DCL-S resultText VARCHAR(32000); // Maximum VARCHAR size - CAST from CLOB with truncation check
DCL-S resultLen INT(10);
DCL-S currentPage INT(10);
DCL-S totalPages INT(10);
DCL-S lineStart INT(10);
DCL-S lineEnd INT(10);
DCL-S lineLen INT(10);
DCL-S i INT(10);
DCL-S displayLine CHAR(78);
DCL-S pageNbrChar CHAR(4);
DCL-S totPagesChar CHAR(4);
DCL-S fullQuery VARCHAR(256);

// Array to hold line field pointers
DCL-DS lineFields QUALIFIED;
  line POINTER DIM(16);
END-DS;

// Constants
DCL-C LINES_PER_PAGE 16;
DCL-C LINE_WIDTH 78;

// Initialize
MODEL = 'gemini-2.5-pro';
QUERY = *BLANKS;
QUERY2 = *BLANKS;
QUERY3 = *BLANKS;
QUERY4 = *BLANKS;
currentPage = 1;

// Initialize line field pointers
lineFields.line(1) = %ADDR(LINE01);
lineFields.line(2) = %ADDR(LINE02);
lineFields.line(3) = %ADDR(LINE03);
lineFields.line(4) = %ADDR(LINE04);
lineFields.line(5) = %ADDR(LINE05);
lineFields.line(6) = %ADDR(LINE06);
lineFields.line(7) = %ADDR(LINE07);
lineFields.line(8) = %ADDR(LINE08);
lineFields.line(9) = %ADDR(LINE09);
lineFields.line(10) = %ADDR(LINE10);
lineFields.line(11) = %ADDR(LINE11);
lineFields.line(12) = %ADDR(LINE12);
lineFields.line(13) = %ADDR(LINE13);
lineFields.line(14) = %ADDR(LINE14);
lineFields.line(15) = %ADDR(LINE15);
lineFields.line(16) = %ADDR(LINE16);

// Main loop
DOW NOT Exit;
  // Display input screen
  EXFMT INPUTSCR;
  
  IF Exit;
    LEAVE;
  ENDIF;
  
  IF Cancel;
    ITER;
  ENDIF;
  
  // Validate input
  IF %TRIM(MODEL) = '';
    MODEL = 'gemini-2.5-pro';
  ENDIF;
  
  // Combine query fields
  fullQuery = %TRIM(QUERY) + %TRIM(QUERY2) + %TRIM(QUERY3) + %TRIM(QUERY4);
  
  IF %TRIM(fullQuery) = '';
    ERRMSG = 'Query cannot be empty';
    ERRMSG2 = '';
    ERRMSG3 = '';
    ERRMSG4 = '';
    
    EXFMT ERRORSCR;
    ITER;
  ENDIF;
  
  // Read API key from data area
  MONITOR;
    IN apiKeyDtaAra;
    hKey = %TRIMR(apiKeyDtaAra);
    
    IF %LEN(%TRIM(hKey)) = 0;
      ERRMSG = 'API key not found in data area GEMINIKEY';
      ERRMSG2 = '';
      ERRMSG3 = '';
      ERRMSG4 = '';
      
      EXFMT ERRORSCR;
      ITER;
    ENDIF;
  ON-ERROR;
    ERRMSG = 'Unable to read API key data area GEMINIKEY';
    ERRMSG2 = '';
    ERRMSG3 = '';
    ERRMSG4 = '';
    
    EXFMT ERRORSCR;
    ITER;
  ENDMON;
  
  // Build JSON content
  jsonQuery = '{"contents":[{"parts":[{"text":"' +
              %TRIM(fullQuery) + '"}]}]}';
  
  hModel = %TRIM(MODEL);
  hContent = jsonQuery;
  
  // Call Gemini API
  EXEC SQL
    SELECT CAST(GEMINI_QUERY(
      MODEL => :hModel,
      KEY => :hKey,
      CONTENT => :hContent
    ) AS VARCHAR(32000))
    INTO :resultText
    FROM SYSIBM.SYSDUMMY1;
  
  // Check for SQL errors or truncation warning
  IF SQLCODE <> 0;
    ERRMSG = 'Error calling Gemini API';
    ERRMSG2 = 'SQLCODE: ' + %CHAR(SQLCODE);
    ERRMSG3 = '';
    ERRMSG4 = '';
    SQLSTATE = SQLSTATE;
    EXFMT ERRORSCR;
    ITER;
  ENDIF;
  
  // Check for truncation warning
  IF SQLWN1 = 'W';
    ERRMSG = 'Warning: Response truncated to 32000 characters';
    ERRMSG2 = 'Full response may be larger than displayed';
    ERRMSG3 = '';
    ERRMSG4 = '';
    EXFMT ERRORSCR;
  ENDIF;
  
  // Get result length
  resultLen = %LEN(%TRIM(resultText));
  
  // Calculate total pages needed to display the result
  // Formula: Divide result length by page capacity (LINES_PER_PAGE * LINE_WIDTH)
  // Add 1 to account for partial pages (integer division rounds down)
  totalPages = %DIV(resultLen: (LINES_PER_PAGE * LINE_WIDTH)) + 1;
  
  // Edge case: If result length is an exact multiple of page capacity,
  // we added one too many pages above, so subtract it back
  // Example: 1248 chars with 16 lines * 78 width = exactly 1 page, not 2
  IF %REM(resultLen: (LINES_PER_PAGE * LINE_WIDTH)) = 0 AND resultLen > 0;
    totalPages = totalPages - 1;
  ENDIF;
  
  IF totalPages = 0;
    totalPages = 1;
  ENDIF;
  
  currentPage = 1;
  
  // Display response with paging
  DOW NOT Exit AND NOT Cancel;
    OUTMODEL = MODEL;
    pageNbrChar = %CHAR(currentPage);
    PAGENBR = pageNbrChar;
    totPagesChar = %CHAR(totalPages);
    TOTPAGES = totPagesChar;
    
    // Calculate starting position for current page
    lineStart = ((currentPage - 1) * LINES_PER_PAGE * LINE_WIDTH) + 1;
    
    // Clear all lines
    LINE01 = *BLANKS;
    LINE02 = *BLANKS;
    LINE03 = *BLANKS;
    LINE04 = *BLANKS;
    LINE05 = *BLANKS;
    LINE06 = *BLANKS;
    LINE07 = *BLANKS;
    LINE08 = *BLANKS;
    LINE09 = *BLANKS;
    LINE10 = *BLANKS;
    LINE11 = *BLANKS;
    LINE12 = *BLANKS;
    LINE13 = *BLANKS;
    LINE14 = *BLANKS;
    LINE15 = *BLANKS;
    LINE16 = *BLANKS;
    
    // Fill lines for current page
    FOR i = 1 TO LINES_PER_PAGE;
      lineEnd = lineStart + LINE_WIDTH - 1;
      
      IF lineStart <= resultLen;
        IF lineEnd > resultLen;
          lineEnd = resultLen;
        ENDIF;
        
        lineLen = lineEnd - lineStart + 1;
        IF lineLen > 0;
          displayLine = %SUBST(resultText: lineStart: lineLen);
        ENDIF;
        
        // Use pointer to assign to the appropriate line field
        %STR(lineFields.line(i):78) = displayLine;
        
        lineStart = lineEnd + 1;
      ENDIF;
    ENDFOR;
    
    // Display output screen
    EXFMT OUTPUTSCR;
    
    IF Exit;
      LEAVE;
    ENDIF;
    
    IF Cancel;
      LEAVE;
    ENDIF;
    
    // Handle paging
    IF PageDown AND currentPage < totalPages;
      currentPage = currentPage + 1;
    ENDIF;
    
    IF PageUp AND currentPage > 1;
      currentPage = currentPage - 1;
    ENDIF;
  ENDDO;
ENDDO;

*INLR = *ON;
RETURN;