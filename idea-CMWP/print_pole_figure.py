print("\n====== Begin angular transformation ====== \n")
for m in range(0, numrings): # itero sobre todos los picos
    outfile = "%s%s_CMWP_PF_%d.mtex" % (pathout, input_file, m)
    fp_cmwp = open(outfile, "w")
    fp_cmwp.write("# Row 2theta theta alpha beta ")
    for field in header:
        fp_cmwp.write("%s ", field)
    fp_cmwp.write("\n")
    fp_cmwp.flush()

    k = 0  # contador del archivo mtex
    spr = 1  # indice que me marca el spr
    # tranformacion angular (gamma, omega)-->(alpha,beta)
    for omega in range(omega_i, omega_f + 1, del_ome):
        for gamma in range(gamma_i, gamma_f, del_gam):
            if(omega > 90):
                neu_ome = omega - 90
                neu_gam = gamma + 180
            else:
                neu_ome = omega
                neu_gam = gamma
            alpha = winkel_al(theta[m], neu_ome, neu_gam)
            beta = winkel_be(theta[m], neu_ome, neu_gam, alpha)
            if(alpha > 90):
                alpha = 180 - alpha
                beta = 360 - beta
            else:
                alpha = alpha
            fp_cmwp.write("%8d %8.4f %8.4f %8.4f %8.4f %8.5f "
                          % (k + 1, 2 * theta[m], theta[m], alpha, beta))
            for i in range(1, solutions.shape[2]):
                fp_cmwp.write("%8.5f " % (solutions[spr][gamma][i]))
            fp_cmwp.write("\n")
            k += 1
        spr += 1
    fp_cmwp.flush()
    fp_cmwp.close()
print("\n======= End angular transformation ======= \n")
