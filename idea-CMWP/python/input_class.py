# -*- coding: utf-8 -*
import numpy
from functions import searchlineintext


class file_data:
    def __init__(self, cmwp_data):
        ln = searchlineintext(cmwp_data, "File Input Data")
        if(ln == -1):
            raise Exception("Wrong ini file")
        else:
            self.pathspr = cmwp_data[ln + 1][22:-1]
            self.pathout = cmwp_data[ln + 2][22:-1]
            self.input_file = cmwp_data[ln + 3][22:-1]
            self.path_base_file = cmwp_data[ln + 4][22:-1]
            self.base_file = cmwp_data[ln + 5][22:-1]
            self.results_folder = cmwp_data[ln + 6][22:-1]
            self.input_file_ext = cmwp_data[ln + 7][22:-1]
            self.ext = ".dat"


class fit2d_data:
    def __init__(self, cmwp_data):
        ln = searchlineintext(cmwp_data, "IndexNr Start")
        self.spr_i = int(cmwp_data[ln][22:-1])
        self.delta_spr = int(cmwp_data[ln + 1][22:-1])
        self.spr_f = int(cmwp_data[ln + 2][22:-1])
        self.omega_i = int(cmwp_data[ln + 3][22:-1])
        self.delta_omega = int(cmwp_data[ln + 4][22:-1])
        self.omega_f = int(cmwp_data[ln + 5][22:-1])
        self.pattern_i = int(cmwp_data[ln + 6][22:-1])
        self.avpattern = int(cmwp_data[ln + 7][22:-1])
        self.delta_pattern = int(cmwp_data[ln + 8][22:-1])
        self.pattern_f = int(cmwp_data[ln + 9][22:-1])

        ln = searchlineintext(cmwp_data, "Peak Positions")
        self.numrings = int(cmwp_data[ln + 1][22:-1])
        self.numphases = int(cmwp_data[ln + 2][22:-1])
        self.ph = numpy.zeros(0)
        self.hkl = numpy.zeros(0)
        self.dtheta = numpy.zeros(0)
        for lines in cmwp_data[ln + 5:]:
            if (lines != "\n" and lines != "\r\n"):
                self.ph = numpy.append(self.ph, int(lines.split()[0]))
                self.hkl = numpy.append(self.hkl, int(lines.split()[1]))
                self.dtheta = numpy.append(self.dtheta, float(lines.split()[2]))
