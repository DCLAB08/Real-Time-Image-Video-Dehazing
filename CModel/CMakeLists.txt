cmake_minimum_required( VERSION 2.8 )
project( dehaze )

set( CMAKE_BUILD_TYPE "Release" )
set( CMAKE_CXX_FLAGS "-std=c++11 -O3" )

find_package( OpenCV 4.5 REQUIRED )

include_directories( 
    ${OpenCV_INCLUDE_DIRS} 
    ${G2O_INCLUDE_DIRS}
    ${CSPARSE_INCLUDE_DIR}
    "/usr/include/eigen3/"
)

add_executable( dehaze frank.cpp  )
target_link_libraries( dehaze ${OpenCV_LIBS} )
