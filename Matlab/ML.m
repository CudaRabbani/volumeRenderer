clc;
clear;
fileName = fopen('../Data/synthetic.raw','w');
alpha = 0.25;

fm = 6;
r = 0.5;

N = 512;

%%
h = 2/(N-1);

[X,Y,Z] = meshgrid(-1:h:1);
rho_r = sqrt(X.^2 + Y.^2);
temp = cos(2*pi*fm*cos((pi*rho_r)/2));

vol = ((1 - sin((pi*Z)/2) + alpha * (1 + temp))) / (2 * ( 1 + alpha));

%%

%vol = uint8(vol);
%vol = vol.*255;
fwrite(fileName,permute(vol, [2 1 3]),'single');
fclose(fileName);