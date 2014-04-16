#script orientado a tomar un archivo separado por columnas con un separador arbitrario y luego descomponerlo en sucesivos archivos dif*.dat que consisten en datos xy de un difractograma. Los valores de x se obtienen de convertir el valor de un pixel a un valor angular a partir de la resolucion espacial de un pixel y la distancia muestra detector. x luego se pasa de radianes a grados sexadecimales. El valor de y correspondiente a cada x se consigue de cada una de las columnas del archivo ingresado

################################################INICIO DEL PROGRAMA####################################################
import sys
import numpy as np
import math
import subprocess as sub
#########################################################################

name = str(sys.argv[1]) #nombre del archivo de entrada
separator = str(sys.argv[2])
filename = str(sys.argv[3]) #nombre del archivo de salida
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
    aux = line[1:] #saco el primer caracter de la linea
    aux = aux.replace(separator, ',') #reemplazo el separador por una ','
    file_output.write(aux) #escribo al archivo
file_output.close()

########################################################################

#ahora que el archivo esta preparado empiezo a trabajar con los datos
diff = np.loadtxt(filename, delimiter = ',')
nrow = diff.shape[0] #360
ncol = diff.shape[1] #1725

########################################################################

#genero los difractogramas que quiero procesar automaticamente (y tambien los proceso)
for i in range(0, nrow, res): #recorro las filas del archivo de res en res
    name_dat = 'dif' + '{:0>3}'.format(str(i)) + '.dat' #genero el archivo de Inv vs 2theta
    f = open(name_dat, 'w')
    f.write('!2theta\tInt\n')
    for j in range(0, ncol):
        avg = 0
        for k in range(i, i + 5): # promedio cada 5 grados de giro de la muestra
            avg = avg + diff[k][j]
        x = math.atan(float(j) * 100e-6 / 1081e-3) * 180. / math.pi
        f.write('%.5f\t%.5f\n' % (x, avg / 5.)) # escribo 2theta y la Int promediada
    f.close() #termine de pasar el difractograma i al formato procesable por winplotr
    #llamo a winplotr
    
    #paso los datos del rst al rsts













###############################################FIN DEL PROGRAMA############################################################
