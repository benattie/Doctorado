from winkel_fns import winkel_al, winkel_be


class cmwp_out:
    def __init__(self, files, rings, cmwp_results):
        for m in range(0, rings.numrings):  # itero sobre todos los picos
            # archivo con las soluciones del ajuste
            outfile = "%s%s_CMWP_SOL_PF_%d_%d.mtex" % (files.pathout, files.input_file, m + 1, rings.hkl[m])
            fp_sol = open(outfile, "w")
            fp_sol.write("# Row 2theta theta alpha beta a b c d e\n")
            fp_sol.flush()

            # archivo con las soluciones fisicas
            outfile = "%s%s_CMWP_PHYSSOL_PF_%d_%d.mtex" % (files.pathout, files.input_file, m + 1, rings.hkl[m])
            fp_physsol = open(outfile, "w")
            fp_physsol.write("# Row 2theta theta alpha beta ")
            for field in cmwp_results.header:
                fp_physsol.write("%s " % field)
            fp_physsol.write("\n")
            fp_physsol.flush()

            k = 0  # contador del archivo mtex
            spr = rings.spr_i - 1  # indice que me marca el spr
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
                    fp_sol.write("%8d %8.4f %8.4f %8.4f %8.4f "
                                 % (k + 1, 2 * rings.theta[m], rings.theta[m], alpha, beta))
                    for i in range(0, cmwp_results.sol.shape[2]):
                        fp_sol.write("%8.5f " % (cmwp_results.sol[spr / rings.delta_spr][pattern / rings.delta_pattern][i]))
                    fp_sol.write("\n")

                    # salida al archivo con las soluciones físicas
                    fp_physsol.write("%8d %8.4f %8.4f %8.4f %8.4f "
                                     % (k + 1, 2 * rings.theta[m], rings.theta[m], alpha, beta))
                    for i in range(0, cmwp_results.physsol.shape[2]):
                        fp_physsol.write("%8.5f " % (cmwp_results.physsol[spr / rings.delta_spr][pattern / rings.delta_pattern][i]))
                    fp_physsol.write("\n")

                    # siguiente dato
                    k += 1
                spr += rings.delta_spr
            fp_sol.flush()
            fp_sol.close()
            fp_physsol.flush()
            fp_physsol.close()
        self.exit = 0
