#!/bin/bash
echo "Check clang-format.."

cur_dir=$(pwd)
script_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $script_path
top_dir=$(pwd)

# NOTE: CI_PROJECT_DIR predefined variable might come from GitLab CI
if [ ! -z $CI_PROJECT_DIR ]; then
    top_dir=$CI_PROJECT_DIR
fi
cd $top_dir
# echo "top_dir: $top_dir"

# Option flag
IN_PLACE="False"
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --in-place)
        IN_PLACE="True"
        shift # past argument
        ;;
        --help)
        echo "Example: ./run_clang_format.sh [--in-place] [--help] [whatever options are supported by clang-format] "
        exit 0
        ;;
        *)
    esac
done

OPTIONS="$@"

scanned_folder="$top_dir"
set -e

folders=("include" "src")
extensions=("c" "cpp" "h" "hh" "hpp")

FILES=()
for folder in "${folders[@]}"; do
  for ext in "${extensions[@]}"; do
    while IFS= read -r -d $'\0' file; do
      FILES+=("$file")
    done < <(find "$folder" -type f -name "*.${ext}" -print0)
  done
done

needs_formatting=()
for file in "${FILES[@]}"; do
  if [ "${IN_PLACE}" = "True" ]; then
    clang-format $OPTIONS -style=file -i "$file"
  else
    if ! diff_output=$(clang-format $OPTIONS -style=file "$file" | diff -q "$file" - > /dev/null); then
      needs_formatting+=("$file")
    fi
  fi
done

if [[ "${IN_PLACE}" = "False" ]]; then
  if [ ${#needs_formatting[@]} -eq 0 ]; then
    echo "All files are properly formatted"
  else
    echo "Some files need formatting:"
    for f in "${needs_formatting[@]}"; do
      echo "  $f"
    done
    echo "Run with '--in-place' to apply formatting. Exit 1"
    exit 1
  fi
fi
cd "${cur_dir}"
echo "Done"
