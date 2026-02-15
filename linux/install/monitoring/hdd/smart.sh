#!/bin/bash

# ==============================================================================
# SMART MANAGER DASHBOARD
# A visual wrapper for smartctl and smartd operations.
# ==============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ==============================================================================
# SELF-ELEVATION LOGIC
# ==============================================================================

# Check if the script is running as root (ID 0).
# If not, execute 'sudo' on the script itself ($0) and pass all arguments ($@).
if [ "$EUID" -ne 0 ]; then
  echo -e "${YELLOW}This script requires root permissions. Elevating...${NC}"
  exec sudo "$0" "$@"
fi

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

print_header() {
    clear
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BOLD}                SMART STORAGE MANAGER                       ${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

pause() {
    echo -e "\n${CYAN}Press Enter to continue...${NC}"
    read -r
}

get_drive_list() {
    # HARDCODED DRIVE LIST
    # Based on User Setup (2x Toshiba HDD, 1x Samsung SATA SSD, 1x Samsung NVMe)

    DRIVES=(
        "/dev/disk/by-id/ata-TOSHIBA_MG09ACA18TE_62X0A10RFJDH"
        "/dev/disk/by-id/ata-TOSHIBA_MG09ACA18TE_94G0A0T8FJDH"
        "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S6PYNJ0R524883Y"
        "/dev/nvme0"
    )

    MODELS=(
        "Toshiba MG09 18TB #1 (Movies/Files)"
        "Toshiba MG09 18TB #2 (Movies/Files)"
        "Samsung 870 EVO 500GB (Plex Metadata)"
        "Samsung 990 EVO 2TB (OS/Home)"
    )

    TYPES=(
        "HDD"
        "HDD"
        "SSD"
        "NVMe"
    )
}

# ==============================================================================
# OPERATIONS
# ==============================================================================

op_short_test() {
    local dev=$1
    echo -e "\n${YELLOW}>>> Initiating Short Self-Test on $dev...${NC}"
    smartctl -t short "$dev" | grep -E "started|begin"
}

op_long_test() {
    local dev=$1
    echo -e "\n${YELLOW}>>> Initiating Long Self-Test on $dev...${NC}"
    smartctl -t long "$dev" | grep -E "started|begin"
}

op_abort_test() {
    local dev=$1
    echo -e "\n${YELLOW}>>> Aborting current self-test on $dev...${NC}"
    smartctl -X "$dev"
}

op_current_status() {
    local dev=$1
    echo -e "\n${YELLOW}>>> Checking Current Test Status for $dev...${NC}"

    if [[ "$dev" == *"/dev/nvme"* ]]; then
        # NVMe status line usually looks like "Self-test status: ..."
        smartctl -a "$dev" | grep "Self-test status"
    else
        # SATA status line
        smartctl -a "$dev" | grep "Self-test execution status"
    fi
}

op_last_result() {
    local dev=$1
    echo -e "\n${YELLOW}>>> Fetching Last Finished Test Result for $dev...${NC}"

    # We display the top entry of the log regardless of execution status
    if [[ "$dev" == *"/dev/nvme"* ]]; then
         # NVMe (Num 0 is usually latest)
         smartctl -l selftest "$dev" | grep "Num" -A 1
    else
         # SATA (Num 1 is latest)
         smartctl -l selftest "$dev" | grep "^# 1" -A 0
    fi
}

op_full_history() {
    local dev=$1
    echo -e "\n${YELLOW}>>> Full Self-Test History for $dev...${NC}"
    smartctl -l selftest "$dev" | grep -v "Revision"
}

op_detailed_info() {
    local dev=$1
    echo -e "\n${YELLOW}>>> Opening Detailed SMART Info for $dev (Press 'q' to exit)...${NC}"
    sleep 1
    smartctl -a "$dev" | less
}

op_power_time() {
    local dev=$1
    echo -e "\n${YELLOW}>>> Power-On Time for $dev...${NC}"
    smartctl -a "$dev" | grep "Power_On_Hours"
    smartctl -a "$dev" | grep "Power On Hours"
}

op_quick_health() {
    local dev=$1
    echo -e "\n${YELLOW}>>> Quick Health Check (PASSED/FAILED) for $dev...${NC}"
    # Grep for the specific Result line
    smartctl -H "$dev" | grep "result"
}

op_temp_check() {
    local dev=$1
    echo -e "\n${YELLOW}>>> Checking Temperature for $dev...${NC}"
    # Filter for Temperature keywords, ignoring table headers if possible
    smartctl -a "$dev" | grep -i "Temperature" | grep -v "ID#"
}

op_service_status() {
    echo -e "\n${YELLOW}>>> Checking smartd System Service...${NC}"
    systemctl status smartd --no-pager
}

op_smart_logs() {
    echo -e "\n${YELLOW}>>> Recent smartd Background Logs (Last 50 lines)...${NC}"
    echo -e "${CYAN}Use Arrow Keys/PageUp/PageDown to scroll. Press 'q' to exit.${NC}"
    journalctl -u smartd -n 50 --no-pager | less
}

op_test_notification() {
    echo -e "\n${YELLOW}>>> Triggering Test Notification...${NC}"

    if [ -f "/usr/local/bin/smartd-notify.sh" ]; then
        # Mock variables that smartd usually provides
        export SMARTD_DEVICE="TEST_DEVICE"
        export SMARTD_DEVICETYPE="TEST_TYPE"
        export SMARTD_MESSAGE="This is a manual test notification."

        /usr/local/bin/smartd-notify.sh
        echo -e "${GREEN}Notification script executed. Check your desktop.${NC}"
    else
        echo -e "${RED}Error: /usr/local/bin/smartd-notify.sh not found.${NC}"
    fi
}

# ==============================================================================
# MENUS
# ==============================================================================

drive_menu() {
    local idx=$1
    local dev="${DRIVES[$idx]}"
    local model="${MODELS[$idx]}"
    local type="${TYPES[$idx]}"

    while true; do
        print_header
        echo -e "Selected Drive: ${BOLD}$model${NC}"
        echo -e "Device Path:    $dev"
        echo -e "Type:           $type"
        echo -e "${BLUE}------------------------------------------------------------${NC}"
        echo "1) Run Short Test (2 mins)"

        # Only show Long Test for HDDs
        if [ "$type" == "HDD" ]; then
            echo "2) Run Long Test (20+ hours)"
        else
            echo -e "${CYAN}2) Run Long Test (Disabled for $type)${NC}"
        fi

        echo "3) Check Current Test Status"
        echo "4) Check Last Finished Test Result"
        echo "5) List All Past Tests"
        echo "6) Show Detailed Info (Log)"
        echo "7) Show Power-On Time"
        echo "8) Abort Running Test"
        echo "9) Quick Health Check (PASSED/FAILED)"
        echo "10) Check Temperature"
        echo "b) Back to Main Menu"
        echo -e "${BLUE}------------------------------------------------------------${NC}"

        read -p "Select an operation: " choice

        case $choice in
            1) op_short_test "$dev"; pause ;;
            2)
                if [ "$type" == "HDD" ]; then
                    op_long_test "$dev"
                else
                    echo -e "\n${RED}Long tests are not recommended/necessary for modern SSDs.${NC}"
                fi
                pause
                ;;
            3) op_current_status "$dev"; pause ;;
            4) op_last_result "$dev"; pause ;;
            5) op_full_history "$dev"; pause ;;
            6) op_detailed_info "$dev" ;; # No pause needed after less
            7) op_power_time "$dev"; pause ;;
            8) op_abort_test "$dev"; pause ;;
            9) op_quick_health "$dev"; pause ;;
            10) op_temp_check "$dev"; pause ;;
            b) break ;;
            *) echo -e "${RED}Invalid option.${NC}"; sleep 1 ;;
        esac
    done
}

main_menu() {
    get_drive_list

    while true; do
        print_header
        echo -e "${BOLD}Drives:${NC}"

        count=${#DRIVES[@]}
        for ((i=0; i<count; i++)); do
            echo -e "$((i+1))) ${BOLD}${MODELS[$i]}${NC} (${TYPES[$i]})"
        done

        echo -e "${BLUE}------------------------------------------------------------${NC}"
        echo -e "s) Check Smartd Service Status"
        echo -e "l) View Recent Background Logs"
        echo -e "n) Test Desktop Notification"
        echo -e "q) Quit"
        echo -e "${BLUE}------------------------------------------------------------${NC}"

        read -p "Select a drive or option: " choice

        # Check if input is a number and valid drive index
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$count" ]; then
            drive_menu $((choice-1))
        elif [[ "$choice" == "s" ]]; then
            op_service_status; pause
        elif [[ "$choice" == "l" ]]; then
            op_smart_logs; pause
        elif [[ "$choice" == "n" ]]; then
            op_test_notification; pause
        elif [[ "$choice" == "q" ]]; then
            echo -e "\nGoodbye!"
            exit 0
        else
            echo -e "${RED}Invalid option.${NC}"; sleep 1
        fi
    done
}

# Start
main_menu
