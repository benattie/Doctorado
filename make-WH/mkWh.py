import numpy
from os import mkdir
from os import stat
from sys import argv
from functions import read_ini
from functions import calc_H2

# read the input data
ini_file = argv[1]
(out_path, idea_path, cmwp_path, filename, wavelength, Ch00, npeaks,
 peaks_hkl) = read_ini(ini_file)

# get q values
full_name = cmwp_path + filename + "CMWP_PHYSSOL_PF.mtex"
# 2 = theta, 3 = omega, 4 = gamma, 5 = alpha, 6 = beta, 7 = q
# 0 = theta, 1 = omega, 2 = gamma, 3 = alpha, 4 = beta, 5 = q
cmwp_values = numpy.loadtxt(full_name, dtype=float, skiprows=2,
                            usecols=(2, 3, 4, 5, 6, 7))

# Alloc memory
nvalues = cmwp_values.shape[0]
degree = numpy.pi / 180.
theta = numpy.zeros((npeaks, nvalues))
K = numpy.zeros((npeaks, nvalues))
FWHM = numpy.zeros((npeaks, nvalues))
FWHM_err = numpy.zeros((npeaks, nvalues))
q = numpy.zeros((nvalues, 1))
DK = numpy.zeros((npeaks, nvalues))
DK_err = numpy.zeros((npeaks, nvalues))
H2 = numpy.zeros((npeaks, 1))
C = numpy.zeros((npeaks, nvalues))


for i in range(0, npeaks):
    full_name = idea_path + filename + "PF_%d.mtex" % (i + 1)
    # 2=theta, 3=omega, 4=gamma, 5=alpha, 6=beta, 10=FWHM, 11=err
    # 0=theta, 1=omega, 2=gamma, 3=alpha, 4=beta, 5=FWHM, 6=err
    idea_values = numpy.loadtxt(full_name, dtype=float, skiprows=2,
                                usecols=(2, 3, 4, 5, 6, 10, 11))
    H2[i] = calc_H2(peaks_hkl[i, 1], peaks_hkl[i, 2], peaks_hkl[i, 3])
    for j in range(0, nvalues):
        theta[i, j] = idea_values[j, 0]
        FWHM[i, j] = idea_values[j, 5]
        FWHM_err[i, j] = idea_values[j, 6]
        q[j] = cmwp_values[j, 5]
        C[i, j] = Ch00 * (1 - q[j] * H2[i])
        K[i, j] = 2 * numpy.sin(theta[i, j] * degree) / wavelength
        DK[i, j] = numpy.cos(theta[i, j] * degree) * \
            (FWHM[i, j] * degree) / wavelength
        DK_err[i, j] = numpy.cos(theta[i, j] * degree) * \
            (FWHM_err[i, j] * degree) / wavelength


# Output to files
out_folder = out_path + "WH/"
try:
    stat(out_folder)
except:
    mkdir(out_folder)

for k in range(0, nvalues):
    fp_out_name = out_folder + "WH_Plot_%d.dat" % (k + 1)
    fp_out = open(fp_out_name, 'w')
    out_array = numpy.column_stack((K[:, k], C[:, k],
                                    K[:, k] * (C[:, k]**0.5),
                                    (K[:, k]**2) * C[:, k],
                                    DK[:, k], DK_err[:, k]))
    title = "K C KC**1/2 K**2C DeltaK err"
    numpy.savetxt(fp_out_name, out_array, fmt='%.4f', delimiter=' ',
                  newline='\n', header=title)
