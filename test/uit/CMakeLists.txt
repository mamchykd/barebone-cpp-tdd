cmake_minimum_required(VERSION 3.2.0)
project (BareboneTDDIntegration)
set(CMAKE_CXX_STANDARD 17)

include_directories("${CMAKE_SOURCE_DIR}/include")

if (BUILD_TESTING)
    add_executable(barebone_tdd_integration run_integration.cpp)
    set_target_properties(barebone_tdd_integration PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    target_link_libraries(barebone_tdd_integration "${CMAKE_SOURCE_DIR}/build/lib${CORE_LIB_NAME}.so")

    enable_testing()
    add_test(NAME BareboneTDDIntegration COMMAND barebone_tdd_integration)
endif()
