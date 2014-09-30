#$ -N Vasp-parallel
#
# entorno paralelo a usar, disponibles mpi, mpich, orte, impi, impi8
# impi es el entorno paralelo usual para cálculos con vasp-parallel
# impi8 es para hacer calculos con vasp-parallel usando un multipl de 8 nucleo
# y funciona de tal manera que ocupa integramente (los 8 nucleos) los hosts donde se va a hacer el calculo 
#$ -pe impi8 8

## Seting the maximum run time: setea 1000 horas de wall clock time 
#$ -l h_rt=72:00:00 

## cambio a mi home
#$ -cwd

#################################################################################################
#  Para pedirle que la memoria libre en cada uno de los nodos a utilizar sea mayor que 13000 Mega
####$ -l mem_free=13000M 

# Para reservar 2Giga de momoria (por core!!!)  para el cálculo : -l h_data2G
##$ -l h_data=2G
#################################################################################################

## cola a usar disponibles, pme, shared, all.q. si no ponemos nada busca en todas
##$ -q 'pme'  ! El sistema decide solo la cola a la que lo mando de acuerdo a requerimientos del job y privilegios de los usuarios

# MPIR_HOME, importo variables de entorno del SGE
#$ -V
#$ -v MPIR_HOME=/opt/intel/impi/3.1/bin64,SGE_QMASTER_PORT

# needs in
#   $NSLOTS
#

echo "Got $NSLOTS slots."

PATH="/opt/intel/impi/3.1/bin64:$PATH" ; export path

#######esto es para control#######
#echo  $TMPDIR/machines
#echo "host"
#echo $NHOSTS
##################################


# Ejecución SIN opciones de debug de MPI
$MPIR_HOME/mpirun -machinefile $TMPDIR/machines -l -genv I_MPI_DEVICE sock -n $NSLOTS /opt/vasp/vasp.4.6/vasp-parallel

# Ejecució nCON opciones de debug de MPI
###$MPIR_HOME/mpirun  -machinefile $TMPDIR/machines -l -genv I_MPI_DEBUG 5 -genv I_MPI_DEVICE sock -n $NSLOTS /opt/vasp/vasp.4.6/vasp-parallel

############################################################################################################
# Este bloque es donde se implementa el calculo recursivo usando como flag (para decidir si para
# o sigue) el numero de iteraciones ionicas del calculo anterior (niter=1 => el cálculo finalmente termino).
#
niter=`grep -c E0 OSZICAR`
echo $niter
if [ $niter != 1 ]
then
mkdir ./dir
cp ./CONTCAR ./dir/POSCAR
cp ./POTCAR ./dir/
cp ./INCAR ./dir/
cp ./KPOINTS ./dir/
cp vasp-parallel-recursivo.sh ./dir
cd ./dir
WDIR=`pwd`
echo $WDIR
ssh hpc-cluster qsub -wd $WDIR $WDIR/vasp-parallel-recursivo.sh
fi
#################################################################################################


exit 0
