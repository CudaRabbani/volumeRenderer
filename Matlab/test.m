GH = 782
GW = 1029
% path = '../textFiles/Pattern/';
% patternString = [num2str(GH) 'by' num2str(GW) ];
% path = strcat(path,patternString,'/');
% name = [patternString '.txt'];
% name = strcat(path,name);
name = '../textFiles/tester.txt';
pattern = fopen(name, 'r');

mask = fscanf(pattern,'%d');
mask = reshape(mask, [GH,GW]);
imshow(mask)