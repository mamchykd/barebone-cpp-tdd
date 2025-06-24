#!/bin/bash
set -e
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

echo "Running clang-tidy.."

build_dir="${top_dir}/build"

directories_to_analyze="\
    include/*\
    src/*\
    src/core/*\
"

header_pattern="'(/include/)'"

if [ ! -f $build_dir/compile_commands.json ]; then
    echo "$build_dir/compile_commands.json not found!"
    echo "Run the command to create compile database: "
    echo "./build.sh"
    exit 1;
fi

# Disable exit on error temporarily
set +e
# You need `clang-tidy-8` or higher to run these successfully
cmd="run-clang-tidy \
    -j$(nproc) \
    -p=$build_dir \
    -header-filter=$header_pattern \
    -quiet\
    -style\
    files $directories_to_analyze\
    -extra-arg="-I/usr/include"\
    | grep -e \": error:\" -e \": warning:\" -A3"

echo $cmd
eval $cmd
no_warnings_found=$?

# Bring exit on error back
set -e
cd "${cur_dir}"

if [ $no_warnings_found -eq 0 ]; then
    echo "Warnings found! Please fix them. Exit 1"
    exit 1
else
    echo "Congrats! No warnings found. Exit 0"
fi
exit 0
