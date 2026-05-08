project("BAQVerification")
cmake_minimum_required(VERSION 3.22)
set(CMAKE_CXX_STANDARD 20)
add_executable(test)
target_sources(test PRIVATE "test.cpp" "models/baq_compressor.cpp" "models/baq_decompressor.cpp" "models/baq_fixed_point.cpp")
target_include_directories(test PRIVATE "models")
target_compile_definitions(test PRIVATE
    LUT_DIR="${CMAKE_CURRENT_SOURCE_DIR}/models/baq_compressor_lut"
    DECOMP_LUT_DIR="${CMAKE_CURRENT_SOURCE_DIR}/models/baq_decompressor_lut"
)