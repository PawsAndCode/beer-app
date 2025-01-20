# Makefile for building and cleaning Lambda zips

# Define build directory
BUILD_DIR = build

# Default target to build all zips
build:
	@mkdir -p $(BUILD_DIR)
	@./build.sh

# Clean the build directory (remove the folder and its contents)
clean:
	@echo "Cleaning build directory..."
	@rm -rf $(BUILD_DIR)

.PHONY: build clean
