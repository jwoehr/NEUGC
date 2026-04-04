# IBM i Db2 SQL for Generative AI

This directory contains SQL scripts, user-defined functions (UDFs), and SQLRPGLE programs to enable generative AI capabilities directly from IBM i Db2.

## SQL File

### SQL Function

- [`callmodel.sql`](callmodel.sql): SQL script containing the `GEMINI_QUERY` user-defined function.

### `GEMINI_QUERY(MODEL, KEY, CONTENT)`

This function allows you to call Google's Gemini large language models.

#### SQL Parameters

- **MODEL**: `VARCHAR(100)` - The name of the Gemini model to use (e.g., 'gemini-1.5-pro-latest').
- **KEY**: `VARCHAR(100)` - Your Google AI API key.
- **CONTENT**: `CLOB(1M)` - The JSON payload for the API call.

#### Returns

- `CLOB(10M)` - The JSON response from the Gemini API.

#### Example Usage

```sql
VALUES GEMINI_QUERY(
    MODEL => 'gemini-2.5-pro',
    KEY => 'YOUR_API_KEY',
    CONTENT => '{"contents":[{"parts":[{"text":"What is AI?"}]}]}'
);
```

## SQLRPGLE Wrapper Program

- [`GEMQRYPGM.sqlrpgle`](GEMQRYPGM.sqlrpgle): SQLRPGLE program that wraps the `GEMINI_QUERY` function. Reads API key from data area to preserve case sensitivity.

### CL Command Interface

- [`CALLGEMQYD.cmd`](CALLGEMQYD.cmd): Command definition for calling the Gemini Query wrapper.
- [`CALLGEMQYD.clle`](CALLGEMQYD.clle): CL program that processes command parameters and calls GEMQRYPGM.

### Overview

The `GEMQRYPGM` program provides a native IBM i interface to the `GEMINI_QUERY` SQL function. It addresses the case sensitivity requirements of the Gemini API by reading the API key from a data area where case is preserved.

### Compilation

**1. Compile the SQLRPGLE program:**

```cl
CRTSQLRPGI OBJ(YOURLIB/GEMQRYDTA) SRCSTMF('/path/to/GEMQRYPGM.sqlrpgle') OBJTYPE(*PGM) COMMIT(*NONE) DBGVIEW(*SOURCE)
```

**2. Compile the CL program:**

```cl
CRTBNDCL PGM(YOURLIB/CALLGEMQYD) SRCSTMF('/path/to/CALLGEMQYD.clle') DBGVIEW(*SOURCE)
```

**3. Create the command:**

```cl
CRTCMD CMD(YOURLIB/CALLGEMQYD) PGM(YOURLIB/CALLGEMQYD) SRCSTMF('/path/to/CALLGEMQYD.cmd')
```

### Setup

**1. Create data area for API key:**

```cl
CRTDTAARA DTAARA(YOURLIB/GEMINIKEY) TYPE(*CHAR) LEN(100)
```

**2. Set API key (preserves case):**

```cl
CALL QSYS2.QCMDEXC('CHGDTAARA DTAARA(YOURLIB/GEMINIKEY) VALUE(''your-API-key-with-exact-case'')');
```

### Usage

**Using the command:**

```cl
CALLGEMQYD MODEL('gemini-2.5-pro') QUERY('What is IBM i?')
```

**With prompting:**

```cl
CALLGEMQYD
```

**Direct program call:**

```cl
DCL VAR(&MODEL) TYPE(*CHAR) LEN(100) VALUE('gemini-2.5-pro')
DCL VAR(&CONTENT) TYPE(*CHAR) LEN(5000) VALUE('{"contents":[{"parts":[{"text":"Hello"}]}]}')
DCL VAR(&RESULT) TYPE(*CHAR) LEN(5000)

CALL PGM(GEMQRYPGM) PARM(&MODEL &CONTENT &RESULT)
```

### Program Parameters

**GEMQRYPGM Program:**

- `pModel` (CHAR 100, optional): Gemini model name (default: 'gemini-2.5-pro')
- `pContent` (CHAR 5000, optional): JSON content for the query
- `pResult` (CHAR 5000, optional): Returned API response

**CALLGEMQYD Command:**

- `MODEL` (CHAR 100): Gemini model name (default: 'gemini-2.5-pro')
- `QUERY` (CHAR 500): Query text (default: 'What is IBM i?')

### Case Sensitivity Note

The Gemini API requires case-sensitive API keys. IBM i CL and RPGLE typically uppercase character data. This solution uses a data area to store the API key where case is preserved. The API key must be set using SQL's QCMDEXC as shown above, or by creating the data area with the exact case value.

### Program Files

- **GEMQRYPGM.sqlrpgle**: Main SQLRPGLE wrapper program
  - Compiles to: GEMQRYPGM
  - Reads API key from data area GEMINIKEY in your library list
    - Does not know the specific library, just the first GEMINIKEY found in library list
  - Calls GEMINI_QUERY SQL function
  
- **CALLGEMQYD.clle**: CL program for command processing
  - Compiles to: CALLGEMQYD program
  - Accepts MODEL and QUERY parameters
  - Builds JSON content
  - Calls GEMQRYPGM
  
- **CALLGEMQYD.cmd**: Command definition
  - Creates: CALLGEMQYD command
  - Provides prompted interface
  - Parameters: MODEL, QUERY

## Interactive Screen Program

- [`GEMQRYUI.dspf`](GEMQRYUI.dspf): Display file for interactive Gemini query interface with color-enhanced UI
- [`GEMQRYUIP.sqlrpgle`](GEMQRYUIP.sqlrpgle): Interactive SQLRPGLE program with screen-based UI

### Overview of Screen Program

The `GEMQRYUIP` program provides a full-screen interactive interface for querying Gemini models. It allows users to:

- Enter the model name and query text via a screen interface
- Execute the query against the Gemini API
- View the complete response with paging capability (PageUp/PageDown)
- Handle long responses that span multiple screens
- Enjoy an enhanced color-coded display for improved usability

### Compilation of Screen Program

**1. Create the display file:**

```cl
CRTDSPF FILE(YOURLIB/GEMQRYUI) SRCSTMF('/path/to/GEMQRYUI.dspf')
```

**2. Compile the SQLRPGLE program:**

```cl
CRTSQLRPGI OBJ(YOURLIB/GEMQRYUIP) SRCSTMF('/path/to/GEMQRYUIP.sqlrpgle') OBJTYPE(*PGM) COMMIT(*NONE) DBGVIEW(*SOURCE) CVTCCSID(*JOB)
```

### Prerequisites

Before running the interactive program, ensure:

1. The `GEMINI_QUERY` SQL function is created (from [`callmodel.sql`](callmodel.sql))
2. The `GEMINIKEY` data area exists with your API key (see Setup section above)
3. The `GEMQRYUI` display file is compiled

### Usage of Screen Program

Simply call the program to launch the interactive interface:

```cl
CALL YOURLIB/GEMQRYUIP
```

### Screen Flow

1. **Input Screen**: Enter model name and query text
   - Default model: `gemini-2.5-pro`
   - Query field: 256 characters
   - F3=Exit, F12=Cancel, Enter=Execute

2. **Output Screen**: View response with paging
   - Displays 16 lines per page (78 characters wide)
   - Shows current page number and total pages
   - PageDown=Next page, PageUp=Previous page
   - F3=Exit, F12=Return to input

3. **Error Screen**: Displays any errors encountered
   - Shows error message, SQLSTATE, and SQLCODE
   - F3=Exit, F12=Return to input

### Features

- **Full Response Display**: Unlike the command interface which truncates output, the screen program displays the entire response
- **Paging Support**: Navigate through long responses using PageUp/PageDown
- **Error Handling**: Clear error messages with SQL diagnostic information
- **User-Friendly**: Interactive prompts and function key support
- **Case-Sensitive API Key**: Uses the same data area approach as GEMQRYPGM
- **Color-Enhanced Interface**: Professional color scheme for improved readability and usability

### Program Files for Screen Program

- **GEMQRYUI.dspf**: Display file definition
  - Three record formats: INPUTSCR, OUTPUTSCR, ERRORSCR
  - Supports function keys F3 (Exit) and F12 (Cancel)
  - Paging indicators for PageUp/PageDown
  - **Color Scheme**:
    - **Input Screen**: Turquoise headers, pink labels, white underlined input fields, blue help text, green function keys
    - **Output Screen**: Turquoise headers, pink labels, yellow model display, white response text, green function keys
    - **Error Screen**: Red blinking header, high-intensity red error messages, yellow warnings, green function keys
  
- **GEMQRYUIP.sqlrpgle**: Interactive program
  - Compiles to: GEMQRYUIP
  - Reads API key from data area GEMINIKEY
  - Calls GEMINI_QUERY SQL function
  - Handles responses up to 32KB (with truncation warning for larger responses). This limit is due to Db2 for i VARCHAR maximum size constraints.
  - **Note**: The GEMINI_QUERY SQL function can return up to 10MB, but the screen program displays up to 32KB (32,000 bytes) due to VARCHAR size limitations. For responses larger than 32KB, consider using the SQL function directly or the GEMQRYPGM program with appropriate output handling.
  - Provides 16-line paging display
