import numpy
import subprocess


class cmwp_fit:
    def __init__(self, files, rings, flag):
        physsol_name = "%s%s.physsol.csv" % (files.path_base_file, files.base_file)
        fp_physsol = open(physsol_name, "r")
        lines = fp_physsol.readlines()
        n_variables = len(lines[1].split("\t"))
        n_spr = int((rings.spr_f - rings.spr_i + 1) / rings.delta_spr)
        n_pattern = int((rings.pattern_f - rings.pattern_i + 1) / rings.delta_pattern)
        shape = (n_spr, n_pattern, n_variables)
        self.solutions = numpy.zeros(shape)

        for spr in range(rings.spr_i, rings.spr_f, rings.delta_spr):
            print("Processing spr %d\n" % spr)
            for pattern in range(rings.pattern_i, rings.pattern_f, rings.delta_pattern):
                # copio el archivo ini
                origin = "%s/%s%s.ini" % (files.path_base_file, files.base_file,
                                          files.ext)
                destination = "%s/%s_spr_%d_pattern_%d%s.ini" % (files.pathout,
                                                                 files.input_file,
                                                                 spr, pattern,
                                                                 files.ext)
                subprocess.call(["cp", origin, destination])
                # copio el archivo .q.ini
                origin = "%s/%s%s.q.ini" % (files.path_base_file, files.base_file,
                                            files.ext)
                destination = "%s/%s_spr_%d_pattern_%d%s.q.ini" % (files.pathout,
                                                                   files.input_file,
                                                                   spr, pattern,
                                                                   files.ext)
                subprocess.call(["cp", origin, destination])
                # copio el archivo .fit.ini
                # aca habria que agregar algun flag para que se copie desde el
                # archivo anterior tambien se podria agregar alguna rutina para
                # implementar diferentes estrategias de fiteo
                origin = "%s/%s%s.fit.ini" % (files.path_base_file, files.base_file,
                                              files.ext)
                destination = "%s/%s_spr_%d_pattern_%d%s.fit.ini" % (files.pathout,
                                                                     files.input_file,
                                                                     spr, pattern,
                                                                     files.ext)
                subprocess.call(["cp", origin, destination])

                if(flag == 1):
                    # correr el cmwp
                    cmd = './evaluate %s%s_spr_%d_pattern_%d%s auto' % (files.pathout,
                                                                        files.input_file,
                                                                        spr, pattern,
                                                                        files.ext)
                    subprocess.call(cmd, shell=True)
                    # leo el physsol.csv y lo guardo en memoria
                    name_solutions = "%s/%s_spr_%d_pattern_%d%s.physsol.csv" % (files.pathout,
                                                                                files.input_file,
                                                                                spr,
                                                                                pattern,
                                                                                files.ext)
                    fp_solutions = open(name_solutions, "r")
                    lines = fp_solutions.readlines()
                    # guardo todas las soluciones fisicas del fit
                    v = 0
                    self.header = lines[0].split("\t")
                    for x in lines[1].split("\t"):
                        self.solutions[spr / rings.delta_spr][pattern / rings.delta_pattern][v] = float(x)
                        v += 1
