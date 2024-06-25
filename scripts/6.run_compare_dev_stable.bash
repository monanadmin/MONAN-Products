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

if [ $# -ne 4 ]
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
YYYYMMDDHHi=${3}; #YYYYMMDDHHi=2024012000
FCST=${4};        #FCST=6
#-------------------------------------------------------


# Local variables--------------------------------------
DIR_SCRIPTS_CDCT_ESTABLE=/mnt/beegfs/monan/scripts_CD-CT
DIR_SCRIPTS_CDCT_DEV=/mnt/beegfs/monan/scripts_CD-CT_dev/scripts_CD-CT
#-------------------------------------------------------
mkdir -p ${DATAOUT}/${YYYYMMDDHHi}/logs
mkdir -p ${DATAOUT}/${YYYYMMDDHHi}/compare


# Check all input files before
files_needed=("${DIR_SCRIPTS_CDCT_ESTABLE}/dataout/${YYYYMMDDHHi}/Post/MONAN_DIAG_G_POS_${EXP}_${YYYYMMDDHHi}.00.00.x${RES}L55.nc" "${DIR_SCRIPTS_CDCT_DEV}/dataout/${YYYYMMDDHHi}/Post/MONAN_DIAG_G_POS_${EXP}_${YYYYMMDDHHi}.00.00.x${RES}L55.nc")
for file in "${files_needed[@]}"
do
  if [ ! -s "${file}" ]
  then
    echo -e  "\n${RED}==>${NC} ***** ATTENTION *****\n"	  
    echo -e  "${RED}==>${NC} [${0}] At least the file ${file} was not generated. \n"
    exit -1
  fi
done

filename=MONAN_DIAG_G_POS_${EXP}_${YYYYMMDDHHi}.00.00.x${RES}L55.nc
file_stable=${DIR_SCRIPTS_CDCT_ESTABLE}/dataout/${YYYYMMDDHHi}/Post/$filename
file_dev=${DIR_SCRIPTS_CDCT_DEV}/dataout/${YYYYMMDDHHi}/Post/$filename

executable=compare_netcdf.py

cd ${SCRIPTS}

# Creates the submition script
rm -f ${SCRIPTS}/sub_compare_dev_stable.bash ${DATAOUT}/${YYYYMMDDHHi}/logs/diffpy.bash.*
cat << EOSH > ${SCRIPTS}/sub_compare_dev_stable.bash
#!/bin/bash
#SBATCH --job-name=${PRODS6_jobname}
#SBATCH --nodes=${PRODS6_nnodes}
#SBATCH --partition=${PRODS6_QUEUE}
#SBATCH --tasks-per-node=${PRODS6_ncpn}
#SBATCH --ntasks=${PRODS6_ncores}
#SBATCH --time=${PRODS6_walltime}
#SBATCH --output=${DATAOUT}/${YYYYMMDDHHi}/logs/diffpy.bash.o    # File name for standard output
#SBATCH --error=${DATAOUT}/${YYYYMMDDHHi}/logs/diffpy.bash.e     # File name for standard error output
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

export LC_ALL='en_US.utf8'

ulimit -s unlimited
MPI_PARAMS="-iface ib0 -bind-to core -map-by core"
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export I_MPI_DEBUG=5

# The python compare_netcdf.py arguments are:
# 
#--version, -v  : display version info.
#--usage,   -h  : display this usage messsage
#--netcdf1, -n1 : pass in name of 1-band Geotiff holding 1-band panchromatic Geotiff image (high resolution, required)
#--netcdf2, -n2 : pass in name of 3 or 4 band multispectral Geotiff image file (low-resolution, required)
#--plot   , -p  : create output PNG plots for each variable (one plot for variable from first NetCDF1, one from second, then a plot differences)
#--outdir , -o  : output directory (required!)
# 
#

echo "./${executable} -n1 ${file_stable} -n2 ${file_dev} -p -o ${DATAOUT}"
./${executable} -n1 ${file_stable} -n2 ${file_dev} -p -o ${DATAOUT}/${YYYYMMDDHHi}/compare


EOSH

# Submit the products scripts
chmod a+x ${SCRIPTS}/sub_compare_dev_stable.bash
sbatch --wait ${SCRIPTS}/sub_compare_dev_stable.bash
mv ${SCRIPTS}/sub_compare_dev_stable.bash ${DATAOUT}/${YYYYMMDDHHi}/logs/

