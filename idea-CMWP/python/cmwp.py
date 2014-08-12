# -*- coding: utf-8 -*
# - importo modulos
from input_class import file_data, fit2d_data
from fitting_class import cmwp_fit
from print_class import cmwp_out
import sys

# leo el archivo de configuracion
print("Getting data")
f = open('para_cmwp.dat', 'r')
para_data = f.readlines()
files = file_data(para_data)
rings = fit2d_data(para_data)
f.close()

# CMWP fitting routine
flag = int(sys.argv[1])
print("Performing CMWP fitting")
cmwp_results = cmwp_fit(files, rings, flag)

# pasar a coordenadas de figuras de polos y dar salida a archivos
print("Print to files")
success = 0
if (flag == 1):
    success = cmwp_out(files, rings, cmwp_results)
    print("Finished with status code %d" % success.exit)
else:
    print("Finished with status code %d" % success)
# pasar a figura de polos regular
