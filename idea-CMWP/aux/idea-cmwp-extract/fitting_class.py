# -*- coding: utf-8 -*
import numpy
from functions import getcmwpsolutions, getphysolutions, getfitsolutions


class cmwp_fit:
    def __init__(self, files):
        physsol_file = "%s%sspr_%d_pattern_%d.physsol.csv" % (files.path_files,
                                                              files.base_file,
                                                              files.spr_i,
                                                              files.pattern_i + files.delta_pattern)
        fp_physsol = open(physsol_file, "r")
        lines = fp_physsol.readlines()
        # numero de variables del ajuste matematico
        n_sol_variables = 5
        # numero de soluciones fisicas
        n_variables = len(lines[1].split("\t"))
        n_spr = int((files.spr_f - files.spr_i + 1) / files.delta_spr)
        n_pattern = int((files.pattern_f - files.pattern_i + 1) / files.delta_pattern)
        shape = (n_spr, n_pattern, n_variables)
        self.sol = numpy.zeros((n_spr, n_pattern, n_sol_variables))
        self.solerr = numpy.zeros((n_spr, n_pattern, n_sol_variables))
        self.physsol = numpy.zeros(shape)
        self.fitvar = numpy.zeros((n_spr, n_pattern, 3))
        title = lines[0].replace("#", "")
        self.header = title.split()
        ptrn_i = files.pattern_i + files.delta_pattern
        ptrn_f = files.pattern_f + files.delta_pattern
        result = numpy.zeros((n_sol_variables))

        for spr in range(files.spr_i, files.spr_f + 1, files.delta_spr):
            for pattern in range(ptrn_i, ptrn_f, files.delta_pattern):
                # soluciones fisicas del problema
                physsol_file = "%s%sspr_%d_pattern_%d.physsol.csv" % (files.path_files, files.base_file, spr, pattern)
                self.physsol[(spr - files.spr_i) / files.delta_spr][(pattern - ptrn_i) / files.delta_pattern] = getphysolutions(physsol_file)
                # soluciones del ajuste
                sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.path_files, files.base_file, spr, pattern)
                result = getcmwpsolutions(sol_file, n_sol_variables)
                self.sol[(spr - files.spr_i) / files.delta_spr][(pattern - ptrn_i) / files.delta_pattern] = result
                # parametros del ajuste
                fitsol_file = "%s%sspr_%d_pattern_%d.int.sol" % (files.path_files, files.base_file, spr, pattern)
                result = getfitsolutions(fitsol_file)
                self.fitvar[(spr - files.spr_i) / files.delta_spr][(pattern - ptrn_i) / files.delta_pattern] = result
