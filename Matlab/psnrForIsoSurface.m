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
percentageSet = [0.3]; %, , 0.4, 0.5, 0.6, 0.7, 0.8, 0.9
[m n] = size(percentageSet);

psnrRatioIsoLinear = zeros(1,totalFrame);
psnrRatioIsoCubic = zeros(1,totalFrame);
psnrRatioIsoSuperLinear = zeros(1,totalFrame);
psnrRatioIsoSuperCubic = zeros(1,totalFrame);


count = 1;
path = ['../textFiles/Pattern/' num2str(H) 'by' num2str(W) '/' num2str(intPercent)]
dirName = [path '/resultImages'];
mkdir(char(dirName));
isoLinear = [dirName '/isoSurfaceLinear.png']
isoCubic = [dirName '/isoSurfaceCubic.png']
superLinear = [dirName '/isoSuperSamplingLinear.png']
superCubic = [dirName '/isoSuperSamplingCubic.png']
isoSurface = [dirName '/isoSurfaceAll.png'];

for i=1:n
        percentage = percentageSet(i);
        intPercent = percentage * 100;
       
        
        psnrIsoLinear = 0;
        psnrIsoCubic = 0;
        psnrIsoSuperLinear = 0;
        psnrIsoSuperCubic = 0;
       
        frameCounter = 1;
    for frame = 1:totalFrame
        patternString = '';
        dirName = '';
        intPercent = percentageSet(i) * 100;        
        
        gtIsoLinearDir = [path num2str(100) '/Result/isoSurface/linear/'];
        gtIsoCubicDir = [path num2str(100) '/Result/isoSurface/cubic/'];
        gtIsoSuperLinearDir = [path num2str(100) '/Result/triCubic/superSampling/lightOn/'];
        gtIsoSuperCubicDir = [path num2str(100) '/Result/triCubic/superSampling/lightOff/'];
        
        isoLinearDir = [path num2str(intPercent) '/Result/isoSurface/linear/'];
        isoCubicDir = [path num2str(intPercent) '/Result/isoSurface/cubic/'];
        isoSuperLinearDir = [path num2str(intPercent) '/Result/isoSurface/superSampling/linear/'];
        isoSuperCubicDir = [path num2str(intPercent) '/Result/isoSurface/superSampling/cubic/'];

        
        rgbFile = ['rgb_' num2str(frame) '.bin'];
               
        %triCubic section
        isoLinaerRGBfile = strcat(isoLinearDir,rgbFile);
        isoCubicRGBfile = strcat(isoCubicDir,rgbFile);
        isoSuperLinearRGBfile = strcat(isoSuperLinearDir,rgbFile);
        isoSuperCubicRGBfile = strcat(isoSuperCubicDir,rgbFile);
        
        GTisoLinearRGBfile = strcat(gtIsoLinearDir,rgbFile);
        GTisoCubicRGBfile = strcat(gtIsoCubicDir,rgbFile);
        GTisoSuperLinearRGBfile = strcat(gtIsoSuperLinearDir,rgbFile);
        GTisoSuperCubicRGBfile = strcat(gtIsoSuperCubicDir,rgbFile);
        
        
        psnrIsoLinear = calculatePSNR(isoLinaerRGBfile,GTisoLinearRGBfile,H,W) + psnrIsoLinear;
        psnrIsoCubic = calculatePSNR(isoCubicRGBfile,GTisoCubicRGBfile,H,W) + psnrIsoCubic;
        psnrIsoSuperLinear = calculatePSNR(isoSuperLinearRGBfile,GTisoSuperLinearRGBfile,H,W) + psnrIsoSuperLinear;
        psnrIsoSuperCubic = calculatePSNR(isoSuperCubicRGBfile,GTisoSuperCubicRGBfile,H,W) + psnrIsoSuperCubic;
        
        
         
        frameCounter = frameCounter +1;
        fclose('all');
    end
    psnrRatioIsoLinear(i) = psnrIsoLinear/frameCounter;
    psnrRatioIsoCubic(i) = psnrIsoCubic/frameCounter;
    psnrRatioIsoSuperLinear(i) = psnrIsoSuperLinear/frameCounter;
    psnrRatioIsoSuperCubic(i) = psnrIsoSuperCubic/frameCounter;
   
    
    count = count + 1;
end

x = 1:count-1;

yIsoLinear = psnrRatioIsoLinear(x);
yIsoCubic = psnrRatioIsoCubic(x);
yIsoSuperLinear = psnrRatioIsoSuperLinear(x);
yIsoSuperCubic = psnrRatioIsoSuperCubic(x);

%Saving Cubic Light On
figure;
plot(x,yIsoLinear,'LineWidth',2);
grid on
grid minor
legend('Tri-Linear');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of iso-surface with tri-linear interpolation');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,isoLinear);

figure;
plot(x,yIsoCubic,'LineWidth',2);
grid on
grid minor
legend('Tri-Cubic');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of iso-surface with tri-cubic interpolation');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,isoCubic);

figure;
plot(x,yIsoSuperLinear,'LineWidth',2);
grid on
grid minor
legend('Super Sampling(tri-linear)');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of iso-surface for super sampling using tri-linear interpolation');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,superLinear);

figure;
plot(x,yIsoSuperCubic,'LineWidth',2);
grid on
grid minor
legend('Super Sampling(tri-cubic)');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of iso-surface for super sampling using tri-cubic interpolation');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,superCubic);

figure;
plot(x,yIsoLinear,'-o',x,yIsoCubic,'-o',x,yIsoSuperLinear, x,yIsoSuperLinear,'-o','LineWidth',2);
grid on
grid minor
legend('Tri-linear','Tri-cubic','Super Sampling(Tri-linear)','Super Sampling(Tri-cubic)');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of Iso-surface for different conditions');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,isoSurface);
