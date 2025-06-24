#!/bin/bash
set -e
EXTRA_FLAGS=$1

CI_PROJECT_DIR=$(pwd)

build_dir="${CI_PROJECT_DIR}/build"
INCLUDE_DIR="${CI_PROJECT_DIR}/include"
INCLUDE_CORE_DIR="${CI_PROJECT_DIR}/include/core"
rm -rf $build_dir

mkdir -p "${build_dir}"
export LD_LIBRARY_PATH="$build_dir"
cd ${build_dir}

# Example:
# ./gcc_build_and_run_uit.sh "-fprofile-arcs -ftest-coverage -fPIC -O0"

echo "# 1. Compile the library:"
SOURCE_CORE="\
    ${CI_PROJECT_DIR}/src/core/barebone_TDD.cpp \
"

OBJECT_CORE="\
    ${build_dir}/barebone_TDD.o \
"

echo "Compiling libbarebone-tdd.so library.."
cmd="g++ --std=c++17 -c -Wall -Werror -fpic ${EXTRA_FLAGS} \
     -I${INCLUDE_DIR} -I${INCLUDE_CORE_DIR} ${SOURCE_CORE}"
echo "${cmd}"
eval "${cmd}"

cmd="g++ --shared -o $build_dir/libbarebone-tdd.so ${OBJECT_CORE}"
echo "${cmd}"
eval "${cmd}"
echo "Compiling barebone-tdd library.."

echo "# 2. Compile Integration test linked to the library:"
cmd="g++ -Wall -o $build_dir/barebone_tdd_integration \
     ${SOURCE_CORE} \
     ${CI_PROJECT_DIR}/test/uit/run_integration.cpp \
     -I${INCLUDE_DIR} -I${INCLUDE_CORE_DIR} -lbarebone-tdd -L$build_dir ${EXTRA_FLAGS}"
echo "${cmd}"
eval "${cmd}"

echo "Running barebone_tdd_integration test runner.."
$build_dir/barebone_tdd_integration

echo "# 3. Compile Stand-Alone executable:"
cmd="g++ -Wall -o $build_dir/run-barebone-tdd \
     ${SOURCE_CORE} \
     ${CI_PROJECT_DIR}/src/main_barebone_TDD.cpp \
    -I${INCLUDE_DIR} -I${INCLUDE_CORE_DIR} ${EXTRA_FLAGS}"
echo "${cmd}"
eval "${cmd}"
echo "Running run-barebone-tdd.."

if [ -f "${build_dir}/run-barebone-tdd" ]; then
    ${build_dir}/run-barebone-tdd
else
    echo "Failed: cannot find ${build_dir}/run-barebone-tdd"
fi

echo "Complete"