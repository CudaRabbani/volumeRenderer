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
    lightOnFig = [resultImgDir 'linearTimingLightOn.png'];
    lightOffFig = [resultImgDir 'linearTimingLightOff.png'];
    superOnFig = [resultImgDir 'linearTimingSuperOn.png'];
    superOffFig = [resultImgDir 'linearTimingSuperOff.png'];
    timingFig = [resultImgDir 'linearTiming.png'];
    dirName = [dir num2str(H) 'by' num2str(W) '/' num2str(intPercent) '/Result/triLinear'];
    lightOnDir = [dirName '/lightOn/timing/'];
    lightOffDir = [dirName '/lightOff/timing/'];
    superOnDir = [dirName '/superSampling/lightOn/timing/'];
    superOffDir = [dirName '/superSampling/lightOff/timing/'];   
    fileName = 'timer.txt';
    
    
%    timerFile = fopen(dirName,'r');
%    timingInfo = fscanf(timerFile, '%f');

    lightOnTimerFile = strcat(lightOnDir, fileName)
    lightOffTimerFile = strcat(lightOffDir, fileName);
    superOnTimerFile = strcat(superOnDir, fileName);
    superOffTimerFile = strcat(superOffDir, fileName);
    
    lightOnTimer = fopen(lightOnTimerFile,'r');
    lightOffTimer = fopen(lightOffTimerFile,'r');
    superOnTimer = fopen(superOnTimerFile,'r');
    superOffTimer = fopen(superOffTimerFile,'r');
 
    lightOn = fscanf(lightOnTimer,'%f');
    lightOnvolTimer(i) = lightOn(3);
    lightOnreconTimer(i) = lightOn(4);
    lightOnblendTimer(i) = lightOn(5);
    lightOnfpsTimer(i) = lightOn(7);
    
    lightOff = fscanf(lightOffTimer,'%f');
    lightOffvolTimer(i) = lightOff(3);
    lightOffreconTimer(i) = lightOff(4);
    lightOffblendTimer(i) = lightOff(5);
    lightOfffpsTimer(i) = lightOff(7);
    
    superOn = fscanf(superOnTimer,'%f');
    superOnvolTimer(i) = superOn(3);
    superOnreconTimer(i) = superOn(4);
    superOnblendTimer(i) = superOn(5);
    superOnfpsTimer(i) = superOn(7);
    
    superOff = fscanf(superOffTimer,'%f');
    superOffvolTimer(i) = superOff(3);
    superOffreconTimer(i) = superOff(4);
    superOffblendTimer(i) = superOff(5);
    superOfffpsTimer(i) = superOff(7);
      
    
    
end

x = 1:n;

yLightOnVolume = lightOnvolTimer(x);
yLightOnRecon = lightOnreconTimer(x);
yLightOnFPS = lightOnfpsTimer(x);
%plot(x,yVolume, '-o', x,yRecon,'-*', x,yBlend, '-+',x,yFPS, '-x', 'LineWidth',2);
plot(x,yLightOnVolume, '-o', x,yLightOnRecon, '-o',  x,yLightOnFPS, '-o',  'LineWidth',2);
%ylim([1 100]);
grid on
grid minor
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90';'100'};
%set(gca,'DefaultTextFontSize',18)
set(gca, 'XTick',[1:n],'XTickLabel', p)
title('Timinig Diagram for linear interpolation with lighting condition');
xlabel('percentage of using pixels');
ylabel('time in mili-seconds to construct one frame');
legend('Volume Rendering','Reconstruciton','FPS');
saveas(gcf,lightOnFig);
figure;

yLightOffVolume = lightOffvolTimer(x);
yLightOffRecon = lightOffreconTimer(x);
yLightOffFPS = lightOfffpsTimer(x);
%plot(x,yVolume, '-o', x,yRecon,'-*', x,yBlend, '-+',x,yFPS, '-x', 'LineWidth',2);
plot(x,yLightOffVolume, '-o', x,yLightOffRecon, '-o',  x,yLightOffFPS, '-o',  'LineWidth',2);
%ylim([1 100]);
grid on
grid minor
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90';'100'};
%set(gca,'DefaultTextFontSize',18)
set(gca, 'XTick',[1:n],'XTickLabel', p)
title('Timinig Diagram for linear interpolation without lighting condition');
xlabel('percentage of using pixels');
ylabel('time in mili-seconds to construct one frame');
legend('Volume Rendering','Reconstruciton','FPS');
saveas(gcf,lightOffFig);
figure;



ySuperOnVolume = superOnvolTimer(x)
ySuperOnRecon = superOnreconTimer(x);
ySuperOnFPS = superOnfpsTimer(x);
%plot(x,yVolume, '-o', x,yRecon,'-*', x,yBlend, '-+',x,yFPS, '-x', 'LineWidth',2);
plot(x,ySuperOnVolume, '-o', x,ySuperOnRecon, '-o',  x,ySuperOnFPS, '-o',  'LineWidth',2);
%ylim([1 100]);
grid on
grid minor
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90';'100'};
%set(gca,'DefaultTextFontSize',18)
set(gca, 'XTick',[1:n],'XTickLabel', p)
title('Timinig Diagram for linear interpolation with Super Sampling and lighting condition');
xlabel('percentage of using pixels');
ylabel('time in mili-seconds to construct one frame');
legend('Volume Rendering','Reconstruciton','FPS');
saveas(gcf,superOnFig);
figure;


ySuperOffVolume = superOffvolTimer(x);
ySuperOffRecon = superOffreconTimer(x);
ySuperOffFPS = superOfffpsTimer(x);
%plot(x,yVolume, '-o', x,yRecon,'-*', x,yBlend, '-+',x,yFPS, '-x', 'LineWidth',2);
plot(x,ySuperOffVolume, '-o', x,ySuperOffRecon, '-o',  x,ySuperOffFPS, '-o',  'LineWidth',2);
%ylim([1 100]);
grid on
grid minor
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90';'100'};
%set(gca,'DefaultTextFontSize',18)
set(gca, 'XTick',[1:n],'XTickLabel', p)
title('Timinig Diagram for linear interpolation with Super Sampling but lighting condition');
xlabel('percentage of using pixels');
ylabel('time in mili-seconds to construct one frame');
legend('Volume Rendering','Reconstruciton','FPS');
saveas(gcf,superOffFig);



%{
x = 1:n;
yVol= volumeTime(x);
plot(x,yVol, '-o', 'LineWidth',2);
ylim([0 40]);
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:n],'XTickLabel', p)
title('Volume Rendering Time');
xlabel('percentage of using pixels');
ylabel('Time in ms');
grid on
grid minor
saveas(gcf,volName);
figure;

yRecon = reconstructionTime(x);
plot(x,yRecon, '-o', 'LineWidth',2);
grid on
grid minor
ylim([0 40]);
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:n],'XTickLabel', p)
title('Reconstruction Time');
xlabel('percentage of using pixels');
ylabel('Time in ms');
saveas(gcf,reconName);
figure;

yFPS = FPS(x);
plot(x,yFPS, '-o', 'LineWidth',2);
grid on
grid minor
ylim([0 40]);
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:n],'XTickLabel', p)
title('FPS Calculation');
xlabel('percentage of using pixels');
ylabel('Time in ms');
saveas(gcf,fpsName);
figure;

yTime = totalTime(x);
plot(x,yVol,'r-o', x,yRecon,'g-o', x,yTime,'b-o', 'LineWidth',2);
grid on
grid minor
ylim([0 50]);
axis equal square
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:n],'XTickLabel', p)
title('Total Timing');
xlabel('percentage of using pixels');
ylabel('Time in ms');
legend('Volume Rendering Time','Reconstruction Time','Total Time')
saveas(gcf,timingName);
%}