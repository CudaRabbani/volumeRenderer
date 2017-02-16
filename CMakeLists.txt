cmake_minimum_required(VERSION 2.8.12)
project(volumeRenderer)

find_package(PkgConfig REQUIRED)
find_package(OpenGL REQUIRED)
find_package(CUDA QUIET REQUIRED)

include_directories(
common/inc
/usr/include
cuda_src
cpp_src
)
set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};-gencode arch=compute_50,code=sm_50)
set ( CMAKE_BUILD_TYPE Debug)

set (CUDA_SRC 
	cuda_src/kernel.cu
	cuda_src/reconstructionkernel.cu
 )
 
 set ( CPP_SRC
 	cpp_src/main.cpp
 )
 
  set ( CPP_HPP
    cpp_src/header.h
    cuda_src/kernel.h
    cuda_src/reconstruction.h
 )

# Specify binary name and source file to build it from
cuda_add_executable(
    volumeRenderer
	${CUDA_SRC}
    ${CPP_SRC}	
	${CPP_HPP}
    )
    
 target_link_libraries(volumeRenderer
     GL GLU GLEW glut
     ${ALL_LIBS}   
 )    
     
     
     
     
     