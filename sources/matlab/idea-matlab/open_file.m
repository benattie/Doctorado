function [header, I] = open_file()
    system('./read_mar.exe New_Al70R-tex_0001.mar3450 New_Al70R-tex_0001_header.txt New_Al70R-tex_0001.dat');
    header = fileread('New_Al70R-tex_0001_header.txt');
    I = importdata('New_Al70R-tex_0001.dat');
    image(I)
end