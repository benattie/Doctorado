import numpy
from numpy import loadtxt
from numpy import fft
import matplotlib.pyplot as plt

# leo los datos
data = loadtxt('Al70R_spr1_gamma0.dat')
peak_data = loadtxt('peaks.dat', skiprows=1)

# grafico en el espacio de 2theta
# plt.plot(data[:, 0], data[:, 1])
# plt.show()
size = 10
A = numpy.zeros((10, size))
K2 = numpy.zeros((10, 1))

# selecciono el pico
j = 0
for hkl in peak_data[:, 0]:
    start = peak_data[j, 1]
    end = peak_data[j, 2]
    peak = data[start:end, :]
    # plt.plot(peak[:, 0], peak[:, 1])
    # plt.show()

    # correccion por ancho instrumental

    # determino el background y lo resto
    dy = peak[-1, 1] - peak[0, 1]
    dx = peak[-1, 0] - peak[0, 0]
    m = dy / dx
    h = peak[-1, 1] - m * peak[-1, 0]

    def bg(x, m, h):
        return m * x + h

    peak_subs = numpy.copy(peak)
    i = 0
    for x in peak[:, 0]:
        peak_subs[i, 1] = peak[i, 1] - bg(x, m, h)
        i = i + 1
    # plt.plot(peak_subs[:, 0], peak_subs[:, 1])
    # plt.show()

    # normalizo el pico
    peak_norm = numpy.copy(peak_subs)
    max_index = numpy.argmax(peak_subs[:, 1])
    peak_norm[:, 1] = peak_subs[:, 1] / peak_subs[max_index, 1]
    # plt.plot(peak_norm[:, 0], peak_norm[:, 1])
    # plt.show()

    # hago la fft
    peak_fou = fft.rfft(peak_norm[max_index:, 1])

    # plotear los coeficientes
    column0 = range(peak_fou.shape[0])
    # for i in column0:
    #     print (i, peak_fou[i])
    # plt.plot(column0, peak_fou)
    # plt.show()

    # extraigo los primeros veinte coeficientes
    A[j, :] = numpy.real(peak_fou[0:size])
    degree = numpy.pi / 180
    theta_Bragg = peak[max_index, 0] / 2 * degree
    lambda_sync = 0.014235
    K2[j] = (2 * numpy.sin(theta_Bragg) / lambda_sync)**2
    j = j + 1

    print (bg(peak[max_index, 0], m, h) * 100 / peak[max_index, 1])
    # extraer la informacion microestructural

    # normalizo

    # creo la PF
j = 0
A[A == 0] = numpy.nan
logA = numpy.log(A)
for k in K2:
    plt.plot(K2, logA[:, j], marker='o', label='n = %d' % j)
    j = j + 1
plt.legend(loc=9, bbox_to_anchor=(0.5, 1.15), ncol=5)
# plt.show()
plt.savefig('5.png')
