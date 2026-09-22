#!/usr/bin/env bash
# Description: Standard terminal color palette and visual styling for Linux scripts
# Note: Automatically disables colors if stdout is not a TTY or if NO_COLOR is set.

# Prevent multiple inclusions in the same subshell environment
if [[ -n "${_INSTALL_COLORS_LOADED:-}" ]]; then
    return 0 2>/dev/null || exit 0
fi
_INSTALL_COLORS_LOADED=1

# Terminal colors & styles (enabled unless NO_COLOR is set)
if [[ -z "${NO_COLOR:-}" ]]; then
    C_RESET='\033[0m'
    C_BOLD='\033[1m'
    C_CYAN='\033[1;36m'
    C_BLUE='\033[1;34m'
    C_GREEN='\033[1;32m'
    C_YELLOW='\033[1;33m'
    C_RED='\033[1;31m'
else
    C_RESET=''
    C_BOLD=''
    C_CYAN=''
    C_BLUE=''
    C_GREEN=''
    C_YELLOW=''
    C_RED=''
fi

DIV_MAIN="================================================================================"
DIV_SUB="--------------------------------------------------------------------------------"
