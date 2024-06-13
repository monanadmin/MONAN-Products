"""gera_figs.py: 

gera_figs. py is part of sanity check, a python scripts used to generate images from output os MONAN model post-processor.

"""
__author__      = ["Rodrigues, L.F. [LFR]"]
__copyright__   = "Copyright 2024, INPE"
__credits__     = ["Luiz Flavio Rodrigues"]
__date__        = "20241505"
__license__     = "GPL"
__version__     = "0.1.0"
__maintainer__  = "Rodrigues, L.F."
__email__       = "luiz.rodrigues@inpe.br"
__status__      = "Production"

import numpy as np
import xarray as xr
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import argparse
from datetime import date, datetime, timedelta
import sys
import time
import os

def makegrid(m):
    # ACrescenta detalhes ao mapa
    m.drawcoastlines(linewidth=0.1)
    m.drawstates(linewidth=0.1)
    m.drawcountries(linewidth=0.1)
    m.drawparallels(range(-90, 90, 30), 
                       linewidth=0.3, 
                       labels=[1,0,0,0],
                       color='b',
                       fontsize = 5)
    m.drawmeridians(range(-180, 180, 45),
                      linewidth=0.3, 
                      labels=[0,0,0,1],
                      color='b',
                      rotation=45,
                      fontsize = 5)
    
def clean():
    plt.clf()
    plt.cla()


def get_new_levels(levels, vmin, vmax):

    levels = np.asarray(levels)
    # because levels could be initialized with integers, it convert to integer when inserting
    levels = levels.astype(float)

    # Adjust levels to include vmin and vmax if necessary
    if vmin < levels[0]:
        levels = np.insert(levels, 0, vmin)
    if vmax > levels[-1]:
        levels = np.append(levels, vmax)
    return levels


def plotInFixLev(step,m,minv,maxv,levels,var,unit,tit1,tit2,newdate,figname,output_dir,prefix,date_in,sufix):
    # This functin generate the figure for fields in a fix levels (e.g. t2m, surface_pressure, etc)
    #Ajusta os valores máximos e mínimos da escala
    vmin=minv
    vmax=maxv
    levels = get_new_levels(levels, vmin, vmax)
    #Cria os ranges de valores da escala a ser plotada (clevs)
    cs = m.contourf(x, y, var[step,:,:], levels = levels, cmap='jet', vmin=vmin, vmax =vmax)
    #cs = m.quiver(x, y, vu[0,:,:], vv[0,:,:], color='Teal', angles='xy', scale=100, headlength=7)
    plt.colorbar(cs, orientation='horizontal', label=unit, pad=0.05, aspect=50)
    title = "MONAN_{3} - {0} at level {1} for {2}".format(tit1,tit2,newdate,version)
    plt.title(title)
    date_out = newdate.strftime("%Y%m%d%H")
    figOutname = "{0}{1}_{2}{3}_{4}{5}.png".format(output_dir,figname,prefix,date_in,date_out,sufix)
    #print(figOutname)
    plt.savefig(figOutname, dpi=300, format='png', transparent=True, bbox_inches='tight')

    clean()
    makegrid(m)


def plotInLev(lev,step,m,minv,maxv,levels,var,unit,tit1,tit2,newdate,figname,output_dir,prefix,date_in,sufix):
    # This functin generate the figure for fields in a pressure levels (e.g. temperature, relhum)
    # Ajusta os valores máximos e mínimos da escala
    vmin=minv
    vmax=maxv
    print('vmin', vmin, 'vmax', vmax)
    levels = get_new_levels(levels, vmin, vmax)
    # Cria os ranges de valores da escala a ser plotada (clevs)
    cs = m.contourf(x, y, var[step,lev,:,:], levels = levels, cmap='jet', vmin=vmin, vmax =vmax)
    # cs = m.quiver(x, y, vu[0,:,:], vv[0,:,:], color='Teal', angles='xy', scale=100, headlength=7)
    plt.colorbar(cs, orientation='horizontal', label=unit, pad=0.05, aspect=50)
    title = "MONAN_{3}- {0} at level {1} hPa for {2}".format(tit1,tit2,newdate,version)
    plt.title(title)
    date_out = newdate.strftime("%Y%m%d%H")
    figOutname = "{0}{1}_{2}{3}_{4}{5}.png".format(output_dir,figname,prefix,date_in,date_out,sufix)
    # print(figOutname)
    plt.savefig(figOutname, dpi=300, format='png', transparent=True, bbox_inches='tight')

    clean()
    makegrid(m)

def plotWindInFixLev(step,m,minv,maxv,levels,varu,varv,unit,tit1,tit2,newdate,figname,output_dir,prefix,date_in,sufix):
    # This functin generate the figure for wind fields in a fix levels (e.g. wind at 10m)
    #Ajusta os valores máximos e mínimos da escala
    speed = np.sqrt(varu[step,:,:]**2 + varv[step,:,:]**2)
    vmin=minv
    vmax=maxv
    levels = get_new_levels(levels, vmin, vmax)
    cs = m.contourf(x, y, speed[:,:], levels = levels, cmap='jet', vmin=vmin, vmax =vmax)
    #cs = m.quiver(x, y, vu[0,:,:], vv[0,:,:], color='Teal', angles='xy', scale=100, headlength=7)
    plt.colorbar(cs, orientation='horizontal', label=unit, pad=0.05, aspect=50)    
    title = "MONAN_{3} - {0} at level {1} for {2}".format(tit1,tit2,newdate,version)
    plt.title(title)
    date_out = newdate.strftime("%Y%m%d%H")
    figOutname = "{0}{1}_{2}{3}_{4}{5}.png".format(output_dir,figname,prefix,date_in,date_out,sufix)
    #print(figOutname)
    plt.savefig(figOutname, dpi=300, format='png', transparent=True, bbox_inches='tight')

    clean()
    makegrid(m)

def plotWindInLev(lev,step,m,minv,maxv,levels,varu,varv,unit,tit1,tit2,newdate,figname,output_dir,prefix,date_in,sufix):
    # This functin generate the figure for wind fields in a pressure levels (e.g. wind)
    #Ajusta os valores máximos e mínimos da escala
    speed = np.sqrt(varu[step,lev,:,:]**2 + varv[step,lev,:,:]**2)
    vmin=minv
    vmax=maxv
    levels = get_new_levels(levels, vmin, vmax)
    cs = m.contourf(x, y, speed[:,:], levels = levels, cmap='jet', vmin=vmin, vmax =vmax)
    #cs = m.quiver(x, y, vu[0,:,:], vv[0,:,:], color='Teal', angles='xy', scale=100, headlength=7)
    plt.colorbar(cs, orientation='horizontal', label=unit, pad=0.05, aspect=50)
    title = "MONAN_{3} - {0} at level {1} hPa for {2}".format(tit1,tit2,newdate,version)
    plt.title(title)
    date_out = newdate.strftime("%Y%m%d%H")
    figOutname = "{0}{1}_{2}{3}_{4}{5}.png".format(output_dir,figname,prefix,date_in,date_out,sufix)
    #print(figOutname)
    plt.savefig(figOutname, dpi=300, format='png', transparent=True, bbox_inches='tight')

    clean()
    makegrid(m)



def makedate(dd):
    return dd.strftime("%Y%m%d")+"00"


#The parse arguments is pre defined to MONAN test strucuture default - You can define others in case of changes
parser = argparse.ArgumentParser()
parser.add_argument('--basedir', type=str, default='/mnt/beegfs/monan/scripts_CD-CT/dataout/',       help='Base directory')
parser.add_argument('--datein' , type=str, default=makedate(date.today())                          , help='Date to be processed')
parser.add_argument('--suffix' , type=str, default='.00.00.x1024002L55',                             help='suffix of file in')
parser.add_argument('--prefix' , type=str, default='MONAN_DIAG_G_POS_GFS_',                          help='prefix of file in')
parser.add_argument('--outdir' , type=str, default='/mnt/beegfs/monan/scripts_CD-CT/dataout/', help='Output directory for figures')
parser.add_argument('--tsteps' , type=int, default=3,                                                help='Time between outputs')
parser.add_argument('--mxhour' , type=int, default=120,                                              help='Total of hours to be processed')

#
args = parser.parse_args()
date_in = args.datein
sufix = args.suffix
prefix = args.prefix
base_input_dir = args.basedir
output_dir = args.outdir
tstep = args.tsteps
max_hours = args.mxhour

#The number of steps to be done is the total of hours to be generated by timestep between output
nsteps = int(max_hours/tstep)
datain = datetime.strptime(date_in, '%Y%m%d%H')
# Build the output dir name by outdir/date/figures
output_dir = output_dir+"/"+date_in+"/figures/"
# If not exists create it - Is the local to put the figures
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

print("Processing ",nsteps," outputs from ",date_in," in steps of ",tstep," h" )

#Create the name of input file ands open dataset
file_input = "{0}/{1}/Post/{2}{1}{3}.nc".format(base_input_dir,date_in,prefix,sufix)
file_version = "{0}/{1}/Post/VERSION.txt".format(base_input_dir,date_in)
try:
    file_ver_p = open(file_version, 'r')
    version=file_ver_p.read().strip()
except Exception as e:
    print('Error reading VERSION.txt', e)

start_time = time.time()
print("Getting variables, please wait! This will take a while...")
dataset = xr.open_dataset(file_input)
#Getting variables from input file dataset
latitude = dataset['latitude'].values
longitude = dataset['longitude'].values
t2m = dataset['t2m'].values
rainnc = dataset['rainnc'].values
surface_pressure = dataset['surface_pressure'].values
u10 = dataset['u10'].values
v10 =dataset['v10'].values
relhum      = dataset['relhum'].values
uzonal      = dataset['uzonal'].values
umeridional = dataset['umeridional'].values
temperature = dataset['temperature'].values
end_time = time.time()
elapsed_time = end_time - start_time
print("Elapsed time reading: ", elapsed_time) 

# Creating a global map information
m = Basemap(projection='cyl', resolution='i',
        llcrnrlat=latitude.min(), urcrnrlat=latitude.max(),
        llcrnrlon=longitude.min(), urcrnrlon=longitude.max(), lat_0=0.0,lon_0=0.0)

makegrid(m)
# Transforma a grade para as coordenadas do Basemap
lon, lat = np.meshgrid(longitude, latitude)
x, y = m(lon, lat)

# All levels from model post output
levs = [15.0, 20.0, 30.0, 50.0, 70.0, 100.0, 150.0, 200.0, 250.0, 300.0, 400.0, 500.0, 600.0, 700.0, 825.0, 850.0, 875.0, 900.0, 925.0, 950.0, 975.0, 1000.0]
# Levels to be used in figures
levs_valid = [100.0,200.0,500.0,850.0,1000.0]

start_time = time.time()

surf_press_percent = surface_pressure/100.0
surf_press_percent_min = surf_press_percent.min()
surf_press_percent_max = surf_press_percent.max()

t2m_celsius = t2m-273.15
t2m_celsius_min = t2m_celsius.min()
t2m_celsius_max = t2m_celsius.max()

temperature_celsius = temperature-273.15
temperature_celsius_min = temperature_celsius.min()
temperature_celsius_max = temperature_celsius.max()

rainnc_min = rainnc.min()
rainnc_max = rainnc.max()

wind10m_min = min(u10.min(), v10.min())
wind10_max = max(u10.max(), v10.max())

wind_min = min(uzonal.min(), umeridional.min())
wind_max = max(uzonal.max(), umeridional.max())

relhum_min = relhum.min()
relhum_max = relhum.max()

#Walk in steps
for step in range(nsteps):
    # The newdate is the initial date and hour plus time advance
    steph = step*tstep
    newdate =  datain + timedelta(hours = steph)
    date_out = newdate.strftime("%Y%m%d%H")
    
    print("Doing ... ",steph,":",date_out,"=====================================================")
    #Create the figures os each variable in fix levels
    print("Temp at 2 m      ...")
    plotInFixLev(steph,m,t2m_celsius_min,t2m_celsius_max,[-60,-50,-40,-30,-20,-10,-5,0,5,10,15,20,25,30,35,40,45,50],t2m_celsius,"[C]","Temp.","2m",newdate,"t2m",output_dir,prefix,date_in,sufix)
    print("Surface Pressure ...")
    plotInFixLev(steph,m,surf_press_percent_min,surf_press_percent_max,np.linspace(860,1040,16),surf_press_percent,"hPa","Surf. Pressure.","",newdate,"surface_pressure",output_dir,prefix,date_in,sufix)
    print("Accumulated rain ...")
    plotInFixLev(steph,m,rainnc_min,rainnc_max,[0,0.5,1.0,2.0,5.0,10.0,15.0,20.,30.,40.,50.,60.0,75.,100.0,150.,200.],rainnc,"mm","Precip.","surf.",newdate,"precip",output_dir,prefix,date_in,sufix)
    print("Wind at 10m")
    plotWindInFixLev(steph,m,wind10m_min,wind10_max,[0,1,2,3,4,5,6,7,8,9,10,15,20,25,30,40],u10,v10,"m/s","Wind","10m",newdate,"wind10m",output_dir,prefix,date_in,sufix)

    #Create the figures os each variable in pressure levels
    for nlev in range(len(levs)):
        #Check if level is in valid levels
        if not levs[nlev] in levs_valid:
            continue
        print("---------")
        lev_name = "{0}".format(int(levs[nlev]))
        print("relhum      ...",levs[nlev])
        var_name = "relhum_{0}hPa".format(int(levs[nlev]))
        plotInLev(nlev,steph,m,relhum_min,relhum_max,[0,10,20,30,40,50,60,70,80,90,100],relhum,"%","R.H.",lev_name,newdate,var_name,output_dir,prefix,date_in,sufix)
        print("temperature ...",levs[nlev])
        var_name = "temperature_{0}hPa".format(int(levs[nlev]))
        plotInLev(nlev,steph,m,temperature_celsius_min,temperature_celsius_max,[-80,-60,-50,-40,-30,-20,-10,-5,0,5,10,15,20,25,30,35,40,45,50],temperature_celsius,"C","Temp.",lev_name,newdate,var_name,output_dir,prefix,date_in,sufix)
        print("wind        ...",levs[nlev])
        var_name = "wind_{0}hPa".format(int(levs[nlev]))
        plotWindInLev(nlev,steph,m,wind_min,wind_max,[0,1,2,3,4,5,6,7,8,9,10,15,20,25,30,40,50,60],umeridional,uzonal,"m/s","Wind",lev_name,newdate,var_name,output_dir,prefix,date_in,sufix)
        
print("========================================")
end_time = time.time()
elapsed_time = end_time - start_time
print("Elapsed time ploting: ", elapsed_time) 
print("### Figures generated ###")
