#!/bin/bash

cur_dir=$(pwd)
script_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $script_path
top_dir=$(pwd)
cd $top_dir
# echo "top_dir: $top_dir"

run_install="False"
run_uninstall="False"
run_tests="False"
run_coverage="False"
run_cleanup="False"
other_cmake_options=""


build_type="Debug"
build_dir="${top_dir}/build"
install_dir="install"

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --run-cleanup)
    run_cleanup="True"
    shift # past argument
    ;;
    --run-tests)
    run_tests="True"
    shift # past argument
    ;;
    --run-coverage)
    run_coverage="True"
    run_tests="True"
    shift # past argument
    ;;
    --run-install)
    run_install="True"
    shift # past argument
    ;;
    --run-uninstall)
    run_uninstall="True"
    shift # past argument
    shift # past value
    ;;
    --cmake-options)
    other_cmake_options=$2
    shift # past argument
    shift # past value
    ;;
    --help)
    echo "Run the script:  ${0} [--run-install] [--run-coverage] [--run-tests] [--clean-only] [--cmake-options] [--help]"
    echo ""
    echo "Arguments description:"
    echo ""
    echo "--run-cleanup:"
    echo "              Only delete temporary build files."
    echo ""
    echo "--run-tests:"
    echo "              Run unit and integration tests."
    echo ""
    echo "--run-coverage:"
    echo "              Run the tests and show coverage report."
    echo ""
    echo "--run-install:"
    echo "              The library will be installed into ./install subfolder of the repo."
    echo "              To install into a different location, run with --cmake-options argument as described below."
    echo ""
    echo "--run-uninstall <installation folder>:"
    echo "              The library will be uninstalled from the specified folder."
    echo "              Example:"
    echo "              --run-uninstall /usr"
    echo ""
    echo "--cmake-options <your options>:"
    echo "              Pass additional space-separate cmake options prefixed with -D."
    echo "              --cmake-options=\"-DCMAKE_INSTALL_PREFIX:PATH=\<your install dir\> -DCMAKE_PROJECT_NAME=\<alternative name of the project\>"
    echo "              Example:"
    echo "              --cmake-options=\"-DCMAKE_INSTALL_PREFIX:PATH=install2 -DCMAKE_PROJECT_NAME=plain-tdd\""
    exit 0
    ;;
    *)
    echo "Unrecognized argument: $key"
    exit 1
esac
done 

TARGET=all

echo "Cleaning up.."
source "${top_dir}/clean_cache.sh"
rm -rf "${build_dir}/*"
rm -rf "${build_dir}"
rm -rf "${install_dir}"
mkdir -p "${build_dir}"
mkdir -p "${install_dir}"

if [ "${run_cleanup}" = "True" ]; then
echo "Clean complete."
exit 0
fi

default_cmake_args="-DCMAKE_INSTALL_PREFIX:PATH=${install_dir} -DCMAKE_BUILD_TYPE=${build_type}"

if [ -n "${CMAKE_INITIAL_CACHE}" ]; then
further_cmake_args="${further_cmake_args} -C $CMAKE_INITIAL_CACHE"
fi

if [ "${run_coverage}" = "True" ]; then
export CXXFLAGS="--coverage "
fi

if [ "${run_tests}" = "True" ]; then
further_cmake_args="${further_cmake_args} -DBUILD_TESTING=ON"
fi

if [ "${run_install}" = "True" ]; then
further_cmake_args="${further_cmake_args} -DPERFORM_INSTALL=ON"
fi

cmake_extra_args=""
if [ ! -z "${other_cmake_options}" -a "${other_cmake_options}" != "" ]; then
cmake_extra_args="${further_cmake_args} ${other_cmake_options}"
else
cmake_extra_args="${default_cmake_args} ${further_cmake_args} "
fi

echo "CMake Extra Args: ${cmake_extra_args}"
cmake $cmake_extra_args -B $build_dir .

cmake --build $build_dir $CMAKE_BUILD_EXTRA_ARGS

# Create a compilation database
echo "Create a compilation database from: $(pwd)"
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .
mv ${top_dir}/compile_commands.json "${build_dir}"


if [ "${run_tests}" == "True" ]; then
    # Run unit tests
    export GTEST_OUTPUT="xml:$(pwd)/test_results/"
    cd $build_dir
    ctest
    cd ..
    echo "${0##*/} UT COMPLETE"
    # Run unit integration tests
    if [ -f "${build_dir}/barebone_tdd_integration" ]; then
        ${build_dir}/barebone_tdd_integration
    else
        echo "UIT Test failed: cannot find ${build_dir}/barebone_tdd_integration"
        return 1
    fi
    echo "${0##*/} UIT COMPLETE"
fi


if [ "${run_install}" == "True" ]; then
echo "Installing.."
# cmake --install $build_dir
cmake --install $build_dir --config $build_type
fi

if [ "${run_coverage}" == "True" ]; then
gcovr --exclude build --exclude CMakeFiles
fi

cd "${cur_dir}"
echo "Complete."
