/*
 * kernel.h
 *
 *  Created on: Jan 30, 2017
 *      Author: reza
 */

#ifndef KERNEL_H_
#define KERNEL_H_







void setTextureFilterMode(bool bLinearFilter);
void initCuda(void *h_volume, cudaExtent volumeSize);
void freeCudaBuffers();
void render_kernel(dim3 gridSize, dim3 blockSize, int *d_pattern, int *d_xPattern, int *d_yPattern, float *d_vol, float *d_red, float *d_green, float *d_blue,
float *res_red, float *res_green, float *res_blue, float *device_x, float *device_p, int imageW, int imageH, float density, float brightness, float transferOffset,
float transferScale,bool isoSurface, float isoValue, bool lightingCondition, float tstep, bool cubic, int filterMethod);
void copyInvViewMatrix(float *invViewMatrix, size_t sizeofMatrix);
void blendFunction(dim3 grid, dim3 block,uint *d_output, float *res_red, float *res_green, float *res_blue, int imageH, int imageW);
//void initPixelBuffer();


void initCudaCubicSurface(const uchar* voxels, uint3 volumeSize);








#endif /* KERNEL_H_ */
