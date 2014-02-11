#import sys
import numpy as np
from winkel_fns import winkel_al, winkel_be
import re

##leer del para_fit2d.dat los parametros relevantes
rsts_i = 1 #rsts inicial
rsts_f = 37  #rsts final
rsts_d = 1 #salto en rsts

anf_gam = 0
ende_gam = 360
del_gam = 5

anf_ome = 1
ende_ome = 181
del_ome = 5


numrings = 7 # numero de picos

#tengo que hacer una figura de polos por cada pico del difractograma y por cada varible que me interese
#nombres de los archivos
names_theta = []
names_im = []
names_fwhm = []
names_eta = []
for i in range(1,numrings + 1):
    names_theta.append("al_theta_mpf_%d.dat" % i)
    names_im.append("al_im_mpf_%d.dat" % i)
    names_fwhm.append("al_fwhm_mpf_%d.dat" % i)
    names_eta.append("al_eta_mpf_%d.dat" % i)


#abro los archivos
fid_theta = [open(name, 'w') for name in names_theta]
fid_im = [open(name, 'w') for name in names_im]
fid_fwhm = [open(name, 'w') for name in names_fwhm]
fid_eta = [open(name, 'w') for name in names_eta]


#inicializo el buffer donde se van a almacenar los valores numericos
s = (ende_gam - anf_gam) / del_gam
s = s * numrings
theta = np.zeros(s + 1)
im = np.zeros(s + 1)
fwhm = np.zeros(s + 1)
eta = np.zeros(s + 1)


#escribo los encabezados de los archivos dat
aux = fid_theta + fid_im + fid_fwhm + fid_eta
for f in aux:
    f.write("anf., ende, schritt-gamma:              %8d%8d       %d\n" % (anf_gam, ende_gam, del_gam))
    f.write("anf., ende, schritt-omega:              %8d%8d%8d\n\n" % (anf_ome, del_ome, del_ome))

################################################################################################################################
print("\n====== procesando archvivos rsts ====== \n");
#lectura de los archivos rsts
for i in range(rsts_i, rsts_f + 1,  rsts_d): #itero sobre los 37 rsts (que es lo mismo que iterar sobre todos los omega)
    name_rsts = 'new_al70r-tex_' + '{:0>5}'.format(str(i)) + '.rsts' #leo el rsts
    f_rsts = open(name_rsts, 'r')
    buf = f_rsts.readlines()
    a_theta = 0
    a_theta = np.array(a_theta)
    a_im = 0
    a_im = np.array(a_im)
    a_fwhm = 0
    a_fwhm = np.array(a_fwhm)
    a_eta = 0
    a_eta = np.array(a_eta)
    for j in range(0, np.size(buf), numrings + 4): # itero sobre todo el archivo rsts, de bloque en bloque (que es lo mismo que iterar sobre todos los gammas)
	for k in range(0, numrings, 1): # itero sobre todos los picos
	    buf[(j + 2) + k] = re.sub("[*]+", "-1", buf[(j + 2) + k])
	    auxf = np.fromstring(buf[(j + 2) + k], sep='    ') # tomo la informacion de la fila y la paso a matriz
            a_theta = np.append(a_theta, auxf[0])
            a_im = np.append(a_im, auxf[2])
            a_fwhm = np.append(a_fwhm, auxf[4])
            a_eta = np.append(a_eta, auxf[6])

    theta = np.vstack([theta, a_theta])
    im = np.vstack([im, a_im])
    fwhm = np.vstack([fwhm, a_fwhm])
    eta = np.vstack([eta, a_eta])
    f_rsts.close()
## a estas alturas tengo cargados todos los datos en los vectores correspondientes. ahora hay que escribirlos en formato maquina
## cada vector tiene su primer fila y columna hecha de ceros
## cada matriz consiste en 72 bloques (variacion en gamma) de datos, consistiendo cada bloque en 7 columnas
## cada matriz tiene 37 filas (el numero de archivos rsts)


rows = theta.shape[0] #37
cols = theta.shape[1] #72*7 = 504
#fin de la lectura de los archivos rsts
###################################################################################################################################

ncols = 12 #especifica cuantas columnas tiene el archvivo .dat
dspace = 0 #define si pongo una linea en blanco entre bloque de datos
##################################################################################################################################
#conversion a formato maquina
print("\n====== transformacion a formato maquina (rsts --> dat) ====== \n");
for i in range(1, numrings + 1): #itero sobre todos los picos
    f_theta = fid_theta[i - 1]
    f_im = fid_im[i - 1]
    f_fwhm = fid_fwhm[i - 1]
    f_eta = fid_eta[i - 1]


    for k in range(1, rows): #itero sobre las 37 filas (que es lo mismo que iterar sobre todos los omega)
        count = 0
	for j in range(i, cols, numrings): #recorro los gamma
	    count += 1
	    f_theta.write('%10.2f' %theta[k][j])
            f_im.write('%10.1f' %im[k][j])
            f_fwhm.write('%10.3f' %fwhm[k][j])
            f_eta.write('%10.3f' %eta[k][j])
            if ((count % ncols) == 0):
                f_theta.write('\n')
                f_im.write('\n')
                f_fwhm.write('\n')
                f_eta.write('\n')
        if(dspace == 1):
            if(cols % ncols == 0):
                f_theta.write('\n')
                f_im.write('\n')
                f_fwhm.write('\n')
                f_eta.write('\n')
            else:
                f_theta.write('\n\n')
                f_im.write('\n\n')
                f_fwhm.write('\n\n')
                f_eta.write('\n\n')


aux = fid_theta + fid_im + fid_fwhm + fid_eta
for f in aux:
    f.close()
# fin de la conversion aformato maquina
###############################################################################################################################
#############################################################################################################################
