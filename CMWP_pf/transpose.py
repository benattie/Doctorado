#python transpose.py name res end
################################################INICIO DEL PROGRAMA####################################################
import numpy as np
import math
import subprocess as sub
import sys
#########################################################################
name = str(sys.argv[1]) #nombre del archivo de entrada
separator = '  '
filename = name + '_trans.dat' #nombre del archivo de salida
#res = raw_input("Ingrese la resolucion angular deseada:\n")
res = int(sys.argv[2]) # resolucion con la que deseo tener los difractogramas. En general no tiene mucho sentido tener una resolucion mejor que de 5 grados
#res = 4
#sub.call(['dos2unix', name]) #paso a codificacion UNIX
########################################################################
#en este tramo del programa hago lo que antes hacia usando la linea de comando de linux. Tomo el archivo que me pasaron, le quito primer linea, saco el caracter de espacio que esta al principio, elimino el doble espacio que esta entre las columnas y lo reemplazo con una ','. CUIDADO, QUE AHORA NO LO ESTOY TRANSPONIENDO!!!!
fp_spr = open(name, 'r')
#leo eliminando el encabezado
lines = fp_spr.readlines()[1:]
fp_spr.close()

fp_csv = open(filename, 'w')
for line in lines:
    #saco el primer caracter de la linea
    aux = line[1:]
    aux = aux.replace(separator, ' ') #reemplazo el separador por un ' '
    fp_csv.write(aux) #escribo al archivo
fp_csv.close()

#ahora que el archivo esta preparado empiezo a trabajar con los datos
diff = np.loadtxt(filename, delimiter = ' ')
nrow = diff.shape[0] #360
ncol = diff.shape[1] #1725
end = int(sys.argv[3])
command = "rm " + filename
sub.call(command, shell=True)
#########################################################################
#Imprimo un archivo para cada difractograma
avg = np.zeros(ncol, dtype=float)
avg_all = np.zeros(ncol, dtype=float)
for i in range(0, nrow):
    avg = avg + diff[i]
    avg_all = avg_all + diff[i]
    if((i + 1) % res == 0):
        name = 'Al70R_spr_1_gamma_' + '{:0>3}'.format(str((i + 1) - res)) + ".dat"
        fp = open(name, 'w')
        for j in range(0, end):
            dostheta = math.atan(float(j) * 100e-6 / 1081e-3) * 180. / math.pi
            fp.write('%.5f %.5f\n' % (dostheta, avg[j] / float(res)))
        avg = np.zeros(ncol, dtype=float)
        fp.close()

fp = open("Al70R_gamma_avg.dat", 'w')
for j in range(0, end):
    dostheta = math.atan(float(j) * 100e-6 / 1081e-3) * 180. / math.pi
    fp.write('%.5f %.5f\n' % (dostheta, avg_all[j] / float(nrow)))
fp.close()
########################################################################
