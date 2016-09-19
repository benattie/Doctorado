#!/bin/bash
#
# Script para correr trabajo serial
#

# Opciones SGE

#$ -l h_rt=360:00:00
# Setea HH:MM:SS wall clock time
#$ -cwd
# Cambia al directorio actual
#$ -V
# Exporta las variables de entorno
#$ -N idea_IF75R
# El nombre del job

# Comando para correr el programa, tal cual lo llamaríamos desde la línea de comandos
# unset DISPLAY
module load gslmod
module load intel-13
./idea-cmwp.exe IF75.ini IF75.fit.strategy.ini
