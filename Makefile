# LaTeX Makefile for lecture notes compilation
# Main document filename (without .tex extension)
MAIN = main

# Output directory for build files
BUILD_DIR = build

# Source files
TEX_FILES = $(MAIN).tex $(wildcard chapters/*.tex) preamble.tex
BIB_FILES = $(wildcard *.bib)

# PDF output
PDF = $(BUILD_DIR)/$(MAIN).pdf

# Build tools
LATEX = pdflatex
BIBTEX = bibtex
MAKEINDEX = makeindex

# LaTeX flags
LATEX_FLAGS = -interaction=nonstopmode -halt-on-error -output-directory=$(BUILD_DIR)

# Default target
.PHONY: all
all: $(PDF)

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Main PDF compilation with bibliography and index
$(PDF): $(TEX_FILES) $(BIB_FILES) | $(BUILD_DIR)
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex
	-$(BIBTEX) $(BUILD_DIR)/$(MAIN)
	-$(MAKEINDEX) $(BUILD_DIR)/$(MAIN).idx
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex

# Quick compilation (single pass, no bibliography/index)
.PHONY: quick
quick: $(BUILD_DIR)
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex

# Clean build files
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

# Clean and rebuild
.PHONY: rebuild
rebuild: clean all

# Open PDF (adjust viewer as needed)
.PHONY: view
view: $(PDF)
	# Linux/WSL
	xdg-open $(PDF) 2>/dev/null || \
	# macOS
	open $(PDF) 2>/dev/null || \
	# Windows
	start $(PDF) 2>/dev/null || \
	echo "Please open $(PDF) manually"

# Continuous compilation (requires inotify-tools on Linux)
.PHONY: watch
watch:
	while inotifywait -e modify $(TEX_FILES) $(BIB_FILES) 2>/dev/null; do \
		make quick; \
	done

# Count words (requires texcount)
.PHONY: wordcount
wordcount:
	texcount -inc -sum $(MAIN).tex

# Show help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all        - Build complete PDF with bibliography and index"
	@echo "  quick      - Quick compilation (single pass)"
	@echo "  clean      - Remove build files"
	@echo "  rebuild    - Clean and rebuild"
	@echo "  view       - Open PDF in default viewer"
	@echo "  watch      - Continuous compilation on file changes"
	@echo "  wordcount  - Count words in document"
	@echo "  help       - Show this help message"

# Declare phony targets
.PHONY: all quick clean rebuild view watch wordcount help
