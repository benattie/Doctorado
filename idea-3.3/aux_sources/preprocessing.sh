#ln -s ../../bin/extract_columns.sh ./
sh extract_columns.sh files.txt
mkdir cut_pole_figures
mkdir cut_pole_figures/scripts
mkdir cut_pole_figures/raw
cp /home/benattie/Documents/Doctorado/XR/Sync/AlSR70/out/cut_pole_figures/scripts/*.m ./cut_pole_figures/scripts/
cd cut_pole_figures
mv *ALL* raw
cd scripts
# sed -i 's/out/out2/g' *
# rename 's/AlSR70/ALAR70/' *.m
# rename 's/Al70R/AlARMH/' *.m
# sed -i 's/New_Al70R/Al-AR-M-H/g' *
# sed -i 's/Al70R/AlARMH/g' *
# sed -i 's/th8/th5/g' *
# sed -i 's/Tex/tex/g' *
