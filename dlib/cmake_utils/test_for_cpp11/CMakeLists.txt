
cmake_minimum_required(VERSION 2.8.12)
project(cpp11_test)

# Try to enable C++11
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
if(COMPILER_SUPPORTS_CXX11)
   message(STATUS "C++11 activated.")
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11") # [IGE]: fix '-std=c++11' not allowed with 'C/ObjC'
elseif(COMPILER_SUPPORTS_CXX0X)
   message(STATUS "C++0x activated.")
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x") # [IGE]: fix '-std=c++11' not allowed with 'C/ObjC'
endif()

add_library(cpp11_test STATIC cpp11_test.cpp )
