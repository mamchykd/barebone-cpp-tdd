cmake_minimum_required(VERSION 3.2.0)
project (BareboneTDD_test)
set(CMAKE_CXX_STANDARD 17)

if (BUILD_TESTING)
    set(CPPUTEST_LDFLAGS CppUTest CppUTestExt)
    if(DEFINED ENV{CPPUTEST_HOME})
        message(STATUS "Using CppUTest home: $ENV{CPPUTEST_HOME}")
        set(CPPUTEST_INCLUDE_DIRS $ENV{CPPUTEST_HOME}/include)
        set(CPPUTEST_LIBRARIES $ENV{CPPUTEST_HOME}/lib)
    else()
        find_package(PkgConfig REQUIRED)
        pkg_search_module(CPPUTEST REQUIRED cpputest>=3.8)
        message(STATUS "Found CppUTest version ${CPPUTEST_VERSION}")
        set(CPPUTEST_INCLUDE_DIRS /usr/include/CppUTest)
        set(CPPUTEST_LIBRARIES /usr/lib/x86_64-linux-gnu)
    endif()

    include_directories("${CPPUTEST_INCLUDE_DIRS}" "${CMAKE_SOURCE_DIR}/include")
    link_directories(${CPPUTEST_LIBRARIES})

    # Test
    add_executable(barebone_tdd_test barebone_TDD_test.cpp run_all_tests.cpp)
    set_target_properties(barebone_tdd_test PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    target_link_libraries(barebone_tdd_test "${CMAKE_SOURCE_DIR}/build/libbarebone-tdd.so" ${CPPUTEST_LDFLAGS})

    enable_testing()
    add_test(NAME BareboneTDD_test COMMAND barebone_tdd_test)

endif()
