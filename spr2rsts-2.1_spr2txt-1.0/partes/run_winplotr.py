#script orientado a generar un archivo cmd que luego pueda correr en winplotr para ajustar funciones pseudo voight a los picos de un difractograma. La posicion de los picos deber ser ubicada a mano. Los nombres de los archivos de datos utilizados (los dif*.dat) son los obtenidos del script split.py que deberia esta en el mismo directorio
################################################INICIO DEL PROGRAMA####################################################
import subprocess as sub

name = raw_input('Ingrese la raiz de los archivos:\n')
ext = raw_input('Ingrese la extension de los archivos\n')

start = raw_input ('Ingrese numero del archivo inicial:\n') #nombre del archivo de entrada
fin = raw_input ('Ingrese el numero del archivo final:\n')
skip = raw_input('Ingrese la resolucion angular:\n')

for i in range(int(start), int(fin) + 1, int(skip)):
    name_dat = name + '{:0>3}'.format(str(i)) + ext
    name_cmd = 'fit_win' + '{:0>3}'.format(str(i)) + '.cmd' #genero el archivo con los comandos de winplotr
    f = open(name_cmd, 'w')
    f.write('FILE ' + name_dat + ' 1\n')
    f.write('FIT_SINGLE_PEAK 3.392 3.578\nFIT_SINGLE_PEAK 3.948 4.108\nFIT_SINGLE_PEAK 5.618 5.830\nFIT_SINGLE_PEAK 6.625 6.784\nFIT_SINGLE_PEAK 6.916 7.076\nFIT_SINGLE_PEAK 8.003 8.215\nFIT_SINGLE_PEAK 8.745 8.957\n')
    f.close()
    sub.call('winplotr ' + name_cmd) #llamo al archivo de winplotr que acabo de generar
#limpio el directorio de todos los archivos innecesarios (me quedo solamente con los archivos RST y los new)
sub.call('rm *.OUT *.REF *.XRF *.cmd')

