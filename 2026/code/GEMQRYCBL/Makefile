# ============================================================================
# Makefile for GEMQRYCBL - COBOL Gemini Query Interface
# ============================================================================
# This Makefile builds three IBM i objects:
#   1. GEMQRYUIC.dspf  - Display file
#   2. GEMQRYUIC       - COBOL interactive program
#   3. GEMCBLPGM       - COBOL headless program
#
# Required Parameters:
#   LIB     - Target library for all objects (e.g., LIB=MYLIB)
#
# Optional Parameters:
#   SRCPF   - Source physical file name (default: QDDSSRC)
#   SRCDIR  - Source directory (default: current directory)
#
# Usage Examples:
#   make all LIB=MYLIB                    # Build all objects
#   make all LIB=MYLIB SRCPF=MYSRCPF      # Use custom source file
#   make dspf LIB=MYLIB                   # Build display file only
#   make gemqryuic LIB=MYLIB              # Build GEMQRYUIC program only
#   make gemcblpgm LIB=MYLIB              # Build GEMCBLPGM program only
#   make clean                            # Clean temporary files
#   make help                             # Show this help
# ============================================================================

# Default values for optional parameters
SRCPF ?= QDDSSRC
SRCDIR ?= .

# Source files (assumed to be in current directory)
DSPF_SRC = $(SRCDIR)/GEMQRYUIC.dspf
GEMQRYUIC_SRC = $(SRCDIR)/GEMQRYUIC.sqlcblle
GEMCBLPGM_SRC = $(SRCDIR)/GEMCBLPGM.sqlcblle

# IBM i command wrapper - use system command to execute CL
SYSTEM = system

# Phony targets (not actual files)
.PHONY: all dspf gemqryuic gemcblpgm clean help check-params

# Default target
all: check-params dspf gemqryuic gemcblpgm
	@echo "============================================"
	@echo "Build complete!"
	@echo "Objects created in library: $(LIB)"
	@echo "  - $(LIB)/GEMQRYUIC (Display File)"
	@echo "  - $(LIB)/GEMQRYUIC (COBOL Program)"
	@echo "  - $(LIB)/GEMCBLPGM (COBOL Program)"
	@echo "============================================"

# Check required parameters
check-params:
ifndef LIB
	@echo "============================================"
	@echo "ERROR: Required parameter LIB is not set"
	@echo "============================================"
	@echo ""
	@echo "Usage:"
	@echo "  make all LIB=<library> [SRCPF=<srcpf>]"
	@echo ""
	@echo "Required Parameters:"
	@echo "  LIB     - Target library for all objects"
	@echo ""
	@echo "Optional Parameters:"
	@echo "  SRCPF   - Source physical file (default: QDDSSRC)"
	@echo "  SRCDIR  - Source directory (default: .)"
	@echo ""
	@echo "Examples:"
	@echo "  make all LIB=MYLIB"
	@echo "  make all LIB=MYLIB SRCPF=MYSRCPF"
	@echo "  make dspf LIB=MYLIB"
	@echo "  make help"
	@echo ""
	@echo "============================================"
	@exit 1
endif
	@echo "Building with parameters:"
	@echo "  LIB    = $(LIB)"
	@echo "  SRCPF  = $(SRCPF)"
	@echo "  SRCDIR = $(SRCDIR)"
	@echo "============================================"

# Build display file
dspf: check-params
	@echo "Building display file GEMQRYUIC..."
	@echo "Step 1: Copying $(DSPF_SRC) to source member..."
	$(SYSTEM) "CPYFRMSTMF FROMSTMF('$(DSPF_SRC)') TOMBR('/QSYS.LIB/$(LIB).LIB/$(SRCPF).FILE/GEMQRYUIC.MBR') MBROPT(*REPLACE)"
	@echo "Step 2: Creating display file object..."
	$(SYSTEM) "CRTDSPF FILE($(LIB)/GEMQRYUIC) SRCFILE($(LIB)/$(SRCPF))"
	@echo "Display file GEMQRYUIC created successfully in $(LIB)"
	@echo ""

# Build GEMQRYUIC COBOL program (depends on display file)
gemqryuic: check-params dspf
	@echo "Building COBOL program GEMQRYUIC..."
	$(SYSTEM) "CRTSQLCBLI OBJ($(LIB)/GEMQRYUIC) SRCSTMF('$(GEMQRYUIC_SRC)') CVTCCSID(*JOB)"
	@echo "COBOL program GEMQRYUIC created successfully in $(LIB)"
	@echo ""

# Build GEMCBLPGM COBOL program
gemcblpgm: check-params
	@echo "Building COBOL program GEMCBLPGM..."
	$(SYSTEM) "CRTSQLCBLI OBJ($(LIB)/GEMCBLPGM) SRCSTMF('$(GEMCBLPGM_SRC)') CVTCCSID(*JOB)"
	@echo "COBOL program GEMCBLPGM created successfully in $(LIB)"
	@echo ""

# Clean target (placeholder - no temporary files in this build)
clean:
	@echo "No temporary files to clean."
	@echo "Note: This does not delete objects from IBM i library $(LIB)"

# Help target
help:
	@echo "============================================"
	@echo "GEMQRYCBL Makefile - Build Instructions"
	@echo "============================================"
	@echo ""
	@echo "This Makefile builds three IBM i objects:"
	@echo "  1. GEMQRYUIC (Display File)"
	@echo "  2. GEMQRYUIC (COBOL Interactive Program)"
	@echo "  3. GEMCBLPGM (COBOL Headless Program)"
	@echo ""
	@echo "Required Parameters:"
	@echo "  LIB     - Target library for all objects"
	@echo ""
	@echo "Optional Parameters:"
	@echo "  SRCPF   - Source physical file name (default: QDDSSRC)"
	@echo "  SRCDIR  - Source directory (default: current directory)"
	@echo ""
	@echo "Targets:"
	@echo "  all        - Build all three objects (default)"
	@echo "  dspf       - Build display file only"
	@echo "  gemqryuic  - Build GEMQRYUIC program (includes dspf)"
	@echo "  gemcblpgm  - Build GEMCBLPGM program only"
	@echo "  clean      - Clean temporary files"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Usage Examples:"
	@echo "  make all LIB=MYLIB"
	@echo "  make all LIB=MYLIB SRCPF=MYSRCPF"
	@echo "  make dspf LIB=MYLIB"
	@echo "  make gemqryuic LIB=MYLIB"
	@echo "  make gemcblpgm LIB=MYLIB"
	@echo ""
	@echo "Prerequisites:"
	@echo "  - Source files must be in current directory"
	@echo "  - Target library (LIB) must exist"
	@echo "  - Source physical file (SRCPF) must exist in LIB"
	@echo "  - GEMINI_QUERY SQL function must be installed"
	@echo "  - GEMINIKEY data area must exist with API key"
	@echo ""
	@echo "============================================"

# Made with Bob
