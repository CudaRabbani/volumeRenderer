clc;
clear;
width = 516;
height = 516;
fileName = '../resultImages/sample.bin';
image = fopen(fileName,'r')
imageValue = fread(image, 'float32');
[row col plane] = size(imageValue);
Red = imageValue(1:3:row);
Green = imageValue(2:3:row);
Blue = imageValue(3:3:row);

red = reshape(Red, [height width]);
green = reshape(Green, [height width]);
blue = reshape(Blue, [height width]);
red = red';
green = green';
blue = blue';
finalImage = cat(3, red, green, blue);
imshow(finalImage, []);