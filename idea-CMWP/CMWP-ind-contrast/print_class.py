# -*- coding: utf-8 -*
from winkel_fns import winkel_al, winkel_be
from functions import organize_files
import time


class cmwp_out:
    def __init__(self, files, rings, cmwp_results):
        # archivo con las soluciones del ajuste
        outfile = "%s%sCMWP_SOL_PF.mtex" % (files.pathout, files.input_file)
        fp_sol = open(outfile, "w")
        fp_sol.write("IDEA CMWP --- RESULT FILE --- %s\n" % time.strftime("%d/%m/%Y %I:%M:%S"))
        fp_sol.write("Row 2theta theta omega gamma alpha beta C0 C0_err i_s0_0 i_s0_0_err i_max_0 i_max_0_err\n")
        fp_sol.flush()

        # archivo con los parametros de calidad de ajuste
        outfile = "%s%sCMWP_FITVAR_PF.mtex" % (files.pathout, files.base_file)
        fp_fitvar = open(outfile, "w")
        fp_fitvar.write("IDEA CMWP --- RESULT FIT FILE --- %s\n" % time.strftime("%d/%m/%Y %I:%M:%S"))
        fp_fitvar.write("Row 2theta theta omega gamma alpha beta WSSR rms redchisq\n")
        fp_fitvar.flush()

        k = 0  # contador del archivo mtex
        # tranformacion angular (gamma, omega) -> (alpha, beta)
        for omega in range(rings.omega_i, rings.omega_f, rings.delta_omega):
            pattern = rings.pattern_i
            for pattern in range(rings.pattern_i, rings.pattern_f + 1, rings.delta_pattern):
                alpha = winkel_al(rings.theta, omega, pattern)
                beta = winkel_be(rings.theta, omega, pattern, alpha)

                # salida al archivo con los valores del ajuste
                fp_sol.write("%d %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f " % (k + 1, 2 * rings.theta, rings.theta, omega, pattern, alpha, beta))
                for i in range(0, cmwp_results.sol.shape[2]):
                    # soluciones matematicas del ajuste
                    fp_sol.write("%8.5f %8.5f " % (cmwp_results.sol[(omega - rings.omega_i) / rings.delta_omega][pattern / rings.delta_pattern][i],
                                                   cmwp_results.solerr[(omega - rings.omega_i) / rings.delta_omega][pattern / rings.delta_pattern][i]))
                fp_sol.write("\n")

                # salida al archivo con los parametros de calidad de ajuste
                fp_fitvar.write("%d %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f " % (k + 1, 2 * rings.theta, rings.theta, omega, pattern, alpha, beta))
                for i in range(0, cmwp_results.fitvar.shape[2]):
                    fp_fitvar.write("%8.5f " % (cmwp_results.fitvar[(omega - rings.omega_i) / rings.delta_omega][pattern / rings.delta_pattern][i]))
                fp_fitvar.write("\n")

                # siguiente dato
                k += 1
        fp_sol.flush()
        fp_sol.close()
        fp_fitvar.flush()
        fp_fitvar.close()
        organize_files(files)
        self.exit = 0
