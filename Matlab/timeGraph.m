r = 512;
c = 512;
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
percentageSet = [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9];
[m n] = size(percentageSet);

for i =1:n
    path = '../textFiles/Pattern/';
    percentage = percentageSet(i);
    intPercent = percentage * 100;
    patternString = '';
    dirName = '';
    patternString = [num2str(GH) 'by' num2str(GW)]; %516by516_30   
    dirName = [num2str(H) 'by' num2str(W) '_' num2str(intPercent) '/Result/timing/timer.txt'];
    dirName = strcat(path,dirName)
    timerFile = fopen(dirName,'r');
    timingInfo = fscanf(timerFile, '%f')
    totalFrame(i) = timingInfo(1)
    volumeTime(i) = timingInfo(2)
    reconstructionTime(i) = timingInfo(3)
    FPS(i) = timingInfo(6)   
end

x = 1:n;
yVol= volumeTime(x);
yRecon = reconstructionTime(x);
y = FPS(x);

plot(x,yVol);
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:n],'XTickLabel', p)
%set(gca, 'XTickLabel',['30'; '40'; '50'; '60'; '70'; '80'; '90'])
title('Timing for Volume rendering');
xlabel('percentage of used pixels');
ylabel('Rendering time of volume in ms');
grid minor
figure;
plot(x,yRecon);
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:n],'XTickLabel', p)
%set(gca, 'XTickLabel',['30'; '40'; '50'; '60'; '70'; '80'; '90'])
title('Timing for Reconstruction');
xlabel('percentage of used pixels');
ylabel('Reconstruction time in ms');
grid minor

figure;
plot(x,y);
p = {'30'; '40'; '50'; '60'; '70'; '80'; '90'};
set(gca, 'XTick',[1:n],'XTickLabel', p)
%set(gca, 'XTickLabel',['30'; '40'; '50'; '60'; '70'; '80'; '90'])
title('Frame Per Second');
xlabel('percentage of used pixels');
ylabel('Time in seconds');
grid minor

