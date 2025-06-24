cmake_minimum_required(VERSION 3.2.0)
set(CMAKE_CXX_STANDARD 17)

set(CORE_PROJECT_NAME BareboneTD)
set(CORE_LIB_NAME barebone-tdd)
set(CORE_APP_NAME run-barebone-tdd)
set(BIN_DESTINATION bin)

project ($CORE_PROJECT_NAME)

if(CMAKE_EXPORT_COMPILE_COMMANDS)
    set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
endif()

set(CORE_SOURCES_LIST
    src/core/barebone_TDD.cpp
)

set(CORE_HEADERS_LIST
    include/core/barebone_TDD.h
)


# NOTE: Simple but not a preferable way
# include_directories("${CMAKE_SOURCE_DIR}/include" "${CMAKE_SOURCE_DIR}/include/core")

# shared library
add_library("${CORE_LIB_NAME}" SHARED ${CORE_SOURCES_LIST})
target_include_directories("${CORE_LIB_NAME}" PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

# project main
add_executable("${CORE_APP_NAME}" ${CORE_SOURCES_LIST} src/main_barebone_TDD.cpp)
target_include_directories("${CORE_APP_NAME}" PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

# unit tests
if(NOT SKIP_EXTERNAL_TESTS)
    if(BUILD_TESTING)
        enable_testing()
    endif()

    # enable ctest support
    include(CTest)

    add_subdirectory(test)
endif()

# install project outputs
if (PERFORM_INSTALL)
    message(STATUS "CMake starts installing ${CORE_PROJECT_NAME} files to the specified locations..")

    #install(TARGETS "${CORE_LIB_NAME}" DESTINATION "lib/${CORE_LIB_NAME}")
    install(FILES "${CORE_HEADERS_LIST}" DESTINATION "include/${CORE_LIB_NAME}")

    # Install library
    install(TARGETS "${CORE_LIB_NAME}"
        LIBRARY DESTINATION "lib/${CORE_LIB_NAME}" # for shared libs (.so)
        INCLUDES DESTINATION "include/${CORE_LIB_NAME}"
    )

    # Install executable
    install(TARGETS "${CORE_APP_NAME}"
        RUNTIME DESTINATION "${BIN_DESTINATION}"
    )
endif()