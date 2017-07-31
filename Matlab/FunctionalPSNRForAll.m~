clear;
clc;
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
psnrRatioLinearOn = zeros(1,totalFrame);
psnrRatioLinearOff = zeros(1,totalFrame);
psnrRatioLinearSuper = zeros(1,totalFrame);

psnrRatioCubicOn = zeros(1,totalFrame);
psnrRatioCubicOff = zeros(1,totalFrame);
psnrRatioCubicSuper = zeros(1,totalFrame);

psnrRatioIsoOn = zeros(1,totalFrame);
psnrRatioIsoOff = zeros(1,totalFrame);
psnrRatioIsoSuperLinear = zeros(1,totalFrame);
psnrRatioIsoSuperCubic = zeros(1,totalFrame);

count = 1;
path = ['../textFiles/Pattern/' num2str(H) 'by' num2str(W) '/' ]
name = [path 'resultImages'];
mkdir(char(name));

linear = [name '/' 'triLinear.png'];
cubic = [name '/' 'triCubic.png'];
iso = [name '/' 'isoSurface.png'];
isoSuper = [name '/' 'isoSurfaceSuperSmapling.png'];

lighting = [name '/' 'lightingOn.png'];
lighingOff = [name '/' 'lightingOff.png']; 

linVsCubicOn = [name '/' 'linVsCubicLightOn.png'];
linVsCubicOff = [name '/' 'linVsCubicLightOff.png'];
linVsCubicSuper = [name '/' 'linVsCubicSuperSampling.png'];

for i=1:n
        psnrLinearOn = 0;
        psnrLinearOff = 0;
        psnrLinearSuper = 0;
        psnrCubicOn = 0;
        psnrCubicOff = 0;
        psnrCubicSuper = 0;
        psnrIsoOn = 0;
        psnrIsoOff = 0;
        psnrIsoSuperLinear = 0;
        psnrIsoSuperCubic = 0;
        frameCounter = 1;
    for frame = 1:totalFrame
        patternString = '';
        dirName = '';
        intPercent = percentageSet(i) * 100;        
        gtLinearOnDir = [path num2str(100) '/Result/triLinear/lightOn/'];
        gtLinearOffDir = [path num2str(100) '/Result/triLinear/lightOff/'];
        gtLinearSuperDir = [path num2str(100) '/Result/triLinear/superSampling/'];
        LinearOnDir = [path num2str(intPercent) '/Result/triLinear/lightOn/'];
        LinearOffDir = [path num2str(intPercent) '/Result/triLinear/lightOff/'];
        LinearSuperDir = [path num2str(intPercent) '/Result/triLinear/superSampling/'];

        gtCubicOnDir = [path num2str(100) '/Result/triCubic/lightOn/'];
        gtCubicOffDir = [path num2str(100) '/Result/triCubic/lightOff/'];
        gtCubicSuperDir = [path num2str(100) '/Result/triCubic/superSampling/'];
        CubicOnDir = [path num2str(intPercent) '/Result/triCubic/lightOn/'];
        CubicOffDir = [path num2str(intPercent) '/Result/triCubic/lightOff/'];
        CubicSuperDir = [path num2str(intPercent) '/Result/triCubic/superSampling/'];
        
        gtIsoLinearDir = [path num2str(100) '/Result/isoSurface/linear/'];
        gtIsoCubicDir = [path num2str(100) '/Result/isoSurface/cubic/'];
        gtIsoSuperLinDir = [path num2str(100) '/Result/isoSurface/superSampling/linear/'];
        gtIsoSuperCubicDir = [path num2str(100) '/Result/isoSurface/superSampling/cubic/'];
        IsoLinearDir = [path num2str(intPercent) '/Result/isoSurface/linear/'];
        IsoOffDir = [path num2str(intPercent) '/Result/isoSurface/cubic/'];
        IsoSuperLinDir = [path num2str(intPercent) '/Result/isoSurface/superSampling/linear/'];
        IsoSuperCubicDir = [path num2str(intPercent) '/Result/isoSurface/superSampling/cubic/'];
        
        rgbFile = ['rgb_' num2str(frame) '.bin'];
        
        lightRGB = strcat(lightDir,rgbFile);
        cubicRGB = strcat(CubicDir,rgbFile);       
        %triLinear section
        linearOnRGBfile = strcat(LinearOnDir,rgbFile);
        linearOffRGBfile = strcat(LinearOnDir,rgbFile);
        linearSuperRGBfile = strcat(LinearOnDir,rgbFile);
        GTlinearOnRGBfile = strcat(gtLinearOnDir,rgbFile);
        GTlinearOffRGBfile = strcat(gtLinearOffDir,rgbFile);
        GTlinearSuperRGBfile = strcat(gtLinearSuperDir,rgbFile);
        %triCubic section
        cubicOnRGBfile = strcat(CubicOnDir,rgbFile);
        cubicOffRGBfile = strcat(CubicOffDir,rgbFile);
        cubicSuperRGBfile = strcat(CubicSuperDir,rgbFile);
        GTcubicOnRGBfile = strcat(gtCubicOnDir,rgbFile);
        GTcubicOffRGBfile = strcat(gtCubicOffDir,rgbFile);
        GTcubicSuperRGBfile = strcat(gtCubicSuperDir,rgbFile);
        %isoSurface
        IsoOnRGBfile = strcat(IsoLinearDir,rgbFile);
        IsoOffRGBfile = strcat(IsoOffDir,rgbFile);
        IsoSuperLinRGBfile = strcat(IsoSuperLinDir,rgbFile);
        IsoSuperCubicRGBfile = strcat(IsoSuperCubicDir,rgbFile);
        GTIsoOnRGBfile = strcat(gtIsoLinearDir,rgbFile);
        GTIsoOffRGBfile = strcat(gtIsoCubicDir,rgbFile);
        GTIsoSuperLinRGBfile = strcat(gtIsoSuperLinDir,rgbFile);
        GTIsoSuperRCubicGBfile = strcat(gtIsoSuperCubicDir,rgbFile);
        
        psnrLinearOn = calculatePSNR(linearOnRGBfile,GTlinearOnRGBfile,H,W) + psnrLinearOn;
        psnrLinearOff = calculatePSNR(linearOffRGBfile,GTlinearOffRGBfile,H,W) + psnrLinearOff;
        psnrLinearSuper = calculatePSNR(linearSuperRGBfile,GTlinearSuperRGBfile,H,W) + psnrLinearSuper;
        
        psnrCubicOn = calculatePSNR(cubicOnRGBfile,GTcubicOnRGBfile,H,W) + psnrCubicOn;
        psnrCubicOff = calculatePSNR(cubicOffRGBfile,GTcubicOffRGBfile,H,W) + psnrCubicOff;
        psnrCubicSuper = calculatePSNR(cubicSuperRGBfile,GTcubicSuperRGBfile,H,W) + psnrCubicSuper;
        
        psnrIsoOn = calculatePSNR(IsoOnRGBfile,GTIsoOnRGBfile,H,W) + psnrIsoOn;
        psnrIsoOff = calculatePSNR(IsoOffRGBfile,GTIsoOffRGBfile,H,W) + psnrIsoOff;
        psnrIsoSuperLinear = calculatePSNR(IsoSuperRGBfile,GTIsoSuperRGBfile,H,W) + psnrIsoSuperLinear;
        psnrIsoSuperCubic = calculatePSNR(IsoSuperRGBfile,GTIsoSuperRGBfile,H,W) + psnrIsoSuperCubic;
         
        frameCounter = frameCounter +1;
        fclose('all');
    end
    psnrRatioLinearOn(i) = psnrLinearOn/frameCounter;
    psnrRatioLinearOff(i) = psnrLinearOff/frameCounter;
    psnrRatioLinearSuper(i) = psnrLinearSuper/frameCounter;
   
    psnrRatioCubicOn(i) = psnrCubicOn/frameCounter;
    psnrRatioCubicOff(i) = psnrCubicOff/frameCounter;
    psnrRatioCubicSuper(i) = psnrCubicSuper/frameCounter;
    
    psnrRatioIsoOn(i) = psnrIsoOn/frameCounter;
    psnrRatioIsoOff(i) = psnrIsoOff/frameCounter;
    psnrRatioIsoSuperLinear(i) = psnrIsoSuperLinear/frameCounter;
    psnrRatioIsoSuperCubic(i) = psnrIsoSuperCubic/frameCounter;
    count = count + 1;
end

x = 1:count-1;

yLinearOn = psnrRatioLinearOn(x);
yLinearOff = psnrRatioLinearOff(x);
yLinearSuper = psnrRatioLinearSuper(x);

yCubicOn = psnrRatioCubicOn(x);
yCubicOff = psnrRatioCubicOff(x);
yCubicSuper = psnrRatioCubicSuper(x);

yIsoOn = psnrRatioIsoOn(x);
yIsoOff = psnrRatioIsoOff(x);
yIsoSuperLinear = psnrRatioIsoSuperLinear(x);
yIsoSuperCubic = psnrRatioIsoSuperCubic(x);

figure;
plot(x,yLinearOn,'-o',x,yLinearOff,'-o',x,yLinearSuper,'LineWidth',2);
grid on
grid minor
legend('Lighting On','Lighting Off','Super Sampling');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of tri-linear interpolation for different conditions');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,linear);

figure;
plot(x,yCubicOn,'-o',x,yCubicOff,'-o',x,yCubicSuper,'LineWidth',2);
grid on
grid minor
legend('Lighting On','Lighting Off','Super Sampling');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of tri-cubic interpolation for different conditions');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,cubic);

figure;
plot(x,yIsoOn,'-o',x,yIsoOff,'-o','LineWidth',2);
grid on
grid minor
legend('Tri-linear','Tri-cubic');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of iso-surface for different conditions');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,iso);
%{
linear = [name '/' 'triLinear.png'];
cubic = [name '/' 'triCubic.png'];
iso = [name '/' 'isoSurface.png'];

lighting = [name '/' 'lightingOn.png'];
lighingOff = [name '/' 'lightingOff.png']; 

linVsCubicOn = [name '/' 'linVsCubicLightOn.png'];
linVsCubicOff = [name '/' 'linVsCubicLightOff.png'];
linVsCubicSuper = [name '/' 'linVsCubicSuperSampling.png'];
%}
figure;
plot(x,yIsoSuperLinear,'-o',x,yIsoSuperCubic,'-o','LineWidth',2);
grid on
grid minor
legend('Tri-linear','Tri-cubic');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of iso-surface with super sampling');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,isoSuper);


figure;
plot(x,yLinearOn,'-o',x,yCubicOn,'-o','LineWidth',2);
grid on
grid minor
legend('Tri-linear interpolation','Tri-cubic interpolation');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR comparison: tri-linear Vs tri-cubic with Lighting');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,linVsCubicOn);

figure;
plot(x,yLinearOff,'-o',x,yCubicOff,'-o','LineWidth',2);
grid on
grid minor
legend('Tri-linear interpolation','Tri-cubic interpolation');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR comparison: tri-linear Vs tri-cubic without Lighting');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,linVsCubicOff);

figure;
plot(x,yLinearSuper,'-o',x,yCubicSuper,'-o','LineWidth',2);
grid on
grid minor
legend('Tri-linear interpolation','Tri-cubic interpolation');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR comparison: tri-linear Vs tri-cubic with Super Sampling');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,linVsCubicSuper);




%{
path = '../textFiles/Pattern/';
patternString = '';
dirName = '';
gtLightDir = [path num2str(H) 'by' num2str(W) '_' num2str(100) '/Result/lighting/groundTruth/'];
lightDir = [path num2str(H) 'by' num2str(W) '_' num2str(50) '/Result/lighting/'];
frame = 2;
rgbFile = ['rgb_' num2str(frame) '.bin'];

lightRGB = strcat(lightDir,rgbFile)
lightingRGB = fopen(lightRGB, 'r');
lightingRGB = fread(lightingRGB, 'float32');
[row col plane] = size(lightingRGB);
lBinRed = lightingRGB(1:3:row);
lBinGreen = lightingRGB(2:3:row);
lBinBlue = lightingRGB(3:3:row);

lBinRed = reshape(lBinRed, [H W]);
lBinGreen = reshape(lBinGreen, [H W]);
lBinBlue = reshape(lBinBlue, [H W]);

lightImage = cat(3, lBinRed, lBinGreen, lBinBlue);
imshow(lightImage, []);
title('image');
figure;

gtLightRGB = strcat(gtLightDir,rgbFile)
gtLightRGB = fopen(gtLightRGB,'r');
gtLightRGB = fread(gtLightRGB, 'float32');
[row col plabe] = size(gtLightRGB);
gtlBinRed = gtLightRGB(1:3:row);
gtlBinGreen = gtLightRGB(2:3:row);
gtlBinBlue = gtLightRGB(3:3:row);

gtlImageR = reshape(gtlBinRed, [H W]);
gtlImageG = reshape(gtlBinGreen, [H W]);
gtlImageB = reshape(gtlBinBlue, [H W]);
GTlightImage = cat(3, gtlImageR, gtlImageG, gtlImageB);
%GTlightImage = uint8(lightImage);
imshow(GTlightImage, []);
title('Ground Truth image');
%}