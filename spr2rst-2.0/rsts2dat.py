#script orientado a tomar los valores de un archivo .RST generado por winplotr, para luego construir un archivo separado por tabulaciones y comentado para gnuplot.

#En primer lugar el programa toma un archivo de la forma data_name_inicial + numero + data_name_final + . + data_format (ingresados por el usuario), donde numero es la variable i del programa y todos los archivos deseados. Luego se extraen las ultimas n filas del archivo .RST. Una vez recorridos todos los archivos deseados se construye el archivo .dat final que luego se puede graficar utilizando su programa favorito.

#CUIDADO: LAS LINEAS COMENTADAS INICIAN CON UN '#'. MODIFICAR LA VARIABLE comment SI SE VA UTILIZAR UN PROGRAMA QUE USE OTRA MARCA DE COMENTARIO

#import subprocess as sub
#from sh import tail

comment ='#'
#las siguientes lineas me dan el patron de los nombres de los archivos de datos
data_name_inicial = raw_input('Ingrese la raiz del nombre del archivo de datos:\n')
data_name_final = raw_input('Ingrese la desinencia del nombre del archivo de datos:\n')
data_format = raw_input('Ingrese la extension del archivo del que se extraeran los datos (sin el punto):\n')

data_id = raw_input('Escriba un encabezado que identifique todos los datos:\n')

data_inicial = raw_input('Ingrese el numero del primer archivo de datos:\n')
data_final = raw_input('Ingrese el numero del ultimo archivo de datos:\n')

n_filas = raw_input('Ingrese el numero de filas a extraer del archivo de datos:\n')
file_name = raw_input('Ingrese el nombre del archivo de salida (con extension):\n')

res = raw_input('Ingrese el espaciamiento angular entre los datos:\n')


#armado del archivo propiamente dicho
f = open(file_name, 'w')

for i in range (int(data_inicial), int(data_final) + 1, int(res)):
    name_dat = data_name_inicial + '{:0>3}'.format(str(i)) + data_name_final + '.' + data_format
    f.write(comment + name_dat + ' ' + data_id + '\n')
    f.write(comment + '2theta(deg.)\tsig_2th\tIntensity\tsig_int\tFWHM\tFWHM_sig\tETA\tETA_sig\n')
    f.flush() #vacio el buffer antes de seguir escribiendo
    n = int(n_filas)
    rst_handler = open(name_dat, 'r')
    lines = rst_handler.readlines()[-n:] # leo las ultimas n lineas del archivo de datos
    for line in lines: # escribo las lineas que acabo de leer
	f.write(line)
    f.write('\n\n') #doble enter para separar los indices en gnuplot

#funciona en un unix os o en un windows con COREutils
#    args = '-n' + n_filas
#    tail(name_dat, args, _out=f)
#	sub.call('tail -' + n_filas + ' ' + name_dat, stdout=f)
f.close()
