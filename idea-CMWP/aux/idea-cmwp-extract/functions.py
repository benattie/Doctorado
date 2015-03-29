import numpy as np
import re
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
    Buscar una cadena de caracteres en data
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


def getphysolutions(physsol_file):
    fp = open(physsol_file, "r")
    lines = fp.readlines()
    output = np.array(lines[1].split(), dtype=float)
    return output


def getcmwpsolutions(sol_file, n):
    find = searchableitems()
    (lines, ln) = searchlineinfile(sol_file, "a_scaled")

    output = np.zeros(n)
    for i in range(n):
        output[i] = float(re.findall(find, lines[ln + i])[0])
    return output


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
        if datafile.startswith(files.base_file):
            move(datafile, folder)
    # me voy a la carpeta con todos los resultados del ajuste
    results = files.results_folder + files.pathout
    chdir(results)
    folder = "cmwp_idea_fit_files"
    call(["mkdir", folder])
    source = listdir("./")
    for datafile in source:
        if datafile.startswith(files.base_file):
            move(datafile, folder)
