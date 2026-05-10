# GEMQRYCBL - COBOL Version of Gemini Query Interface

This folder contains a COBOL implementation of the Gemini Query interface, equivalent to the RPG version in ../GEMQRY.

## Requirements

Reuired to compile and run these COBOL Gemini queries:

- IBM's open source [AI-SDK-Db2-IBMi](https://github.com/IBM/AI-SDK-Db2-IBMi)

## Files

- **GEMQRYUIC.dspf** - Display file definition (identical to RPG version)
- **GEMQRYUIC.sqlcblle** - COBOL program source
- **GEMCBLPGM.sqlcblle** - Headless COBOL wrapper program for the Gemini API
- **CALLGEMCBD.cmd** - Command definition to easily invoke the headless wrapper
- **CALLGEMCBD.clle** - CL program implementation for the command
- **README.md** - This file

## Compilation Instructions

### Option 1: Using the Makefile (Recommended)

A GNU Makefile is provided to automate the build process. This is the easiest method.

**Prerequisites:**

- GNU Make must be available on your IBM i system
- Target library must exist
- Source physical files (QDDSSRC and QCMDSRC) must exist in the target library

**Basic Usage:**

```bash
# Build all objects (display file, programs, and command)
make all LIB=YOURLIB

# Build with custom source physical files
make all LIB=YOURLIB SRCPF=MYSRCPF CMDSRCPF=MYCMDSRC

# Build individual components
make dspf LIB=YOURLIB        # Display file only
make gemqryuic LIB=YOURLIB   # GEMQRYUIC program (includes display file)
make gemcblpgm LIB=YOURLIB   # GEMCBLPGM program only
make callgemcbd LIB=YOURLIB  # CALLGEMCBD CL program only
make cmd LIB=YOURLIB         # CALLGEMCBD command (includes CL program)

# Show help
make help
```

**Makefile Parameters:**

- `LIB` (required) - Target library for all objects
- `SRCPF` (optional) - Source physical file for display file (default: QDDSSRC)
- `CMDSRCPF` (optional) - Source physical file for command (default: QCMDSRC)
- `SRCDIR` (optional) - Source directory (default: current directory)

**What the Makefile Does:**

1. Validates required parameters
2. Copies GEMQRYUIC.dspf to source member and creates display file
3. Compiles GEMQRYUIC.sqlcblle (COBOL interactive program)
4. Compiles GEMCBLPGM.sqlcblle (COBOL headless program)
5. Compiles CALLGEMCBD.clle (CL wrapper program)
6. Copies CALLGEMCBD.cmd to source member and creates command

### Option 2: Manual Compilation

If you prefer to compile manually or don't have GNU Make available:

#### 1. Create the Display File

```cl
CRTDSPF FILE(YOURLIB/GEMQRYUIC) SRCSTMF('/path/to/GEMQRYUIC.dspf')
```

#### 2. Create the COBOL Display Program

```cl
CRTSQLCBLI OBJ(YOURLIB/GEMQRYUIC) +
  SRCSTMF('/path/to/GEMQRYUIC.sqlcblle') +
  COMMIT(*NONE) OBJTYPE(*PGM) CVTCCSID(*JOB)
```

#### 3. Create the Headless COBOL Program

```cl
CRTSQLCBLI OBJ(YOURLIB/GEMCBLPGM) +
  SRCSTMF('/path/to/GEMCBLPGM.sqlcblle') +
  COMMIT(*NONE) OBJTYPE(*PGM) CVTCCSID(*JOB)
```

#### 4. Create the CL Wrapper and Command for the Headless COBOL Program

Compile the CL program first:

```cl
CRTBNDCL PGM(YOURLIB/CALLGEMCBD) +
  SRCSTMF('/path/to/CALLGEMCBD.clle') +
  TGTCCSID(*JOB)
```

Then create the command:

```cl
CRTCMD CMD(YOURLIB/CALLGEMCBD) PGM(YOURLIB/CALLGEMCBD) +
  SRCSTMF('/path/to/CALLGEMCBD.cmd')
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

### Option 3: Using the Headless Command

```cl
YOURLIB/CALLGEMCBD MODEL('gemini-2.5-flash') QUERY('What is IBM i?')
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

- Key handling in GEMQRYUIC is flakey, to say the least.
  - Safest is to only
    - Type a query
    - Hit enter
    - Scroll thru the response
    - Hit F3 to exit
  - Otherwise you might get stuck and have to do a SYSREQ option 2 to exit.
    - After which the display file is stuck and you'll need to invoke the program once more which will exit immediately unlocking the screen file.
