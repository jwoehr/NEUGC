# ============================================================================
# Makefile for GEMQRY - RPG Gemini Query Interface
# ============================================================================
# This Makefile builds five IBM i objects:
#   1. GEMQRYUI.dspf   - Display file
#   2. GEMQRYUIP       - SQLRPGLE interactive program
#   3. GEMQRYPGM       - SQLRPGLE headless program
#   4. CALLGEMQYD      - CL wrapper program
#   5. CALLGEMQYD      - Command definition
#
# Required Parameters:
#   LIB       - Target library for all objects (e.g., LIB=MYLIB)
#
# Optional Parameters:
#   SRCPF     - Source physical file for display file (default: QDDSSRC)
#   CMDSRCPF  - Source physical file for command (default: QCMDSRC)
#   SRCDIR    - Source directory (default: current directory)
#
# Usage Examples:
#   make all LIB=MYLIB                         # Build all objects
#   make all LIB=MYLIB SRCPF=MYSRCPF           # Use custom source file
#   make all LIB=MYLIB CMDSRCPF=MYCMDSRC       # Use custom command source
#   make dspf LIB=MYLIB                        # Build display file only
#   make gemqryuip LIB=MYLIB                   # Build GEMQRYUIP program only
#   make gemqrypgm LIB=MYLIB                   # Build GEMQRYPGM program only
#   make callgemqyd LIB=MYLIB                  # Build CL program only
#   make cmd LIB=MYLIB                         # Build command only
#   make clean                                 # Clean temporary files
#   make help                                  # Show this help
# ============================================================================

# Default values for optional parameters
SRCPF ?= QDDSSRC
CMDSRCPF ?= QCMDSRC
SRCDIR ?= .

# Source files (assumed to be in current directory)
DSPF_SRC = $(SRCDIR)/GEMQRYUI.dspf
GEMQRYUIP_SRC = $(SRCDIR)/GEMQRYUIP.sqlrpgle
GEMQRYPGM_SRC = $(SRCDIR)/GEMQRYPGM.sqlrpgle
CALLGEMQYD_CL_SRC = $(SRCDIR)/CALLGEMQYD.clle
CALLGEMQYD_CMD_SRC = $(SRCDIR)/CALLGEMQYD.cmd

# IBM i command wrapper - use system command to execute CL
SYSTEM = system

# Phony targets (not actual files)
.PHONY: all dspf gemqryuip gemqrypgm callgemqyd cmd clean help check-params

# Default target
all: check-params dspf gemqryuip gemqrypgm callgemqyd cmd
	@echo "============================================"
	@echo "Build complete!"
	@echo "Objects created in library: $(LIB)"
	@echo "  - $(LIB)/GEMQRYUI (Display File)"
	@echo "  - $(LIB)/GEMQRYUIP (SQLRPGLE Program)"
	@echo "  - $(LIB)/GEMQRYPGM (SQLRPGLE Program)"
	@echo "  - $(LIB)/CALLGEMQYD (CL Program)"
	@echo "  - $(LIB)/CALLGEMQYD (Command)"
	@echo "============================================"

# Check required parameters
check-params:
ifndef LIB
	@echo "============================================"
	@echo "ERROR: Required parameter LIB is not set"
	@echo "============================================"
	@echo ""
	@echo "Usage:"
	@echo "  make all LIB=<library> [SRCPF=<srcpf>] [CMDSRCPF=<cmdsrcpf>]"
	@echo ""
	@echo "Required Parameters:"
	@echo "  LIB       - Target library for all objects"
	@echo ""
	@echo "Optional Parameters:"
	@echo "  SRCPF     - Source physical file for display file (default: QDDSSRC)"
	@echo "  CMDSRCPF  - Source physical file for command (default: QCMDSRC)"
	@echo "  SRCDIR    - Source directory (default: .)"
	@echo ""
	@echo "Examples:"
	@echo "  make all LIB=MYLIB"
	@echo "  make all LIB=MYLIB SRCPF=MYSRCPF CMDSRCPF=MYCMDSRC"
	@echo "  make dspf LIB=MYLIB"
	@echo "  make help"
	@echo ""
	@echo "============================================"
	@exit 1
endif
	@echo "Building with parameters:"
	@echo "  LIB       = $(LIB)"
	@echo "  SRCPF     = $(SRCPF)"
	@echo "  CMDSRCPF  = $(CMDSRCPF)"
	@echo "  SRCDIR    = $(SRCDIR)"
	@echo "============================================"

# Build display file
dspf: check-params
	@echo "Building display file GEMQRYUI..."
	@echo "Step 1: Copying $(DSPF_SRC) to source member..."
	$(SYSTEM) "CPYFRMSTMF FROMSTMF('$(DSPF_SRC)') TOMBR('/QSYS.LIB/$(LIB).LIB/$(SRCPF).FILE/GEMQRYUI.MBR') MBROPT(*REPLACE)"
	@echo "Step 2: Creating display file object..."
	$(SYSTEM) "CRTDSPF FILE($(LIB)/GEMQRYUI) SRCFILE($(LIB)/$(SRCPF))"
	@echo "Display file GEMQRYUI created successfully in $(LIB)"
	@echo ""

# Build GEMQRYUIP SQLRPGLE program (depends on display file)
gemqryuip: check-params dspf
	@echo "Building SQLRPGLE program GEMQRYUIP..."
	$(SYSTEM) "CRTSQLRPGI OBJ($(LIB)/GEMQRYUIP) SRCSTMF('$(GEMQRYUIP_SRC)') OBJTYPE(*PGM) COMMIT(*NONE) CVTCCSID(*JOB)"
	@echo "SQLRPGLE program GEMQRYUIP created successfully in $(LIB)"
	@echo ""

# Build GEMQRYPGM SQLRPGLE program
gemqrypgm: check-params
	@echo "Building SQLRPGLE program GEMQRYPGM..."
	$(SYSTEM) "CRTSQLRPGI OBJ($(LIB)/GEMQRYPGM) SRCSTMF('$(GEMQRYPGM_SRC)') OBJTYPE(*PGM) COMMIT(*NONE) CVTCCSID(*JOB)"
	@echo "SQLRPGLE program GEMQRYPGM created successfully in $(LIB)"
	@echo ""

# Build CALLGEMQYD CL program
callgemqyd: check-params
	@echo "Building CL program CALLGEMQYD..."
	$(SYSTEM) "CRTBNDCL PGM($(LIB)/CALLGEMQYD) SRCSTMF('$(CALLGEMQYD_CL_SRC)') TGTCCSID(*JOB)"
	@echo "CL program CALLGEMQYD created successfully in $(LIB)"
	@echo ""

# Build CALLGEMQYD command (depends on CL program)
cmd: check-params callgemqyd
	@echo "Building command CALLGEMQYD..."
	@echo "Step 1: Copying $(CALLGEMQYD_CMD_SRC) to command source member..."
	$(SYSTEM) "CPYFRMSTMF FROMSTMF('$(CALLGEMQYD_CMD_SRC)') TOMBR('/QSYS.LIB/$(LIB).LIB/$(CMDSRCPF).FILE/CALLGEMQYD.MBR') MBROPT(*REPLACE)"
	@echo "Step 2: Creating command object..."
	$(SYSTEM) "CRTCMD CMD($(LIB)/CALLGEMQYD) PGM($(LIB)/CALLGEMQYD) SRCFILE($(LIB)/$(CMDSRCPF))"
	@echo "Command CALLGEMQYD created successfully in $(LIB)"
	@echo ""

# Clean target (placeholder - no temporary files in this build)
clean:
	@echo "No temporary files to clean."
	@echo "Note: This does not delete objects from IBM i library $(LIB)"

# Help target
help:
	@echo "============================================"
	@echo "GEMQRY Makefile - Build Instructions"
	@echo "============================================"
	@echo ""
	@echo "This Makefile builds five IBM i objects:"
	@echo "  1. GEMQRYUI (Display File)"
	@echo "  2. GEMQRYUIP (SQLRPGLE Interactive Program)"
	@echo "  3. GEMQRYPGM (SQLRPGLE Headless Program)"
	@echo "  4. CALLGEMQYD (CL Wrapper Program)"
	@echo "  5. CALLGEMQYD (Command Definition)"
	@echo ""
	@echo "Required Parameters:"
	@echo "  LIB       - Target library for all objects"
	@echo ""
	@echo "Optional Parameters:"
	@echo "  SRCPF     - Source physical file for display file (default: QDDSSRC)"
	@echo "  CMDSRCPF  - Source physical file for command (default: QCMDSRC)"
	@echo "  SRCDIR    - Source directory (default: current directory)"
	@echo ""
	@echo "Targets:"
	@echo "  all        - Build all five objects (default)"
	@echo "  dspf       - Build display file only"
	@echo "  gemqryuip  - Build GEMQRYUIP program (includes dspf)"
	@echo "  gemqrypgm  - Build GEMQRYPGM program only"
	@echo "  callgemqyd - Build CALLGEMQYD CL program only"
	@echo "  cmd        - Build CALLGEMQYD command (includes callgemqyd)"
	@echo "  clean      - Clean temporary files"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Usage Examples:"
	@echo "  make all LIB=MYLIB"
	@echo "  make all LIB=MYLIB SRCPF=MYSRCPF CMDSRCPF=MYCMDSRC"
	@echo "  make dspf LIB=MYLIB"
	@echo "  make gemqryuip LIB=MYLIB"
	@echo "  make gemqrypgm LIB=MYLIB"
	@echo "  make callgemqyd LIB=MYLIB"
	@echo "  make cmd LIB=MYLIB"
	@echo ""
	@echo "Prerequisites:"
	@echo "  - Source files must be in SRCDIR (default: current directory)"
	@echo "  - Target library (LIB) must exist"
	@echo "  - Source physical file (SRCPF) must exist in LIB"
	@echo "  - Command source physical file (CMDSRCPF) must exist in LIB"
	@echo "  - GEMINI_QUERY SQL function must be installed"
	@echo "  - GEMINIKEY data area must exist with API key"
	@echo ""
	@echo "============================================"

# Made with Bob
