# -*- coding: utf-8 -*
from functions import searchlineintext


class file_data:
    def __init__(self, cmwp_data):
        ln = searchlineintext(cmwp_data, "File Input Data")
        if(ln == -1):
            raise Exception("Wrong ini file")
        else:
            self.pathin = cmwp_data[ln + 1][22:-1]
            self.pathout = cmwp_data[ln + 2][22:-1]
            self.input_file = cmwp_data[ln + 3][22:-1]
            self.path_base_file = cmwp_data[ln + 4][22:-1]
            self.base_file = cmwp_data[ln + 5][22:-1]
            self.results_folder = cmwp_data[ln + 6][22:-1]
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
        self.theta = 1.0
        self.Ch00 = 1.0
        ln = searchlineintext(cmwp_data, "Peaks2fit")
        self.hkl = map(int, cmwp_data[ln + 1:])
