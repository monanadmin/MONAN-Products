#!/bin/bash
#SBATCH --job-name=Compare.Stable
#SBATCH --nodes=1
#SBATCH --partition=proc
#SBATCH --tasks-per-node=1
#SBATCH --ntasks=1
#SBATCH --time=4:00:00
#SBATCH --output=/mnt/beegfs/monan/i534-MONAN-Products/MONAN-Products/scripts/../dataout/2024062400/logs/diffpy.bash.o    # File name for standard output
#SBATCH --error=/mnt/beegfs/monan/i534-MONAN-Products/MONAN-Products/scripts/../dataout/2024062400/logs/diffpy.bash.e     # File name for standard error output
#SBATCH --exclusive

# Set environment variables exports:
echo ""
echo -e "\033[1;32m==>\033[0m Moduling environment for MONAN Products...\n"
. /mnt/beegfs/monan/i534-MONAN-Products/MONAN-Products/scripts/../scripts/setenv.bash



cd $SLURM_SUBMIT_DIR
echo $SLURM_SUBMIT_DIR
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

echo "./compare_netcdf.py -n1 /mnt/beegfs/monan/scripts_CD-CT/dataout/2024062400/Post/MONAN_DIAG_G_POS_GFS_2024062400.00.00.x1024002L55.nc -n2 /mnt/beegfs/monan/scripts_CD-CT_dev/scripts_CD-CT/dataout/2024062400/Post/MONAN_DIAG_G_POS_GFS_2024062400.00.00.x1024002L55.nc -p -o /mnt/beegfs/monan/i534-MONAN-Products/MONAN-Products/scripts/../dataout"
./compare_netcdf.py -n1 /mnt/beegfs/monan/scripts_CD-CT/dataout/2024062400/Post/MONAN_DIAG_G_POS_GFS_2024062400.00.00.x1024002L55.nc -n2 /mnt/beegfs/monan/scripts_CD-CT_dev/scripts_CD-CT/dataout/2024062400/Post/MONAN_DIAG_G_POS_GFS_2024062400.00.00.x1024002L55.nc -p -o /mnt/beegfs/monan/i534-MONAN-Products/MONAN-Products/scripts/../dataout


