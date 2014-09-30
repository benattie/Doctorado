# -*- coding: utf-8 -*
import numpy
import time
import subprocess
from fitting_strategy import update_params
from sys import stdout


class cmwp_fit:
    def __init__(self, files, rings, flag):
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
        physsol_name = "%s%s.physsol.csv" % (files.path_base_file, files.base_file)
        fp_physsol = open(physsol_name, "r")
        lines = fp_physsol.readlines()
        # numero de variables del ajuste matematico
        n_sol_variables = 5
        # numero de soluciones fisicas
        n_variables = len(lines[1].split("\t"))
        n_spr = int((rings.spr_f - rings.spr_i + 1) / rings.delta_spr)
        n_pattern = int((rings.pattern_f - rings.pattern_i + 1) / rings.delta_pattern)
        shape = (n_spr, n_pattern, n_variables)
        self.sol = numpy.zeros((n_spr, n_pattern, n_sol_variables))
        self.solerr = numpy.zeros((n_spr, n_pattern, n_sol_variables))
        self.physsol = numpy.zeros(shape)
        self.header = ""
        ptrn_i = rings.pattern_i + rings.delta_pattern
        ptrn_f = rings.pattern_f + rings.delta_pattern
        ptrn_por_spr = (ptrn_f - ptrn_i) / rings.delta_pattern + 1
        spr_total = (rings.spr_f - rings.spr_i) / rings.delta_spr + 1
        ptrn_total = ptrn_por_spr * spr_total
        n_bad_fit = 0
        bad_fit = 0
        result = numpy.zeros((n_sol_variables, 3))
        fp_log = open("errors.log", "a")
        fp_log.write("IDEA CMWP\nERROR LOG FILE\n%s\n\n" % time.strftime("%d/%m/%Y %I:%M:%S"))
        start_time = time.time()

        for spr in range(rings.spr_i, rings.spr_f + 1, rings.delta_spr):
            n_spr = (spr - rings.spr_i) / rings.delta_spr + 1
            n_previos = ptrn_por_spr * (n_spr - 1)
            sec = int(time.time() - start_time)  # tiempo de ejecucion (seg)
            hour = int(sec / 3600)  # horas de ejecucion
            sec = sec % 3600  # tiempo de ejecucion sin las horas
            minute = int(sec / 60)  # minutos de ejecucion
            sec = sec % 60  # segundos de ejecucion
            print("Processing spr %d of %d" % (n_spr, spr_total))
            print("%d hours, %d min, %d sec elapsed" % (hour, minute, sec))
            for pattern in range(ptrn_i, ptrn_f, rings.delta_pattern):
                n = (pattern - ptrn_i) / rings.delta_pattern
                if (n % 5 == 0):
                    stdout.write("\r")
                    stdout.write("pattern %d of %d (%2.2f %% completed)" % (n, ptrn_por_spr, float(n_previos + n) / ptrn_total * 100.))
                    stdout.flush()
                if(flag == 1):
                    # soluciones fisicas del problema
                    (physsol_file, bad_fit, result) = update_params(files, rings, spr, pattern, flag, find, bad_fit, result)
                    if(bad_fit == 1 or physsol_file == ""):
                        n_bad_fit += 1
                        reset_parameters(files, spr, pattern)
                        fp_log.write("Bad fit spr = %d, pattern = %d\n" % (spr, pattern))
                        # self.sol[spr / rings.delta_spr - 1][pattern / rings.delta_pattern - 1] = -1 * numpy.ones((1, n_sol_variables))
                        self.physsol[spr / rings.delta_spr - 1][pattern / rings.delta_pattern - 1] = -1 * numpy.ones((1, n_variables))
                    else:
                        # guardo todas las soluciones fisicas del fit
                        fp = open(physsol_file, "r")
                        lines = fp.readlines()
                        fp.close()
                        v = 0
                        self.header = lines[0].split("\t")
                        for x in lines[1].split("\t"):
                            # print(spr, pattern, x)
                            self.physsol[spr / rings.delta_spr - 1][pattern / rings.delta_pattern - 1][v] = float(x)
                            v += 1
                    # soluciones matematicas del ajuste
                    for i in range(0, n_sol_variables):
                        self.sol[spr / rings.delta_spr - 1][pattern / rings.delta_pattern - 1][i] = result[i][0]
                        self.solerr[spr / rings.delta_spr - 1][pattern / rings.delta_pattern - 1][i] = result[i][1]
            stdout.write("\n")
        if(flag == 1):
            print "\n*******************************"
            print "*******************************\n"
            print "Warning: there were %d bad fits" % n_bad_fit
            print "\n*******************************"
            print "*******************************\n"
            fp_log.write("\n*******************************\n")
            fp_log.write("*******************************\n")
            fp_log.write("There were %d bad fits" % n_bad_fit)
            fp_log.write("\n*******************************\n")
            fp_log.write("*******************************\n")
        fp_log.close()


def reset_parameters(files, spr, pattern):
    # copio el archivo .sol
    origin = "%s%s.sol" % (files.path_base_file, files.base_file)
    destination = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file, spr, pattern)
    subprocess.call(["cp", origin, destination])
