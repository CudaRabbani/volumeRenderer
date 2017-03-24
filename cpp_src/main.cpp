#include "header.h"
#include "kernel.h"
#include "reconstruction.h"
#include "deviceVars.h"

#define CudaCheckError() __cudaCheckError( __FILE__, __LINE__ )

#define CHECK(call)

#define MAX_EPSILON_ERROR 5.00f
#define THRESHOLD 0.30f

float *temp_red, *temp_green, *temp_blue;
cudaEvent_t volStart, volEnd;
float volTime;



inline void __cudaCheckError( const char *file, const int line )
{
//#ifdef CUDA_ERROR_CHECK
    cudaError err = cudaGetLastError();
    if ( cudaSuccess != err )
    {
        fprintf( stderr, "cudaCheckError() failed at %s:%i : %s\n",
                 file, line, cudaGetErrorString( err ) );
        //exit( -1 );
    }

    // More careful checking. However, this will affect performance.
    // Comment away if needed.
    err = cudaDeviceSynchronize();
    if( cudaSuccess != err )
    {
        fprintf( stderr, "cudaCheckError() with sync failed at %s:%i : %s\n",
                 file, line, cudaGetErrorString( err ) );
        exit( -1 );
    }
//#endif

    return;
}

void writeOutputReconstruction(float *red, float *green, float *blue)
{
	FILE *R, *G, *B;

	R = fopen("textFiles/redOutRecon.txt","w");
	G = fopen("textFiles/greenOutRecon.txt","w");
	B = fopen("textFiles/blueOutRecon.txt","w");

	for(int i=0; i< width* height; i++)
	{
		fprintf(R, "%f\n", red[i]);
		fprintf(G, "%f\n", green[i]);
		fprintf(B, "%f\n", blue[i]);
	}
	fclose(R);
	fclose(G);
	fclose(B);
//	printf("Output writing done for reconstruction of: %d %d\n", width, height);


}

void writeOutputVolume(float *red, float *green, float *blue)
{
	FILE *R, *G, *B;

	R = fopen("textFiles/redOutVol.txt","w");
	G = fopen("textFiles/greenOutVol.txt","w");
	B = fopen("textFiles/blueOutVol.txt","w");
	for(int i=0; i< width* height; i++)
	{
		fprintf(R, "%f\n", red[i]);
		fprintf(G, "%f\n", green[i]);
		fprintf(B, "%f\n", blue[i]);
	}
	fclose(R);
	fclose(G);
	fclose(B);
//	printf("From writeOutput: %d %d\n", width, height);

}

void loadFiles(float *in_red, float *in_green, float *in_blue)
{

//	printf("File Loading For Reconstruction\n");
	FILE *R, *G, *B;
	R = fopen("textFiles/redOutVol.txt", "r");
	G = fopen("textFiles/greenOutVol.txt", "r");
	B = fopen("textFiles/blueOutVol.txt", "r");
	for(int i= 0; i<width*height; i++)
	{
		fscanf(R, "%f", &in_red[i]);
		fscanf(G, "%f", &in_green[i]);
		fscanf(B, "%f", &in_blue[i]);
	}
//	printf("File loading done\n");

}

void loadPattern(int *h_pattern,int *h_linear, int *xPattern, int *yPattern, int gH, int gW, int pixelCount)
{
	FILE *pattern, *X, *Y, *patternInfo, *test, *linPatternInfo;
	char H[5], W[5];
	char path[50] = "textFiles/Pattern/";
	char linCoord[15] = "_ptrnIdx.txt";
	char xCoord[15]= "Xcoord.txt";
	char yCoord[15]= "Ycoord.txt";
	char xFile[60] = "";
	char yFile[60] = "";
	char linFile[60]= "";
	char dimX[10];
	char dimY[10];
	sprintf(dimY,"%d", gH);
	sprintf(dimX,"%d", gW);
	strcat(dimY,"by");
	strcat(dimY,dimX);
	strcat(path,dimY);
	strcat(path,"/"); //path = textFiles/Pattern/516by516/
	char patternName[50] = "";
	char name[50] = "";
	char ext[5] = ".txt";
	sprintf(H, "%d", gH);
	sprintf(W, "%d", gW);
	strcat(name,H);
	strcat(name,"by");
	strcat(name,W);
	char patternFile[70] = "";
	strcat(patternFile,path);
	strcat(patternFile,name);
	strcat(patternFile,ext);
//	printf("Input: %s\n", patternFile);
	char lin[70]="";
	strcat(lin,path);
	strcat(lin,dimY);
	strcat(lin,linCoord);
//	strcat(lin);
//	printf("Linear Pattern File: %s\n", lin);
	strcat(xFile,path);
	strcat(xFile,name);
	strcat(xFile,xCoord);
//	printf("X-COORD: %s\t", xFile);
	strcat(yFile,path);
	strcat(yFile,name);
	strcat(yFile,yCoord);
//	printf("Y-COORD: %s\n", yFile);
	char info[70] = "";
	strcat(info,path);
	strcat(info,name);
	strcat(info,"_patternInfo.txt");

	pattern = fopen(patternFile, "r");
	X = fopen(xFile, "r");
	Y = fopen(yFile, "r");
	patternInfo = fopen(info, "r");
	linPatternInfo = fopen(lin,"r");
//	printf("Pattern Info: %s\n", info);


	if(!X || !Y || !linPatternInfo)
	{
		fprintf(stderr, "Error in opening pattern file for X or Y or linear Pattern index\n");
	}
	else{
		for(int i = 0; i<pixelCount; i++)
		{
			fscanf(X, "%d", &xPattern[i]);
			fscanf(Y, "%d", &yPattern[i]);
			fscanf(linPatternInfo, "%d", &h_linear[i]);
		}
//		printf("Pattern reading for x and y coords done\n");
	}
	if(!pattern)
	{
		fprintf(stderr, "Error in opening pattern file\n");
	}
	else{
		printf("Loading Pattern\n");
		for(int i=0;i <gH*gW; i++)
		{
			fscanf(pattern, "%d", &h_pattern[i]);
		}
	}
	fclose(pattern);
	fclose(patternInfo);
	fclose(linPatternInfo);
	fclose(X);
	fclose(Y);

	printf("Pattern loading complete for %d by %d image\n", gH, gW);
}

void outputTest(float *test)
{
	FILE *f = fopen("textFiles/testOutput.txt","w");

	for(int i= 0; i<pixelCount; i++)
	{
		fprintf(f, "%f\n", test[i]);
	}
	fclose(f);
}

int iDivUp(int a, int b)
{
    return (a % b != 0) ? (a / b + 1) : (a / b);
}

void computeFPS()
{

    frameCount++;
    fpsCount++;
    char fps[256];
    /*
    fpsTimer = glutGet(GLUT_ELAPSED_TIME);
    if(fpsTimer - timerBase > 1000)
    {
    	sprintf(fps, "Volume Render: %3.1f fps", frameCount * 1000.0/(fpsTimer - timerBase));
    	glutSetWindowTitle(fps);
    	timerBase = fpsTimer;
    	frameCount = 0;
    }
*/


    if (fpsCount == fpsLimit)
    {
        char fps[256];
        float ifps = 1.f / (sdkGetAverageTimerValue(&timer) / 1000.f);
        sprintf(fps, "Volume Render: %3.1f fps", ifps);

        glutSetWindowTitle(fps);
        fpsCount = 0;

        fpsLimit = (int)MAX(1.f, ifps);
        sdkResetTimer(&timer);
    }

}

// render image using CUDA
void render()
{
    copyInvViewMatrix(invViewMatrix, sizeof(float4)*3);

    // map PBO to get CUDA device pointer
    uint *d_output;
    // map PBO to get CUDA device pointer
    checkCudaErrors(cudaGraphicsMapResources(1, &cuda_pbo_resource, 0));
    size_t num_bytes;
    checkCudaErrors(cudaGraphicsResourceGetMappedPointer((void **)&d_output, &num_bytes, cuda_pbo_resource));
    //printf("CUDA mapped PBO: May access %ld bytes\n", num_bytes);

    // clear image
    checkCudaErrors(cudaMemset(d_output, 0, width*height*sizeof(float)));

    blendFunction(gridBlend, blockSize, d_output,d_vol, res_red, res_green, res_blue, height, width, d_xPattern, d_yPattern, d_linear);
    cudaDeviceSynchronize();
    CudaCheckError();
 /*
    void reconstructionFunction(dim3 grid, dim3 block, float *red, float *green, float *blue, int *pattern, float *red_res, float *green_res, float *blue_res,
     		int dataH, int dataW, float *device_x, float *device_p);
*/


    getLastCudaError("kernel failed");

    checkCudaErrors(cudaGraphicsUnmapResources(1, &cuda_pbo_resource, 0));
    cudaDeviceSynchronize();
//	}
//	run = false;
}

// display results using OpenGL (called by GLUT)
void display()
{
    sdkStartTimer(&timer);

    // use OpenGL to build view matrix
    GLfloat modelView[16];
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();
//    glScalef(1.0, 1.0, 2.0);
    glRotatef(-viewRotation.x, 1.0, 0.0, 0.0);
    glRotatef(-viewRotation.y, 0.0, 1.0, 0.0);
    glTranslatef(-viewTranslation.x, -viewTranslation.y, -viewTranslation.z);
    glGetFloatv(GL_MODELVIEW_MATRIX, modelView);
    glPopMatrix();

    invViewMatrix[0] = modelView[0];
    invViewMatrix[1] = modelView[4];
    invViewMatrix[2] = modelView[8];
    invViewMatrix[3] = modelView[12];
    invViewMatrix[4] = modelView[1];
    invViewMatrix[5] = modelView[5];
    invViewMatrix[6] = modelView[9];
    invViewMatrix[7] = modelView[13];
    invViewMatrix[8] = modelView[2];
    invViewMatrix[9] = modelView[6];
    invViewMatrix[10] = modelView[10];
    invViewMatrix[11] = modelView[14];
/*
    cudaMemcpy(d_red, temp,sizeof(float)*width*height, cudaMemcpyHostToDevice);
    cudaMemcpy(d_green, temp,sizeof(float)*width*height, cudaMemcpyHostToDevice);
    cudaMemcpy(d_blue, temp,sizeof(float)*width*height, cudaMemcpyHostToDevice);
    cudaMemcpy(res_red, temp,sizeof(float)*width*height, cudaMemcpyHostToDevice);
    cudaMemcpy(res_green, temp,sizeof(float)*width*height, cudaMemcpyHostToDevice);
    cudaMemcpy(res_blue, temp,sizeof(float)*width*height, cudaMemcpyHostToDevice);
*/
//    render_kernel(gridVol, blockSize, d_pattern, d_linear, d_xPattern, d_yPattern, d_vol, d_red, d_green, d_blue, res_red, res_green, res_blue, device_x, device_p,
//			width, height, density, brightness, transferOffset, transferScale, isoSurface, isoValue, lightingCondition, tstep, cubic, filterMethod,d_temp);
    /*
    render_kernel(gridVol, blockSize,d_pattern, d_linear, d_xPattern, d_yPattern, d_vol, d_red, d_green, d_blue, res_red, res_green, res_blue, device_x, device_p,
    			width, height, density, brightness, transferOffset, transferScale, isoSurface, isoValue, lightingCondition, tstep, cubic, filterMethod,d_temp);

	reconstructionFunction(gridSize, blockSize, d_red, d_green, d_blue, d_pattern, res_red, res_green, res_blue, height, width, device_x, device_p);
*/
    render_kernel(gridVol, blockSize,d_pattern, d_linear, d_xPattern, d_yPattern, d_vol, d_red, d_green, d_blue, res_red, res_green, res_blue, device_x, device_p,
       			width, height, density, brightness, transferOffset, transferScale, isoSurface, isoValue, lightingCondition, tstep, cubic, cubicLight, filterMethod,d_temp);


//   	reconstructionFunction(gridSize, blockSize, d_red, d_green, d_blue, d_pattern, res_red, res_green, res_blue, height, width, device_x, device_p);
//   	cudaDeviceSynchronize();
   	render();
    // display results
//    glClear(GL_COLOR_BUFFER_BIT);
//    glClearColor(0.0f, 0.0f, 0.0f, 1.0);

    // draw image from PBO
    glDisable(GL_DEPTH_TEST);

    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
#if 0
    // draw using glDrawPixels (slower)
    glRasterPos2i(0, 0);
    glBindBufferARB(GL_PIXEL_UNPACK_BUFFER_ARB, pbo);
    glDrawPixels(width, height, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    glBindBufferARB(GL_PIXEL_UNPACK_BUFFER_ARB, 0);
#else
    // draw using texture

    std::vector<GLubyte> emptyData(width * height * 4, 0);
    glBindTexture(GL_TEXTURE_2D, tex);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_BGRA, GL_UNSIGNED_BYTE, &emptyData[0]);

    // copy from pbo to texture
    glBindBufferARB(GL_PIXEL_UNPACK_BUFFER_ARB, pbo);
    glBindTexture(GL_TEXTURE_2D, tex);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    glBindBufferARB(GL_PIXEL_UNPACK_BUFFER_ARB, 0);

    // draw textured quad
    glPushMatrix();
    glTranslatef(viewTranslation.x, viewTranslation.y, viewTranslation.z);
    glRotatef(viewRotation.y, 0.0f, 1.0f, 0.0f);
    glTranslatef(-viewTranslation.x, -viewTranslation.y, -viewTranslation.z);
    glPopMatrix();
    glEnable(GL_TEXTURE_2D);
    glBegin(GL_QUADS);
    glTexCoord2f(0, 0);
    glVertex2f(0, 0);
    glTexCoord2f(1, 0);
    glVertex2f(1, 0);
    glTexCoord2f(1, 1);
    glVertex2f(1, 1);
    glTexCoord2f(0, 1);
    glVertex2f(0, 1);
    glEnd();
    viewRotation.y += 5.0f;
    glDisable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, 0);

#endif

    glutSwapBuffers();
    glutReportErrors();

    sdkStopTimer(&timer);

    computeFPS();
}

void idle()
{
    glutPostRedisplay();
}

void keyboard(unsigned char key, int x, int y)
{
    switch (key)
    {
        case 27:
            #if defined (__APPLE__) || defined(MACOSX)
                exit(EXIT_SUCCESS);
            #else
                glutDestroyWindow(glutGetWindow());
                return;
            #endif
            break;

        case 'f':
            linearFiltering = !linearFiltering;
            setTextureFilterMode(linearFiltering);
            break;

        case '+':
            density += 0.01f;
            break;

        case '-':
            density -= 0.01f;
            break;

        case ']':
            brightness += 0.1f;
            break;

        case '[':
            brightness -= 0.1f;
            break;

        case ';':
            transferOffset += 0.01f;
            break;

        case '\'':
            transferOffset -= 0.01f;
            break;

        case '.':
            transferScale += 0.01f;
            break;

        case ',':
            transferScale -= 0.01f;
            break;

        case 'l':
        	lightingCondition = !lightingCondition;
        	break;

        case 'i':
        	isoSurface = !isoSurface;
        	break;
        case '>':
        	isoValue += 0.005f;
        	break;
        case '<':
        	isoValue -= 0.005f;
        	break;
        case 'S':
        	tstep += 0.0001f;
        	break;
        case 's':
        	tstep -= 0.0001f;
        	break;
        case 'Q':
        	cubic = !cubic;
        	break;
        case 'q':
        	cubicLight = !cubicLight;
        	break;
        case '1':
        	filterMethod = 1;
        	break;
        case '2':
			filterMethod = 2;
			break;
        default:
            break;
    }

    printf("dens = %.2f, brightness = %.2f, transferOffset = %.2f, transferScale = %.2f, isoValue: %.3f \n", density, brightness, transferOffset, transferScale, isoValue);
    glutPostRedisplay();
}

void mouse(int button, int state, int x, int y)
{
    if (state == GLUT_DOWN)
    {
        buttonState  |= 1<<button;
    }
    else if (state == GLUT_UP)
    {
        buttonState = 0;
    }

    ox = x;
    oy = y;
    glutPostRedisplay();
}

void motion(int x, int y)
{
    float dx, dy;
    dx = (float)(x - ox);
    dy = (float)(y - oy);

    if (buttonState == 4)
    {
        // right = zoom
        viewTranslation.z += dy / 100.0f;
    }
    else if (buttonState == 2)
    {
        // middle = translate
        viewTranslation.x += dx / 100.0f;
        viewTranslation.y -= dy / 100.0f;
    }
    else if (buttonState == 1)
    {
        // left = rotate
        viewRotation.x += dy / 5.0f;
        viewRotation.y += dx / 5.0f;
    }

    ox = x;
    oy = y;
    glutPostRedisplay();
}

void reshape(int w, int h)
{
    width = w;
    height = h;
    initPixelBuffer();

    // calculate new grid size
//    gridSize = dim3(iDivUp(width, blockSize.x), iDivUp(height, blockSize.y));
    gridSize = dim3(blocksX, blocksY);
//    gridVol = dim3(iDivUp(width,blockXsize), iDivUp(height,blockYsize));
//    gridVol = dim3(iDivUp(ceil(sqrt(pixelCount)),blockXsize), iDivUp(ceil(sqrt(pixelCount)),blockYsize));
    gridVol = dim3(iDivUp(pixelCount,256));
    gridBlend = dim3(iDivUp(width,blockXsize), iDivUp(height,blockYsize));
//    gridSize = dim3(iDivUp(pixelCount, blockSize.x), iDivUp(pixelCount, blockSize.y));
//    gridVol = dim3(iDivUp(sqrt(pixelCount),blockXsize), iDivUp(sqrt(pixelCount),blockYsize));
    glViewport(0, 0, w, h);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0.0, 1.0, 0.0, 1.0, 0.0, 1.0);
}

void cleanup()
{
    sdkDeleteTimer(&timer);

    freeCudaBuffers();

    if (pbo)
    {
        cudaGraphicsUnregisterResource(cuda_pbo_resource);
        glDeleteBuffersARB(1, &pbo);
        glDeleteTextures(1, &tex);
    }
    // cudaDeviceReset causes the driver to clean up all state. While
    // not mandatory in normal operation, it is good practice.  It is also
    // needed to ensure correct operation when the application is being
    // profiled. Calling cudaDeviceReset causes all profile data to be
    // flushed before the application exits
    cudaDeviceReset();
}

void initGL(int *argc, char **argv)
{
    // initialize GLUT callback functions
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE);
    glClearColor(0.0,0.0,0.0,1.0);
    glutInitWindowSize(width, height);
    glutCreateWindow("CUDA volume rendering");

    glewInit();

    if (!glewIsSupported("GL_VERSION_2_0 GL_ARB_pixel_buffer_object"))
    {
        printf("Required OpenGL extensions missing.");
        exit(EXIT_SUCCESS);
    }
}

void initPixelBuffer()
{
    if (pbo)
    {
        // unregister this buffer object from CUDA C
        checkCudaErrors(cudaGraphicsUnregisterResource(cuda_pbo_resource));

        // delete old buffer
        glDeleteBuffersARB(1, &pbo);
        glDeleteTextures(1, &tex);
    }

    // create pixel buffer object for display
    glGenBuffersARB(1, &pbo);
    glBindBufferARB(GL_PIXEL_UNPACK_BUFFER_ARB, pbo);
    glBufferDataARB(GL_PIXEL_UNPACK_BUFFER_ARB, width*height*sizeof(GLubyte)*4, 0, GL_STREAM_DRAW_ARB);
    glBindBufferARB(GL_PIXEL_UNPACK_BUFFER_ARB, 0);

    // register this buffer object with CUDA
    checkCudaErrors(cudaGraphicsGLRegisterBuffer(&cuda_pbo_resource, pbo, cudaGraphicsMapFlagsWriteDiscard));

    // create texture for display
    glGenTextures(1, &tex);
    glBindTexture(GL_TEXTURE_2D, tex);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glBindTexture(GL_TEXTURE_2D, 0);
}

// Load raw data from disk
void *loadRawFile(char *filename, size_t size)
{
    FILE *fp = fopen(filename, "rb");

    if (!fp)
    {
        fprintf(stderr, "Error opening file '%s'\n", filename);
        return 0;
    }

    void *data = malloc(size);
    size_t read = fread(data, 1, size, fp);
    fclose(fp);

#if defined(_MSC_VER_)
    printf("Read '%s', %Iu bytes\n", filename, read);
#else
    printf("Read '%s', %zu bytes\n", filename, read);
#endif

    return data;
}


void loadKernel(float *kernel, float lambda, int length)
{

    kernel[0] = 0.0001;
    kernel[1] = 0.0099;
    kernel[2] = -0.0793;
    kernel[3] = -0.0280;
    kernel[4] = -0.0793;
    kernel[5] = 0.0099;
    kernel[6] = 0.0001;
    kernel[7] = 0.0099;
    kernel[8] = -0.1692;
    kernel[9] = 0.6540;
    kernel[10] = 1.0106;
    kernel[11] = 0.6540;
    kernel[12] = -0.1692;
    kernel[13] = 0.0099;
    kernel[14] = -0.0793;
    kernel[15] = 0.6540;
    kernel[16] = 0.1814;
    kernel[17] = -8.0122;
    kernel[18] = 0.1814;
    kernel[19] = 0.6540;
    kernel[20] = -0.0793;
    kernel[21] = -0.0280;
    kernel[22] = 1.0106;
    kernel[23] = -8.0122;
    kernel[24] = 23.3926;
    kernel[25] = -8.0122;
    kernel[26] = 1.0106;
    kernel[27] = -0.0280;
    kernel[28] = -0.0793;
    kernel[29] = 0.6540;
    kernel[30] = 0.1814;
    kernel[31] = -8.0122;
    kernel[32] = 0.1814;
    kernel[33] = 0.6540;
    kernel[34] = -0.0793;
    kernel[35] = 0.0099;
    kernel[36] = -0.1692;
    kernel[37] = 0.6540;
    kernel[38] = 1.0106;
    kernel[39] = 0.6540;
    kernel[40] = -0.1692;
    kernel[41] = 0.0099;
    kernel[42] = 0.0001;
    kernel[43] = 0.0099;
    kernel[44] = -0.0793;
    kernel[45] = -0.0280;
    kernel[46] = -0.0793;
    kernel[47] = 0.0099;
    kernel[48] = 0.0001;
//    kernel[49] = 0.0001;

    for(int i=0;i<length; i++)
    {
        kernel[i] = kernel[i]* lambda;
    }

    initializeConvolutionFilter(kernel, length);

}

int main(int argc, char **argv)
{
	FILE *volumeInfo, *patternInfo;
	char volName[50];
	char patternInformation[100] = "textFiles/Pattern/";

	char H[15], W[15];

	int volXdim, volYdim, volZdim; //Volume Size in each directions
	int dataH, dataW, GW, GH; // GW @ Padded Width
    char *ref_file = NULL;
    float x_spacing, y_spacing, z_spacing;
    float *kernel;

    float lambda = 0.01f;
    run = true;
    frameCounter = 0;

    dataH = 1024;
    dataW = 1024;
    //This portion is for the reconstruction setup, Ghost height and width;
    int pad = 3;
    blockXsize = 16;
    blockYsize = 16;
    kernelH = 7;
    kernelW = 7;
    float beforeCeilX = ((float)(dataW-pad)/(float)(blockXsize + pad));
	float beforeCeilY = ((float)(dataH-pad)/(float)(blockYsize + pad));
	float blocksXFloat = (ceil(beforeCeilX));
	float blocksYFloat = (ceil(beforeCeilY));
	blocksX = (int)blocksXFloat;
	blocksY = (int)blocksYFloat;

    GW = blocksX * blockXsize + (blocksX + 1) * pad;
    GH = blocksY * blockYsize + (blocksY + 1) * pad;
    width = GW;
    height = GH;
    printf("Window Size is: %d by %d\n", GW,GH);
    sprintf(H,"%d", GH);
    sprintf(W,"%d", GW);
    strcat(patternInformation,H);
    strcat(patternInformation,"by");
    strcat(patternInformation,W);
    strcat(patternInformation,"/");
    strcat(patternInformation,H);
    strcat(patternInformation,"by");
    strcat(patternInformation,W);

    strcat(patternInformation,"_patternInfo.txt");
    patternInfo = fopen(patternInformation,"r");
    fscanf(patternInfo, "%d", &pixelCount); //total number of active pixels
    printf("Using pixels: %d\nPath: %s\n", pixelCount,patternInformation);


    h_linear = (int *) malloc(sizeof(int)*pixelCount);
    cudaMalloc(&d_linear, sizeof(int)*pixelCount);

    blockSize = dim3(blockXsize, blockYsize);
    gridSize = dim3(blocksX, blocksY);
    gridVol = dim3(iDivUp(GW,blockXsize), iDivUp(GH,blockYsize));

//    gridVol = dim3(iDivUp(ceil(sqrt(pixelCount)),blockXsize), iDivUp(ceil(sqrt(pixelCount)),blockYsize));
    gridVol = dim3(iDivUp(pixelCount,256));

    printf("Number of thread launched: %d\n", gridVol.x*gridVol.y*blockXsize*blockYsize);

    gridBlend = dim3(iDivUp(width,blockXsize), iDivUp(height,blockYsize));
//    gridSize = dim3(iDivUp(pixelCount, blockXsize), iDivUp(pixelCount, blockYsize));
    printf("Volume Block: %d by %d\nReconstruction Block: %d by %d\n", gridVol.x , gridVol.y, gridSize.x, gridSize.y);


    //memory allocation goes here
    int lengthOfDatainFloat = GW * GH * sizeof(float);
    int lengthOfDatainInt = GH * GW * sizeof(int);

    in_red = (float *)malloc(lengthOfDatainFloat);
    in_green = (float *)malloc(lengthOfDatainFloat);
    in_blue = (float *)malloc(lengthOfDatainFloat);
    temp = (float*)malloc(lengthOfDatainFloat); //testing
    temp_red = (float *)malloc(lengthOfDatainFloat);
    temp_green = (float *)malloc(lengthOfDatainFloat);
    temp_blue = (float *)malloc(lengthOfDatainFloat);

    h_vol = (float *)malloc(sizeof(float)*7); //6 for vol->height,width,depth,x,y,z space, pixelCount
    cudaMalloc(&d_vol, sizeof(float)*7);

    cudaEventCreate(&volStart);
    cudaEventCreate(&volEnd);
    cudaMalloc(&d_temp, sizeof(float)*pixelCount);
    cudaMalloc(&d_red, lengthOfDatainFloat);
    cudaMalloc(&d_green, lengthOfDatainFloat);
    cudaMalloc(&d_blue, lengthOfDatainFloat);
    cudaMalloc(&d_opacity, lengthOfDatainFloat);
    cudaMalloc(&res_red, lengthOfDatainFloat);
	cudaMalloc(&res_green, lengthOfDatainFloat);
	cudaMalloc(&res_blue, lengthOfDatainFloat);
    cudaMalloc(&recon_red, lengthOfDatainFloat);
	cudaMalloc(&recon_green, lengthOfDatainFloat);
	cudaMalloc(&recon_blue, lengthOfDatainFloat);
	cudaMalloc(&res_opacity, lengthOfDatainFloat);
	cudaMalloc(&device_x,lengthOfDatainFloat);
	cudaMalloc(&device_p,lengthOfDatainFloat);

    h_pattern = (int*)malloc(lengthOfDatainInt);
    if(cudaMalloc(&d_pattern, lengthOfDatainInt) != cudaSuccess)
    {
    	printf("cudaMalloc error for d_pattern");
    }

    xPattern = (int *)malloc(sizeof(int) * pixelCount);
    yPattern = (int *)malloc(sizeof(int) * pixelCount);
    h_temp = (float *)malloc(sizeof(float) * pixelCount );
    for(int i=0; i<GH*GW; i++)
    {
    	temp[i] = 0.0f;
    }
    cudaMemcpy(device_x, temp, sizeof(float) * GH * GW, cudaMemcpyHostToDevice);
    cudaMemcpy(device_p, temp, sizeof(float) * GH * GW, cudaMemcpyHostToDevice);
    cudaMemcpy(d_red, temp, lengthOfDatainFloat, cudaMemcpyHostToDevice);
    cudaMemcpy(d_green, temp, lengthOfDatainFloat, cudaMemcpyHostToDevice);
    cudaMemcpy(d_blue, temp, lengthOfDatainFloat, cudaMemcpyHostToDevice);
    cudaMemcpy(d_opacity, temp, lengthOfDatainFloat, cudaMemcpyHostToDevice);
    cudaMemcpy(res_red, temp, lengthOfDatainFloat, cudaMemcpyHostToDevice);
    cudaMemcpy(res_green, temp, lengthOfDatainFloat, cudaMemcpyHostToDevice);
    cudaMemcpy(res_blue, temp, lengthOfDatainFloat, cudaMemcpyHostToDevice);
    cudaMemcpy(res_opacity, temp, lengthOfDatainFloat, cudaMemcpyHostToDevice);
    cudaMalloc(&d_xPattern, sizeof(float) * pixelCount);
    cudaMalloc(&d_yPattern, sizeof(float) * pixelCount);

    printf("Total Number of Pixel is : %d\n", pixelCount);
    loadPattern(h_pattern,h_linear, xPattern, yPattern, GH, GW, pixelCount);

    kernel = (float *)malloc(sizeof(float) * kernelH * kernelW);
    loadKernel(kernel, lambda,kernelH*kernelW);
    cudaMemcpy(d_xPattern, xPattern, sizeof(int) * pixelCount, cudaMemcpyHostToDevice);
    cudaMemcpy(d_yPattern, yPattern, sizeof(int) * pixelCount, cudaMemcpyHostToDevice);
    cudaMemcpy(d_linear, h_linear, sizeof(int) * pixelCount, cudaMemcpyHostToDevice);
    if(cudaMemcpy(d_pattern, h_pattern, sizeof(int) * GH * GW, cudaMemcpyHostToDevice) != cudaSuccess) //h_Pattern    if(cudaMemcpy(d_pattern, h_pattern, lengthOfDatainInt, cudaMemcpyHostToDevice) != cudaSuccess)
    {
    	printf("cudaMemcpy error for h_pattern\n");
    	return -1;
    }

    // Reconstruction Testing------------------------------------------------
/*
    loadFiles(in_red, in_green, in_blue);
    cudaMemcpy(d_red, in_red, lengthOfDatainFloat, cudaMemcpyHostToDevice);
    cudaMemcpy(d_green, in_green, lengthOfDatainFloat, cudaMemcpyHostToDevice);
    cudaMemcpy(d_blue, in_blue, lengthOfDatainFloat, cudaMemcpyHostToDevice);
    cudaMemcpy(res_red, in_red, lengthOfDatainFloat, cudaMemcpyHostToDevice);
    cudaMemcpy(res_green, in_green, lengthOfDatainFloat, cudaMemcpyHostToDevice);
    cudaMemcpy(res_blue, in_blue, lengthOfDatainFloat, cudaMemcpyHostToDevice);
    reconstructionFunction(gridSize, blockSize, d_red, d_green, d_blue, d_pattern, res_red, res_green, res_blue, GH, GW, device_x, device_p);
    cudaMemcpy(temp_red, res_red, lengthOfDatainFloat, cudaMemcpyDeviceToHost);
    cudaMemcpy(temp_green, res_green, lengthOfDatainFloat, cudaMemcpyDeviceToHost);
    cudaMemcpy(temp_blue, res_blue, lengthOfDatainFloat, cudaMemcpyDeviceToHost);
    writeOutputReconstruction(temp_red, temp_green,temp_blue);
*/


#if defined(__linux__)
    setenv ("DISPLAY", ":0", 0);
#endif

    //start logs
    printf("%s Starting...\n\n", sSDKsample);

        // First initialize OpenGL context, so we can properly set the GL for CUDA.
        // This is necessary in order to achieve optimal performance with OpenGL/CUDA interop.
        initGL(&argc, argv);

    // parse arguments

    volumeInfo = fopen("Volume.txt","r");
    if(volumeInfo == NULL)
    {
    	printf("Error in Volume information reading\n");
    }
    else{
    	fscanf(volumeInfo, "%s", volName);
    	fscanf(volumeInfo, "%d", &volXdim);
    	fscanf(volumeInfo, "%d", &volYdim);
    	fscanf(volumeInfo, "%d", &volZdim);
    	fscanf(volumeInfo, "%f", &x_spacing);
    	fscanf(volumeInfo, "%f", &y_spacing);
    	fscanf(volumeInfo, "%f", &z_spacing);
    }

    printf("[VOL]: %s\n[X]: %d\t[Y]: %d\t[Z]: %d", volName, volXdim,volYdim,volZdim);
    printf("\tSpacing: %.3f\t %.3f\t %.3f\n", x_spacing, y_spacing, z_spacing);
    h_vol[0] = volXdim;
    h_vol[1] = volYdim;
    h_vol[2] = volZdim;
    h_vol[3] = x_spacing;
    h_vol[4] = y_spacing;
    h_vol[5] = z_spacing;
    h_vol[6] = pixelCount;

    cudaMemcpy(d_vol, h_vol, sizeof(float)*7, cudaMemcpyHostToDevice);

    char *path = volName;//sdkFindFilePath(volumeFilename, argv[0]);

    if (path == 0)
    {
        printf("Error finding file '%s'\n", volName);
        exit(EXIT_FAILURE);
    }
    volumeSize = make_cudaExtent(volXdim, volYdim, volZdim);
    size_t size = volumeSize.width*volumeSize.height*volumeSize.depth*sizeof(VolumeType);
    void *h_volume = loadRawFile(path, size);

    initCuda(h_volume, volumeSize);
    FILE *fp = fopen(path, "rb");
    uint3 volumeSizeCubic = make_uint3(volXdim, volYdim, volZdim);
    size_t noOfVoxels = volumeSizeCubic.x * volumeSizeCubic.y * volumeSizeCubic.z;
    uchar* voxels = new uchar[noOfVoxels];
	size_t linesRead = fread(voxels, volumeSizeCubic.x, volumeSizeCubic.y * volumeSizeCubic.z, fp);
	initCudaCubicSurface(voxels, volumeSizeCubic);
    free(h_volume);

    sdkCreateTimer(&timer);

    printf("Press '+' and '-' to change density (0.01 increments)\n"
           "      ']' and '[' to change brightness\n"
           "      ';' and ''' to modify transfer function offset\n"
           "      '.' and ',' to modify transfer function scale\n\n");

    // calculate new grid size
//    gridSize = dim3(iDivUp(width, blockSize.x), iDivUp(height, blockSize.y));

        glutDisplayFunc(display);

        glutKeyboardFunc(keyboard);
        glutMouseFunc(mouse);
        glutMotionFunc(motion);
        glutReshapeFunc(reshape);
        glutIdleFunc(idle);

        initPixelBuffer();

#if defined (__APPLE__) || defined(MACOSX)
        atexit(cleanup);
#else
        glutCloseFunc(cleanup);
#endif

        glutMainLoop();
}
