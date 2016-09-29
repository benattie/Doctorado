import numpy as np
import re
import subprocess
from glob import iglob
from os.path import exists as existe
from os import chdir
from os import path
from subprocess import call
from shutil import move


def searchlineinfile(filename, chain):
    """
    Buscar una cadena de caracteres en filename
    devolver un array con el contenido de filename y con el numero de linea
    en que aparece chain
    """

    fp = open(filename, "r")
    lines = fp.readlines()
    fp.close()
    ln = 0
    while(not(chain in lines[ln])):
        if(ln == len(lines) - 1):
            return (1, 1)
        else:
            ln += 1
    return (lines, ln)


def searchlineintext(data, chain):
    """
    Buscar la cadena de caracteres chain en data
    devolvuelve el numero de linea en que aparece chain
    """

    ln = 0
    while(not(chain in data[ln])):
        if(ln == len(data) - 1):
            return -1
        else:
            ln += 1
    return ln


def searchableitems():
    """
    Define cadenas de caracteres que me interesan buscar.
    Son todas las formas en que puede aparecer un numero en un archivo
    """

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


def fit_strategy(files, rings, spr, pattern, find, fit_data):
    """
    Implementa una estrategia de ajuste de CMWP a partir de los datos obtenidos
    de filename.
    """

    ln = searchlineintext(fit_data, "Fitting strategy")
    if(ln == -1):
        print "Wrong fit.ini file (there's no fitting strategy)"
        return 1
    else:
        fit_int = fit_data[ln + 2].replace("\n", "")
        fit_stpr = fit_data[ln + 4].replace("\n", "")
        nsteps = int(fit_data[ln + 6])
        fit_steps = np.zeros((nsteps, 8), dtype=str)
        for i in range(nsteps):
            fit_steps[i] = fit_data[ln + 8 + i].split()

        # verifico si tengo que ajustar por fallas de apilamiento
        if(fit_stpr.lower() == 'y'):
            filename = set_fit_stpr(files, rings, spr, pattern, find, "y")
        else:
            filename = set_fit_stpr(files, rings, spr, pattern, find, "n")

        if(fit_int.lower() == 'y'):
            set_fit_intensity(filename, rings, spr, pattern, find, "y")
            fit_flags = np.array(['0', 'n', 'n', 'n', 'n', 'n', 'n'])
            sol_file = set_sol_file(files, rings, rings.spr_i, rings.pattern_i
                                    + rings.delta_pattern)
            print("\nAjustando intensidades")
            physsol_file = fit_cmwp(files, sol_file, rings, spr, pattern, find,
                                    fit_flags)
            set_fit_intensity(filename, rings, spr, pattern, find, "n")
            sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathout,
                                                      files.input_file, spr,
                                                      pattern)
            for i in range(nsteps):
                print "Paso %d del ajuste" % i
                physsol_file = fit_cmwp(files, sol_file, rings, spr, pattern,
                                        find, fit_steps[i])
        else:
            print("\nPaso 1 del ajuste")
            set_fit_intensity(filename, rings, spr, pattern, find, "n")
            sol_file = set_sol_file(files, rings, rings.spr_i, rings.pattern_i
                                    + rings.delta_pattern)
            physsol_file = fit_cmwp(files, sol_file, rings, spr, pattern, find,
                                    fit_steps[0])
            sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathout,
                                                      files.input_file, spr,
                                                      pattern)
            for i in range(1, nsteps):
                print "Paso %d del ajuste" % (i + 1)
                physsol_file = fit_cmwp(files, sol_file, rings, spr, pattern,
                                        find, fit_steps[i])
        return (physsol_file, fit_int.lower(), nsteps)


def set_fit_stpr(files, rings, spr, pattern, find, flag):
    """
    Prepara los archivos .ini del cmwp para que se ajusten las intensidades de
    los picos o no. Esto lo determina el valor de la variable fit_int que debe
    ser un string 'y' o 'n'
    """

    # copio el archivo .ini
    origin = "%s%s%s.ini" % (files.path_base_file, files.base_file, files.ext)
    destination = "%s%sspr_%d_pattern_%d%s.ini" % (files.pathout,
                                                   files.input_file, spr,
                                                   pattern, files.ext)
    subprocess.call(["cp", origin, destination])
    # copio el archivo .indC.ini
    origin = "%s%s%s.indC.ini" % (files.path_base_file, files.base_file,
                                  files.ext)
    destination = "%s%sspr_%d_pattern_%d%s.indC.ini" % (files.pathout,
                                                        files.input_file,
                                                        spr, pattern,
                                                        files.ext)
    if(path.isfile(origin) is True):
        subprocess.call(["cp", origin, destination])
    # genero el archivo .q.ini
    origin = "%s%s%s.q.ini" % (files.path_base_file, files.base_file,
                               files.ext)
    fp = open(origin, "r")
    lines = fp.readlines()
    fp.close()
    destination = "%s%sspr_%d_pattern_%d%s.q.ini" % (files.pathout,
                                                     files.input_file,
                                                     spr, pattern, files.ext)
    chain = "USE_STACKING"
    ln = searchlineintext(lines, chain)
    lines[ln] = "USE_STACKING=" + flag + "\n"
    fp = open(destination, "w")
    fp.writelines(lines)
    fp.close()
    return destination


def set_fit_intensity(filename, rings, spr, pattern, find, fit_int):
    """
    Prepara los archivos .ini del cmwp para que se ajusten las intensidades de
    los picos o no. Esto lo determina el valor de la variable fit_int que debe
    ser un string 'y' o 'n'
    """

    # genero el archivo .q.ini
    fp = open(filename, "r+")
    lines = fp.readlines()
    chain = "FIT_LIMIT"
    ln = searchlineintext(lines, chain)
    if(fit_int == "y"):
        lines[ln] = "FIT_LIMIT=1e-8\n"
    else:
        lines[ln] = "FIT_LIMIT=1e-10\n"
    chain = "peak_pos_fit"
    ln_1 = searchlineintext(lines, chain)
    chain = "peak_int_fit"
    ln_2 = searchlineintext(lines, chain)
    ln = min(ln_1, ln_2)
    lines[ln] = "peak_pos_fit=" + fit_int + "\n"
    lines[ln + 1] = "peak_int_fit=" + fit_int + "\n"
    fp.seek(0, 0)
    fp.writelines(lines)
    fp.close()


def set_sol_file(files, rings, spr, pattern):
    """
    Determina en que archivo tengo que buscar las semillas para el ajuste,
    en funcion del spr y el pattern en el que me encuentro
    """

    # defino cual es el archivo anterior
    if(spr == rings.spr_i and pattern == rings.pattern_i + rings.delta_pattern):
        spr_prev = spr
        pattern_prev = rings.pattern_i + rings.delta_pattern
    else:
        if(pattern == rings.pattern_i + rings.delta_pattern):
            spr_prev = spr - rings.delta_spr
            pattern_prev = rings.pattern_i + rings.delta_pattern
        else:
            spr_prev = spr
            pattern_prev = pattern - rings.delta_pattern
    # leo los resultados del archivo anterior
    sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file,
                                              spr_prev, pattern_prev)
    return sol_file


def fit_cmwp(files, sol_file, rings, spr, pattern, find, fit_flags):
    """
    Prepara los archivos para hacer un ajuste con el CMWP y corre el mismo.
    fit_flags es un vector de caracteres 'y' o 'n' que indican si deben
    ajustarse las variables a,b,c,d,e.
    """

    (lines, ln) = searchlineinfile(sol_file, "*** THE SOLUTIONS ***")
    if (lines == 1):
        print "Gnuplot no termino correctamente en el paso anterior"
        print "Revise el archivo *_std_output.txt para mas detalles"
        print "Modifique sus valores iniciales o su estrategia de ajuste"
        raise Exception('SingularMatrix')
    else:
        a = np.zeros(rings.numphases)
        b = np.zeros(rings.numphases)
        c = np.zeros(rings.numphases)
        d = np.zeros(rings.numphases)
        e = np.zeros(rings.numphases)
        # st_pr = np.zeros((1, rings.numphases))
        ln = searchlineintext(lines, "The scaled parameters:")
        a[0] = float(re.findall(find, lines[ln + 1])[0])
        b[0] = float(re.findall(find, lines[ln + 2])[0])
        c[0] = float(re.findall(find, lines[ln + 3])[0])
        d[0] = float(re.findall(find, lines[ln + 4])[0])
        e[0] = float(re.findall(find, lines[ln + 5])[0])
        for i in range(1, rings.numphases):
            chain = "The parameters for phase %d:" % i
            ln = searchlineintext(lines, chain)
            if (ln == -1):
                print "Wrong .sol file."
                print "There's no phase number %d" % i
            else:
                a[i] = float(re.findall(find, lines[ln + 1])[1])
                b[i] = float(re.findall(find, lines[ln + 2])[1])
                c[i] = float(re.findall(find, lines[ln + 3])[1])
                d[i] = float(re.findall(find, lines[ln + 4])[1])
                e[i] = float(re.findall(find, lines[ln + 5])[1])

        ln = searchlineintext(lines, "stacking faults probability")
        if(ln == -1):
            fit_flags[6] = 'y'
            st_pr = -1.0
        else:
            st_pr = float(re.findall(find, lines[ln + 1])[0])

        # genero el archivo .fit.ini
        fit_ini = "%s%sspr_%d_pattern_%d%s.fit.ini" % (files.pathout,
                                                       files.input_file, spr,
                                                       pattern, files.ext)
        fp = open(fit_ini, "w")
        # valores iniciales
        string = "init_a=%f\ninit_b=%f\ninit_c=%f\n" % (a[0], b[0], c[0])
        string += "init_d=%f\ninit_e=%f\ninit_epsilon=1.0\n" % (d[0], e[0])
        string += "init_st_pr=%f\n" % st_pr
        # variables a ajustar
        string += "a_fixed=%s\nb_fixed=%s\n" % (fit_flags[1], fit_flags[2])
        string += "c_fixed=%s\n" % fit_flags[3]
        string += "d_fixed=%s\ne_fixed=%s\n" % (fit_flags[4], fit_flags[5])
        string += "epsilon_fixed=y\nst_pr_fixed=%s\n" % fit_flags[6]
        string += "de_fixed=%s\n" % fit_flags[7]
        for i in range(1, rings.numphases):
            # valores iniciales
            string += "init_a_%d=%f\ninit_b_%d=%f\n" % (i, a[i], i, b[i])
            string += "init_c_%d=%f\ninit_d_%d=%f\n" % (i, c[i], i, d[i])
            string += "init_e_%d=%f\ninit_epsilon_%d=1.0\n" % (i, e[i], i)
            string += "init_st_pr_%d=%f\n" % (i, st_pr)
            # variables a ajustar
            string += "a_%d_fixed=%s\n" % (i, fit_flags[1])
            string += "b_%d_fixed=%s\n" % (i, fit_flags[2])
            string += "c_%d_fixed=%s\n" % (i, fit_flags[3])
            string += "d_%d_fixed=%s\n" % (i, fit_flags[4])
            string += "e_%d_fixed=%s\n" % (i, fit_flags[5])
            string += "epsilon_%d_fixed=y\nst_pr_%d_fixed=%s\n" % (i, i, fit_flags[6])
            string += "de_%d_fixed=%s\n" % (i, fit_flags[7])

    # parametros de escala
    string += "scale_a=1.0\nscale_b=1.0\nscale_c=1.0\nscale_d=1.0\nscale_e=1.0"
    fp.write(string)
    fp.close()
    # raw_input("Generado .fit.ini\nPresione Enter para continuar...\n")
    # correr el cmwp
    cmd = 'unset DISPLAY\n'
    cmd += './evaluate %s%sspr_%d_pattern_%d%s auto >> %sstd_output.txt' \
        % (files.pathout, files.input_file, spr, pattern, files.ext, files.input_file)
    subprocess.call(cmd, shell=True)

    # leo el physsol.csv y lo guardo en memoria
    physsol_file = "%s%sspr_%d_pattern_%d.physsol.csv" % (files.pathout,
                                                          files.input_file,
                                                          spr, pattern)
    return physsol_file


def getcmwpsolutions(rings, data, ln, resultado):
    """
    Dado el contenido de un archivo (en forma de array)
    devuelve una lista de cinco elementos conteniendo el resultado
    de los ajustes del cmwp (valor final, error absoluto, error relativo)
    Si no encuentra nada le pone un cero.
    """

    find = searchableitems()
    if(data[ln].startswith("a")):
        resultado[0][0] = np.array(map(float, re.findall(find, data[ln])))
        ln += 1
    if(data[ln].startswith("b")):
        resultado[1][0] = np.array(map(float, re.findall(find, data[ln])))
        ln += 1
    if(data[ln].startswith("c")):
        resultado[2][0] = np.array(map(float, re.findall(find, data[ln])))
        ln += 1
    if(data[ln].startswith("d")):
        resultado[3][0] = np.array(map(float, re.findall(find, data[ln])))
        ln += 1
    if(data[ln].startswith("e")):
        resultado[4][0] = np.array(map(float, re.findall(find, data[ln])))
        ln += 1
    if(data[ln].startswith("st_pr")):
        resultado[5][0] = np.array(map(float, re.findall(find, data[ln])))
        ln += 1
    for i in range(1, rings.numphases):
        if(data[ln].startswith("a_%d" % i)):
            temp_res = np.array(map(float, re.findall(find, data[ln])))
            resultado[0][i] = temp_res[1:]
            ln += 1
        if(data[ln].startswith("b_%d" % i)):
            temp_res = np.array(map(float, re.findall(find, data[ln])))
            resultado[1][i] = temp_res[1:]
            ln += 1
        if(data[ln].startswith("c_%d" % i)):
            temp_res = np.array(map(float, re.findall(find, data[ln])))
            resultado[2][i] = temp_res[1:]
            ln += 1
        if(data[ln].startswith("d_%d" % i)):
            temp_res = np.array(map(float, re.findall(find, data[ln])))
            resultado[3][i] = temp_res[1:]
            ln += 1
        if(data[ln].startswith("e_%d" % i)):
            temp_res = np.array(map(float, re.findall(find, data[ln])))
            resultado[4][i] = temp_res[1:]
            ln += 1
        if(data[ln].startswith("st_pr_%d" % i)):
            temp_res = np.array(map(float, re.findall(find, data[ln])))
            resultado[5][i] = temp_res[1:]
            ln += 1

    return resultado


def getfitsolutions(fitsol_file):
    find = searchableitems()
    (lines, ln) = searchlineinfile(fitsol_file, "final")
    if(lines == 1):
        (lines, ln) = searchlineinfile(fitsol_file, "WSSR")
        WSSR = float(re.findall(find, lines[ln])[0])
        return np.array((WSSR, -1, -1))
    else:
        output = np.zeros(3)
        output[0] = float(re.findall(find, lines[ln])[0])
        ln = searchlineintext(lines, "rms")
        output[1] = float(re.findall(find, lines[ln])[0])
        ln = searchlineintext(lines, "variance")
        output[2] = float(re.findall(find, lines[ln])[0])
        return output


def getcmwpphyssol(physsol_file):
    find = searchableitems()
    fp = open(physsol_file)
    lines = fp.readlines()
    output = map(float, re.findall(find, lines[1]))
    return output


def organize_files(files):
    # me voy a la carpeta con los datos
    chdir(files.pathout)
    folder = "cmwp_idea_pole_figures"
    call(["mkdir", folder])
    for datafile in iglob("*.mtex"):
        if existe(folder + datafile):
            print("Error moving .mtex file: %s already exists in destination"
                  % datafile)
        else:
            move(datafile, folder)
    folder = "cmwp_idea_files"
    call(["mkdir", folder])
    for datafile in iglob(files.input_file + "*"):
        if existe(folder + datafile):
            print("Error moving files into %s: %s already exists in destination"
                  % (folder, datafile))
        else:
            move(datafile, folder)
    # me voy a la carpeta con todos los resultados del ajuste
    results = files.results_folder + files.pathout
    chdir(results)
    folder = "cmwp_idea_fit_files"
    call(["mkdir", folder])
    for datafile in iglob(files.input_file + "*"):
        if existe(folder + datafile):
            print("Error moving files into %s: %s already exists in destination"
                  % (folder, datafile))
        else:
            move(datafile, folder)


def periodic_index(index, ini, end):
    if(index < ini):
        return end
    if(index > end):
        return ini
    return index


def smooth(mat, ini_i, i, end_i, ini_j, j, end_j, k, flag):
    tot = 0.0
    avg = flag
    n = 0
    for dx in range(-1, 2, 1):
        for dy in range(-1, 2, 1):
            x = periodic_index(ini_i, i + dx, end_i)
            y = periodic_index(ini_j, j + dy, end_j)
            if(mat[x][y][k] != flag):
                tot = tot + mat[x][y][k]
                n = n + 1

    if(n > 0):
        avg = tot / n
        mat[i][j][k] = avg
    else:
        mat[i][j][k] = flag


def return_flag():
    return -10.0
