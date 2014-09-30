#!/bin/bash
#
# Script para correr trabajo serial
#

# Opciones SGE

#$ -l h_rt=00:05:00
# Setea HH:MM:SS wall clock time
#$ -cwd
# Cambia al directorio actual
#$ -V
# Exporta las variables de entorno
#$ -N cmwp
# El nombre del job

# Comando para correr el programa, tal cual lo llamaríamos desde la línea de comandos
unset DISPLAY
./evaluate data/Al6Mg6.dat auto
