# -*- coding: utf-8 -*
from winkel_fns import winkel_al, winkel_be
import time
from os import chdir
from os import listdir
from subprocess import call
from shutil import move


class cmwp_out:
    def __init__(self, files, rings, cmwp_results):
        m = 0
        # archivo con las soluciones del ajuste
        outfile = "%s%sCMWP_SOL_PF.mtex" % (files.pathout, files.input_file)
        fp_sol = open(outfile, "w")
        fp_sol.write("# IDEA CMWP --- RESULT FILE --- %s\n" % time.strftime("%d/%m/%Y %I:%M:%S"))
        fp_sol.write("# Row 2theta theta alpha beta a a_err b b_err c c_err d d_err e e_err\n")
        fp_sol.flush()

        # archivo con las soluciones fisicas
        outfile = "%s%sCMWP_PHYSSOL_PF.mtex" % (files.pathout, files.input_file)
        fp_physsol = open(outfile, "w")
        fp_physsol.write("# IDEA CMWP --- RESULT FILE --- %s\n" % time.strftime("%d/%m/%Y %I:%M:%S"))
        fp_physsol.write("# Row 2theta theta alpha beta ")
        for field in cmwp_results.header:
            fp_physsol.write("%s " % field)
        fp_physsol.write("\n")
        fp_physsol.flush()

        k = 0  # contador del archivo mtex
        spr = rings.spr_i  # indice que me marca el spr
        ptrn_i = rings.pattern_i + rings.delta_pattern
        # tranformacion angular (gamma, omega) -> (alpha, beta)
        for omega in range(rings.omega_i, rings.omega_f + 1, rings.delta_omega):
            pattern = rings.pattern_i
            for pattern in range(rings.pattern_i, rings.pattern_f + 1, rings.delta_pattern):
                if(omega > 90):
                    neu_ome = omega - 90
                    neu_gam = pattern + 180
                else:
                    neu_ome = omega
                    neu_gam = pattern

                alpha = winkel_al(rings.theta[m], neu_ome, neu_gam)
                beta = winkel_be(rings.theta[m], neu_ome, neu_gam, alpha)
                if(alpha > 90):
                    alpha = 180 - alpha
                    beta = 360 - beta

                # salida al archivo con los valores del ajuste
                fp_sol.write("%4d %8.4f %8.4f %8.4f %8.4f " % (k + 1, 2 * rings.theta[m], rings.theta[m], alpha, beta))
                for i in range(0, cmwp_results.sol.shape[2]):

                    # soluciones matematicas del ajuste
                    fp_sol.write("%8.5f %8.5f " % (cmwp_results.sol[(spr - rings.spr_i) / rings.delta_spr][(pattern - ptrn_i) / rings.delta_pattern][i],
                                                   cmwp_results.solerr[(spr - rings.spr_i) / rings.delta_spr][(pattern - ptrn_i) / rings.delta_pattern][i]))
                fp_sol.write("\n")

                # salida al archivo con las soluciones fisicas
                fp_physsol.write("%8d %8.4f %8.4f %8.4f %8.4f " % (k + 1, 2 * rings.theta[m], rings.theta[m], alpha, beta))
                for i in range(0, cmwp_results.physsol.shape[2]):
                    fp_physsol.write("%8.5f " % (cmwp_results.physsol[(spr - rings.spr_i) / rings.delta_spr][(pattern - ptrn_i) / rings.delta_pattern]))
                fp_physsol.write("\n")

                # siguiente dato
                k += 1
            spr += rings.delta_spr
        fp_sol.flush()
        fp_sol.close()
        fp_physsol.flush()
        fp_physsol.close()
    organize_files(files)
    self.exit = 0


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
