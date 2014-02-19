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

f_av_trs = open('Al1726x74.csv', 'w') #archivo en el que escribo los datos promediados en un formato graficable por gnuplot
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
    f.close()

###############################################FIN DEL PROGRAMA############################################################

    #parte de winplotr del programa. Lo puse aca porque deberia hacer que el programa sea mas eficiente
#    name_cmd = 'fit_win' + '{:0>3}'.format(str(i)) + '.cmd' #genero el archivo con los comandos de winplotr
#    f = open(name_cmd, 'w')
#    f.write('FILE ' + name_dat + ' 1\n')
#    f.write('FIT_SINGLE_PEAK 3.388 3.573\nFIT_SINGLE_PEAK 3.942 4.101\nFIT_SINGLE_PEAK 5.600 5.810\nFIT_SINGLE_PEAK 6.596 6.753\nFIT_SINGLE_PEAK 6.884 7.040\nFIT_SINGLE_PEAK 7.952 8.160\nFIT_SINGLE_PEAK 8.678 8.886\nFIT_SINGLE_PEAK 8.937 9.067\n')
#   f.close()
#    sub.call('winplotr ' + name_cmd) #llamo al archivo de winplotr que acabo de generar

#haciendo el transpose.sh utilizando subprocess. Es poco eficiente y no es multiplataforma por eso no lo uso mas. Lo dejo aca para tener ejemplos de como usar subprocess con pipes.

#aux_str = "sed 1d" + name + "aux.txt"
#sub.Popen(aux_str, shell=True) # elimino la primer linea del archivo
#grep -c '\r' filename (comando para chequear si el archivo esta en formato UNIX)
#forma correcta
#p1 = sub.Popen(['less', 'aux.txt'], stdout=sub.PIPE)
#out_file = open('aux2.txt', 'w')
#p2 = sub.Popen(['tr', '-s', '\' \''], stdin=p1.stdout, stdout=out_file)
#p1.stdout.close()  # Allow p1 to receive a SIGPIPE if p2 exits.
#output = p2.communicate()[0]
#forma insegura pero facil
#sub.Popen("less aux.txt | tr -s ' ' > aux2.txt", shell=True) #elimino los espacios repetidos
