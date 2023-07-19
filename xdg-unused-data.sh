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

    ([ -n "$APP_OUTPUT" ] && print_info_output ) || ($OPTION_RAW || printf "No files found\n")
}

check_application() {
    APP_NAME="$1"
    APP_EXECUTABLE="$2"
    FILE_PATH=$(echo "$3" | envsubst)

    # Skip if executable and file or folder doesn't exists
    (! check_command_available "$APP_EXECUTABLE" && { [ -f "$FILE_PATH" ] || [ -d "$FILE_PATH" ]; }) || return 0

    OBJECT_SIZE=$(\du -0 -b -s "$FILE_PATH" 2>/dev/null | \cut -f1)
    TOTAL_FOUND_FILE_SIZE=$((TOTAL_FOUND_FILE_SIZE + OBJECT_SIZE))
    TOTAL_FOUND_FILE_COUNT=$((TOTAL_FOUND_FILE_COUNT + 1))

    if $OPTION_RAW; then
        printf -v APP_OUTPUT_LOC "%s\n" "$FILE_PATH"
    else
        printf -v APP_OUTPUT_LOC "[$COLOR_XA_GREEN%s$COLOR_XA_RESET]: %s ($COLOR_XA_BLUE%s$COLOR_XA_RESET)\n" "$APP_NAME" "$FILE_PATH" "$(bytes_to_human_readable "$OBJECT_SIZE")"
    fi

    APP_OUTPUT="$APP_OUTPUT""$APP_OUTPUT_LOC"
}

print_info_output() {
    printf "%b" "$APP_OUTPUT"

    if ! $OPTION_RAW; then
        printf "\n%s:\n" "Summary"
        printf " Total files: %s\n" "$TOTAL_FOUND_FILE_COUNT"
        printf " Total size: %s\n" "$(bytes_to_human_readable "$TOTAL_FOUND_FILE_SIZE")"
    fi
}

requirement_check() {
    check_command_available "jq" || {
        printf "$COLOR_XA_RED%b$COLOR_XA_RESET" "jq is required. Please install https://github.com/jqlang/jq\n"
        exit 1
    }

    MISSING_XDG=""
    [ -z "${XDG_DATA_HOME+x}" ] && MISSING_XDG=$MISSING_XDG"\n- \$XDG_DATA_HOME" && XDG_DATA_HOME=$HOME"/"
    [ -z "${XDG_CONFIG_HOME+x}" ] && MISSING_XDG=$MISSING_XDG"\n- \$XDG_CONFIG_HOME" && XDG_CONFIG_HOME=$HOME"/.config"
    [ -z "${XDG_STATE_HOME+x}" ] && MISSING_XDG=$MISSING_XDG"\n- \$XDG_STATE_HOME" && XDG_STATE_HOME=$HOME"/.local/state"
    [ -z "${XDG_CACHE_HOME+x}" ] && MISSING_XDG=$MISSING_XDG"\n- \$XDG_CACHE_HOME" && XDG_CACHE_HOME=$HOME"/.cache"

    if [ -n "$MISSING_XDG" ]; then
        printf "$COLOR_XA_YELLOW%s\n\n%s%b\n\n$COLOR_XA_RESET" "Some xdg-basedir envirnoment variables are not defined. Fallbacks will be used!" "Missing:" "$MISSING_XDG"
    fi
}

manage_flags() {
    if [ "$1" = "--raw" ]; then
        OPTION_RAW=true
    elif [ -n "$1" ]; then
        print_help
        exit
    fi
}

print_help() {
    HELP_OUTPUT=$(
        cat <<END
A simple way to identify and remove unused data from applications stored in user directories

USAGE:
    $SCRIPT_NAME [argument]

ARGUMENTS:
    -h, --help    Print this help message
    --raw         Outputs only pathes of files
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
    TOTAL_FOUND_FILE_SIZE=0
    TOTAL_FOUND_FILE_COUNT=0
    [ -t 1 ] && OPTION_RAW=false || OPTION_RAW=true

    COLOR_XA_RESET="\033[0m"
    COLOR_XA_RED="\033[31m"
    COLOR_XA_GREEN="\033[32m"
    COLOR_XA_YELLOW="\033[33m"
    COLOR_XA_BLUE="\033[34m"
}

set_global_variables
requirement_check
[ $# -ne 0 ] && manage_flags "$@"
main
