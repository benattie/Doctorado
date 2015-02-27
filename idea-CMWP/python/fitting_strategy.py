# -*- coding: utf-8 -*
import subprocess
import numpy
from math import isnan
from functions import getcmwpsolutions, searchlineinfile, fit_strategy


def update_params(files, rings, spr, pattern, find, fit_data, bad_fit, fit_result):
    if(spr == rings.spr_i and pattern == rings.pattern_i + rings.delta_pattern):
        # copio el archivo ini
        origin = "%s%s%s.ini" % (files.path_base_file, files.base_file, files.ext)
        destination = "%s%sspr_%d_pattern_%d%s.ini" % (files.pathout, files.input_file,
                                                       spr, pattern, files.ext)
        subprocess.call(["cp", origin, destination])
        # copio el archivo .q.ini
        origin = "%s%s%s.q.ini" % (files.path_base_file, files.base_file, files.ext)
        destination = "%s%sspr_%d_pattern_%d%s.q.ini" % (files.pathout, files.input_file,
                                                         spr, pattern, files.ext)
        subprocess.call(["cp", origin, destination])
        # copio el archivo .fit.ini
        origin = "%s%s%s.fit.ini" % (files.path_base_file, files.base_file, files.ext)
        destination = "%s%sspr_%d_pattern_%d%s.fit.ini" % (files.pathout, files.input_file,
                                                           spr, pattern, files.ext)
        subprocess.call(["cp", origin, destination])
        # copio el physsol del archivo base
        origin = "%s%s.physsol.csv" % (files.path_base_file, files.base_file)
        destination = "%s%sspr_%d_pattern_%d.physsol.csv" % (files.pathout, files.input_file,
                                                             spr, pattern)
        subprocess.call(["cp", origin, destination])
        # copio el sol del archivo base
        origin = "%s%s.sol" % (files.path_base_file, files.base_file)
        destination = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file,
                                                     spr, pattern)
        subprocess.call(["cp", origin, destination])
        physsol_file = "%s%sspr_%d_pattern_%d.physsol.csv" % (files.pathout, files.input_file,
                                                              spr, pattern)
    else:
        physsol_file = fit_strategy(files, rings, spr, pattern, find, fit_data)
        if(physsol_file == 1):
            "Mal ajuste en spr = %d y pattern = %d\n" % (spr, pattern)
            return ("", 1, 1)
        (bad_fit, fit_result) = check_fit(files, spr, pattern, find)
    return (physsol_file, bad_fit, fit_result)


def check_fit(files, spr, pattern, find):
    # defino el vector nan
    v_nan = numpy.array(map(float, ['NaN', 'NaN', 'NaN']))
    # obtengo los resultados del paso 1
    file_name = "%sspr_%d_pattern_%d" % (files.input_file, spr, pattern)
    sol_file = "%s%s%s%s/%s.sol" % (files.results_folder, files.pathout, file_name, files.ext, file_name)
    chain = "Final set of parameters"
    (lines, ln) = searchlineinfile(file_name, chain)
    if(lines == 1):
        (a, b, c, d, e) = (v_nan, v_nan, v_nan, v_nan, v_nan)
    else:
        (a, b, c, d, e) = getcmwpsolutions(lines, ln)
    # obtengo los resultados del paso 2
    n_steps = 1
    sol_file = "%s%s%s%s-%d/%s.sol" % (files.results_folder, files.pathout, file_name, files.ext, n_steps, file_name)
    chain = "Final set of parameters"
    (lines, ln) = searchlineinfile(file_name, chain)
    if(lines == 1):
        (a, b, c, d, e) = (v_nan, v_nan, v_nan, v_nan, v_nan)
    else:
        (a, b, c, d, e) = getcmwpsolutions(lines, ln)
    n_steps += 1
    # obtengo los resultados del paso 3
    sol_file = "%s%s%s%s-%d/%s.sol" % (files.results_folder, files.pathout, file_name, files.ext, n_steps, file_name)
    chain = "Final set of parameters"
    (lines, ln) = searchlineinfile(file_name, chain)
    if(lines == 1):
        (a, b, c, d, e) = (v_nan, v_nan, v_nan, v_nan, v_nan)
    else:
        (a, b, c, d, e) = getcmwpsolutions(lines, ln)
    n_steps += 1
    fit_result = numpy.vstack((a, b, c, d, e))
    bad_fit = 0
    for x in fit_result[:, 2]:
        if (x > 100 or isnan(x)):
            bad_fit = 1
    return (bad_fit, fit_result)
