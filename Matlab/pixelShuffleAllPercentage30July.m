clc;
clear;
warning off
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
H = GH
W = GW
percentageSet = [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]; %, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0
[m n] = size(percentageSet);
%s = strcat(num2str(r),'by', num2str(c))
path = '../textFiles/Pattern/';
dirName = '';
dirName = [num2str(GH) 'by' num2str(GW)]; %516by516
fileName = dirName;
dirPath = strcat(path,dirName);
mkdir(char(dirPath));

for i =1:n
    percentage = percentageSet(i);
    intPercent = percentage * 100;
    %dirName = [num2str(H) 'by' num2str(W) '_' num2str(intPercent)];%516by516_30
    dirName = [dirPath '/' num2str(intPercent)];%30
%    patternString = dirName;
%    dirName = strcat(path,dirName)
%    dirName = char(dirName);
    mkdir(char(dirName));
    resultDir = [dirName '/Result'];
    mkdir(char(resultDir));
    
    isoSurfaceDir = [resultDir '/isoSurface'];
    mkdir(char(isoSurfaceDir));
    isoLinear = [isoSurfaceDir '/linear'];
    mkdir(char(isoLinear));
    isoCubic = [isoSurfaceDir '/cubic'];
    mkdir(char(isoCubic));
    isoSuperSampling = [isoSurfaceDir '/superSampling'];
    mkdir(char(isoSuperSampling));
    isoSuperSamplingLinear = [isoSurfaceDir '/superSampling/linear'];
    mkdir(char(isoSuperSamplingLinear));
    isoSuperSamplingCubic = [isoSurfaceDir '/superSampling/cubic'];
    mkdir(char(isoSuperSamplingCubic));
    
    
    
    triLinearDir = [resultDir '/triLinear'];
    mkdir(char(triLinearDir));
    triLinearOn = [triLinearDir '/lightOn'];
    mkdir(char(triLinearOn));
    triLinearOff = [triLinearDir '/lightOff'];
    mkdir(char(triLinearOff));
    linearSuperSampling = [triLinearDir '/superSampling'];
    mkdir(char(linearSuperSampling));
    
    
    triCubicDir = [resultDir '/triCubic'];
    mkdir(char(triCubicDir));
    triCubicOn = [triCubicDir '/lightOn'];
    mkdir(char(triCubicOn));
    triCubicOff = [triCubicDir '/lightOff'];
    mkdir(char(triCubicOff));
    cubicSuperSampling = [triCubicDir '/superSampling'];
    mkdir(char(cubicSuperSampling));
 
    path = strcat(dirName,'/');%path = strcat(path,patternString,'/'); % path = strcat(path,num2str(GH),'/')
    xString = [path 'Xcoord'];
    yString = [path 'Ycoord'];
    ext = [{'.txt'}];
    
    
    patternFileName = strcat(dirName,'/',fileName,ext);
    patternFileName = char(patternFileName);
    xFile = strcat(xString, ext);
    xFile = char(xFile);
    yFile = strcat(yString, ext);
    yFile = char(yFile);
    patternIdx = [dirName '/ptrnIdx'];
    patternIdx = strcat(patternIdx,ext);
    patternIdx = char(patternIdx);
    
    patternInfo = 'patternInfo';
    patternFile =strcat(dirName,'/',patternInfo,ext);
    patternFile = char(patternFile);
    
    patternWithHolo = fopen(patternFileName, 'wt');
    patternXcoords = fopen(xFile, 'wt');
    patternYcoords = fopen(yFile, 'wt');
    patternFileId = fopen(patternFile, 'wt');
    patternLinIdx = fopen(patternIdx,'wt');
    
    mask=zeros(H,W);
    patternString = ones(H, W);
    for col = 1:blockX+padX:blockX+padX %1:N+P:N+P
        patternString(:,col:col+padX-1) = 0; % (:,col:col+P-1) = 0;
    end
    for row = 1:blockY+padY:blockY+padY  % row = 1:N+P:N+P
        patternString(row:row+padY-1,:) = 0;
    end
    for col = blockX+padX+1:blockX+padX:c+diffW % N+P+1:N+P:c+4
        patternString(:,col:col+padX-1) = 0;
    end
    for row = blockY+padY+1:blockY+padY:r+diffH
        patternString(row:row+padY-1,:) = 0;
    end
    
    invPatternString = ~patternString;
    onPixel = sum(sum(invPatternString(:,:)));
    % 0, 1, 1, 1, 2, 3, 4, 6, 9, 13, 19, 28, 41, 60, 88, 129, 189, 277, 406, 595, 872, 1278, 1873, 2745, 4023, 5896
    G2=595;
    G1=872;
    inc=abs(G2-G1);
    NUM=H*W*percentage;
    pixCount = int64(NUM)
    x=0;y=0;N=0;
%    remainingPixel = pixCount - onPixel;
    
    counter = 1;
    while N<pixCount
        if and(x<W, y<H)
        %    if(invPatternString(sub2ind(size(invPatternString), y+1, x+1))==0)
                mask(sub2ind(size(mask), y+1, x+1))=1;
                N=N+1;
        %    end
        end
        x=mod(x+inc, G1);
        y=mod(y+inc, G2);
    end
    patternString = ~patternString;
    tempMaskedImage = mask + invPatternString;
    tempMaskedImage = logical(tempMaskedImage);
    
    effectivePixel = sum(tempMaskedImage(:));
    effectivePercentage = effectivePixel/(H * W) * 100;
    Percentage(i) = effectivePercentage;
    xCoords = zeros(effectivePixel,1);
    yCoords = zeros(effectivePixel,1);
    linCoords = zeros(effectivePixel,1);
    info = [GW, GH, percentage*100, effectivePixel];
    fprintf(patternFileId, '%d\n', effectivePixel);
    
%    imshow(tempMaskedImage);
    tempMaskedImage = tempMaskedImage';
%    imshow(tempMaskedImage,[]);
%    figure;
    fprintf(patternWithHolo, '%d\n', tempMaskedImage);
    counter = 1;
    for i = 1:GH
        for j = 1:GW
            if(tempMaskedImage(j,i) == 1)
                local = (i-1)*GW+(j-1);
                linCoords(counter) = local;
                xCoords(counter) = j-1;
                yCoords(counter) = i-1;
                counter = counter + 1;
            end
        end
    end
    counter
    fprintf(patternXcoords, '%d\n', xCoords);
    fprintf(patternYcoords, '%d\n', yCoords);
    fprintf(patternLinIdx, '%d\n', linCoords);
    fclose('all');    
end


Percentage






