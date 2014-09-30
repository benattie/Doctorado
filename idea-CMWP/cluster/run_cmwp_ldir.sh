#!/bin/bash
#$ -S /bin/bash
#
### Job Name
#$ -N NAME
#
###### Add the $ symbol after # only in the desired SGE option
#
### Select a queue
##$ -q  'long_amd'
#
#
### Write output files .oxxxx .exxxx in current directory
#$ -cwd
#                                                                                                                                                                                           
### Merge '-j y' (do not merge '-j n') stderr into stdout stream:                                                                                                                           
#$ -j y                                                                                                                                                                                     
#                                                                                                                                                                                           
                                                                                                                                                                                            
## Seting the maximum run time: setea el wall clock time                                                                                                                                    
#$ -l h_rt=24:00:00                                                                                                                                                                         
                                                                                                                                                                                            
# -------- SECTION print some infos to stdout ---------------------------------                                                                                                             
echo " "                                                                                                                                                                                    
echo "START_TIME           = `date +'%y-%m-%d %H:%M:%S %s'`"
START_TIME=`date +%s`
echo "HOSTNAME             = $HOSTNAME"
echo "JOB_NAME             = $JOB_NAME"
echo "JOB_ID               = $JOB_ID"
echo "SGE_O_WORKDIR        = $SGE_O_WORKDIR"
echo "NSLOTS               = $NSLOTS"
echo "PE_HOSTFILE          = $PE_HOSTFILE"
if [ -e "$PE_HOSTFILE" ]; then
  echo "--------------------------------------------------------"
  cat $PE_HOSTFILE
  echo "--------------------------------------------------------"
fi
echo "Creating TMP_WORK_DIR directory ..."
echo " "

TMP_WORK_DIR="/local/$USER/$JOB_ID"
echo "TMP_WORK_DIR         = $TMP_WORK_DIR"
mkdir -vp "${TMP_WORK_DIR}" || die "Could not create TMP_WORK_DIR '$TMP_WORK_DIR'."
#echo "Copying SGE script to TMP_WORK_DIR ..."
#cp -v "$0" "${TMP_WORK_DIR}/"
cd "${TMP_WORK_DIR}"        || die "Could not change to TMP_WORK_DIR '$TMP_WORK_DIR'."
echo "Now we are in directory '`pwd`'."


# -------- SECTION copy input files from $HOME to $TMP_WORK_DIR ---------------
# # SGE_O_WORKDIR is the dir where you did type 'qsub vasp-example.sge'.
# # You can copy your VASP input files here:
echo " "
echo "Copying input files from your submit dir:"
echo " "
cp -v $SGE_O_WORKDIR/{....lista de archivos de entrada....}         $TMP_WORK_DIR/

#-------- SECTION executing VASP  ---------------------------------------------

echo " "
echo "Calling EXE:"
echo " "

PATH="/opt/intel/impi/3.1/bin64:$PATH" ; export path

EXE= ....ejecutable con su path....

$EXE

# -------- SECTION clean up files ---------------------------------------------
echo " "
echo "Cleaning up files ... removing unnecessary files ..."
echo " "
rm -vf ....Lista de archivos de salida que no me interesa conservar .....

# Correct group IDs of files (since vasp is setgid):
group=`groups "$USER" | sed 's/^.*://g' | awk '{print $1}'`
echo " "
echo "Correcting group '$group' for user '$USER' in '$TMP_WORK_DIR'."
[ "$group" ] && chgrp -c -R "$group" "${TMP_WORK_DIR}"
sleep 10 # Wait some time for potential stale nfs handles to disappear.

# -------- SECTION copy back results ------------------------------------------
echo " "
echo "Compressing results and copying back result archive ..."
echo " "
# Get parent dir and name of "${TMP_WORK_DIR}":
work_pdir=`dirname  "${TMP_WORK_DIR}"` # Parent dir of TMP_WORK_DIR
work_name=`basename "${TMP_WORK_DIR}"` # Name of TMP_WORK_DIR
echo "work_pdir         = $work_pdir"
echo "work_name         = $work_name"
cd "${work_pdir}"
# Create and move back tgz file:
tar -zcvf "${work_name}.tgz" "${work_name}" \
  || die "Tgz of '$work_name' in '$work_pdir' failed."
mv -vf "${work_name}.tgz" "${SGE_O_WORKDIR}/"  \
  || die "'mv ${work_name}.tgz $SGE_O_WORKDIR' failed."

# -------- SECTION final cleanup and timing statistics ------------------------
# -------- NO NEED TO MODIFY THIS SECTION -------------------------------------
echo " "
echo "Final cleanup: Remove TMP_WORK_DIR, and print timings ..."
echo " "
cd "${work_pdir}"; rm -vrf "${TMP_WORK_DIR}" 
echo "END_TIME (success)   = `date +'%y-%m-%d %H:%M:%S %s'`"
END_TIME=`date +%s`
echo "RUN_TIME (hours)     = "`echo "$START_TIME $END_TIME" | awk '{printf("%.4f",($2-$1)/60.0/60.0)}'`

exit 0
