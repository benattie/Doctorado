#import sys
import numpy as np
import winkel_fns
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
    names_theta.append("Al_theta_MPF_%d.dat" % i)
    names_IM.append("Al_IM_MPF_%d.dat" % i)
    names_FWHM.append("Al_FWHM_MPF_%d.dat" % i)
    names_ETA.append("Al_ETA_MPF_%d.dat" % i)


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
#lectura de los archivos rsts
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
#fin de la lectura de los archivos rsts
###################################################################################################################################


##################################################################################################################################
#conversion a formato maquina
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


aux = fid_theta + fid_IM + fid_FWHM + fid_ETA
for f in aux:
    f.close()
# fin de la conversion aformato maquina
###############################################################################################################################
#############################################################################################################################
#conversion de formato maquina a formato figura de polos
print("\n====== Begin angular transformation ====== \n");
for i in range(1, numrings + 1):
    step = 1 #Si step > 1 lo que hago es promediar step's intensidades de la figura de polos en formato maquina

    #abro los archivos con los dato en formato maquina
    fid_theta = [open(name, 'r') for name in names_theta]
    fid_IM = [open(name, 'r') for name in names_IM]
    fid_FWHM = [open(name, 'r') for name in names_FWHM]
    fid_ETA = [open(name, 'r') for name in names_ETA]

    names_theta = []
    names_IM = []
    names_FWHM = []
    names_ETA = []
    for j in range(1,numrings + 1):
        names_theta.append("Al_theta_PF_%d.dat" % j)
        names_IM.append("Al_IM_PF_%d.dat" % j)
        names_FWHM.append("Al_FWHM_PF_%d.dat" % j)
        names_ETA.append("Al_ETA_PF_%d.dat" % j)

    fid_theta2 = [open(name, 'w') for name in names_theta]
    fid_IM2 = [open(name, 'w') for name in names_IM]
    fid_FWHM2 = [open(name, 'w') for name in names_FWHM]
    fid_ETA2 = [open(name, 'w') for name in names_ETA]

        #//leo el \gamma inicial, el final y el salto
        #fgets(buf,42,fp2);
        #fscanf(fp2,"%d",&anf_gam);
        #fscanf(fp2,"%d",&ende_gam);
        #fscanf(fp2,"%d",&del_gam);

        #fgets(buf,2,fp2);//skip line

        #//leo el \omega inicial, el final y el salto
        #fgets(buf,42,fp2);
        #fscanf(fp2,"%f",&anf_ome);
        #fscanf(fp2,"%f",&ende_ome);
        #fscanf(fp2,"%f",&del_ome);

        #printf("anf_gam=%5d , end_gam=%5d , del_gam=%5d \nanf_ome=%5.1f , end_ome=%5.1f , del_ome=%5.1f \n\n",anf_gam,ende_gam,del_gam,anf_ome,ende_ome,del_ome);
        #step_ome=abs((ende_ome-anf_ome)/del_ome);

        #if(ende_ome<anf_ome)
            #del_ome=-1*del_ome;

        #//Imprimo el tiempo de ejecucion del programa en el .mtex
        #fprintf(fp1,"  FIT2D_DATA.exe: %d-%2d-%2d %2d:%2d:%2d\n",zeit->tm_year + 1900,zeit->tm_mon + 1,zeit->tm_mday,zeit->tm_hour,zeit->tm_min,zeit->tm_sec);

        #k=0;//numero de pico
        #//tranformacion angular (gamma, omega)-->(alpha,beta)
        #if(ende_ome>anf_ome)
        #{
            #i=anf_ome;
            #while(i<=ende_ome)//itero sobre \omega
            #{
                #for(j=anf_gam;j<=ende_gam;j+=del_gam)//itero sobre \gamma
                #{
                    #neu_gam1=j;
                    #neu_ome1=i;
                    #//transformacion geometrica
					#if(neu_ome1>90)
					#{
                        #neu_ome = neu_ome1-90;
						#neu_gam = neu_gam1+180;
                    #}
                    #else
                    #{
                        #neu_ome = neu_ome1;
                        #neu_gam = neu_gam1;
                    #}

                    #alpha = winkel_al(theta[m],neu_ome,neu_gam);

                    #beta  = winkel_be(theta[m],neu_ome,neu_gam,alpha);

                    #if(j%step==0)
                    #{
                        #n_intens=0;
                        #for(l=1;l<=step;l++)
                        #{
                            #fscanf(fp2,"%f",&m_intens);//leo la intensidad de la figura de polos en formato maquina
                            #n_intens += m_intens;
                        #}

                        #nn_intens=n_intens/step;

                        #if(alpha>90)
                        #{
                            #alpha=180-alpha;
                            #beta=360-beta;
						#}
                        #else
                            #alpha=alpha;

                        #//imprimo las intensidades en formato figura de polos, asi como el grid
						#if(theta>0)
                        #{
                            #fprintf(fp1,"%11d%10.4f%10.4f%10.4f%10.4f%12.0f\n"
                            #,k+1,2*theta[m],theta[m],alpha,beta,nn_intens);
                        #}
                        #else
                        #{
                            #fprintf(fp1,"%11d%10.4f%10.4f%10.4f%10.4f%12.0f\n"
                            #,k+1,-2*theta[m],-1*theta[m],alpha,beta,nn_intens);
                        #}

						#fprintf(fp3,"%11d%10.1f%10.1f%10.4f%10.4f\n"
                        #,k+1,neu_ome,neu_gam,alpha,beta);

                        #k++;
                    #}
                #}
                #i+=del_ome;
            #}
        #}
        #else
        #{
            #i=anf_ome;
            #while(i>=ende_ome)
            #{
                #for(j=anf_gam;j<=ende_gam;j+=del_gam)
                #{
                    #neu_gam=j;
                    #neu_ome=i;

                    #alpha = winkel_al(theta[m],neu_ome,neu_gam);

                    #beta  = winkel_be(theta[m],neu_ome,neu_gam,alpha);

                    #fscanf(fp2,"%f",&m_intens);

                    #if(j%step==0)
                    #{
                        #if(alpha>90)
                        #{
                            #alpha=180-alpha;
                            #beta=360-beta;
                        #}
                        #else
                            #alpha=alpha;

                        #if(theta>0)
                        #{
                            #fprintf(fp1,"%11d%10.4f%10.4f%10.4f%10.4f%12.0f\n"
                            #,k+1,2*theta[m],theta[m],alpha,beta,m_intens);
                        #}
                        #else
                        #{
                            #fprintf(fp1,"%11d%10.4f%10.4f%10.4f%10.4f%12.0f\n"
                            #,k+1,-2*theta[m],-1*theta[m],alpha,beta,m_intens);
                        #}

                        #fprintf(fp3,"%11d%10.1f%10.1f%10.4f%10.4f\n"
                        #,k+1,neu_ome,neu_gam,alpha,beta);

                        #k++;
                    #}
                #}
                #i+=del_ome;
            #}
        #}
        #fflush(fp1); fflush(fp2); fflush(fp3);
        #fclose(fp3); fclose(fp1); fclose(fp2);


    #

#############################################################################################################################
