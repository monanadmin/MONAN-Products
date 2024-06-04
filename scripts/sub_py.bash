#!/bin/bash
#SBATCH --job-name=Prods.MONAN
#SBATCH --nodes=1
#SBATCH --partition=batch
#SBATCH --tasks-per-node=1
#SBATCH --ntasks=1
#SBATCH --time=8:00:00
#SBATCH --output=/mnt/beegfs/carlos.souza/repo_Monan/i523-MONAN-Products_E_MONAN-WorkFlow/MONAN-WorkFlow/ecflow/MONAN/MONAN_CDCT/MONAN-Products/scripts/../dataout/2024060400/logs/subpy.bash.o    # File name for standard output
#SBATCH --error=/mnt/beegfs/carlos.souza/repo_Monan/i523-MONAN-Products_E_MONAN-WorkFlow/MONAN-WorkFlow/ecflow/MONAN/MONAN_CDCT/MONAN-Products/scripts/../dataout/2024060400/logs/subpy.bash.e     # File name for standard error output
#SBATCH --exclusive


# Set environment variables exports:
echo ""
echo -e "\033[1;32m==>\033[0m Moduling environment for MONAN Products...\n"
. /mnt/beegfs/carlos.souza/repo_Monan/i523-MONAN-Products_E_MONAN-WorkFlow/MONAN-WorkFlow/ecflow/MONAN/MONAN_CDCT/MONAN-Products/scripts/../scripts/setenv.bash



cd $SLURM_SUBMIT_DIR
echo $SLURM_SUBMIT_DIR
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

python /mnt/beegfs/carlos.souza/repo_Monan/i523-MONAN-Products_E_MONAN-WorkFlow/MONAN-WorkFlow/ecflow/MONAN/MONAN_CDCT/MONAN-Products/scripts/../scripts/gera_figs.py --datein 2024060400 --suffix .00.00.x1024002L55 --outdir /mnt/beegfs/carlos.souza/repo_Monan/i523-MONAN-Products_E_MONAN-WorkFlow/MONAN-WorkFlow/ecflow/MONAN/MONAN_CDCT/MONAN-Products/scripts/../dataout --prefix MONAN_DIAG_G_POS_GFS_  --mxhour 240
