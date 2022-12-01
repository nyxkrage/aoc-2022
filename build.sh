#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
declare -a YASM_FLAGS
YASM_FLAGS=(-f elf64 -g dwarf2)
declare -a LIBRARIES
declare -a POSITIONAL_ARGS
declare -a PASSTHROUGH_ARGS

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)"

# Parse arguments

print_list() {
  declare -a EXECUTABLES
  for DAY_DIR in "$SCRIPTPATH"/day*; do
    DAY=$(basename "$DAY_DIR")
    mkdir -p "$SCRIPTPATH/build/$DAY"
    for DAY_PART in "$DAY_DIR"/*.asm; do
      PART=$(basename "$DAY_PART" .asm)
      EXECUTABLES+=("$DAY/$PART")
    done
  done
  echo "Available executables:"

  for EXECUTABLE in "${EXECUTABLES[@]}"; do
    echo "  $EXECUTABLE"
  done

}

print_version() {
  cat <<HELP
build.sh 1.0.0
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
HELP
}

print_help() {
  cat <<HELP
Usage: $0 [options]*

Options:
    -h|--help               print this help text
    -v|--version            print version and licensing text
    -l|--list               list available executables
    -r|--run <executable>   run the exectuable directly (day1/part1)
    -g|--debug <executable> start gdb with the executable (day1/part1)
    -d|--dry-run            just print commands that would be executed
    -c|--clean              clean up build artifacts

HELP
}

clean_build() {
  rm -rf build/*
}

while [[ $# -gt 0 ]]; do
  if [[ -n ${PASSTHROUGH+x} ]]; then
    PASSTHROUGH_ARGS+=("$1") # save passthrough arg
    shift                    # past argument
  else
    case $1 in
    -r | --run)
      RUN="$2"
      RUNNER=""
      shift # past argument
      shift # past value
      ;;
    -g | --debug)
      RUN="$2"
      RUNNER="gdb"
      shift # past argument
      shift # past value
      ;;
    -d | --dry-run)
      DRY_RUN="TRUE"
      shift # past argument
      ;;
    -c | --clean)
      clean_build
      exit 0
      ;;
    -l | --list)
      print_list
      exit 1
      ;;
    -v | --version)
      print_version
      exit 1
      ;;
    -h | --help)
      print_help
      exit 1
      ;;
    --)
      PASSTHROUGH="TRUE"
      shift
      ;;
    -*)
      echo "Unknown option $1"
      print_help
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift                   # past argument
      ;;
    esac
  fi
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# Assemble Library files

mkdir -p "$SCRIPTPATH/build/lib"
for LIB_PATH in "$SCRIPTPATH"/lib/*; do
  LIB=$(basename "$LIB_PATH" .asm)
  LIBRARIES+=("$SCRIPTPATH/build/lib/$LIB.o")
  echo yasm "${YASM_FLAGS[@]}" -l "$SCRIPTPATH/build/lib/$LIB.lst" -o "$SCRIPTPATH/build/lib/$LIB.o" "$LIB_PATH"
  if [[ -z "${DRY_RUN+x}" ]]; then
    yasm "${YASM_FLAGS[@]}" -l "$SCRIPTPATH/build/lib/$LIB.lst" -o "$SCRIPTPATH/build/lib/$LIB.o" "$LIB_PATH"
  fi
done

# Assemble Solutions

for DAY_DIR in "$SCRIPTPATH"/day*; do
  DAY=$(basename "$DAY_DIR")
  mkdir -p "$SCRIPTPATH/build/$DAY"
  for DAY_PART in "$DAY_DIR"/*.asm; do
    PART=$(basename "$DAY_PART" .asm)
    echo yasm "${YASM_FLAGS[@]}" -l "$SCRIPTPATH/build/$DAY/$PART.lst" -o "$SCRIPTPATH/build/$DAY/$PART.o" "$DAY_PART"
    if [[ -z "${DRY_RUN+x}" ]]; then
      yasm "${YASM_FLAGS[@]}" -l "$SCRIPTPATH/build/$DAY/$PART.lst" -o "$SCRIPTPATH/build/$DAY/$PART.o" "$DAY_PART"
    fi
  done
done

# Linking

for DAY_DIR in "$SCRIPTPATH/build"/day*; do
  DAY=$(basename "$DAY_DIR")
  for DAY_PART in "$DAY_DIR"/*.o; do
    PART=$(basename "$DAY_PART" .o)
    echo ld -o "$SCRIPTPATH/build/$DAY/$PART" "$DAY_PART" "${LIBRARIES[@]}"
    if [[ -z "${DRY_RUN+x}" ]]; then
      ld -o "$SCRIPTPATH/build/$DAY/$PART" "$DAY_PART" "${LIBRARIES[@]}"
    fi
  done
done

if [[ -n "${RUN+x}" ]]; then
  if [[ -f "$SCRIPTPATH/build/$RUN" ]]; then
    echo "$RUNNER $SCRIPTPATH/build/$RUN" "${PASSTHROUGH_ARGS[@]}"
    if [[ -z "${DRY_RUN+x}" ]]; then
      exec $RUNNER "$SCRIPTPATH/build/$RUN" "${PASSTHROUGH_ARGS[@]}"
    fi
  else
    echo "$SCRIPTPATH/build/$RUN does not exist"
    exit 1
  fi
fi
