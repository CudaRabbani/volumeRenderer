/*
 * header.h
 *
 *  Created on: Jan 30, 2017
 *      Author: reza
 */

#ifndef HEADER_H_
#define HEADER_H_


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>


#include <GL/glew.h>
#if defined (__APPLE__) || defined(MACOSX)
  #pragma clang diagnostic ignored "-Wdeprecated-declarations"
  #include <GLUT/glut.h>
  #ifndef glutCloseFunc
  #define glutCloseFunc glutWMCloseFunc
  #endif
#else
#include <GL/freeglut.h>
#endif

#include <cuda_runtime.h>
#include <cuda_gl_interop.h>
#include <vector_types.h>
#include <vector_functions.h>
#include <driver_functions.h>

#include <helper_cuda.h>
#include <helper_functions.h>
#include <helper_timer.h>
#include <unistd.h>

typedef unsigned int uint;
typedef unsigned char uchar;


const char *sSDKsample = "Volume Rendering Project with Reconstruction";


cudaExtent volumeSize;
typedef unsigned char VolumeType;
int width, height;
int pixelCount;
int *d_pattern, *h_pattern;
int *xPattern, *yPattern;
int *d_xPattern, *d_yPattern;
float *d_red, *d_green, *d_blue, *d_opacity;
float *in_red, *in_green, *in_blue;
float *res_red, *res_green, *res_blue, *res_opacity;
float *recon_red, *recon_green, *recon_blue;
float *h_vol, *d_vol;

dim3 blockSize;//(16, 16);
dim3 gridSize;
dim3 gridVol;
dim3 gridBlend;

int blocksX, blocksY, blockXsize, blockYsize;
int kernelH, kernelW;

float *device_x, *device_p;
bool run;
int frameCounter;


float3 viewRotation;
float3 viewTranslation = make_float3(0.0, 0.0, -4.0f);
float invViewMatrix[12];
int ox, oy;
int buttonState = 0;


float density = 1.00f;
float brightness = 1.0f;
float transferOffset = 0.0f;
float transferScale = 1.0f;
bool linearFiltering = true;
float tstep = 0.001f;
float tstepGrad = 0.01f;
bool lightingCondition = false;
bool isoSurface = false;
float isoValue = 0.498;
bool hq = false;
int filterMethod = 0;



GLuint pbo = 0;     // OpenGL pixel buffer object
GLuint tex = 0;     // OpenGL texture object
struct cudaGraphicsResource *cuda_pbo_resource; // CUDA Graphics Resource (to transfer PBO)

StopWatchInterface *timer = 0;

// Auto-Verification Code
const int frameCheckNumber = 2;
int fpsCount = 0;        // FPS count for averaging
int fpsLimit = 1;        // FPS limit for sampling
int g_Index = 0;
unsigned int frameCount = 0;

int *pArgc;
char **pArgv;

#ifndef MAX
#define MAX(a,b) ((a > b) ? a : b)
#endif


using namespace std;



void initPixelBuffer();




#endif /* HEADER_H_ */
