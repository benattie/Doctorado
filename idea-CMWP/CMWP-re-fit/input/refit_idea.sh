#!/bin/bash
#
# Script para correr trabajo serial
#

# Opciones SGE
## Select a queue
##$ -q 'medium_intel'

#$ -l h_rt=47:00:00
# Setea HH:MM:SS wall clock time
#$ -cwd
# Cambia al directorio actual
#$ -V
# Exporta las variables de entorno
#$ -N IF75R_110
# El nombre del job

# Comando para correr el programa, tal cual lo llamaríamos desde la línea de comandos
# unset DISPLAY
module load intel-13
python ./CMWP-re-fit/cmwp.py IF75.indC.ini IF75.refit.fit.strategy.ini
