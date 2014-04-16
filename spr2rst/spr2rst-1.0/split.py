#script orientado a tomar un archivo separado por columnas con un separador arbitrario y luego descomponerlo en sucesivos archivos dif*.dat que consisten en datos xy de un difractograma. Los valores de x se obtienen de convertir el valor de un pixel a un valor angular a partir de la resolucion espacial de un pixel y la distancia muestra detector. x luego se pasa de radianes a grados sexadecimales. El valor de y correspondiente a cada x se consigue de cada una de las columnas del archivo ingresado
import numpy as np
import math

name=raw_input('Ingrese el nombre del archivo:\n')
separator=raw_input('Ingrese el tipo de delimitador:\n')

diff = np.loadtxt(name, delimiter=separator)
nrow=diff.shape[0]
ncol=diff.shape[1]
sum = np.zeros(shape=(nrow,1))

for i in range(0,ncol):
    name='dif'+'{:0>3}'.format(str(i))+'.dat'
    f = open(name, 'w')
    f.write('#2theta\tInt\n')
    for j in range(0,nrow):
	x=math.atan(float(j)*100e-6/1081e-3)*180./math.pi
	f.write('%.5f\t%.5f\n' % (x, diff[j][i]))
	f.close()

f = open('average.dat', 'w')
f.write('#2theta\tAvInt\n')
for j in range(0,nrow):
    x = math.atan(float(j)*100e-6/1081e-3)*180./math.pi
    av = np.average(diff[j])
    f.write('%.5f\t%.5f\n' % (x, av))
f.close()
