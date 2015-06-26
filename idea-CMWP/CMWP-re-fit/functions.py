import numpy as np
import re
import subprocess
from os import chdir
from os import listdir
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
    Implementa una estrategia de ajuste de CMWP a partir de los datos obtenidos de
    filename.
    """

    ln = searchlineintext(fit_data, "Fitting strategy")
    if(ln == -1):
        print "Wrong fit.ini file (there's no fitting strategy)"
        return 1
    else:
        fit_int = fit_data[ln + 2].replace("\n", "")
        fit_stpr = fit_data[ln + 4].replace("\n", "")
        nsteps = int(fit_data[ln + 6])
        fit_steps = np.zeros((nsteps, 7), dtype=str)
        for i in range(nsteps):
            fit_steps[i] = fit_data[ln + 8 + i].split()

        # verifico si tengo que ajustar por fallas de apilamiento
        if(fit_stpr.lower() == 'y'):
            filename = set_fit_stpr(files, rings, spr, pattern, find, "y")
        else:
            filename = set_fit_stpr(files, rings, spr, pattern, find, "n")

        sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathin, files.input_file, spr, pattern)

        if(fit_int.lower() == 'y'):
            set_fit_intensity(filename, rings, spr, pattern, find, "y")
            fit_flags = np.array(['0', 'y', 'y', 'y', 'n', 'y', 'y'])
            # print("\nPaso 0 del ajuste (ajuste de intensidades)")
            physsol_file = fit_cmwp(files, sol_file, rings, spr, pattern, find, fit_flags)
            set_fit_intensity(filename, rings, spr, pattern, find, "n")
            sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file, spr, pattern)
            for i in range(nsteps):
                # print "Paso %d del ajuste" % (i + 1)
                physsol_file = fit_cmwp(files, sol_file, rings, spr, pattern, find, fit_steps[i])
        else:
            # print("\nPaso 1 del ajuste")
            set_fit_intensity(filename, rings, spr, pattern, find, "n")
            physsol_file = fit_cmwp(files, sol_file, rings, spr, pattern, find, fit_steps[0])
            sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file, spr, pattern)
            for i in range(1, nsteps):
                # print "Paso %d del ajuste" % (i + 1)
                physsol_file = fit_cmwp(files, sol_file, rings, spr, pattern, find, fit_steps[i])
        return (physsol_file, fit_int.lower(), nsteps)


def set_fit_stpr(files, rings, spr, pattern, find, flag):
    """
    Prepara los archivos .ini del cmwp para que se ajusten las intensidades de los
    picos o no. Esto lo determina el valor de la variable fit_int que debe ser un
    string 'y' o 'n'
    """

    # copio el archivo .ini
    orig = "%s%s%s.ini" % (files.path_base_file, files.base_file, files.ext)
    dest = "%s%sspr_%d_pattern_%d%s.ini" % (files.pathout, files.input_file,
                                            spr, pattern, files.ext)
    subprocess.call(["cp", orig, dest])
    # genero el archivo .q.ini
    orig = "%s%s%s.q.ini" % (files.path_base_file, files.base_file, files.ext)
    fp = open(orig, "r")
    lines = fp.readlines()
    fp.close()
    dest = "%s%sspr_%d_pattern_%d%s.q.ini" % (files.pathout, files.input_file,
                                              spr, pattern, files.ext)
    chain = "USE_STACKING"
    ln = searchlineintext(lines, chain)
    lines[ln] = "USE_STACKING=" + flag + "\n"
    fp = open(dest, "w")
    fp.writelines(lines)
    fp.close()
    return dest


def set_fit_intensity(filename, rings, spr, pattern, find, fit_int):
    """
    Prepara los archivos .ini del cmwp para que se ajusten las intensidades de los
    picos o no. Esto lo determina el valor de la variable fit_int que debe ser un
    string 'y' o 'n'
    """

    # genero el archivo .q.ini
    fp = open(filename, "r+")
    lines = fp.readlines()
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


def fit_cmwp(files, sol_file, rings, spr, pattern, find, fit_flags):
    """
    Prepara los archivos para hacer un ajuste con el CMWP y corre el mismo.
    fit_flags es un vector de caracteres 'y' o 'n' que indican si deben ajustarse
    las variables a,b,c,d,e.
    """

    (lines, ln) = searchlineinfile(sol_file, "The unscaled")
    if (lines == 1):
        print "Gnuplot no termino correctamente en el paso anterior"
        print "Revise el archivo *_std_output.txt para mas detalles"
        print "Modifique sus valores iniciales o su estrategia de ajuste"
        raise Exception('SingularMatrix')
    a = float(re.findall(find, lines[ln + 1])[0])
    b = float(re.findall(find, lines[ln + 2])[0])
    c = float(re.findall(find, lines[ln + 3])[0])
    d = float(re.findall(find, lines[ln + 4])[0])
    e = float(re.findall(find, lines[ln + 5])[0])

    ln = searchlineintext(lines, "stacking faults probability")
    if(ln == -1):
        fit_flags[6] = 'y'
        st_pr = -1.0
    else:
        st_pr = float(re.findall(find, lines[ln + 1])[0])

    # genero el archivo .fit.ini
    fit_ini = "%s%sspr_%d_pattern_%d%s.fit.ini" % (files.pathout, files.input_file, spr, pattern, files.ext)
    fp = open(fit_ini, "w")
    # valores iniciales
    string = "init_b=%f\ninit_c=%f\ninit_d=%f\ninit_e=%f\n" % (b, c, d / 5, e)
    string += "init_epsilon=1.0\ninit_st_pr=%f\n" % st_pr
    # variables a ajustar
    string += "a_fixed=%s\nb_fixed=%s\n" % (fit_flags[1], fit_flags[2])
    string += "c_fixed=%s\n" % fit_flags[3]
    string += "d_fixed=%s\ne_fixed=%s\n" % (fit_flags[4], fit_flags[5])
    string += "epsilon_fixed=y\nst_pr_fixed=%s\n" % fit_flags[6]
    # parametros de escala
    string += "scale_a=1.0\nscale_b=1.0\nscale_c=1.0\nscale_d=1.0\nscale_e=1.0"
    fp.write(string)
    fp.close()
    miller_str = str(rings.hkl)
    h = int(miller_str[1])
    k = int(miller_str[2])
    l = int(miller_str[3])
    H2_inv = H2(h, k, l)
    C0 = rings.Ch00 * (1 - a * H2_inv)
    # genero el archivo .indC.ini
    fit_ini = "%s%sspr_%d_pattern_%d%s.indC.ini" % (files.pathout, files.input_file, spr, pattern, files.ext)
    fp = open(fit_ini, "w")
    # valores iniciales
    string = "init_C0=%f\nC_0_fixed=\"y\"\n" % C0
    fp.write(string)
    fp.close()

    # correr el cmwp
    cmd = 'unset DISPLAY\n'
    cmd += './evaluate %s%sspr_%d_pattern_%d%s auto >> %sstd_output.txt' % (files.pathout, files.input_file, spr, pattern, files.ext, files.input_file)
    # cmd = './evaluate %s%sspr_%d_pattern_%d%s auto >> %sstd_output.txt' % (files.pathout, files.input_file, spr, pattern, files.ext, files.input_file)
    subprocess.call(cmd, shell=True)

    # devuelvo el physsol.csv
    physsol_file = "%s%sspr_%d_pattern_%d.physsol.csv" % (files.pathout, files.input_file, spr, pattern)
    return physsol_file


def getcmwpsolutions(data, ln, resultado):
    """
    Dado el contenido de un archivo (en forma de array)
    devuelve una lista de cinco elementos conteniendo el resultado
    de los ajustes del cmwp (valor final, error absoluto, error relativo)
    Si no encuentra nada le pone un cero.
    """

    find = searchableitems()
    if(data[ln].startswith("a")):
        resultado[0] = np.array(map(float, re.findall(find, data[ln])))
        ln += 1
    if(data[ln].startswith("b")):
        resultado[1] = np.array(map(float, re.findall(find, data[ln])))
        ln += 1
    if(data[ln].startswith("c")):
        resultado[2] = np.array(map(float, re.findall(find, data[ln])))
        ln += 1
    if(data[ln].startswith("d")):
        resultado[3] = np.array(map(float, re.findall(find, data[ln])))
        ln += 1
    if(data[ln].startswith("e")):
        resultado[4] = np.array(map(float, re.findall(find, data[ln])))
        ln += 1
    if(data[ln].startswith("st_pr")):
        resultado[5] = np.array(map(float, re.findall(find, data[ln])))
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
    source = listdir("./")
    for datafile in source:
        if datafile.endswith(".mtex"):
            move(datafile, folder)
    folder = "cmwp_idea_files"
    call(["mkdir", folder])
    source = listdir("./")
    for datafile in source:
        if datafile.startswith(files.input_file):
            move(datafile, folder)
    # me voy a la carpeta con todos los resultados del ajuste
    results = files.results_folder + files.pathout
    chdir(results)
    folder = "cmwp_idea_fit_files"
    call(["mkdir", folder])
    source = listdir("./")
    for datafile in source:
        if datafile.startswith(files.input_file):
            move(datafile, folder)


def copy_cmwp_files(files, spr, pattern, hkl):
    # copio el physsol del archivo base
    orig = "%s%sspr_%d_pattern_%d.physsol.csv" % (files.pathin, files.input_file,
                                                  spr, pattern)
    dest = "%s%sspr_%d_pattern_%d.physsol.csv" % (files.pathout, files.input_file,
                                                  spr, pattern)
    subprocess.call(["cp", orig, dest])
    # copio el sol del archivo base
    orig = "%s%sspr_%d_pattern_%d.sol" % (files.pathin, files.input_file,
                                          spr, pattern)
    dest = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file,
                                          spr, pattern)
    subprocess.call(["cp", orig, dest])
    # copio el dat del archivo base
    orig = "%s%sspr_%d_pattern_%d.dat" % (files.pathin, files.input_file,
                                          spr, pattern)
    dest = "%s%sspr_%d_pattern_%d.dat" % (files.pathout, files.input_file,
                                          spr, pattern)
    subprocess.call(["cp", orig, dest])
    # copio el archivo de background del archivo base
    orig = "%s%sspr_%d_pattern_%d.bg-spline.dat" % (files.pathin, files.input_file,
                                                    spr, pattern)
    dest = "%s%sspr_%d_pattern_%d.bg-spline.dat" % (files.pathout, files.input_file,
                                                    spr, pattern)
    subprocess.call(["cp", orig, dest])
    # genero el archivo peak-index a partir del archivo base
    orig = "%s%sspr_%d_pattern_%d.peak-index.dat" % (files.pathin, files.input_file,
                                                     spr, pattern)
    dest = "%s%sspr_%d_pattern_%d.peak-index.dat" % (files.pathout, files.input_file,
                                                     spr, pattern)
    subprocess.call(["cp", orig, dest])
    # Selecciono los picos
    fp = open(dest, 'r')
    data = fp.readlines()
    fp.close()
    fp = open(dest, 'w')
    peak_list = select_peaks(data, hkl)
    peak_list = peak_list.astype(np.float)
    for peak in peak_list:
        fp.write('%.4f %.4f %d %d\n' % (peak[0], peak[1], peak[2], peak[3]))
    fp.close()


def clean_cmwp_files(files, spr, pattern):
    # borro el physsol del archivo base
    fp = "%s%sspr_%d_pattern_%d.physsol.csv" % (files.pathout, files.input_file,
                                                spr, pattern)
    subprocess.call(["rm", fp])
    # borro el sol del archivo base
    fp = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file,
                                        spr, pattern)
    subprocess.call(["rm", fp])
    # borro el dat del archivo base
    fp = "%s%sspr_%d_pattern_%d.dat" % (files.pathout, files.input_file,
                                        spr, pattern)
    subprocess.call(["rm", fp])
    # borro el dat del archivo base
    fp = "%s%sspr_%d_pattern_%d.bg-spline.dat" % (files.pathout, files.input_file,
                                                  spr, pattern)
    subprocess.call(["rm", fp])
    # borro el dat del archivo base
    fp = "%s%sspr_%d_pattern_%d.peak-index.dat" % (files.pathout, files.input_file,
                                                   spr, pattern)
    subprocess.call(["rm", fp])


def select_peaks(data, hkl):
    """
    Selecciono de los datos presentes en el string data, los picos que
    corresponden a los indicados en hkl
    """

    # extraigo los picos del archivo original
    table = data[0].split()
    for peak in data:
        table = np.vstack((table, peak.split()))
    table = table[1:, :]
    output = np.zeros((1, table.shape[1]))
    for miller in hkl:
        ln = 0
        for m in table[:, 2]:
            if(miller == int(m)):
                output = np.vstack((output, table[ln]))
                break
            else:
                ln = ln + 1
    return output[1:]


def H2(h, k, l):
    num = float(h**2 * k**2 + h**2 * l**2 + k**2 * l**2)
    den = float((h**2 + k**2 + l**2)**2)
    return num / den
