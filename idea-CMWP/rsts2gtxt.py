# import sys
import numpy as np
import subprocess as sub

# leer del para_fit2d.dat los parametros relevantes
# saco los datos que necesito del para_fit2d.dat
f = open('..\para_fit2d.dat', 'r')
para_data = f.readlines()
name_root = para_data[5][22:-1]

rsts_i = int(para_data[7][22:-1])  # rsts inicial
rsts_f = int(para_data[9][22:-1])  # rsts final
rsts_d = int(para_data[11][22:-1])  # salto en rsts

anf_gam = int(para_data[13][22:-1])
ende_gam = int(para_data[14][22:-1]) + 1
del_gam = 5

anf_ome = int(para_data[8][22:-1])
ende_ome = int(para_data[10][22:-1])
del_ome = int(para_data[12][22:-1])


numrings = int(para_data[19][22:-1])  # numero de picos

# inicializo el buffer donde se van a almacenar los valores numericos
s = (ende_gam - anf_gam) / del_gam
s = s * numrings
theta = np.zeros(s + 1)
im = np.zeros(s + 1)
fwhm = np.zeros(s + 1)
eta = np.zeros(s + 1)


###############################################################################
print("\n====== procesando archvivos rsts ====== \n")
buf = []
# lectura de los archivos rsts
for i in range(rsts_i, rsts_f + 1,  rsts_d):  # itero sobre los 37 rsts (que es lo mismo que iterar sobre todos los omega)
    name_rsts = name_root + '{:0>5}'.format(str(i)) + '.rsts'  # leo el rsts
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
    # print i
    for j in range(0, np.size(buf), numrings + 4):  # itero sobre todo el archivo rsts, de bloque en bloque (que es lo mismo que iterar sobre todos los gammas)
        # print j
        for k in range(0, numrings, 1):  # itero sobre todos los picos
            # print k
            buf[(j + 2) + k] = re.sub('\*\*\*\*\*\*\*\*\*\*\*\*', " ***", buf[(j + 2) + k])
            buf[(j + 2) + k] = re.sub('\*+', "-1", buf[(j + 2) + k])
            auxf = np.fromstring(buf[(j + 2) + k], sep='    ')  # tomo la informacion de la fila y la paso a matriz
            # print auxf
            a_theta = np.append(a_theta, auxf[0])
            a_im = np.append(a_im, auxf[2])
            a_fwhm = np.append(a_fwhm, auxf[4])
            a_eta = np.append(a_eta, auxf[6])

    theta = np.vstack([theta, a_theta])
    im = np.vstack([im, a_im])
    fwhm = np.vstack([fwhm, a_fwhm])
    eta = np.vstack([eta, a_eta])
    f_rsts.close()
# a estas alturas tengo cargados todos los datos en los vectores correspondientes. ahora hay que escribirlos en formato maquina
# cada vector tiene su primer fila y columna hecha de ceros
# cada matriz consiste en 72 bloques (variacion en gamma) de datos, consistiendo cada bloque en 7 columnas
# cada matriz tiene 37 filas (el numero de archivos rsts)


rows = theta.shape[0]  # 37
cols = theta.shape[1]  # 72*7 = 504
# fin de la lectura de los archivos rsts
###############################################################################

###############################################################################
# conversion a formato maquina
print("\n====== transformacion a formato maquina (rsts --> dat) ====== \n")

sub.call("mkdir mpf")
# tengo que hacer una figura de polos por cada pico del difractograma y por cada varible que me interese
# nombres de los archivos
names_theta = []
names_im = []
names_fwhm = []
names_eta = []
for i in range(1, numrings + 1):
    buf_str = []
    buf_str = "mpf/" + name_root + "theta_%d.mpf" % i
    names_theta.append(buf_str)

    buf_str = []
    buf_str = "mpf/" + name_root + "im_%d.mpf" % i
    names_im.append(buf_str)

    buf_str = []
    buf_str = "mpf/" + name_root + "fwhm_%d.mpf" % i
    names_fwhm.append(buf_str)

    buf_str = []
    buf_str = "mpf/" + name_root + "eta_%d.mpf" % i
    names_eta.append(buf_str)


# abro los archivos
fid_theta = [open(name, 'w') for name in names_theta]
fid_im = [open(name, 'w') for name in names_im]
fid_fwhm = [open(name, 'w') for name in names_fwhm]
fid_eta = [open(name, 'w') for name in names_eta]

# escribo los encabezados de los archivos dat
aux = fid_theta + fid_im + fid_fwhm + fid_eta
for f in aux:
    f.write("anf., ende, schritt-gamma:              %8d%8d       %d\n" % (anf_gam, ende_gam, del_gam))
    f.write("anf., ende, schritt-omega:              %8d%8d%8d\n\n" % (anf_ome, del_ome, del_ome))


for i in range(1, numrings + 1):  # itero sobre todos los picos
    # print i
    f_theta = fid_theta[i - 1]
    f_im = fid_im[i - 1]
    f_fwhm = fid_fwhm[i - 1]
    f_eta = fid_eta[i - 1]

    for k in range(1, rows):  # itero sobre las 37 filas (que es lo mismo que iterar sobre todos los omega)
        count = 0
    for j in range(i, cols, numrings):  # recorro los gamma
        count += 1
        f_theta.write('%12.3f' % theta[k][j])
        f_im.write('%12.2f' % im[k][j])
        f_fwhm.write('%12.4f' % fwhm[k][j])
        f_eta.write('%12.4f' % eta[k][j])
        if ((count % 12) == 0):
            f_theta.write('\n')
            f_im.write('\n')
            f_fwhm.write('\n')
            f_eta.write('\n')
#        f_theta.write('\n\n')
#        f_im.write('\n\n')
#        f_fwhm.write('\n\n')
#        f_eta.write('\n\n')


aux = fid_theta + fid_im + fid_fwhm + fid_eta
for f in aux:
    f.close()
# fin de la conversion a formato maquina
###############################################################################
###############################################################################
# conversion de formato maquina a formato figura de polos
print("\n====== begin angular transformation ====== \n")

# obtengo los angulos de los picos del para_fit2d
buf = para_data[22:]
theta = []
for line in buf:
    aux = np.fromstring(line, sep=' ')
    theta.append(aux[0])
f.close()

# creo el directorio donde se van a guardar los mtex
sub.call("mkdir mtex")


for i in range(1, numrings + 1):
    # print i
    # step = 1 #si step > 1 lo que hago es promediar step's intensidades de la figura de polos en formato maquina

    # abro los archivos con los datos en formato maquina
    names = [names_theta[i - 1], names_im[i - 1], names_fwhm[i - 1], names_eta[i - 1]]
    fid_in = [open(name, 'r') for name in names]

    # abro los archivos en formato figura de polos (mtex)
    names = ["mtex/" + name_root + 'theta_%d.mtex' % i, "mtex/" + name_root + "im_%d.mtex" % i, "mtex/" + name_root + 'fwhm_%d.mtex' % i, "mtex/" + name_root + 'eta_%d.mtex' % i]
    fid_mtex = [open(name, 'w') for name in names]

    # names = ['PF_GRID_theta_%d.dat' % i, 'PF_GRID_theta_im_%d.dat' % i, 'PF_GRID_fwhm_%d.dat' % i, 'PF_GRID_eta_%d.dat' % i]
    # fid_grid = [open(name, 'w') for name in names]

    for j in range(0, 4):  # itero sobre cada figura de polos generalizada
        f_in = fid_in[j]
        f_mtex = fid_mtex[j]
        # f_grid = fid_grid[j]

        lines = f_in.readlines()[:]

        # leo el \gamma inicial, el final y el salto
        # buf_str = re.split(" +", lines[0])
        # anf_gam = int(buf_str[3])
        # ende_gam = int(buf_str[4])
        # del_gam = int(buf_str[5])

        # leo el \omega inicial, el final y el salto
        # buf_str = re.split(" +", lines[1])
        # anf_ome = int(buf_str[3])
        # ende_ome = int(buf_str[4])
        # del_ome = int(buf_str[5])

        print("anf_gam=%5d , end_gam=%5d , del_gam=%5d \nanf_ome=%5.1f , end_ome=%5.1f , del_ome=%5.1f \n\n" % (anf_gam, ende_gam, del_gam, anf_ome, ende_ome, del_ome))
        step_ome = abs((ende_ome - anf_ome) / del_ome)

        if(ende_ome < anf_ome):
            del_ome = -1 * del_ome

        buf_str = lines[3:]  # me quedo solo con las lineas de numeros
        buf_float = []
        for line in buf_str:
            line = re.split(" +", line)  # convierto la linea en un array de strings
            line = line[1:]  # elimino el primer elemento (es un espacio en blanco)
            float_line = map(float, line)  # convierto a float
            buf_float = np.append(buf_float, float_line)  # lo paso a un array lineal

        # buf_float = np.array(buf_float) # lo paso a array numpy
        # buf_float = buf_float.flatten() #pasar el array a linea

        k = 0  # contador del arcihvo grid y del mtex; contador que recorre todos los valores de la matriz de valores
        # print "i = %d\tj = %d\n" % (i, j)
        # tranformacion angular (gamma, omega)-->(alpha,beta)
        if(ende_ome > anf_ome):
            w = anf_ome  # cambiar i por w
            while(w < ende_ome):  # itero sobre \omega: (saque el =)
                for g in range(anf_gam, ende_gam, del_gam):  # itero sobre \gamma, cambiar j por g
                    neu_gam1 = g
                    neu_ome1 = w
                    # transformacion geometrica
                    if(neu_ome1 > 90):
                        neu_ome = neu_ome1 - 90
                        neu_gam = neu_gam1 + 180
                    else:
                        neu_ome = neu_ome1
                        neu_gam = neu_gam1

                    alpha = winkel_al(theta[i - 1], neu_ome, neu_gam)  # agarrar theta de algun lado
                    beta = winkel_be(theta[i - 1], neu_ome, neu_gam, alpha)  # idem anterior

                    if(alpha > 90):
                        alpha = 180 - alpha
                        beta = 360 - beta
                    else:
                        alpha = alpha

                    # imprimo las intensidades en formato figura de polos, asi como el grid
                    if(theta > 0):
                        f_mtex.write("%11d%10.3f%10.3f%10.4f%10.4f%12.4f\n" % (k + 1, 2 * theta[i - 1], theta[i - 1], alpha, beta, buf_float[k]))
#                       fprintf(fp1,"%11d%10.4f%10.4f%10.4f%10.4f%12.0f\n"
#                       ,k+1,2*theta[m],theta[m],alpha,beta,nn_intens); #traducir, recordar que fp1 es el archvio mtex
                    else:
                        f_mtex.write("%11d%10.4f%10.4f%10.4f%10.4f%12.4f\n" % (k + 1, -2 * theta[i - 1], -1 * theta[i - 1], alpha, beta, buf_float[k]))
#                       fprintf(fp1,"%11d%10.4f%10.4f%10.4f%10.4f%12.0f\n"
#                       ,k+1,-2*theta[m],-1*theta[m],alpha,beta,nn_intens);#traducir

#                   f_grid.write("%11d%10.1f%10.1f%10.4f%10.4f\n" % (k + 1, neu_ome, neu_gam, alpha, beta))
#                   fprintf(fp3,"%11d%10.1f%10.1f%10.4f%10.4f\n"
#                   ,k+1,neu_ome,neu_gam,alpha,beta); #traducir, recordar que fp3 es el archivo grid

                    k += 1
                w += del_ome
        else:
            w = anf_ome
            while(w > ende_ome):  # (saque el =)
                for g in range(anf_gam, ende_gam, del_gam):
                    neu_gam = g
                    neu_ome = w

                    alpha = winkel_al(theta[i - 1], neu_ome, neu_gam)  # sacar theta de algun lado
                    beta = winkel_be(theta[i - 1], neu_ome, neu_gam, alpha)  # idem

                    if(alpha > 90):
                        alpha = 180 - alpha
                        beta = 360 - beta
                    else:
                        alpha = alpha

                    if(theta > 0):
                        f_mtex.write("%11d%10.4f%10.4f%10.4f%10.4f%12.4f\n" % (k + 1, 2 * theta[i - 1], theta[i - 1], alpha, beta, buf_float[k]))
#                        fprintf(fp1,"%11d%10.4f%10.4f%10.4f%10.4f%12.0f\n"
#                        ,k+1,2*theta[m],theta[m],alpha,beta,m_intens); #traducir
                    else:
                        f_mtex.write("%11d%10.4f%10.4f%10.4f%10.4f%12.4f\n" % (k + 1, -2 * theta[i - 1], -1 * theta[i - 1], alpha, beta, buf_float[k]))
#                        fprintf(fp1,"%11d%10.4f%10.4f%10.4f%10.4f%12.0f\n"
#                        ,k+1,-2*theta[m],-1*theta[m],alpha,beta,m_intens); #traducir

#                   f_grid.write("%11d%10.1f%10.1f%10.4f%10.4f\n" % (k + 1, neu_ome, neu_gam, alpha, beta))

#                    fprintf(fp3,"%11d%10.1f%10.1f%10.4f%10.4f\n"
#                    ,k+1,neu_ome,neu_gam,alpha,beta); #traducir

                    k += 1
                w += del_ome

            f_in.flush()
            f_mtex.flush()
#           f_grid.flush()
            # fflush(fp1); fflush(fp2); fflush(fp3);
    aux = fid_in + fid_mtex  # + fid_grid
    for f in aux:
        f.close()
###############################################################################
