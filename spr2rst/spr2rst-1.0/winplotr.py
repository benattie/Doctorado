#script orientado a generar un archivo cmd que luego pueda correr en winplotr para ajustar funciones pseudo voight a los picos de un difractograma. La posicion de los picos deber ser ubicada a mano. Los nombres de los archivos de datos utilizados (los dif*.dat) son los obtenidos del script split.py que deberia esta en el mismo directorio

#aca agrego una secuencia de comandos para llamar a winplotr directamente del script. Ver si combienen ponerlo aca o en un script aparte
import subprocess as sub
###########################

for i in range(0,ncol):
	name_dat='dif'+'{:0>3}'.format(str(i))+'.dat'
	name_cmd='fit_win'+'{:0>3}'.format(str(i))+'.cmd'
	f = open(name_cmd, 'w')
	f.write('FILE '+ name_dat + ' 1\n')
	f.write('FIT_SINGLE_PEAK 3.388 3.573\nFIT_SINGLE_PEAK 3.942 4.101\nFIT_SINGLE_PEAK 5.600 5.810\nFIT_SINGLE_PEAK 6.596 6.753\nFIT_SINGLE_PEAK 6.884 7.040\nFIT_SINGLE_PEAK 7.952 8.160\nFIT_SINGLE_PEAK 8.678 8.886\nFIT_SINGLE_PEAK 8.937 9.067\n')
	f.close()
	###############################
	sub.call('winplotr '+name_cmd)
# ver si esto anda sub.call('winplotr_nuevo '+name_cmd)
	##############################
