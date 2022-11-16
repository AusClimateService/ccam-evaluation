begin
  f = addfile("/g/data/xv83/bxn599/CaRSA/mask_files/ccam_12.5km_masks.nc", "r")
  g = addfile("/g/data/xv83/mxt599/ccam_era5_aus-11i_12.5km_coupled/drs_cordex/CORDEX-CMIP6/output/AUS-11i/CSIRO/ECMWF-ERA5/evaluation/r1i1p1f1/CSIRO-CCAM-2203/v1/fx/sftlf/sftlf_AUS-11i_ECMWF-ERA5_evaluation_r1i1p1f1_CSIRO-CCAM-2203_v1_fx_19870101-19871231.nc", "r")

  sftlf = g->sftlf
  lat = g->lat
  lon = g->lon
  lat_bnds = g->lat_bnds
  lon_bnds = g->lon_bnds

  land_mask = f->land_mask

  delete(land_mask&lat)
  delete(land_mask&lon)
  land_mask&lat = lat
  land_mask&lon = lon
  bnds = lat_bnds&bnds

  nlat = dimsizes(lat)
  nlon = dimsizes(lon)
  nbnds = dimsizes(bnds)

  printVarSummary(land_mask)
  printVarSummary(lat)
  printVarSummary(lat_bnds)

  fout = addfile("./ccam_land.nc","c")

    ;===================================================================
    ; explicitly declare file definition mode. Improve efficiency.
    ;===================================================================
  setfileoption(fout,"DefineMode",True)

    ;===================================================================
    ; create global attributes of the file
    ;===================================================================
  fAtt               = True            ; assign file attributes
  fAtt@title         = "NCL Efficient Approach to netCDF Creation"  
  fAtt@source_file   =  "/g/data/xv83/bxn599/CaRSA/mask_files/ccam_12.5km_masks.nc"
  fAtt@Conventions   = "None"   
  fAtt@creation_date = systemfunc ("date")        
  fileattdef( fout, fAtt )            ; copy file attributes    

    ;===================================================================
    ; predefine the coordinate variables and their dimensionality
    ; Note: to get an UNLIMITED record dimension, we set the dimensionality
    ; to -1 (or the actual size) and set the dimension name to True.
    ;===================================================================
        dimNames = (/"lat", "lon", "bnds"/)  
  dimSizes = (/ nlat,  nlon, nbnds /) 
  dimUnlim = (/ False, False, False /)   
  filedimdef(fout,dimNames,dimSizes,dimUnlim)

    ;===================================================================
    ; predefine the the dimensionality of the variables to be written out
    ;===================================================================
    ; Here we are using NCL functions to facilitate defining 
    ; each variable's dimension name(s) and type. 
    ; The following could be replaced with explicit, user defined dimension 
    ; names different from those associated with the variable in memory. 
    ; Say, PS(time,lat,lon) in the NCL script. They could be redefined for the file via: 
    ; filevardef(fout, "PS"   ,typeof(PS) ,(/"TIME","latitude","longitude"/)) 
    ;===================================================================                         
       filevardef(fout, "lat"  ,typeof(lat),getvardims(lat))                          
       filevardef(fout, "lon"  ,typeof(lon),getvardims(lon))                          
       filevardef(fout, "bnds"  ,typeof(bnds),getvardims(bnds))                                  
       filevardef(fout, "lat_bnds"  ,typeof(lat_bnds),getvardims(lat_bnds))                          
       filevardef(fout, "lon_bnds"  ,typeof(lon_bnds),getvardims(lon_bnds))                          
       filevardef(fout, "land_mask"    ,typeof(land_mask)  ,getvardims(land_mask))                
                                                              ; different from name on script
    ;===================================================================
    ; Copy attributes associated with each variable to the file
    ; All attributes associated with each variable will be copied.
    ;====================================================================
       filevarattdef(fout,"land_mask",land_mask)                           ; copy T attributes
       filevarattdef(fout,"lat"  ,lat)                     ; copy lat attributes
       filevarattdef(fout,"lon"  ,lon)                     ; copy lon attributes
       filevarattdef(fout,"bnds"  ,bnds)                     ; copy lon attributes
       filevarattdef(fout,"lat_bnds"  ,lat_bnds)                     ; copy lat attributes
       filevarattdef(fout,"lon_bnds"  ,lon_bnds)                     ; copy lon attributes

    ;===================================================================
    ; explicitly exit file definition mode. **NOT REQUIRED**
    ;===================================================================
        setfileoption(fout,"DefineMode",False)

    ;===================================================================
    ; output only the data values since the dimensionality and such have
    ; been predefined. The "(/", "/)" syntax tells NCL to only output the
    ; data values to the predefined locations on the file.
    ;====================================================================
       fout->lat    = (/lat/)
       fout->lon    = (/lon/) 
       fout->lat_bnds    = (/lat_bnds/)
       fout->lon_bnds    = (/lon_bnds/) 
       fout->land_mask      = (/land_mask/)
end