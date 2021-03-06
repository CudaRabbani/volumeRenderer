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
percentageSet = [0.3, 0.4, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]; %, , 0.4, 0.5, 0.6, 0.7, 0.8, 0.9
[m n] = size(percentageSet);
n
psnrRatioLinearOn = zeros(1,totalFrame);
psnrRatioLinearOff = zeros(1,totalFrame);
psnrRatioLinearSuperOn = zeros(1,totalFrame);
psnrRatioLinearSuperOff = zeros(1,totalFrame);

dir = '/media/reza/projectResults/';
count = 1;

for i=1:n
    intPercent = percentageSet(i)*100;
    %path = ['../textFiles/Pattern/' num2str(H) 'by' num2str(W)]
    path = [dir num2str(H) 'by' num2str(W)]
    dirName = [path '/resultImages'];
    mkdir(char(dirName));
    linearOn = [dirName '/linearOn.png'];
    linearOff = [dirName '/linearOff.png'];
    superOn = [dirName '/linearSuperSamplingOn.png'];
    superOff = [dirName '/linearSuperSamplingOff.png'];
    linear = [dirName '/LinearAll.png'];
     
    
    psnrLinearOn = 0;
    psnrLinearOff = 0;
    psnrLinearSuperOn = 0;
    psnrLinearSuperOff = 0;
       
        frameCounter = 1;
    for frame = 1:totalFrame
        patternString = '';
        dirName = '';
 
        
        gtLinearOnDir = [path '/' num2str(100) '/Result/triLinear/lightOn/'];
        gtLinearOffDir = [path '/' num2str(100) '/Result/triLinear/lightOff/'];
        gtLinearSuperOnDir = [path '/' num2str(100) '/Result/triLinear/superSampling/lightOn/'];
        gtLinearSuperOffDir = [path '/' num2str(100) '/Result/triLinear/superSampling/lightOff/'];
        
        LinearOnDir = [path '/' num2str(intPercent) '/Result/triLinear/lightOn/'];
        LinearOffDir = [path '/' num2str(intPercent) '/Result/triLinear/lightOff/'];
        LinearSuperOnDir = [path '/' num2str(intPercent) '/Result/triLinear/superSampling/lightOn/'];
        LinearSuperOffDir = [path '/' num2str(intPercent) '/Result/triLinear/superSampling/lightOff/'];

        
        rgbFile = ['rgb_' num2str(frame) '.bin'];
               
        %triLinear section
        linearOnRGBfile = strcat(LinearOnDir,rgbFile);
        linearOffRGBfile = strcat(LinearOffDir,rgbFile);
        linearSuperOnRGBfile = strcat(LinearSuperOnDir,rgbFile);
        linearSuperOffRGBfile = strcat(LinearSuperOffDir,rgbFile);
        
        GTlinearOnRGBfile = strcat(gtLinearOnDir,rgbFile);
        GTlinearOffRGBfile = strcat(gtLinearOffDir,rgbFile);
        GTlinearSuperOnRGBfile = strcat(gtLinearSuperOnDir,rgbFile);
        GTlinearSuperOffRGBfile = strcat(gtLinearSuperOffDir,rgbFile);
        
        
        psnrLinearOn = calculatePSNR(linearOnRGBfile,GTlinearOnRGBfile,H,W) + psnrLinearOn;
        psnrLinearOff = calculatePSNR(linearOffRGBfile,GTlinearOffRGBfile,H,W) + psnrLinearOff;
        psnrLinearSuperOn = calculatePSNR(linearSuperOnRGBfile,GTlinearSuperOnRGBfile,H,W) + psnrLinearSuperOn;
        psnrLinearSuperOff = calculatePSNR(linearSuperOffRGBfile,GTlinearSuperOffRGBfile,H,W) + psnrLinearSuperOff;
        
        
         
        frameCounter = frameCounter +1;
        fclose('all');
    end
    psnrRatioLinearOn(i) = psnrLinearOn/frameCounter;
    psnrRatioLinearOff(i) = psnrLinearOff/frameCounter;
    psnrRatioLinearSuperOn(i) = psnrLinearSuperOn/frameCounter;
    psnrRatioLinearSuperOff(i) = psnrLinearSuperOff/frameCounter;
   
    
    count = count + 1;
end
%psnrRatioLinearSuperOn
x = 1:count-2

yLinearOn = psnrRatioLinearOn(x);
yLinearOff = psnrRatioLinearOff(x);
yLinearSuperOn = psnrRatioLinearSuperOn(x);
yLinearSuperOff = psnrRatioLinearSuperOff(x);

%Saving Linear Light On
figure;
plot(x,yLinearOn,'LineWidth',2);
grid on
grid minor
legend('Lighting On');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of tri-linear interpolation for lighting on condition');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,linearOn);

figure;
plot(x,yLinearOff,'LineWidth',2);
grid on
grid minor
legend('Lighting Off');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of tri-linear interpolation for lighting off condition');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,linearOff);

figure;
plot(x,yLinearSuperOn,'LineWidth',2);
grid on
grid minor
legend('Lighting On');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of tri-linear interpolation for lighting on condition with super sampling');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,superOn);

figure;
plot(x,yLinearSuperOff,'LineWidth',2);
grid on
grid minor
legend('Lighting Off');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of tri-linear interpolation for lighting off condition with super sampling');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,superOff);

figure;
plot(x,yLinearOn,'-o',x,yLinearOff,'-o',x,yLinearSuperOn, x,yLinearSuperOff,'-o','LineWidth',2);
grid on
grid minor
legend('Lighting On','Lighting Off','Super Sampling with Lighting','Super Sampling without Lighting');
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:count-1],'XTickLabel', p)
title('PSNR of tri-linear interpolation for different conditions');
xlabel('percentage of using pixels');
ylabel('PSNR');
saveas(gcf,linear);

