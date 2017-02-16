/*
 * deviceVars.h
 *
 *  Created on: Feb 8, 2017
 *      Author: reza
 */

#ifndef DEVICEVARS_H_
#define DEVICEVARS_H_



extern int width, height;
extern int pixelCount;
extern int *d_pattern, *h_pattern;
extern int *xPattern, *yPattern;
extern int *d_xPattern, *d_yPattern;
extern float *d_red, *d_green, *d_blue, *d_opacity;
extern float *in_red, *in_green, *in_blue;
extern float *res_red, *res_green, *res_blue, *res_opacity;
extern float *recon_red, *recon_green, *recon_blue;


#endif /* DEVICEVARS_H_ */
