# -*- coding: utf-8 -*
import subprocess
import re


def update_params(files, rings, spr, pattern, flag, find):
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
            #                                                   spr, pattern, files.ext)
            # leo el physsol.csv y lo guardo en memoria
            # physsol_file = "%s%sspr_%d_pattern_%d.physsol.csv" % (files.pathout, files.input_file,
            #                                                      spr, pattern)
            # subprocess.call(cmd, shell=True)
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
            step_1(files, rings, spr, pattern, flag, find)
            step_2(files, rings, spr, pattern, flag, find)
            step_3(files, rings, spr, pattern, flag, find)
            physsol_file = step_4(files, rings, spr, pattern, flag)
    else:
        physsol_file = ""
    return physsol_file


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
    lines[17] = "peak_pos_fit=y\n"
    lines[18] = "peak_int_fit=y\n"
    fp.writelines(lines)
    fp.close()
    # defino cual es el archivo anterior
    if(pattern == rings.pattern_i):
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
    while(not(lines[ln].startswith("*** THE SOLUTIONS"))):
        ln += 1
    a = float(re.findall(find, lines[ln + 3])[0])
    b = float(re.findall(find, lines[ln + 4])[0])
    c = float(re.findall(find, lines[ln + 5])[0])
    d = float(re.findall(find, lines[ln + 6])[0])
    e = float(re.findall(find, lines[ln + 7])[0])
    fp.close()
    # genero el archivo .fit.ini
    fit_ini = "%s%sspr_%d_pattern_%d%s.fit.ini" % (files.pathout, files.input_file,
                                                   spr, pattern, files.ext)
    fp = open(fit_ini, "w")
    string = "a_fixed=y\nb_fixed=y\nc_fixed=y\nd_fixed=y\ne_fixed=y\nepsilon_fixed=y\n"
    string += "init_a=%f\ninit_b=%f\ninit_c=%f\ninit_d=%f\ninit_e=%f\ninit_epsilon=1.00\n" % (a, b, c, d, e)
    string += "a_scale=1.0 \nb_scale=1.0\nc_scale=1.0\nd_scale=1.0\ne_scale=1.0"
    fp.write(string)
    fp.close()
    if(flag == 1):
        # correr el cmwp
        cmd = './evaluate %s%sspr_%d_pattern_%d%s auto' % (files.pathout, files.input_file,
                                                           spr, pattern, files.ext)
        subprocess.call(cmd, shell=True)


def step_2(files, rings, spr, pattern, flag, find):
    # copio el archivo .q.ini
    origin = "%s%sspr_%d_pattern_%d%s.q.ini" % (files.pathout, files.input_file,
                                                spr, pattern, files.ext)
    fp = open(origin, "r+")
    lines = fp.readlines()
    lines[17] = "peak_pos_fit=n\n"
    lines[18] = "peak_int_fit=n\n"
    fp.writelines(lines)
    fp.close()
    # leo los resultados del archivo anterior
    sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file, spr, pattern)
    ln = 0
    fp = open(sol_file, "r+")
    lines = fp.readlines()
    while(not(lines[ln].startswith("*** THE SOLUTIONS"))):
        ln += 1
    a = float(re.findall(find, lines[ln + 3])[0])
    b = float(re.findall(find, lines[ln + 4])[0])
    c = float(re.findall(find, lines[ln + 5])[0])
    d = float(re.findall(find, lines[ln + 6])[0])
    e = float(re.findall(find, lines[ln + 7])[0])
    # genero el archivo .fit.ini
    fit_ini = "%s%sspr_%d_pattern_%d%s.fit.ini" % (files.pathout, files.input_file,
                                                   spr, pattern, files.ext)
    fp = open(fit_ini, "w")
    string = "a_fixed=n\nb_fixed=n\nc_fixed=y\nd_fixed=n\ne_fixed=y\nepsilon_fixed=y\n"
    string += "init_a=%f\ninit_b=%f\ninit_c=%f\ninit_d=%f\ninit_e=%f\ninit_epsilon=1.00\n" % (a, b, c, d, e)
    string += "a_scale=1.0 \nb_scale=1.0\nc_scale=1.0\nd_scale=1.0\ne_scale=1.0"
    fp.write(string)
    fp.close()
    if(flag == 1):
        # correr el cmwp
        cmd = './evaluate %s%sspr_%d_pattern_%d%s auto' % (files.pathout, files.input_file,
                                                           spr, pattern, files.ext)
        subprocess.call(cmd, shell=True)


def step_3(files, rings, spr, pattern, flag, find):
    # leo los resultados del archivo anterior
    sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file, spr, pattern)
    ln = 0
    fp = open(sol_file, "r+")
    lines = fp.readlines()
    while(not(lines[ln].startswith("*** THE SOLUTIONS"))):
        ln += 1
    a = float(re.findall(find, lines[ln + 3])[0])
    b = float(re.findall(find, lines[ln + 4])[0])
    c = float(re.findall(find, lines[ln + 5])[0])
    d = float(re.findall(find, lines[ln + 6])[0])
    e = float(re.findall(find, lines[ln + 7])[0])
    # genero el archivo .fit.ini
    fit_ini = "%s%sspr_%d_pattern_%d%s.fit.ini" % (files.pathout, files.input_file,
                                                   spr, pattern, files.ext)
    fp = open(fit_ini, "w")
    string = "a_fixed=y\nb_fixed=y\nc_fixed=n\nd_fixed=y\ne_fixed=n\nepsilon_fixed=y\n"
    string += "init_a=%f\ninit_b=%f\ninit_c=%f\ninit_d=%f\ninit_e=%f\ninit_epsilon=1.00\n" % (a, b, c, d, e)
    string += "a_scale=1.0 \nb_scale=1.0\nc_scale=1.0\nd_scale=1.0\ne_scale=1.0"
    fp.write(string)
    fp.close()
    if(flag == 1):
        # correr el cmwp
        cmd = './evaluate %s%sspr_%d_pattern_%d%s auto' % (files.pathout, files.input_file,
                                                           spr, pattern, files.ext)
        subprocess.call(cmd, shell=True)


def step_4(files, rings, spr, pattern, flag, find):
    # leo los resultados del archivo anterior
    sol_file = "%s%sspr_%d_pattern_%d.sol" % (files.pathout, files.input_file, spr, pattern)
    ln = 0
    fp = open(sol_file, "r+")
    lines = fp.readlines()
    while(not(lines[ln].startswith("*** THE SOLUTIONS"))):
        ln += 1
    a = float(re.findall(find, lines[ln + 3])[0])
    b = float(re.findall(find, lines[ln + 4])[0])
    c = float(re.findall(find, lines[ln + 5])[0])
    d = float(re.findall(find, lines[ln + 6])[0])
    e = float(re.findall(find, lines[ln + 7])[0])
    # genero el archivo .fit.ini
    fit_ini = "%s%sspr_%d_pattern_%d%s.fit.ini" % (files.pathout, files.input_file,
                                                   spr, pattern, files.ext)
    fp = open(fit_ini, "w")
    string = "a_fixed=y\nb_fixed=n\nc_fixed=y\nd_fixed=n\ne_fixed=y\nepsilon_fixed=y\n"
    string += "init_a=%f\ninit_b=%f\ninit_c=%f\ninit_d=%f\ninit_e=%f\ninit_epsilon=1.00\n" % (a, b, c, d, e)
    string += "a_scale=1.0 \nb_scale=1.0\nc_scale=1.0\nd_scale=1.0\ne_scale=1.0"
    fp.write(string)
    fp.close()
    if(flag == 1):
        # correr el cmwp
        cmd = './evaluate %s%sspr_%d_pattern_%d%s auto' % (files.pathout, files.input_file,
                                                           spr, pattern, files.ext)
        subprocess.call(cmd, shell=True)
        # leo el physsol.csv y lo guardo en memoria
        physsol_file = "%s%sspr_%d_pattern_%d.physsol.csv" % (files.pathout, files.input_file,
                                                              spr, pattern)
        return physsol_file
