#include "helper_math.h"
#include "helper_functions.h"
#include "CI/memcpy.cu"
#include "CI/cubicPrefilter3D.cu"
#include "CI/cubicTex3D.cu"

#include <cuda.h>
#include <cuda_runtime.h>
#include "helper_cuda.h"
#include "helper_functions.h"

#include <helper_cuda.h>
#include <helper_math.h>

#include "deviceVars.h"
#include "reconstruction.h"

#define PAD 3

cudaEvent_t start, stop;
float volumeTime;

typedef unsigned int  uint;
typedef unsigned char uchar;
typedef unsigned short ushort;

cudaArray *d_volumeArray = 0;
cudaArray *volumeArray = 0;
cudaArray *d_transferFuncArray;

typedef unsigned char VolumeType;
//typedef unsigned short VolumeType;

texture<VolumeType, 3, cudaReadModeNormalizedFloat> tex;         // 3D texture
texture<float4, 1, cudaReadModeElementType>         transferTex; // 1D transfer function texture
texture<float4, 1, cudaReadModeElementType>         transferTexIso;
texture<uchar, 3, cudaReadModeNormalizedFloat> tex_cubic;
//texture<ushort, 3, cudaReadModeNormalizedFloat> tex_cubic;
texture<float, 3, cudaReadModeElementType> coeffs;


typedef struct
{
	float4 m[3];
} float3x4;

__constant__ float3x4 c_invViewMatrix;  // inverse view matrix

struct Ray
{
	float3 o;   // origin
	float3 d;   // direction
};

__device__ int intersectBox(Ray r, float3 boxmin, float3 boxmax, float *tnear, float *tfar)
{
	// compute intersection of ray with all six bbox planes
	float3 invR = make_float3(1.0f) / r.d;
	float3 tbot = invR * (boxmin - r.o);
	float3 ttop = invR * (boxmax - r.o);

	// re-order intersections to find smallest and largest on each axis
	float3 tmin = fminf(ttop, tbot);
	float3 tmax = fmaxf(ttop, tbot);

	// find the largest tmin and the smallest tmax
	float largest_tmin = fmaxf(fmaxf(tmin.x, tmin.y), fmaxf(tmin.x, tmin.z));
	float smallest_tmax = fminf(fminf(tmax.x, tmax.y), fminf(tmax.x, tmax.z));

	*tnear = largest_tmin;
	*tfar = smallest_tmax;

	return smallest_tmax > largest_tmin;
}

// transform vector by matrix (no translation)
__device__ float3 mul(const float3x4 &M, const float3 &v)
{
	float3 r;
	r.x = dot(v, make_float3(M.m[0]));
	r.y = dot(v, make_float3(M.m[1]));
	r.z = dot(v, make_float3(M.m[2]));
	return r;
}

// transform vector by matrix with translation
__device__ float4 mul(const float3x4 &M, const float4 &v)
{
	float4 r;
	r.x = dot(v, M.m[0]);
	r.y = dot(v, M.m[1]);
	r.z = dot(v, M.m[2]);
	r.w = 1.0f;
	return r;
}


void setTextureFilterMode(bool bLinearFilter)
{
	tex.filterMode = bLinearFilter ? cudaFilterModeLinear : cudaFilterModePoint;
}

void initCuda(void *h_volume, cudaExtent volumeSize)
{
	// create 3D array
	cudaChannelFormatDesc channelDesc = cudaCreateChannelDesc<VolumeType>();
	checkCudaErrors(cudaMalloc3DArray(&d_volumeArray, &channelDesc, volumeSize));

	//	cudaPitchedPtr d_volumeMem;
	//	size_t size = d_volumeMem.pitch * volumeSize.height * volumeSize.depth;
	//	h_volume = (VolumeType*)malloc(size);

	// copy data to 3D array
	cudaMemcpy3DParms copyParams = {0};
	copyParams.srcPtr   = make_cudaPitchedPtr(h_volume, volumeSize.width*sizeof(VolumeType), volumeSize.width, volumeSize.height);
	copyParams.dstArray = d_volumeArray;
	copyParams.extent   = volumeSize;
	copyParams.kind     = cudaMemcpyHostToDevice;
	checkCudaErrors(cudaMemcpy3D(&copyParams));

	// set texture parameters
	tex.normalized = true;                      // access with normalized texture coordinates
	tex.filterMode = cudaFilterModeLinear;      // linear interpolation
	tex.addressMode[0] = cudaAddressModeBorder;  // clamp texture coordinates //cudaAddressModeClamp //cudaAddressModeBorder
	tex.addressMode[1] = cudaAddressModeBorder;
	tex.addressMode[2] = cudaAddressModeBorder;
	// bind array to 3D texture
	checkCudaErrors(cudaBindTextureToArray(tex, d_volumeArray, channelDesc));
	/*
    // create transfer function texture
    float4 transferFunc[] =
    {
        {  0.0, 0.0, 0.0, 0.0, },
        {  1.0, 0.0, 0.0, 1.0, },
        {  1.0, 0.5, 0.0, 1.0, },
        {  1.0, 1.0, 0.0, 1.0, },
        {  0.0, 1.0, 0.0, 1.0, },
        {  0.0, 1.0, 1.0, 1.0, },
        {  0.0, 0.0, 1.0, 1.0, },
        {  1.0, 0.0, 1.0, 1.0, },
        {  0.0, 0.0, 0.0, 0.0, },
    };
	 */
	float4 transferFunc[] =
	{
			{0.231372549,	0.298039216,	0.752941176,	0,},
			{0.266666667,	0.352941176,	0.8,	0.03125,},
			{0.301960784,	0.407843137,	0.843137255,	0.0625,},
			{0.341176471,	0.458823529,	0.882352941,	0.09375,},
			{0.384313725,	0.509803922,	0.917647059,	0.125,},
			{0.423529412,	0.556862745,	0.945098039,	0.15625,},
			{0.466666667,	0.603921569,	0.968627451,	0.1875,},
			{0.509803922,	0.647058824,	0.984313725,	0.21875,},
			{0.552941176,	0.690196078,	0.996078431,	0.25,},
			{0.596078431,	0.725490196,	1,	0.28125,},
			{0.639215686,	0.760784314,	1,	0.3125,},
			{0.682352941,	0.788235294,	0.992156863,	0.34375,},
			{0.721568627,	0.815686275,	0.976470588,	0.375,},
			{0.760784314,	0.835294118,	0.956862745,	0.40625,},
			{0.800000000,	0.850980392,	0.933333333,	0.4375,},
			{0.835294118,	0.858823529,	0.901960784,	0.46875,},
			{0.866666667,	0.866666667,	0.866666667,	0.5,},
			{0.898039216,	0.847058824,	0.819607843,	0.53125,},
			{0.925490196,	0.827450980,	0.772549020,	0.5625,},
			{0.945098039,	0.8,	0.725490196,	0.59375,},
			{0.960784314,	0.768627451,	0.678431373,	0.625,},
			{0.968627451,	0.733333333,	0.62745098,	0.65625,},
			{0.968627451,	0.694117647,	0.580392157,	0.6875,},
			{0.968627451,	0.650980392,	0.529411765,	0.71875,},
			{0.956862745,	0.603921569,	0.482352941,	0.75,},
			{0.945098039,	0.552941176,	0.435294118,	0.78125,},
			{0.925490196,	0.498039216,	0.388235294,	0.8125,},
			{0.898039216,	0.439215686,	0.345098039,	0.84375,},
			{0.870588235,	0.376470588,	0.301960784,	0.875,},
			{0.835294118,	0.31372549,	0.258823529,	0.90625,},
			{0.796078431,	0.243137255,	0.219607843,	0.9375,},
			{0.752941176,	0.156862745,	0.184313725,	0.96875,},
			{0.705882353,	0.015686275,	0.149019608,	1,}
	};
	cudaChannelFormatDesc channelDesc2 = cudaCreateChannelDesc<float4>();
	cudaArray *d_transferFuncArray;
	checkCudaErrors(cudaMallocArray(&d_transferFuncArray, &channelDesc2, sizeof(transferFunc)/sizeof(float4), 1));
	checkCudaErrors(cudaMemcpyToArray(d_transferFuncArray, 0, 0, transferFunc, sizeof(transferFunc), cudaMemcpyHostToDevice));

	transferTex.filterMode = cudaFilterModeLinear;
	transferTex.normalized = true;    // access with normalized texture coordinates
	transferTex.addressMode[0] = cudaAddressModeBorder;//cudaAddressModeClamp;   // wrap texture coordinates

	// Bind the array to the texture
	checkCudaErrors(cudaBindTextureToArray(transferTex, d_transferFuncArray, channelDesc2));

	//Creating TransferTexIso
	float4 transferFuncIso[] =
	{
			{  0.0, 1.0, 0.0, 1.0 },
			{  0.0, 1.0, 0.0, 1.0 }
	};

	cudaChannelFormatDesc channelDesc3 = cudaCreateChannelDesc<float4>();
	cudaArray *d_transferFuncArrayIso;
	checkCudaErrors(cudaMallocArray(&d_transferFuncArrayIso, &channelDesc3, sizeof(transferFuncIso)/sizeof(float4), 1));
	checkCudaErrors(cudaMemcpyToArray(d_transferFuncArrayIso, 0, 0, transferFuncIso, sizeof(transferFuncIso), cudaMemcpyHostToDevice));

	transferTexIso.filterMode = cudaFilterModeLinear;
	transferTexIso.normalized = true;    // access with normalized texture coordinates
	transferTexIso.addressMode[0] = cudaAddressModeBorder;   // wrap texture coordinates

	// Bind the array to the texture
	checkCudaErrors(cudaBindTextureToArray(transferTexIso, d_transferFuncArrayIso, channelDesc3));





}

void freeCudaBuffers()
{
	checkCudaErrors(cudaFreeArray(d_volumeArray));
	checkCudaErrors(cudaFreeArray(d_transferFuncArray));
}
//void initCudaCubicSurface(const ushort* voxels, uint3 volumeSize)
void initCudaCubicSurface(const uchar* voxels, uint3 volumeSize)
{

	// calculate the b-spline coefficients
	cudaPitchedPtr bsplineCoeffs = CastVolumeHostToDevice(voxels, volumeSize.x, volumeSize.y, volumeSize.z);
	CubicBSplinePrefilter3DTimer((float*)bsplineCoeffs.ptr, (uint)bsplineCoeffs.pitch, volumeSize.x, volumeSize.y, volumeSize.z);

	// create the b-spline coefficients texture
	cudaArray *coeffArray = 0;
	cudaExtent volumeExtent = make_cudaExtent(volumeSize.x, volumeSize.y, volumeSize.z);
	CreateTextureFromVolume(&coeffs, &coeffArray, bsplineCoeffs, volumeExtent, true);
	//    CUDA_SAFE_CALL(cudaFree(bsplineCoeffs.ptr));  //they are now in the coeffs texture, we do not need this anymore
	cudaFree(bsplineCoeffs.ptr);
	// Now create a texture with the original sample values for nearest neighbor and linear interpolation
	// Note that if you are going to do cubic interpolation only, you can remove the following code

	CreateTextureFromVolume(&tex_cubic, &volumeArray, voxels, volumeExtent, false);
	tex_cubic.addressMode[0] = cudaAddressModeBorder;
	tex_cubic.addressMode[1] = cudaAddressModeBorder;
	tex_cubic.addressMode[2] = cudaAddressModeBorder;




}

__device__ float max( float value )
{
	if( value < 0.0 )
		return 0.0;
	else
		return value;
}

__device__ uint rgbaFloatToInt(float4 rgba)
{
	rgba.x = __saturatef(rgba.x);   // clamp to [0.0, 1.0]
	rgba.y = __saturatef(rgba.y);
	rgba.z = __saturatef(rgba.z);
	rgba.w = __saturatef(rgba.w);
	return (uint(rgba.w*255)<<24) | (uint(rgba.z*255)<<16) | (uint(rgba.y*255)<<8) | uint(rgba.x*255);
}

__device__ float4 bisection(float3 start, float3 next,float3 direction, float stepSize, float isoValue)
{
	float tstep = stepSize/2;
	float3 a= start;
	float3 b = start+direction*tstep;
	float3 c = next;
	float3 point;
	float val = 0.0f;
	float temp_a = tex3D(tex, a.x , a.y , a.z ) - isoValue;
	float temp_b = tex3D(tex, b.x , b.y , b.z ) - isoValue;
	float temp_c = tex3D(tex, c.x , c.y , c.z ) - isoValue;
	int count = 0;
	float4 sample = make_float4(0.0f);

	while(count<25)
	{

		if(fabs(temp_b) <= (1e-6))
		{
			break;
		}

		if(temp_a*temp_b < 0)
		{
			tstep = tstep/2;
			c = b;
			b = a + direction * tstep;
		}
		else if(temp_b * temp_c < 0)
		{
			a = b;
			tstep = (3/4)*stepSize;
			b = a + direction*tstep;
		}
		val = tex3D(tex, b.x , b.y , b.z );
		point = b;
		if(fabs(val - isoValue)<= (1e-6))
		{
			break;
		}
		count++;
	}

	/*
         while(count<25)
    {
        if(fabs(temp_b) <= (1e-6))
        {
            break;
        }
        if(temp_a*temp_b < 0)
        {
            tstep = tstep/2;
            c = b;
            b = a + direction * tstep;
        }
        else if(temp_b * temp_c < 0)
        {
            a = b;
            tstep = (3/4)*stepSize;
            b = a + direction*tstep;
        }
        val = tex3D(tex, b.x , b.y , b.z );
        point = b;
        if(fabs(val - isoValue)<= (1e-6))
        {
            break;
        }
        count++;
    }
	 */
	sample.w = val;
	sample.x = b.x;
	sample.y = b.y;
	sample.z = b.z;

	return sample;
}



__global__ void d_render(int *d_pattern, int *linPattern, int *d_xPattern, int *d_yPattern, float *d_vol, float *d_red, float *d_green, float *d_blue, float *res_red, float *res_green, float *res_blue, int imageW, int imageH,
		float density, float brightness,float transferOffset, float transferScale, bool isoSurface, float isoValue, bool lightingCondition, bool isoLinear, float tstep,bool cubic, bool cubicLight, bool superSample, int filterMethod, float *d_temp)
{
	int maxSteps =1000;

	//    const float tstep = 0.001f;
	const float opacityThreshold = 1.00f;
	float powerFactor = 32.0f;

	float4 backGround = make_float4(1.0f);
	float4 finalSum = make_float4(0.0f);
	float4 averageSum = make_float4(0.0f);
	float4 sum, col;
	float I = 5.5f;
	float ka = 0.25f; //0.0025f;
	float I_amb = 0.2;
	float kd = 0.7;
	float I_dif;
	float ks = 0.5;
	float I_spec;
	float phong = 0.0f;
	float tstepGrad = 0.001f;
	float4 value;
	float sample;


	float x_space, y_space, z_space, x_dim, y_dim, z_dim, xAspect, yAspect, zAspect;
	x_dim = d_vol[0];
	y_dim = d_vol[1];
	z_dim = d_vol[2];

	x_space = d_vol[3];
	y_space = d_vol[4];
	z_space = d_vol[5];

	int pixel = (int)d_vol[6];
	//	brightness *= float(noRays);

	xAspect = (((x_dim - 1) * x_space)/((x_dim - 1) * x_space));
	xAspect = (((y_dim - 1) * y_space)/((x_dim - 1) * x_space));
	xAspect = (((z_dim - 1) * z_space)/((x_dim - 1) * x_space));

	//	float3 minB = (make_float3(-x_dim/x_dim, -y_dim/x_dim, -z_dim/x_dim));
	//	float3 maxB = (make_float3(x_dim/x_dim, y_dim/x_dim, z_dim/x_dim));

	float3 minB = (make_float3(-x_space, -y_space, -z_space));
	float3 maxB = (make_float3(x_space, y_space, z_space));

	const float3 boxMin = minB;//make_float3(-0.9316f, -0.9316f, -0.5f);
	const float3 boxMax = maxB;//make_float3( 0.9316f, 0.9316f, 0.5f);

	int x = blockIdx.x*blockDim.x + threadIdx.x;
	//    int y = blockIdx.y*blockDim.y + threadIdx.y;
	//	int id = blockIdx.x*blockDim.x + threadIdx.x;
	//	int y = blockIdx.y*blockDim.y + threadIdx.y;
	int id = x;// + y * imageW;
	float displaceX = 1.0/float(imageW);
	float displaceY = 1.0/float(imageH);

	int xArray[5] = {0,-1,1,1,-1};
	int yArray[5] = {0,1,1,-1,-1};


	if(id>=pixel)
		return;

	int tempLin = linPattern[id];


	float u = (d_xPattern[id]/(float)imageW)*2.0f - 1.0f;
	float v = (d_yPattern[id]/(float)imageH)*2.0f - 1.0f;

	// calculate eye ray in world space
	Ray eyeRay;
	eyeRay.o = make_float3(mul(c_invViewMatrix, make_float4(0.0f, 0.0f, 0.0f, 1.0f)));


	int noRays;
	if(superSample)
	{
		noRays = 5;
	}
	else
	{
		noRays = 1;
	}
	float4 accumulatedSum[5];
	for(int i=0; i<noRays; i++)
	{
		accumulatedSum[i]= make_float4(0.0f);
	}
	for(int i= 0; i<noRays; i++)
	{
		sum = make_float4(0.0f);
		int tempX = xArray[i];
		int tempY = yArray[i];

		eyeRay.d = normalize(make_float3(u+(displaceX*tempX)/4.0f, v+(displaceY*tempY)/4.0f, -1.0f));
		eyeRay.d = normalize(make_float3(u+(displaceX*tempX)/2.0f, v+(displaceY*tempY)/2.0f, -1.0f));
		eyeRay.d = mul(c_invViewMatrix, eyeRay.d);

		float tnear, tfar;
		int hit = intersectBox(eyeRay, boxMin, boxMax, &tnear, &tfar);


		if (!hit)
		{
			d_red[tempLin] = backGround.x;
			res_red[tempLin] = backGround.x;
			d_green[tempLin] = backGround.y;
			res_green[tempLin] = backGround.y;
			d_blue[tempLin] = backGround.z;
			res_blue[tempLin] = backGround.z;

			return;

		}
		else
		{

			float grad_x, grad_y, grad_z;


			if (tnear < 0.0f) tnear = 0.0f;     // clamp to near plane
			// march along ray from front to back, accumulating color
			float t = tnear;
			float3 pos = eyeRay.o + eyeRay.d*tnear;
			float3 step = eyeRay.d*tstep;
			col = make_float4(0.0f);
			sample = 0.0f;
			float3 next;
			float3 start, mid, end, gradPos;
			float preValue, postValue;


			bool flag = false;

			pos.x = (pos.x/x_space) * 0.5f + 0.5f;
			pos.y = (pos.y/y_space) * 0.5f + 0.5f;
			pos.z = (pos.z/z_space) * 0.5f + 0.5f;

			for (int i=0; i<maxSteps; i++)
			{
				if(lightingCondition)
				{
					isoSurface = false;
					cubic = false;
					sample = tex3D(tex, pos.x, pos.y, pos.z);
					col = tex1D(transferTex, (sample-transferOffset)*transferScale);
					gradPos.x = pos.x;
					gradPos.y = pos.y;
					gradPos.z = pos.z;

					preValue = tex3D(tex, (gradPos.x-tstepGrad), gradPos.y, gradPos.z);
					postValue = tex3D(tex, (gradPos.x+tstepGrad), gradPos.y, gradPos.z);
					grad_x = (postValue-preValue)/(2.0f*tstepGrad);

					preValue = tex3D(tex, gradPos.x, (gradPos.y-tstepGrad), gradPos.z);
					postValue = tex3D(tex, gradPos.x, (gradPos.y+tstepGrad), gradPos.z);
					grad_y = (postValue-preValue)/(2.0f*tstepGrad);

					preValue = tex3D(tex, gradPos.x, gradPos.y, (gradPos.z-tstepGrad));
					postValue = tex3D(tex, gradPos.x, gradPos.y, (gradPos.z+tstepGrad));
					grad_z = (postValue-preValue)/(2.0f*tstepGrad);

					float3 dir = normalize(eyeRay.d);
					float3 norm = normalize(make_float3(grad_x, grad_y,grad_z));
					I_dif = max(dot(norm, dir))*kd;
					float3 R = normalize(dir + (2.0 * dot(dir,norm)*norm));
					float I_spec = pow(max(dot(dir, R)), powerFactor);
					phong = clamp(I_dif + I_spec+ ka * I_amb, 0.0, 1.0);
					col.w *= density;
					col.x = I_amb* col.w  + clamp(col.w*col.x*(phong), 0.0, 1.0);
					col.y = I_amb* col.w  + clamp(col.w*col.y*(phong), 0.0, 1.0);
					col.z = I_amb* col.w  + clamp(col.w*col.z*(phong), 0.0, 1.0);

					sum = sum + col*pow((1.0f - sum.w),(0.004f/tstep));

				}
				else if(isoSurface)
				{
					lightingCondition = false;
					cubic = false;
					float temp1, temp2;
					start = pos;
					next = pos + eyeRay.d*tstep;
					float3 coord1, coord2;
					coord1.x = start.x*x_dim;
					coord1.y = start.y*y_dim;
					coord1.z = start.z*z_dim;
					coord2.x = next.x*x_dim;
					coord2.y = next.y*y_dim;
					coord2.z = next.z*z_dim;
					if(isoLinear)
					{
						temp1 = tex3D(tex, start.x , start.y , start.z );
						temp2 = tex3D(tex, next.x , next.y , next.z );
					}
					else
					{
						temp1 = cubicTex3D(tex_cubic, coord1);
						temp2 = cubicTex3D(tex_cubic, coord2);
					}

					float val1 = temp1 - isoValue;
					float val2 = temp2 - isoValue;
					if(val1*val2<0)
					{
						value = bisection(start,next,eyeRay.d,tstep,isoValue);
						sample = value.w;
						gradPos.x = value.x;
						gradPos.y = value.y;
						gradPos.z = value.z;

						flag = true;
					}
					else if(val1 == isoValue)
					{
						sample = temp1;
						gradPos.x = start.x;
						gradPos.y = start.y;
						gradPos.z = start.z;
						flag = true;
					}
					else if(val2 == isoValue)
					{
						sample = temp2;
						gradPos.x = next.x;
						gradPos.y = next.y;
						gradPos.z = next.z;
						flag = true;
					}
					if(flag)
					{
						sum = tex1D(transferTexIso, (sample-transferOffset)*transferScale);
						preValue = tex3D(tex, (gradPos.x-tstepGrad) , gradPos.y , gradPos.z );
						postValue = tex3D(tex, (gradPos.x+tstepGrad) , gradPos.y , gradPos.z );
						grad_x = (postValue-preValue)/(2*tstepGrad);

						preValue = tex3D(tex, gradPos.x , (gradPos.y-tstepGrad) , gradPos.z );
						postValue = tex3D(tex, gradPos.x , (gradPos.y+tstepGrad) , gradPos.z );
						grad_y = (postValue-preValue)/(2*tstepGrad);

						preValue = tex3D(tex, gradPos.x , gradPos.y , (gradPos.z-tstepGrad) );
						postValue = tex3D(tex, gradPos.x , gradPos.y , (gradPos.z+tstepGrad) );
						grad_z = (postValue-preValue)/(2*tstepGrad);

						float3 dir = normalize(eyeRay.d);
						float3 norm = normalize(make_float3(grad_x, grad_y,grad_z));
						//norm = normalize(mul(c_invViewMatrix, norm));
						//I_dif = fabs(dot(norm, -eyeRay.d))*kd;
						I_dif = max(dot(norm, dir))*kd;
						float3 R = normalize(dir + (2.0 * dot(dir,norm)*norm));
						float I_spec = pow(max(dot(dir, R)), powerFactor);
						//phong = clamp(I_dif + I_spec+ ka * I_amb, 0.0, 1.0);
						phong = clamp(I_dif + ka * I_amb, 0.0, 1.0);
						sum.x = (173.0/255.0)* phong;
						sum.y = (142.0/255.0) *phong;
						sum.z = (116.0/255.0) *phong;
						sum.w = 1;
						break;
					}

				}
				else if(cubic)
				{
					isoSurface = false;
					lightingCondition = false;


					float3 coord;
					coord.x = pos.x*x_dim;
					coord.y = pos.y*y_dim;
					coord.z = pos.z*z_dim;
					if(filterMethod == 1){
						sample = linearTex3D(tex_cubic, coord);
					}
					else if(filterMethod == 2){
						sample = cubicTex3D(tex_cubic, coord);
					}
					else
					{
						sample = cubicTex3D(tex_cubic, coord);
					}
					col = tex1D(transferTex, (sample - transferOffset)*transferScale);

					if(cubicLight)
					{
						gradPos.x = pos.x;
						gradPos.y = pos.y;
						gradPos.z = pos.z;


						preValue = cubicTex3D(tex_cubic, ((gradPos.x-tstepGrad))*x_dim, (gradPos.y)*y_dim, (gradPos.z)*z_dim);
						postValue = cubicTex3D(tex_cubic, ((gradPos.x+tstepGrad))*x_dim, (gradPos.y)*y_dim, (gradPos.z)*z_dim);
						grad_x = (postValue-preValue)/(2.0f*tstepGrad*x_dim);

						preValue = cubicTex3D(tex_cubic, (gradPos.x)*x_dim, ((gradPos.y-tstepGrad))*y_dim, (gradPos.z)*z_dim);
						postValue = cubicTex3D(tex_cubic, (gradPos.x)*x_dim, ((gradPos.y+tstepGrad))*y_dim, (gradPos.z)*z_dim);
						grad_y = (postValue-preValue)/(2.0f*tstepGrad*y_dim);

						preValue = cubicTex3D(tex_cubic, (gradPos.x)*x_dim, (gradPos.y)*y_dim, ((gradPos.z-tstepGrad))*z_dim);
						postValue = cubicTex3D(tex_cubic, (gradPos.x)*x_dim, (gradPos.y)*y_dim, ((gradPos.z+tstepGrad))*z_dim);
						grad_z = (postValue-preValue)/(2.0f*tstepGrad*z_dim);
						float3 dir = normalize(eyeRay.d);
						float3 norm = normalize(make_float3(grad_x, grad_y,grad_z));
						I_dif = max(dot(norm, dir))*kd;
						float3 R = normalize(dir + (2.0 * dot(dir,norm)*norm));
						float I_spec = pow(max(dot(dir, R)), powerFactor);
						phong = clamp(I_dif + I_spec+ ka * I_amb, 0.0, 1.0);
						col.w *= density;
						col.x = I_amb* col.w  + clamp(col.w*col.x*(phong), 0.0, 1.0);
						col.y = I_amb* col.w  + clamp(col.w*col.y*(phong), 0.0, 1.0);
						col.z = I_amb* col.w  + clamp(col.w*col.z*(phong), 0.0, 1.0);

					}
					else
					{
						col.w *= density;
						col.x *= col.w;
						col.y *= col.w;
						col.z *= col.w;

					}

					sum = sum + col*pow((1.0f - sum.w), (0.004f/tstep));

				}
				else
				{
					sample = tex3D(tex, pos.x, pos.y, pos.z);
					col = tex1D(transferTex, (sample-transferOffset)*transferScale);
					col.w *= density;
					col.x *= col.w;
					col.y *= col.w;
					col.z *= col.w;
					sum = sum + col*pow((1.0f - sum.w),(0.004f/tstep));

				}

				if (sum.w > opacityThreshold)
				{
					break;
				}

				t += tstep;

				if (t > tfar) break;

				pos += step;
			}
			sum *= brightness;
			sum = sum + backGround * (1.0f - sum.w);

			accumulatedSum[i] = sum;
		}

	}
//	sum *= brightness;
	for(int i=0; i<noRays; i++)
	{
		finalSum += accumulatedSum[i];
	}
	averageSum = finalSum/float(noRays);



	d_red[tempLin] = averageSum.x;
	res_red[tempLin] = averageSum.x;
	d_green[tempLin] = averageSum.y;
	res_green[tempLin] = averageSum.y;
	d_blue[tempLin] = averageSum.z;
	res_blue[tempLin] = averageSum.z;
}



void render_kernel(dim3 gridSize, dim3 blockSize,int *d_pattern, int *linPattern, int *d_xPattern, int *d_yPattern, float *d_vol, float *d_red, float *d_green, float *d_blue,
		float *res_red, float *res_green, float *res_blue, float *device_x, float *device_p, int imageW, int imageH, float density, float brightness, float transferOffset,
		float transferScale,bool isoSurface, float isoValue, bool lightingCondition, bool isoLinear, float tstep, bool cubic, bool cubicLight, bool superSample, int filterMethod, float *d_temp)
{
	//	cudaEventCreate(&start);
	//	cudaEventRecord(start,0);
	d_render<<<gridSize, 256>>>(d_pattern, linPattern, d_xPattern, d_yPattern, d_vol, d_red, d_green, d_blue,res_red, res_green, res_blue,
			imageW, imageH, density, brightness, transferOffset, transferScale, isoSurface, isoValue, lightingCondition, isoLinear, tstep, cubic, cubicLight, superSample, filterMethod, d_temp);
	cudaDeviceSynchronize();

}
//d_output, d_vol, res_red, res_green, res_blue, imageW, imageH, d_xPattern, d_yPattern, d_linear
__global__ void blend(bool reconstruction, uint *d_output,float *d_vol, float *res_red, float *res_green, float *res_blue, int imageW, int imageH, float *d_red, float *d_green, float *d_blue)
{

	int x = blockIdx.x*blockDim.x + threadIdx.x;
	int y = blockIdx.y*blockDim.y + threadIdx.y;
	if((x>=imageW)||(y>=imageH))
		return;

	int index = x + y * imageW;

	float4 temp = make_float4(0.0f);

	if(reconstruction)
	{
		temp.x = res_red[index];
		temp.y = res_green[index];
		temp.z = res_blue[index];
	}
	else
	{
		temp.x = d_red[index];
		temp.y = d_green[index];
		temp.z = d_blue[index];

	}

	d_output[index] = rgbaFloatToInt(temp);



}
//    blendFunction(gridVol, blockSize, d_output,d_vol, res_red, res_green, res_blue, height, width, d_xPattern, d_yPattern, d_linear);
void blendFunction(dim3 grid, dim3 block, bool reconstruction, uint *d_output, float *d_vol, float *res_red, float *res_green, float *res_blue, int imageH, int imageW, float *d_red, float *d_green, float *d_blue)
{
	//	 blend<<<grid, block>>>(d_output, res_red, res_green, res_blue, imageW, imageH);
	blend<<<grid, block>>>(reconstruction, d_output, d_vol, res_red, res_green, res_blue, imageW, imageH, d_red, d_green, d_blue);
}

/*
void reconstructionFunction(dim3 grid, dim3 block, float *data, float *red, float *green, float *blue,
 		int *pattern, float *kernel, float *d_result,float *red_res, float *green_res, float *blue_res,
 		int maskH, int maskW, int dataH, int dataW, float *device_x, float *device_p)
 */


void copyInvViewMatrix(float *invViewMatrix, size_t sizeofMatrix)
{
	checkCudaErrors(cudaMemcpyToSymbol(c_invViewMatrix, invViewMatrix, sizeofMatrix));
}

