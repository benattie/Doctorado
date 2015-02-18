#script generador de scrpts :P de gnuplot. Este programa me permite general varios script que me permiten graficar, y eventualmente procesar masivamente todos datos que extraje de los RST

data = raw_input('Ingrese el nombre del archivo de datos:\n')

name = 'comp_diffs.gpl'
f = open(name, 'w')
f.write('set key autotitle columnhead\nset grid\n')
for i in range(0,36):
    #Intensidad
    #f.write('set xlabel \'2{/Symbol q}\'\nset ylabel \'Intensidad\'\n')
    #f.write('plot \'' + data + '\' i ' + str(i) + ' u 1:3:4 w error pt 1 ps 1.5, \'rst_py.dat\' i ' + str(i) + ' u 1:3:4 w error pt 2 ps 1.5\n')
    #f.write('pause -1\n')
    #mystr = 'set terminal png enhanced\nset output \'comp_Int_dif' + '{:0>3}'.format(str(10*i)) + '.png\'\n'
    #f.write(mystr)
    #f.write('replot\nset terminal wxt\nset output\n')
    #FWHM
    f.write('set ylabel \'FWHM\'\n')
    f.write('plot \'' + data + '\' i ' + str(i) + ' u 1:5:6 w error pt 5 ps 1.5\n')
    f.write('pause -1\n')
    f.write('set terminal png enhanced\nset output \'FWHM_dif' + '{:0>3}'.format(str(10*i)) + '.png\'\n')
    f.write('replot\nset terminal wxt\nset output\n')

    #ETA
    f.write('set ylabel \'ETA\'\n')
    f.write('plot \'' + data + '\' i ' + str(i) + ' u 1:7:8 w error pt 9 ps 1.5\n')
    f.write('pause -1\n')
    f.write('set terminal png enhanced\nset output \'comp_ETA_dif' + '{:0>3}'.format(str(10*i)) + '.png\'\n')
    f.write('replot\nset terminal wxt\nset output\n')

f.close()
