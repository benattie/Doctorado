# importo modulos
from winkel_fns import winkel_al, winkel_be
import subprocess
import numpy
###############################################################################
# leo el archivo de configuracion
f = open('para_cmwp.dat', 'r')
para_data = f.readlines()
pathspr = para_data[1][22:-1]
pathout = para_data[2][22:-1]
input_file = para_data[3][22:-1]
path_base_file = para_data[4][22:-1]
base_file = para_data[5][22:-1]
input_file_ext = para_data[6][22:-1]
spr_i = int(para_data[7][22:-1])
delta_spr = int(para_data[8][22:-1])
spr_f = int(para_data[9][22:-1])
omega_i = int(para_data[10][22:-1])
delta_omega = int(para_data[11][22:-1])
omega_f = int(para_data[12][22:-1])
pattern_i = int(para_data[13][22:-1])
delta_pattern = int(para_data[14][22:-1])
pattern_f = int(para_data[15][22:-1])

numrings = int(para_data[24][22:-1])
hkl = numpy.zeros(0)
theta = numpy.zeros(0)
for lines in para_data[27:]:
    hkl = numpy.append(hkl, int(lines.split()[0]))
    theta = numpy.append(theta, float(lines.split()[1]))

f.close()
###############################################################################
# Start CMWP fitting routine
# variables auxiliares
ext = ".dat"

# leo el physol del archivo inicial
# falta poner el archivo correcto
physsol_name = "%s%s.physsol.csv" % (path_base_file, base_file)
fp_physsol = open(physsol_name, "r")
lines = fp_physsol.readlines()
n_variables = len(lines[1].split("\t"))
n_spr = int((spr_f - spr_i + 1) / delta_spr)
n_pattern = int((pattern_f - pattern_i + 1) / delta_pattern)
shape = (n_spr, n_pattern, n_variables)
solutions = numpy.zeros(shape)

for spr in range(spr_i, spr_f, delta_spr):
    for pattern in range(pattern_i, pattern_f, delta_pattern):
        # copio el archivo ini
        origin = "%s/%s%s.ini" % (path_base_file, base_file, ext)
        destination = "%s/%s_spr_%d_pattern_%d%s.ini" % (pathout, input_file,
                                                         spr, pattern, ext)
        subprocess.call(["cp", origin, destination])
        # copio el archivo .q.ini
        origin = "%s/%s%s.q.ini" % (path_base_file, base_file, ext)
        destination = "%s/%s_spr_%d_pattern_%d%s.q.ini" % (pathout, input_file,
                                                           spr, pattern, ext)
        subprocess.call(["cp", origin, destination])
        # copio el archivo .fit.ini
        # aca habria que agregar algun flag para que se copie desde el archivo
        # anterior
        # tambien se podria agregar alguna rutina para implementar diferentes
        # estrategias de fiteo
        origin = "%s/%s%s.fit.ini" % (path_base_file, base_file, ext)
        destination = "%s/%s_spr_%d_pattern_%d%s.fit.ini" % (pathout,
                                                             input_file, spr,
                                                             pattern, ext)
        subprocess.call(["cp", origin, destination])
        # correr el cmwp
        cmd = './evaluate %s%s_spr_%d_pattern_%d%s auto' % (pathout, input_file,
                                                            spr, pattern, ext)
        subprocess.call(cmd, shell=True)
        # leo el physsol.csv y lo guardo en memoria
        name_solutions = "%s/%s_spr_%d_pattern_%d%s.physsol.csv" % (pathout,
                                                                    input_file,
                                                                    spr,
                                                                    pattern,
                                                                    ext)
        fp_solutions = open(name_solutions, "r")
        lines = fp_solutions.readlines()
        # guardo todas las soluciones fisicas del fit
        v = 0
        header = lines[0].split("\t")
        for x in lines[1].split("\t"):
            solutions[spr / delta_spr][pattern / delta_pattern][v] = float(x)
            v += 1
# end CMWP fitting routine
###############################################################################
# pasar a coordenadas de figuras de polos y dar salida a archivos
print("\n====== Begin angular transformation ====== \n")
for m in range(0, numrings):  # itero sobre todos los picos
    outfile = "%s%s_CMWP_PF_%d_%d.mtex" % (pathout, input_file, m, hkl[m])
    fp_cmwp = open(outfile, "w")
    fp_cmwp.write("# Row 2theta theta alpha beta ")
    for field in header:
        fp_cmwp.write("%s ", field)
    fp_cmwp.write("\n")
    fp_cmwp.flush()

    k = 0  # contador del archivo mtex
    spr = spr_i  # indice que me marca el spr
    # tranformacion angular (gamma, omega) -> (alpha, beta)
    for omega in range(omega_i, omega_f + 1, delta_omega):
        pattern = pattern_i
        for pattern in range(pattern_i, pattern_f + 1, delta_pattern):
            if(omega > 90):
                neu_ome = omega - 90
                neu_gam = pattern + 180
            else:
                neu_ome = omega
                neu_gam = pattern
            alpha = winkel_al(theta[m], neu_ome, neu_gam)
            beta = winkel_be(theta[m], neu_ome, neu_gam, alpha)
            if(alpha > 90):
                alpha = 180 - alpha
                beta = 360 - beta

            fp_cmwp.write("%8d %8.4f %8.4f %8.4f %8.4f %8.5f "
                          % (k + 1, 2 * theta[m], theta[m], alpha, beta))
            for i in range(1, solutions.shape[2]):
                fp_cmwp.write("%8.5f " % (solutions[spr / delta_spr]
                                          [pattern / delta_pattern][i]))
            fp_cmwp.write("\n")
            k += 1
        spr += delta_spr
    fp_cmwp.flush()
    fp_cmwp.close()
print("\n======= End angular transformation ======= \n")
###############################################################################
# pasar a figura de polos regular
