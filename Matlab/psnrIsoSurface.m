clear;
clc;
warning off
r = 512;
c = 512;
padX = 3;
padY = 3;
blockX = 16;
blockY = 16;
totalFrame = 10;

NBx = ceil( ( c - padX ) /  (blockX + padX) );
NBy = ceil( ( r - padY ) /  (blockY + padY) );

GW = NBx * blockX + (NBx+1) * padX;
GH = NBy * blockY + (NBy+1) * padY;
diffH = GH - r;
diffW = GW - c;
H = GH;
W = GW;
percentageSet = [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]; %, , 0.4, 0.5, 0.6, 0.7, 0.8, 0.9
[m n] = size(percentageSet);

psnrRatioLinear = zeros(1,totalFrame);
psnrRatioCubic = zeros(1,totalFrame);
psnrRatioLinearSuper = zeros(1,totalFrame);
psnrRatioCubicSuper = zeros(1,totalFrame);

dir = '/media/reza/projectResults/';
count = 1;


for i=1:n
        percentage = percentageSet(i);
        intPercent = percentage * 100;
        path = [dir num2str(H) 'by' num2str(W)];
        dirName = [path '/resultImages'];
        mkdir(char(dirName));
        surfaceLinear = [dirName '/surfaceLinear.png'];
        surfaceCubic = [dirName '/surfaceCubic.png'];
        superLinear = [dirName '/surfaceSuperLinear.png'];
        superCubic = [dirName '/surfaceSuperCubic.png'];
        triCubic = [dirName '/isoSurface.png'];
       
        
        psnrLinear = 0;
        psnrCubic = 0;
        psnrSuperLinear = 0;
        psnrSuperCubic = 0;
       
        frameCounter = 1;
    for frame = 1:totalFrame
        patternString = '';
        dirName = '';
        intPercent = percentageSet(i) * 100;        
        
        gtSurfLinearDir = [path '/' num2str(100) '/Result/isoSurface/linear/'];
        gtSurfCubicDir = [path '/' num2str(100) '/Result/isoSurface/cubic/'];
        gtCubicSuperLinDir = [path '/' num2str(100) '/Result/isoSurface/superSampling/linear/'];
        gtCubicSuperCubicDir = [path '/' num2str(100) '/Result/isoSurface/superSampling/cubic/'];
        
        surfaceLinearDir = [path '/' num2str(intPercent) '/Result/isoSurface/linear/'];
        surfaceCubicDir = [path '/' num2str(intPercent) '/Result/isoSurface/cubic/'];
        SuperLinearDir = [path '/' num2str(intPercent) '/Result/isoSurface/superSampling/linear/'];
        SuperCubicDir = [path '/' num2str(intPercent) '/Result/isoSurface/superSampling/cubic/'];

        
        rgbFile = ['rgb_' num2str(frame) '.bin'];
               
        %triCubic section
        surfLinearRGBfile = strcat(surfaceLinearDir,rgbFile);
        surfCubicRGBfile = strcat(surfaceCubicDir,rgbFile);
        superSurfLinearRGBfile = strcat(SuperLinearDir,rgbFile);
        superSurfCubicRGBfile = strcat(SuperCubicDir,rgbFile);
        
        GTlinearRGBfile = strcat(gtSurfLinearDir,rgbFile);
        GTcubicRGBfile = strcat(gtSurfCubicDir,rgbFile);
        GTSuperLinRGBfile = strcat(gtCubicSuperLinDir,rgbFile);
        GTSuperCubicRGBfile = strcat(gtCubicSuperCubicDir,rgbFile);
        
        
        psnrLinear = calculatePSNR(surfLinearRGBfile,GTlinearRGBfile,H,W) + psnrLinear;
        psnrCubic = calculatePSNR(surfCubicRGBfile,GTcubicRGBfile,H,W) + psnrCubic;
        psnrSuperLinear = calculatePSNR(superSurfLinearRGBfile,GTSuperLinRGBfile,H,W) + psnrSuperLinear;
        psnrSuperCubic = calculatePSNR(superSurfCubicRGBfile,GTSuperCubicRGBfile,H,W) + psnrSuperCubic;
        
        
         
        frameCounter = frameCounter +1;
        fclose('all');
    end
    psnrRatioLinear(i) = psnrLinear/frameCounter;
    psnrRatioCubic(i) = psnrCubic/frameCounter;
    psnrRatioLinearSuper(i) = psnrSuperLinear/frameCounter;
    psnrRatioCubicSuper(i) = psnrSuperCubic/frameCounter;
   
    
    count = count + 1;
end

x = 1:count-2

yLinear = psnrRatioLinear(x);
yCubic = psnrRatioCubic(x);
ySuperLinear = psnrRatioLinearSuper(x);
ySuperCubic = psnrRatioCubicSuper(x);

%Saving Cubic Light On
figure;
plot(x,yLinear,'LineWidth',2);
grid on
grid minor
legend('Tri-linear interpolation');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of tri-linear interpolation');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,surfaceLinear);

figure;
plot(x,yCubic,'LineWidth',2);
grid on
grid minor
legend('Tri-cubic interpolation');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of tri-cubic interpolation');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,surfaceCubic);

figure;
plot(x,ySuperLinear,'LineWidth',2);
grid on
grid minor
legend('Lighting On');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of tri-linear interpolation with super sampling');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,superLinear);

figure;
plot(x,ySuperCubic,'LineWidth',2);
grid on
grid minor
legend('Lighting Off');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of tri-cubic interpolation with super sampling');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,superCubic);

figure;
plot(x,yLinear,'-o',x,yCubic,'-o',x,ySuperLinear,'-o', x,ySuperCubic,'-o','LineWidth',2);
grid on
grid minor
legend('Tri-linear','Tri-cubic','Super Sampling with tri-linear','Super Sampling with tri-cubic');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of tri-cubic interpolation for different conditions');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,triCubic);
