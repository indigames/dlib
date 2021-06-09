
CMAKE_MINIMUM_REQUIRED(VERSION 2.8.12)
project(dlib_python_bindings)

if(DEFINED ANDROID_PLATFORM)
    set (ANDROID 1)
    if(ANDROID_ABI STREQUAL "armeabi-v7a")
        add_compile_options(-marm -march=armv7-a -mtune=cortex-a15 -mfpu=neon-fp16 -mfloat-abi=softfp)
    elseif(ANDROID_ABI STREQUAL "x86")
        add_compile_options(-march=atom -m32 -msse -msse2 -msse3 -mssse3 -mfpmath=sse -mstackrealign)
    elseif(ANDROID_ABI STREQUAL "arm64-v8a")
        add_compile_options(-march=armv8-a+simd+sve -mtune=cortex-a53 -D__ARM_NEON -D__ARM_NEON__)
    elseif(ANDROID_ABI STREQUAL "x86_64")
        add_compile_options(-march=atom -m64 -msse -msse2 -msse3 -mssse3 -msse4.1 -msse4.2 -mfpmath=sse)
    endif()
    if(CMAKE_BUILD_TYPE STREQUAL "Release")
        add_compile_options(-g0 -Ofast)
    else(CMAKE_BUILD_TYPE STREQUAL "Debug")
        add_compile_options(-Og)
    endif()
elseif(MSVC)
    add_compile_options(/MP)
elseif(IOS)
    if(CMAKE_BUILD_TYPE STREQUAL "Release")
        add_compile_options(-g0 -Ofast)
    endif()
endif()
# [/IGE]

# [IGE]: build static python binding
find_package(Python REQUIRED)
set (PYTHON_INCLUDE_DIRS "${Python_INCLUDE_DIRS}")
set(DLIB_NO_GUI_SUPPORT ON)
# [/IGE]

# Pybind11's cmake scripts enable link time optimization by default.  However,
# it makes linking take a really long time and doesn't seem to substantively
# improve runtime performance.  So we disable LTO here to make building dlib
# faster.
set(PYBIND11_LTO_CXX_FLAGS "")


# Avoid cmake warnings about changes in behavior of some Mac OS X path 
# variable we don't care about.
if (POLICY CMP0042)
    cmake_policy(SET CMP0042 NEW)
endif()


# To avoid dll hell, always link everything statically when compiling in
# visual studio.  This way, the resulting library won't depend on a bunch
# of other dll files and can be safely copied to someone else's computer
# and expected to run.
# [IGE]: REM THIS, should use default to link with other libs
# if (MSVC)
    # include(${CMAKE_CURRENT_LIST_DIR}/../../dlib/cmake_utils/tell_visual_studio_to_use_static_runtime.cmake)
# endif()
# [/IGE]

# [IGE]: use latest pybind11
find_package(pybind11 REQUIRED)
add_subdirectory("${pybind11_INCLUDE_DIR}/.." pybind11_build)
add_subdirectory(../../dlib dlib_build)
# [/IGE]

if (USING_OLD_VISUAL_STUDIO_COMPILER)
   message(FATAL_ERROR "You have to use a version of Visual Studio that supports C++11.  As of December 2017, the only versions that have good enough C++11 support to compile the dlib Python API is a fully updated Visual Studio 2015 or a fully updated Visual Studio 2017.  Older versions of either of these compilers have bad C++11 support and will fail to compile the Python extension. ***SO UPDATE YOUR VISUAL STUDIO TO MAKE THIS ERROR GO AWAY***")
endif()


add_definitions(-DDLIB_VERSION=${DLIB_VERSION})

# Tell cmake to compile all these cpp files into a dlib python module.
set(python_srcs
   src/dlib.cpp
   src/matrix.cpp
   src/vector.cpp
   src/svm_c_trainer.cpp
   src/svm_rank_trainer.cpp
   src/decision_functions.cpp
   src/other.cpp
   src/basic.cpp
   src/cca.cpp
   src/sequence_segmenter.cpp
   src/svm_struct.cpp
   src/image.cpp
   src/image2.cpp
   src/image3.cpp
   src/image4.cpp
   src/rectangles.cpp
   src/object_detection.cpp
   src/shape_predictor.cpp
   src/correlation_tracker.cpp
   src/face_recognition.cpp
   src/cnn_face_detector.cpp
   src/global_optimization.cpp
   src/image_dataset_metadata.cpp
   src/numpy_returns.cpp
   src/line.cpp
)

# Only add the GUI module if requested
if(NOT ${DLIB_NO_GUI_SUPPORT})
   list(APPEND python_srcs src/gui.cpp)
endif()

# [IGE]: if not defined python.exe, then build static
if (DEFINED PYTHON_EXECUTABLE)
   pybind11_add_module(dlib_python ${python_srcs})
   target_link_libraries(dlib_python PRIVATE dlib::dlib)
   # Set the output library name to dlib because that's what setup.py and distutils expects.
   set_target_properties(dlib_python PROPERTIES OUTPUT_NAME dlib)
else()
   pybind11_add_module(dlib_python STATIC ${python_srcs})
   target_link_libraries(dlib_python PRIVATE dlib::dlib)
endif()
# [/IGE]

