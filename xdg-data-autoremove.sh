#!/usr/bin/env bash

# bash strict mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

main() {
    PARSED_JSON=$(jq -r '.name as $name | .executables as $executables | .locations[] | "\($name),\($executables|join("|")),\(.file)"' "$APPLICATION_JSON_DIRECTORY"/*.json)

    while IFS="," read -r APP_NAME APP_EXECUTABLE FILE_PATH; do
        check_application "$APP_NAME" "$APP_EXECUTABLE" "$FILE_PATH"
    done <<<"$PARSED_JSON"

    if [ ${#FOUND_APP_PATHES[@]} -ne 0 ]; then
        info_output
        confirm_file_delete
    else
        $OPTION_RAW || printf "No files found\n"
    fi
}

check_application() {
    APP_NAME="$1"
    APP_EXECUTABLE="$2"
    FILE_PATH=$(echo "$3" | envsubst)

    # Skip if executable and file or folder doesn't exists
    (! check_command_available "$APP_EXECUTABLE" && { [ -f "$FILE_PATH" ] || [ -d "$FILE_PATH" ]; }) || return 0

    XA_OBJECT_SIZE=$(\du -0 -b -s "$FILE_PATH" 2>/dev/null | \cut -f1)
    TOTAL_FOUND_FILE_SIZE=$((TOTAL_FOUND_FILE_SIZE + XA_OBJECT_SIZE))
    TOTAL_FOUND_FILE_COUNT=$((TOTAL_FOUND_FILE_COUNT + 1))
    FOUND_APP_PATHES+=("$FILE_PATH")

    if $OPTION_RAW; then
        printf -v APP_OUTPUT_LOC "%s\n" "$FILE_PATH"
    else
        printf -v APP_OUTPUT_LOC "[$COLOR_XA_GREEN%s$COLOR_XA_RESET]: %s ($COLOR_XA_BLUE%s$COLOR_XA_RESET)\n" "$APP_NAME" "$FILE_PATH" "$(bytes_to_human_readable "$XA_OBJECT_SIZE")"
    fi

    APP_OUTPUT="$APP_OUTPUT""$APP_OUTPUT_LOC"

}

confirm_file_delete() {
    REMOVE_CONFIRMATION='n'
    $OPTION_REMOVE_ALL && warning_message && read -rep "Are you sure you want to delete this files? (y/N): " REMOVE_CONFIRMATION

    if [ "${REMOVE_CONFIRMATION,,}" == "y" ] || [ $OPTION_REMOVE_ALL_FORCE == true ]; then
        remove_application_files
    fi
}

remove_application_files() {
    APP_PATH_INDEX=0

    printf "\nStatus of removed files:\n"

    while [ $APP_PATH_INDEX -lt ${#FOUND_APP_PATHES[@]} ]; do
        APP_PATH=${FOUND_APP_PATHES[$APP_PATH_INDEX]}
        APP_PATH_INDEX=$((APP_PATH_INDEX + 1))

        rm -rf "$APP_PATH" >/dev/null 2>&1

        if [ -f "$APP_PATH" ] || [ -d "$APP_PATH" ]; then
            printf " [$COLOR_XA_RED%s$COLOR_XA_RESET] %s\n" "Failed" "$APP_PATH"
        else
            printf " [$COLOR_XA_GREEN%s$COLOR_XA_RESET] %s\n" "Success" "$APP_PATH"
        fi
    done
}

info_output() {
    printf "%b" "$APP_OUTPUT"

    if ! $OPTION_RAW; then
        printf "\n%s:\n" "Summary"
        printf " Total files: %s\n" "$TOTAL_FOUND_FILE_COUNT"
        printf " Total size: %s\n" "$(bytes_to_human_readable "$TOTAL_FOUND_FILE_SIZE")"
    fi

    if ! $OPTION_REMOVE_ALL && ! $OPTION_REMOVE_ALL_FORCE && ! $OPTION_RAW; then
        printf "\nUse %b%s --remove-all%b to remove files\n" "$COLOR_XA_BOLD" "$SCRIPT_NAME" "$COLOR_XA_RESET"
    fi
}

requirement_check() {
    check_command_available "jq" || {
        printf "$COLOR_XA_RED%b$COLOR_XA_RESET" "jq is required. Please install https://github.com/jqlang/jq\n"
        exit 1
    }

    MISSING_XDG=""
    [ -z "${HOME}" ] && MISSING_XDG=$MISSING_XDG"\n- \$HOME"
    [ -z "${XDG_DATA_HOME}" ] && MISSING_XDG=$MISSING_XDG"\n- \$XDG_DATA_HOME"
    [ -z "${XDG_CONFIG_HOME}" ] && MISSING_XDG=$MISSING_XDG"\n- \$XDG_CONFIG_HOME"
    [ -z "${XDG_STATE_HOME}" ] && MISSING_XDG=$MISSING_XDG"\n- \$XDG_STATE_HOME"
    [ -z "${XDG_CACHE_HOME}" ] && MISSING_XDG=$MISSING_XDG"\n- \$XDG_CACHE_HOME"

    if [ -n "$MISSING_XDG" ]; then
        printf "$COLOR_XA_RED%s\n\n$COLOR_XA_RESET" "Missing XDG environment variables detected."
        printf "$COLOR_XA_YELLOW%s %b$COLOR_XA_RESET\n" "Please configure the following variables in your shell configuration:" "$MISSING_XDG"

        exit 1
    fi
}

manage_flags() {
    if [ "$1" = "--raw" ]; then
        OPTION_RAW=true
    elif [ "$1" = "--remove-all" ]; then
        OPTION_REMOVE_ALL=true
    elif [ "$1" = "--remove-all-force" ]; then
        OPTION_REMOVE_ALL_FORCE=true
    elif [ -n "$1" ]; then
        print_help
        exit
    fi

}

print_help() {
    HELP_OUTPUT=$(
        cat <<END
$SCRIPT_NAME identifies and removes unused data from applications in your .cache and .config folder

$COLOR_XA_YELLOW Usage:$COLOR_XA_RESET 
    $SCRIPT_NAME [argument]

$COLOR_XA_YELLOW Arguments:$COLOR_XA_RESET 
    $COLOR_XA_GREEN-h, --help$COLOR_XA_RESET            Print this help message
    $COLOR_XA_GREEN--raw$COLOR_XA_RESET                 Outputs only pathes of files
    $COLOR_XA_GREEN--remove-all$COLOR_XA_RESET          Remove all files found
    $COLOR_XA_GREEN--remove-all-force$COLOR_XA_RESET    Remove all files without confirmation
END
    )
    printf "%b\n" "$HELP_OUTPUT"
}

check_command_available() {
    APP_COMMANDS="$1"
    APP_COMMAND_CHECK_RETURN=1

    IFS='|' read -ra APP_COMMANDS <<<"$APP_COMMANDS"

    for APP_COMMAND in "${APP_COMMANDS[@]}"; do
        command -v "$APP_COMMAND" >/dev/null 2>&1 && APP_COMMAND_CHECK_RETURN=0
    done

    return $APP_COMMAND_CHECK_RETURN
}

warning_message() {
    WARNING_MESSAGE=$(
        cat <<END
$COLOR_XA_RED
=========================================$COLOR_XA_BOLD
WARNING: DELETING FILES$COLOR_XA_RESET$COLOR_XA_RED

You are about to delete all files listed above. Please consider the following before proceeding:
$COLOR_XA_BOLD
1. DATA LOSS:$COLOR_XA_RESET$COLOR_XA_RED 
Deleting files can result in permanent data loss. Ensure you have backups of important files.
$COLOR_XA_BOLD
2. SYSTEM STABILITY:$COLOR_XA_RESET$COLOR_XA_RED
Removing files without caution may impact system or application stability.
$COLOR_XA_BOLD
3. REVIEW CAREFULLY:$COLOR_XA_RESET$COLOR_XA_RED
The detection may not always be accurate. Review the list of files to be deleted carefully.
=========================================
$COLOR_XA_RESET
END
    )
    printf "%b\n" "$WARNING_MESSAGE"
}

# https://unix.stackexchange.com/a/259254
bytes_to_human_readable() {
    local i=${1:-0} d="" s=0 S=("B" "kB" "MB" "GB" "TB")
    while ((i > 1024 && s < ${#S[@]} - 1)); do
        printf -v d ".%02d" $((i % 1024 * 100 / 1024))
        i=$((i / 1024))
        s=$((s + 1))
    done

    echo "$i$d ${S[$s]}"
}

set_global_variables() {
    APPLICATION_JSON_DIRECTORY=$(realpath "$0" | xargs dirname)"/applications"
    SCRIPT_NAME="$0"
    APP_OUTPUT=""
    FOUND_APP_PATHES=()
    TOTAL_FOUND_FILE_SIZE=0
    TOTAL_FOUND_FILE_COUNT=0
    [ -t 1 ] && OPTION_RAW=false || OPTION_RAW=true
    OPTION_REMOVE_ALL=false
    OPTION_REMOVE_ALL_FORCE=false

    COLOR_XA_RESET="\033[0m"
    COLOR_XA_BOLD="\033[1m"
    COLOR_XA_RED="\033[31m"
    COLOR_XA_GREEN="\033[32m"
    COLOR_XA_YELLOW="\033[33m"
    COLOR_XA_BLUE="\033[34m"
}

set_global_variables
requirement_check
[ $# -ne 0 ] && manage_flags "$@"
main
