; calculate Added Value (AV)

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/g/data/xv83/bxn599/CaRSA/rav_ncl/percentiles.ncl"

begin
  fout_name_ANN = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_ANN_added_value.nc"

  fout_name_DJF = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_DJF_added_value.nc"
  fout_name_MAM = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_MAM_added_value.nc"
  fout_name_JJA = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_JJA_added_value.nc"
  fout_name_SON = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_SON_added_value.nc"

  fout_name_JAN = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_JAN_added_value.nc"
  fout_name_FEB = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_FEB_added_value.nc"
  fout_name_MAR = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_MAR_added_value.nc"
  fout_name_APR = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_APR_added_value.nc"
  fout_name_MAY = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_MAY_added_value.nc"
  fout_name_JUN = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_JUN_added_value.nc"
  fout_name_JUL = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_JUL_added_value.nc"
  fout_name_AUG = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_AUG_added_value.nc"
  fout_name_SEP = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_SEP_added_value.nc"
  fout_name_OCT = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_OCT_added_value.nc"
  fout_name_NOV = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_NOV_added_value.nc"
  fout_name_DEC = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_"+var+"_DEC_added_value.nc"

  yyyymmdd_start = (yyyy_start*10000)+101
  yyyymmdd_end = (yyyy_end*10000)+1231

  yyyy = ispan(yyyy_start, yyyy_end, 1)
  yyyymm = yyyymm_time(yyyy_start, yyyy_end, "integer")
  window = yyyy_end - yyyy_start + 1
  
  ls_obs_hist = ls_obs+yyyy+".nc"
  ls_rcm_hist = ls_rcm+yyyymm+".nc"
  ls_gdd_hist = ls_gdd+yyyy+".nc"

  ; land sea mask file
  f2 = addfile("/scratch/e53/mxt599/esci/sftrf_AWAP0.05_NRMv3.nc", "r")
  lsmask = f2->AUS

;******************************
;******************************
  print(systemfunc("date"))
; **********************
; GDD GDD GDD GDD GDD
; **********************
  ifile_gdd_hist = addfiles(ls_gdd_hist, "r")

  gdd_time = ifile_gdd_hist[:]->time
  gdd_date = cd_calendar(gdd_time, -2)
  gdd_start = ind(gdd_date.eq.yyyymmdd_start)
  gdd_end = ind(gdd_date.eq.yyyymmdd_end)

  gdd_hist = ifile_gdd_hist[:]->$gdd_var_name$(gdd_start:gdd_end,{latS-1:latN+1},{lonL-1:lonR+1})
  delete(ifile_gdd_hist)
  if gdd_hist@units .eq. "kg/m2/s" .or. gdd_hist@units .eq."kg m-2 s-1" then
    gdd_hist = gdd_hist*86400
    gdd_hist@units = "mm/day"
  else if gdd_hist@units .eq. "m" then
    gdd_hist = gdd_hist*1000
    gdd_hist@units = "mm/day"
  else if gdd_hist@units .eq. "K" .or. gdd_hist@units .eq. "degK" then
    gdd_hist = gdd_hist - 273.15
    gdd_hist@units = "degC"
  else if gdd_hist@units .eq. "degrees_Celsius" .or. gdd_hist@units .eq. "Celsius" .or. gdd_hist@units .eq. "C" then
    gdd_hist@units = "degC"
  end if
  end if
  end if
  end if

  gdd_hist!1 = "lat"
  gdd_hist!2 = "lon"
  delete([/gdd_time, gdd_date, gdd_start, gdd_end/])

; **********************
; RCM RCM RCM RCM RCM
; **********************
  ifile_rcm_hist = addfiles(ls_rcm_hist, "r")

  rcm_time = ifile_rcm_hist[:]->time
  rcm_date = cd_calendar(rcm_time, -2)
  rcm_start = ind(rcm_date.eq.yyyymmdd_start)
  rcm_end = ind(rcm_date.eq.yyyymmdd_end)

  rcm_hist_ = ifile_rcm_hist[:]->$rcm_var_name$(:,{latS:latN},{lonL:lonR}) ; use all time steps because raw RCM output is from 19800102 to 20200101, NOT 19800101 to 20191213
  delete(ifile_rcm_hist)
  if rcm_hist_@units .eq. "kg/m2/s" .or. rcm_hist_@units .eq."kg m-2 s-1" then
    rcm_hist_ = rcm_hist_*86400
    rcm_hist_@units = "mm/day"
  else if rcm_hist_@units .eq. "K" .or. rcm_hist_@units .eq. "degK" then
    rcm_hist_ = rcm_hist_ - 273.15
    rcm_hist_@units = "degC"
  else if rcm_hist_@units .eq. "degrees_Celsius" .or. rcm_hist_@units .eq. "Celsius" .or. rcm_hist_@units .eq. "C" then
    rcm_hist_@units = "degC"
  end if
  end if
  end if
  rcm_hist_!1 = "lat"
  rcm_hist_!2 = "lon"
  delete([/rcm_time, rcm_date, rcm_start, rcm_end/])

  time =  rcm_hist_&time
  rcm_yyyymmdd = yyyymmdd_time(yyyy_start, yyyy_end, "integer")
  rcm_yyyy = rcm_yyyymmdd/10000
  rcm_mmdd = rcm_yyyymmdd-rcm_yyyy*10000
  rcm_mm = rcm_mmdd/100
  rcm_dd = rcm_mmdd-rcm_mm*100
  rcm_hh = rcm_dd
  rcm_mn = rcm_dd
  rcm_sc = rcm_dd
  rcm_hh = 0
  rcm_mn = 0
  rcm_sc = 0

  rcm_time_units = "hours since 1900-01-01 00:00:00"
  new_time = cd_inv_calendar(rcm_yyyy, rcm_mm, rcm_dd, rcm_hh, rcm_mn, rcm_sc, rcm_time_units, 0)
  delete(rcm_hist_&time)
  rcm_hist_&time = new_time
  rcm_time = rcm_hist_&time
  rcm_date = cd_calendar(rcm_time, -2)
  rcm_start = ind(rcm_date.eq.yyyymmdd_start)
  rcm_end = ind(rcm_date.eq.yyyymmdd_end)
  rcm_hist = rcm_hist_(rcm_start:rcm_end,:,:)

; **********************
; OBS OBS OBS OBS OBS
; **********************
  ifile_obs = addfiles(ls_obs_hist, "r")

  obs_time = ifile_obs[:]->time
  obs_date = cd_calendar(obs_time, -2)
  obs_start = ind(obs_date.eq.yyyymmdd_start)
  obs_end = ind(obs_date.eq.yyyymmdd_end)

  obs = ifile_obs[:]->$obs_var_name$(obs_start:obs_end,{latS:latN},{lonL:lonR})
  delete(ifile_obs)
  if obs@units .eq. "kg/m2/s" .or. obs@units .eq."kg m-2 s-1" then
    obs = obs * 86400
    obs@units = "mm/day"
  else if obs@units .eq. "mm" then
    obs@units = "mm/day"
  else if obs@units .eq. "K" .or. obs@units .eq. "degK" then
    obs = obs - 273.15
    obs@units = "degC"
  else if obs@units .eq. "degrees_Celsius" .or. obs@units .eq. "Celsius" .or. obs@units .eq. "C" then
    obs@units = "degC"
  end if
  end if
  end if
  end if
  obs!1 = "lat"
  obs!2 = "lon"

;******************************
;******************************
  print(systemfunc("date"))
  print("Finished reading files, starting interpolation")
  ; interpolate to common grid
  lat = lsmask&lat
  lon = lsmask&lon
  nlat = dimsizes(lat)
  nlon = dimsizes(lon)

  newlat = fspan(-44.5, -10., nlat)
  newlon = fspan(112., 156.25, nlon)
  newlat@units = "degrees_north"
  newlon@units = "degrees_east"

  gdd_hist_regrid = linint2_Wrap(gdd_hist&lon, gdd_hist&lat, gdd_hist, False, newlon, newlat, 0)
  gdd_hist_regrid!1   = "lat"
  gdd_hist_regrid!2   = "lon"
  gdd_hist_regrid&lat = newlat
  gdd_hist_regrid&lon = newlon
  delete(gdd_hist)
  gdd_hist = gdd_hist_regrid
  delete(gdd_hist_regrid)

  rcm_hist_regrid = linint2_Wrap(rcm_hist&lon, rcm_hist&lat, rcm_hist, False, newlon, newlat, 0)
  rcm_hist_regrid!1   = "lat"
  rcm_hist_regrid!2   = "lon"
  rcm_hist_regrid&lat = newlat
  rcm_hist_regrid&lon = newlon
  delete(rcm_hist)
  rcm_hist = rcm_hist_regrid
  delete(rcm_hist_regrid)

;******************************
;******************************
  print(systemfunc("date"))
  print("Finished interpolation, masking data")
  rcm_hist_mask = rcm_hist
  rcm_hist_mask = mask(rcm_hist, conform(rcm_hist, lsmask, (/1,2/)), 1)
  delete(rcm_hist)
  rcm_hist = rcm_hist_mask
  delete(rcm_hist_mask)

  gdd_hist_mask = gdd_hist
  gdd_hist_mask = mask(gdd_hist, conform(gdd_hist, lsmask, (/1,2/)), 1)
  delete(gdd_hist)
  gdd_hist = gdd_hist_mask
  delete(gdd_hist_mask)

  obs_mask = obs
  obs_mask = mask(obs, conform(obs, lsmask, (/1,2/)), 1)
  delete(obs)
  obs = obs_mask
  delete(obs_mask)
  delete(lsmask)

;  obs_lat = obs&lat
;  delete(obs&lat)
;  obs&lat = tofloat(obs_lat)
;  delete(obs_lat)
;  obs_lon = obs&lon
;  delete(obs&lon)
;  obs&lon = tofloat(obs_lon)
;  delete(obs_lon)

;******************************
;******************************
  print(systemfunc("date"))
  print("Finished masking, starting annual statistics calculation")

; calculate statistics (e.g., mean, percentiles)
; annual stats
  gdd_hist_ANN_avg = dim_avg_n_Wrap(gdd_hist, 0)
  gdd_hist_ANN_var = dim_variance_n_Wrap(gdd_hist, 0)
  gdd_hist_ANN_99p = percent_to_value_2d(gdd_hist, 99)
  gdd_hist_ANN_01p = percent_to_value_2d(gdd_hist, 1)

  rcm_hist_ANN_avg = dim_avg_n_Wrap(rcm_hist, 0)
  rcm_hist_ANN_var = dim_variance_n_Wrap(rcm_hist, 0)
  rcm_hist_ANN_99p = percent_to_value_2d(rcm_hist, 99)
  rcm_hist_ANN_01p = percent_to_value_2d(rcm_hist, 1)

  obs_ANN_avg = dim_avg_n_Wrap(obs, 0)
  obs_ANN_99p = percent_to_value_2d(obs, 99)
  obs_ANN_01p = percent_to_value_2d(obs, 1)
  obs_ANN_var = dim_variance_n_Wrap(obs, 0)

  hist_date_sel = cd_calendar(rcm_hist&time, 0)
  hist_date_mth = hist_date_sel(:,1)
  delete(hist_date_sel)

; monthly stats
  hist_date_JAN = ind(hist_date_mth.eq.1)
  rcm_hist_JAN = rcm_hist(hist_date_JAN,:,:)
  rcm_hist_JAN_avg = dim_avg_n_Wrap(rcm_hist_JAN, 0)
  rcm_hist_JAN_var = dim_variance_n_Wrap(rcm_hist_JAN, 0)
  rcm_hist_JAN_99p = percent_to_value_2d(rcm_hist_JAN, 99)
  rcm_hist_JAN_01p = percent_to_value_2d(rcm_hist_JAN, 1)
  delete(rcm_hist_JAN)

  gdd_hist_JAN = gdd_hist(hist_date_JAN,:,:)
  gdd_hist_JAN_avg = dim_avg_n_Wrap(gdd_hist_JAN, 0)
  gdd_hist_JAN_var = dim_variance_n_Wrap(gdd_hist_JAN, 0)
  gdd_hist_JAN_01p = percent_to_value_2d(gdd_hist_JAN, 1)
  gdd_hist_JAN_99p = percent_to_value_2d(gdd_hist_JAN, 99)
  delete(gdd_hist_JAN)

  obs_JAN = obs(hist_date_JAN,:,:)
  obs_JAN_avg = dim_avg_n_Wrap(obs_JAN, 0)
  obs_JAN_var = dim_variance_n_Wrap(obs_JAN, 0)
  obs_JAN_01p = percent_to_value_2d(obs_JAN, 1)
  obs_JAN_99p = percent_to_value_2d(obs_JAN, 99)
  delete(obs_JAN)
  delete(hist_date_JAN)

  hist_date_FEB = ind(hist_date_mth.eq.2)
  rcm_hist_FEB = rcm_hist(hist_date_FEB,:,:)
  rcm_hist_FEB_avg = dim_avg_n_Wrap(rcm_hist_FEB, 0)
  rcm_hist_FEB_var = dim_variance_n_Wrap(rcm_hist_FEB, 0)
  rcm_hist_FEB_99p = percent_to_value_2d(rcm_hist_FEB, 99)
  rcm_hist_FEB_01p = percent_to_value_2d(rcm_hist_FEB, 1)
  delete(rcm_hist_FEB)

  gdd_hist_FEB = gdd_hist(hist_date_FEB,:,:)
  gdd_hist_FEB_avg = dim_avg_n_Wrap(gdd_hist_FEB, 0)
  gdd_hist_FEB_var = dim_variance_n_Wrap(gdd_hist_FEB, 0)
  gdd_hist_FEB_01p = percent_to_value_2d(gdd_hist_FEB, 1)
  gdd_hist_FEB_99p = percent_to_value_2d(gdd_hist_FEB, 99)
  delete(gdd_hist_FEB)

  obs_FEB = obs(hist_date_FEB,:,:)
  obs_FEB_avg = dim_avg_n_Wrap(obs_FEB, 0)
  obs_FEB_var = dim_variance_n_Wrap(obs_FEB, 0)
  obs_FEB_01p = percent_to_value_2d(obs_FEB, 1)
  obs_FEB_99p = percent_to_value_2d(obs_FEB, 99)
  delete(obs_FEB)
  delete(hist_date_FEB)

  hist_date_MAR = ind(hist_date_mth.eq.3)
  rcm_hist_MAR = rcm_hist(hist_date_MAR,:,:)
  rcm_hist_MAR_avg = dim_avg_n_Wrap(rcm_hist_MAR, 0)
  rcm_hist_MAR_var = dim_variance_n_Wrap(rcm_hist_MAR, 0)
  rcm_hist_MAR_99p = percent_to_value_2d(rcm_hist_MAR, 99)
  rcm_hist_MAR_01p = percent_to_value_2d(rcm_hist_MAR, 1)
  delete(rcm_hist_MAR)

  gdd_hist_MAR = gdd_hist(hist_date_MAR,:,:)
  gdd_hist_MAR_avg = dim_avg_n_Wrap(gdd_hist_MAR, 0)
  gdd_hist_MAR_var = dim_variance_n_Wrap(gdd_hist_MAR, 0)
  gdd_hist_MAR_01p = percent_to_value_2d(gdd_hist_MAR, 1)
  gdd_hist_MAR_99p = percent_to_value_2d(gdd_hist_MAR, 99)
  delete(gdd_hist_MAR)

  obs_MAR = obs(hist_date_MAR,:,:)
  obs_MAR_avg = dim_avg_n_Wrap(obs_MAR, 0)
  obs_MAR_var = dim_variance_n_Wrap(obs_MAR, 0)
  obs_MAR_01p = percent_to_value_2d(obs_MAR, 1)
  obs_MAR_99p = percent_to_value_2d(obs_MAR, 99)
  delete(obs_MAR)
  delete(hist_date_MAR)

  hist_date_APR = ind(hist_date_mth.eq.4)
  rcm_hist_APR = rcm_hist(hist_date_APR,:,:)
  rcm_hist_APR_avg = dim_avg_n_Wrap(rcm_hist_APR, 0)
  rcm_hist_APR_var = dim_variance_n_Wrap(rcm_hist_APR, 0)
  rcm_hist_APR_99p = percent_to_value_2d(rcm_hist_APR, 99)
  rcm_hist_APR_01p = percent_to_value_2d(rcm_hist_APR, 1)
  delete(rcm_hist_APR)

  gdd_hist_APR = gdd_hist(hist_date_APR,:,:)
  gdd_hist_APR_avg = dim_avg_n_Wrap(gdd_hist_APR, 0)
  gdd_hist_APR_var = dim_variance_n_Wrap(gdd_hist_APR, 0)
  gdd_hist_APR_01p = percent_to_value_2d(gdd_hist_APR, 1)
  gdd_hist_APR_99p = percent_to_value_2d(gdd_hist_APR, 99)
  delete(gdd_hist_APR)

  obs_APR = obs(hist_date_APR,:,:)
  obs_APR_avg = dim_avg_n_Wrap(obs_APR, 0)
  obs_APR_var = dim_variance_n_Wrap(obs_APR, 0)
  obs_APR_01p = percent_to_value_2d(obs_APR, 1)
  obs_APR_99p = percent_to_value_2d(obs_APR, 99)
  delete(obs_APR)
  delete(hist_date_APR)

  hist_date_MAY = ind(hist_date_mth.eq.5)
  rcm_hist_MAY = rcm_hist(hist_date_MAY,:,:)
  rcm_hist_MAY_avg = dim_avg_n_Wrap(rcm_hist_MAY, 0)
  rcm_hist_MAY_var = dim_variance_n_Wrap(rcm_hist_MAY, 0)
  rcm_hist_MAY_99p = percent_to_value_2d(rcm_hist_MAY, 99)
  rcm_hist_MAY_01p = percent_to_value_2d(rcm_hist_MAY, 1)
  delete(rcm_hist_MAY)

  gdd_hist_MAY = gdd_hist(hist_date_MAY,:,:)
  gdd_hist_MAY_avg = dim_avg_n_Wrap(gdd_hist_MAY, 0)
  gdd_hist_MAY_var = dim_variance_n_Wrap(gdd_hist_MAY, 0)
  gdd_hist_MAY_01p = percent_to_value_2d(gdd_hist_MAY, 1)
  gdd_hist_MAY_99p = percent_to_value_2d(gdd_hist_MAY, 99)
  delete(gdd_hist_MAY)

  obs_MAY = obs(hist_date_MAY,:,:)
  obs_MAY_avg = dim_avg_n_Wrap(obs_MAY, 0)
  obs_MAY_var = dim_variance_n_Wrap(obs_MAY, 0)
  obs_MAY_01p = percent_to_value_2d(obs_MAY, 1)
  obs_MAY_99p = percent_to_value_2d(obs_MAY, 99)
  delete(obs_MAY)
  delete(hist_date_MAY)

  hist_date_JUN = ind(hist_date_mth.eq.6)
  rcm_hist_JUN = rcm_hist(hist_date_JUN,:,:)
  rcm_hist_JUN_avg = dim_avg_n_Wrap(rcm_hist_JUN, 0)
  rcm_hist_JUN_var = dim_variance_n_Wrap(rcm_hist_JUN, 0)
  rcm_hist_JUN_99p = percent_to_value_2d(rcm_hist_JUN, 99)
  rcm_hist_JUN_01p = percent_to_value_2d(rcm_hist_JUN, 1)
  delete(rcm_hist_JUN)

  gdd_hist_JUN = gdd_hist(hist_date_JUN,:,:)
  gdd_hist_JUN_avg = dim_avg_n_Wrap(gdd_hist_JUN, 0)
  gdd_hist_JUN_var = dim_variance_n_Wrap(gdd_hist_JUN, 0)
  gdd_hist_JUN_01p = percent_to_value_2d(gdd_hist_JUN, 1)
  gdd_hist_JUN_99p = percent_to_value_2d(gdd_hist_JUN, 99)
  delete(gdd_hist_JUN)

  obs_JUN = obs(hist_date_JUN,:,:)
  obs_JUN_avg = dim_avg_n_Wrap(obs_JUN, 0)
  obs_JUN_var = dim_variance_n_Wrap(obs_JUN, 0)
  obs_JUN_01p = percent_to_value_2d(obs_JUN, 1)
  obs_JUN_99p = percent_to_value_2d(obs_JUN, 99)
  delete(obs_JUN)
  delete(hist_date_JUN)

  hist_date_JUL = ind(hist_date_mth.eq.7)
  rcm_hist_JUL = rcm_hist(hist_date_JUL,:,:)
  rcm_hist_JUL_avg = dim_avg_n_Wrap(rcm_hist_JUL, 0)
  rcm_hist_JUL_var = dim_variance_n_Wrap(rcm_hist_JUL, 0)
  rcm_hist_JUL_99p = percent_to_value_2d(rcm_hist_JUL, 99)
  rcm_hist_JUL_01p = percent_to_value_2d(rcm_hist_JUL, 1)
  delete(rcm_hist_JUL)

  gdd_hist_JUL = gdd_hist(hist_date_JUL,:,:)
  gdd_hist_JUL_avg = dim_avg_n_Wrap(gdd_hist_JUL, 0)
  gdd_hist_JUL_var = dim_variance_n_Wrap(gdd_hist_JUL, 0)
  gdd_hist_JUL_01p = percent_to_value_2d(gdd_hist_JUL, 1)
  gdd_hist_JUL_99p = percent_to_value_2d(gdd_hist_JUL, 99)
  delete(gdd_hist_JUL)

  obs_JUL = obs(hist_date_JUL,:,:)
  obs_JUL_avg = dim_avg_n_Wrap(obs_JUL, 0)
  obs_JUL_var = dim_variance_n_Wrap(obs_JUL, 0)
  obs_JUL_01p = percent_to_value_2d(obs_JUL, 1)
  obs_JUL_99p = percent_to_value_2d(obs_JUL, 99)
  delete(obs_JUL)
  delete(hist_date_JUL)

  hist_date_AUG = ind(hist_date_mth.eq.8)
  rcm_hist_AUG = rcm_hist(hist_date_AUG,:,:)
  rcm_hist_AUG_avg = dim_avg_n_Wrap(rcm_hist_AUG, 0)
  rcm_hist_AUG_var = dim_variance_n_Wrap(rcm_hist_AUG, 0)
  rcm_hist_AUG_99p = percent_to_value_2d(rcm_hist_AUG, 99)
  rcm_hist_AUG_01p = percent_to_value_2d(rcm_hist_AUG, 1)
  delete(rcm_hist_AUG)

  gdd_hist_AUG = gdd_hist(hist_date_AUG,:,:)
  gdd_hist_AUG_avg = dim_avg_n_Wrap(gdd_hist_AUG, 0)
  gdd_hist_AUG_var = dim_variance_n_Wrap(gdd_hist_AUG, 0)
  gdd_hist_AUG_01p = percent_to_value_2d(gdd_hist_AUG, 1)
  gdd_hist_AUG_99p = percent_to_value_2d(gdd_hist_AUG, 99)
  delete(gdd_hist_AUG)

  obs_AUG = obs(hist_date_AUG,:,:)
  obs_AUG_avg = dim_avg_n_Wrap(obs_AUG, 0)
  obs_AUG_var = dim_variance_n_Wrap(obs_AUG, 0)
  obs_AUG_01p = percent_to_value_2d(obs_AUG, 1)
  obs_AUG_99p = percent_to_value_2d(obs_AUG, 99)
  delete(obs_AUG)
  delete(hist_date_AUG)

  hist_date_SEP = ind(hist_date_mth.eq.9)
  rcm_hist_SEP = rcm_hist(hist_date_SEP,:,:)
  rcm_hist_SEP_avg = dim_avg_n_Wrap(rcm_hist_SEP, 0)
  rcm_hist_SEP_var = dim_variance_n_Wrap(rcm_hist_SEP, 0)
  rcm_hist_SEP_99p = percent_to_value_2d(rcm_hist_SEP, 99)
  rcm_hist_SEP_01p = percent_to_value_2d(rcm_hist_SEP, 1)
  delete(rcm_hist_SEP)

  gdd_hist_SEP = gdd_hist(hist_date_SEP,:,:)
  gdd_hist_SEP_avg = dim_avg_n_Wrap(gdd_hist_SEP, 0)
  gdd_hist_SEP_var = dim_variance_n_Wrap(gdd_hist_SEP, 0)
  gdd_hist_SEP_01p = percent_to_value_2d(gdd_hist_SEP, 1)
  gdd_hist_SEP_99p = percent_to_value_2d(gdd_hist_SEP, 99)
  delete(gdd_hist_SEP)

  obs_SEP = obs(hist_date_SEP,:,:)
  obs_SEP_avg = dim_avg_n_Wrap(obs_SEP, 0)
  obs_SEP_var = dim_variance_n_Wrap(obs_SEP, 0)
  obs_SEP_01p = percent_to_value_2d(obs_SEP, 1)
  obs_SEP_99p = percent_to_value_2d(obs_SEP, 99)
  delete(obs_SEP)
  delete(hist_date_SEP)

  hist_date_OCT = ind(hist_date_mth.eq.10)
  rcm_hist_OCT = rcm_hist(hist_date_OCT,:,:)
  rcm_hist_OCT_avg = dim_avg_n_Wrap(rcm_hist_OCT, 0)
  rcm_hist_OCT_var = dim_variance_n_Wrap(rcm_hist_OCT, 0)
  rcm_hist_OCT_99p = percent_to_value_2d(rcm_hist_OCT, 99)
  rcm_hist_OCT_01p = percent_to_value_2d(rcm_hist_OCT, 1)
  delete(rcm_hist_OCT)

  gdd_hist_OCT = gdd_hist(hist_date_OCT,:,:)
  gdd_hist_OCT_avg = dim_avg_n_Wrap(gdd_hist_OCT, 0)
  gdd_hist_OCT_var = dim_variance_n_Wrap(gdd_hist_OCT, 0)
  gdd_hist_OCT_01p = percent_to_value_2d(gdd_hist_OCT, 1)
  gdd_hist_OCT_99p = percent_to_value_2d(gdd_hist_OCT, 99)
  delete(gdd_hist_OCT)

  obs_OCT = obs(hist_date_OCT,:,:)
  obs_OCT_avg = dim_avg_n_Wrap(obs_OCT, 0)
  obs_OCT_var = dim_variance_n_Wrap(obs_OCT, 0)
  obs_OCT_01p = percent_to_value_2d(obs_OCT, 1)
  obs_OCT_99p = percent_to_value_2d(obs_OCT, 99)
  delete(obs_OCT)
  delete(hist_date_OCT)

  hist_date_NOV = ind(hist_date_mth.eq.11)
  rcm_hist_NOV = rcm_hist(hist_date_NOV,:,:)
  rcm_hist_NOV_avg = dim_avg_n_Wrap(rcm_hist_NOV, 0)
  rcm_hist_NOV_var = dim_variance_n_Wrap(rcm_hist_NOV, 0)
  rcm_hist_NOV_99p = percent_to_value_2d(rcm_hist_NOV, 99)
  rcm_hist_NOV_01p = percent_to_value_2d(rcm_hist_NOV, 1)
  delete(rcm_hist_NOV)

  gdd_hist_NOV = gdd_hist(hist_date_NOV,:,:)
  gdd_hist_NOV_avg = dim_avg_n_Wrap(gdd_hist_NOV, 0)
  gdd_hist_NOV_var = dim_variance_n_Wrap(gdd_hist_NOV, 0)
  gdd_hist_NOV_01p = percent_to_value_2d(gdd_hist_NOV, 1)
  gdd_hist_NOV_99p = percent_to_value_2d(gdd_hist_NOV, 99)
  delete(gdd_hist_NOV)

  obs_NOV = obs(hist_date_NOV,:,:)
  obs_NOV_avg = dim_avg_n_Wrap(obs_NOV, 0)
  obs_NOV_var = dim_variance_n_Wrap(obs_NOV, 0)
  obs_NOV_01p = percent_to_value_2d(obs_NOV, 1)
  obs_NOV_99p = percent_to_value_2d(obs_NOV, 99)
  delete(obs_NOV)
  delete(hist_date_NOV)

  hist_date_DEC = ind(hist_date_mth.eq.12)
  rcm_hist_DEC = rcm_hist(hist_date_DEC,:,:)
  rcm_hist_DEC_avg = dim_avg_n_Wrap(rcm_hist_DEC, 0)
  rcm_hist_DEC_var = dim_variance_n_Wrap(rcm_hist_DEC, 0)
  rcm_hist_DEC_99p = percent_to_value_2d(rcm_hist_DEC, 99)
  rcm_hist_DEC_01p = percent_to_value_2d(rcm_hist_DEC, 1)
  delete(rcm_hist_DEC)

  gdd_hist_DEC = gdd_hist(hist_date_DEC,:,:)
  gdd_hist_DEC_avg = dim_avg_n_Wrap(gdd_hist_DEC, 0)
  gdd_hist_DEC_var = dim_variance_n_Wrap(gdd_hist_DEC, 0)
  gdd_hist_DEC_01p = percent_to_value_2d(gdd_hist_DEC, 1)
  gdd_hist_DEC_99p = percent_to_value_2d(gdd_hist_DEC, 99)
  delete(gdd_hist_DEC)

  obs_DEC = obs(hist_date_DEC,:,:)
  obs_DEC_avg = dim_avg_n_Wrap(obs_DEC, 0)
  obs_DEC_var = dim_variance_n_Wrap(obs_DEC, 0)
  obs_DEC_01p = percent_to_value_2d(obs_DEC, 1)
  obs_DEC_99p = percent_to_value_2d(obs_DEC, 99)
  delete(obs_DEC)
  delete(hist_date_DEC)
  delete(hist_date_mth)

  hist_date = cd_calendar(rcm_hist&time, -2)
  hist_year = hist_date/10000
  hist_years = ispan(min(hist_year), max(hist_year), 1)

; create new arrays for inter-annual statistics (obs only)
  obs_ANN_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_ANN_avg_yearly!0 = "year"
  obs_ANN_avg_yearly!1 = "lat"
  obs_ANN_avg_yearly!2 = "lon"
  obs_ANN_avg_yearly&year = hist_years
  obs_ANN_avg_yearly&lat = lat
  obs_ANN_avg_yearly&lon = lon
  obs_ANN_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_ANN_var_yearly!0 = "year"
  obs_ANN_var_yearly!1 = "lat"
  obs_ANN_var_yearly!2 = "lon"
  obs_ANN_var_yearly&year = hist_years
  obs_ANN_var_yearly&lat = lat
  obs_ANN_var_yearly&lon = lon
  obs_ANN_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_ANN_99p_yearly!0 = "year"
  obs_ANN_99p_yearly!1 = "lat"
  obs_ANN_99p_yearly!2 = "lon"
  obs_ANN_99p_yearly&year = hist_years
  obs_ANN_99p_yearly&lat = lat
  obs_ANN_99p_yearly&lon = lon
  obs_ANN_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_ANN_01p_yearly!0 = "year"
  obs_ANN_01p_yearly!1 = "lat"
  obs_ANN_01p_yearly!2 = "lon"
  obs_ANN_01p_yearly&year = hist_years
  obs_ANN_01p_yearly&lat = lat
  obs_ANN_01p_yearly&lon = lon

  obs_JAN_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_JAN_avg_yearly!0 = "year"
  obs_JAN_avg_yearly!1 = "lat"
  obs_JAN_avg_yearly!2 = "lon"
  obs_JAN_avg_yearly&year = hist_years
  obs_JAN_avg_yearly&lat = lat
  obs_JAN_avg_yearly&lon = lon
  obs_JAN_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_JAN_var_yearly!0 = "year"
  obs_JAN_var_yearly!1 = "lat"
  obs_JAN_var_yearly!2 = "lon"
  obs_JAN_var_yearly&year = hist_years
  obs_JAN_var_yearly&lat = lat
  obs_JAN_var_yearly&lon = lon
  obs_JAN_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_JAN_99p_yearly!0 = "year"
  obs_JAN_99p_yearly!1 = "lat"
  obs_JAN_99p_yearly!2 = "lon"
  obs_JAN_99p_yearly&year = hist_years
  obs_JAN_99p_yearly&lat = lat
  obs_JAN_99p_yearly&lon = lon
  obs_JAN_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_JAN_01p_yearly!0 = "year"
  obs_JAN_01p_yearly!1 = "lat"
  obs_JAN_01p_yearly!2 = "lon"
  obs_JAN_01p_yearly&year = hist_years
  obs_JAN_01p_yearly&lat = lat
  obs_JAN_01p_yearly&lon = lon

  obs_FEB_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_FEB_avg_yearly!0 = "year"
  obs_FEB_avg_yearly!1 = "lat"
  obs_FEB_avg_yearly!2 = "lon"
  obs_FEB_avg_yearly&year = hist_years
  obs_FEB_avg_yearly&lat = lat
  obs_FEB_avg_yearly&lon = lon
  obs_FEB_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_FEB_var_yearly!0 = "year"
  obs_FEB_var_yearly!1 = "lat"
  obs_FEB_var_yearly!2 = "lon"
  obs_FEB_var_yearly&year = hist_years
  obs_FEB_var_yearly&lat = lat
  obs_FEB_var_yearly&lon = lon
  obs_FEB_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_FEB_99p_yearly!0 = "year"
  obs_FEB_99p_yearly!1 = "lat"
  obs_FEB_99p_yearly!2 = "lon"
  obs_FEB_99p_yearly&year = hist_years
  obs_FEB_99p_yearly&lat = lat
  obs_FEB_99p_yearly&lon = lon
  obs_FEB_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_FEB_01p_yearly!0 = "year"
  obs_FEB_01p_yearly!1 = "lat"
  obs_FEB_01p_yearly!2 = "lon"
  obs_FEB_01p_yearly&year = hist_years
  obs_FEB_01p_yearly&lat = lat
  obs_FEB_01p_yearly&lon = lon

  obs_MAR_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_MAR_avg_yearly!0 = "year"
  obs_MAR_avg_yearly!1 = "lat"
  obs_MAR_avg_yearly!2 = "lon"
  obs_MAR_avg_yearly&year = hist_years
  obs_MAR_avg_yearly&lat = lat
  obs_MAR_avg_yearly&lon = lon
  obs_MAR_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_MAR_var_yearly!0 = "year"
  obs_MAR_var_yearly!1 = "lat"
  obs_MAR_var_yearly!2 = "lon"
  obs_MAR_var_yearly&year = hist_years
  obs_MAR_var_yearly&lat = lat
  obs_MAR_var_yearly&lon = lon
  obs_MAR_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_MAR_99p_yearly!0 = "year"
  obs_MAR_99p_yearly!1 = "lat"
  obs_MAR_99p_yearly!2 = "lon"
  obs_MAR_99p_yearly&year = hist_years
  obs_MAR_99p_yearly&lat = lat
  obs_MAR_99p_yearly&lon = lon
  obs_MAR_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_MAR_01p_yearly!0 = "year"
  obs_MAR_01p_yearly!1 = "lat"
  obs_MAR_01p_yearly!2 = "lon"
  obs_MAR_01p_yearly&year = hist_years
  obs_MAR_01p_yearly&lat = lat
  obs_MAR_01p_yearly&lon = lon

  obs_APR_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_APR_avg_yearly!0 = "year"
  obs_APR_avg_yearly!1 = "lat"
  obs_APR_avg_yearly!2 = "lon"
  obs_APR_avg_yearly&year = hist_years
  obs_APR_avg_yearly&lat = lat
  obs_APR_avg_yearly&lon = lon
  obs_APR_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_APR_var_yearly!0 = "year"
  obs_APR_var_yearly!1 = "lat"
  obs_APR_var_yearly!2 = "lon"
  obs_APR_var_yearly&year = hist_years
  obs_APR_var_yearly&lat = lat
  obs_APR_var_yearly&lon = lon
  obs_APR_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_APR_99p_yearly!0 = "year"
  obs_APR_99p_yearly!1 = "lat"
  obs_APR_99p_yearly!2 = "lon"
  obs_APR_99p_yearly&year = hist_years
  obs_APR_99p_yearly&lat = lat
  obs_APR_99p_yearly&lon = lon
  obs_APR_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_APR_01p_yearly!0 = "year"
  obs_APR_01p_yearly!1 = "lat"
  obs_APR_01p_yearly!2 = "lon"
  obs_APR_01p_yearly&year = hist_years
  obs_APR_01p_yearly&lat = lat
  obs_APR_01p_yearly&lon = lon

  obs_MAY_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_MAY_avg_yearly!0 = "year"
  obs_MAY_avg_yearly!1 = "lat"
  obs_MAY_avg_yearly!2 = "lon"
  obs_MAY_avg_yearly&year = hist_years
  obs_MAY_avg_yearly&lat = lat
  obs_MAY_avg_yearly&lon = lon
  obs_MAY_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_MAY_var_yearly!0 = "year"
  obs_MAY_var_yearly!1 = "lat"
  obs_MAY_var_yearly!2 = "lon"
  obs_MAY_var_yearly&year = hist_years
  obs_MAY_var_yearly&lat = lat
  obs_MAY_var_yearly&lon = lon
  obs_MAY_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_MAY_99p_yearly!0 = "year"
  obs_MAY_99p_yearly!1 = "lat"
  obs_MAY_99p_yearly!2 = "lon"
  obs_MAY_99p_yearly&year = hist_years
  obs_MAY_99p_yearly&lat = lat
  obs_MAY_99p_yearly&lon = lon
  obs_MAY_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_MAY_01p_yearly!0 = "year"
  obs_MAY_01p_yearly!1 = "lat"
  obs_MAY_01p_yearly!2 = "lon"
  obs_MAY_01p_yearly&year = hist_years
  obs_MAY_01p_yearly&lat = lat
  obs_MAY_01p_yearly&lon = lon

  obs_JUN_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_JUN_avg_yearly!0 = "year"
  obs_JUN_avg_yearly!1 = "lat"
  obs_JUN_avg_yearly!2 = "lon"
  obs_JUN_avg_yearly&year = hist_years
  obs_JUN_avg_yearly&lat = lat
  obs_JUN_avg_yearly&lon = lon
  obs_JUN_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_JUN_var_yearly!0 = "year"
  obs_JUN_var_yearly!1 = "lat"
  obs_JUN_var_yearly!2 = "lon"
  obs_JUN_var_yearly&year = hist_years
  obs_JUN_var_yearly&lat = lat
  obs_JUN_var_yearly&lon = lon
  obs_JUN_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_JUN_99p_yearly!0 = "year"
  obs_JUN_99p_yearly!1 = "lat"
  obs_JUN_99p_yearly!2 = "lon"
  obs_JUN_99p_yearly&year = hist_years
  obs_JUN_99p_yearly&lat = lat
  obs_JUN_99p_yearly&lon = lon
  obs_JUN_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_JUN_01p_yearly!0 = "year"
  obs_JUN_01p_yearly!1 = "lat"
  obs_JUN_01p_yearly!2 = "lon"
  obs_JUN_01p_yearly&year = hist_years
  obs_JUN_01p_yearly&lat = lat
  obs_JUN_01p_yearly&lon = lon

  obs_JUL_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_JUL_avg_yearly!0 = "year"
  obs_JUL_avg_yearly!1 = "lat"
  obs_JUL_avg_yearly!2 = "lon"
  obs_JUL_avg_yearly&year = hist_years
  obs_JUL_avg_yearly&lat = lat
  obs_JUL_avg_yearly&lon = lon
  obs_JUL_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_JUL_var_yearly!0 = "year"
  obs_JUL_var_yearly!1 = "lat"
  obs_JUL_var_yearly!2 = "lon"
  obs_JUL_var_yearly&year = hist_years
  obs_JUL_var_yearly&lat = lat
  obs_JUL_var_yearly&lon = lon
  obs_JUL_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_JUL_99p_yearly!0 = "year"
  obs_JUL_99p_yearly!1 = "lat"
  obs_JUL_99p_yearly!2 = "lon"
  obs_JUL_99p_yearly&year = hist_years
  obs_JUL_99p_yearly&lat = lat
  obs_JUL_99p_yearly&lon = lon
  obs_JUL_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_JUL_01p_yearly!0 = "year"
  obs_JUL_01p_yearly!1 = "lat"
  obs_JUL_01p_yearly!2 = "lon"
  obs_JUL_01p_yearly&year = hist_years
  obs_JUL_01p_yearly&lat = lat
  obs_JUL_01p_yearly&lon = lon

  obs_AUG_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_AUG_avg_yearly!0 = "year"
  obs_AUG_avg_yearly!1 = "lat"
  obs_AUG_avg_yearly!2 = "lon"
  obs_AUG_avg_yearly&year = hist_years
  obs_AUG_avg_yearly&lat = lat
  obs_AUG_avg_yearly&lon = lon
  obs_AUG_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_AUG_var_yearly!0 = "year"
  obs_AUG_var_yearly!1 = "lat"
  obs_AUG_var_yearly!2 = "lon"
  obs_AUG_var_yearly&year = hist_years
  obs_AUG_var_yearly&lat = lat
  obs_AUG_var_yearly&lon = lon
  obs_AUG_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_AUG_99p_yearly!0 = "year"
  obs_AUG_99p_yearly!1 = "lat"
  obs_AUG_99p_yearly!2 = "lon"
  obs_AUG_99p_yearly&year = hist_years
  obs_AUG_99p_yearly&lat = lat
  obs_AUG_99p_yearly&lon = lon
  obs_AUG_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_AUG_01p_yearly!0 = "year"
  obs_AUG_01p_yearly!1 = "lat"
  obs_AUG_01p_yearly!2 = "lon"
  obs_AUG_01p_yearly&year = hist_years
  obs_AUG_01p_yearly&lat = lat
  obs_AUG_01p_yearly&lon = lon

  obs_SEP_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_SEP_avg_yearly!0 = "year"
  obs_SEP_avg_yearly!1 = "lat"
  obs_SEP_avg_yearly!2 = "lon"
  obs_SEP_avg_yearly&year = hist_years
  obs_SEP_avg_yearly&lat = lat
  obs_SEP_avg_yearly&lon = lon
  obs_SEP_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_SEP_var_yearly!0 = "year"
  obs_SEP_var_yearly!1 = "lat"
  obs_SEP_var_yearly!2 = "lon"
  obs_SEP_var_yearly&year = hist_years
  obs_SEP_var_yearly&lat = lat
  obs_SEP_var_yearly&lon = lon
  obs_SEP_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_SEP_99p_yearly!0 = "year"
  obs_SEP_99p_yearly!1 = "lat"
  obs_SEP_99p_yearly!2 = "lon"
  obs_SEP_99p_yearly&year = hist_years
  obs_SEP_99p_yearly&lat = lat
  obs_SEP_99p_yearly&lon = lon
  obs_SEP_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_SEP_01p_yearly!0 = "year"
  obs_SEP_01p_yearly!1 = "lat"
  obs_SEP_01p_yearly!2 = "lon"
  obs_SEP_01p_yearly&year = hist_years
  obs_SEP_01p_yearly&lat = lat
  obs_SEP_01p_yearly&lon = lon

  obs_OCT_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_OCT_avg_yearly!0 = "year"
  obs_OCT_avg_yearly!1 = "lat"
  obs_OCT_avg_yearly!2 = "lon"
  obs_OCT_avg_yearly&year = hist_years
  obs_OCT_avg_yearly&lat = lat
  obs_OCT_avg_yearly&lon = lon
  obs_OCT_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_OCT_var_yearly!0 = "year"
  obs_OCT_var_yearly!1 = "lat"
  obs_OCT_var_yearly!2 = "lon"
  obs_OCT_var_yearly&year = hist_years
  obs_OCT_var_yearly&lat = lat
  obs_OCT_var_yearly&lon = lon
  obs_OCT_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_OCT_99p_yearly!0 = "year"
  obs_OCT_99p_yearly!1 = "lat"
  obs_OCT_99p_yearly!2 = "lon"
  obs_OCT_99p_yearly&year = hist_years
  obs_OCT_99p_yearly&lat = lat
  obs_OCT_99p_yearly&lon = lon
  obs_OCT_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_OCT_01p_yearly!0 = "year"
  obs_OCT_01p_yearly!1 = "lat"
  obs_OCT_01p_yearly!2 = "lon"
  obs_OCT_01p_yearly&year = hist_years
  obs_OCT_01p_yearly&lat = lat
  obs_OCT_01p_yearly&lon = lon

  obs_NOV_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_NOV_avg_yearly!0 = "year"
  obs_NOV_avg_yearly!1 = "lat"
  obs_NOV_avg_yearly!2 = "lon"
  obs_NOV_avg_yearly&year = hist_years
  obs_NOV_avg_yearly&lat = lat
  obs_NOV_avg_yearly&lon = lon
  obs_NOV_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_NOV_var_yearly!0 = "year"
  obs_NOV_var_yearly!1 = "lat"
  obs_NOV_var_yearly!2 = "lon"
  obs_NOV_var_yearly&year = hist_years
  obs_NOV_var_yearly&lat = lat
  obs_NOV_var_yearly&lon = lon
  obs_NOV_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_NOV_99p_yearly!0 = "year"
  obs_NOV_99p_yearly!1 = "lat"
  obs_NOV_99p_yearly!2 = "lon"
  obs_NOV_99p_yearly&year = hist_years
  obs_NOV_99p_yearly&lat = lat
  obs_NOV_99p_yearly&lon = lon
  obs_NOV_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_NOV_01p_yearly!0 = "year"
  obs_NOV_01p_yearly!1 = "lat"
  obs_NOV_01p_yearly!2 = "lon"
  obs_NOV_01p_yearly&year = hist_years
  obs_NOV_01p_yearly&lat = lat
  obs_NOV_01p_yearly&lon = lon

  obs_DEC_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_DEC_avg_yearly!0 = "year"
  obs_DEC_avg_yearly!1 = "lat"
  obs_DEC_avg_yearly!2 = "lon"
  obs_DEC_avg_yearly&year = hist_years
  obs_DEC_avg_yearly&lat = lat
  obs_DEC_avg_yearly&lon = lon
  obs_DEC_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_DEC_var_yearly!0 = "year"
  obs_DEC_var_yearly!1 = "lat"
  obs_DEC_var_yearly!2 = "lon"
  obs_DEC_var_yearly&year = hist_years
  obs_DEC_var_yearly&lat = lat
  obs_DEC_var_yearly&lon = lon
  obs_DEC_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_DEC_99p_yearly!0 = "year"
  obs_DEC_99p_yearly!1 = "lat"
  obs_DEC_99p_yearly!2 = "lon"
  obs_DEC_99p_yearly&year = hist_years
  obs_DEC_99p_yearly&lat = lat
  obs_DEC_99p_yearly&lon = lon
  obs_DEC_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_DEC_01p_yearly!0 = "year"
  obs_DEC_01p_yearly!1 = "lat"
  obs_DEC_01p_yearly!2 = "lon"
  obs_DEC_01p_yearly&year = hist_years
  obs_DEC_01p_yearly&lat = lat
  obs_DEC_01p_yearly&lon = lon

;******************************
; Loop over years using non-shifted data
;******************************
  print(systemfunc("date"))
  print("Looping over years (non-shifted)")
  do nyrc=0, window-1
    print(nyrc)
    print(systemfunc("date"))
    hist_yrs = min(hist_year)+nyrc
    hist_yr_sel = ind(hist_year.eq.hist_yrs)
    obs_temp = obs(hist_yr_sel,:,:)
    printVarSummary(obs_temp&lat)
    printVarSummary(obs_temp&lon)
    exit

    hist_date_sel = cd_calendar(obs_temp&time, 0)
    hist_date_mth = hist_date_sel(:,1)
    delete(hist_date_sel)
    
    hist_date_JAN = ind(hist_date_mth.eq.1)
    hist_date_FEB = ind(hist_date_mth.eq.2)
    hist_date_MAR = ind(hist_date_mth.eq.3)
    hist_date_APR = ind(hist_date_mth.eq.4)
    hist_date_MAY = ind(hist_date_mth.eq.5)
    hist_date_JUN = ind(hist_date_mth.eq.6)
    hist_date_JUL = ind(hist_date_mth.eq.7)
    hist_date_AUG = ind(hist_date_mth.eq.8)
    hist_date_SEP = ind(hist_date_mth.eq.9)
    hist_date_OCT = ind(hist_date_mth.eq.10)
    hist_date_NOV = ind(hist_date_mth.eq.11)
    hist_date_DEC = ind(hist_date_mth.eq.12)
    delete(hist_date_mth)

    ; calculate stats
    obs_temp_avg = dim_avg_n_Wrap(obs_temp, 0)
    obs_temp_var = dim_variance_n_Wrap(obs_temp, 0)
    obs_temp_99p = percent_to_value_2d(obs_temp, 99)
    obs_temp_01p = percent_to_value_2d(obs_temp, 1)

    ; put into array
    obs_ANN_avg_yearly(nyrc,:,:) = (/obs_temp_avg/)
    obs_ANN_var_yearly(nyrc,:,:) = (/obs_temp_var/)
    obs_ANN_99p_yearly(nyrc,:,:) = (/obs_temp_99p/)
    obs_ANN_01p_yearly(nyrc,:,:) = (/obs_temp_01p/)

    obs_temp_JAN = obs_temp(hist_date_JAN,:,:)
    obs_temp_FEB = obs_temp(hist_date_FEB,:,:)
    obs_temp_MAR = obs_temp(hist_date_MAR,:,:)
    obs_temp_APR = obs_temp(hist_date_APR,:,:)
    obs_temp_MAY = obs_temp(hist_date_MAY,:,:)
    obs_temp_JUN = obs_temp(hist_date_JUN,:,:)
    obs_temp_JUL = obs_temp(hist_date_JUL,:,:)
    obs_temp_AUG = obs_temp(hist_date_AUG,:,:)
    obs_temp_SEP = obs_temp(hist_date_SEP,:,:)
    obs_temp_OCT = obs_temp(hist_date_OCT,:,:)
    obs_temp_NOV = obs_temp(hist_date_NOV,:,:)
    obs_temp_DEC = obs_temp(hist_date_DEC,:,:)

    delete([/hist_date_JAN, hist_date_FEB, hist_date_MAR, hist_date_APR, hist_date_MAY, hist_date_JUN, hist_date_JUL, hist_date_AUG, hist_date_SEP, hist_date_OCT, hist_date_NOV, hist_date_DEC/])

    obs_temp_JAN_avg = dim_avg_n_Wrap(obs_temp_JAN, 0)
    obs_temp_JAN_var = dim_variance_n_Wrap(obs_temp_JAN, 0)
    obs_temp_JAN_99p = percent_to_value_2d(obs_temp_JAN, 99)
    obs_temp_JAN_01p = percent_to_value_2d(obs_temp_JAN, 1)
    obs_temp_FEB_avg = dim_avg_n_Wrap(obs_temp_FEB, 0)
    obs_temp_FEB_var = dim_variance_n_Wrap(obs_temp_FEB, 0)
    obs_temp_FEB_99p = percent_to_value_2d(obs_temp_FEB, 99)
    obs_temp_FEB_01p = percent_to_value_2d(obs_temp_FEB, 1)
    obs_temp_MAR_avg = dim_avg_n_Wrap(obs_temp_MAR, 0)
    obs_temp_MAR_var = dim_variance_n_Wrap(obs_temp_MAR, 0)
    obs_temp_MAR_99p = percent_to_value_2d(obs_temp_MAR, 99)
    obs_temp_MAR_01p = percent_to_value_2d(obs_temp_MAR, 1)
    obs_temp_APR_avg = dim_avg_n_Wrap(obs_temp_APR, 0)
    obs_temp_APR_var = dim_variance_n_Wrap(obs_temp_APR, 0)
    obs_temp_APR_99p = percent_to_value_2d(obs_temp_APR, 99)
    obs_temp_APR_01p = percent_to_value_2d(obs_temp_APR, 1)
    obs_temp_MAY_avg = dim_avg_n_Wrap(obs_temp_MAY, 0)
    obs_temp_MAY_var = dim_variance_n_Wrap(obs_temp_MAY, 0)
    obs_temp_MAY_99p = percent_to_value_2d(obs_temp_MAY, 99)
    obs_temp_MAY_01p = percent_to_value_2d(obs_temp_MAY, 1)
    obs_temp_JUN_avg = dim_avg_n_Wrap(obs_temp_JUN, 0)
    obs_temp_JUN_var = dim_variance_n_Wrap(obs_temp_JUN, 0)
    obs_temp_JUN_99p = percent_to_value_2d(obs_temp_JUN, 99)
    obs_temp_JUN_01p = percent_to_value_2d(obs_temp_JUN, 1)
    obs_temp_JUL_avg = dim_avg_n_Wrap(obs_temp_JUL, 0)
    obs_temp_JUL_var = dim_variance_n_Wrap(obs_temp_JUL, 0)
    obs_temp_JUL_99p = percent_to_value_2d(obs_temp_JUL, 99)
    obs_temp_JUL_01p = percent_to_value_2d(obs_temp_JUL, 1)
    obs_temp_AUG_avg = dim_avg_n_Wrap(obs_temp_AUG, 0)
    obs_temp_AUG_var = dim_variance_n_Wrap(obs_temp_AUG, 0)
    obs_temp_AUG_99p = percent_to_value_2d(obs_temp_AUG, 99)
    obs_temp_AUG_01p = percent_to_value_2d(obs_temp_AUG, 1)
    obs_temp_SEP_avg = dim_avg_n_Wrap(obs_temp_SEP, 0)
    obs_temp_SEP_var = dim_variance_n_Wrap(obs_temp_SEP, 0)
    obs_temp_SEP_99p = percent_to_value_2d(obs_temp_SEP, 99)
    obs_temp_SEP_01p = percent_to_value_2d(obs_temp_SEP, 1)
    obs_temp_OCT_avg = dim_avg_n_Wrap(obs_temp_OCT, 0)
    obs_temp_OCT_var = dim_variance_n_Wrap(obs_temp_OCT, 0)
    obs_temp_OCT_99p = percent_to_value_2d(obs_temp_OCT, 99)
    obs_temp_OCT_01p = percent_to_value_2d(obs_temp_OCT, 1)
    obs_temp_NOV_avg = dim_avg_n_Wrap(obs_temp_NOV, 0)
    obs_temp_NOV_var = dim_variance_n_Wrap(obs_temp_NOV, 0)
    obs_temp_NOV_99p = percent_to_value_2d(obs_temp_NOV, 99)
    obs_temp_NOV_01p = percent_to_value_2d(obs_temp_NOV, 1)
    obs_temp_DEC_avg = dim_avg_n_Wrap(obs_temp_DEC, 0)
    obs_temp_DEC_var = dim_variance_n_Wrap(obs_temp_DEC, 0)
    obs_temp_DEC_99p = percent_to_value_2d(obs_temp_DEC, 99)
    obs_temp_DEC_01p = percent_to_value_2d(obs_temp_DEC, 1)

    obs_JAN_avg_yearly(nyrc,:,:) = (/obs_temp_JAN_avg/)
    obs_JAN_var_yearly(nyrc,:,:) = (/obs_temp_JAN_var/)
    obs_JAN_99p_yearly(nyrc,:,:) = (/obs_temp_JAN_99p/)
    obs_JAN_01p_yearly(nyrc,:,:) = (/obs_temp_JAN_01p/)
    obs_FEB_avg_yearly(nyrc,:,:) = (/obs_temp_FEB_avg/)
    obs_FEB_var_yearly(nyrc,:,:) = (/obs_temp_FEB_var/)
    obs_FEB_99p_yearly(nyrc,:,:) = (/obs_temp_FEB_99p/)
    obs_FEB_01p_yearly(nyrc,:,:) = (/obs_temp_FEB_01p/)
    obs_MAR_avg_yearly(nyrc,:,:) = (/obs_temp_MAR_avg/)
    obs_MAR_var_yearly(nyrc,:,:) = (/obs_temp_MAR_var/)
    obs_MAR_99p_yearly(nyrc,:,:) = (/obs_temp_MAR_99p/)
    obs_MAR_01p_yearly(nyrc,:,:) = (/obs_temp_MAR_01p/)
    obs_APR_avg_yearly(nyrc,:,:) = (/obs_temp_APR_avg/)
    obs_APR_var_yearly(nyrc,:,:) = (/obs_temp_APR_var/)
    obs_APR_99p_yearly(nyrc,:,:) = (/obs_temp_APR_99p/)
    obs_APR_01p_yearly(nyrc,:,:) = (/obs_temp_APR_01p/)
    obs_MAY_avg_yearly(nyrc,:,:) = (/obs_temp_MAY_avg/)
    obs_MAY_var_yearly(nyrc,:,:) = (/obs_temp_MAY_var/)
    obs_MAY_99p_yearly(nyrc,:,:) = (/obs_temp_MAY_99p/)
    obs_MAY_01p_yearly(nyrc,:,:) = (/obs_temp_MAY_01p/)
    obs_JUN_avg_yearly(nyrc,:,:) = (/obs_temp_JUN_avg/)
    obs_JUN_var_yearly(nyrc,:,:) = (/obs_temp_JUN_var/)
    obs_JUN_99p_yearly(nyrc,:,:) = (/obs_temp_JUN_99p/)
    obs_JUN_01p_yearly(nyrc,:,:) = (/obs_temp_JUN_01p/)
    obs_JUL_avg_yearly(nyrc,:,:) = (/obs_temp_JUL_avg/)
    obs_JUL_var_yearly(nyrc,:,:) = (/obs_temp_JUL_var/)
    obs_JUL_99p_yearly(nyrc,:,:) = (/obs_temp_JUL_99p/)
    obs_JUL_01p_yearly(nyrc,:,:) = (/obs_temp_JUL_01p/)
    obs_AUG_avg_yearly(nyrc,:,:) = (/obs_temp_AUG_avg/)
    obs_AUG_var_yearly(nyrc,:,:) = (/obs_temp_AUG_var/)
    obs_AUG_99p_yearly(nyrc,:,:) = (/obs_temp_AUG_99p/)
    obs_AUG_01p_yearly(nyrc,:,:) = (/obs_temp_AUG_01p/)
    obs_SEP_avg_yearly(nyrc,:,:) = (/obs_temp_SEP_avg/)
    obs_SEP_var_yearly(nyrc,:,:) = (/obs_temp_SEP_var/)
    obs_SEP_99p_yearly(nyrc,:,:) = (/obs_temp_SEP_99p/)
    obs_SEP_01p_yearly(nyrc,:,:) = (/obs_temp_SEP_01p/)
    obs_OCT_avg_yearly(nyrc,:,:) = (/obs_temp_OCT_avg/)
    obs_OCT_var_yearly(nyrc,:,:) = (/obs_temp_OCT_var/)
    obs_OCT_99p_yearly(nyrc,:,:) = (/obs_temp_OCT_99p/)
    obs_OCT_01p_yearly(nyrc,:,:) = (/obs_temp_OCT_01p/)
    obs_NOV_avg_yearly(nyrc,:,:) = (/obs_temp_NOV_avg/)
    obs_NOV_var_yearly(nyrc,:,:) = (/obs_temp_NOV_var/)
    obs_NOV_99p_yearly(nyrc,:,:) = (/obs_temp_NOV_99p/)
    obs_NOV_01p_yearly(nyrc,:,:) = (/obs_temp_NOV_01p/)
    obs_DEC_avg_yearly(nyrc,:,:) = (/obs_temp_DEC_avg/)
    obs_DEC_var_yearly(nyrc,:,:) = (/obs_temp_DEC_var/)
    obs_DEC_99p_yearly(nyrc,:,:) = (/obs_temp_DEC_99p/)
    obs_DEC_01p_yearly(nyrc,:,:) = (/obs_temp_DEC_01p/)

    delete([/obs_temp_avg, obs_temp_var, obs_temp_99p, obs_temp_01p, obs_temp/])
    delete([/hist_yr_sel, hist_yrs/])
    delete([/obs_temp_JAN, obs_temp_JAN_avg, obs_temp_JAN_var, obs_temp_JAN_99p, obs_temp_JAN_01p/])
    delete([/obs_temp_FEB, obs_temp_FEB_avg, obs_temp_FEB_var, obs_temp_FEB_99p, obs_temp_FEB_01p/])
    delete([/obs_temp_MAR, obs_temp_MAR_avg, obs_temp_MAR_var, obs_temp_MAR_99p, obs_temp_MAR_01p/])
    delete([/obs_temp_APR, obs_temp_APR_avg, obs_temp_APR_var, obs_temp_APR_99p, obs_temp_APR_01p/])
    delete([/obs_temp_MAY, obs_temp_MAY_avg, obs_temp_MAY_var, obs_temp_MAY_99p, obs_temp_MAY_01p/])
    delete([/obs_temp_JUN, obs_temp_JUN_avg, obs_temp_JUN_var, obs_temp_JUN_99p, obs_temp_JUN_01p/])
    delete([/obs_temp_JUL, obs_temp_JUL_avg, obs_temp_JUL_var, obs_temp_JUL_99p, obs_temp_JUL_01p/])
    delete([/obs_temp_AUG, obs_temp_AUG_avg, obs_temp_AUG_var, obs_temp_AUG_99p, obs_temp_AUG_01p/])
    delete([/obs_temp_SEP, obs_temp_SEP_avg, obs_temp_SEP_var, obs_temp_SEP_99p, obs_temp_SEP_01p/])
    delete([/obs_temp_OCT, obs_temp_OCT_avg, obs_temp_OCT_var, obs_temp_OCT_99p, obs_temp_OCT_01p/])
    delete([/obs_temp_NOV, obs_temp_NOV_avg, obs_temp_NOV_var, obs_temp_NOV_99p, obs_temp_NOV_01p/])
    delete([/obs_temp_DEC, obs_temp_DEC_avg, obs_temp_DEC_var, obs_temp_DEC_99p, obs_temp_DEC_01p/])
  end do

;******************************
;******************************
  print(systemfunc("date"))

; ANNUAL
  print(systemfunc("date"))
  print("ANN")
  rcm_ANN_avg_rmse = rcm_hist_ANN_avg
  rcm_ANN_avg_rmse = sqrt((rcm_hist_ANN_avg - obs_ANN_avg)^2)
  rcm_ANN_var_rmse = rcm_hist_ANN_var
  rcm_ANN_var_rmse = sqrt((rcm_hist_ANN_var - obs_ANN_var)^2)
  rcm_ANN_99p_rmse = rcm_hist_ANN_99p
  rcm_ANN_99p_rmse = sqrt((rcm_hist_ANN_99p - obs_ANN_99p)^2)
  rcm_ANN_01p_rmse = rcm_hist_ANN_01p
  rcm_ANN_01p_rmse = sqrt((rcm_hist_ANN_01p - obs_ANN_01p)^2)

  gdd_ANN_avg_rmse = gdd_hist_ANN_avg
  gdd_ANN_avg_rmse = sqrt((gdd_hist_ANN_avg - obs_ANN_avg)^2)
  gdd_ANN_var_rmse = gdd_hist_ANN_var
  gdd_ANN_var_rmse = sqrt((gdd_hist_ANN_var - obs_ANN_var)^2)
  gdd_ANN_99p_rmse = gdd_hist_ANN_99p
  gdd_ANN_99p_rmse = sqrt((gdd_hist_ANN_99p - obs_ANN_99p)^2)
  gdd_ANN_01p_rmse = gdd_hist_ANN_01p
  gdd_ANN_01p_rmse = sqrt((gdd_hist_ANN_01p - obs_ANN_01p)^2)

  av_ANN_avg = gdd_ANN_avg_rmse
  av_ANN_avg = gdd_ANN_avg_rmse - rcm_ANN_avg_rmse
  av_ANN_var = gdd_ANN_var_rmse
  av_ANN_var = gdd_ANN_var_rmse - rcm_ANN_var_rmse
  av_ANN_99p = gdd_ANN_99p_rmse
  av_ANN_99p = gdd_ANN_99p_rmse - rcm_ANN_99p_rmse
  av_ANN_01p = gdd_ANN_01p_rmse
  av_ANN_01p = gdd_ANN_01p_rmse - rcm_ANN_01p_rmse

  obs_ANN_avg_variance = dim_variance_n_Wrap(obs_ANN_avg_yearly, 0)
  obs_ANN_var_variance = dim_variance_n_Wrap(obs_ANN_var_yearly, 0)
  obs_ANN_99p_variance = dim_variance_n_Wrap(obs_ANN_99p_yearly, 0)
  obs_ANN_01p_variance = dim_variance_n_Wrap(obs_ANN_01p_yearly, 0)

  delete([/obs_ANN_avg_yearly, obs_ANN_var_yearly, obs_ANN_99p_yearly, obs_ANN_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_ANN_avg_variance_mask = obs_ANN_avg_variance
  obs_ANN_avg_variance_mask = where(obs_ANN_avg_variance_mask.eq.0, obs_ANN_avg_variance_mask@_FillValue, obs_ANN_avg_variance_mask)
  delete(obs_ANN_avg_variance)
  obs_ANN_avg_variance = obs_ANN_avg_variance_mask
  delete(obs_ANN_avg_variance_mask)
  obs_ANN_var_variance_mask = obs_ANN_var_variance
  obs_ANN_var_variance_mask = where(obs_ANN_var_variance_mask.eq.0, obs_ANN_var_variance_mask@_FillValue, obs_ANN_var_variance_mask)
  delete(obs_ANN_var_variance)
  obs_ANN_var_variance = obs_ANN_var_variance_mask
  delete(obs_ANN_var_variance_mask)
  obs_ANN_99p_variance_mask = obs_ANN_99p_variance
  obs_ANN_99p_variance_mask = where(obs_ANN_99p_variance_mask.eq.0, obs_ANN_99p_variance_mask@_FillValue, obs_ANN_99p_variance_mask)
  delete(obs_ANN_99p_variance)
  obs_ANN_99p_variance = obs_ANN_99p_variance_mask
  delete(obs_ANN_99p_variance_mask)
  obs_ANN_01p_variance_mask = obs_ANN_01p_variance
  obs_ANN_01p_variance_mask = where(obs_ANN_01p_variance_mask.eq.0, obs_ANN_01p_variance_mask@_FillValue, obs_ANN_01p_variance_mask)
  delete(obs_ANN_01p_variance)
  obs_ANN_01p_variance = obs_ANN_01p_variance_mask
  delete(obs_ANN_01p_variance_mask)

  fout_ANN = addfile(fout_name_ANN, "c")
  fout_ANN->av_ANN_avg = av_ANN_avg
  fout_ANN->gdd_ANN_avg_rmse = gdd_ANN_avg_rmse
  fout_ANN->rcm_ANN_avg_rmse = rcm_ANN_avg_rmse
  fout_ANN->obs_ANN_avg_variance = obs_ANN_avg_variance
  fout_ANN->obs_ANN_avg = obs_ANN_avg
  fout_ANN->gdd_hist_ANN_avg = gdd_hist_ANN_avg
  fout_ANN->rcm_hist_ANN_avg = rcm_hist_ANN_avg
  fout_ANN->av_ANN_var = av_ANN_var
  fout_ANN->gdd_ANN_var_rmse = gdd_ANN_var_rmse
  fout_ANN->rcm_ANN_var_rmse = rcm_ANN_var_rmse
  fout_ANN->obs_ANN_var_variance = obs_ANN_var_variance
  fout_ANN->obs_ANN_var = obs_ANN_var
  fout_ANN->gdd_hist_ANN_var = gdd_hist_ANN_var
  fout_ANN->rcm_hist_ANN_var = rcm_hist_ANN_var
  fout_ANN->av_ANN_99p = av_ANN_99p
  fout_ANN->gdd_ANN_99p_rmse = gdd_ANN_99p_rmse
  fout_ANN->rcm_ANN_99p_rmse = rcm_ANN_99p_rmse
  fout_ANN->obs_ANN_99p_variance = obs_ANN_99p_variance
  fout_ANN->obs_ANN_99p = obs_ANN_99p
  fout_ANN->gdd_hist_ANN_99p = gdd_hist_ANN_99p
  fout_ANN->rcm_hist_ANN_99p = rcm_hist_ANN_99p
  fout_ANN->av_ANN_01p = av_ANN_01p
  fout_ANN->gdd_ANN_01p_rmse = gdd_ANN_01p_rmse
  fout_ANN->rcm_ANN_01p_rmse = rcm_ANN_01p_rmse
  fout_ANN->obs_ANN_01p_variance = obs_ANN_01p_variance
  fout_ANN->obs_ANN_01p = obs_ANN_01p
  fout_ANN->gdd_hist_ANN_01p = gdd_hist_ANN_01p
  fout_ANN->rcm_hist_ANN_01p = rcm_hist_ANN_01p

  printVarSummary(obs_ANN_avg_variance&lat)
  printVarSummary(obs_ANN_avg_variance&lon)
  printVarSummary(av_ANN_avg&lat)
  printVarSummary(av_ANN_avg&lon)
  printVarSummary(gdd_ANN_avg_rmse&lat)
  printVarSummary(gdd_ANN_avg_rmse&lon)

  delete(fout_ANN)

; JAN
  print(systemfunc("date"))
  print("JAN")
  rcm_JAN_avg_rmse = rcm_hist_JAN_avg
  rcm_JAN_avg_rmse = sqrt((rcm_hist_JAN_avg - obs_JAN_avg)^2)
  rcm_JAN_var_rmse = rcm_hist_JAN_var
  rcm_JAN_var_rmse = sqrt((rcm_hist_JAN_var - obs_JAN_var)^2)
  rcm_JAN_99p_rmse = rcm_hist_JAN_99p
  rcm_JAN_99p_rmse = sqrt((rcm_hist_JAN_99p - obs_JAN_99p)^2)
  rcm_JAN_01p_rmse = rcm_hist_JAN_01p
  rcm_JAN_01p_rmse = sqrt((rcm_hist_JAN_01p - obs_JAN_01p)^2)

  gdd_JAN_avg_rmse = gdd_hist_JAN_avg
  gdd_JAN_avg_rmse = sqrt((gdd_hist_JAN_avg - obs_JAN_avg)^2)
  gdd_JAN_var_rmse = gdd_hist_JAN_var
  gdd_JAN_var_rmse = sqrt((gdd_hist_JAN_var - obs_JAN_var)^2)
  gdd_JAN_99p_rmse = gdd_hist_JAN_99p
  gdd_JAN_99p_rmse = sqrt((gdd_hist_JAN_99p - obs_JAN_99p)^2)
  gdd_JAN_01p_rmse = gdd_hist_JAN_01p
  gdd_JAN_01p_rmse = sqrt((gdd_hist_JAN_01p - obs_JAN_01p)^2)

  av_JAN_avg = gdd_JAN_avg_rmse
  av_JAN_avg = gdd_JAN_avg_rmse - rcm_JAN_avg_rmse
  av_JAN_var = gdd_JAN_var_rmse
  av_JAN_var = gdd_JAN_var_rmse - rcm_JAN_var_rmse
  av_JAN_99p = gdd_JAN_99p_rmse
  av_JAN_99p = gdd_JAN_99p_rmse - rcm_JAN_99p_rmse
  av_JAN_01p = gdd_JAN_01p_rmse
  av_JAN_01p = gdd_JAN_01p_rmse - rcm_JAN_01p_rmse
  
  obs_JAN_avg_variance = dim_variance_n_Wrap(obs_JAN_avg_yearly, 0)
  obs_JAN_var_variance = dim_variance_n_Wrap(obs_JAN_var_yearly, 0)
  obs_JAN_99p_variance = dim_variance_n_Wrap(obs_JAN_99p_yearly, 0)
  obs_JAN_01p_variance = dim_variance_n_Wrap(obs_JAN_01p_yearly, 0)

  delete([/obs_JAN_avg_yearly, obs_JAN_var_yearly, obs_JAN_99p_yearly, obs_JAN_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_JAN_avg_variance_mask = obs_JAN_avg_variance
  obs_JAN_avg_variance_mask = where(obs_JAN_avg_variance_mask.eq.0, obs_JAN_avg_variance_mask@_FillValue, obs_JAN_avg_variance_mask)
  delete(obs_JAN_avg_variance)
  obs_JAN_avg_variance = obs_JAN_avg_variance_mask
  delete(obs_JAN_avg_variance_mask)
  obs_JAN_var_variance_mask = obs_JAN_var_variance
  obs_JAN_var_variance_mask = where(obs_JAN_var_variance_mask.eq.0, obs_JAN_var_variance_mask@_FillValue, obs_JAN_var_variance_mask)
  delete(obs_JAN_var_variance)
  obs_JAN_var_variance = obs_JAN_var_variance_mask
  delete(obs_JAN_var_variance_mask)
  obs_JAN_99p_variance_mask = obs_JAN_99p_variance
  obs_JAN_99p_variance_mask = where(obs_JAN_99p_variance_mask.eq.0, obs_JAN_99p_variance_mask@_FillValue, obs_JAN_99p_variance_mask)
  delete(obs_JAN_99p_variance)
  obs_JAN_99p_variance = obs_JAN_99p_variance_mask
  delete(obs_JAN_99p_variance_mask)
  obs_JAN_01p_variance_mask = obs_JAN_01p_variance
  obs_JAN_01p_variance_mask = where(obs_JAN_01p_variance_mask.eq.0, obs_JAN_01p_variance_mask@_FillValue, obs_JAN_01p_variance_mask)
  delete(obs_JAN_01p_variance)
  obs_JAN_01p_variance = obs_JAN_01p_variance_mask
  delete(obs_JAN_01p_variance_mask)

  fout_JAN = addfile(fout_name_JAN, "c")
  fout_JAN->av_JAN_avg = av_JAN_avg
  fout_JAN->gdd_JAN_avg_rmse = gdd_JAN_avg_rmse
  fout_JAN->rcm_JAN_avg_rmse = rcm_JAN_avg_rmse
  fout_JAN->obs_JAN_avg_variance = obs_JAN_avg_variance
  fout_JAN->obs_JAN_avg = obs_JAN_avg
  fout_JAN->gdd_hist_JAN_avg = gdd_hist_JAN_avg
  fout_JAN->rcm_hist_JAN_avg = rcm_hist_JAN_avg
  fout_JAN->av_JAN_var = av_JAN_var
  fout_JAN->gdd_JAN_var_rmse = gdd_JAN_var_rmse
  fout_JAN->rcm_JAN_var_rmse = rcm_JAN_var_rmse
  fout_JAN->obs_JAN_var_variance = obs_JAN_var_variance
  fout_JAN->obs_JAN_var = obs_JAN_var
  fout_JAN->gdd_hist_JAN_var = gdd_hist_JAN_var
  fout_JAN->rcm_hist_JAN_var = rcm_hist_JAN_var
  fout_JAN->av_JAN_99p = av_JAN_99p
  fout_JAN->gdd_JAN_99p_rmse = gdd_JAN_99p_rmse
  fout_JAN->rcm_JAN_99p_rmse = rcm_JAN_99p_rmse
  fout_JAN->obs_JAN_99p_variance = obs_JAN_99p_variance
  fout_JAN->obs_JAN_99p = obs_JAN_99p
  fout_JAN->gdd_hist_JAN_99p = gdd_hist_JAN_99p
  fout_JAN->rcm_hist_JAN_99p = rcm_hist_JAN_99p
  fout_JAN->av_JAN_01p = av_JAN_01p
  fout_JAN->gdd_JAN_01p_rmse = gdd_JAN_01p_rmse
  fout_JAN->rcm_JAN_01p_rmse = rcm_JAN_01p_rmse
  fout_JAN->obs_JAN_01p_variance = obs_JAN_01p_variance
  fout_JAN->obs_JAN_01p = obs_JAN_01p
  fout_JAN->gdd_hist_JAN_01p = gdd_hist_JAN_01p
  fout_JAN->rcm_hist_JAN_01p = rcm_hist_JAN_01p

  delete(fout_JAN)
  
; FEB
  print(systemfunc("date"))
  print("FEB")
  rcm_FEB_avg_rmse = rcm_hist_FEB_avg
  rcm_FEB_avg_rmse = sqrt((rcm_hist_FEB_avg - obs_FEB_avg)^2)
  rcm_FEB_var_rmse = rcm_hist_FEB_var
  rcm_FEB_var_rmse = sqrt((rcm_hist_FEB_var - obs_FEB_var)^2)
  rcm_FEB_99p_rmse = rcm_hist_FEB_99p
  rcm_FEB_99p_rmse = sqrt((rcm_hist_FEB_99p - obs_FEB_99p)^2)
  rcm_FEB_01p_rmse = rcm_hist_FEB_01p
  rcm_FEB_01p_rmse = sqrt((rcm_hist_FEB_01p - obs_FEB_01p)^2)

  gdd_FEB_avg_rmse = gdd_hist_FEB_avg
  gdd_FEB_avg_rmse = sqrt((gdd_hist_FEB_avg - obs_FEB_avg)^2)
  gdd_FEB_var_rmse = gdd_hist_FEB_var
  gdd_FEB_var_rmse = sqrt((gdd_hist_FEB_var - obs_FEB_var)^2)
  gdd_FEB_99p_rmse = gdd_hist_FEB_99p
  gdd_FEB_99p_rmse = sqrt((gdd_hist_FEB_99p - obs_FEB_99p)^2)
  gdd_FEB_01p_rmse = gdd_hist_FEB_01p
  gdd_FEB_01p_rmse = sqrt((gdd_hist_FEB_01p - obs_FEB_01p)^2)

  av_FEB_avg = gdd_FEB_avg_rmse
  av_FEB_avg = gdd_FEB_avg_rmse - rcm_FEB_avg_rmse
  av_FEB_var = gdd_FEB_var_rmse
  av_FEB_var = gdd_FEB_var_rmse - rcm_FEB_var_rmse
  av_FEB_99p = gdd_FEB_99p_rmse
  av_FEB_99p = gdd_FEB_99p_rmse - rcm_FEB_99p_rmse
  av_FEB_01p = gdd_FEB_01p_rmse
  av_FEB_01p = gdd_FEB_01p_rmse - rcm_FEB_01p_rmse

  obs_FEB_avg_variance = dim_variance_n_Wrap(obs_FEB_avg_yearly, 0)
  obs_FEB_var_variance = dim_variance_n_Wrap(obs_FEB_var_yearly, 0)
  obs_FEB_99p_variance = dim_variance_n_Wrap(obs_FEB_99p_yearly, 0)
  obs_FEB_01p_variance = dim_variance_n_Wrap(obs_FEB_01p_yearly, 0)

  delete([/obs_FEB_avg_yearly, obs_FEB_var_yearly, obs_FEB_99p_yearly, obs_FEB_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_FEB_avg_variance_mask = obs_FEB_avg_variance
  obs_FEB_avg_variance_mask = where(obs_FEB_avg_variance_mask.eq.0, obs_FEB_avg_variance_mask@_FillValue, obs_FEB_avg_variance_mask)
  delete(obs_FEB_avg_variance)
  obs_FEB_avg_variance = obs_FEB_avg_variance_mask
  delete(obs_FEB_avg_variance_mask)
  obs_FEB_var_variance_mask = obs_FEB_var_variance
  obs_FEB_var_variance_mask = where(obs_FEB_var_variance_mask.eq.0, obs_FEB_var_variance_mask@_FillValue, obs_FEB_var_variance_mask)
  delete(obs_FEB_var_variance)
  obs_FEB_var_variance = obs_FEB_var_variance_mask
  delete(obs_FEB_var_variance_mask)
  obs_FEB_99p_variance_mask = obs_FEB_99p_variance
  obs_FEB_99p_variance_mask = where(obs_FEB_99p_variance_mask.eq.0, obs_FEB_99p_variance_mask@_FillValue, obs_FEB_99p_variance_mask)
  delete(obs_FEB_99p_variance)
  obs_FEB_99p_variance = obs_FEB_99p_variance_mask
  delete(obs_FEB_99p_variance_mask)
  obs_FEB_01p_variance_mask = obs_FEB_01p_variance
  obs_FEB_01p_variance_mask = where(obs_FEB_01p_variance_mask.eq.0, obs_FEB_01p_variance_mask@_FillValue, obs_FEB_01p_variance_mask)
  delete(obs_FEB_01p_variance)
  obs_FEB_01p_variance = obs_FEB_01p_variance_mask
  delete(obs_FEB_01p_variance_mask)

  fout_FEB = addfile(fout_name_FEB, "c")
  fout_FEB->av_FEB_avg = av_FEB_avg
  fout_FEB->gdd_FEB_avg_rmse = gdd_FEB_avg_rmse
  fout_FEB->rcm_FEB_avg_rmse = rcm_FEB_avg_rmse
  fout_FEB->obs_FEB_avg_variance = obs_FEB_avg_variance
  fout_FEB->obs_FEB_avg = obs_FEB_avg
  fout_FEB->gdd_hist_FEB_avg = gdd_hist_FEB_avg
  fout_FEB->rcm_hist_FEB_avg = rcm_hist_FEB_avg
  fout_FEB->av_FEB_var = av_FEB_var
  fout_FEB->gdd_FEB_var_rmse = gdd_FEB_var_rmse
  fout_FEB->rcm_FEB_var_rmse = rcm_FEB_var_rmse
  fout_FEB->obs_FEB_var_variance = obs_FEB_var_variance
  fout_FEB->obs_FEB_var = obs_FEB_var
  fout_FEB->gdd_hist_FEB_var = gdd_hist_FEB_var
  fout_FEB->rcm_hist_FEB_var = rcm_hist_FEB_var
  fout_FEB->av_FEB_99p = av_FEB_99p
  fout_FEB->gdd_FEB_99p_rmse = gdd_FEB_99p_rmse
  fout_FEB->rcm_FEB_99p_rmse = rcm_FEB_99p_rmse
  fout_FEB->obs_FEB_99p_variance = obs_FEB_99p_variance
  fout_FEB->obs_FEB_99p = obs_FEB_99p
  fout_FEB->gdd_hist_FEB_99p = gdd_hist_FEB_99p
  fout_FEB->rcm_hist_FEB_99p = rcm_hist_FEB_99p
  fout_FEB->av_FEB_01p = av_FEB_01p
  fout_FEB->gdd_FEB_01p_rmse = gdd_FEB_01p_rmse
  fout_FEB->rcm_FEB_01p_rmse = rcm_FEB_01p_rmse
  fout_FEB->obs_FEB_01p_variance = obs_FEB_01p_variance
  fout_FEB->obs_FEB_01p = obs_FEB_01p
  fout_FEB->gdd_hist_FEB_01p = gdd_hist_FEB_01p
  fout_FEB->rcm_hist_FEB_01p = rcm_hist_FEB_01p

  delete(fout_FEB)

; MAR
  print(systemfunc("date"))
  print("MAR")
  rcm_MAR_avg_rmse = rcm_hist_MAR_avg
  rcm_MAR_avg_rmse = sqrt((rcm_hist_MAR_avg - obs_MAR_avg)^2)
  rcm_MAR_var_rmse = rcm_hist_MAR_var
  rcm_MAR_var_rmse = sqrt((rcm_hist_MAR_var - obs_MAR_var)^2)
  rcm_MAR_99p_rmse = rcm_hist_MAR_99p
  rcm_MAR_99p_rmse = sqrt((rcm_hist_MAR_99p - obs_MAR_99p)^2)
  rcm_MAR_01p_rmse = rcm_hist_MAR_01p
  rcm_MAR_01p_rmse = sqrt((rcm_hist_MAR_01p - obs_MAR_01p)^2)

  gdd_MAR_avg_rmse = gdd_hist_MAR_avg
  gdd_MAR_avg_rmse = sqrt((gdd_hist_MAR_avg - obs_MAR_avg)^2)
  gdd_MAR_var_rmse = gdd_hist_MAR_var
  gdd_MAR_var_rmse = sqrt((gdd_hist_MAR_var - obs_MAR_var)^2)
  gdd_MAR_99p_rmse = gdd_hist_MAR_99p
  gdd_MAR_99p_rmse = sqrt((gdd_hist_MAR_99p - obs_MAR_99p)^2)
  gdd_MAR_01p_rmse = gdd_hist_MAR_01p
  gdd_MAR_01p_rmse = sqrt((gdd_hist_MAR_01p - obs_MAR_01p)^2)

  av_MAR_avg = gdd_MAR_avg_rmse
  av_MAR_avg = gdd_MAR_avg_rmse - rcm_MAR_avg_rmse
  av_MAR_var = gdd_MAR_var_rmse
  av_MAR_var = gdd_MAR_var_rmse - rcm_MAR_var_rmse
  av_MAR_99p = gdd_MAR_99p_rmse
  av_MAR_99p = gdd_MAR_99p_rmse - rcm_MAR_99p_rmse
  av_MAR_01p = gdd_MAR_01p_rmse
  av_MAR_01p = gdd_MAR_01p_rmse - rcm_MAR_01p_rmse

  obs_MAR_avg_variance = dim_variance_n_Wrap(obs_MAR_avg_yearly, 0)
  obs_MAR_var_variance = dim_variance_n_Wrap(obs_MAR_var_yearly, 0)
  obs_MAR_99p_variance = dim_variance_n_Wrap(obs_MAR_99p_yearly, 0)
  obs_MAR_01p_variance = dim_variance_n_Wrap(obs_MAR_01p_yearly, 0)

  delete([/obs_MAR_avg_yearly, obs_MAR_var_yearly, obs_MAR_99p_yearly, obs_MAR_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_MAR_avg_variance_mask = obs_MAR_avg_variance
  obs_MAR_avg_variance_mask = where(obs_MAR_avg_variance_mask.eq.0, obs_MAR_avg_variance_mask@_FillValue, obs_MAR_avg_variance_mask)
  delete(obs_MAR_avg_variance)
  obs_MAR_avg_variance = obs_MAR_avg_variance_mask
  delete(obs_MAR_avg_variance_mask)
  obs_MAR_var_variance_mask = obs_MAR_var_variance
  obs_MAR_var_variance_mask = where(obs_MAR_var_variance_mask.eq.0, obs_MAR_var_variance_mask@_FillValue, obs_MAR_var_variance_mask)
  delete(obs_MAR_var_variance)
  obs_MAR_var_variance = obs_MAR_var_variance_mask
  delete(obs_MAR_var_variance_mask)
  obs_MAR_99p_variance_mask = obs_MAR_99p_variance
  obs_MAR_99p_variance_mask = where(obs_MAR_99p_variance_mask.eq.0, obs_MAR_99p_variance_mask@_FillValue, obs_MAR_99p_variance_mask)
  delete(obs_MAR_99p_variance)
  obs_MAR_99p_variance = obs_MAR_99p_variance_mask
  delete(obs_MAR_99p_variance_mask)
  obs_MAR_01p_variance_mask = obs_MAR_01p_variance
  obs_MAR_01p_variance_mask = where(obs_MAR_01p_variance_mask.eq.0, obs_MAR_01p_variance_mask@_FillValue, obs_MAR_01p_variance_mask)
  delete(obs_MAR_01p_variance)
  obs_MAR_01p_variance = obs_MAR_01p_variance_mask
  delete(obs_MAR_01p_variance_mask)

  fout_MAR = addfile(fout_name_MAR, "c")
  fout_MAR->av_MAR_avg = av_MAR_avg
  fout_MAR->gdd_MAR_avg_rmse = gdd_MAR_avg_rmse
  fout_MAR->rcm_MAR_avg_rmse = rcm_MAR_avg_rmse
  fout_MAR->obs_MAR_avg_variance = obs_MAR_avg_variance
  fout_MAR->obs_MAR_avg = obs_MAR_avg
  fout_MAR->gdd_hist_MAR_avg = gdd_hist_MAR_avg
  fout_MAR->rcm_hist_MAR_avg = rcm_hist_MAR_avg
  fout_MAR->av_MAR_var = av_MAR_var
  fout_MAR->gdd_MAR_var_rmse = gdd_MAR_var_rmse
  fout_MAR->rcm_MAR_var_rmse = rcm_MAR_var_rmse
  fout_MAR->obs_MAR_var_variance = obs_MAR_var_variance
  fout_MAR->obs_MAR_var = obs_MAR_var
  fout_MAR->gdd_hist_MAR_var = gdd_hist_MAR_var
  fout_MAR->rcm_hist_MAR_var = rcm_hist_MAR_var
  fout_MAR->av_MAR_99p = av_MAR_99p
  fout_MAR->gdd_MAR_99p_rmse = gdd_MAR_99p_rmse
  fout_MAR->rcm_MAR_99p_rmse = rcm_MAR_99p_rmse
  fout_MAR->obs_MAR_99p_variance = obs_MAR_99p_variance
  fout_MAR->obs_MAR_99p = obs_MAR_99p
  fout_MAR->gdd_hist_MAR_99p = gdd_hist_MAR_99p
  fout_MAR->rcm_hist_MAR_99p = rcm_hist_MAR_99p
  fout_MAR->av_MAR_01p = av_MAR_01p
  fout_MAR->gdd_MAR_01p_rmse = gdd_MAR_01p_rmse
  fout_MAR->rcm_MAR_01p_rmse = rcm_MAR_01p_rmse
  fout_MAR->obs_MAR_01p_variance = obs_MAR_01p_variance
  fout_MAR->obs_MAR_01p = obs_MAR_01p
  fout_MAR->gdd_hist_MAR_01p = gdd_hist_MAR_01p
  fout_MAR->rcm_hist_MAR_01p = rcm_hist_MAR_01p

  delete(fout_MAR)

; APR
  print(systemfunc("date"))
  print("APR")
  rcm_APR_avg_rmse = rcm_hist_APR_avg
  rcm_APR_avg_rmse = sqrt((rcm_hist_APR_avg - obs_APR_avg)^2)
  rcm_APR_var_rmse = rcm_hist_APR_var
  rcm_APR_var_rmse = sqrt((rcm_hist_APR_var - obs_APR_var)^2)
  rcm_APR_99p_rmse = rcm_hist_APR_99p
  rcm_APR_99p_rmse = sqrt((rcm_hist_APR_99p - obs_APR_99p)^2)
  rcm_APR_01p_rmse = rcm_hist_APR_01p
  rcm_APR_01p_rmse = sqrt((rcm_hist_APR_01p - obs_APR_01p)^2)

  gdd_APR_avg_rmse = gdd_hist_APR_avg
  gdd_APR_avg_rmse = sqrt((gdd_hist_APR_avg - obs_APR_avg)^2)
  gdd_APR_var_rmse = gdd_hist_APR_var
  gdd_APR_var_rmse = sqrt((gdd_hist_APR_var - obs_APR_var)^2)
  gdd_APR_99p_rmse = gdd_hist_APR_99p
  gdd_APR_99p_rmse = sqrt((gdd_hist_APR_99p - obs_APR_99p)^2)
  gdd_APR_01p_rmse = gdd_hist_APR_01p
  gdd_APR_01p_rmse = sqrt((gdd_hist_APR_01p - obs_APR_01p)^2)

  av_APR_avg = gdd_APR_avg_rmse
  av_APR_avg = gdd_APR_avg_rmse - rcm_APR_avg_rmse
  av_APR_var = gdd_APR_var_rmse
  av_APR_var = gdd_APR_var_rmse - rcm_APR_var_rmse
  av_APR_99p = gdd_APR_99p_rmse
  av_APR_99p = gdd_APR_99p_rmse - rcm_APR_99p_rmse
  av_APR_01p = gdd_APR_01p_rmse
  av_APR_01p = gdd_APR_01p_rmse - rcm_APR_01p_rmse

  obs_APR_avg_variance = dim_variance_n_Wrap(obs_APR_avg_yearly, 0)
  obs_APR_var_variance = dim_variance_n_Wrap(obs_APR_var_yearly, 0)
  obs_APR_99p_variance = dim_variance_n_Wrap(obs_APR_99p_yearly, 0)
  obs_APR_01p_variance = dim_variance_n_Wrap(obs_APR_01p_yearly, 0)

  delete([/obs_APR_avg_yearly, obs_APR_var_yearly, obs_APR_99p_yearly, obs_APR_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_APR_avg_variance_mask = obs_APR_avg_variance
  obs_APR_avg_variance_mask = where(obs_APR_avg_variance_mask.eq.0, obs_APR_avg_variance_mask@_FillValue, obs_APR_avg_variance_mask)
  delete(obs_APR_avg_variance)
  obs_APR_avg_variance = obs_APR_avg_variance_mask
  delete(obs_APR_avg_variance_mask)
  obs_APR_var_variance_mask = obs_APR_var_variance
  obs_APR_var_variance_mask = where(obs_APR_var_variance_mask.eq.0, obs_APR_var_variance_mask@_FillValue, obs_APR_var_variance_mask)
  delete(obs_APR_var_variance)
  obs_APR_var_variance = obs_APR_var_variance_mask
  delete(obs_APR_var_variance_mask)
  obs_APR_99p_variance_mask = obs_APR_99p_variance
  obs_APR_99p_variance_mask = where(obs_APR_99p_variance_mask.eq.0, obs_APR_99p_variance_mask@_FillValue, obs_APR_99p_variance_mask)
  delete(obs_APR_99p_variance)
  obs_APR_99p_variance = obs_APR_99p_variance_mask
  delete(obs_APR_99p_variance_mask)
  obs_APR_01p_variance_mask = obs_APR_01p_variance
  obs_APR_01p_variance_mask = where(obs_APR_01p_variance_mask.eq.0, obs_APR_01p_variance_mask@_FillValue, obs_APR_01p_variance_mask)
  delete(obs_APR_01p_variance)
  obs_APR_01p_variance = obs_APR_01p_variance_mask
  delete(obs_APR_01p_variance_mask)


  fout_APR = addfile(fout_name_APR, "c")
  fout_APR->av_APR_avg = av_APR_avg
  fout_APR->gdd_APR_avg_rmse = gdd_APR_avg_rmse
  fout_APR->rcm_APR_avg_rmse = rcm_APR_avg_rmse
  fout_APR->obs_APR_avg_variance = obs_APR_avg_variance
  fout_APR->obs_APR_avg = obs_APR_avg
  fout_APR->gdd_hist_APR_avg = gdd_hist_APR_avg
  fout_APR->rcm_hist_APR_avg = rcm_hist_APR_avg
  fout_APR->av_APR_var = av_APR_var
  fout_APR->gdd_APR_var_rmse = gdd_APR_var_rmse
  fout_APR->rcm_APR_var_rmse = rcm_APR_var_rmse
  fout_APR->obs_APR_var_variance = obs_APR_var_variance
  fout_APR->obs_APR_var = obs_APR_var
  fout_APR->gdd_hist_APR_var = gdd_hist_APR_var
  fout_APR->rcm_hist_APR_var = rcm_hist_APR_var
  fout_APR->av_APR_99p = av_APR_99p
  fout_APR->gdd_APR_99p_rmse = gdd_APR_99p_rmse
  fout_APR->rcm_APR_99p_rmse = rcm_APR_99p_rmse
  fout_APR->obs_APR_99p_variance = obs_APR_99p_variance
  fout_APR->obs_APR_99p = obs_APR_99p
  fout_APR->gdd_hist_APR_99p = gdd_hist_APR_99p
  fout_APR->rcm_hist_APR_99p = rcm_hist_APR_99p
  fout_APR->av_APR_01p = av_APR_01p
  fout_APR->gdd_APR_01p_rmse = gdd_APR_01p_rmse
  fout_APR->rcm_APR_01p_rmse = rcm_APR_01p_rmse
  fout_APR->obs_APR_01p_variance = obs_APR_01p_variance
  fout_APR->obs_APR_01p = obs_APR_01p
  fout_APR->gdd_hist_APR_01p = gdd_hist_APR_01p
  fout_APR->rcm_hist_APR_01p = rcm_hist_APR_01p

  delete(fout_APR)

; MAY
  print(systemfunc("date"))
  print("MAY")
  rcm_MAY_avg_rmse = rcm_hist_MAY_avg
  rcm_MAY_avg_rmse = sqrt((rcm_hist_MAY_avg - obs_MAY_avg)^2)
  rcm_MAY_var_rmse = rcm_hist_MAY_var
  rcm_MAY_var_rmse = sqrt((rcm_hist_MAY_var - obs_MAY_var)^2)
  rcm_MAY_99p_rmse = rcm_hist_MAY_99p
  rcm_MAY_99p_rmse = sqrt((rcm_hist_MAY_99p - obs_MAY_99p)^2)
  rcm_MAY_01p_rmse = rcm_hist_MAY_01p
  rcm_MAY_01p_rmse = sqrt((rcm_hist_MAY_01p - obs_MAY_01p)^2)

  gdd_MAY_avg_rmse = gdd_hist_MAY_avg
  gdd_MAY_avg_rmse = sqrt((gdd_hist_MAY_avg - obs_MAY_avg)^2)
  gdd_MAY_var_rmse = gdd_hist_MAY_var
  gdd_MAY_var_rmse = sqrt((gdd_hist_MAY_var - obs_MAY_var)^2)
  gdd_MAY_99p_rmse = gdd_hist_MAY_99p
  gdd_MAY_99p_rmse = sqrt((gdd_hist_MAY_99p - obs_MAY_99p)^2)
  gdd_MAY_01p_rmse = gdd_hist_MAY_01p
  gdd_MAY_01p_rmse = sqrt((gdd_hist_MAY_01p - obs_MAY_01p)^2)

  av_MAY_avg = gdd_MAY_avg_rmse
  av_MAY_avg = gdd_MAY_avg_rmse - rcm_MAY_avg_rmse
  av_MAY_var = gdd_MAY_var_rmse
  av_MAY_var = gdd_MAY_var_rmse - rcm_MAY_var_rmse
  av_MAY_99p = gdd_MAY_99p_rmse
  av_MAY_99p = gdd_MAY_99p_rmse - rcm_MAY_99p_rmse
  av_MAY_01p = gdd_MAY_01p_rmse
  av_MAY_01p = gdd_MAY_01p_rmse - rcm_MAY_01p_rmse

  obs_MAY_avg_variance = dim_variance_n_Wrap(obs_MAY_avg_yearly, 0)
  obs_MAY_var_variance = dim_variance_n_Wrap(obs_MAY_var_yearly, 0)
  obs_MAY_99p_variance = dim_variance_n_Wrap(obs_MAY_99p_yearly, 0)
  obs_MAY_01p_variance = dim_variance_n_Wrap(obs_MAY_01p_yearly, 0)

  delete([/obs_MAY_avg_yearly, obs_MAY_var_yearly, obs_MAY_99p_yearly, obs_MAY_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_MAY_avg_variance_mask = obs_MAY_avg_variance
  obs_MAY_avg_variance_mask = where(obs_MAY_avg_variance_mask.eq.0, obs_MAY_avg_variance_mask@_FillValue, obs_MAY_avg_variance_mask)
  delete(obs_MAY_avg_variance)
  obs_MAY_avg_variance = obs_MAY_avg_variance_mask
  delete(obs_MAY_avg_variance_mask)
  obs_MAY_var_variance_mask = obs_MAY_var_variance
  obs_MAY_var_variance_mask = where(obs_MAY_var_variance_mask.eq.0, obs_MAY_var_variance_mask@_FillValue, obs_MAY_var_variance_mask)
  delete(obs_MAY_var_variance)
  obs_MAY_var_variance = obs_MAY_var_variance_mask
  delete(obs_MAY_var_variance_mask)
  obs_MAY_99p_variance_mask = obs_MAY_99p_variance
  obs_MAY_99p_variance_mask = where(obs_MAY_99p_variance_mask.eq.0, obs_MAY_99p_variance_mask@_FillValue, obs_MAY_99p_variance_mask)
  delete(obs_MAY_99p_variance)
  obs_MAY_99p_variance = obs_MAY_99p_variance_mask
  delete(obs_MAY_99p_variance_mask)
  obs_MAY_01p_variance_mask = obs_MAY_01p_variance
  obs_MAY_01p_variance_mask = where(obs_MAY_01p_variance_mask.eq.0, obs_MAY_01p_variance_mask@_FillValue, obs_MAY_01p_variance_mask)
  delete(obs_MAY_01p_variance)
  obs_MAY_01p_variance = obs_MAY_01p_variance_mask
  delete(obs_MAY_01p_variance_mask)

  fout_MAY = addfile(fout_name_MAY, "c")
  fout_MAY->av_MAY_avg = av_MAY_avg
  fout_MAY->gdd_MAY_avg_rmse = gdd_MAY_avg_rmse
  fout_MAY->rcm_MAY_avg_rmse = rcm_MAY_avg_rmse
  fout_MAY->obs_MAY_avg_variance = obs_MAY_avg_variance
  fout_MAY->obs_MAY_avg = obs_MAY_avg
  fout_MAY->gdd_hist_MAY_avg = gdd_hist_MAY_avg
  fout_MAY->rcm_hist_MAY_avg = rcm_hist_MAY_avg
  fout_MAY->av_MAY_var = av_MAY_var
  fout_MAY->gdd_MAY_var_rmse = gdd_MAY_var_rmse
  fout_MAY->rcm_MAY_var_rmse = rcm_MAY_var_rmse
  fout_MAY->obs_MAY_var_variance = obs_MAY_var_variance
  fout_MAY->obs_MAY_var = obs_MAY_var
  fout_MAY->gdd_hist_MAY_var = gdd_hist_MAY_var
  fout_MAY->rcm_hist_MAY_var = rcm_hist_MAY_var
  fout_MAY->av_MAY_99p = av_MAY_99p
  fout_MAY->gdd_MAY_99p_rmse = gdd_MAY_99p_rmse
  fout_MAY->rcm_MAY_99p_rmse = rcm_MAY_99p_rmse
  fout_MAY->obs_MAY_99p_variance = obs_MAY_99p_variance
  fout_MAY->obs_MAY_99p = obs_MAY_99p
  fout_MAY->gdd_hist_MAY_99p = gdd_hist_MAY_99p
  fout_MAY->rcm_hist_MAY_99p = rcm_hist_MAY_99p
  fout_MAY->av_MAY_01p = av_MAY_01p
  fout_MAY->gdd_MAY_01p_rmse = gdd_MAY_01p_rmse
  fout_MAY->rcm_MAY_01p_rmse = rcm_MAY_01p_rmse
  fout_MAY->obs_MAY_01p_variance = obs_MAY_01p_variance
  fout_MAY->obs_MAY_01p = obs_MAY_01p
  fout_MAY->gdd_hist_MAY_01p = gdd_hist_MAY_01p
  fout_MAY->rcm_hist_MAY_01p = rcm_hist_MAY_01p

  delete(fout_MAY)

; JUN
  print(systemfunc("date"))
  print("JUN")
  rcm_JUN_avg_rmse = rcm_hist_JUN_avg
  rcm_JUN_avg_rmse = sqrt((rcm_hist_JUN_avg - obs_JUN_avg)^2)
  rcm_JUN_var_rmse = rcm_hist_JUN_var
  rcm_JUN_var_rmse = sqrt((rcm_hist_JUN_var - obs_JUN_var)^2)
  rcm_JUN_99p_rmse = rcm_hist_JUN_99p
  rcm_JUN_99p_rmse = sqrt((rcm_hist_JUN_99p - obs_JUN_99p)^2)
  rcm_JUN_01p_rmse = rcm_hist_JUN_01p
  rcm_JUN_01p_rmse = sqrt((rcm_hist_JUN_01p - obs_JUN_01p)^2)

  gdd_JUN_avg_rmse = gdd_hist_JUN_avg
  gdd_JUN_avg_rmse = sqrt((gdd_hist_JUN_avg - obs_JUN_avg)^2)
  gdd_JUN_var_rmse = gdd_hist_JUN_var
  gdd_JUN_var_rmse = sqrt((gdd_hist_JUN_var - obs_JUN_var)^2)
  gdd_JUN_99p_rmse = gdd_hist_JUN_99p
  gdd_JUN_99p_rmse = sqrt((gdd_hist_JUN_99p - obs_JUN_99p)^2)
  gdd_JUN_01p_rmse = gdd_hist_JUN_01p
  gdd_JUN_01p_rmse = sqrt((gdd_hist_JUN_01p - obs_JUN_01p)^2)

  av_JUN_avg = gdd_JUN_avg_rmse
  av_JUN_avg = gdd_JUN_avg_rmse - rcm_JUN_avg_rmse
  av_JUN_var = gdd_JUN_var_rmse
  av_JUN_var = gdd_JUN_var_rmse - rcm_JUN_var_rmse
  av_JUN_99p = gdd_JUN_99p_rmse
  av_JUN_99p = gdd_JUN_99p_rmse - rcm_JUN_99p_rmse
  av_JUN_01p = gdd_JUN_01p_rmse
  av_JUN_01p = gdd_JUN_01p_rmse - rcm_JUN_01p_rmse

  obs_JUN_avg_variance = dim_variance_n_Wrap(obs_JUN_avg_yearly, 0)
  obs_JUN_var_variance = dim_variance_n_Wrap(obs_JUN_var_yearly, 0)
  obs_JUN_99p_variance = dim_variance_n_Wrap(obs_JUN_99p_yearly, 0)
  obs_JUN_01p_variance = dim_variance_n_Wrap(obs_JUN_01p_yearly, 0)

  delete([/obs_JUN_avg_yearly, obs_JUN_var_yearly, obs_JUN_99p_yearly, obs_JUN_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_JUN_avg_variance_mask = obs_JUN_avg_variance
  obs_JUN_avg_variance_mask = where(obs_JUN_avg_variance_mask.eq.0, obs_JUN_avg_variance_mask@_FillValue, obs_JUN_avg_variance_mask)
  delete(obs_JUN_avg_variance)
  obs_JUN_avg_variance = obs_JUN_avg_variance_mask
  delete(obs_JUN_avg_variance_mask)
  obs_JUN_var_variance_mask = obs_JUN_var_variance
  obs_JUN_var_variance_mask = where(obs_JUN_var_variance_mask.eq.0, obs_JUN_var_variance_mask@_FillValue, obs_JUN_var_variance_mask)
  delete(obs_JUN_var_variance)
  obs_JUN_var_variance = obs_JUN_var_variance_mask
  delete(obs_JUN_var_variance_mask)
  obs_JUN_99p_variance_mask = obs_JUN_99p_variance
  obs_JUN_99p_variance_mask = where(obs_JUN_99p_variance_mask.eq.0, obs_JUN_99p_variance_mask@_FillValue, obs_JUN_99p_variance_mask)
  delete(obs_JUN_99p_variance)
  obs_JUN_99p_variance = obs_JUN_99p_variance_mask
  delete(obs_JUN_99p_variance_mask)
  obs_JUN_01p_variance_mask = obs_JUN_01p_variance
  obs_JUN_01p_variance_mask = where(obs_JUN_01p_variance_mask.eq.0, obs_JUN_01p_variance_mask@_FillValue, obs_JUN_01p_variance_mask)
  delete(obs_JUN_01p_variance)
  obs_JUN_01p_variance = obs_JUN_01p_variance_mask
  delete(obs_JUN_01p_variance_mask)

  fout_JUN = addfile(fout_name_JUN, "c")
  fout_JUN->av_JUN_avg = av_JUN_avg
  fout_JUN->gdd_JUN_avg_rmse = gdd_JUN_avg_rmse
  fout_JUN->rcm_JUN_avg_rmse = rcm_JUN_avg_rmse
  fout_JUN->obs_JUN_avg_variance = obs_JUN_avg_variance
  fout_JUN->obs_JUN_avg = obs_JUN_avg
  fout_JUN->gdd_hist_JUN_avg = gdd_hist_JUN_avg
  fout_JUN->rcm_hist_JUN_avg = rcm_hist_JUN_avg
  fout_JUN->av_JUN_var = av_JUN_var
  fout_JUN->gdd_JUN_var_rmse = gdd_JUN_var_rmse
  fout_JUN->rcm_JUN_var_rmse = rcm_JUN_var_rmse
  fout_JUN->obs_JUN_var_variance = obs_JUN_var_variance
  fout_JUN->obs_JUN_var = obs_JUN_var
  fout_JUN->gdd_hist_JUN_var = gdd_hist_JUN_var
  fout_JUN->rcm_hist_JUN_var = rcm_hist_JUN_var
  fout_JUN->av_JUN_99p = av_JUN_99p
  fout_JUN->gdd_JUN_99p_rmse = gdd_JUN_99p_rmse
  fout_JUN->rcm_JUN_99p_rmse = rcm_JUN_99p_rmse
  fout_JUN->obs_JUN_99p_variance = obs_JUN_99p_variance
  fout_JUN->obs_JUN_99p = obs_JUN_99p
  fout_JUN->gdd_hist_JUN_99p = gdd_hist_JUN_99p
  fout_JUN->rcm_hist_JUN_99p = rcm_hist_JUN_99p
  fout_JUN->av_JUN_01p = av_JUN_01p
  fout_JUN->gdd_JUN_01p_rmse = gdd_JUN_01p_rmse
  fout_JUN->rcm_JUN_01p_rmse = rcm_JUN_01p_rmse
  fout_JUN->obs_JUN_01p_variance = obs_JUN_01p_variance
  fout_JUN->obs_JUN_01p = obs_JUN_01p
  fout_JUN->gdd_hist_JUN_01p = gdd_hist_JUN_01p
  fout_JUN->rcm_hist_JUN_01p = rcm_hist_JUN_01p

  delete(fout_JUN)

; JUL
  print(systemfunc("date"))
  print("JUL")
  rcm_JUL_avg_rmse = rcm_hist_JUL_avg
  rcm_JUL_avg_rmse = sqrt((rcm_hist_JUL_avg - obs_JUL_avg)^2)
  rcm_JUL_var_rmse = rcm_hist_JUL_var
  rcm_JUL_var_rmse = sqrt((rcm_hist_JUL_var - obs_JUL_var)^2)
  rcm_JUL_99p_rmse = rcm_hist_JUL_99p
  rcm_JUL_99p_rmse = sqrt((rcm_hist_JUL_99p - obs_JUL_99p)^2)
  rcm_JUL_01p_rmse = rcm_hist_JUL_01p
  rcm_JUL_01p_rmse = sqrt((rcm_hist_JUL_01p - obs_JUL_01p)^2)

  gdd_JUL_avg_rmse = gdd_hist_JUL_avg
  gdd_JUL_avg_rmse = sqrt((gdd_hist_JUL_avg - obs_JUL_avg)^2)
  gdd_JUL_var_rmse = gdd_hist_JUL_var
  gdd_JUL_var_rmse = sqrt((gdd_hist_JUL_var - obs_JUL_var)^2)
  gdd_JUL_99p_rmse = gdd_hist_JUL_99p
  gdd_JUL_99p_rmse = sqrt((gdd_hist_JUL_99p - obs_JUL_99p)^2)
  gdd_JUL_01p_rmse = gdd_hist_JUL_01p
  gdd_JUL_01p_rmse = sqrt((gdd_hist_JUL_01p - obs_JUL_01p)^2)

  av_JUL_avg = gdd_JUL_avg_rmse
  av_JUL_avg = gdd_JUL_avg_rmse - rcm_JUL_avg_rmse
  av_JUL_var = gdd_JUL_var_rmse
  av_JUL_var = gdd_JUL_var_rmse - rcm_JUL_var_rmse
  av_JUL_99p = gdd_JUL_99p_rmse
  av_JUL_99p = gdd_JUL_99p_rmse - rcm_JUL_99p_rmse
  av_JUL_01p = gdd_JUL_01p_rmse
  av_JUL_01p = gdd_JUL_01p_rmse - rcm_JUL_01p_rmse

  obs_JUL_avg_variance = dim_variance_n_Wrap(obs_JUL_avg_yearly, 0)
  obs_JUL_var_variance = dim_variance_n_Wrap(obs_JUL_var_yearly, 0)
  obs_JUL_99p_variance = dim_variance_n_Wrap(obs_JUL_99p_yearly, 0)
  obs_JUL_01p_variance = dim_variance_n_Wrap(obs_JUL_01p_yearly, 0)

  delete([/obs_JUL_avg_yearly, obs_JUL_var_yearly, obs_JUL_99p_yearly, obs_JUL_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_JUL_avg_variance_mask = obs_JUL_avg_variance
  obs_JUL_avg_variance_mask = where(obs_JUL_avg_variance_mask.eq.0, obs_JUL_avg_variance_mask@_FillValue, obs_JUL_avg_variance_mask)
  delete(obs_JUL_avg_variance)
  obs_JUL_avg_variance = obs_JUL_avg_variance_mask
  delete(obs_JUL_avg_variance_mask)
  obs_JUL_var_variance_mask = obs_JUL_var_variance
  obs_JUL_var_variance_mask = where(obs_JUL_var_variance_mask.eq.0, obs_JUL_var_variance_mask@_FillValue, obs_JUL_var_variance_mask)
  delete(obs_JUL_var_variance)
  obs_JUL_var_variance = obs_JUL_var_variance_mask
  delete(obs_JUL_var_variance_mask)
  obs_JUL_99p_variance_mask = obs_JUL_99p_variance
  obs_JUL_99p_variance_mask = where(obs_JUL_99p_variance_mask.eq.0, obs_JUL_99p_variance_mask@_FillValue, obs_JUL_99p_variance_mask)
  delete(obs_JUL_99p_variance)
  obs_JUL_99p_variance = obs_JUL_99p_variance_mask
  delete(obs_JUL_99p_variance_mask)
  obs_JUL_01p_variance_mask = obs_JUL_01p_variance
  obs_JUL_01p_variance_mask = where(obs_JUL_01p_variance_mask.eq.0, obs_JUL_01p_variance_mask@_FillValue, obs_JUL_01p_variance_mask)
  delete(obs_JUL_01p_variance)
  obs_JUL_01p_variance = obs_JUL_01p_variance_mask
  delete(obs_JUL_01p_variance_mask)

  fout_JUL = addfile(fout_name_JUL, "c")
  fout_JUL->av_JUL_avg = av_JUL_avg
  fout_JUL->gdd_JUL_avg_rmse = gdd_JUL_avg_rmse
  fout_JUL->rcm_JUL_avg_rmse = rcm_JUL_avg_rmse
  fout_JUL->obs_JUL_avg_variance = obs_JUL_avg_variance
  fout_JUL->obs_JUL_avg = obs_JUL_avg
  fout_JUL->gdd_hist_JUL_avg = gdd_hist_JUL_avg
  fout_JUL->rcm_hist_JUL_avg = rcm_hist_JUL_avg
  fout_JUL->av_JUL_var = av_JUL_var
  fout_JUL->gdd_JUL_var_rmse = gdd_JUL_var_rmse
  fout_JUL->rcm_JUL_var_rmse = rcm_JUL_var_rmse
  fout_JUL->obs_JUL_var_variance = obs_JUL_var_variance
  fout_JUL->obs_JUL_var = obs_JUL_var
  fout_JUL->gdd_hist_JUL_var = gdd_hist_JUL_var
  fout_JUL->rcm_hist_JUL_var = rcm_hist_JUL_var
  fout_JUL->av_JUL_99p = av_JUL_99p
  fout_JUL->gdd_JUL_99p_rmse = gdd_JUL_99p_rmse
  fout_JUL->rcm_JUL_99p_rmse = rcm_JUL_99p_rmse
  fout_JUL->obs_JUL_99p_variance = obs_JUL_99p_variance
  fout_JUL->obs_JUL_99p = obs_JUL_99p
  fout_JUL->gdd_hist_JUL_99p = gdd_hist_JUL_99p
  fout_JUL->rcm_hist_JUL_99p = rcm_hist_JUL_99p
  fout_JUL->av_JUL_01p = av_JUL_01p
  fout_JUL->gdd_JUL_01p_rmse = gdd_JUL_01p_rmse
  fout_JUL->rcm_JUL_01p_rmse = rcm_JUL_01p_rmse
  fout_JUL->obs_JUL_01p_variance = obs_JUL_01p_variance
  fout_JUL->obs_JUL_01p = obs_JUL_01p
  fout_JUL->gdd_hist_JUL_01p = gdd_hist_JUL_01p
  fout_JUL->rcm_hist_JUL_01p = rcm_hist_JUL_01p

  delete(fout_JUL)

; AUG
  print(systemfunc("date"))
  print("AUG")
  rcm_AUG_avg_rmse = rcm_hist_AUG_avg
  rcm_AUG_avg_rmse = sqrt((rcm_hist_AUG_avg - obs_AUG_avg)^2)
  rcm_AUG_var_rmse = rcm_hist_AUG_var
  rcm_AUG_var_rmse = sqrt((rcm_hist_AUG_var - obs_AUG_var)^2)
  rcm_AUG_99p_rmse = rcm_hist_AUG_99p
  rcm_AUG_99p_rmse = sqrt((rcm_hist_AUG_99p - obs_AUG_99p)^2)
  rcm_AUG_01p_rmse = rcm_hist_AUG_01p
  rcm_AUG_01p_rmse = sqrt((rcm_hist_AUG_01p - obs_AUG_01p)^2)

  gdd_AUG_avg_rmse = gdd_hist_AUG_avg
  gdd_AUG_avg_rmse = sqrt((gdd_hist_AUG_avg - obs_AUG_avg)^2)
  gdd_AUG_var_rmse = gdd_hist_AUG_var
  gdd_AUG_var_rmse = sqrt((gdd_hist_AUG_var - obs_AUG_var)^2)
  gdd_AUG_99p_rmse = gdd_hist_AUG_99p
  gdd_AUG_99p_rmse = sqrt((gdd_hist_AUG_99p - obs_AUG_99p)^2)
  gdd_AUG_01p_rmse = gdd_hist_AUG_01p
  gdd_AUG_01p_rmse = sqrt((gdd_hist_AUG_01p - obs_AUG_01p)^2)

  av_AUG_avg = gdd_AUG_avg_rmse
  av_AUG_avg = gdd_AUG_avg_rmse - rcm_AUG_avg_rmse
  av_AUG_var = gdd_AUG_var_rmse
  av_AUG_var = gdd_AUG_var_rmse - rcm_AUG_var_rmse
  av_AUG_99p = gdd_AUG_99p_rmse
  av_AUG_99p = gdd_AUG_99p_rmse - rcm_AUG_99p_rmse
  av_AUG_01p = gdd_AUG_01p_rmse
  av_AUG_01p = gdd_AUG_01p_rmse - rcm_AUG_01p_rmse

  obs_AUG_avg_variance = dim_variance_n_Wrap(obs_AUG_avg_yearly, 0)
  obs_AUG_var_variance = dim_variance_n_Wrap(obs_AUG_var_yearly, 0)
  obs_AUG_99p_variance = dim_variance_n_Wrap(obs_AUG_99p_yearly, 0)
  obs_AUG_01p_variance = dim_variance_n_Wrap(obs_AUG_01p_yearly, 0)

  delete([/obs_AUG_avg_yearly, obs_AUG_var_yearly, obs_AUG_99p_yearly, obs_AUG_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_AUG_avg_variance_mask = obs_AUG_avg_variance
  obs_AUG_avg_variance_mask = where(obs_AUG_avg_variance_mask.eq.0, obs_AUG_avg_variance_mask@_FillValue, obs_AUG_avg_variance_mask)
  delete(obs_AUG_avg_variance)
  obs_AUG_avg_variance = obs_AUG_avg_variance_mask
  delete(obs_AUG_avg_variance_mask)
  obs_AUG_var_variance_mask = obs_AUG_var_variance
  obs_AUG_var_variance_mask = where(obs_AUG_var_variance_mask.eq.0, obs_AUG_var_variance_mask@_FillValue, obs_AUG_var_variance_mask)
  delete(obs_AUG_var_variance)
  obs_AUG_var_variance = obs_AUG_var_variance_mask
  delete(obs_AUG_var_variance_mask)
  obs_AUG_99p_variance_mask = obs_AUG_99p_variance
  obs_AUG_99p_variance_mask = where(obs_AUG_99p_variance_mask.eq.0, obs_AUG_99p_variance_mask@_FillValue, obs_AUG_99p_variance_mask)
  delete(obs_AUG_99p_variance)
  obs_AUG_99p_variance = obs_AUG_99p_variance_mask
  delete(obs_AUG_99p_variance_mask)
  obs_AUG_01p_variance_mask = obs_AUG_01p_variance
  obs_AUG_01p_variance_mask = where(obs_AUG_01p_variance_mask.eq.0, obs_AUG_01p_variance_mask@_FillValue, obs_AUG_01p_variance_mask)
  delete(obs_AUG_01p_variance)
  obs_AUG_01p_variance = obs_AUG_01p_variance_mask
  delete(obs_AUG_01p_variance_mask)

  fout_AUG = addfile(fout_name_AUG, "c")
  fout_AUG->av_AUG_avg = av_AUG_avg
  fout_AUG->gdd_AUG_avg_rmse = gdd_AUG_avg_rmse
  fout_AUG->rcm_AUG_avg_rmse = rcm_AUG_avg_rmse
  fout_AUG->obs_AUG_avg_variance = obs_AUG_avg_variance
  fout_AUG->obs_AUG_avg = obs_AUG_avg
  fout_AUG->gdd_hist_AUG_avg = gdd_hist_AUG_avg
  fout_AUG->rcm_hist_AUG_avg = rcm_hist_AUG_avg
  fout_AUG->av_AUG_var = av_AUG_var
  fout_AUG->gdd_AUG_var_rmse = gdd_AUG_var_rmse
  fout_AUG->rcm_AUG_var_rmse = rcm_AUG_var_rmse
  fout_AUG->obs_AUG_var_variance = obs_AUG_var_variance
  fout_AUG->obs_AUG_var = obs_AUG_var
  fout_AUG->gdd_hist_AUG_var = gdd_hist_AUG_var
  fout_AUG->rcm_hist_AUG_var = rcm_hist_AUG_var
  fout_AUG->av_AUG_99p = av_AUG_99p
  fout_AUG->gdd_AUG_99p_rmse = gdd_AUG_99p_rmse
  fout_AUG->rcm_AUG_99p_rmse = rcm_AUG_99p_rmse
  fout_AUG->obs_AUG_99p_variance = obs_AUG_99p_variance
  fout_AUG->obs_AUG_99p = obs_AUG_99p
  fout_AUG->gdd_hist_AUG_99p = gdd_hist_AUG_99p
  fout_AUG->rcm_hist_AUG_99p = rcm_hist_AUG_99p
  fout_AUG->av_AUG_01p = av_AUG_01p
  fout_AUG->gdd_AUG_01p_rmse = gdd_AUG_01p_rmse
  fout_AUG->rcm_AUG_01p_rmse = rcm_AUG_01p_rmse
  fout_AUG->obs_AUG_01p_variance = obs_AUG_01p_variance
  fout_AUG->obs_AUG_01p = obs_AUG_01p
  fout_AUG->gdd_hist_AUG_01p = gdd_hist_AUG_01p
  fout_AUG->rcm_hist_AUG_01p = rcm_hist_AUG_01p

  delete(fout_AUG)

; SEP
  print(systemfunc("date"))
  print("SEP")
  rcm_SEP_avg_rmse = rcm_hist_SEP_avg
  rcm_SEP_avg_rmse = sqrt((rcm_hist_SEP_avg - obs_SEP_avg)^2)
  rcm_SEP_var_rmse = rcm_hist_SEP_var
  rcm_SEP_var_rmse = sqrt((rcm_hist_SEP_var - obs_SEP_var)^2)
  rcm_SEP_99p_rmse = rcm_hist_SEP_99p
  rcm_SEP_99p_rmse = sqrt((rcm_hist_SEP_99p - obs_SEP_99p)^2)
  rcm_SEP_01p_rmse = rcm_hist_SEP_01p
  rcm_SEP_01p_rmse = sqrt((rcm_hist_SEP_01p - obs_SEP_01p)^2)

  gdd_SEP_avg_rmse = gdd_hist_SEP_avg
  gdd_SEP_avg_rmse = sqrt((gdd_hist_SEP_avg - obs_SEP_avg)^2)
  gdd_SEP_var_rmse = gdd_hist_SEP_var
  gdd_SEP_var_rmse = sqrt((gdd_hist_SEP_var - obs_SEP_var)^2)
  gdd_SEP_99p_rmse = gdd_hist_SEP_99p
  gdd_SEP_99p_rmse = sqrt((gdd_hist_SEP_99p - obs_SEP_99p)^2)
  gdd_SEP_01p_rmse = gdd_hist_SEP_01p
  gdd_SEP_01p_rmse = sqrt((gdd_hist_SEP_01p - obs_SEP_01p)^2)

  av_SEP_avg = gdd_SEP_avg_rmse
  av_SEP_avg = gdd_SEP_avg_rmse - rcm_SEP_avg_rmse
  av_SEP_var = gdd_SEP_var_rmse
  av_SEP_var = gdd_SEP_var_rmse - rcm_SEP_var_rmse
  av_SEP_99p = gdd_SEP_99p_rmse
  av_SEP_99p = gdd_SEP_99p_rmse - rcm_SEP_99p_rmse
  av_SEP_01p = gdd_SEP_01p_rmse
  av_SEP_01p = gdd_SEP_01p_rmse - rcm_SEP_01p_rmse

  obs_SEP_avg_variance = dim_variance_n_Wrap(obs_SEP_avg_yearly, 0)
  obs_SEP_var_variance = dim_variance_n_Wrap(obs_SEP_var_yearly, 0)
  obs_SEP_99p_variance = dim_variance_n_Wrap(obs_SEP_99p_yearly, 0)
  obs_SEP_01p_variance = dim_variance_n_Wrap(obs_SEP_01p_yearly, 0)

  delete([/obs_SEP_avg_yearly, obs_SEP_var_yearly, obs_SEP_99p_yearly, obs_SEP_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_SEP_avg_variance_mask = obs_SEP_avg_variance
  obs_SEP_avg_variance_mask = where(obs_SEP_avg_variance_mask.eq.0, obs_SEP_avg_variance_mask@_FillValue, obs_SEP_avg_variance_mask)
  delete(obs_SEP_avg_variance)
  obs_SEP_avg_variance = obs_SEP_avg_variance_mask
  delete(obs_SEP_avg_variance_mask)
  obs_SEP_var_variance_mask = obs_SEP_var_variance
  obs_SEP_var_variance_mask = where(obs_SEP_var_variance_mask.eq.0, obs_SEP_var_variance_mask@_FillValue, obs_SEP_var_variance_mask)
  delete(obs_SEP_var_variance)
  obs_SEP_var_variance = obs_SEP_var_variance_mask
  delete(obs_SEP_var_variance_mask)
  obs_SEP_99p_variance_mask = obs_SEP_99p_variance
  obs_SEP_99p_variance_mask = where(obs_SEP_99p_variance_mask.eq.0, obs_SEP_99p_variance_mask@_FillValue, obs_SEP_99p_variance_mask)
  delete(obs_SEP_99p_variance)
  obs_SEP_99p_variance = obs_SEP_99p_variance_mask
  delete(obs_SEP_99p_variance_mask)
  obs_SEP_01p_variance_mask = obs_SEP_01p_variance
  obs_SEP_01p_variance_mask = where(obs_SEP_01p_variance_mask.eq.0, obs_SEP_01p_variance_mask@_FillValue, obs_SEP_01p_variance_mask)
  delete(obs_SEP_01p_variance)
  obs_SEP_01p_variance = obs_SEP_01p_variance_mask
  delete(obs_SEP_01p_variance_mask)

  fout_SEP = addfile(fout_name_SEP, "c")
  fout_SEP->av_SEP_avg = av_SEP_avg
  fout_SEP->gdd_SEP_avg_rmse = gdd_SEP_avg_rmse
  fout_SEP->rcm_SEP_avg_rmse = rcm_SEP_avg_rmse
  fout_SEP->obs_SEP_avg_variance = obs_SEP_avg_variance
  fout_SEP->obs_SEP_avg = obs_SEP_avg
  fout_SEP->gdd_hist_SEP_avg = gdd_hist_SEP_avg
  fout_SEP->rcm_hist_SEP_avg = rcm_hist_SEP_avg
  fout_SEP->av_SEP_var = av_SEP_var
  fout_SEP->gdd_SEP_var_rmse = gdd_SEP_var_rmse
  fout_SEP->rcm_SEP_var_rmse = rcm_SEP_var_rmse
  fout_SEP->obs_SEP_var_variance = obs_SEP_var_variance
  fout_SEP->obs_SEP_var = obs_SEP_var
  fout_SEP->gdd_hist_SEP_var = gdd_hist_SEP_var
  fout_SEP->rcm_hist_SEP_var = rcm_hist_SEP_var
  fout_SEP->av_SEP_99p = av_SEP_99p
  fout_SEP->gdd_SEP_99p_rmse = gdd_SEP_99p_rmse
  fout_SEP->rcm_SEP_99p_rmse = rcm_SEP_99p_rmse
  fout_SEP->obs_SEP_99p_variance = obs_SEP_99p_variance
  fout_SEP->obs_SEP_99p = obs_SEP_99p
  fout_SEP->gdd_hist_SEP_99p = gdd_hist_SEP_99p
  fout_SEP->rcm_hist_SEP_99p = rcm_hist_SEP_99p
  fout_SEP->av_SEP_01p = av_SEP_01p
  fout_SEP->gdd_SEP_01p_rmse = gdd_SEP_01p_rmse
  fout_SEP->rcm_SEP_01p_rmse = rcm_SEP_01p_rmse
  fout_SEP->obs_SEP_01p_variance = obs_SEP_01p_variance
  fout_SEP->obs_SEP_01p = obs_SEP_01p
  fout_SEP->gdd_hist_SEP_01p = gdd_hist_SEP_01p
  fout_SEP->rcm_hist_SEP_01p = rcm_hist_SEP_01p

  delete(fout_SEP)

; OCT
  print(systemfunc("date"))
  print("OCT")
  rcm_OCT_avg_rmse = rcm_hist_OCT_avg
  rcm_OCT_avg_rmse = sqrt((rcm_hist_OCT_avg - obs_OCT_avg)^2)
  rcm_OCT_var_rmse = rcm_hist_OCT_var
  rcm_OCT_var_rmse = sqrt((rcm_hist_OCT_var - obs_OCT_var)^2)
  rcm_OCT_99p_rmse = rcm_hist_OCT_99p
  rcm_OCT_99p_rmse = sqrt((rcm_hist_OCT_99p - obs_OCT_99p)^2)
  rcm_OCT_01p_rmse = rcm_hist_OCT_01p
  rcm_OCT_01p_rmse = sqrt((rcm_hist_OCT_01p - obs_OCT_01p)^2)

  gdd_OCT_avg_rmse = gdd_hist_OCT_avg
  gdd_OCT_avg_rmse = sqrt((gdd_hist_OCT_avg - obs_OCT_avg)^2)
  gdd_OCT_var_rmse = gdd_hist_OCT_var
  gdd_OCT_var_rmse = sqrt((gdd_hist_OCT_var - obs_OCT_var)^2)
  gdd_OCT_99p_rmse = gdd_hist_OCT_99p
  gdd_OCT_99p_rmse = sqrt((gdd_hist_OCT_99p - obs_OCT_99p)^2)
  gdd_OCT_01p_rmse = gdd_hist_OCT_01p
  gdd_OCT_01p_rmse = sqrt((gdd_hist_OCT_01p - obs_OCT_01p)^2)

  av_OCT_avg = gdd_OCT_avg_rmse
  av_OCT_avg = gdd_OCT_avg_rmse - rcm_OCT_avg_rmse
  av_OCT_var = gdd_OCT_var_rmse
  av_OCT_var = gdd_OCT_var_rmse - rcm_OCT_var_rmse
  av_OCT_99p = gdd_OCT_99p_rmse
  av_OCT_99p = gdd_OCT_99p_rmse - rcm_OCT_99p_rmse
  av_OCT_01p = gdd_OCT_01p_rmse
  av_OCT_01p = gdd_OCT_01p_rmse - rcm_OCT_01p_rmse

  obs_OCT_avg_variance = dim_variance_n_Wrap(obs_OCT_avg_yearly, 0)
  obs_OCT_var_variance = dim_variance_n_Wrap(obs_OCT_var_yearly, 0)
  obs_OCT_99p_variance = dim_variance_n_Wrap(obs_OCT_99p_yearly, 0)
  obs_OCT_01p_variance = dim_variance_n_Wrap(obs_OCT_01p_yearly, 0)

  delete([/obs_OCT_avg_yearly, obs_OCT_var_yearly, obs_OCT_99p_yearly, obs_OCT_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_OCT_avg_variance_mask = obs_OCT_avg_variance
  obs_OCT_avg_variance_mask = where(obs_OCT_avg_variance_mask.eq.0, obs_OCT_avg_variance_mask@_FillValue, obs_OCT_avg_variance_mask)
  delete(obs_OCT_avg_variance)
  obs_OCT_avg_variance = obs_OCT_avg_variance_mask
  delete(obs_OCT_avg_variance_mask)
  obs_OCT_var_variance_mask = obs_OCT_var_variance
  obs_OCT_var_variance_mask = where(obs_OCT_var_variance_mask.eq.0, obs_OCT_var_variance_mask@_FillValue, obs_OCT_var_variance_mask)
  delete(obs_OCT_var_variance)
  obs_OCT_var_variance = obs_OCT_var_variance_mask
  delete(obs_OCT_var_variance_mask)
  obs_OCT_99p_variance_mask = obs_OCT_99p_variance
  obs_OCT_99p_variance_mask = where(obs_OCT_99p_variance_mask.eq.0, obs_OCT_99p_variance_mask@_FillValue, obs_OCT_99p_variance_mask)
  delete(obs_OCT_99p_variance)
  obs_OCT_99p_variance = obs_OCT_99p_variance_mask
  delete(obs_OCT_99p_variance_mask)
  obs_OCT_01p_variance_mask = obs_OCT_01p_variance
  obs_OCT_01p_variance_mask = where(obs_OCT_01p_variance_mask.eq.0, obs_OCT_01p_variance_mask@_FillValue, obs_OCT_01p_variance_mask)
  delete(obs_OCT_01p_variance)
  obs_OCT_01p_variance = obs_OCT_01p_variance_mask
  delete(obs_OCT_01p_variance_mask)


  fout_OCT = addfile(fout_name_OCT, "c")
  fout_OCT->av_OCT_avg = av_OCT_avg
  fout_OCT->gdd_OCT_avg_rmse = gdd_OCT_avg_rmse
  fout_OCT->rcm_OCT_avg_rmse = rcm_OCT_avg_rmse
  fout_OCT->obs_OCT_avg_variance = obs_OCT_avg_variance
  fout_OCT->obs_OCT_avg = obs_OCT_avg
  fout_OCT->gdd_hist_OCT_avg = gdd_hist_OCT_avg
  fout_OCT->rcm_hist_OCT_avg = rcm_hist_OCT_avg
  fout_OCT->av_OCT_var = av_OCT_var
  fout_OCT->gdd_OCT_var_rmse = gdd_OCT_var_rmse
  fout_OCT->rcm_OCT_var_rmse = rcm_OCT_var_rmse
  fout_OCT->obs_OCT_var_variance = obs_OCT_var_variance
  fout_OCT->obs_OCT_var = obs_OCT_var
  fout_OCT->gdd_hist_OCT_var = gdd_hist_OCT_var
  fout_OCT->rcm_hist_OCT_var = rcm_hist_OCT_var
  fout_OCT->av_OCT_99p = av_OCT_99p
  fout_OCT->gdd_OCT_99p_rmse = gdd_OCT_99p_rmse
  fout_OCT->rcm_OCT_99p_rmse = rcm_OCT_99p_rmse
  fout_OCT->obs_OCT_99p_variance = obs_OCT_99p_variance
  fout_OCT->obs_OCT_99p = obs_OCT_99p
  fout_OCT->gdd_hist_OCT_99p = gdd_hist_OCT_99p
  fout_OCT->rcm_hist_OCT_99p = rcm_hist_OCT_99p
  fout_OCT->av_OCT_01p = av_OCT_01p
  fout_OCT->gdd_OCT_01p_rmse = gdd_OCT_01p_rmse
  fout_OCT->rcm_OCT_01p_rmse = rcm_OCT_01p_rmse
  fout_OCT->obs_OCT_01p_variance = obs_OCT_01p_variance
  fout_OCT->obs_OCT_01p = obs_OCT_01p
  fout_OCT->gdd_hist_OCT_01p = gdd_hist_OCT_01p
  fout_OCT->rcm_hist_OCT_01p = rcm_hist_OCT_01p

  delete(fout_OCT)

; NOV
  print(systemfunc("date"))
  print("NOV")
  rcm_NOV_avg_rmse = rcm_hist_NOV_avg
  rcm_NOV_avg_rmse = sqrt((rcm_hist_NOV_avg - obs_NOV_avg)^2)
  rcm_NOV_var_rmse = rcm_hist_NOV_var
  rcm_NOV_var_rmse = sqrt((rcm_hist_NOV_var - obs_NOV_var)^2)
  rcm_NOV_99p_rmse = rcm_hist_NOV_99p
  rcm_NOV_99p_rmse = sqrt((rcm_hist_NOV_99p - obs_NOV_99p)^2)
  rcm_NOV_01p_rmse = rcm_hist_NOV_01p
  rcm_NOV_01p_rmse = sqrt((rcm_hist_NOV_01p - obs_NOV_01p)^2)

  gdd_NOV_avg_rmse = gdd_hist_NOV_avg
  gdd_NOV_avg_rmse = sqrt((gdd_hist_NOV_avg - obs_NOV_avg)^2)
  gdd_NOV_var_rmse = gdd_hist_NOV_var
  gdd_NOV_var_rmse = sqrt((gdd_hist_NOV_var - obs_NOV_var)^2)
  gdd_NOV_99p_rmse = gdd_hist_NOV_99p
  gdd_NOV_99p_rmse = sqrt((gdd_hist_NOV_99p - obs_NOV_99p)^2)
  gdd_NOV_01p_rmse = gdd_hist_NOV_01p
  gdd_NOV_01p_rmse = sqrt((gdd_hist_NOV_01p - obs_NOV_01p)^2)

  av_NOV_avg = gdd_NOV_avg_rmse
  av_NOV_avg = gdd_NOV_avg_rmse - rcm_NOV_avg_rmse
  av_NOV_var = gdd_NOV_var_rmse
  av_NOV_var = gdd_NOV_var_rmse - rcm_NOV_var_rmse
  av_NOV_99p = gdd_NOV_99p_rmse
  av_NOV_99p = gdd_NOV_99p_rmse - rcm_NOV_99p_rmse
  av_NOV_01p = gdd_NOV_01p_rmse
  av_NOV_01p = gdd_NOV_01p_rmse - rcm_NOV_01p_rmse

  obs_NOV_avg_variance = dim_variance_n_Wrap(obs_NOV_avg_yearly, 0)
  obs_NOV_var_variance = dim_variance_n_Wrap(obs_NOV_var_yearly, 0)
  obs_NOV_99p_variance = dim_variance_n_Wrap(obs_NOV_99p_yearly, 0)
  obs_NOV_01p_variance = dim_variance_n_Wrap(obs_NOV_01p_yearly, 0)

  delete([/obs_NOV_avg_yearly, obs_NOV_var_yearly, obs_NOV_99p_yearly, obs_NOV_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_NOV_avg_variance_mask = obs_NOV_avg_variance
  obs_NOV_avg_variance_mask = where(obs_NOV_avg_variance_mask.eq.0, obs_NOV_avg_variance_mask@_FillValue, obs_NOV_avg_variance_mask)
  delete(obs_NOV_avg_variance)
  obs_NOV_avg_variance = obs_NOV_avg_variance_mask
  delete(obs_NOV_avg_variance_mask)
  obs_NOV_var_variance_mask = obs_NOV_var_variance
  obs_NOV_var_variance_mask = where(obs_NOV_var_variance_mask.eq.0, obs_NOV_var_variance_mask@_FillValue, obs_NOV_var_variance_mask)
  delete(obs_NOV_var_variance)
  obs_NOV_var_variance = obs_NOV_var_variance_mask
  delete(obs_NOV_var_variance_mask)
  obs_NOV_99p_variance_mask = obs_NOV_99p_variance
  obs_NOV_99p_variance_mask = where(obs_NOV_99p_variance_mask.eq.0, obs_NOV_99p_variance_mask@_FillValue, obs_NOV_99p_variance_mask)
  delete(obs_NOV_99p_variance)
  obs_NOV_99p_variance = obs_NOV_99p_variance_mask
  delete(obs_NOV_99p_variance_mask)
  obs_NOV_01p_variance_mask = obs_NOV_01p_variance
  obs_NOV_01p_variance_mask = where(obs_NOV_01p_variance_mask.eq.0, obs_NOV_01p_variance_mask@_FillValue, obs_NOV_01p_variance_mask)
  delete(obs_NOV_01p_variance)
  obs_NOV_01p_variance = obs_NOV_01p_variance_mask
  delete(obs_NOV_01p_variance_mask)


  fout_NOV = addfile(fout_name_NOV, "c")
  fout_NOV->av_NOV_avg = av_NOV_avg
  fout_NOV->gdd_NOV_avg_rmse = gdd_NOV_avg_rmse
  fout_NOV->rcm_NOV_avg_rmse = rcm_NOV_avg_rmse
  fout_NOV->obs_NOV_avg_variance = obs_NOV_avg_variance
  fout_NOV->obs_NOV_avg = obs_NOV_avg
  fout_NOV->gdd_hist_NOV_avg = gdd_hist_NOV_avg
  fout_NOV->rcm_hist_NOV_avg = rcm_hist_NOV_avg
  fout_NOV->av_NOV_var = av_NOV_var
  fout_NOV->gdd_NOV_var_rmse = gdd_NOV_var_rmse
  fout_NOV->rcm_NOV_var_rmse = rcm_NOV_var_rmse
  fout_NOV->obs_NOV_var_variance = obs_NOV_var_variance
  fout_NOV->obs_NOV_var = obs_NOV_var
  fout_NOV->gdd_hist_NOV_var = gdd_hist_NOV_var
  fout_NOV->rcm_hist_NOV_var = rcm_hist_NOV_var
  fout_NOV->av_NOV_99p = av_NOV_99p
  fout_NOV->gdd_NOV_99p_rmse = gdd_NOV_99p_rmse
  fout_NOV->rcm_NOV_99p_rmse = rcm_NOV_99p_rmse
  fout_NOV->obs_NOV_99p_variance = obs_NOV_99p_variance
  fout_NOV->obs_NOV_99p = obs_NOV_99p
  fout_NOV->gdd_hist_NOV_99p = gdd_hist_NOV_99p
  fout_NOV->rcm_hist_NOV_99p = rcm_hist_NOV_99p
  fout_NOV->av_NOV_01p = av_NOV_01p
  fout_NOV->gdd_NOV_01p_rmse = gdd_NOV_01p_rmse
  fout_NOV->rcm_NOV_01p_rmse = rcm_NOV_01p_rmse
  fout_NOV->obs_NOV_01p_variance = obs_NOV_01p_variance
  fout_NOV->obs_NOV_01p = obs_NOV_01p
  fout_NOV->gdd_hist_NOV_01p = gdd_hist_NOV_01p
  fout_NOV->rcm_hist_NOV_01p = rcm_hist_NOV_01p

  delete(fout_NOV)

; DEC
  print(systemfunc("date"))
  print("DEC")
  rcm_DEC_avg_rmse = rcm_hist_DEC_avg
  rcm_DEC_avg_rmse = sqrt((rcm_hist_DEC_avg - obs_DEC_avg)^2)
  rcm_DEC_var_rmse = rcm_hist_DEC_var
  rcm_DEC_var_rmse = sqrt((rcm_hist_DEC_var - obs_DEC_var)^2)
  rcm_DEC_99p_rmse = rcm_hist_DEC_99p
  rcm_DEC_99p_rmse = sqrt((rcm_hist_DEC_99p - obs_DEC_99p)^2)
  rcm_DEC_01p_rmse = rcm_hist_DEC_01p
  rcm_DEC_01p_rmse = sqrt((rcm_hist_DEC_01p - obs_DEC_01p)^2)

  gdd_DEC_avg_rmse = gdd_hist_DEC_avg
  gdd_DEC_avg_rmse = sqrt((gdd_hist_DEC_avg - obs_DEC_avg)^2)
  gdd_DEC_var_rmse = gdd_hist_DEC_var
  gdd_DEC_var_rmse = sqrt((gdd_hist_DEC_var - obs_DEC_var)^2)
  gdd_DEC_99p_rmse = gdd_hist_DEC_99p
  gdd_DEC_99p_rmse = sqrt((gdd_hist_DEC_99p - obs_DEC_99p)^2)
  gdd_DEC_01p_rmse = gdd_hist_DEC_01p
  gdd_DEC_01p_rmse = sqrt((gdd_hist_DEC_01p - obs_DEC_01p)^2)

  av_DEC_avg = gdd_DEC_avg_rmse
  av_DEC_avg = gdd_DEC_avg_rmse - rcm_DEC_avg_rmse
  av_DEC_var = gdd_DEC_var_rmse
  av_DEC_var = gdd_DEC_var_rmse - rcm_DEC_var_rmse
  av_DEC_99p = gdd_DEC_99p_rmse
  av_DEC_99p = gdd_DEC_99p_rmse - rcm_DEC_99p_rmse
  av_DEC_01p = gdd_DEC_01p_rmse
  av_DEC_01p = gdd_DEC_01p_rmse - rcm_DEC_01p_rmse

  obs_DEC_avg_variance = dim_variance_n_Wrap(obs_DEC_avg_yearly, 0)
  obs_DEC_var_variance = dim_variance_n_Wrap(obs_DEC_var_yearly, 0)
  obs_DEC_99p_variance = dim_variance_n_Wrap(obs_DEC_99p_yearly, 0)
  obs_DEC_01p_variance = dim_variance_n_Wrap(obs_DEC_01p_yearly, 0)

  delete([/obs_DEC_avg_yearly, obs_DEC_var_yearly, obs_DEC_99p_yearly, obs_DEC_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_DEC_avg_variance_mask = obs_DEC_avg_variance
  obs_DEC_avg_variance_mask = where(obs_DEC_avg_variance_mask.eq.0, obs_DEC_avg_variance_mask@_FillValue, obs_DEC_avg_variance_mask)
  delete(obs_DEC_avg_variance)
  obs_DEC_avg_variance = obs_DEC_avg_variance_mask
  delete(obs_DEC_avg_variance_mask)
  obs_DEC_var_variance_mask = obs_DEC_var_variance
  obs_DEC_var_variance_mask = where(obs_DEC_var_variance_mask.eq.0, obs_DEC_var_variance_mask@_FillValue, obs_DEC_var_variance_mask)
  delete(obs_DEC_var_variance)
  obs_DEC_var_variance = obs_DEC_var_variance_mask
  delete(obs_DEC_var_variance_mask)
  obs_DEC_99p_variance_mask = obs_DEC_99p_variance
  obs_DEC_99p_variance_mask = where(obs_DEC_99p_variance_mask.eq.0, obs_DEC_99p_variance_mask@_FillValue, obs_DEC_99p_variance_mask)
  delete(obs_DEC_99p_variance)
  obs_DEC_99p_variance = obs_DEC_99p_variance_mask
  delete(obs_DEC_99p_variance_mask)
  obs_DEC_01p_variance_mask = obs_DEC_01p_variance
  obs_DEC_01p_variance_mask = where(obs_DEC_01p_variance_mask.eq.0, obs_DEC_01p_variance_mask@_FillValue, obs_DEC_01p_variance_mask)
  delete(obs_DEC_01p_variance)
  obs_DEC_01p_variance = obs_DEC_01p_variance_mask
  delete(obs_DEC_01p_variance_mask)

  fout_DEC = addfile(fout_name_DEC, "c")
  fout_DEC->av_DEC_avg = av_DEC_avg
  fout_DEC->gdd_DEC_avg_rmse = gdd_DEC_avg_rmse
  fout_DEC->rcm_DEC_avg_rmse = rcm_DEC_avg_rmse
  fout_DEC->obs_DEC_avg_variance = obs_DEC_avg_variance
  fout_DEC->obs_DEC_avg = obs_DEC_avg
  fout_DEC->gdd_hist_DEC_avg = gdd_hist_DEC_avg
  fout_DEC->rcm_hist_DEC_avg = rcm_hist_DEC_avg
  fout_DEC->av_DEC_var = av_DEC_var
  fout_DEC->gdd_DEC_var_rmse = gdd_DEC_var_rmse
  fout_DEC->rcm_DEC_var_rmse = rcm_DEC_var_rmse
  fout_DEC->obs_DEC_var_variance = obs_DEC_var_variance
  fout_DEC->obs_DEC_var = obs_DEC_var
  fout_DEC->gdd_hist_DEC_var = gdd_hist_DEC_var
  fout_DEC->rcm_hist_DEC_var = rcm_hist_DEC_var
  fout_DEC->av_DEC_99p = av_DEC_99p
  fout_DEC->gdd_DEC_99p_rmse = gdd_DEC_99p_rmse
  fout_DEC->rcm_DEC_99p_rmse = rcm_DEC_99p_rmse
  fout_DEC->obs_DEC_99p_variance = obs_DEC_99p_variance
  fout_DEC->obs_DEC_99p = obs_DEC_99p
  fout_DEC->gdd_hist_DEC_99p = gdd_hist_DEC_99p
  fout_DEC->rcm_hist_DEC_99p = rcm_hist_DEC_99p
  fout_DEC->av_DEC_01p = av_DEC_01p
  fout_DEC->gdd_DEC_01p_rmse = gdd_DEC_01p_rmse
  fout_DEC->rcm_DEC_01p_rmse = rcm_DEC_01p_rmse
  fout_DEC->obs_DEC_01p_variance = obs_DEC_01p_variance
  fout_DEC->obs_DEC_01p = obs_DEC_01p
  fout_DEC->gdd_hist_DEC_01p = gdd_hist_DEC_01p
  fout_DEC->rcm_hist_DEC_01p = rcm_hist_DEC_01p

  delete(fout_DEC)

;******************************
; DEC Shifted data
;******************************
  print(systemfunc("date"))
  print("Starting shifted data calculation")

;******************************
;******************************
  print(systemfunc("date"))
  print("Starting seasonal statistics calculation")

; seasonal stats
  hist_date_sel = cd_calendar(rcm_hist&time, 0)
  hist_date_mth = hist_date_sel(:,1)
  delete(hist_date_sel)
  hist_date_DJF = ind(hist_date_mth.eq.1.or.hist_date_mth.eq.2.or.hist_date_mth.eq.12)
  hist_date_MAM = ind(hist_date_mth.eq.3.or.hist_date_mth.eq.4.or.hist_date_mth.eq.5)
  hist_date_JJA = ind(hist_date_mth.eq.6.or.hist_date_mth.eq.7.or.hist_date_mth.eq.8)
  hist_date_SON = ind(hist_date_mth.eq.9.or.hist_date_mth.eq.10.or.hist_date_mth.eq.11)
  delete(hist_date_mth)


  rcm_hist_DJF = rcm_hist(hist_date_DJF,:,:) ; no need to use dec shifted data here because we're calculating over all DJF points
  rcm_hist_DJF_avg = dim_avg_n_Wrap(rcm_hist_DJF, 0)
  rcm_hist_DJF_var = dim_variance_n_Wrap(rcm_hist_DJF, 0)
  rcm_hist_DJF_99p = percent_to_value_2d(rcm_hist_DJF, 99)
  rcm_hist_DJF_01p = percent_to_value_2d(rcm_hist_DJF, 1)
  delete(rcm_hist_DJF)

  rcm_hist_MAM = rcm_hist(hist_date_MAM,:,:)
  rcm_hist_MAM_avg = dim_avg_n_Wrap(rcm_hist_MAM, 0)
  rcm_hist_MAM_var = dim_variance_n_Wrap(rcm_hist_MAM, 0)
  rcm_hist_MAM_99p = percent_to_value_2d(rcm_hist_MAM, 99)
  rcm_hist_MAM_01p = percent_to_value_2d(rcm_hist_MAM, 1)
  delete(rcm_hist_MAM)

  rcm_hist_JJA = rcm_hist(hist_date_JJA,:,:)
  rcm_hist_JJA_avg = dim_avg_n_Wrap(rcm_hist_JJA, 0)
  rcm_hist_JJA_var = dim_variance_n_Wrap(rcm_hist_JJA, 0)
  rcm_hist_JJA_99p = percent_to_value_2d(rcm_hist_JJA, 99)
  rcm_hist_JJA_01p = percent_to_value_2d(rcm_hist_JJA, 1)
  delete(rcm_hist_JJA)

  rcm_hist_SON = rcm_hist(hist_date_SON,:,:)
  rcm_hist_SON_avg = dim_avg_n_Wrap(rcm_hist_SON, 0)
  rcm_hist_SON_var = dim_variance_n_Wrap(rcm_hist_SON, 0)
  rcm_hist_SON_99p = percent_to_value_2d(rcm_hist_SON, 99)
  rcm_hist_SON_01p = percent_to_value_2d(rcm_hist_SON, 1)
  delete(rcm_hist_SON)
  delete(rcm_hist)

  gdd_hist_DJF = gdd_hist(hist_date_DJF,:,:)
  gdd_hist_DJF_avg = dim_avg_n_Wrap(gdd_hist_DJF, 0)
  gdd_hist_DJF_var = dim_variance_n_Wrap(gdd_hist_DJF, 0)
  gdd_hist_DJF_99p = percent_to_value_2d(gdd_hist_DJF, 99)
  gdd_hist_DJF_01p = percent_to_value_2d(gdd_hist_DJF, 1)
  delete(gdd_hist_DJF)

  gdd_hist_MAM = gdd_hist(hist_date_MAM,:,:)
  gdd_hist_MAM_avg = dim_avg_n_Wrap(gdd_hist_MAM, 0)
  gdd_hist_MAM_var = dim_variance_n_Wrap(gdd_hist_MAM, 0)
  gdd_hist_MAM_99p = percent_to_value_2d(gdd_hist_MAM, 99)
  gdd_hist_MAM_01p = percent_to_value_2d(gdd_hist_MAM, 1)
  delete(gdd_hist_MAM)
  
  gdd_hist_JJA = gdd_hist(hist_date_JJA,:,:)
  gdd_hist_JJA_avg = dim_avg_n_Wrap(gdd_hist_JJA, 0)
  gdd_hist_JJA_var = dim_variance_n_Wrap(gdd_hist_JJA, 0)
  gdd_hist_JJA_99p = percent_to_value_2d(gdd_hist_JJA, 99)
  gdd_hist_JJA_01p = percent_to_value_2d(gdd_hist_JJA, 1)
  delete(gdd_hist_JJA)
  
  gdd_hist_SON = gdd_hist(hist_date_SON,:,:)
  gdd_hist_SON_avg = dim_avg_n_Wrap(gdd_hist_SON, 0)
  gdd_hist_SON_var = dim_variance_n_Wrap(gdd_hist_SON, 0)
  gdd_hist_SON_99p = percent_to_value_2d(gdd_hist_SON, 99)
  gdd_hist_SON_01p = percent_to_value_2d(gdd_hist_SON, 1)
  delete(gdd_hist_SON)
  delete(gdd_hist)





  obs_DJF = obs(hist_date_DJF,:,:)
  obs_DJF_avg = dim_avg_n_Wrap(obs_DJF, 0)
  obs_DJF_var = dim_variance_n_Wrap(obs_DJF, 0)
  obs_DJF_99p = percent_to_value_2d(obs_DJF, 99)
  obs_DJF_01p = percent_to_value_2d(obs_DJF, 1)
  delete(obs_DJF)

  obs_MAM = obs(hist_date_MAM,:,:)
  obs_MAM_avg = dim_avg_n_Wrap(obs_MAM, 0)
  obs_MAM_var = dim_variance_n_Wrap(obs_MAM, 0)
  obs_MAM_99p = percent_to_value_2d(obs_MAM, 99)
  obs_MAM_01p = percent_to_value_2d(obs_MAM, 1)
  delete(obs_MAM)

  obs_JJA = obs(hist_date_JJA,:,:)
  obs_JJA_avg = dim_avg_n_Wrap(obs_JJA, 0)
  obs_JJA_var = dim_variance_n_Wrap(obs_JJA, 0)
  obs_JJA_99p = percent_to_value_2d(obs_JJA, 99)
  obs_JJA_01p = percent_to_value_2d(obs_JJA, 1)
  delete(obs_JJA)

  obs_SON = obs(hist_date_SON,:,:)
  obs_SON_avg = dim_avg_n_Wrap(obs_SON, 0)
  obs_SON_var = dim_variance_n_Wrap(obs_SON, 0)
  obs_SON_99p = percent_to_value_2d(obs_SON, 99)
  obs_SON_01p = percent_to_value_2d(obs_SON, 1)
  delete(obs_SON)

  delete([/hist_date_DJF, hist_date_MAM, hist_date_JJA, hist_date_SON/])

; shift December months a year forward for DJF calculation. e.g., Dec86 becomes Dec87 so DJF87 is actually Dec86, JF87
  opt = 0
  opt@return_type = "float"
  hist_date_all = cd_calendar(obs&time, 0)
  hist_date_new = hist_date_all
  hist_date_new(:,0) = where(hist_date_all(:,1).eq.12, hist_date_new(:,0)+1, hist_date_new(:,0))
  delete(hist_date_all)
  hist_time_new = cd_inv_calendar(hist_date_new(:,0), hist_date_new(:,1), hist_date_new(:,2), hist_date_new(:,3), hist_date_new(:,4), hist_date_new(:,5), obs&time@units, opt)
  delete(hist_date_new)

  ; only need to shift obs for inter-annual calculation
  obs_dec_shifted = obs
  delete(obs)

  obs_dec_shifted&time = hist_time_new
  delete(hist_time_new)

  asciiwrite("obs_all_months_new_time", obs_dec_shifted(:,{-37.5},{145}))

  hist_date = cd_calendar(obs_dec_shifted&time, -2)
  hist_year = hist_date/10000
  hist_years = ispan(min(hist_year), max(hist_year)-1, 1) ; subract 1 from max because shifting last Dec moves it the year after
  delete(hist_date)

  lat = obs_dec_shifted&lat
  lon = obs_dec_shifted&lon
  nlat = dimsizes(lat)
  nlon = dimsizes(lon)

; create new arrays for statistics
  obs_DJF_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_DJF_avg_yearly!0 = "year"
  obs_DJF_avg_yearly!1 = "lat"
  obs_DJF_avg_yearly!2 = "lon"
  obs_DJF_avg_yearly&year = hist_years
  obs_DJF_avg_yearly&lat = lat
  obs_DJF_avg_yearly&lon = lon
  obs_DJF_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_DJF_var_yearly!0 = "year"
  obs_DJF_var_yearly!1 = "lat"
  obs_DJF_var_yearly!2 = "lon"
  obs_DJF_var_yearly&year = hist_years
  obs_DJF_var_yearly&lat = lat
  obs_DJF_var_yearly&lon = lon
  obs_DJF_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_DJF_99p_yearly!0 = "year"
  obs_DJF_99p_yearly!1 = "lat"
  obs_DJF_99p_yearly!2 = "lon"
  obs_DJF_99p_yearly&year = hist_years
  obs_DJF_99p_yearly&lat = lat
  obs_DJF_99p_yearly&lon = lon
  obs_DJF_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_DJF_01p_yearly!0 = "year"
  obs_DJF_01p_yearly!1 = "lat"
  obs_DJF_01p_yearly!2 = "lon"
  obs_DJF_01p_yearly&year = hist_years
  obs_DJF_01p_yearly&lat = lat
  obs_DJF_01p_yearly&lon = lon

  obs_MAM_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_MAM_avg_yearly!0 = "year"
  obs_MAM_avg_yearly!1 = "lat"
  obs_MAM_avg_yearly!2 = "lon"
  obs_MAM_avg_yearly&year = hist_years
  obs_MAM_avg_yearly&lat = lat
  obs_MAM_avg_yearly&lon = lon
  obs_MAM_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_MAM_var_yearly!0 = "year"
  obs_MAM_var_yearly!1 = "lat"
  obs_MAM_var_yearly!2 = "lon"
  obs_MAM_var_yearly&year = hist_years
  obs_MAM_var_yearly&lat = lat
  obs_MAM_var_yearly&lon = lon
  obs_MAM_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_MAM_99p_yearly!0 = "year"
  obs_MAM_99p_yearly!1 = "lat"
  obs_MAM_99p_yearly!2 = "lon"
  obs_MAM_99p_yearly&year = hist_years
  obs_MAM_99p_yearly&lat = lat
  obs_MAM_99p_yearly&lon = lon
  obs_MAM_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_MAM_01p_yearly!0 = "year"
  obs_MAM_01p_yearly!1 = "lat"
  obs_MAM_01p_yearly!2 = "lon"
  obs_MAM_01p_yearly&year = hist_years
  obs_MAM_01p_yearly&lat = lat
  obs_MAM_01p_yearly&lon = lon

  obs_JJA_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_JJA_avg_yearly!0 = "year"
  obs_JJA_avg_yearly!1 = "lat"
  obs_JJA_avg_yearly!2 = "lon"
  obs_JJA_avg_yearly&year = hist_years
  obs_JJA_avg_yearly&lat = lat
  obs_JJA_avg_yearly&lon = lon
  obs_JJA_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_JJA_var_yearly!0 = "year"
  obs_JJA_var_yearly!1 = "lat"
  obs_JJA_var_yearly!2 = "lon"
  obs_JJA_var_yearly&year = hist_years
  obs_JJA_var_yearly&lat = lat
  obs_JJA_var_yearly&lon = lon
  obs_JJA_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_JJA_99p_yearly!0 = "year"
  obs_JJA_99p_yearly!1 = "lat"
  obs_JJA_99p_yearly!2 = "lon"
  obs_JJA_99p_yearly&year = hist_years
  obs_JJA_99p_yearly&lat = lat
  obs_JJA_99p_yearly&lon = lon
  obs_JJA_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_JJA_01p_yearly!0 = "year"
  obs_JJA_01p_yearly!1 = "lat"
  obs_JJA_01p_yearly!2 = "lon"
  obs_JJA_01p_yearly&year = hist_years
  obs_JJA_01p_yearly&lat = lat
  obs_JJA_01p_yearly&lon = lon

  obs_SON_avg_yearly = new((/window, nlat, nlon/), float) ; average
  obs_SON_avg_yearly!0 = "year"
  obs_SON_avg_yearly!1 = "lat"
  obs_SON_avg_yearly!2 = "lon"
  obs_SON_avg_yearly&year = hist_years
  obs_SON_avg_yearly&lat = lat
  obs_SON_avg_yearly&lon = lon
  obs_SON_var_yearly = new((/window, nlat, nlon/), float) ; variance
  obs_SON_var_yearly!0 = "year"
  obs_SON_var_yearly!1 = "lat"
  obs_SON_var_yearly!2 = "lon"
  obs_SON_var_yearly&year = hist_years
  obs_SON_var_yearly&lat = lat
  obs_SON_var_yearly&lon = lon
  obs_SON_99p_yearly = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_SON_99p_yearly!0 = "year"
  obs_SON_99p_yearly!1 = "lat"
  obs_SON_99p_yearly!2 = "lon"
  obs_SON_99p_yearly&year = hist_years
  obs_SON_99p_yearly&lat = lat
  obs_SON_99p_yearly&lon = lon
  obs_SON_01p_yearly = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_SON_01p_yearly!0 = "year"
  obs_SON_01p_yearly!1 = "lat"
  obs_SON_01p_yearly!2 = "lon"
  obs_SON_01p_yearly&year = hist_years
  obs_SON_01p_yearly&lat = lat
  obs_SON_01p_yearly&lon = lon

  delete(nlat)
  delete(nlon)
  
;******************************
; loop over years using shifted data
;******************************
  print(systemfunc("date"))
  print("Looping over years (shifted)")
  do nyrc=0, window-1
    print(nyrc)
    print(systemfunc("date"))
    ; hist_yrs is the individual year selected in the loop e.g., 1986, 1987, 1988 etc.
    hist_yrs = min(hist_year)+nyrc ; hist_year is array of years (e.g., 1986*365, 1987*365 ... 2006*31).
    hist_yr_sel = ind(hist_year.eq.hist_yrs)

    obs_temp = obs_dec_shifted(hist_yr_sel,:,:)

; select seasons. December has been shifted to be the same year as JF
    hist_date_sel = cd_calendar(obs_temp&time, 0)
    hist_date_mth = hist_date_sel(:,1)

    hist_date_DJF = ind(hist_date_mth.eq.1.or.hist_date_mth.eq.2.or.hist_date_mth.eq.12)
    hist_date_MAM = ind(hist_date_mth.eq.3.or.hist_date_mth.eq.4.or.hist_date_mth.eq.5)
    hist_date_JJA = ind(hist_date_mth.eq.6.or.hist_date_mth.eq.7.or.hist_date_mth.eq.8)
    hist_date_SON = ind(hist_date_mth.eq.9.or.hist_date_mth.eq.10.or.hist_date_mth.eq.11)

    obs_temp_DJF = obs_temp(hist_date_DJF,:,:)
    obs_temp_MAM = obs_temp(hist_date_MAM,:,:)
    obs_temp_JJA = obs_temp(hist_date_JJA,:,:)
    obs_temp_SON = obs_temp(hist_date_SON,:,:)
    delete(obs_temp)

    obs_temp_DJF_avg = dim_avg_n_Wrap(obs_temp_DJF, 0)
    obs_temp_DJF_var = dim_variance_n_Wrap(obs_temp_DJF, 0)
    obs_temp_DJF_99p = percent_to_value_2d(obs_temp_DJF, 99)
    obs_temp_DJF_01p = percent_to_value_2d(obs_temp_DJF, 1)
    obs_temp_MAM_avg = dim_avg_n_Wrap(obs_temp_MAM, 0)
    obs_temp_MAM_var = dim_variance_n_Wrap(obs_temp_MAM, 0)
    obs_temp_MAM_99p = percent_to_value_2d(obs_temp_MAM, 99)
    obs_temp_MAM_01p = percent_to_value_2d(obs_temp_MAM, 1)
    obs_temp_JJA_avg = dim_avg_n_Wrap(obs_temp_JJA, 0)
    obs_temp_JJA_var = dim_variance_n_Wrap(obs_temp_JJA, 0)
    obs_temp_JJA_99p = percent_to_value_2d(obs_temp_JJA, 99)
    obs_temp_JJA_01p = percent_to_value_2d(obs_temp_JJA, 1)
    obs_temp_SON_avg = dim_avg_n_Wrap(obs_temp_SON, 0)
    obs_temp_SON_var = dim_variance_n_Wrap(obs_temp_SON, 0)
    obs_temp_SON_99p = percent_to_value_2d(obs_temp_SON, 99)
    obs_temp_SON_01p = percent_to_value_2d(obs_temp_SON, 1)

    obs_DJF_avg_yearly(nyrc,:,:) = (/obs_temp_DJF_avg/)
    obs_DJF_var_yearly(nyrc,:,:) = (/obs_temp_DJF_var/)
    obs_DJF_99p_yearly(nyrc,:,:) = (/obs_temp_DJF_99p/)
    obs_DJF_01p_yearly(nyrc,:,:) = (/obs_temp_DJF_01p/)
    obs_MAM_avg_yearly(nyrc,:,:) = (/obs_temp_MAM_avg/)
    obs_MAM_var_yearly(nyrc,:,:) = (/obs_temp_MAM_var/)
    obs_MAM_99p_yearly(nyrc,:,:) = (/obs_temp_MAM_99p/)
    obs_MAM_01p_yearly(nyrc,:,:) = (/obs_temp_MAM_01p/)
    obs_JJA_avg_yearly(nyrc,:,:) = (/obs_temp_JJA_avg/)
    obs_JJA_var_yearly(nyrc,:,:) = (/obs_temp_JJA_var/)
    obs_JJA_99p_yearly(nyrc,:,:) = (/obs_temp_JJA_99p/)
    obs_JJA_01p_yearly(nyrc,:,:) = (/obs_temp_JJA_01p/)
    obs_SON_avg_yearly(nyrc,:,:) = (/obs_temp_SON_avg/)
    obs_SON_var_yearly(nyrc,:,:) = (/obs_temp_SON_var/)
    obs_SON_99p_yearly(nyrc,:,:) = (/obs_temp_SON_99p/)
    obs_SON_01p_yearly(nyrc,:,:) = (/obs_temp_SON_01p/)

; delete
    delete([/hist_date_sel, hist_yr_sel, hist_date_mth, hist_date_DJF, hist_date_MAM, hist_date_JJA, hist_date_SON/])
    delete([/obs_temp_DJF, obs_temp_DJF_avg, obs_temp_DJF_var, obs_temp_DJF_99p, obs_temp_DJF_01p/])
    delete([/obs_temp_MAM, obs_temp_MAM_avg, obs_temp_MAM_var, obs_temp_MAM_99p, obs_temp_MAM_01p/])
    delete([/obs_temp_JJA, obs_temp_JJA_avg, obs_temp_JJA_var, obs_temp_JJA_99p, obs_temp_JJA_01p/])
    delete([/obs_temp_SON, obs_temp_SON_avg, obs_temp_SON_var, obs_temp_SON_99p, obs_temp_SON_01p/])
  end do

  delete(obs_dec_shifted)
  delete(hist_year)

;******************************
;******************************
  print(systemfunc("date"))

; DJF
  print(systemfunc("date"))
  print("DJF")
  rcm_DJF_avg_rmse = rcm_hist_DJF_avg
  rcm_DJF_avg_rmse = sqrt((rcm_hist_DJF_avg - obs_DJF_avg)^2)
  rcm_DJF_var_rmse = rcm_hist_DJF_var
  rcm_DJF_var_rmse = sqrt((rcm_hist_DJF_var - obs_DJF_var)^2)
  rcm_DJF_99p_rmse = rcm_hist_DJF_99p
  rcm_DJF_99p_rmse = sqrt((rcm_hist_DJF_99p - obs_DJF_99p)^2)
  rcm_DJF_01p_rmse = rcm_hist_DJF_01p
  rcm_DJF_01p_rmse = sqrt((rcm_hist_DJF_01p - obs_DJF_01p)^2)

  gdd_DJF_avg_rmse = gdd_hist_DJF_avg
  gdd_DJF_avg_rmse = sqrt((gdd_hist_DJF_avg - obs_DJF_avg)^2)
  gdd_DJF_var_rmse = gdd_hist_DJF_var
  gdd_DJF_var_rmse = sqrt((gdd_hist_DJF_var - obs_DJF_var)^2)
  gdd_DJF_99p_rmse = gdd_hist_DJF_99p
  gdd_DJF_99p_rmse = sqrt((gdd_hist_DJF_99p - obs_DJF_99p)^2)
  gdd_DJF_01p_rmse = gdd_hist_DJF_01p
  gdd_DJF_01p_rmse = sqrt((gdd_hist_DJF_01p - obs_DJF_01p)^2)

  av_DJF_avg = gdd_DJF_avg_rmse
  av_DJF_avg = gdd_DJF_avg_rmse - rcm_DJF_avg_rmse
  av_DJF_var = gdd_DJF_var_rmse
  av_DJF_var = gdd_DJF_var_rmse - rcm_DJF_var_rmse
  av_DJF_99p = gdd_DJF_99p_rmse
  av_DJF_99p = gdd_DJF_99p_rmse - rcm_DJF_99p_rmse
  av_DJF_01p = gdd_DJF_01p_rmse
  av_DJF_01p = gdd_DJF_01p_rmse - rcm_DJF_01p_rmse

  obs_DJF_avg_variance = dim_variance_n_Wrap(obs_DJF_avg_yearly, 0)
  obs_DJF_var_variance = dim_variance_n_Wrap(obs_DJF_var_yearly, 0)
  obs_DJF_99p_variance = dim_variance_n_Wrap(obs_DJF_99p_yearly, 0)
  obs_DJF_01p_variance = dim_variance_n_Wrap(obs_DJF_01p_yearly, 0)

  delete([/obs_DJF_avg_yearly, obs_DJF_var_yearly, obs_DJF_99p_yearly, obs_DJF_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_DJF_avg_variance_mask = obs_DJF_avg_variance
  obs_DJF_avg_variance_mask = where(obs_DJF_avg_variance_mask.eq.0, obs_DJF_avg_variance_mask@_FillValue, obs_DJF_avg_variance_mask)
  delete(obs_DJF_avg_variance)
  obs_DJF_avg_variance = obs_DJF_avg_variance_mask
  delete(obs_DJF_avg_variance_mask)
  obs_DJF_var_variance_mask = obs_DJF_var_variance
  obs_DJF_var_variance_mask = where(obs_DJF_var_variance_mask.eq.0, obs_DJF_var_variance_mask@_FillValue, obs_DJF_var_variance_mask)
  delete(obs_DJF_var_variance)
  obs_DJF_var_variance = obs_DJF_var_variance_mask
  delete(obs_DJF_var_variance_mask)
  obs_DJF_99p_variance_mask = obs_DJF_99p_variance
  obs_DJF_99p_variance_mask = where(obs_DJF_99p_variance_mask.eq.0, obs_DJF_99p_variance_mask@_FillValue, obs_DJF_99p_variance_mask)
  delete(obs_DJF_99p_variance)
  obs_DJF_99p_variance = obs_DJF_99p_variance_mask
  delete(obs_DJF_99p_variance_mask)
  obs_DJF_01p_variance_mask = obs_DJF_01p_variance
  obs_DJF_01p_variance_mask = where(obs_DJF_01p_variance_mask.eq.0, obs_DJF_01p_variance_mask@_FillValue, obs_DJF_01p_variance_mask)
  delete(obs_DJF_01p_variance)
  obs_DJF_01p_variance = obs_DJF_01p_variance_mask
  delete(obs_DJF_01p_variance_mask)

  fout_DJF = addfile(fout_name_DJF, "c")
  fout_DJF->av_DJF_avg = av_DJF_avg
  fout_DJF->gdd_DJF_avg_rmse = gdd_DJF_avg_rmse
  fout_DJF->rcm_DJF_avg_rmse = rcm_DJF_avg_rmse
  fout_DJF->obs_DJF_avg_variance = obs_DJF_avg_variance
  fout_DJF->obs_DJF_avg = obs_DJF_avg
  fout_DJF->gdd_hist_DJF_avg = gdd_hist_DJF_avg
  fout_DJF->rcm_hist_DJF_avg = rcm_hist_DJF_avg
  fout_DJF->av_DJF_var = av_DJF_var
  fout_DJF->gdd_DJF_var_rmse = gdd_DJF_var_rmse
  fout_DJF->rcm_DJF_var_rmse = rcm_DJF_var_rmse
  fout_DJF->obs_DJF_var_variance = obs_DJF_var_variance
  fout_DJF->obs_DJF_var = obs_DJF_var
  fout_DJF->gdd_hist_DJF_var = gdd_hist_DJF_var
  fout_DJF->rcm_hist_DJF_var = rcm_hist_DJF_var
  fout_DJF->av_DJF_99p = av_DJF_99p
  fout_DJF->gdd_DJF_99p_rmse = gdd_DJF_99p_rmse
  fout_DJF->rcm_DJF_99p_rmse = rcm_DJF_99p_rmse
  fout_DJF->obs_DJF_99p_variance = obs_DJF_99p_variance
  fout_DJF->obs_DJF_99p = obs_DJF_99p
  fout_DJF->gdd_hist_DJF_99p = gdd_hist_DJF_99p
  fout_DJF->rcm_hist_DJF_99p = rcm_hist_DJF_99p
  fout_DJF->av_DJF_01p = av_DJF_01p
  fout_DJF->gdd_DJF_01p_rmse = gdd_DJF_01p_rmse
  fout_DJF->rcm_DJF_01p_rmse = rcm_DJF_01p_rmse
  fout_DJF->obs_DJF_01p_variance = obs_DJF_01p_variance
  fout_DJF->obs_DJF_01p = obs_DJF_01p
  fout_DJF->gdd_hist_DJF_01p = gdd_hist_DJF_01p
  fout_DJF->rcm_hist_DJF_01p = rcm_hist_DJF_01p

  delete(fout_DJF)

; MAM
  print(systemfunc("date"))
  print("MAM")
  rcm_MAM_avg_rmse = rcm_hist_MAM_avg
  rcm_MAM_avg_rmse = sqrt((rcm_hist_MAM_avg - obs_MAM_avg)^2)
  rcm_MAM_var_rmse = rcm_hist_MAM_var
  rcm_MAM_var_rmse = sqrt((rcm_hist_MAM_var - obs_MAM_var)^2)
  rcm_MAM_99p_rmse = rcm_hist_MAM_99p
  rcm_MAM_99p_rmse = sqrt((rcm_hist_MAM_99p - obs_MAM_99p)^2)
  rcm_MAM_01p_rmse = rcm_hist_MAM_01p
  rcm_MAM_01p_rmse = sqrt((rcm_hist_MAM_01p - obs_MAM_01p)^2)

  gdd_MAM_avg_rmse = gdd_hist_MAM_avg
  gdd_MAM_avg_rmse = sqrt((gdd_hist_MAM_avg - obs_MAM_avg)^2)
  gdd_MAM_var_rmse = gdd_hist_MAM_var
  gdd_MAM_var_rmse = sqrt((gdd_hist_MAM_var - obs_MAM_var)^2)
  gdd_MAM_99p_rmse = gdd_hist_MAM_99p
  gdd_MAM_99p_rmse = sqrt((gdd_hist_MAM_99p - obs_MAM_99p)^2)
  gdd_MAM_01p_rmse = gdd_hist_MAM_01p
  gdd_MAM_01p_rmse = sqrt((gdd_hist_MAM_01p - obs_MAM_01p)^2)

  av_MAM_avg = gdd_MAM_avg_rmse
  av_MAM_avg = gdd_MAM_avg_rmse - rcm_MAM_avg_rmse
  av_MAM_var = gdd_MAM_var_rmse
  av_MAM_var = gdd_MAM_var_rmse - rcm_MAM_var_rmse
  av_MAM_99p = gdd_MAM_99p_rmse
  av_MAM_99p = gdd_MAM_99p_rmse - rcm_MAM_99p_rmse
  av_MAM_01p = gdd_MAM_01p_rmse
  av_MAM_01p = gdd_MAM_01p_rmse - rcm_MAM_01p_rmse

  obs_MAM_avg_variance = dim_variance_n_Wrap(obs_MAM_avg_yearly, 0)
  obs_MAM_var_variance = dim_variance_n_Wrap(obs_MAM_var_yearly, 0)
  obs_MAM_99p_variance = dim_variance_n_Wrap(obs_MAM_99p_yearly, 0)
  obs_MAM_01p_variance = dim_variance_n_Wrap(obs_MAM_01p_yearly, 0)

  delete([/obs_MAM_avg_yearly, obs_MAM_var_yearly, obs_MAM_99p_yearly, obs_MAM_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_MAM_avg_variance_mask = obs_MAM_avg_variance
  obs_MAM_avg_variance_mask = where(obs_MAM_avg_variance_mask.eq.0, obs_MAM_avg_variance_mask@_FillValue, obs_MAM_avg_variance_mask)
  delete(obs_MAM_avg_variance)
  obs_MAM_avg_variance = obs_MAM_avg_variance_mask
  delete(obs_MAM_avg_variance_mask)
  obs_MAM_var_variance_mask = obs_MAM_var_variance
  obs_MAM_var_variance_mask = where(obs_MAM_var_variance_mask.eq.0, obs_MAM_var_variance_mask@_FillValue, obs_MAM_var_variance_mask)
  delete(obs_MAM_var_variance)
  obs_MAM_var_variance = obs_MAM_var_variance_mask
  delete(obs_MAM_var_variance_mask)
  obs_MAM_99p_variance_mask = obs_MAM_99p_variance
  obs_MAM_99p_variance_mask = where(obs_MAM_99p_variance_mask.eq.0, obs_MAM_99p_variance_mask@_FillValue, obs_MAM_99p_variance_mask)
  delete(obs_MAM_99p_variance)
  obs_MAM_99p_variance = obs_MAM_99p_variance_mask
  delete(obs_MAM_99p_variance_mask)
  obs_MAM_01p_variance_mask = obs_MAM_01p_variance
  obs_MAM_01p_variance_mask = where(obs_MAM_01p_variance_mask.eq.0, obs_MAM_01p_variance_mask@_FillValue, obs_MAM_01p_variance_mask)
  delete(obs_MAM_01p_variance)
  obs_MAM_01p_variance = obs_MAM_01p_variance_mask
  delete(obs_MAM_01p_variance_mask)

  fout_MAM = addfile(fout_name_MAM, "c")
  fout_MAM->av_MAM_avg = av_MAM_avg
  fout_MAM->gdd_MAM_avg_rmse = gdd_MAM_avg_rmse
  fout_MAM->rcm_MAM_avg_rmse = rcm_MAM_avg_rmse
  fout_MAM->obs_MAM_avg_variance = obs_MAM_avg_variance
  fout_MAM->obs_MAM_avg = obs_MAM_avg
  fout_MAM->gdd_hist_MAM_avg = gdd_hist_MAM_avg
  fout_MAM->rcm_hist_MAM_avg = rcm_hist_MAM_avg
  fout_MAM->av_MAM_var = av_MAM_var
  fout_MAM->gdd_MAM_var_rmse = gdd_MAM_var_rmse
  fout_MAM->rcm_MAM_var_rmse = rcm_MAM_var_rmse
  fout_MAM->obs_MAM_var_variance = obs_MAM_var_variance
  fout_MAM->obs_MAM_var = obs_MAM_var
  fout_MAM->gdd_hist_MAM_var = gdd_hist_MAM_var
  fout_MAM->rcm_hist_MAM_var = rcm_hist_MAM_var
  fout_MAM->av_MAM_99p = av_MAM_99p
  fout_MAM->gdd_MAM_99p_rmse = gdd_MAM_99p_rmse
  fout_MAM->rcm_MAM_99p_rmse = rcm_MAM_99p_rmse
  fout_MAM->obs_MAM_99p_variance = obs_MAM_99p_variance
  fout_MAM->obs_MAM_99p = obs_MAM_99p
  fout_MAM->gdd_hist_MAM_99p = gdd_hist_MAM_99p
  fout_MAM->rcm_hist_MAM_99p = rcm_hist_MAM_99p
  fout_MAM->av_MAM_01p = av_MAM_01p
  fout_MAM->gdd_MAM_01p_rmse = gdd_MAM_01p_rmse
  fout_MAM->rcm_MAM_01p_rmse = rcm_MAM_01p_rmse
  fout_MAM->obs_MAM_01p_variance = obs_MAM_01p_variance
  fout_MAM->obs_MAM_01p = obs_MAM_01p
  fout_MAM->gdd_hist_MAM_01p = gdd_hist_MAM_01p
  fout_MAM->rcm_hist_MAM_01p = rcm_hist_MAM_01p

  delete(fout_MAM)

; JJA
  print(systemfunc("date"))
  print("JJA")
  rcm_JJA_avg_rmse = rcm_hist_JJA_avg
  rcm_JJA_avg_rmse = sqrt((rcm_hist_JJA_avg - obs_JJA_avg)^2)
  rcm_JJA_var_rmse = rcm_hist_JJA_var
  rcm_JJA_var_rmse = sqrt((rcm_hist_JJA_var - obs_JJA_var)^2)
  rcm_JJA_99p_rmse = rcm_hist_JJA_99p
  rcm_JJA_99p_rmse = sqrt((rcm_hist_JJA_99p - obs_JJA_99p)^2)
  rcm_JJA_01p_rmse = rcm_hist_JJA_01p
  rcm_JJA_01p_rmse = sqrt((rcm_hist_JJA_01p - obs_JJA_01p)^2)

  gdd_JJA_avg_rmse = gdd_hist_JJA_avg
  gdd_JJA_avg_rmse = sqrt((gdd_hist_JJA_avg - obs_JJA_avg)^2)
  gdd_JJA_var_rmse = gdd_hist_JJA_var
  gdd_JJA_var_rmse = sqrt((gdd_hist_JJA_var - obs_JJA_var)^2)
  gdd_JJA_99p_rmse = gdd_hist_JJA_99p
  gdd_JJA_99p_rmse = sqrt((gdd_hist_JJA_99p - obs_JJA_99p)^2)
  gdd_JJA_01p_rmse = gdd_hist_JJA_01p
  gdd_JJA_01p_rmse = sqrt((gdd_hist_JJA_01p - obs_JJA_01p)^2)

  av_JJA_avg = gdd_JJA_avg_rmse
  av_JJA_avg = gdd_JJA_avg_rmse - rcm_JJA_avg_rmse
  av_JJA_var = gdd_JJA_var_rmse
  av_JJA_var = gdd_JJA_var_rmse - rcm_JJA_var_rmse
  av_JJA_99p = gdd_JJA_99p_rmse
  av_JJA_99p = gdd_JJA_99p_rmse - rcm_JJA_99p_rmse
  av_JJA_01p = gdd_JJA_01p_rmse
  av_JJA_01p = gdd_JJA_01p_rmse - rcm_JJA_01p_rmse

  obs_JJA_avg_variance = dim_variance_n_Wrap(obs_JJA_avg_yearly, 0)
  obs_JJA_var_variance = dim_variance_n_Wrap(obs_JJA_var_yearly, 0)
  obs_JJA_99p_variance = dim_variance_n_Wrap(obs_JJA_99p_yearly, 0)
  obs_JJA_01p_variance = dim_variance_n_Wrap(obs_JJA_01p_yearly, 0)

  delete([/obs_JJA_avg_yearly, obs_JJA_var_yearly, obs_JJA_99p_yearly, obs_JJA_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_JJA_avg_variance_mask = obs_JJA_avg_variance
  obs_JJA_avg_variance_mask = where(obs_JJA_avg_variance_mask.eq.0, obs_JJA_avg_variance_mask@_FillValue, obs_JJA_avg_variance_mask)
  delete(obs_JJA_avg_variance)
  obs_JJA_avg_variance = obs_JJA_avg_variance_mask
  delete(obs_JJA_avg_variance_mask)
  obs_JJA_var_variance_mask = obs_JJA_var_variance
  obs_JJA_var_variance_mask = where(obs_JJA_var_variance_mask.eq.0, obs_JJA_var_variance_mask@_FillValue, obs_JJA_var_variance_mask)
  delete(obs_JJA_var_variance)
  obs_JJA_var_variance = obs_JJA_var_variance_mask
  delete(obs_JJA_var_variance_mask)
  obs_JJA_99p_variance_mask = obs_JJA_99p_variance
  obs_JJA_99p_variance_mask = where(obs_JJA_99p_variance_mask.eq.0, obs_JJA_99p_variance_mask@_FillValue, obs_JJA_99p_variance_mask)
  delete(obs_JJA_99p_variance)
  obs_JJA_99p_variance = obs_JJA_99p_variance_mask
  delete(obs_JJA_99p_variance_mask)
  obs_JJA_01p_variance_mask = obs_JJA_01p_variance
  obs_JJA_01p_variance_mask = where(obs_JJA_01p_variance_mask.eq.0, obs_JJA_01p_variance_mask@_FillValue, obs_JJA_01p_variance_mask)
  delete(obs_JJA_01p_variance)
  obs_JJA_01p_variance = obs_JJA_01p_variance_mask
  delete(obs_JJA_01p_variance_mask)

  fout_JJA = addfile(fout_name_JJA, "c")
  fout_JJA->av_JJA_avg = av_JJA_avg
  fout_JJA->gdd_JJA_avg_rmse = gdd_JJA_avg_rmse
  fout_JJA->rcm_JJA_avg_rmse = rcm_JJA_avg_rmse
  fout_JJA->obs_JJA_avg_variance = obs_JJA_avg_variance
  fout_JJA->obs_JJA_avg = obs_JJA_avg
  fout_JJA->gdd_hist_JJA_avg = gdd_hist_JJA_avg
  fout_JJA->rcm_hist_JJA_avg = rcm_hist_JJA_avg
  fout_JJA->av_JJA_var = av_JJA_var
  fout_JJA->gdd_JJA_var_rmse = gdd_JJA_var_rmse
  fout_JJA->rcm_JJA_var_rmse = rcm_JJA_var_rmse
  fout_JJA->obs_JJA_var_variance = obs_JJA_var_variance
  fout_JJA->obs_JJA_var = obs_JJA_var
  fout_JJA->gdd_hist_JJA_var = gdd_hist_JJA_var
  fout_JJA->rcm_hist_JJA_var = rcm_hist_JJA_var
  fout_JJA->av_JJA_99p = av_JJA_99p
  fout_JJA->gdd_JJA_99p_rmse = gdd_JJA_99p_rmse
  fout_JJA->rcm_JJA_99p_rmse = rcm_JJA_99p_rmse
  fout_JJA->obs_JJA_99p_variance = obs_JJA_99p_variance
  fout_JJA->obs_JJA_99p = obs_JJA_99p
  fout_JJA->gdd_hist_JJA_99p = gdd_hist_JJA_99p
  fout_JJA->rcm_hist_JJA_99p = rcm_hist_JJA_99p
  fout_JJA->av_JJA_01p = av_JJA_01p
  fout_JJA->gdd_JJA_01p_rmse = gdd_JJA_01p_rmse
  fout_JJA->rcm_JJA_01p_rmse = rcm_JJA_01p_rmse
  fout_JJA->obs_JJA_01p_variance = obs_JJA_01p_variance
  fout_JJA->obs_JJA_01p = obs_JJA_01p
  fout_JJA->gdd_hist_JJA_01p = gdd_hist_JJA_01p
  fout_JJA->rcm_hist_JJA_01p = rcm_hist_JJA_01p

  delete(fout_JJA)

; SON
  print(systemfunc("date"))
  print("SON")
  rcm_SON_avg_rmse = rcm_hist_SON_avg
  rcm_SON_avg_rmse = sqrt((rcm_hist_SON_avg - obs_SON_avg)^2)
  rcm_SON_var_rmse = rcm_hist_SON_var
  rcm_SON_var_rmse = sqrt((rcm_hist_SON_var - obs_SON_var)^2)
  rcm_SON_99p_rmse = rcm_hist_SON_99p
  rcm_SON_99p_rmse = sqrt((rcm_hist_SON_99p - obs_SON_99p)^2)
  rcm_SON_01p_rmse = rcm_hist_SON_01p
  rcm_SON_01p_rmse = sqrt((rcm_hist_SON_01p - obs_SON_01p)^2)

  gdd_SON_avg_rmse = gdd_hist_SON_avg
  gdd_SON_avg_rmse = sqrt((gdd_hist_SON_avg - obs_SON_avg)^2)
  gdd_SON_var_rmse = gdd_hist_SON_var
  gdd_SON_var_rmse = sqrt((gdd_hist_SON_var - obs_SON_var)^2)
  gdd_SON_99p_rmse = gdd_hist_SON_99p
  gdd_SON_99p_rmse = sqrt((gdd_hist_SON_99p - obs_SON_99p)^2)
  gdd_SON_01p_rmse = gdd_hist_SON_01p
  gdd_SON_01p_rmse = sqrt((gdd_hist_SON_01p - obs_SON_01p)^2)

  av_SON_avg = gdd_SON_avg_rmse
  av_SON_avg = gdd_SON_avg_rmse - rcm_SON_avg_rmse
  av_SON_var = gdd_SON_var_rmse
  av_SON_var = gdd_SON_var_rmse - rcm_SON_var_rmse
  av_SON_99p = gdd_SON_99p_rmse
  av_SON_99p = gdd_SON_99p_rmse - rcm_SON_99p_rmse
  av_SON_01p = gdd_SON_01p_rmse
  av_SON_01p = gdd_SON_01p_rmse - rcm_SON_01p_rmse

  obs_SON_avg_variance = dim_variance_n_Wrap(obs_SON_avg_yearly, 0)
  obs_SON_var_variance = dim_variance_n_Wrap(obs_SON_var_yearly, 0)
  obs_SON_99p_variance = dim_variance_n_Wrap(obs_SON_99p_yearly, 0)
  obs_SON_01p_variance = dim_variance_n_Wrap(obs_SON_01p_yearly, 0)

  delete([/obs_SON_avg_yearly, obs_SON_var_yearly, obs_SON_99p_yearly, obs_SON_01p_yearly/])

; mask obs variance where it equals zero to avoid divide by zero errors
  obs_SON_avg_variance_mask = obs_SON_avg_variance
  obs_SON_avg_variance_mask = where(obs_SON_avg_variance_mask.eq.0, obs_SON_avg_variance_mask@_FillValue, obs_SON_avg_variance_mask)
  delete(obs_SON_avg_variance)
  obs_SON_avg_variance = obs_SON_avg_variance_mask
  delete(obs_SON_avg_variance_mask)
  obs_SON_var_variance_mask = obs_SON_var_variance
  obs_SON_var_variance_mask = where(obs_SON_var_variance_mask.eq.0, obs_SON_var_variance_mask@_FillValue, obs_SON_var_variance_mask)
  delete(obs_SON_var_variance)
  obs_SON_var_variance = obs_SON_var_variance_mask
  delete(obs_SON_var_variance_mask)
  obs_SON_99p_variance_mask = obs_SON_99p_variance
  obs_SON_99p_variance_mask = where(obs_SON_99p_variance_mask.eq.0, obs_SON_99p_variance_mask@_FillValue, obs_SON_99p_variance_mask)
  delete(obs_SON_99p_variance)
  obs_SON_99p_variance = obs_SON_99p_variance_mask
  delete(obs_SON_99p_variance_mask)
  obs_SON_01p_variance_mask = obs_SON_01p_variance
  obs_SON_01p_variance_mask = where(obs_SON_01p_variance_mask.eq.0, obs_SON_01p_variance_mask@_FillValue, obs_SON_01p_variance_mask)
  delete(obs_SON_01p_variance)
  obs_SON_01p_variance = obs_SON_01p_variance_mask
  delete(obs_SON_01p_variance_mask)

  fout_SON = addfile(fout_name_SON, "c")
  fout_SON->av_SON_avg = av_SON_avg
  fout_SON->gdd_SON_avg_rmse = gdd_SON_avg_rmse
  fout_SON->rcm_SON_avg_rmse = rcm_SON_avg_rmse
  fout_SON->obs_SON_avg_variance = obs_SON_avg_variance
  fout_SON->obs_SON_avg = obs_SON_avg
  fout_SON->gdd_hist_SON_avg = gdd_hist_SON_avg
  fout_SON->rcm_hist_SON_avg = rcm_hist_SON_avg
  fout_SON->av_SON_var = av_SON_var
  fout_SON->gdd_SON_var_rmse = gdd_SON_var_rmse
  fout_SON->rcm_SON_var_rmse = rcm_SON_var_rmse
  fout_SON->obs_SON_var_variance = obs_SON_var_variance
  fout_SON->obs_SON_var = obs_SON_var
  fout_SON->gdd_hist_SON_var = gdd_hist_SON_var
  fout_SON->rcm_hist_SON_var = rcm_hist_SON_var
  fout_SON->av_SON_99p = av_SON_99p
  fout_SON->gdd_SON_99p_rmse = gdd_SON_99p_rmse
  fout_SON->rcm_SON_99p_rmse = rcm_SON_99p_rmse
  fout_SON->obs_SON_99p_variance = obs_SON_99p_variance
  fout_SON->obs_SON_99p = obs_SON_99p
  fout_SON->gdd_hist_SON_99p = gdd_hist_SON_99p
  fout_SON->rcm_hist_SON_99p = rcm_hist_SON_99p
  fout_SON->av_SON_01p = av_SON_01p
  fout_SON->gdd_SON_01p_rmse = gdd_SON_01p_rmse
  fout_SON->rcm_SON_01p_rmse = rcm_SON_01p_rmse
  fout_SON->obs_SON_01p_variance = obs_SON_01p_variance
  fout_SON->obs_SON_01p = obs_SON_01p
  fout_SON->gdd_hist_SON_01p = gdd_hist_SON_01p
  fout_SON->rcm_hist_SON_01p = rcm_hist_SON_01p

  delete(fout_SON)
  print(systemfunc("date"))

end