cmake_minimum_required(VERSION 3.16)
project(lab02)
set(CMAKE_CXX_STANDARD 14)


find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)


FLEX_TARGET(Lexer src/lexer.l ${CMAKE_CURRENT_BINARY_DIR}/lexer.cpp)
BISON_TARGET(Parser src/grammar.y ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp)
ADD_FLEX_BISON_DEPENDENCY(Lexer Parser)


include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${PROJECT_SOURCE_DIR}/src
    ${PROJECT_SOURCE_DIR}/include
)


add_executable(Compilerlab4
    src/main.cpp
    src/utils.cpp
    src/codegen.cpp
    src/symbol_table.cpp
    ${FLEX_Lexer_OUTPUTS}
    ${BISON_Parser_OUTPUTS}
)


target_link_libraries(Compilerlab4
    PRIVATE
    ${BISON_LIBRARIES}
)


target_compile_options(Compilerlab4
    PRIVATE
    -pedantic
)
