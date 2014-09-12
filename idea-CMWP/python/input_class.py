# -*- coding: utf-8 -*
import numpy


class file_data:
    def __init__(self, cmwp_data):
        self.pathspr = cmwp_data[1][22:-1]
        self.pathout = cmwp_data[2][22:-1]
        self.input_file = cmwp_data[3][22:-1]
        self.path_base_file = cmwp_data[4][22:-1]
        self.base_file = cmwp_data[5][22:-1]
        self.results_folder = cmwp_data[6][22:-1]
        self.input_file_ext = cmwp_data[7][22:-1]
        self.ext = ".dat"


class fit2d_data:
    def __init__(self, cmwp_data):
        self.spr_i = int(cmwp_data[8][22:-1])
        self.delta_spr = int(cmwp_data[9][22:-1])
        self.spr_f = int(cmwp_data[10][22:-1])
        self.omega_i = int(cmwp_data[11][22:-1])
        self.delta_omega = int(cmwp_data[12][22:-1])
        self.omega_f = int(cmwp_data[13][22:-1])
        self.pattern_i = int(cmwp_data[14][22:-1])
        self.avpattern = int(cmwp_data[15][22:-1])
        self.delta_pattern = int(cmwp_data[16][22:-1])
        self.pattern_f = int(cmwp_data[17][22:-1])
        self.numrings = int(cmwp_data[26][22:-1])
        self.hkl = numpy.zeros(0)
        self.theta = numpy.zeros(0)
        for lines in cmwp_data[29:]:
            self.hkl = numpy.append(self.hkl, int(lines.split()[0]))
            self.theta = numpy.append(self.theta, float(lines.split()[1]))
