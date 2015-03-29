# -*- coding: utf-8 -*
from functions import searchlineintext


class file_data:
    def __init__(self, cmwp_data):
        ln = searchlineintext(cmwp_data, "File Input Data")
        if(ln == -1):
            raise Exception("Wrong ini file")
        else:
            self.base_file = cmwp_data[ln + 1][22:-1]
            self.path_files = cmwp_data[ln + 2][22:-1]
            self.pathout = cmwp_data[ln + 3][22:-1]
            self.spr_i = int(cmwp_data[ln + 4][22:-1])
            self.delta_spr = int(cmwp_data[ln + 5][22:-1])
            self.spr_f = int(cmwp_data[ln + 6][22:-1])
            self.omega_i = int(cmwp_data[ln + 7][22:-1])
            self.delta_omega = int(cmwp_data[ln + 8][22:-1])
            self.omega_f = int(cmwp_data[ln + 9][22:-1])
            self.pattern_i = int(cmwp_data[ln + 10][22:-1])
            self.avpattern = int(cmwp_data[ln + 11][22:-1])
            self.delta_pattern = int(cmwp_data[ln + 12][22:-1])
            self.pattern_f = int(cmwp_data[ln + 13][22:-1])
            self.theta = float(cmwp_data[ln + 14][22:-1])
