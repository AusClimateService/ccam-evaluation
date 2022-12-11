import iris
import os
from mpi4py import MPI
comm = MPI.COMM_WORLD
i = int(comm.Get_rank())
print(i)


convert = {'ua':'ua','va':'va','omega':'wap','ta':'ta','zg':'zg','hus':'hus','hur':'hur'}
cx = iris.Constraint(longitude=lambda x:0<=x<=360)
cy = iris.Constraint(latitude=lambda x:-90<=x<=90)

def callback(cube,field,filename):
    cube1 = cube.extract(iris.Constraint(longitude=lambda x: x>=0))
    cube2 = cube.extract(iris.Constraint(longitude=lambda x: x<0))
    cube2.coord('longitude').points = cube2.coord('longitude').points + 360
    if cube2.coord('longitude').has_bounds():
        cube2.coord('longitude').bounds = cube2.coord('longitude').bounds + 360
    return iris.cube.CubeList([cube1,cube2]).concatenate_cube()

def prep_for_ilamb(var):
    try:  # pressure level
        height = int(var[-3:])
        var1 = var[:-3]
    except ValueError:  #not pressure level
        height = None
        var1=var
    if height is None:
        path = "/g/data/xv83/bxn599/ACS/data/access-esm1-5/hist/mon/"+convert[var1]+"/*/*/*/*nc"
        #data = iris.load(path,cx&cy,callback) # original
        data = iris.load(path)
    else:
        cp = iris.Constraint(air_pressure=height*100)
        path = "/g/data/xv83/bxn599/ACS/data/access-esm1-5/hist/mon/"+convert[var1]+"/*/*/*/*nc"
        #data = iris.load(path,cx&cy&cp,callback) # original
        data = iris.load(path,cp)
    iris.util.equalise_attributes(data)
    data=data.concatenate_cube()
##    if var1 == 'zg':
###        g = iris.coords.AuxCoord(1/9.8,units='s/m2')
###        data = data*g
##        g = iris.coords.AuxCoord(9.8,units='m s**-2')
##        data = data/g
##        data.rename("geopotential_height")
    data.coord('longitude').bounds = None
    data.coord('latitude').bounds = None
    data.coord('time').bounds = None
    data.coord('longitude').guess_bounds()
    data.coord('latitude').guess_bounds()
    data.coord('time').guess_bounds()
    data.rename(var)
    try:
        os.mkdir("/g/data/xv83/bxn599/ACS/data/access-esm1-5/hist/mon/"+var)
    except:
        1
    iris.save(data,"/g/data/xv83/bxn599/ACS/data/access-esm1-5/hist/mon/{var}/{var}_Amon_ACCESS-ESM1-5_historical_r6i1p1f1_185001-201412.nc".format(var=var),zlib=True,packing='i2')
    
    
        
#['hurs','hus600','hus700','huss','omega500','psl','ta300','ta500','ta600','ta700','ta850','tas','ua200','ua300','ua500','ua850','va200','va300','va500','va850','zg300','zg500']
#variables = ['hus600','hus700','hus850','omega500','ta300','ta500','ta600','ta700','ta850','tas','ua200','ua300','ua500','ua850','va200','va300','va500','va850','zg200','zg500','zg850']

# 21 variables, don't need hur600, hur700, hur850
variables = ['hus600','hus700','hus850','omega500','ta300','ta500','ta600','ta700','ta850','ua200','ua300','ua500','ua850','va200','va300','va500','va850','zg200','zg300','zg500','zg850']
print(len(variables))
prep_for_ilamb(variables[i])
prep_for_ilamb(variables[i+11])
