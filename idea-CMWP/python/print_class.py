from winkel_fns import winkel_al, winkel_be


class cmwp_out:
    def __init__(self, files, rings, cmwp_results):
        for m in range(0, rings.numrings):  # itero sobre todos los picos
            outfile = "%s%s_CMWP_PF_%d_%d.mtex" % (files.pathout,
                                                   files.input_file, m,
                                                   rings.hkl[m])
            fp_cmwp = open(outfile, "w")
            fp_cmwp.write("# Row 2theta theta alpha beta ")
            for field in cmwp_results.header:
                fp_cmwp.write("%s " % field)
            fp_cmwp.write("\n")
            fp_cmwp.flush()

            k = 0  # contador del archivo mtex
            spr = rings.spr_i - 1 # indice que me marca el spr
            # tranformacion angular (gamma, omega) -> (alpha, beta)
            for omega in range(rings.omega_i, rings.omega_f + 1,
                               rings.delta_omega):
                pattern = rings.pattern_i
                for pattern in range(rings.pattern_i, rings.pattern_f + 1,
                                     rings.delta_pattern):
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

                    fp_cmwp.write("%8d %8.4f %8.4f %8.4f %8.4f "
                                  % (k + 1, 2 * rings.theta[m], rings.theta[m],
                                     alpha, beta))
                    # print(cmwp_results.solutions.shape, spr, rings.delta_spr)
                    # print(pattern, rings.delta_pattern)
                    for i in range(1, cmwp_results.solutions.shape[2]):
                        fp_cmwp.write("%8.5f " % (cmwp_results.solutions
                                                  [spr / rings.delta_spr]
                                                  [pattern / rings.delta_pattern][i]))
                        fp_cmwp.write("\n")
                    k += 1
                spr += rings.delta_spr
            fp_cmwp.flush()
            fp_cmwp.close()
        self.exit = 0
