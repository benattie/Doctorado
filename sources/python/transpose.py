# script orientado a tomar un archivo separado por columnas con un separador
# arbitrario y luego descomponerlo en sucesivos archivos dif*.dat que consisten
# en datos xy de un difractograma. Los valores de x se obtienen de convertir el
# valor de un pixel a un valor angular a partir de la resolucion espacial de un
# pixel y la distancia muestra detector. x luego se pasa de radianes a grados
# sexadecimales. El valor de y correspondiente a cada x se consigue de cada una
# de las columnas del archivo ingresado

# python transpose.py name res
# ###########################INICIO DEL PROGRAMA###############################
import numpy as np
import math
import subprocess as sub
import sys
###############################################################################
name = str(sys.argv[1])  # nombre del archivo de entrada
separator = '  '
filename = name + '_trans.dat'  # nombre del archivo de salida
# res = raw_input("Ingrese la resolucion angular deseada:\n")
res = int(sys.argv[2])  # resolucion con la que deseo tener los difractogramas.
# En general no tiene mucho sentido tener una resolucion mejor que de 5 grados.

sub.call(['dos2unix', name])  # paso a codificacion UNIX
# #############################################################################
# en este tramo del programa hago lo que antes hacia usando la linea de comando
# de linux. Tomo el archivo que me pasaron, le quito primer linea, saco el
# caracter de espacio que esta al principio, elimino el doble espacio que esta
# entre las columnas y lo reemplazo con una ','.
# CUIDADO, QUE AHORA NO LO ESTOY TRANSPONIENDO!!!!
fp_spr = open(name, 'r')
# leo eliminando el encabezado
lines = fp_spr.readlines()[1:]
fp_spr.close()

fp_csv = open(filename, 'w')
for line in lines:
    # saco el primer caracter de la linea
    aux = line[1:]
    aux = aux.replace(separator, ',')  # reemplazo el separador por una ','
    fp_csv.write(aux)  # escribo al archivo
fp_csv.close()

# ahora que el archivo esta preparado empiezo a trabajar con los datos
diff = np.loadtxt(filename, delimiter=',')
nrow = diff.shape[0]  # 360
ncol = diff.shape[1]  # 1725
command = "rm " + filename
sub.call(command, shell=True)
##############################################################################
# imprimo promediado segun res
f_name = name + '_trs.csv'  # archivo en el escribo los datos transpuestos en
# un formato graficable por gnuplot
f = open(f_name, 'w')
f.write("\"2theta\",")
mystr = name + '_avtrs_' + str(res) + '.csv'
f_av_trs = open(mystr, 'w')  # archivo en el que escribo los datos promediados
# en un formato graficable por gnuplot
f_av_trs.write("\"2theta\",")

for i in range(0, nrow):  # imprimo los encabezados
    f.write('\"dif' + '{:0>3}'.format(str(i)) + "\",")
    if ((i % res) == 0):
        f_av_trs.write('\"dif' + '{:0>3}'.format(str(i)) + "\",")
f.write("\n")
f.flush()

f_av_trs.write("\n")
f_av_trs.flush()

for i in range(0, ncol):
    f.write('%.5f,' % (math.atan(float(i) * 100e-6 / 1081e-3) *
                       180. / math.pi))  # columna de los angulos
    f_av_trs.write('%.5f,' % (math.atan(float(i) * 100e-6 / 1081e-3) *
                              180. / math.pi))  # columna de los angulos
    avg = 0.0
    for j in range(0, nrow):
        avg = avg + diff[j][i]
        f.write('%.5f,' % (diff[j][i]))  # imprimo los datos transpuestos
        if (((j + 1) % res) == 0):
            f_av_trs.write('%.5f,' % (avg / float(res)))  # imprimo el promedio
            avg = 0
    f.write('\n')
    f_av_trs.write('\n')
f.close()
f_av_trs.close()
##############################################################################
