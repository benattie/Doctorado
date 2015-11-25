# -*- coding: utf-8 -*
import numpy
import time
from fitting_strategy import update_params
from sys import stdout
from functions import getfitsolutions, searchableitems, select_peaks


class cmwp_fit:
    def __init__(self, files, rings, fit_data):
        # regla para buscar números en strings
        find = searchableitems()
        # Defino el theta del pico que voy a usar para generar la PF
        fname = "%s%s.peak-index.dat" % (files.path_base_file, files.base_file)
        fp = open(fname, "r")
        lines = fp.readlines()
        fp.close()
        pdata = select_peaks(lines, rings.hkl)
        rings.theta = float(pdata[0][0]) * 0.5

        n_spr = int((rings.spr_f - rings.spr_i + 1) / rings.delta_spr)
        n_pattern = int((rings.pattern_f - rings.pattern_i + 1) / rings.delta_pattern)
        self.sol = numpy.zeros((n_spr, n_pattern, 3))
        self.solerr = numpy.zeros((n_spr, n_pattern, 3))
        self.fitvar = numpy.zeros((n_spr, n_pattern, 3))
        ptrn_i = rings.pattern_i + rings.delta_pattern
        ptrn_f = rings.pattern_f + rings.delta_pattern
        ptrn_por_spr = (ptrn_f - ptrn_i) / rings.delta_pattern + 1
        spr_total = (rings.spr_f - rings.spr_i) / rings.delta_spr + 1
        ptrn_total = ptrn_por_spr * spr_total
        n_bad_fit = 0
        bad_fit = 0
        result = numpy.zeros((3, 3))
        error_filename = "%serrors.log" % files.input_file
        fp_log = open(error_filename, "a")
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
                # soluciones fisicas del problema
                (result, bad_fit) = update_params(files, rings, spr, pattern, find, fit_data, bad_fit, result)
                if(bad_fit == 1):
                    n_bad_fit += 1
                    fp_log.write("Bad fit spr = %d, pattern = %d\n" % (spr, pattern))

                # soluciones matematicas del ajuste
                for i in range(0, 3):
                    self.sol[(spr - rings.spr_i) / rings.delta_spr][(pattern - ptrn_i) / rings.delta_pattern][i] = result[i][0]
                    self.solerr[(spr - rings.spr_i) / rings.delta_spr][(pattern - ptrn_i) / rings.delta_pattern][i] = result[i][1]
                # parametros del ajuste
                fitsol_file = "%s%sspr_%d_pattern_%d.int.sol" % (files.path_base_file, files.input_file, spr, pattern)
                chi = getfitsolutions(fitsol_file)
                self.fitvar[(spr - rings.spr_i) / rings.delta_spr][(pattern - ptrn_i) / rings.delta_pattern] = chi
            stdout.write("\n")
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
