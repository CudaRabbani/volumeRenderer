clear;
clc;
r = 512;
c = 512;
warning off
padX = 3;
padY = 3;
blockX = 16;
blockY = 16;

NBx = ceil( ( c - padX ) /  (blockX + padX) );
NBy = ceil( ( r - padY ) /  (blockY + padY) );

GW = NBx * blockX + (NBx+1) * padX;
GH = NBy * blockY + (NBy+1) * padY;
diffH = GH - r;
diffW = GW - c;
H = GH;
W = GW;
percentageSet = [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.00]; %, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9
[m n] = size(percentageSet);

dir = '/media/reza/projectResults/';
count = 1;



for i =1:n
    percentage = percentageSet(i);
    intPercent = percentage * 100;
    patternString = '';
    dirName = '';
    resultImgDir = [dir num2str(H) 'by' num2str(W) '/resultImages/'];
    surfaceLinearFig = [resultImgDir 'surfaceTimingLinear.png'];
    surfaceCubicFig = [resultImgDir 'surfaceTimingCubic.png'];
    superLinearFig = [resultImgDir 'surfaceTimingSuperLinear.png'];
    superCubicFig = [resultImgDir 'surfaceTimingSuperCubic.png'];
    timingFig = [resultImgDir 'isoSurfaceTiming.png'];
    
    dirName = [dir num2str(H) 'by' num2str(W) '/' num2str(intPercent) '/Result/isoSurface'];
    linearDir = [dirName '/linear/timing/'];
    cubicDir = [dirName '/cubic/timing/'];
    superLinearDir = [dirName '/superSampling/linear/timing/'];
    superCubicDir = [dirName '/superSampling/cubic/timing/'];   
    fileName = 'timer.txt';
    
    
%    timerFile = fopen(dirName,'r');
%    timingInfo = fscanf(timerFile, '%f');

    linearTimerFile = strcat(linearDir, fileName)
    cubicTimerFile = strcat(cubicDir, fileName);
    superLinearTimerFile = strcat(superLinearDir, fileName);
    superCubicTimerFile = strcat(superCubicDir, fileName);
    
    linearTimer = fopen(linearTimerFile,'r');
    cubicTimer = fopen(cubicTimerFile,'r');
    superLinearTimer = fopen(superLinearTimerFile,'r');
    superCubicTimer = fopen(superCubicTimerFile,'r');
 
    linear = fscanf(linearTimer,'%f');
    linearVolTimer(i) = linear(3);
    linearReconTimer(i) = linear(4);
    linearBlendTimer(i) = linear(5);
    linearFpsTimer(i) = linear(7);
    
    cubic = fscanf(cubicTimer,'%f');
    cubicVolTimer(i) = cubic(3);
    cubicReconTimer(i) = cubic(4);
    cubicBlendTimer(i) = cubic(5);
    cubicFpsTimer(i) = cubic(7);
    
    superLinear = fscanf(superLinearTimer,'%f');
    superLinearVolTimer(i) = superLinear(3);
    superLinearReconTimer(i) = superLinear(4);
    superLinearBlendTimer(i) = superLinear(5);
    superLinearFpsTimer(i) = superLinear(7);
    
    superCubic = fscanf(superCubicTimer,'%f');
    superCubicVolTimer(i) = superCubic(3);
    superCubicReconTimer(i) = superCubic(4);
    superCubicBlendTimer(i) = superCubic(5);
    superCubicFpsTimer(i) = superCubic(7);
      
    
    
end

x = 1:n;

yLinearVolume = linearVolTimer(x);
yLinearRecon = linearReconTimer(x);
yLinearFPS = linearFpsTimer(x);
%plot(x,yVolume, '-o', x,yRecon,'-*', x,yBlend, '-+',x,yFPS, '-x', 'LineWidth',2);
plot(x,yLinearVolume, '-o', x,yLinearRecon, '-o', x,yLinearFPS, '-o', 'LineWidth',2);
%ylim([1 100]);
grid on
grid minor
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90';'100'};
%set(gca,'DefaultTextFontSize',8)
set(gca, 'XTick',[1:n],'XTickLabel', p)
%set(gca,'DefaultTextFontSize',8)
%set(gca, 'XTick',[1:n],'XTickLabel', p, 'FontSize',8)
title('Timinig Diagram for tri-linear interpolation');
xlabel('percentage of using pixels');
ylabel('Time in mili-seconds to construct one frame');
legend('Volume Rendering','Reconstruciton','FPS');
saveas(gcf,surfaceLinearFig);
figure;

yCubicVolume = cubicVolTimer(x);
yCubiRecon = cubicReconTimer(x);
yCubicFPS = cubicFpsTimer(x);
%plot(x,yVolume, '-o', x,yRecon,'-*', x,yBlend, '-+',x,yFPS, '-x', 'LineWidth',2);
plot(x,yCubicVolume, '-o', x,yCubiRecon, '-o', x,yCubicFPS, '-o', 'LineWidth',2);
%ylim([1 100]);
grid on
grid minor
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90';'100'};
%set(gca,'DefaultTextFontSize',8)
set(gca, 'XTick',[1:n],'XTickLabel', p)
title('Timinig Diagram for tri-cubic interpolation');
xlabel('percentage of using pixels');
ylabel('Time in mili-seconds to construct one frame');
legend('Volume Rendering','Reconstruciton','FPS');
saveas(gcf,surfaceCubicFig);
figure;



ySuperLinearVolume = superLinearVolTimer(x)
ySuperLinearRecon = superLinearReconTimer(x);
ySuperLinearFPS = superLinearFpsTimer(x);
%plot(x,yVolume, '-o', x,yRecon,'-*', x,yBlend, '-+',x,yFPS, '-x', 'LineWidth',2);
plot(x,ySuperLinearVolume, '-o', x,ySuperLinearRecon, '-o',  x,ySuperLinearFPS, '-o', 'LineWidth',2);
%ylim([1 100]);
grid on
grid minor
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90';'100'};
%set(gca,'DefaultTextFontSize',8)
set(gca, 'XTick',[1:n],'XTickLabel', p)
title('Timinig Diagram for tri-linear interpolation with Super Sampling');
xlabel('percentage of using pixels');
ylabel('Time in mili-seconds to construct one frame');
legend('Volume Rendering','Reconstruciton','FPS');
saveas(gcf,superLinearFig);
figure;


ySuperCubicVolume = superCubicVolTimer(x);
ySuperCubicRecon = superCubicReconTimer(x);
ySuperCubicFPS = superCubicFpsTimer(x);
%plot(x,yVolume, '-o', x,yRecon,'-*', x,yBlend, '-+',x,yFPS, '-x', 'LineWidth',2);
plot(x,ySuperCubicVolume, '-o', x,ySuperCubicRecon, '-o', x,ySuperCubicFPS, '-o', 'LineWidth',2);
%ylim([1 100]);
grid on
grid minor
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90';'100'};
%set(gca,'DefaultTextFontSize',8)
set(gca, 'XTick',[1:n],'XTickLabel', p)
title('Timinig Diagram for tri-cubic interpolation with Super Sampling');
xlabel('percentage of using pixels');
ylabel('Time in mili-seconds to construct one frame');
legend('Volume Rendering','Reconstruciton','FPS');
saveas(gcf,superCubicFig);
