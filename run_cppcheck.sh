
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

source_dir="${top_dir}/src"

suppressions_file="cppcheck_suppressions_list.txt"

# Disable exit on error temporarily
set +e

cppcheck_options="-v --error-exitcode=1 --inconclusive --enable=all --inline-suppr "
cmd="cppcheck --suppressions-list=$suppressions_file --std=c11 $cppcheck_options -I${top_dir}/include . "
echo $cmd
eval $cmd
ret_code=$?

# Bring exit on error back
set -e

cd "${cur_dir}"
if [ ! $ret_code -eq 0 ]; then
    echo "Warnings found! Please fix them"
    exit 1
else
    echo "Congrats! No warnings found. Exit 0"
fi
exit 0
