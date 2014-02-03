#script orientado a tomar un archivo separado por columnas con un separador arbitrario y luego descomponerlo en sucesivos archivos dif*.dat que consisten en datos xy de un difractograma. Los valores de x se obtienen de convertir el valor de un pixel a un valor angular a partir de la resolucion espacial de un pixel y la distancia muestra detector. x luego se pasa de radianes a grados sexadecimales. El valor de y correspondiente a cada x se consigue de cada una de las columnas del archivo ingresado

#script orientado a generar un archivo cmd que luego pueda correr en winplotr para ajustar funciones pseudo voight a los picos de un difractograma. La posicion de los picos deber ser ubicada a mano. Los nombres de los archivos de datos utilizados (los dif*.dat) son los obtenidos del script split.py que deberia esta en el mismo directorio
import numpy as np
import math
import subprocess as sub

name=raw_input('Ingrese el nombre del archivo:\n')
separator=raw_input('Ingrese el tipo de delimitador:\n')

diff = np.loadtxt(name, delimiter=separator)
nrow=diff.shape[0]
ncol=diff.shape[1]

for i in range(0,ncol): 
    name_dat='dif'+'{:0>3}'.format(str(i))+'.dat'
    f = open(name_dat, 'w')
    f.write('!2theta\tInt\n')
    for j in range(0,nrow):
        x=math.atan(float(j)*100e-6/1081e-3)*180./math.pi
        f.write('%.5f\t%.5f\n' % (x, diff[j][i]))
        f.close()
    #parte de winplotr del programa. Lo puse aca porque deberia hacer que el programa sea mas eficiente
        name_cmd='fit_win'+'{:0>3}'.format(str(i))+'.cmd'
        f = open(name_cmd, 'w')
        f.write('FILE '+ name_dat + ' 1\n')
        f.write('FIT_SINGLE_PEAK 3.388 3.573\nFIT_SINGLE_PEAK 3.942 4.101\nFIT_SINGLE_PEAK 5.600 5.810\nFIT_SINGLE_PEAK 6.596 6.753\nFIT_SINGLE_PEAK 6.884 7.040\nFIT_SINGLE_PEAK 7.952 8.160\nFIT_SINGLE_PEAK 8.678 8.886\nFIT_SINGLE_PEAK 8.937 9.067\n')
        f.close()
        sub.call('winplotr '+name_cmd)
