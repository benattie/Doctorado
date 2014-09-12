# -*- coding: utf-8 -*
import subprocess
import re
import numpy
from math import isnan


def update_params(files, rings, spr, pattern, flag, find, bad_fit, fit_result):
    if(flag == 1):
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
            # correr el cmwp
            # cmd = './evaluate %s%sspr_%d_pattern_%d%s auto' % (files.pathout, files.input_file,
            #                                                    spr, pattern, files.ext)
            # subprocess.call(cmd, shell=True)
            # leo el physsol.csv y lo guardo en memoria
            # physsol_file = "%s%sspr_%d_pattern_%d.physsol.csv" % (files.pathout, files.input_file,
            #                                                       spr, pattern)
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
            error = 0
            # n_steps = 1
            # print "Paso %d" % n_steps
            # n_steps += 1
            # error = step_1(files, rings, spr, pattern, flag, find)
            # print "Paso %d" % n_steps
            # n += 1
            error = step_2(files, rings, spr, pattern, flag, find)
            if(error == 1):
                "Mal ajuste en spr = %d y pattern = %d (paso %d)\n" % (spr, pattern, 2)
                return "", 1
            # print "Paso %d" % n_steps
            # n_steps += 1
            error = step_3(files, rings, spr, pattern, flag, find)
            if(error == 1):
                "Mal ajuste en spr = %d y pattern = %d (paso %d)\n" % (spr, pattern, 3)
                return "", 1
            # print "Paso %d" % n_steps
            # n_steps += 1
            physsol_file = step_4(files, rings, spr, pattern, flag, find)
            (bad_fit, fit_result) = check_fit(files, spr, pattern, find)
    else:
        physsol_file = ""
        bad_fit = 0
    return (physsol_file, bad_fit, fit_result)


def check_fit(files, spr, pattern, find):
    # obtengo los resultados del paso 1
    file_name = "%sspr_%d_pattern_%d" % (files.input_file, spr, pattern)
    sol_file = "%s%s%s%s/%s.sol" % (files.results_folder, files.pathout, file_name, files.ext, file_name)
    ln = 0
    fp = open(sol_file, "r")
    lines = fp.readlines()
    success = 1
    while(not(lines[ln].startswith("Final set of parameters"))):
        if(ln == len(lines) - 1):
            fp.close()
            a = numpy.array(map(float, ['NaN', 'NaN', 'NaN']))
            b = numpy.array(map(float, ['NaN', 'NaN', 'NaN']))
            d = numpy.array(map(float, ['NaN', 'NaN', 'NaN']))
            success = 0
            break
        else:
            ln += 1
    if(success):
        a = numpy.array(map(float, re.findall(find, lines[ln + 3])))
        b = numpy.array(map(float, re.findall(find, lines[ln + 4])))
        d = numpy.array(map(float, re.findall(find, lines[ln + 5])))
    fp.close()
    # obtengo los resultados del paso 2
    n_steps = 1
    sol_file = "%s%s%s%s-%d/%s.sol" % (files.results_folder, files.pathout, file_name, files.ext, n_steps, file_name)
    ln = 0
    fp = open(sol_file, "r")
    lines = fp.readlines()
    success = 1
    while(not(lines[ln].startswith("Final set of parameters"))):
        if(ln == len(lines) - 1):
            fp.close()
            c = numpy.array(map(float, ['NaN', 'NaN', 'NaN']))
            e = numpy.array(map(float, ['NaN', 'NaN', 'NaN']))
            success = 0
            break
        else:
            ln += 1
    if(success):
        c = numpy.array(map(float, re.findall(find, lines[ln + 3])))
        e = numpy.array(map(float, re.findall(find, lines[ln + 4])))
    fp.close()
    n_steps += 1
    # obtengo los resultados del paso 3
    sol_file = "%s%s%s%s-%d/%s.sol" % (files.results_folder, files.pathout, file_name, files.ext, n_steps, file_name)
    ln = 0
    fp = open(sol_file, "r")
    lines = fp.readlines()
    success = 1
    while(not(lines[ln].startswith("Final set of parameters"))):
        if(ln == len(lines) - 1):
            fp.close()
            b = numpy.array(map(float, ['NaN', 'NaN', 'NaN']))
            d = numpy.array(map(float, ['NaN', 'NaN', 'NaN']))
            success = 0
            break
        else:
            ln += 1
    if(success):
        b = numpy.array(map(float, re.findall(find, lines[ln + 3])))
        d = numpy.array(map(float, re.findall(find, lines[ln + 4])))
    fp.close()
    n_steps += 1
    fit_result = numpy.vstack((a, b, c, d, e))
    bad_fit = 0
    for x in fit_result[:, 2]:
        if (x > 100 or isnan(x)):
            bad_fit = 1
    return (bad_fit, fit_result)


def step_1(files, rings, spr, pattern, flag, find):
    # copio el archivo ini
    origin = "%s%s%s.ini" % (files.path_base_file, files.base_file, files.ext)
    destination = "%s%sspr_%d_pattern_%d%s.ini" % (files.pathout, files.input_file,
                                                   spr, pattern, files.ext)
    subprocess.call(["cp", origin, destination])
    # genero el archivo .q.ini
    origin = "%s%s%s.q.ini" % (files.path_base_file, files.base_file, files.ext)
    fp = open(origin, "r")
    lines = fp.readlines()
    fp.close()
    destination = "%s%sspr_%d_pattern_%d%s.q.ini" % (files.pathout, files.input_file,
                                                     spr, pattern, files.ext)
    fp = open(destination, "w")
    ln = 0
    while(not(lines[ln].startswith("FIT_LIMIT"))):
        if(ln == len(lines) - 1):
            fp.close()
            return 1
        else:
            ln += 1
    lines[ln] = "FIT_LIMIT=1e-9\n"
    ln = 0
    while(not(lines[ln].startswith("peak_pos_fit") or lines[ln].startswith("peak_int_fit"))):
        if(ln == len(lines) - 1):
            fp.close()
            return 1
        else:
            ln += 1
    lines[ln] = "peak_pos_fit=y\n"
    lines[ln + 1] = "peak_int_fit=y\n"
    fp.writelines(lines)
    fp.close()
    # defino cual es el archivo anterior
    if(pattern == rings.pattern_i + rings.delta_pattern):
        spr_prev = spr - rings.delta_spr
        pattern_prev = rings.pattern_i
    else:
        spr_prev = spr
        pattern_prev = pattern - rings.delta_pattern
    # leo los resultados del archivo anterior
    sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file,
                                              spr_prev, pattern_prev)
    ln = 0
    fp = open(sol_file, "r")
    lines = fp.readlines()
    fp.close()
    while(not(lines[ln].startswith("a_scaled"))):
        if(ln == len(lines) - 1):
            return 1
        else:
            ln += 1
    a = float(re.findall(find, lines[ln + 0])[0])
    b = float(re.findall(find, lines[ln + 1])[0])
    c = float(re.findall(find, lines[ln + 2])[0])
    d = float(re.findall(find, lines[ln + 3])[0])
    e = float(re.findall(find, lines[ln + 4])[0])
    # epsilon = float(re.findall(find, lines[ln + 5])[0])
    # while(not(lines[ln].startswith("The stacking faults probability"))):
    #     ln += 1
    # st_pr = float(re.findall(find, lines[ln + 1])[0])
    # genero el archivo .fit.ini
    fit_ini = "%s%sspr_%d_pattern_%d%s.fit.ini" % (files.pathout, files.input_file,
                                                   spr, pattern, files.ext)
    fp = open(fit_ini, "w")
    string = "init_a=%f\ninit_b=%f\ninit_c=%f\ninit_d=%f\ninit_e=%f\ninit_epsilon=%f\n" % (a, b, c, d, e, 1.0)
    string += "a_fixed=y\nb_fixed=y\nc_fixed=y\nd_fixed=y\ne_fixed=y\nepsilon_fixed=y\n"
    string += "scale_a=1.0\nscale_b=1.0\nscale_c=1.0\nscale_d=1.0\nscale_e=1.0"
    fp.write(string)
    fp.close()
    if(flag == 1):
        # correr el cmwp
        # cmd = './evaluate %s%sspr_%d_pattern_%d%s auto' % (files.pathout, files.input_file, spr, pattern, files.ext)
        cmd = 'unset DISPLAY\n'
        cmd += './evaluate %s%sspr_%d_pattern_%d%s auto >> std_output.txt' % (files.pathout, files.input_file, spr, pattern, files.ext)
        subprocess.call(cmd, shell=True)


def step_2(files, rings, spr, pattern, flag, find):
    # copio el archivo ini
    origin = "%s%s%s.ini" % (files.path_base_file, files.base_file, files.ext)
    destination = "%s%sspr_%d_pattern_%d%s.ini" % (files.pathout, files.input_file,
                                                   spr, pattern, files.ext)
    subprocess.call(["cp", origin, destination])
    # genero el archivo .q.ini
    origin = "%s%s%s.q.ini" % (files.path_base_file, files.base_file, files.ext)
    fp = open(origin, "r")
    lines = fp.readlines()
    fp.close()
    destination = "%s%sspr_%d_pattern_%d%s.q.ini" % (files.pathout, files.input_file,
                                                     spr, pattern, files.ext)
    fp = open(destination, "w")
    ln = 0
    while(not(lines[ln].startswith("FIT_LIMIT"))):
        if(ln == len(lines) - 1):
            fp.close()
            return 1
        else:
            ln += 1
    lines[ln] = "FIT_LIMIT=1e-12\n"
    ln = 0
    while(not(lines[ln].startswith("peak_pos_fit") or lines[ln].startswith("peak_int_fit"))):
        if(ln == len(lines) - 1):
            fp.close()
            return 1
        else:
            ln += 1
    lines[ln] = "peak_pos_fit=n\n"
    lines[ln + 1] = "peak_int_fit=n\n"
    fp.writelines(lines)
    fp.close()
    # defino cual es el archivo anterior
    if(pattern == rings.pattern_i + rings.delta_pattern):
        spr_prev = spr - rings.delta_spr
        pattern_prev = rings.pattern_i + rings.delta_pattern
    else:
        spr_prev = spr
        pattern_prev = pattern - rings.delta_pattern
    # leo los resultados del archivo anterior
    sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file, spr_prev, pattern_prev)
    ln = 0
    fp = open(sol_file, "r")
    lines = fp.readlines()
    fp.close()
    while(not(lines[ln].startswith("a_scaled"))):
        if(ln == len(lines) - 1):
            return 1
        else:
            ln += 1
    a = float(re.findall(find, lines[ln + 0])[0])
    b = float(re.findall(find, lines[ln + 1])[0])
    c = float(re.findall(find, lines[ln + 2])[0])
    d = float(re.findall(find, lines[ln + 3])[0])
    e = float(re.findall(find, lines[ln + 4])[0])
    # epsilon = float(re.findall(find, lines[ln + 5])[0])
    # while(not(lines[ln].startswith("The stacking faults probability"))):
    #     ln += 1
    # st_pr = float(re.findall(find, lines[ln + 1])[0])
    # genero el archivo .fit.ini
    fit_ini = "%s%sspr_%d_pattern_%d%s.fit.ini" % (files.pathout, files.input_file, spr, pattern, files.ext)
    fp = open(fit_ini, "w")
    string = "init_a=%f\ninit_b=%f\ninit_c=%f\ninit_d=%f\ninit_e=%f\ninit_epsilon=%f\n" % (a, b, c, d, e, 1.00)
    string += "a_fixed=n\nb_fixed=n\nc_fixed=y\nd_fixed=n\ne_fixed=y\nepsilon_fixed=y\n"
    string += "scale_a=1.0\nscale_b=1.0\nscale_c=1.0\nscale_d=1.0\nscale_e=1.0"
    fp.write(string)
    fp.close()
    if(flag == 1):
        # correr el cmwp
        # cmd = './evaluate %s%sspr_%d_pattern_%d%s auto' % (files.pathout, files.input_file, spr, pattern, files.ext)
        cmd = 'unset DISPLAY\n'
        cmd += './evaluate %s%sspr_%d_pattern_%d%s auto >> std_output.txt' % (files.pathout, files.input_file, spr, pattern, files.ext)
        subprocess.call(cmd, shell=True)


def step_3(files, rings, spr, pattern, flag, find):
    # leo los resultados del archivo anterior
    sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file, spr, pattern)
    ln = 0
    fp = open(sol_file, "r")
    lines = fp.readlines()
    fp.close()
    while(not(lines[ln].startswith("a_scaled"))):
        if(ln == len(lines) - 1):
            return 1
        else:
            ln += 1
    a = float(re.findall(find, lines[ln + 0])[0])
    b = float(re.findall(find, lines[ln + 1])[0])
    c = float(re.findall(find, lines[ln + 2])[0])
    d = float(re.findall(find, lines[ln + 3])[0])
    e = float(re.findall(find, lines[ln + 4])[0])
    # epsilon = float(re.findall(find, lines[ln + 5])[0])
    # while(not(lines[ln].startswith("The stacking faults probability"))):
    #     ln += 1
    # st_pr = float(re.findall(find, lines[ln + 1])[0])
    # genero el archivo .fit.ini
    fit_ini = "%s%sspr_%d_pattern_%d%s.fit.ini" % (files.pathout, files.input_file,
                                                   spr, pattern, files.ext)
    fp = open(fit_ini, "w")
    string = "init_a=%f\ninit_b=%f\ninit_c=%f\ninit_d=%f\ninit_e=%f\ninit_epsilon=%f\n" % (a, b, c, d, e, 1.00)
    string += "a_fixed=y\nb_fixed=y\nc_fixed=n\nd_fixed=y\ne_fixed=n\nepsilon_fixed=y\n"
    string += "scale_a=1.0\nscale_b=1.0\nscale_c=1.0\nscale_d=1.0\nscale_e=1.0"
    fp.write(string)
    fp.close()

    if(flag == 1):
        # correr el cmwp
        # cmd = './evaluate %s%sspr_%d_pattern_%d%s auto' % (files.pathout, files.input_file, spr, pattern, files.ext)
        cmd = 'unset DISPLAY\n'
        cmd += './evaluate %s%sspr_%d_pattern_%d%s auto >> std_output.txt' % (files.pathout, files.input_file, spr, pattern, files.ext)
        subprocess.call(cmd, shell=True)


def step_4(files, rings, spr, pattern, flag, find):
    # leo los resultados del archivo anterior
    sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file, spr, pattern)
    ln = 0
    fp = open(sol_file, "r")
    lines = fp.readlines()
    fp.close()
    while(not(lines[ln].startswith("a_scaled"))):
        if(ln == len(lines) - 1):
            return 1
        else:
            ln += 1
    a = float(re.findall(find, lines[ln + 0])[0])
    b = float(re.findall(find, lines[ln + 1])[0])
    c = float(re.findall(find, lines[ln + 2])[0])
    d = float(re.findall(find, lines[ln + 3])[0])
    e = float(re.findall(find, lines[ln + 4])[0])
    # epsilon = float(re.findall(find, lines[ln + 5])[0])
    # while(not(lines[ln].startswith("The stacking faults probability"))):
    #     ln += 1
    # st_pr = float(re.findall(find, lines[ln + 1])[0])
    # genero el archivo .fit.ini
    fit_ini = "%s%sspr_%d_pattern_%d%s.fit.ini" % (files.pathout, files.input_file,
                                                   spr, pattern, files.ext)
    fp = open(fit_ini, "w")
    string = "init_a=%f\ninit_b=%f\ninit_c=%f\ninit_d=%f\ninit_e=%f\ninit_epsilon=%f\n" % (a, b, c, d, e, 1.00)
    string += "a_fixed=y\nb_fixed=n\nc_fixed=y\nd_fixed=n\ne_fixed=y\nepsilon_fixed=y\n"
    string += "scale_a=1.0 \nscale_b=1.0\nscale_c=1.0\nscale_d=1.0\nscale_e=1.0"
    fp.write(string)
    fp.close()
    if(flag == 1):
        # correr el cmwp
        # cmd = './evaluate %s%sspr_%d_pattern_%d%s auto' % (files.pathout, files.input_file, spr, pattern, files.ext)
        cmd = 'unset DISPLAY\n'
        cmd += './evaluate %s%sspr_%d_pattern_%d%s auto >> std_output.txt' % (files.pathout, files.input_file, spr, pattern, files.ext)
        subprocess.call(cmd, shell=True)
        # leo el physsol.csv y lo guardo en memoria
        physsol_file = "%s%sspr_%d_pattern_%d.physsol.csv" % (files.pathout, files.input_file,
                                                              spr, pattern)
        return physsol_file
