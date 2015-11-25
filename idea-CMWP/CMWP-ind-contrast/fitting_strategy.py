# -*- coding: utf-8 -*
import numpy
from math import isnan
from functions import get_cmwp_solutions, searchlineinfile, fit_strategy
from functions import copy_cmwp_files


def update_params(files, rings, spr, pattern, find, fit_data, bad_fit, fit_result):
    # print("\nINICIO DEL AJUSTE")
    # print (spr, pattern)
    copy_cmwp_files(files, spr, pattern, rings.hkl)
    physsol_file = "%s%sspr_%d_pattern_%d.physsol.csv" % (files.pathout, files.input_file,
                                                          spr, pattern)
    physsol_file = fit_strategy(files, rings, spr, pattern, find, fit_data)
    if(physsol_file == 1):
        "Mal ajuste en spr = %d y pattern = %d\n" % (spr, pattern)
        bad_result = -1 * numpy.ones((3, 3))
        return (bad_result, 1)
    # print("FIN DEL AJUSTE")
    # clean_cmwp_files(files, spr, pattern)
    (fit_result, bad_fit) = check_fit(files, spr, pattern, find, fit_result)
    return (fit_result, bad_fit)


def check_fit(files, spr, pattern, find, fit_result):
    # defino el vector nan
    v_nan = numpy.array(map(float, ['NaN', 'NaN', 'NaN']))
    result_nan = numpy.vstack((v_nan, v_nan, v_nan))
    # obtengo los resultados
    file_name = "%sspr_%d_pattern_%d" % (files.input_file, spr, pattern)
    sol_file = "%s%s%s%s/%s.sol" % (files.results_folder, files.pathout,
                                    file_name, files.ext, file_name)
    chain = "Final set of parameters"
    (lines, ln) = searchlineinfile(sol_file, chain)
    if(lines == 1):
        fit_result = result_nan
    else:
        fit_result = get_cmwp_solutions(lines, ln + 3, fit_result)

    bad_fit = 0
    for x in fit_result[:, 2]:
        if (x > 100 or isnan(x)):
            bad_fit = 1
    return (fit_result, bad_fit)
