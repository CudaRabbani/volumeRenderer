% window size generator

Width = [128, 256, 512, 1024, 1280, 2048, 3840, 4096]
Height = [128, 256, 512, 1024, 720, 1080, 2160, 2160]


padX = 3;
padY = 3;
blockX = 16;
blockY = 16;

path = '../textFiles/Pattern/';

for i = 1:a
    NBx = ceil( ( Width(1,i) - padX ) /  (blockX + padX) )
    NBy = ceil( ( Height(1,i) - padY ) /  (blockY + padY) );

    GW = NBx * blockX + (NBx+1) * padX;
    GH = NBy * blockY + (NBy+1) * padY;
    H = GH;
    W = GW;
    dirName = [num2str(H)];
    dirName = strcat(path,dirName);
    dirName = char(dirName);
    mkdir(dirName);    
end
    
    