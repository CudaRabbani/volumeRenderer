clc;
clear;
fileName = fopen('../Data/synthetic.raw','w');
x = 40;
y = 40;
z = 10;
alpha = 0.25;

r = 0.5;
%vol = zeros(x*y*z);

counter = 1;

for i = -x:1:x
    for j = -y:1:y
        dimCounter = 1;
        for k= -z:1:z
            xVal = (i/(x - 1) - 0.5);
            yVal = (j/(y - 1) - 0.5);
            zVal = (k/(z - 1) - 0.5);
            vol(counter) = ((1 - sin((pi*zVal)/2) + alpha * (1 + rho_r(sqrt(xVal*xVal + yVal*yVal))))/(2 * ( 1 + alpha)));
            counter = counter + 1;
            dimCounter = dimCounter + 1;
        end
    end
end
dimCounter
vol = uint8(vol);
%vol = vol.*255;
fwrite(fileName,vol,'double');
fclose(fileName);