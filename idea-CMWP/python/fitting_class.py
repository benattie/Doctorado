# -*- coding: utf-8 -*
import numpy
import re
from fitting_strategy import update_params


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
        n_variables = len(lines[1].split("\t"))
        n_spr = int((rings.spr_f - rings.spr_i + 1) / rings.delta_spr)
        n_pattern = int((rings.pattern_f - rings.pattern_i + 1) / rings.delta_pattern)
        shape = (n_spr, n_pattern, n_variables)
        self.sol = numpy.zeros((n_spr, n_pattern, 5))
        self.physsol = numpy.zeros(shape)
        self.header = ""
        ptrn_i = rings.pattern_i + rings.delta_pattern
        ptrn_f = rings.pattern_f + rings.delta_pattern
        n_bad_fit = 0
        bad_fit = 0

        for spr in range(rings.spr_i, rings.spr_f + 1, rings.delta_spr):
            # print("Processing spr %d" % spr)
            for pattern in range(ptrn_i, ptrn_f, rings.delta_pattern):
                # print "%d, %d" % (spr, pattern)
                if(flag == 1):
                    # soluciones fisicas del problema
                    (physsol_file, bad_fit) = update_params(files, rings, spr, pattern, flag, find, bad_fit)
                    if(bad_fit):
                        n_bad_fit += 1
                    # soluciones matematicas del ajuste
                    sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file,
                                                              spr, pattern)
                    ln = 0
                    fp = open(sol_file, "r")
                    lines = fp.readlines()
                    while(not(lines[ln].startswith("*** THE SOLUTIONS"))):
                        ln += 1
                    fp.close()
                    for i in range(0, 5):
                        x = float(re.findall(find, lines[ln + 3 + i])[0])
                        self.sol[spr / rings.delta_spr - 1][pattern / rings.delta_pattern][i] = float(x)
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
        print "\n*******************************\n"
        print "*******************************\n"
        print "Warning: there were %d bad fits" % n_bad_fit
        print "\n*******************************\n"
        print "*******************************\n"
