% uso
% export_reg_PF(polefigure, archivo_de_salida)
function export_reg_PF(pf, fname)
    inten = get(pf, 'intensities');
    fid = fopen(fname, 'w');
    k = 1;
    for al = 1:5:91
       for be = 1:5:360
          fprintf(fid, '%7.0f', inten(k));
          if(mod(k, 10) == 0)
              fprintf(fid, '\n');
          end
          k = k + 1;
       end
    end
    fclose(fid);
end
