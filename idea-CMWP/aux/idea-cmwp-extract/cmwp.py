# -*- coding: utf-8 -*
# - importo modulos
from input_class import file_data
from fitting_class import cmwp_fit
from print_class import cmwp_out
import sys

# leo el archivo de configuracion
print("Getting data")
main_input = sys.argv[1]
fp = open(main_input, 'r')
main_data = fp.readlines()
fp.close()
files = file_data(main_data)

# CMWP fitting routine
print("Extracting CMWP data")
cmwp_results = cmwp_fit(files)

# pasar a coordenadas de figuras de polos y dar salida a archivos
print("Print to files")
success = cmwp_out(files, cmwp_results)
print("Finished with status code %d" % success.exit)
