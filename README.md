Acá figura un conjunto de scripts de python, código C, más algún que otro programita y archivos de configuración accesorios que fui generando junto durante el doctorado.

aux data files/: archivos necesarios para correr los programas siguientes. Contiene información relevante de los ajustes, como dónde se van a guardar los archivos de salida, la cantidad de archivos de entrada, etc.
status_error_codes.txt --> salidas del programa para hacer ajustes no lineales de la gsl
Makefile --> makefile para compilar en C usando la gsl
Instructivo.txt --> instructivo para utilizar idea
IRF.dat --> Archivo con los parametros de Caglioti para sustraer el ancho intrumental en idea
fit_ini.dat --> valores iniciales de los parametros que fitea idea
para_fit2d.dat
parafit2d.xlsx --> tabla de conversion de bin a 2theta
PARA_LIN2GKSS.dat

aux code files/:
gnuplot_script_generator-1.0/: scripts que permiten generar scripts de gnuplot para procesar masivamente los datos obtenidos de los ajustes
    gpl_scrip_gen.py
interpolate/:
    programas para encontrar la relacion entre los anchos de pico de una pseudo-voigt y una voigt
root_ply/: 
    programas para encontrar raices de polinomios
Williamson Hall(Nati):
    programas para encontrar factores de contraste necesarios para hacer WIlliamson-Hall con mediciones de ancho de pico.

aux bin files/:
    transpose.py: script que transpone un archivo spr y lo pone en un formato graficable por gnuplot y procesable por winplotr
    winplotr: programa para poder ajustar difractogramas

older versions/:
    código de versiones viejas del software idea

idea-2.1/:
    version actual de idea



