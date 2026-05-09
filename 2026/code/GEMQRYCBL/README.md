# GEMQRYCBL - COBOL Version of Gemini Query Interface

This folder contains a COBOL implementation of the Gemini Query interface, equivalent to the RPG version in ../GEMQRY.

## Files

- **GEMQRYUIC.dspf** - Display file definition (identical to RPG version)
- **GEMQRYUIC.sqlcblle** - COBOL program source
- **README.md** - This file

## Compilation Instructions

### 1. Create the Display File

```cl
CRTDSPF FILE(YOURLIB/GEMQRYUIC) SRCSTMF('/path/to/GEMQRYUIC.dspf')
```

### 2. Create the COBOL Program

```cl
CRTSQLCBLI OBJ(YOURLIB/GEMQRYUIC) +
  SRCSTMF('/path/to/GEMQRYUIC.sqlcblle') +
  COMMIT(*NONE) OBJTYPE(*PGM) CVTCCSID(*JOB)
```

## Prerequisites

1. **GEMINI_QUERY SQL Function** - Must be created (see ../GEMQRY/README.md)
2. **GEMINIKEY Data Area** - Must exist with your Gemini API key
3. **Display File** - GEMQRYUIC must be compiled before the program

## Running the Program

### Option 1: Direct Call

```cl
CALL YOURLIB/GEMQRYUIC
```

### Option 2: With File Override (if needed)

```cl
OVRDBF FILE(GEMQRYUIC) TOFILE(YOURLIB/GEMQRYUIC)
CALL YOURLIB/GEMQRYUIC
DLTOVR FILE(GEMQRYUIC)
```

## Known Issues

If you encounter file status '30' errors, this typically means:

- The display file GEMQRYUIC is not in your library list
- The display file was not compiled successfully
- There's a library resolution issue

To debug:

1. Verify display file exists: `DSPFD FILE(YOURLIB/GEMQRYUIC)`
2. Check library list: `DSPLIBL`
3. Ensure YOURLIB is in the library list before calling the program

## Functionality

The COBOL program provides the same functionality as the RPG version:

- Interactive input screen for model selection and query entry
- Calls GEMINI_QUERY SQL function
- Displays paginated response (16 lines × 78 characters per page)
- PageUp/PageDown navigation
- Error handling with SQLSTATE display
- F3=Exit, F12=Cancel/Return

## Differences from RPG Version

- Uses COBOL syntax and structure
- File handling uses COBOL workstation file I/O
- Indicator testing uses binary literals (B"1")
- String operations use COBOL STRING and FUNCTION TRIM

## Bugs

- Key handling is flakey, to say the least.
  - Safest is to only
    - Type a query
    - Hit enter
    - Scroll thru the response
    - Hit F3 to exit
  - Otherwise you might get stuck and have to do a SYSREQ option 2 to exit.
    - After which the display file is stuck and you'll need to invoke the program once more which will exit immediately unlocking the screen file.
