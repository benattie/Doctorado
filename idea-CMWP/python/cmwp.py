# -*- coding: utf-8 -*
# - importo modulos
from input_class import file_data, fit2d_data
from fitting_class import cmwp_fit
from print_class import cmwp_out
import sys

# leo el archivo de configuracion
print("Getting data")
main_input = sys.argv[1]
fp = open(main_input, 'r')
main_data = fp.readlines()
fp.close()
fit_input = sys.argv[2]
fp = open(fit_input, 'r')
fit_data = fp.readlines()
fp.close()

files = file_data(main_data)
rings = fit2d_data(main_data)

# CMWP fitting routine
print("Performing CMWP fitting")
cmwp_results = cmwp_fit(files, rings, fit_data)

# pasar a coordenadas de figuras de polos y dar salida a archivos
print("Print to files")
success = cmwp_out(files, rings, cmwp_results)
print("Finished with status code %d" % success.exit)
