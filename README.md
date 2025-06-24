# Barebone Cpp TDD Template

## The repo

    [TDD template for CMake-based C++ projects](https://github.com/mamchykd/barebone-cpp-tdd)


## Dependencies

    $ sudo apt-get install cmake
    $ sudo apt-get install clang-format 
    $ sudo apt install clang-tidy
    $ sudo apt-get install cppcheck
    $ sudo apt-get install cpputest
    $ sudo apt-get install gcovr


## Build the project

    $ ./build.sh


## Build project with coverage

    $ ./build.sh --run-coverage


## Build the project and install library, headers and binary

    $ ./build.sh --run-install

    NOTE:
    The files are installed into ./install local folder by default
    To set a different location, use --cmake-options flag:

    $ ./build.sh --run-install 



## Build with gcc
  
    ./gcc_build_and_run_uit.sh


## Build and run unit tests

    $ ./build.sh --run-tests

    The path the unit test binary:
    ./build/barebone_tdd_test

    Dependencies:
    sudo apt-get install cpputest

    NOTE: CppUTest has a nice memory leak detection feature


## Run integration tests

    The integration tests are built along with the unit tests by the command:
    $ ./build.sh --run-tests

    The path the integration test binary:
    $ ./build/barebone_tdd_integration


## Run clang-tidy checker

    $ ./build.sh
    $ ./run_clang_tidy.sh

    NOTE: the script needs ./build/compile_commands.json produced by build.sh


## Run gcovr checker

    $ ./build.sh --run-coverage

    To see a gcovr report outside of the build script, run:
    $ gcovr --exclude build --exclude CMakeFiles
