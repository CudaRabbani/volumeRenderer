function psnrValue = calculatePSNR(fileName, gtFileName, H, W)

%File Reading Section
RGBFile = fopen(fileName, 'r');
RGBValue = fread(RGBFile,'float32');
[row col plane] = size(RGBValue);
BinRed = RGBValue(1:3:row);
BinGreen = RGBValue(2:3:row);
BinBlue = RGBValue(3:3:row);
RedImage = reshape(BinRed, [H W]);
GreenImage = reshape(BinGreen, [H W]);
BlueImage = reshape(BinBlue, [H W]);
Image = cat(3, RedImage, GreenImage, BlueImage);

gtRGBFile = fopen(gtFileName, 'r');
gtRGBValue = fread(gtRGBFile,'float32');
[row col plane] = size(RGBValue);
gtBinRed = gtRGBValue(1:3:row);
gtBinGreen = gtRGBValue(2:3:row);
gtBinBlue = gtRGBValue(3:3:row);
gtRedImage = reshape(gtBinRed, [H W]);
gtGreenImage = reshape(gtBinGreen, [H W]);
gtBlueImage = reshape(gtBinBlue, [H W]);
gtImage = cat(3, gtRedImage, gtGreenImage, gtBlueImage);

%PSNR Calculation
error = gtImage - Image;
MSE = sum(sum(sum(error.^2))) / (H * W * 3);
PSNR = 20*log10(max(max(max(gtImage))))-10*log10(MSE);
psnrValue = PSNR;

end