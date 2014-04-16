#script orientado a tomar un archivo separado por columnas con un separador arbitrario y luego descomponerlo en sucesivos archivos dif*.dat que consisten en datos xy de un difractograma. Los valores de x se obtienen de convertir el valor de un pixel a un valor angular a partir de la resolucion espacial de un pixel y la distancia muestra detector. x luego se pasa de radianes a grados sexadecimales. El valor de y correspondiente a cada x se consigue de cada una de las columnas del archivo ingresado
#este srcipt es la combinacion de los archivos spr2csv.py, run_winplotr.py, rst2rsts.py, en ese orden
################################################INICIO DEL PROGRAMA####################################################
import sys
import numpy as np
import math
import subprocess as sub
import re
#########################################################################
#print str(sys.argv)
#for i in range(0,8):
#    print "Argv " + str(i) + "is: " + str(sys.argv[i])

name = str(sys.argv[1]) # nombre del archivo de entrada (marfile)
separator = str(sys.argv[2]) # separador del archivo spr ("  ")
filename = str(sys.argv[3]) # nombre del archivo de salida (csv_file)
res = 5 # resolucion con la que deseo tener los difractogramas. En general no tiene mucho sentido tener una resolucion mejor que de 5 grados

########################################################################

sub.call(['dos2unix', name]) #paso a codificacion UNIX

#Tomo el archivo que me pasaron, le quito primer linea, saco el caracter de espacio que esta al principio, elimino el doble espacio que esta entre las columnas y lo reemplazo con una ','. CUIDADO, QUE AHORA NO LO ESTOY TRANSPONIENDO!!!!
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
comment = "#"
f_rst = open(str(sys.argv[4]), 'w') #rsts_file
n = int(sys.argv[5]) #numrings

para_data = open("para_fit2d.dat", 'r')
buf_str = para_data.readlines()[22:]
fit_cmd = ''
for line in buf_str:
    line = re.split(" +", line) #convierto la linea en un array de strings

    aux1 = float(line[4])
    aux1 = math.atan(aux1 * 100e-6 / 1081e-3) * 180. / math.pi

    aux2 = float(line[5])
    aux2 = math.atan(aux2 * 100e-6 / 1081e-3) * 180. / math.pi
#    print "%.3f %.3f\n" % (aux1, aux2)
    fit_cmd = fit_cmd + 'FIT_SINGLE_PEAK %.3f %.3f' % (aux1, aux2) + '\n'
#    print fit_cmd
para_data.close()

#genero los difractogramas que quiero procesar automaticamente
for i in range(0, nrow, res): #recorro las filas del archivo de res en res
    buf = str(sys.argv[6]) #sys.argv[6] = difs_file
    name_dat = buf + 'dif' + '{:0>3}'.format(str(i)) + '.dat' #genero el archivo de Inv vs 2theta
    f_dat = open(name_dat, 'w')
    f_dat.write('!2theta\tInt\n')
    for j in range(0, ncol):
        avg = 0
        for k in range(i, i + res): # promedio cada 5 grados de giro de la muestra
            avg = avg + diff[k][j]
        x = math.atan(float(j) * 100e-6 / 1081e-3) * 180. / math.pi
        f_dat.write('%.5f\t%.5f\n' % (x, avg / float(res))) # escribo 2theta y la Int promediada
    f_dat.close() #termine de pasar el difractograma i al formato procesable por winplotr
    
    #proceso el archivo con winplotr
    name_cmd = 'fit_winplotr_' + '{:0>3}'.format(str(i)) + '.cmd' #genero el archivo con los comandos de winplotr
    f_cmd = open(name_cmd, 'w')
    f_cmd.write('FILE ' + name_dat + ' 1\n')
    #f_cmd.write('FIT_SINGLE_PEAK 3.177 3.705\nFIT_SINGLE_PEAK 3.863 4.312\nFIT_SINGLE_PEAK 5.548 5.863\nFIT_SINGLE_PEAK 6.518 6.857\nFIT_SINGLE_PEAK 6.857 7.145\nFIT_SINGLE_PEAK 7.900 8.186\nFIT_SINGLE_PEAK 8.653 8.937\n')#esto lo podria armar con los datos del para_fit2d.dat
    f_cmd.write(fit_cmd)
    f_cmd.close()
    sub.call('winplotr ' + name_cmd) #llamo al archivo de winplotr que acabo de generar


    #paso los datos del rst al rsts
    name_rst = buf.upper() + 'DIF' + '{:0>3}'.format(str(i)) + '_PF.RST' #abro el archivo que va a contener todos los rst
    f_rst.write(comment + name_rst + ' ' + str(sys.argv[7]) + '\n') #sys.argv[7] == filename1
    f_rst.write(comment + '2theta(deg.)\tsig_2th\tIntensity\tsig_int\tFWHM\tFWHM_sig\tETA\tETA_sig\n')
    f_rst.flush() #vacio el buffer antes de seguir escribiendo
    rst_handler = open(name_rst, 'r') #abro el archvio rst del que voy a sacar los datos
    lines = rst_handler.readlines()[-n:] # leo las ultimas n lineas del archivo de datos
    for line in lines: # escribo las lineas que acabo de leer
	f_rst.write(line)
    f_rst.write('\n\n') #doble enter para separar los indices en gnuplot

f_rst.close()
###############################################FIN DEL PROGRAMA############################################################
