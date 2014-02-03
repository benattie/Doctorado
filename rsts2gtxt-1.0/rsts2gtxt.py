import sys
import numpy as np
import re

##leer del para_fit2d.dat los parametros relevantes
rsts_i = 1 #rsts inicial
rsts_f = 1  #rsts final
rsts_d = 1 #salto en rsts

om_i = 1
om_f = 181
om_d = 1

gamm_i = 0
gamm_f = 360
gamm_d = 5

numrings = 7 # numero de picos

#tengo que hacer una figura de polos por cada pico del difractograma y por cada varible que me interese
#nombres de los archivos
names_theta = []
names_IM = []
names_FWHM = []
names_ETA = []
for i in range(1,numrings + 1):
    names_theta.append("Al_theta_PF_%d.dat" % i)
    names_IM.append("Al_IM_PF_%d.dat" % i)
    names_FWHM.append("Al_FWHM_PF_%d.dat" % i)
    names_ETA.append("Al_ETA_PF_%d.dat" % i)


#abro los archivos
fid_theta = [open(name, 'w') for name in names_theta] 
fid_IM = [open(name, 'w') for name in names_IM] 
fid_FWHM = [open(name, 'w') for name in names_FWHM] 
fid_ETA = [open(name, 'w') for name in names_ETA]


#inicializo el buffer donde se van a almacenar los valores numericos
s = (gamm_f - gamm_i)/gamm_d
s = s * numrings
theta = np.zeros(s + 1)
IM = np.zeros(s + 1)
FWHM = np.zeros(s + 1)
ETA = np.zeros(s + 1)


#escribo los encabezados de los archivos dat
aux = fid_theta + fid_IM + fid_FWHM + fid_ETA
for f in aux: 
    f.write("Anf., Ende, Schritt-Gamma:              %8d%8d       %d\n" % (gamm_i, gamm_f, gamm_d))
    f.write("Anf., Ende, Schritt-Omega:              %8d%8d%8d\n\n" % (om_i, om_f, om_d))

################################################################################################################################
for i in range(rsts_i, rsts_f + 1,  rsts_d): #itero sobre los 37 rsts (que es lo mismo que iterar sobre todos los omega)
    name_rsts = 'New_Al70R-tex_' + '{:0>5}'.format(str(i)) + '.rsts' #leo el rsts
    f_rsts = open(name_rsts, 'r')
    buf = f_rsts.readlines()
    a_theta = 0
    a_theta = np.array(a_theta)
    a_IM = 0
    a_IM = np.array(a_IM)
    a_FWHM = 0
    a_FWHM = np.array(a_FWHM)
    a_ETA = 0
    a_ETA = np.array(a_ETA)
    for j in range(0, np.size(buf), numrings + 4): # itero sobre todo el archivo rsts, de bloque en bloque (que es lo mismo que iterar sobre todos los gammas) 
	for k in range(0, numrings, 1): # itero sobre todos los picos
	    buf[(j + 2) + k] = re.sub("[*]+", "-1", buf[(j + 2) + k]) 
	    auxf = np.fromstring(buf[(j + 2) + k], sep='    ') # tomo la informacion de la fila y la paso a matriz
            a_theta = np.append(a_theta, auxf[0])
            a_IM = np.append(a_IM, auxf[2])
            a_FWHM = np.append(a_FWHM, auxf[4])
            a_ETA = np.append(a_ETA, auxf[6])
    
    theta = np.vstack([theta, a_theta])
    IM = np.vstack([IM, a_IM])
    FWHM = np.vstack([FWHM, a_FWHM])
    ETA = np.vstack([ETA, a_ETA])
    f_rsts.close()
## a estas alturas tengo cargados todos los datos en los vectores correspondientes. Ahora hay que escribirlos en formato maquina
## cada vector tiene su primer fila y columna hecha de ceros
## cada matriz consiste en 72 bloques (variacion en gamma) de datos, consistiendo cada bloque en 7 columnas
## cada matriz tiene 37 filas (el numero de archivos rsts)


rows = theta.shape[0] #37
cols = theta.shape[1] #72*7 = 504
###################################################################################################################################


##################################################################################################################################
for i in range(1, numrings + 1): #itero sobre todos los picos
    f_theta = fid_theta[i - 1]
    f_IM = fid_IM[i - 1]
    f_FWHM = fid_FWHM[i - 1]
    f_ETA = fid_ETA[i - 1]
   

    for k in range(1, rows): #itero sobre las 37 filas (que es lo mismo que iterar sobre todos los omega)
        count = 0
	for j in range(i, cols, numrings): #recorro los gamma
	    count += 1
	    f_theta.write('%8.3f' %theta[k][j])
            f_IM.write('%8.3f' %IM[k][j])
            f_FWHM.write('%8.3f' %FWHM[k][j])
            f_ETA.write('%8.3f' %ETA[k][j])
            if ((count % 10) == 0):
                f_theta.write('\n')
                f_IM.write('\n')
                f_FWHM.write('\n')
                f_ETA.write('\n')
        f_theta.write('\n')
        f_IM.write('\n')
        f_FWHM.write('\n')
        f_ETA.write('\n')

## en este punto tengo todas las figuras de polos en formato maquina

##aca iria el ejecutable de C que transforma de formato maquina a formato figura de polos

aux = fid_theta + fid_IM + fid_FWHM + fid_ETA
for f in aux:
    f.close()
