import numpy as np
import re
import subprocess

"""
Buscar una cadena de caracteres en filename
devolver un array con el contenido de filename y con el numero de linea
en que aparece chain
"""


def searchlineinfile(filename, chain):
    fp = open(filename, "r")
    lines = fp.readlines()
    fp.close()
    ln = 0
    while(not(lines[ln].startswith(chain))):
        if(ln == len(lines) - 1):
            return (1, 1)
        else:
            ln += 1
    return (lines, ln)

"""
Buscar una cadena de caracteres en data
devolvuelve el numero de linea en que aparece chain
"""


def searchlineintext(data, chain):
    ln = 0
    while(not(data[ln].startswith(chain))):
        if(ln == len(data) - 1):
            return (1, 1)
        else:
            ln += 1
    return ln

"""
Define cadenas de caracteres que me interesan buscar.
Son todas las formas en que puede aparecer un numero en un archivo
"""


def searchableitems():
    searches = []
    # float con punto en la mantisa y exponente seguido de un + o -
    searches.append("[-+]?\d*\.\d+e[-+]\d+")
    # entero seguido de un exponente segido de un + o -
    searches.append("[-+]?\d*e[-+]\d+")
    # float sin exponente
    searches.append("[-+]?\d*\.\d+")
    # entero
    searches.append("[-+]?\d+")
    find = "%s|%s|%s|%s" % (searches[0], searches[1], searches[2], searches[3])
    return find


"""
Dado el contenido de un archivo (en forma de array)
devuelve una lista de cinco elementos conteniendo el resultado
de los ajustes del cmwp (valor final, error absoluto, error relativo)
Si no encuentra nada le pone un cero.
"""


def getcmwpsolutions(data, ln):
    find = searchableitems()
    if(data[ln].startswith("a")):
        a = np.array(map(float, re.findall(find, data[ln])))
        ln += 1
    if(data[ln].startswith("b")):
        b = np.array(map(float, re.findall(find, data[ln])))
        ln += 1
    if(data[ln].startswith("c")):
        c = np.array(map(float, re.findall(find, data[ln])))
        ln += 1
    if(data[ln].startswith("d")):
        d = np.array(map(float, re.findall(find, data[ln])))
        ln += 1
    if(data[ln].startswith("e")):
        e = np.array(map(float, re.findall(find, data[ln])))
        ln += 1
    return (a, b, c, d, e)

"""
Implementa una estrategia de ajuste de CMWP a partir de los datos obtenidos de
filename.
"""


def fit_strategy(filename, files, rings, spr, pattern, flag, find):
    chain = "# Fitting strategy"
    (data, ln) = searchlineinfile(filename, chain)
    if(data == 1):
        print "Wrong fit.ini file (there's no fitting strategy)"
        return -1
    else:
        fit_int = data[ln + 2].replace("\n", "")
        nsteps = int(data[ln + 4])
        fit_steps = np.zeros((nsteps, 6), dtype=str)
        for i in range(nsteps):
            fit_steps[i] = data[ln+6+i].split()

        if(fit_int.lower() == 'y'):
            set_fit_intensity(files, rings, spr, pattern, flag, find, "y")
            fit_flags = np.array(['0', 'n', 'n', 'n', 'n', 'n'])
            sol_file = set_sol_file(files, rings, spr, pattern)
            fit_cmwp(files, rings, spr, pattern, flag, find, fit_flags)
            set_fit_intensity(files, rings, spr, pattern, flag, find, "n")
            sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file, spr, pattern)
            for i in range(nsteps):
                physsol_file = fit_cmwp(files, sol_file, rings, spr, pattern, flag, find, fit_steps[i])
        else:
            set_fit_intensity(files, rings, spr, pattern, flag, find, "n")
            set_sol_file(files, rings, spr, pattern)
            physsol_file = fit_cmwp(files, sol_file, rings, spr, pattern, flag, find, fit_steps[0])
            sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file, spr, pattern)
            for i in range(1, nsteps):
                physsol_file = fit_cmwp(files, sol_file, rings, spr, pattern, flag, find, fit_steps[i])
        return physsol_file

"""
Prepara los archivos .ini del cmwp para que se ajusten las intensidades de los
picos o no. Esto lo determina el valor de la variable fit_int que debe ser un
string 'y' o 'n'
"""


def set_fit_intensity(files, rings, spr, pattern, flag, find, fit_int):
    # copio el archivo ini
    origin = "%s%s%s.ini" % (files.path_base_file, files.base_file, files.ext)
    destination = "%s%sspr_%d_pattern_%d%s.ini" % (files.pathout, files.input_file,
                                                   spr, pattern, files.ext)
    subprocess.call(["cp", origin, destination])
    # genero el archivo .q.ini
    origin = "%s%s%s.q.ini" % (files.path_base_file, files.base_file, files.ext)
    fp = open(origin, "r")
    lines = fp.readlines()
    fp.close()
    destination = "%s%sspr_%d_pattern_%d%s.q.ini" % (files.pathout, files.input_file,
                                                     spr, pattern, files.ext)
    chain = "FIT_LIMIT"
    ln = searchlineintext(lines, chain)
    if(fit_int == "y"):
        lines[ln] = "FIT_LIMIT=1e-9\n"
    else:
        lines[ln] = "FIT_LIMIT=1e-12\n"
    chain = "peak_pos_fit"
    ln = searchlineintext(lines, chain)
    if(lines == 1):
        chain = "peak_int_fit"
        ln = searchlineintext(lines, chain)
    lines[ln] = "peak_pos_fit=" + fit_int + "\n"
    lines[ln + 1] = "peak_int_fit=" + fit_int + "\n"
    fp = open(destination, "w")
    fp.writelines(lines)
    fp.close()

"""
Prepara los archivos para hacer un ajuste con el CMWP y corre el mismo.
fit_flags es un vector de caracteres 'y' o 'n' que indican si deben ajustarse
las variables a,b,c,d,e.
"""


def fit_cmwp(files, sol_file, rings, spr, pattern, flag, find, fit_flags):
    chain = "a_scaled"
    (lines, ln) = searchlineinfile(sol_file, chain)
    if (lines == 1):
        return 1
    ln = 0
    a = float(re.findall(find, lines[ln + 0])[0])
    b = float(re.findall(find, lines[ln + 1])[0])
    c = float(re.findall(find, lines[ln + 2])[0])
    d = float(re.findall(find, lines[ln + 3])[0])
    e = float(re.findall(find, lines[ln + 4])[0])
    # epsilon = float(re.findall(find, lines[ln + 5])[0])
    # while(not(lines[ln].startswith("The stacking faults probability"))):
    #     ln += 1
    # st_pr = float(re.findall(find, lines[ln + 1])[0])
    # genero el archivo .fit.ini
    fit_ini = "%s%sspr_%d_pattern_%d%s.fit.ini" % (files.pathout, files.input_file,
                                                   spr, pattern, files.ext)
    fp = open(fit_ini, "w")
    string = "init_a=%f\ninit_b=%f\ninit_c=%f\n" % (a, b, c)
    string += "init_d=%f\ninit_e=%f\ninit_epsilon=1.0\n" % (d, e)
    string += "a_fixed=%s\nb_fixed=%s\nc_fixed=%s\n" % (fit_flags[1], fit_flags[2], fit_flags[3])
    string += "d_fixed=%s\ne_fixed=%s\nepsilon_fixed=y\n" % (fit_flags[4], fit_flags[5])
    string += "scale_a=1.0\nscale_b=1.0\nscale_c=1.0\nscale_d=1.0\nscale_e=1.0"
    fp.write(string)
    fp.close()
    if(flag == 1):
        # correr el cmwp
        # cmd = './evaluate %s%sspr_%d_pattern_%d%s auto' % (files.pathout, files.input_file, spr, pattern, files.ext)
        cmd = 'unset DISPLAY\n'
        cmd += './evaluate %s%sspr_%d_pattern_%d%s auto >> std_output.txt' % (files.pathout, files.input_file, spr, pattern, files.ext)
        subprocess.call(cmd, shell=True)
        # leo el physsol.csv y lo guardo en memoria
        physsol_file = "%s%sspr_%d_pattern_%d.physsol.csv" % (files.pathout, files.input_file,
                                                              spr, pattern)
        return physsol_file

"""
Determina en que archivo tengo que buscar las semillas para el ajuste,
en funcion del spr y el pattern en el que me encuentro
"""


def set_sol_file(files, rings, spr, pattern):
    # defino cual es el archivo anterior
    if(pattern == rings.pattern_i + rings.delta_pattern):
        spr_prev = spr - rings.delta_spr
        pattern_prev = rings.pattern_i
    else:
        spr_prev = spr
        pattern_prev = pattern - rings.delta_pattern
    # leo los resultados del archivo anterior
    sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file,
                                              spr_prev, pattern_prev)
    return sol_file
