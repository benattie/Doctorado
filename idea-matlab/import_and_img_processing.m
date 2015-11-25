img = imread('input/5ARB-tex_new_0001_16b.tif', 'tif')

imgadj = imadjust(img);
h = fspecial('gaussian', [15 15],7);
imgfilter = imfilter(img, h);
[center, radii] = imfindcircles(img, [760 770], 'Sensitivity', 0.99);
viscircles(center, radii,'EdgeColor','r');