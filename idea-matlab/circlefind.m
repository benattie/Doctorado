clear all
close all

%% Import image
imgname = 'New_Al70R-tex_0001';
imgval = imread([imgname '.tif']);
% imshow(imgval);
% Increase contrast
img_corr = adapthisteq(imgval);
% imshow(img_corr)

% Radii search zone
rmin =  [700 1200];
rmax = [800 1300];
rsize = max(size(rmin));

%% Get center of image
xcenter = 0;
ycenter = 0;
mradii = 0;
for i = 1:rsize
    [center{i}, radii{i}] = imfindcircles(img_corr, [rmin(i) rmax(i)], 'ObjectPolarity','dark', 'Sensitivity',0.99);
    viscircles(center{i}, radii{i},'EdgeColor','b');
    xcenter = xcenter + center{i}(1,1);
    ycenter = ycenter + center{i}(1,2);
    mradii = mradii + radii{i};
end
xcenter = xcenter / max(size(radii));
ycenter = ycenter / max(size(radii));

%% Extract the data
start = 0;
step = 10;
stop = 360 - step;
R = 4000;
outfile = [imgname '.dat'];
fid = fopen(outfile, 'w');
for gamma = start:step:stop
    indx = gamma / step + 1;
    x = [xcenter xcenter + R*cos(gamma*degree)];
    y = [ycenter ycenter + R*sin(gamma*degree)];
    c{indx} = improfile(imgval,x,y);
    c{indx}(isnan(c{indx})) = [];
    c{indx} = -1*(c{indx} - 255);
    c{indx}(end) = 1;
    g = sprintf('%d ', c{indx});
    fprintf(fid, '%s\n', g);
%     plot(c{indx})
%     k = waitforbuttonpress;
end
fclose(fid)