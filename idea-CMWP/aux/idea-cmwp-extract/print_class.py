# -*- coding: utf-8 -*
from winkel_fns import winkel_al, winkel_be
import time


class cmwp_out:
    def __init__(self, files, cmwp_results):
        # archivo con las soluciones del ajuste
        outfile = "%s%sCMWP_SOL_PF.mtex" % (files.pathout, files.base_file)
        fp_sol = open(outfile, "w")
        fp_sol.write("# IDEA CMWP --- RESULT SOL FILE --- %s\n" % time.strftime("%d/%m/%Y %I:%M:%S"))
        fp_sol.write("# Row 2theta theta alpha beta a a_err b b_err c c_err d d_err e e_err\n")
        fp_sol.flush()

        # archivo con las soluciones fisicas
        outfile = "%s%sCMWP_PHYSSOL_PF.mtex" % (files.pathout, files.base_file)
        fp_physsol = open(outfile, "w")
        fp_physsol.write("# IDEA CMWP --- RESULT PHYSSOL FILE --- %s\n" % time.strftime("%d/%m/%Y %I:%M:%S"))
        fp_physsol.write("# Row 2theta theta alpha beta ")
        for field in cmwp_results.header:
            fp_physsol.write("%s " % field)
        fp_physsol.write("\n")
        fp_physsol.flush()

        # archivo con los parametros de calidad de ajuste
        outfile = "%s%sCMWP_FITVAR_PF.mtex" % (files.pathout, files.base_file)
        fp_fitvar = open(outfile, "w")
        fp_fitvar.write("# IDEA CMWP --- RESULT FIT FILE --- %s\n" % time.strftime("%d/%m/%Y %I:%M:%S"))
        fp_fitvar.write("# Row 2theta theta alpha beta WSSR rms redchisq\n")
        fp_fitvar.flush()

        k = 0  # contador del archivo mtex
        spr = files.spr_i  # indice que me marca el spr
        ptrn_i = files.pattern_i + files.delta_pattern
        # tranformacion angular (gamma, omega) -> (alpha, beta)
        for omega in range(files.omega_i, files.omega_f + 1, files.delta_omega):
            for pattern in range(files.pattern_i, files.pattern_f + 1, files.delta_pattern):
                if(omega > 90):
                    neu_ome = omega - 90
                    neu_gam = pattern + 180
                else:
                    neu_ome = omega
                    neu_gam = pattern

                alpha = winkel_al(files.theta, neu_ome, neu_gam)
                beta = winkel_be(files.theta, neu_ome, neu_gam, alpha)
                if(alpha > 90):
                    alpha = 180 - alpha
                    beta = 360 - beta

                # salida al archivo con los valores del ajuste
                fp_sol.write("%4d %8.4f %8.4f %8.4f %8.4f " % (k + 1, 2 * files.theta, files.theta, alpha, beta))
                sol = cmwp_results.sol[(spr - files.spr_i) / files.delta_spr][(pattern - ptrn_i) / files.delta_pattern]
                err = cmwp_results.solerr[(spr - files.spr_i) / files.delta_spr][(pattern - ptrn_i) / files.delta_pattern]
                rer = cmwp_results.solerr[(spr - files.spr_i) / files.delta_spr][(pattern - ptrn_i) / files.delta_pattern]
                for i in range(0, cmwp_results.sol.shape[2]):
                    if(sol[i] != 0):
                        rer[i] = err[i] / sol[i] * 100
                    else:
                        rer[i] = 200
                    # soluciones matematicas del ajuste
                    fp_sol.write("%8.5f %8.5f " % (sol[i], err[i]))
                fp_sol.write("\n")

                # salida al archivo con las soluciones fisicas
                fp_physsol.write("%8d %8.4f %8.4f %8.4f %8.4f " % (k + 1, 2 * files.theta, files.theta, alpha, beta))
                for i in range(0, cmwp_results.physsol.shape[2]):
                    if(rer[3] < 1000):
                        fp_physsol.write("%8.5f " % (cmwp_results.physsol[(spr - files.spr_i) / files.delta_spr][(pattern - ptrn_i) / files.delta_pattern][i]))
                    else:
                        fp_physsol.write("%8.5f " % -1)
                fp_physsol.write("\n")

                # salida al archivo con los parametros de calidad de ajuste
                fp_fitvar.write("%8d %8.4f %8.4f %8.4f %8.4f " % (k + 1, 2 * files.theta, files.theta, alpha, beta))
                for i in range(0, cmwp_results.fitvar.shape[2]):
                    fp_fitvar.write("%8.5f " % (cmwp_results.fitvar[(spr - files.spr_i) / files.delta_spr][(pattern - ptrn_i) / files.delta_pattern][i]))
                fp_fitvar.write("\n")

                # siguiente dato
                k += 1
            spr += files.delta_spr
        fp_sol.flush()
        fp_sol.close()
        fp_physsol.flush()
        fp_physsol.close()
        fp_fitvar.flush()
        fp_fitvar.close()
        self.exit = 0
