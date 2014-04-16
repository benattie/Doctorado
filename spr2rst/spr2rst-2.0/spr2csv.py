#script orientado a tomar un archivo separado por columnas con un separador arbitrario y luego descomponerlo en sucesivos archivos dif*.dat que consisten en datos xy de un difractograma. Los valores de x se obtienen de convertir el valor de un pixel a un valor angular a partir de la resolucion espacial de un pixel y la distancia muestra detector. x luego se pasa de radianes a grados sexadecimales. El valor de y correspondiente a cada x se consigue de cada una de las columnas del archivo ingresado

#script orientado a generar un archivo cmd que luego pueda correr en winplotr para ajustar funciones pseudo voight a los picos de un difractograma. La posicion de los picos deber ser ubicada a mano. Los nombres de los archivos de datos utilizados (los dif*.dat) son los obtenidos del script split.py que deberia esta en el mismo directorio
################################################INICIO DEL PROGRAMA####################################################
import numpy as np
import math
import subprocess as sub
#########################################################################

name = raw_input ('Ingrese el nombre del archivo de entrada:\n') #nombre del archivo de entrada
separator = raw_input ('Ingrese el tipo de delimitador:\n')

name = name.replace("\r", "") #elimino el caracter del carriage return para hacerlo compatibla con windor. Si saco esta linea no me encuentra el archivo
#separator = separator.replace("\r", "")

filename = raw_input('Ingrese el nombre del archivo de salida:\n') #nombre del archivo de salida
#res = raw_input("Ingrese la resolucion angular deseada:\n")
res = 5 # resolucion con la que deseo tener los difractogramas. En general no tiene mucho sentido tener una resolucion mejor que de 5 grados

########################################################################

sub.call(['dos2unix', name]) #paso a codificacion UNIX

#en este tramo del programa hago lo que antes hacia usando la linea de comando de linux. Tomo el archivo que me pasaron, le quito primer linea, saco el caracter de espacio que esta al principio, elimino el doble espacio que esta entre las columnas y lo reemplazo con una ','. CUIDADO, QUE AHORA NO LO ESTOY TRANSPONIENDO!!!!
file_input = open(name, 'r')
#leo eliminando el encabezado
lines = file_input.readlines()[1:]
file_input.close()

file_output = open(filename, 'w')
for line in lines:
    #saco el primer caracter de la linea
    aux = line[1:]
    aux = aux.replace(separator, ',') #reemplazo el separador por una ','
    file_output.write(aux) #escribo al archivo
file_output.close()

########################################################################

#ahora que el archivo esta preparado empiezo a trabajar con los datos
diff = np.loadtxt(filename, delimiter = ',')
nrow = diff.shape[0] #360
ncol = diff.shape[1] #1725

########################################################################

#imprimo el archivo con los datos transpuestos (no es necesario para lo que necesito pero igual me puede ser util)
#tambien los imprimo promediados segun res
f_name = name + '_trs.csv' #archivo en el escribo los datos transpuestos en un formato graficable por gnuplot
f = open(f_name, 'w')
f.write("\"2theta\",")

mystr = name + '_trs_av.csv'
f_av_trs = open(mystr, 'w') #archivo en el que escribo los datos promediados en un formato graficable por gnuplot
f_av_trs.write("\"2theta\",")

for i in range(0, nrow): # imprimo los encabezados
    f.write('\"dif' + '{:0>3}'.format(str(i)) + "\",")
    if ((i%res) == 0):
        f_av_trs.write('\"dif' + '{:0>3}'.format(str(i)) + "\",")

f.write("\n")
f.flush()

f_av_trs.write("\n")
f_av_trs.flush()

for i in range(0, ncol):
    f.write('%.5f,' % (math.atan(float(i) * 100e-6 / 1081e-3) * 180. / math.pi)) #columna de los angulos
    f_av_trs.write('%.5f,' % (math.atan(float(i) * 100e-6 / 1081e-3) * 180. / math.pi)) #columna de los angulos
    avg = 0.
    for j in range(0, nrow):
        avg = avg + diff[j][i]
        f.write('%.5f,' % (diff[j][i])) #imprimo los datos transpuestos
        if (((j + 1) % res) == 0):
            f_av_trs.write('%.5f,' % (avg / float(res))) #imprimo el promedio
            avg = 0
    f.write('\n')
    f_av_trs.write('\n')
f.close()
f_av_trs.close()

########################################################################
