import subprocess
import numpy
import sys

# estos parametros debo obtenerlos de idea-cmwp.c a traves de argv
spr_i = 1
spr_f = 2
pattern_i = 1
pattern_f = 2
path = "/home/benattie/Documents/Doctorado/Git/idea-CMWP/"
cmwp_input_path = "Al70R/"
root_name = "Al70R"
ext = ".dat"
# leo el physol del archivo inicial
# falta poner el archivo correcto
name_solutions = "%s%s.physsol.csv" % (path, root_name)
fp_solutions = open(name_solutions, "r")
lines = fp_solutions.readlines()
variables = len(lines[1].split("\t"))
shape = (spr_f, pattern_f, variables)
solutions = numpy.zeros(shape)

for spr in range(spr_i, spr_f):
    for pattern in range(pattern_i, pattern_f):
        # copio el archivo ini
        origin = "%s/%s%s.ini" % (path, root_name, ext)
        destination = "%s/%s_spr_%d_pattern_%d%s.ini" % (path, root_name, spr,
                                                         pattern, ext)
        subprocess.call(["cp", origin, destination])
        # copio el archivo .q.ini
        origin = "%s/%s%s.q.ini" % (path, root_name, ext)
        destination = "%s/%s_spr_%d_pattern_%d%s.q.ini" % (path, root_name,
                                                           spr, pattern, ext)
        subprocess.call(["cp", origin, destination])
        # copio el archivo .fit.ini
        # aca habria que agregar algun flag para que se copie desde el archivo
        # anterior
        # tambien se podria agregar alguna rutina para implementar diferentes
        # estrategias de fiteo
        origin = "%s/%s%s.fit.ini" % (path, root_name, ext)
        destination = "%s/%s_spr_%d_pattern_%d%s.fit.ini" % (path, root_name,
                                                             spr, pattern, ext)
        subprocess.call(["cp", origin, destination])
        # correr el cmwp
        cmd = './evaluate data/%s%s_spr_%d_pattern_%d%s auto' % (cmwp_input_path,
                                                                 root_name,
                                                                 spr, pattern,
                                                                 ext)
        subprocess.call(cmd, shell=True)
        # leo el physsol.csv y lo guardo en memoria
        name_solutions = "%s/%s_spr_%d_pattern_%d%s.physsol.csv" % (path,
                                                                    root_name,
                                                                    spr,
                                                                    pattern,
                                                                    ext)
        fp_solutions = open(name_solutions, "r")
        lines = fp_solutions.readlines()
        # guardo todas las soluciones fisicas del fiteo
        physsol = numpy.zeros(0)
        for x in lines[1].split("\t"):
            physsol = numpy.append(physsol, float(x))
        # aca van las soluciones que voy a graficar
        for v in range(0, variables):
            solutions[spr][pattern][v] = physsol[v]

# pasar a coordenadas de figuras de polos y dar salida a archivos
# pasar a figura de polos regular
