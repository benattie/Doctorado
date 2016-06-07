function find_circle(I)
    %% Get the image
    I_row = reshape(I, 1, numel(I));
    I_max = quantile(I_row, 0.99);
    I_g = mat2gray(I, [0 I_max]);
%     imshow(I_g)
    %% Get center of image
    % Radii search zone
    I_prof = improfile(I_g, [1725 3450], [1725 1725]);
    sel = (max(I_prof) - min(I_prof)) / 20;
    tresh = 0.5;
    peakLoc = peakfinder(I_prof, sel, tresh, 1, 0);
    delta = 25;
    for i=1:length(peakLoc)
        rmin(i) = peakLoc(i) - delta;
        rmax(i) = peakLoc(i) + delta;
    end
    rsize = length(rmin);
    xcenter = 0;
    ycenter = 0;
    n = 0;
    for i = 1:rsize
        [center{i}, radii{i}] = imfindcircles(I_g, [rmin(i) rmax(i)], 'ObjectPolarity','bright' , 'Sensitivity',0.99, 'EdgeThreshold',0.1);
        if (~isempty(radii{i}))
%             viscircles(center{i}, radii{i},'EdgeColor','b');
            xcenter = xcenter + center{i}(1,1);
            ycenter = ycenter + center{i}(1,2);
            n = n + 1;
        end
    end
    xcenter = xcenter / n;
    ycenter = ycenter / n;
    
    %% Extract the data
    start = 0;
    step = 5;
    stop = 360 - step;
    R = 4000;
    imgname = 'New_Al70R-tex_0001_hist';
    outfile = [imgname '.dat'];
    fid = fopen(outfile, 'w');
    for gamma = start:step:stop
        indx = gamma / step + 1;
        x = [xcenter xcenter + R*cos(gamma*degree)];
        y = [ycenter ycenter + R*sin(gamma*degree)];
        c{indx} = improfile(I, x, y, 1725);
        c{indx}(isnan(c{indx})) = [];
        g = sprintf('%d ', c{indx});
        fprintf(fid, '%s\n', g);
        plot(c{indx})
        axis([0,1725,0,inf])
        waitforbuttonpress;
    end
    fclose(fid);
end