# MONAN-Products

This repository contains some products for MONAN.

## sanity-check:

Script to make some sanity-check figures of some variables to be plotted on an internal website.

## compare-dev-stable:

This is a simple Python3 command line program created by Gerasimos Michalitsianos that iterates through the corresponding variables of two NetCDF4 or GRIB files and computes some basic statistics (mean, min, max, and standard deviation), writing these statistics to a text file. For each variable, a difference matrix is ​​computed (e.g., the absolute value of the first matrix minus the second matrix), and the same statistics of these differences are computed and written to the output text file.

# History

[Develop] - There is no tagged version yet.

# Instructions

```
$ git clone https://github.com/monanadmin/MONAN-Products.git

$ cd MONAN-Products/scripts

$ ./1.install.bash
```

### sanity-check

24 hour forcast example:
```
./5.run_sanity_check.bash GFS 1024002 2024010100 24 /mnt/beegfs/<user>/<monan_dir>/scripts_CD-CT
```

### compare-dev-stable

24 hour forcast example:
```
./6.run_compare_dev_stable.bash GFS 1024002 2024010100 24 /mnt/beegfs/<user>/<monan_dir_A>/scripts_CD-CT /mnt/beegfs/<user>/<monan_dir_B>/scripts_CD-CT
```
