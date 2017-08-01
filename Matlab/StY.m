H = 512;
W = 512;
mask=zeros(H,W);
G2=1278;
G1=1873;
inc=abs(G2-G1);
pixel = 0.7;
NUM=H*W*pixel;
x=0;y=0;N=0;

while N<NUM
    if and(x<W, y<H)
        mask(sub2ind(size(mask), y+1, x+1))=1;
        N=N+1;
    end
    x=mod(x+inc, G1);
    y=mod(y+inc, G2);
end

%mask=logical(mask);

mask=mask';
im =imread('../resultImages/backpackRotate.jpg');
im = im2double(im);
R = im(:,:,1);
G = im(:,:,2);
B = im(:,:,3);
red = R .* mask;
green = G .* mask;
blue = B .* mask;
image = cat(3, red, green, blue);
imshow(image,[]);
%imshow(mask);

