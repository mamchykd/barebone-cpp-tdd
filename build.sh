#!/bin/bash

cur_dir=$(pwd)
script_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $script_path
top_dir=$(pwd)
cd $top_dir
# echo "top_dir: $top_dir"

enable_install="False"
enable_testing="False"
enable_coverage="False"
clean_only="False"
other_cmake_options=""

build_type="Debug"

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --run-install)
    enable_install="True"
    shift # past argument
    ;;
    --run-coverage)
    enable_coverage="True"
    enable_testing="True"
    shift # past argument
    ;;
    --run-tests)
    enable_testing="True"
    shift # past argument
    ;;
    --clean-only)
    clean_only="True"
    shift # past argument
    ;;
    --cmake-options)
    other_cmake_options=$2
    shift # past argument
    shift # past value
    ;;
    --help)
    echo "Run the script: ${0} [--run-install] [--enable-coverage] [--run-tests] [--clean-only] [--cmake-options] [--help]"
    echo ""
    echo "--run-install: The library will be installed into ./install/barebone-tdd subfolder of the repo."
    echo "               To install into other location, run with argument:"
    echo "               --cmake-options=-DCMAKE_INSTALL_PREFIX:PATH=<your install dir>"
    exit 0
    ;;
    *)
    echo "Unrecognized argument: $key"
    exit 1
esac
done 

build_dir="${top_dir}/build"
install_dir="install"
TARGET=all

echo "Cleaning up.."
source "${top_dir}/clean_cache.sh"
rm -rf "${build_dir}/*"
rm -rf "${build_dir}"
rm -rf "${install_dir}"
mkdir -p "${build_dir}"
mkdir -p "${install_dir}"

if [ "${clean_only}" = "True" ]; then
echo "Clean complete."
exit 0
fi

CMAKE_EXTRA_ARGS="-DCMAKE_INSTALL_PREFIX:PATH=${install_dir} -DCMAKE_BUILD_TYPE=${build_type}"

if [ -n "$CMAKE_INITIAL_CACHE" ]; then
CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -C $CMAKE_INITIAL_CACHE"
fi

if [ "${enable_coverage}" = "True" ]; then
export CXXFLAGS="--coverage "
fi

if [ "${enable_testing}" = "True" ]; then
CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DBUILD_TESTING=ON"
fi

if [ "${enable_install}" = "True" ]; then
CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DPERFORM_INSTALL=ON"
fi

if [ ! -z "${other_cmake_options}" -a "${other_cmake_options}" != "" ]; then
CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} ${other_cmake_options}"
fi


echo "CMake Extra Args: ${CMAKE_EXTRA_ARGS}"
cmake $CMAKE_EXTRA_ARGS -B $build_dir .


cmake --build $build_dir $CMAKE_BUILD_EXTRA_ARGS

# Create a compilation database
echo "Create a compilation database from: $(pwd)"
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .
mv ${top_dir}/compile_commands.json "${build_dir}"


if [ "${enable_testing}" == "True" ]; then
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


if [ "${enable_install}" == "True" ]; then
echo "Installing.."
# cmake --install $build_dir
cmake --install $build_dir --config $build_type
fi

if [ "${enable_coverage}" == "True" ]; then
gcovr --exclude build --exclude CMakeFiles
fi

cd "${cur_dir}"
echo "Complete."
