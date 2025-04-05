#!/bin/bash 
#-----------------------------------------------------------------------------#
# !SCRIPT: run_poducts
#
# !DESCRIPTION:
#     Script to run the products of pos-processing of MONAN model .
#     
#     Performs the following tasks:
# 
#        o Check all input files before (post-processed files)
#        o Creates the submition script
#        o Submit the products scripts
#        o Veriffy all products generated
#        
#
#-----------------------------------------------------------------------------#

if [ $# -ne 5 ]
then
   echo ""
   echo "Instructions: execute the command below"
   echo ""
   echo "${0} EXP_NAME RESOLUTION LABELI FCST"
   echo ""
   echo "EXP_NAME    :: Forcing: GFS"
   echo "            :: Others options to be added later..."
   echo "RESOLUTION  :: number of points in resolution model grid, e.g: 1024002  (24 km)"
   echo "LABELI      :: Initial date YYYYMMDDHH, e.g.: 2024010100"
   echo "FCST        :: Forecast hours, e.g.: 24 or 36, etc."
   echo ""
   echo "24 hour forcast example:"
   echo "${0} GFS 1024002 2024010100 24"
   echo ""

   exit
fi

# Set environment variables exports:
echo ""
echo -e "\033[1;32m==>\033[0m Moduling environment for MONAN model...\n"
. setenv.bash

# TODO - execute install outside here , just when needed, for example
# when a new Python library would be included
#. 1.install.bash

# Standart directories variables:---------------------------------------
DIRHOMES=${DIR_PRODUCTS};     #mkdir -p ${DIRHOMES}  
DIRHOMED=${DIR_PRODUCTD};     #mkdir -p ${DIRHOMED}  
SCRIPTS=${DIRHOMES}/scripts;  #mkdir -p ${SCRIPTS}
DATAIN=${DIRHOMED}/datain;    #mkdir -p ${DATAIN}
DATAOUT=${DIRHOMED}/dataout;  mkdir -p ${DATAOUT}
SOURCES=${DIRHOMES}/sources;  #mkdir -p ${SOURCES}
EXECS=${DIRHOMED}/execs;      #mkdir -p ${EXECS}
#----------------------------------------------------------------------



# Input variables:--------------------------------------
EXP=${1};         #EXP=GFS
RES=${2};         #RES=1024002
YYYYMMDDHHi=${3}; #YYYYMMDDHHi=2024062400
FCST=${4};        #FCST=6
#-------------------------------------------------------


# Local variables--------------------------------------
DIR_SCRIPTS_CDCT_ESTABLE=${5}
#-------------------------------------------------------
mkdir -p ${DATAOUT}/${YYYYMMDDHHi}/logs


# Check all input files before
files_needed=("${DIR_SCRIPTS_CDCT_ESTABLE}/dataout/${YYYYMMDDHHi}/Post/MONAN_DIAG_G_POS_${EXP}_${YYYYMMDDHHi}.00.00.x${RES}L55.nc")
for file in "${files_needed[@]}"
do
  if [ ! -s "${file}" ]
  then
    echo -e  "\n${RED}==>${NC} ***** ATTENTION *****\n"	  
    echo -e  "${RED}==>${NC} [${0}] At least the file ${file} was not generated. \n"
    exit -1
  fi
done



# Creates the submition script
rm -f ${SCRIPTS}/sub_sanity_check.bash ${DATAOUT}/${YYYYMMDDHHi}/logs/sub*
cat << EOSH > ${SCRIPTS}/sub_sanity_check.bash
#!/bin/bash
#SBATCH --job-name=${PRODS_jobname}
#SBATCH --nodes=${PRODS_nnodes}
#SBATCH --partition=${PRODS_QUEUE}
#SBATCH --tasks-per-node=${PRODS_ncpn}
#SBATCH --ntasks=${PRODS_ncores}
#SBATCH --time=${PRODS_walltime}
#SBATCH --output=${DATAOUT}/${YYYYMMDDHHi}/logs/sub_sanity_check.bash.o    # File name for standard output
#SBATCH --error=${DATAOUT}/${YYYYMMDDHHi}/logs/sub_sanity_check.bash.e     # File name for standard error output
#SBATCH --exclusive


# Set environment variables exports:
echo ""
echo -e "\033[1;32m==>\033[0m Moduling environment for MONAN Products...\n"
. ${SCRIPTS}/setenv.bash



cd \$SLURM_SUBMIT_DIR
echo \$SLURM_SUBMIT_DIR
echo "Lista de módulos carregados: "
module list
echo "========"


ulimit -s unlimited
MPI_PARAMS="-iface ib0 -bind-to core -map-by core"
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export I_MPI_DEBUG=5

# The python gera_figs.py arguments are:
# 
# --basedir - Base directory (input)         :: default='/mnt/beegfs/monan/scripts_CD-CT/dataout/'
# --datein  - Date to be processed           :: default=makedate(date.today())
# --suffix  - suffix of file in              :: default='.00.00.x1024002L55'
# --prefix  - prefix of file in              :: default='MONAN_DIAG_G_POS_GFS_'
# --outdir  - Output directory for figures   :: default='/mnt/beegfs/monan/scripts_CD-CT/dataout/'
# --tsteps  - Time in hours between outputs  :: default=3
# --mxhour  - Total of hours to be processed :: default=120
# 
#

python ${SCRIPTS}/sanity_check.py --datein ${YYYYMMDDHHi} --suffix .00.00.x${RES}L55 --outdir ${DATAOUT} --prefix MONAN_DIAG_G_POS_${EXP}_  --mxhour ${FCST} --basedir ${5}/dataout/
EOSH
# Submit the products scripts
chmod a+x ${SCRIPTS}/sub_sanity_check.bash
sbatch --wait ${SCRIPTS}/sub_sanity_check.bash
mv ${SCRIPTS}/sub_sanity_check.bash ${DATAOUT}/${YYYYMMDDHHi}/logs/







