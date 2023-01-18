; plot bias and rmse

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/g/data/xv83/users/bxn599/CaRSA/rav_ncl/percentiles.ncl"

begin
  print(systemfunc("date"))

  foutname = "./"+run_name+"_"+var+"_annual_added_value_bias_rmse_awap_grid.nc"

  if (fileexists(foutname)) then
    exit
  end if

  ; land sea mask file (AWAP grid)
  f2 = addfile("/scratch/e53/mxt599/esci/sftrf_AWAP0.05_NRMv3.nc", "r")
  lsmask = f2->AUS

  yyyymmdd_start = (yyyy_start*10000)+101
  yyyymmdd_end = (yyyy_end*10000)+1231

  yyyy = ispan(yyyy_start, yyyy_end, 1)
  yyyymm = yyyymm_time(yyyy_start, yyyy_end, "integer")
  window = yyyy_end - yyyy_start + 1
  
  ls_obs_var = ls_obs+yyyy+".nc"
  ls_rcm_var = ls_rcm+yyyymm+".nc"
  ls_gdd_var = systemfunc("ls "+ls_gdd+"*.nc");ls_gdd+yyyy+".nc"

  f_obs_var = addfiles(ls_obs_var, "r")
  f_rcm_var = addfiles(ls_rcm_var, "r")
  f_gdd_var = addfiles(ls_gdd_var, "r")

  obs_time = f_obs_var[:]->time
  obs_date = cd_calendar(obs_time, -2)
  obs_start = ind(obs_date.eq.yyyymmdd_start)
  obs_end = ind(obs_date.eq.yyyymmdd_end)

  obs_varn = f_obs_var[:]->$obs_var_name$(obs_start:obs_end,{-44.5:-10},{112:156.25})
  if obs_varn@units .eq. "kg/m2/s" .or. obs_varn@units .eq."kg m-2 s-1" then
    obs_varn = obs_varn*86400
    obs_varn@units = "mm/day"
  else if obs_varn@units .eq. "mm" then
    obs_varn@units = "mm/day"
  end if
  end if

  if obs_varn@units .eq. "K" .or. obs_varn@units .eq."degK" then
    obs_varn = obs_varn-273.15
    obs_varn@units = "degC"
  end if

  obs_varn!1 = "lat"
  obs_varn!2 = "lon"
  delete([/obs_time, obs_date, obs_start, obs_end/])

  rcm_time = f_rcm_var[:]->time
  rcm_date = cd_calendar(rcm_time, -2)
  rcm_start = ind(rcm_date.eq.yyyymmdd_start)
  rcm_end = ind(rcm_date.eq.yyyymmdd_end)

  rcm_varn_ = f_rcm_var[:]->$rcm_var_name$(:,{-44.5:-10},{112:156.25}) ; use all time steps because raw RCM output is from 19800102 to 20200101, NOT 19800101 to 20191213
  if rcm_varn_@units .eq. "kg/m2/s" .or. rcm_varn_@units .eq."kg m-2 s-1" then
    rcm_varn_ = rcm_varn_*86400
    rcm_varn_@units = "mm/day"
  end if
  if rcm_varn_@units .eq. "K" .or. rcm_varn_@units .eq."degK" then
    rcm_varn_ = rcm_varn_-273.15
    rcm_varn_@units = "degC"
  end if

  rcm_varn_!1 = "lat"
  rcm_varn_!2 = "lon"
  delete([/rcm_time, rcm_date, rcm_start, rcm_end/])

;  time =  rcm_varn_&time
;  rcm_yyyymmdd = yyyymmdd_time(yyyy_start, yyyy_end, "integer")
;  rcm_yyyy = rcm_yyyymmdd/10000
;  rcm_mmdd = rcm_yyyymmdd-rcm_yyyy*10000
;  rcm_mm = rcm_mmdd/100
;  rcm_dd = rcm_mmdd-rcm_mm*100
;  rcm_hh = rcm_dd
;  rcm_mn = rcm_dd
;  rcm_sc = rcm_dd
;  rcm_hh = 0
;  rcm_mn = 0
;  rcm_sc = 0
;
;  rcm_time_units = "hours since 1900-01-01 00:00:00"
;  new_time = cd_inv_calendar(rcm_yyyy, rcm_mm, rcm_dd, rcm_hh, rcm_mn, rcm_sc, rcm_time_units, 0)

  gdd_time = f_gdd_var[:]->time
  gdd_date = cd_calendar(gdd_time, -2)
  gdd_start = ind(gdd_date.eq.yyyymmdd_start)
  gdd_end = ind(gdd_date.eq.yyyymmdd_end)

  delete(rcm_varn_&time)
  rcm_varn_&time = gdd_time
  rcm_time = rcm_varn_&time
  rcm_date = cd_calendar(rcm_time, -2)
  rcm_start = ind(rcm_date.eq.yyyymmdd_start)
  rcm_end = ind(rcm_date.eq.yyyymmdd_end)
  rcm_varn = rcm_varn_(rcm_start:rcm_end,:,:)
  delete([/rcm_time, rcm_date, rcm_start, rcm_end, rcm_varn_/])

  gdd_varn = f_gdd_var[:]->$gdd_var_name$(gdd_start:gdd_end,{-44.5:-10},{112:156.25})
  if gdd_varn@units .eq. "kg/m2/s" .or. gdd_varn@units .eq."kg m-2 s-1" then
    gdd_varn = gdd_varn*86400
    gdd_varn@units = "mm/day"
  else if gdd_varn@units .eq. "m" then
    gdd_varn = gdd_varn*1000
    gdd_varn@units = "mm/day"
  end if
  end if
  if gdd_varn@units .eq. "K" .or. gdd_varn@units .eq."degK" then
    gdd_varn = gdd_varn-273.15
    gdd_varn@units = "degC"
  end if

  gdd_varn!1 = "lat"
  gdd_varn!2 = "lon"
  delete([/gdd_time, gdd_date, gdd_start, gdd_end/])

  print(systemfunc("date"))
  print("Calculating climatology")
; calculate climatology
  obs_var_month = calculate_monthly_values(obs_varn, "avg", 0, False) ; monthly average
  rcm_var_month = calculate_monthly_values(rcm_varn, "avg", 0, False) ; monthly average
  gdd_var_month = calculate_monthly_values(gdd_varn, "avg", 0, False) ; monthly average

  obs_var_ann = month_to_annual(obs_var_month, 1)
  rcm_var_ann = month_to_annual(rcm_var_month, 1)
  gdd_var_ann = month_to_annual(gdd_var_month, 1)

  obs_var_ann_avg = dim_avg_n_Wrap(obs_var_ann, 0)
  rcm_var_ann_avg = dim_avg_n_Wrap(rcm_var_ann, 0)
  gdd_var_ann_avg = dim_avg_n_Wrap(gdd_var_ann, 0)

  ; select rcm area
  rcm = rcm_var_ann_avg
  obs = obs_var_ann_avg

  ; regrid rcm. this is regridded to the obs grid i.e., compare rcm_regrid with obs
  newlat = fspan(-44.5, -10., dimsizes(obs&lat)) ; 691
  newlon = fspan(112., 156.25, dimsizes(obs&lon)) ; 886
  newlat@units = "degrees_north"
  newlon@units = "degrees_east"

  rcm_regrid = linint2_Wrap(rcm&lon, rcm&lat, rcm, False, newlon, newlat, 0)
  rcm_regrid!0   ="lat"
  rcm_regrid!1   = "lon"
  rcm_regrid&lat = newlat
  rcm_regrid&lon = newlon

  ; calculate bias (difference)
  bias = rcm_regrid
  bias = rcm_regrid - obs

  ; regrid annual rcm
  rcm_ann = rcm_var_ann
  obs_ann = obs_var_ann

  delete([/newlat, newlon/])
  newlat = fspan(-44.5, -10., dimsizes(obs_ann&lat)) ; 691
  newlon = fspan(112., 156.25, dimsizes(obs_ann&lon)) ; 886
  newlat@units = "degrees_north"
  newlon@units = "degrees_east"

  rcm_ann_regrid = linint2_Wrap(rcm_ann&lon, rcm_ann&lat, rcm_ann, False, newlon, newlat, 0)
  rcm_ann_regrid!1   ="lat"
  rcm_ann_regrid!2   = "lon"
  rcm_ann_regrid&lat = newlat
  rcm_ann_regrid&lon = newlon

  ; calculate rmse
  rmse = dim_rmsd_n_Wrap(rcm_ann_regrid, obs_ann, 0)

  fout = addfile(foutname, "c")
  fout->bias_awap_grid = bias
  fout->rmse_awap_grid = rmse

  print(systemfunc("date"))
  date = cd_calendar(rcm_varn&time, -2)
  year = date/10000
  years = ispan(min(year), max(year), 1)

  rcm_lat = rcm_varn&lat
  rcm_lon = rcm_varn&lon
  rcm_nlat = dimsizes(rcm_lat)
  rcm_nlon = dimsizes(rcm_lon)

  gdd_lat = gdd_varn&lat
  gdd_lon = gdd_varn&lon
  gdd_nlat = dimsizes(gdd_lat)
  gdd_nlon = dimsizes(gdd_lon)

  obs_lat = obs_varn&lat
  obs_lon = obs_varn&lon
  obs_nlat = dimsizes(obs_lat)
  obs_nlon = dimsizes(obs_lon)

; create new arrays for statistics
  rcm_avg = new((/window, rcm_nlat, rcm_nlon/), double) ; average
  rcm_avg!0 = "year"
  rcm_avg!1 = "lat"
  rcm_avg!2 = "lon"
  rcm_avg&year = years
  rcm_avg&lat = rcm_lat
  rcm_avg&lon = rcm_lon
  rcm_var = new((/window, rcm_nlat, rcm_nlon/), double) ; variance
  rcm_var!0 = "year"
  rcm_var!1 = "lat"
  rcm_var!2 = "lon"
  rcm_var&year = years
  rcm_var&lat = rcm_lat
  rcm_var&lon = rcm_lon
  rcm_99p = new((/window, rcm_nlat, rcm_nlon/), double) ; 99th percentile 
  rcm_99p!0 = "year"
  rcm_99p!1 = "lat"
  rcm_99p!2 = "lon"
  rcm_99p&year = years
  rcm_99p&lat = rcm_lat
  rcm_99p&lon = rcm_lon
  rcm_01p = new((/window, rcm_nlat, rcm_nlon/), double) ; 1th percentile
  rcm_01p!0 = "year"
  rcm_01p!1 = "lat"
  rcm_01p!2 = "lon"
  rcm_01p&year = years
  rcm_01p&lat = rcm_lat
  rcm_01p&lon = rcm_lon

  gdd_avg = new((/window, gdd_nlat, gdd_nlon/), double) ; average
  gdd_avg!0 = "year"
  gdd_avg!1 = "lat"
  gdd_avg!2 = "lon"
  gdd_avg&year = years
  gdd_avg&lat = gdd_lat
  gdd_avg&lon = gdd_lon
  gdd_var = new((/window, gdd_nlat, gdd_nlon/), double) ; variance
  gdd_var!0 = "year"
  gdd_var!1 = "lat"
  gdd_var!2 = "lon"
  gdd_var&year = years
  gdd_var&lat = gdd_lat
  gdd_var&lon = gdd_lon
  gdd_99p = new((/window, gdd_nlat, gdd_nlon/), double) ; 99th percentile 
  gdd_99p!0 = "year"
  gdd_99p!1 = "lat"
  gdd_99p!2 = "lon"
  gdd_99p&year = years
  gdd_99p&lat = gdd_lat
  gdd_99p&lon = gdd_lon
  gdd_01p = new((/window, gdd_nlat, gdd_nlon/), double) ; 1th percentile
  gdd_01p!0 = "year"
  gdd_01p!1 = "lat"
  gdd_01p!2 = "lon"
  gdd_01p&year = years
  gdd_01p&lat = gdd_lat
  gdd_01p&lon = gdd_lon

  obs_avg = new((/window, obs_nlat, obs_nlon/), double) ; average
  obs_avg!0 = "year"
  obs_avg!1 = "lat"
  obs_avg!2 = "lon"
  obs_avg&year = years
  obs_avg&lat = obs_lat
  obs_avg&lon = obs_lon
  obs_var = new((/window, obs_nlat, obs_nlon/), double) ; variance
  obs_var!0 = "year"
  obs_var!1 = "lat"
  obs_var!2 = "lon"
  obs_var&year = years
  obs_var&lat = obs_lat
  obs_var&lon = obs_lon
  obs_99p = new((/window, obs_nlat, obs_nlon/), double) ; 99th percentile 
  obs_99p!0 = "year"
  obs_99p!1 = "lat"
  obs_99p!2 = "lon"
  obs_99p&year = years
  obs_99p&lat = obs_lat
  obs_99p&lon = obs_lon
  obs_01p = new((/window, obs_nlat, obs_nlon/), double) ; 1th percentile
  obs_01p!0 = "year"
  obs_01p!1 = "lat"
  obs_01p!2 = "lon"
  obs_01p&year = years
  obs_01p&lat = obs_lat
  obs_01p&lon = obs_lon

;******************************
;******************************
  print(systemfunc("date"))
  print("Looping over years")
  do nyrc=0, window-1
    print(nyrc)
    print(systemfunc("date"))
    yrs = min(year)+nyrc
    yr_sel = ind(year.eq.yrs)

    rcm_temp = rcm_varn(yr_sel,:,:)
    gdd_temp = gdd_varn(yr_sel,:,:)
    obs_temp = obs_varn(yr_sel,:,:)

    ; calculate stats
    rcm_temp_avg = dim_avg_n_Wrap(rcm_temp, 0)
    rcm_temp_var = dim_variance_n_Wrap(rcm_temp, 0)
    rcm_temp_99p = percent_to_value_2d(rcm_temp, 99)
    rcm_temp_01p = percent_to_value_2d(rcm_temp, 1)

    gdd_temp_avg = dim_avg_n_Wrap(gdd_temp, 0)
    gdd_temp_var = dim_variance_n_Wrap(gdd_temp, 0)
    gdd_temp_99p = percent_to_value_2d(gdd_temp, 99)
    gdd_temp_01p = percent_to_value_2d(gdd_temp, 1)

    obs_temp_avg = dim_avg_n_Wrap(obs_temp, 0)
    obs_temp_var = dim_variance_n_Wrap(obs_temp, 0)
    obs_temp_99p = percent_to_value_2d(obs_temp, 99)
    obs_temp_01p = percent_to_value_2d(obs_temp, 1)

    ; put into array
    rcm_avg(nyrc,:,:) = (/rcm_temp_avg/)
    rcm_var(nyrc,:,:) = (/rcm_temp_var/)
    rcm_99p(nyrc,:,:) = (/rcm_temp_99p/)
    rcm_01p(nyrc,:,:) = (/rcm_temp_01p/)
    gdd_avg(nyrc,:,:) = (/gdd_temp_avg/)
    gdd_var(nyrc,:,:) = (/gdd_temp_var/)
    gdd_99p(nyrc,:,:) = (/gdd_temp_99p/)
    gdd_01p(nyrc,:,:) = (/gdd_temp_01p/)
    obs_avg(nyrc,:,:) = (/obs_temp_avg/)
    obs_var(nyrc,:,:) = (/obs_temp_var/)
    obs_99p(nyrc,:,:) = (/obs_temp_99p/)
    obs_01p(nyrc,:,:) = (/obs_temp_01p/)

    delete([/rcm_temp, gdd_temp, obs_temp, rcm_temp_avg, rcm_temp_var, rcm_temp_99p, rcm_temp_01p/])
    delete([/gdd_temp_avg, gdd_temp_var, gdd_temp_99p, gdd_temp_01p/])
    delete([/obs_temp_avg, obs_temp_var, obs_temp_99p, obs_temp_01p/])
    delete([/yr_sel, yrs/])
  end do

;******************************
;******************************
  print(systemfunc("date"))
  print("Finished looping over years, starting interpolation")
  ; interpolate to common grid
  newlat = fspan(-44.5, -10., 691)
  newlon = fspan(112., 156.25, 886)
  newlat@units = "degrees_north"
  newlon@units = "degrees_east"

  gdd_avg_regrid = linint2_Wrap(gdd_avg&lon, gdd_avg&lat, gdd_avg, False, newlon, newlat, 0)
  gdd_avg_regrid!1   = "lat"
  gdd_avg_regrid!2   = "lon"
  gdd_avg_regrid&lat = newlat
  gdd_avg_regrid&lon = newlon
  delete(gdd_avg)
  gdd_avg = gdd_avg_regrid
  delete(gdd_avg_regrid)

  gdd_var_regrid = linint2_Wrap(gdd_var&lon, gdd_var&lat, gdd_var, False, newlon, newlat, 0)
  gdd_var_regrid!1   = "lat"
  gdd_var_regrid!2   = "lon"
  gdd_var_regrid&lat = newlat
  gdd_var_regrid&lon = newlon
  delete(gdd_var)
  gdd_var = gdd_var_regrid
  delete(gdd_var_regrid)

  gdd_99p_regrid = linint2_Wrap(gdd_99p&lon, gdd_99p&lat, gdd_99p, False, newlon, newlat, 0)
  gdd_99p_regrid!1   = "lat"
  gdd_99p_regrid!2   = "lon"
  gdd_99p_regrid&lat = newlat
  gdd_99p_regrid&lon = newlon
  delete(gdd_99p)
  gdd_99p = gdd_99p_regrid
  delete(gdd_99p_regrid)

  gdd_01p_regrid = linint2_Wrap(gdd_01p&lon, gdd_01p&lat, gdd_01p, False, newlon, newlat, 0)
  gdd_01p_regrid!1   = "lat"
  gdd_01p_regrid!2   = "lon"
  gdd_01p_regrid&lat = newlat
  gdd_01p_regrid&lon = newlon
  delete(gdd_01p)
  gdd_01p = gdd_01p_regrid
  delete(gdd_01p_regrid)

  rcm_avg_regrid = linint2_Wrap(rcm_avg&lon, rcm_avg&lat, rcm_avg, False, newlon, newlat, 0)
  rcm_avg_regrid!1   = "lat"
  rcm_avg_regrid!2   = "lon"
  rcm_avg_regrid&lat = newlat
  rcm_avg_regrid&lon = newlon
  delete(rcm_avg)
  rcm_avg = rcm_avg_regrid
  delete(rcm_avg_regrid)

  rcm_var_regrid = linint2_Wrap(rcm_var&lon, rcm_var&lat, rcm_var, False, newlon, newlat, 0)
  rcm_var_regrid!1   = "lat"
  rcm_var_regrid!2   = "lon"
  rcm_var_regrid&lat = newlat
  rcm_var_regrid&lon = newlon
  delete(rcm_var)
  rcm_var = rcm_var_regrid
  delete(rcm_var_regrid)

  rcm_99p_regrid = linint2_Wrap(rcm_99p&lon, rcm_99p&lat, rcm_99p, False, newlon, newlat, 0)
  rcm_99p_regrid!1   = "lat"
  rcm_99p_regrid!2   = "lon"
  rcm_99p_regrid&lat = newlat
  rcm_99p_regrid&lon = newlon
  delete(rcm_99p)
  rcm_99p = rcm_99p_regrid
  delete(rcm_99p_regrid)

  rcm_01p_regrid = linint2_Wrap(rcm_01p&lon, rcm_01p&lat, rcm_01p, False, newlon, newlat, 0)
  rcm_01p_regrid!1   = "lat"
  rcm_01p_regrid!2   = "lon"
  rcm_01p_regrid&lat = newlat
  rcm_01p_regrid&lon = newlon
  delete(rcm_01p)
  rcm_01p = rcm_01p_regrid
  delete(rcm_01p_regrid)

  obs_avg_regrid = linint2_Wrap(obs_avg&lon, obs_avg&lat, obs_avg, False, newlon, newlat, 0)
  obs_avg_regrid!1   = "lat"
  obs_avg_regrid!2   = "lon"
  obs_avg_regrid&lat = newlat
  obs_avg_regrid&lon = newlon
  delete(obs_avg)
  obs_avg = obs_avg_regrid
  delete(obs_avg_regrid)

  obs_var_regrid = linint2_Wrap(obs_var&lon, obs_var&lat, obs_var, False, newlon, newlat, 0)
  obs_var_regrid!1   = "lat"
  obs_var_regrid!2   = "lon"
  obs_var_regrid&lat = newlat
  obs_var_regrid&lon = newlon
  delete(obs_var)
  obs_var = obs_var_regrid
  delete(obs_var_regrid)

  obs_99p_regrid = linint2_Wrap(obs_99p&lon, obs_99p&lat, obs_99p, False, newlon, newlat, 0)
  obs_99p_regrid!1   = "lat"
  obs_99p_regrid!2   = "lon"
  obs_99p_regrid&lat = newlat
  obs_99p_regrid&lon = newlon
  delete(obs_99p)
  obs_99p = obs_99p_regrid
  delete(obs_99p_regrid)

  obs_01p_regrid = linint2_Wrap(obs_01p&lon, obs_01p&lat, obs_01p, False, newlon, newlat, 0)
  obs_01p_regrid!1   = "lat"
  obs_01p_regrid!2   = "lon"
  obs_01p_regrid&lat = newlat
  obs_01p_regrid&lon = newlon
  delete(obs_01p)
  obs_01p = obs_01p_regrid
  delete(obs_01p_regrid)

;******************************
;******************************
  print(systemfunc("date"))
  print("Finished interpolation, masking data")
  gdd_avg_mask = gdd_avg
  gdd_avg_mask = mask(gdd_avg, conform(gdd_avg, lsmask, (/1, 2/)), 1)
  delete(gdd_avg)
  gdd_avg = gdd_avg_mask
  delete(gdd_avg_mask)

  gdd_var_mask = gdd_var
  gdd_var_mask = mask(gdd_var, conform(gdd_var, lsmask, (/1, 2/)), 1)
  delete(gdd_var)
  gdd_var = gdd_var_mask
  delete(gdd_var_mask)

  gdd_99p_mask = gdd_99p
  gdd_99p_mask = mask(gdd_99p, conform(gdd_99p, lsmask, (/1, 2/)), 1)
  delete(gdd_99p)
  gdd_99p = gdd_99p_mask
  delete(gdd_99p_mask)

  gdd_01p_mask = gdd_01p
  gdd_01p_mask = mask(gdd_01p, conform(gdd_01p, lsmask, (/1, 2/)), 1)
  delete(gdd_01p)
  gdd_01p = gdd_01p_mask
  delete(gdd_01p_mask)

  rcm_avg_mask = rcm_avg
  rcm_avg_mask = mask(rcm_avg, conform(rcm_avg, lsmask, (/1, 2/)), 1)
  delete(rcm_avg)
  rcm_avg = rcm_avg_mask
  delete(rcm_avg_mask)

  rcm_var_mask = rcm_var
  rcm_var_mask = mask(rcm_var, conform(rcm_var, lsmask, (/1, 2/)), 1)
  delete(rcm_var)
  rcm_var = rcm_var_mask
  delete(rcm_var_mask)

  rcm_99p_mask = rcm_99p
  rcm_99p_mask = mask(rcm_99p, conform(rcm_99p, lsmask, (/1, 2/)), 1)
  delete(rcm_99p)
  rcm_99p = rcm_99p_mask
  delete(rcm_99p_mask)

  rcm_01p_mask = rcm_01p
  rcm_01p_mask = mask(rcm_01p, conform(rcm_01p, lsmask, (/1, 2/)), 1)
  delete(rcm_01p)
  rcm_01p = rcm_01p_mask
  delete(rcm_01p_mask)

  obs_avg_mask = obs_avg
  obs_avg_mask = mask(obs_avg, conform(obs_avg, lsmask, (/1, 2/)), 1)
  delete(obs_avg)
  obs_avg = obs_avg_mask
  delete(obs_avg_mask)

  obs_var_mask = obs_var
  obs_var_mask = mask(obs_var, conform(obs_var, lsmask, (/1, 2/)), 1)
  delete(obs_var)
  obs_var = obs_var_mask
  delete(obs_var_mask)

  obs_99p_mask = obs_99p
  obs_99p_mask = mask(obs_99p, conform(obs_99p, lsmask, (/1, 2/)), 1)
  delete(obs_99p)
  obs_99p = obs_99p_mask
  delete(obs_99p_mask)

  obs_01p_mask = obs_01p
  obs_01p_mask = mask(obs_01p, conform(obs_01p, lsmask, (/1, 2/)), 1)
  delete(obs_01p)
  obs_01p = obs_01p_mask
  delete(obs_01p_mask)

;******************************
;******************************
  print(systemfunc("date"))
  print("Finished looping over years, calculating AV")

  ; calculate avg, variance, percentiles annual mean
  rcm_avg_clm = dim_avg_n_Wrap(rcm_avg, 0)
  rcm_var_clm = dim_avg_n_Wrap(rcm_var, 0)
  rcm_99p_clm = dim_avg_n_Wrap(rcm_99p, 0)
  rcm_01p_clm = dim_avg_n_Wrap(rcm_01p, 0)

  gdd_avg_clm = dim_avg_n_Wrap(gdd_avg, 0)
  gdd_var_clm = dim_avg_n_Wrap(gdd_var, 0)
  gdd_99p_clm = dim_avg_n_Wrap(gdd_99p, 0)
  gdd_01p_clm = dim_avg_n_Wrap(gdd_01p, 0)

  obs_avg_clm = dim_avg_n_Wrap(obs_avg, 0)
  obs_var_clm = dim_avg_n_Wrap(obs_var, 0)
  obs_99p_clm = dim_avg_n_Wrap(obs_99p, 0)
  obs_01p_clm = dim_avg_n_Wrap(obs_01p, 0)

;******************************
;******************************

  ; calculate Added Value (AV) for avg, variance, percentiles
  rcm_avg_rmse = rcm_avg_clm
  rcm_avg_rmse = sqrt((rcm_avg_clm - obs_avg_clm)^2)
  rcm_var_rmse = rcm_var_clm
  rcm_var_rmse = sqrt((rcm_var_clm - obs_var_clm)^2)
  rcm_99p_rmse = rcm_99p_clm
  rcm_99p_rmse = sqrt((rcm_99p_clm - obs_99p_clm)^2)
  rcm_01p_rmse = rcm_01p_clm
  rcm_01p_rmse = sqrt((rcm_01p_clm - obs_01p_clm)^2)

  gdd_avg_rmse = gdd_avg_clm
  gdd_avg_rmse = sqrt((gdd_avg_clm - obs_avg_clm)^2)
  gdd_var_rmse = gdd_var_clm
  gdd_var_rmse = sqrt((gdd_var_clm - obs_var_clm)^2)
  gdd_99p_rmse = gdd_99p_clm
  gdd_99p_rmse = sqrt((gdd_99p_clm - obs_99p_clm)^2)
  gdd_01p_rmse = gdd_01p_clm
  gdd_01p_rmse = sqrt((gdd_01p_clm - obs_01p_clm)^2)

  av_avg = gdd_avg_rmse
  av_avg = gdd_avg_rmse - rcm_avg_rmse
  av_var = gdd_var_rmse
  av_var = gdd_var_rmse - rcm_var_rmse
  av_99p = gdd_99p_rmse
  av_99p = gdd_99p_rmse - rcm_99p_rmse
  av_01p = gdd_01p_rmse
  av_01p = gdd_01p_rmse - rcm_01p_rmse

  ; calculate rmse using ncl function (uses annual time series data)
  rcm_avg_rmse_ncl = dim_rmsd_n_Wrap(obs_avg, rcm_avg, 0)
  rcm_var_rmse_ncl = dim_rmsd_n_Wrap(obs_var, rcm_var, 0)
  rcm_99p_rmse_ncl = dim_rmsd_n_Wrap(obs_99p, rcm_99p, 0)
  rcm_01p_rmse_ncl = dim_rmsd_n_Wrap(obs_01p, rcm_01p, 0)

  gdd_avg_rmse_ncl = dim_rmsd_n_Wrap(obs_avg, gdd_avg, 0)
  gdd_var_rmse_ncl = dim_rmsd_n_Wrap(obs_var, gdd_var, 0)
  gdd_99p_rmse_ncl = dim_rmsd_n_Wrap(obs_99p, gdd_99p, 0)
  gdd_01p_rmse_ncl = dim_rmsd_n_Wrap(obs_01p, gdd_01p, 0)

  av_avg_ncl = gdd_avg_rmse_ncl
  av_avg_ncl = gdd_avg_rmse_ncl - rcm_avg_rmse_ncl
  av_var_ncl = gdd_var_rmse_ncl
  av_var_ncl = gdd_var_rmse_ncl - rcm_var_rmse_ncl
  av_99p_ncl = gdd_99p_rmse_ncl
  av_99p_ncl = gdd_99p_rmse_ncl - rcm_99p_rmse_ncl
  av_01p_ncl = gdd_01p_rmse_ncl
  av_01p_ncl = gdd_01p_rmse_ncl - rcm_01p_rmse_ncl

  ; calculate obs variance
  obs_avg_variance = dim_variance_n_Wrap(obs_avg, 0)
  obs_var_variance = dim_variance_n_Wrap(obs_var, 0)
  obs_99p_variance = dim_variance_n_Wrap(obs_99p, 0)
  obs_01p_variance = dim_variance_n_Wrap(obs_01p, 0)

  obs_avg_variance_mask = obs_avg_variance
  obs_avg_variance_mask = where(obs_avg_variance_mask.eq.0, obs_avg_variance_mask@_FillValue, obs_avg_variance_mask)
  delete(obs_avg_variance)
  obs_avg_variance = obs_avg_variance_mask
  delete(obs_avg_variance_mask)
  obs_var_variance_mask = obs_var_variance
  obs_var_variance_mask = where(obs_var_variance_mask.eq.0, obs_var_variance_mask@_FillValue, obs_var_variance_mask)
  delete(obs_var_variance)
  obs_var_variance = obs_var_variance_mask
  delete(obs_var_variance_mask)
  obs_99p_variance_mask = obs_99p_variance
  obs_99p_variance_mask = where(obs_99p_variance_mask.eq.0, obs_99p_variance_mask@_FillValue, obs_99p_variance_mask)
  delete(obs_99p_variance)
  obs_99p_variance = obs_99p_variance_mask
  delete(obs_99p_variance_mask)
  obs_01p_variance_mask = obs_01p_variance
  obs_01p_variance_mask = where(obs_01p_variance_mask.eq.0, obs_01p_variance_mask@_FillValue, obs_01p_variance_mask)
  delete(obs_01p_variance)
  obs_01p_variance = obs_01p_variance_mask
  delete(obs_01p_variance_mask)

  print(systemfunc("date"))
  print("Outputting data")
  fout->av_avg = av_avg
  fout->gdd_avg_rmse = gdd_avg_rmse
  fout->rcm_avg_rmse = rcm_avg_rmse
  fout->av_avg_ncl = av_avg_ncl
  fout->gdd_avg_rmse_ncl = gdd_avg_rmse_ncl
  fout->rcm_avg_rmse_ncl = rcm_avg_rmse_ncl
  fout->obs_avg_variance = obs_avg_variance
  fout->obs_avg_clm = obs_avg_clm
  fout->gdd_avg_clm = gdd_avg_clm
  fout->rcm_avg_clm = rcm_avg_clm

  fout->av_var = av_var
  fout->gdd_var_rmse = gdd_var_rmse
  fout->rcm_var_rmse = rcm_var_rmse
  fout->av_var_ncl = av_var_ncl
  fout->gdd_var_rmse_ncl = gdd_var_rmse_ncl
  fout->rcm_var_rmse_ncl = rcm_var_rmse_ncl
  fout->obs_var_variance = obs_var_variance
  fout->obs_var_clm = obs_var_clm
  fout->gdd_var_clm = gdd_var_clm
  fout->rcm_var_clm = rcm_var_clm

  fout->av_99p = av_99p
  fout->gdd_99p_rmse = gdd_99p_rmse
  fout->rcm_99p_rmse = rcm_99p_rmse
  fout->av_99p_ncl = av_99p_ncl
  fout->gdd_99p_rmse_ncl = gdd_99p_rmse_ncl
  fout->rcm_99p_rmse_ncl = rcm_99p_rmse_ncl
  fout->obs_99p_variance = obs_99p_variance
  fout->obs_99p_clm = obs_99p_clm
  fout->gdd_99p_clm = gdd_99p_clm
  fout->rcm_99p_clm = rcm_99p_clm

  fout->av_01p = av_01p
  fout->gdd_01p_rmse = gdd_01p_rmse
  fout->rcm_01p_rmse = rcm_01p_rmse
  fout->av_01p_ncl = av_01p_ncl
  fout->gdd_01p_rmse_ncl = gdd_01p_rmse_ncl
  fout->rcm_01p_rmse_ncl = rcm_01p_rmse_ncl
  fout->obs_01p_variance = obs_01p_variance
  fout->obs_01p_clm = obs_01p_clm
  fout->gdd_01p_clm = gdd_01p_clm
  fout->rcm_01p_clm = rcm_01p_clm

  print(systemfunc("date"))
end