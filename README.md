Acá figura un conjunto de scripts de python, código C, más algún que otro programita y archivos de configuración accesorios.

aux files/: archivos necesarios para correr los programas siguientes. Contiene información relevante de los ajustes, como dónde se van a guardar los archivos de salida, la cantidad de archivos de entrada, etc.
    para_fit2d.dat
    para_linkgss.dat

gnuplot_script_generator-1.0/: scripts que permiten generar scripts de gnuplot para procesar masivamente los datos obtenidos de los ajustes
    gpl_scrip_gen.py

rsts2gtxt/: código para transformar tomar los datos de un archivo rsts (salida de spr2rsts) convertirlos escribirlos en formato máquina para finalmente escribirlos en figura de polos generalizadas. Para esto último uso el programa de transormación angular de Sabo
    angular_transformation.c
    rsts2gtxt.py


