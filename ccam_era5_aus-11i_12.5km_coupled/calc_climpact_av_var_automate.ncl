; calculate Added Value (AV)

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/g/data/xv83/bxn599/CaRSA/rav_ncl/percentiles.ncl"

begin
  fout_name_ANN = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_ANN_added_value.nc"

  fout_name_DJF = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_DJF_added_value.nc"
  fout_name_MAM = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_MAM_added_value.nc"
  fout_name_JJA = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_JJA_added_value.nc"
  fout_name_SON = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_SON_added_value.nc"

  fout_name_JAN = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_JAN_added_value.nc"
  fout_name_FEB = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_FEB_added_value.nc"
  fout_name_MAR = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_MAR_added_value.nc"
  fout_name_APR = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_APR_added_value.nc"
  fout_name_MAY = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_MAY_added_value.nc"
  fout_name_JUN = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_JUN_added_value.nc"
  fout_name_JUL = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_JUL_added_value.nc"
  fout_name_AUG = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_AUG_added_value.nc"
  fout_name_SEP = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_SEP_added_value.nc"
  fout_name_OCT = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_OCT_added_value.nc"
  fout_name_NOV = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_NOV_added_value.nc"
  fout_name_DEC = "../calculated/ccam_era5_aus-11i_12.5km_coupled_"+yyyy_start+"-"+yyyy_end+"_climpact_"+var+"_DEC_added_value.nc"

  yyyymm_start = (yyyy_start*100)+1
  yyyymm_end = (yyyy_end*100)+12

  yyyy = ispan(yyyy_start, yyyy_end, 1)
  yyyymm = yyyymm_time(yyyy_start, yyyy_end, "integer")
  window = yyyy_end - yyyy_start + 1

  ; land sea mask file
  f2 = addfile("/scratch/e53/mxt599/esci/sftrf_AWAP0.05_NRMv3.nc", "r")
  lsmask = f2->AUS

;******************************
;******************************
  print(systemfunc("date"))
; **********************
; GDD GDD GDD GDD GDD
; **********************
  ifile_gdd_hist = addfile(ls_gdd+var+gdd_name, "r")

  gdd_hist = ifile_gdd_hist->$var$(:,{latS-1:latN+1},{lonL-1:lonR+1})
  delete(ifile_gdd_hist)
  gdd_hist!1 = "lat"
  gdd_hist!2 = "lon"

; **********************
; RCM RCM RCM RCM RCM
; **********************
  ifile_rcm_hist = addfile(ls_rcm+var+rcm_name, "r")

  rcm_hist = ifile_rcm_hist->$var$(:,{latS:latN},{lonL:lonR})
  delete(ifile_rcm_hist)
  rcm_hist!1 = "lat"
  rcm_hist!2 = "lon"

; **********************
; OBS OBS OBS OBS OBS
; **********************
  ifile_obs = addfile(ls_obs+var+obs_name, "r")

  obs = ifile_obs->$var$(:,{latS:latN},{lonL:lonR})
  delete(ifile_obs)
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

  obs_lat = obs&lat
  delete(obs&lat)
  obs&lat = tofloat(obs_lat)
  delete(obs_lat)
  obs_lon = obs&lon
  delete(obs&lon)
  obs&lon = tofloat(obs_lon)
  delete(obs_lon)

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

  fout_ANN = addfile(fout_name_ANN, "c")
  fout_ANN->av_ANN_avg = av_ANN_avg
  fout_ANN->gdd_ANN_avg_rmse = gdd_ANN_avg_rmse
  fout_ANN->rcm_ANN_avg_rmse = rcm_ANN_avg_rmse
  fout_ANN->obs_ANN_avg = obs_ANN_avg
  fout_ANN->gdd_hist_ANN_avg = gdd_hist_ANN_avg
  fout_ANN->rcm_hist_ANN_avg = rcm_hist_ANN_avg
  fout_ANN->av_ANN_var = av_ANN_var
  fout_ANN->gdd_ANN_var_rmse = gdd_ANN_var_rmse
  fout_ANN->rcm_ANN_var_rmse = rcm_ANN_var_rmse
  fout_ANN->obs_ANN_var = obs_ANN_var
  fout_ANN->gdd_hist_ANN_var = gdd_hist_ANN_var
  fout_ANN->rcm_hist_ANN_var = rcm_hist_ANN_var
  fout_ANN->av_ANN_99p = av_ANN_99p
  fout_ANN->gdd_ANN_99p_rmse = gdd_ANN_99p_rmse
  fout_ANN->rcm_ANN_99p_rmse = rcm_ANN_99p_rmse
  fout_ANN->obs_ANN_99p = obs_ANN_99p
  fout_ANN->gdd_hist_ANN_99p = gdd_hist_ANN_99p
  fout_ANN->rcm_hist_ANN_99p = rcm_hist_ANN_99p
  fout_ANN->av_ANN_01p = av_ANN_01p
  fout_ANN->gdd_ANN_01p_rmse = gdd_ANN_01p_rmse
  fout_ANN->rcm_ANN_01p_rmse = rcm_ANN_01p_rmse
  fout_ANN->obs_ANN_01p = obs_ANN_01p
  fout_ANN->gdd_hist_ANN_01p = gdd_hist_ANN_01p
  fout_ANN->rcm_hist_ANN_01p = rcm_hist_ANN_01p

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
  
  fout_JAN = addfile(fout_name_JAN, "c")
  fout_JAN->av_JAN_avg = av_JAN_avg
  fout_JAN->gdd_JAN_avg_rmse = gdd_JAN_avg_rmse
  fout_JAN->rcm_JAN_avg_rmse = rcm_JAN_avg_rmse
  fout_JAN->obs_JAN_avg = obs_JAN_avg
  fout_JAN->gdd_hist_JAN_avg = gdd_hist_JAN_avg
  fout_JAN->rcm_hist_JAN_avg = rcm_hist_JAN_avg
  fout_JAN->av_JAN_var = av_JAN_var
  fout_JAN->gdd_JAN_var_rmse = gdd_JAN_var_rmse
  fout_JAN->rcm_JAN_var_rmse = rcm_JAN_var_rmse
  fout_JAN->obs_JAN_var = obs_JAN_var
  fout_JAN->gdd_hist_JAN_var = gdd_hist_JAN_var
  fout_JAN->rcm_hist_JAN_var = rcm_hist_JAN_var
  fout_JAN->av_JAN_99p = av_JAN_99p
  fout_JAN->gdd_JAN_99p_rmse = gdd_JAN_99p_rmse
  fout_JAN->rcm_JAN_99p_rmse = rcm_JAN_99p_rmse
  fout_JAN->obs_JAN_99p = obs_JAN_99p
  fout_JAN->gdd_hist_JAN_99p = gdd_hist_JAN_99p
  fout_JAN->rcm_hist_JAN_99p = rcm_hist_JAN_99p
  fout_JAN->av_JAN_01p = av_JAN_01p
  fout_JAN->gdd_JAN_01p_rmse = gdd_JAN_01p_rmse
  fout_JAN->rcm_JAN_01p_rmse = rcm_JAN_01p_rmse
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

  fout_FEB = addfile(fout_name_FEB, "c")
  fout_FEB->av_FEB_avg = av_FEB_avg
  fout_FEB->gdd_FEB_avg_rmse = gdd_FEB_avg_rmse
  fout_FEB->rcm_FEB_avg_rmse = rcm_FEB_avg_rmse
  fout_FEB->obs_FEB_avg = obs_FEB_avg
  fout_FEB->gdd_hist_FEB_avg = gdd_hist_FEB_avg
  fout_FEB->rcm_hist_FEB_avg = rcm_hist_FEB_avg
  fout_FEB->av_FEB_var = av_FEB_var
  fout_FEB->gdd_FEB_var_rmse = gdd_FEB_var_rmse
  fout_FEB->rcm_FEB_var_rmse = rcm_FEB_var_rmse
  fout_FEB->obs_FEB_var = obs_FEB_var
  fout_FEB->gdd_hist_FEB_var = gdd_hist_FEB_var
  fout_FEB->rcm_hist_FEB_var = rcm_hist_FEB_var
  fout_FEB->av_FEB_99p = av_FEB_99p
  fout_FEB->gdd_FEB_99p_rmse = gdd_FEB_99p_rmse
  fout_FEB->rcm_FEB_99p_rmse = rcm_FEB_99p_rmse
  fout_FEB->obs_FEB_99p = obs_FEB_99p
  fout_FEB->gdd_hist_FEB_99p = gdd_hist_FEB_99p
  fout_FEB->rcm_hist_FEB_99p = rcm_hist_FEB_99p
  fout_FEB->av_FEB_01p = av_FEB_01p
  fout_FEB->gdd_FEB_01p_rmse = gdd_FEB_01p_rmse
  fout_FEB->rcm_FEB_01p_rmse = rcm_FEB_01p_rmse
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

  fout_MAR = addfile(fout_name_MAR, "c")
  fout_MAR->av_MAR_avg = av_MAR_avg
  fout_MAR->gdd_MAR_avg_rmse = gdd_MAR_avg_rmse
  fout_MAR->rcm_MAR_avg_rmse = rcm_MAR_avg_rmse
  fout_MAR->obs_MAR_avg = obs_MAR_avg
  fout_MAR->gdd_hist_MAR_avg = gdd_hist_MAR_avg
  fout_MAR->rcm_hist_MAR_avg = rcm_hist_MAR_avg
  fout_MAR->av_MAR_var = av_MAR_var
  fout_MAR->gdd_MAR_var_rmse = gdd_MAR_var_rmse
  fout_MAR->rcm_MAR_var_rmse = rcm_MAR_var_rmse
  fout_MAR->obs_MAR_var = obs_MAR_var
  fout_MAR->gdd_hist_MAR_var = gdd_hist_MAR_var
  fout_MAR->rcm_hist_MAR_var = rcm_hist_MAR_var
  fout_MAR->av_MAR_99p = av_MAR_99p
  fout_MAR->gdd_MAR_99p_rmse = gdd_MAR_99p_rmse
  fout_MAR->rcm_MAR_99p_rmse = rcm_MAR_99p_rmse
  fout_MAR->obs_MAR_99p = obs_MAR_99p
  fout_MAR->gdd_hist_MAR_99p = gdd_hist_MAR_99p
  fout_MAR->rcm_hist_MAR_99p = rcm_hist_MAR_99p
  fout_MAR->av_MAR_01p = av_MAR_01p
  fout_MAR->gdd_MAR_01p_rmse = gdd_MAR_01p_rmse
  fout_MAR->rcm_MAR_01p_rmse = rcm_MAR_01p_rmse
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

  fout_APR = addfile(fout_name_APR, "c")
  fout_APR->av_APR_avg = av_APR_avg
  fout_APR->gdd_APR_avg_rmse = gdd_APR_avg_rmse
  fout_APR->rcm_APR_avg_rmse = rcm_APR_avg_rmse
  fout_APR->obs_APR_avg = obs_APR_avg
  fout_APR->gdd_hist_APR_avg = gdd_hist_APR_avg
  fout_APR->rcm_hist_APR_avg = rcm_hist_APR_avg
  fout_APR->av_APR_var = av_APR_var
  fout_APR->gdd_APR_var_rmse = gdd_APR_var_rmse
  fout_APR->rcm_APR_var_rmse = rcm_APR_var_rmse
  fout_APR->obs_APR_var = obs_APR_var
  fout_APR->gdd_hist_APR_var = gdd_hist_APR_var
  fout_APR->rcm_hist_APR_var = rcm_hist_APR_var
  fout_APR->av_APR_99p = av_APR_99p
  fout_APR->gdd_APR_99p_rmse = gdd_APR_99p_rmse
  fout_APR->rcm_APR_99p_rmse = rcm_APR_99p_rmse
  fout_APR->obs_APR_99p = obs_APR_99p
  fout_APR->gdd_hist_APR_99p = gdd_hist_APR_99p
  fout_APR->rcm_hist_APR_99p = rcm_hist_APR_99p
  fout_APR->av_APR_01p = av_APR_01p
  fout_APR->gdd_APR_01p_rmse = gdd_APR_01p_rmse
  fout_APR->rcm_APR_01p_rmse = rcm_APR_01p_rmse
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

  fout_MAY = addfile(fout_name_MAY, "c")
  fout_MAY->av_MAY_avg = av_MAY_avg
  fout_MAY->gdd_MAY_avg_rmse = gdd_MAY_avg_rmse
  fout_MAY->rcm_MAY_avg_rmse = rcm_MAY_avg_rmse
  fout_MAY->obs_MAY_avg = obs_MAY_avg
  fout_MAY->gdd_hist_MAY_avg = gdd_hist_MAY_avg
  fout_MAY->rcm_hist_MAY_avg = rcm_hist_MAY_avg
  fout_MAY->av_MAY_var = av_MAY_var
  fout_MAY->gdd_MAY_var_rmse = gdd_MAY_var_rmse
  fout_MAY->rcm_MAY_var_rmse = rcm_MAY_var_rmse
  fout_MAY->obs_MAY_var = obs_MAY_var
  fout_MAY->gdd_hist_MAY_var = gdd_hist_MAY_var
  fout_MAY->rcm_hist_MAY_var = rcm_hist_MAY_var
  fout_MAY->av_MAY_99p = av_MAY_99p
  fout_MAY->gdd_MAY_99p_rmse = gdd_MAY_99p_rmse
  fout_MAY->rcm_MAY_99p_rmse = rcm_MAY_99p_rmse
  fout_MAY->obs_MAY_99p = obs_MAY_99p
  fout_MAY->gdd_hist_MAY_99p = gdd_hist_MAY_99p
  fout_MAY->rcm_hist_MAY_99p = rcm_hist_MAY_99p
  fout_MAY->av_MAY_01p = av_MAY_01p
  fout_MAY->gdd_MAY_01p_rmse = gdd_MAY_01p_rmse
  fout_MAY->rcm_MAY_01p_rmse = rcm_MAY_01p_rmse
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

  fout_JUN = addfile(fout_name_JUN, "c")
  fout_JUN->av_JUN_avg = av_JUN_avg
  fout_JUN->gdd_JUN_avg_rmse = gdd_JUN_avg_rmse
  fout_JUN->rcm_JUN_avg_rmse = rcm_JUN_avg_rmse
  fout_JUN->obs_JUN_avg = obs_JUN_avg
  fout_JUN->gdd_hist_JUN_avg = gdd_hist_JUN_avg
  fout_JUN->rcm_hist_JUN_avg = rcm_hist_JUN_avg
  fout_JUN->av_JUN_var = av_JUN_var
  fout_JUN->gdd_JUN_var_rmse = gdd_JUN_var_rmse
  fout_JUN->rcm_JUN_var_rmse = rcm_JUN_var_rmse
  fout_JUN->obs_JUN_var = obs_JUN_var
  fout_JUN->gdd_hist_JUN_var = gdd_hist_JUN_var
  fout_JUN->rcm_hist_JUN_var = rcm_hist_JUN_var
  fout_JUN->av_JUN_99p = av_JUN_99p
  fout_JUN->gdd_JUN_99p_rmse = gdd_JUN_99p_rmse
  fout_JUN->rcm_JUN_99p_rmse = rcm_JUN_99p_rmse
  fout_JUN->obs_JUN_99p = obs_JUN_99p
  fout_JUN->gdd_hist_JUN_99p = gdd_hist_JUN_99p
  fout_JUN->rcm_hist_JUN_99p = rcm_hist_JUN_99p
  fout_JUN->av_JUN_01p = av_JUN_01p
  fout_JUN->gdd_JUN_01p_rmse = gdd_JUN_01p_rmse
  fout_JUN->rcm_JUN_01p_rmse = rcm_JUN_01p_rmse
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

  fout_JUL = addfile(fout_name_JUL, "c")
  fout_JUL->av_JUL_avg = av_JUL_avg
  fout_JUL->gdd_JUL_avg_rmse = gdd_JUL_avg_rmse
  fout_JUL->rcm_JUL_avg_rmse = rcm_JUL_avg_rmse
  fout_JUL->obs_JUL_avg = obs_JUL_avg
  fout_JUL->gdd_hist_JUL_avg = gdd_hist_JUL_avg
  fout_JUL->rcm_hist_JUL_avg = rcm_hist_JUL_avg
  fout_JUL->av_JUL_var = av_JUL_var
  fout_JUL->gdd_JUL_var_rmse = gdd_JUL_var_rmse
  fout_JUL->rcm_JUL_var_rmse = rcm_JUL_var_rmse
  fout_JUL->obs_JUL_var = obs_JUL_var
  fout_JUL->gdd_hist_JUL_var = gdd_hist_JUL_var
  fout_JUL->rcm_hist_JUL_var = rcm_hist_JUL_var
  fout_JUL->av_JUL_99p = av_JUL_99p
  fout_JUL->gdd_JUL_99p_rmse = gdd_JUL_99p_rmse
  fout_JUL->rcm_JUL_99p_rmse = rcm_JUL_99p_rmse
  fout_JUL->obs_JUL_99p = obs_JUL_99p
  fout_JUL->gdd_hist_JUL_99p = gdd_hist_JUL_99p
  fout_JUL->rcm_hist_JUL_99p = rcm_hist_JUL_99p
  fout_JUL->av_JUL_01p = av_JUL_01p
  fout_JUL->gdd_JUL_01p_rmse = gdd_JUL_01p_rmse
  fout_JUL->rcm_JUL_01p_rmse = rcm_JUL_01p_rmse
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

  fout_AUG = addfile(fout_name_AUG, "c")
  fout_AUG->av_AUG_avg = av_AUG_avg
  fout_AUG->gdd_AUG_avg_rmse = gdd_AUG_avg_rmse
  fout_AUG->rcm_AUG_avg_rmse = rcm_AUG_avg_rmse
  fout_AUG->obs_AUG_avg = obs_AUG_avg
  fout_AUG->gdd_hist_AUG_avg = gdd_hist_AUG_avg
  fout_AUG->rcm_hist_AUG_avg = rcm_hist_AUG_avg
  fout_AUG->av_AUG_var = av_AUG_var
  fout_AUG->gdd_AUG_var_rmse = gdd_AUG_var_rmse
  fout_AUG->rcm_AUG_var_rmse = rcm_AUG_var_rmse
  fout_AUG->obs_AUG_var = obs_AUG_var
  fout_AUG->gdd_hist_AUG_var = gdd_hist_AUG_var
  fout_AUG->rcm_hist_AUG_var = rcm_hist_AUG_var
  fout_AUG->av_AUG_99p = av_AUG_99p
  fout_AUG->gdd_AUG_99p_rmse = gdd_AUG_99p_rmse
  fout_AUG->rcm_AUG_99p_rmse = rcm_AUG_99p_rmse
  fout_AUG->obs_AUG_99p = obs_AUG_99p
  fout_AUG->gdd_hist_AUG_99p = gdd_hist_AUG_99p
  fout_AUG->rcm_hist_AUG_99p = rcm_hist_AUG_99p
  fout_AUG->av_AUG_01p = av_AUG_01p
  fout_AUG->gdd_AUG_01p_rmse = gdd_AUG_01p_rmse
  fout_AUG->rcm_AUG_01p_rmse = rcm_AUG_01p_rmse
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

  fout_SEP = addfile(fout_name_SEP, "c")
  fout_SEP->av_SEP_avg = av_SEP_avg
  fout_SEP->gdd_SEP_avg_rmse = gdd_SEP_avg_rmse
  fout_SEP->rcm_SEP_avg_rmse = rcm_SEP_avg_rmse
  fout_SEP->obs_SEP_avg = obs_SEP_avg
  fout_SEP->gdd_hist_SEP_avg = gdd_hist_SEP_avg
  fout_SEP->rcm_hist_SEP_avg = rcm_hist_SEP_avg
  fout_SEP->av_SEP_var = av_SEP_var
  fout_SEP->gdd_SEP_var_rmse = gdd_SEP_var_rmse
  fout_SEP->rcm_SEP_var_rmse = rcm_SEP_var_rmse
  fout_SEP->obs_SEP_var = obs_SEP_var
  fout_SEP->gdd_hist_SEP_var = gdd_hist_SEP_var
  fout_SEP->rcm_hist_SEP_var = rcm_hist_SEP_var
  fout_SEP->av_SEP_99p = av_SEP_99p
  fout_SEP->gdd_SEP_99p_rmse = gdd_SEP_99p_rmse
  fout_SEP->rcm_SEP_99p_rmse = rcm_SEP_99p_rmse
  fout_SEP->obs_SEP_99p = obs_SEP_99p
  fout_SEP->gdd_hist_SEP_99p = gdd_hist_SEP_99p
  fout_SEP->rcm_hist_SEP_99p = rcm_hist_SEP_99p
  fout_SEP->av_SEP_01p = av_SEP_01p
  fout_SEP->gdd_SEP_01p_rmse = gdd_SEP_01p_rmse
  fout_SEP->rcm_SEP_01p_rmse = rcm_SEP_01p_rmse
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

  fout_OCT = addfile(fout_name_OCT, "c")
  fout_OCT->av_OCT_avg = av_OCT_avg
  fout_OCT->gdd_OCT_avg_rmse = gdd_OCT_avg_rmse
  fout_OCT->rcm_OCT_avg_rmse = rcm_OCT_avg_rmse
  fout_OCT->obs_OCT_avg = obs_OCT_avg
  fout_OCT->gdd_hist_OCT_avg = gdd_hist_OCT_avg
  fout_OCT->rcm_hist_OCT_avg = rcm_hist_OCT_avg
  fout_OCT->av_OCT_var = av_OCT_var
  fout_OCT->gdd_OCT_var_rmse = gdd_OCT_var_rmse
  fout_OCT->rcm_OCT_var_rmse = rcm_OCT_var_rmse
  fout_OCT->obs_OCT_var = obs_OCT_var
  fout_OCT->gdd_hist_OCT_var = gdd_hist_OCT_var
  fout_OCT->rcm_hist_OCT_var = rcm_hist_OCT_var
  fout_OCT->av_OCT_99p = av_OCT_99p
  fout_OCT->gdd_OCT_99p_rmse = gdd_OCT_99p_rmse
  fout_OCT->rcm_OCT_99p_rmse = rcm_OCT_99p_rmse
  fout_OCT->obs_OCT_99p = obs_OCT_99p
  fout_OCT->gdd_hist_OCT_99p = gdd_hist_OCT_99p
  fout_OCT->rcm_hist_OCT_99p = rcm_hist_OCT_99p
  fout_OCT->av_OCT_01p = av_OCT_01p
  fout_OCT->gdd_OCT_01p_rmse = gdd_OCT_01p_rmse
  fout_OCT->rcm_OCT_01p_rmse = rcm_OCT_01p_rmse
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

  fout_NOV = addfile(fout_name_NOV, "c")
  fout_NOV->av_NOV_avg = av_NOV_avg
  fout_NOV->gdd_NOV_avg_rmse = gdd_NOV_avg_rmse
  fout_NOV->rcm_NOV_avg_rmse = rcm_NOV_avg_rmse
  fout_NOV->obs_NOV_avg = obs_NOV_avg
  fout_NOV->gdd_hist_NOV_avg = gdd_hist_NOV_avg
  fout_NOV->rcm_hist_NOV_avg = rcm_hist_NOV_avg
  fout_NOV->av_NOV_var = av_NOV_var
  fout_NOV->gdd_NOV_var_rmse = gdd_NOV_var_rmse
  fout_NOV->rcm_NOV_var_rmse = rcm_NOV_var_rmse
  fout_NOV->obs_NOV_var = obs_NOV_var
  fout_NOV->gdd_hist_NOV_var = gdd_hist_NOV_var
  fout_NOV->rcm_hist_NOV_var = rcm_hist_NOV_var
  fout_NOV->av_NOV_99p = av_NOV_99p
  fout_NOV->gdd_NOV_99p_rmse = gdd_NOV_99p_rmse
  fout_NOV->rcm_NOV_99p_rmse = rcm_NOV_99p_rmse
  fout_NOV->obs_NOV_99p = obs_NOV_99p
  fout_NOV->gdd_hist_NOV_99p = gdd_hist_NOV_99p
  fout_NOV->rcm_hist_NOV_99p = rcm_hist_NOV_99p
  fout_NOV->av_NOV_01p = av_NOV_01p
  fout_NOV->gdd_NOV_01p_rmse = gdd_NOV_01p_rmse
  fout_NOV->rcm_NOV_01p_rmse = rcm_NOV_01p_rmse
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

  fout_DEC = addfile(fout_name_DEC, "c")
  fout_DEC->av_DEC_avg = av_DEC_avg
  fout_DEC->gdd_DEC_avg_rmse = gdd_DEC_avg_rmse
  fout_DEC->rcm_DEC_avg_rmse = rcm_DEC_avg_rmse
  fout_DEC->obs_DEC_avg = obs_DEC_avg
  fout_DEC->gdd_hist_DEC_avg = gdd_hist_DEC_avg
  fout_DEC->rcm_hist_DEC_avg = rcm_hist_DEC_avg
  fout_DEC->av_DEC_var = av_DEC_var
  fout_DEC->gdd_DEC_var_rmse = gdd_DEC_var_rmse
  fout_DEC->rcm_DEC_var_rmse = rcm_DEC_var_rmse
  fout_DEC->obs_DEC_var = obs_DEC_var
  fout_DEC->gdd_hist_DEC_var = gdd_hist_DEC_var
  fout_DEC->rcm_hist_DEC_var = rcm_hist_DEC_var
  fout_DEC->av_DEC_99p = av_DEC_99p
  fout_DEC->gdd_DEC_99p_rmse = gdd_DEC_99p_rmse
  fout_DEC->rcm_DEC_99p_rmse = rcm_DEC_99p_rmse
  fout_DEC->obs_DEC_99p = obs_DEC_99p
  fout_DEC->gdd_hist_DEC_99p = gdd_hist_DEC_99p
  fout_DEC->rcm_hist_DEC_99p = rcm_hist_DEC_99p
  fout_DEC->av_DEC_01p = av_DEC_01p
  fout_DEC->gdd_DEC_01p_rmse = gdd_DEC_01p_rmse
  fout_DEC->rcm_DEC_01p_rmse = rcm_DEC_01p_rmse
  fout_DEC->obs_DEC_01p = obs_DEC_01p
  fout_DEC->gdd_hist_DEC_01p = gdd_hist_DEC_01p
  fout_DEC->rcm_hist_DEC_01p = rcm_hist_DEC_01p

  delete(fout_DEC)

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

  delete(nlat)
  delete(nlon)

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

  fout_DJF = addfile(fout_name_DJF, "c")
  fout_DJF->av_DJF_avg = av_DJF_avg
  fout_DJF->gdd_DJF_avg_rmse = gdd_DJF_avg_rmse
  fout_DJF->rcm_DJF_avg_rmse = rcm_DJF_avg_rmse
  fout_DJF->obs_DJF_avg = obs_DJF_avg
  fout_DJF->gdd_hist_DJF_avg = gdd_hist_DJF_avg
  fout_DJF->rcm_hist_DJF_avg = rcm_hist_DJF_avg
  fout_DJF->av_DJF_var = av_DJF_var
  fout_DJF->gdd_DJF_var_rmse = gdd_DJF_var_rmse
  fout_DJF->rcm_DJF_var_rmse = rcm_DJF_var_rmse
  fout_DJF->obs_DJF_var = obs_DJF_var
  fout_DJF->gdd_hist_DJF_var = gdd_hist_DJF_var
  fout_DJF->rcm_hist_DJF_var = rcm_hist_DJF_var
  fout_DJF->av_DJF_99p = av_DJF_99p
  fout_DJF->gdd_DJF_99p_rmse = gdd_DJF_99p_rmse
  fout_DJF->rcm_DJF_99p_rmse = rcm_DJF_99p_rmse
  fout_DJF->obs_DJF_99p = obs_DJF_99p
  fout_DJF->gdd_hist_DJF_99p = gdd_hist_DJF_99p
  fout_DJF->rcm_hist_DJF_99p = rcm_hist_DJF_99p
  fout_DJF->av_DJF_01p = av_DJF_01p
  fout_DJF->gdd_DJF_01p_rmse = gdd_DJF_01p_rmse
  fout_DJF->rcm_DJF_01p_rmse = rcm_DJF_01p_rmse
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

  fout_MAM = addfile(fout_name_MAM, "c")
  fout_MAM->av_MAM_avg = av_MAM_avg
  fout_MAM->gdd_MAM_avg_rmse = gdd_MAM_avg_rmse
  fout_MAM->rcm_MAM_avg_rmse = rcm_MAM_avg_rmse
  fout_MAM->obs_MAM_avg = obs_MAM_avg
  fout_MAM->gdd_hist_MAM_avg = gdd_hist_MAM_avg
  fout_MAM->rcm_hist_MAM_avg = rcm_hist_MAM_avg
  fout_MAM->av_MAM_var = av_MAM_var
  fout_MAM->gdd_MAM_var_rmse = gdd_MAM_var_rmse
  fout_MAM->rcm_MAM_var_rmse = rcm_MAM_var_rmse
  fout_MAM->obs_MAM_var = obs_MAM_var
  fout_MAM->gdd_hist_MAM_var = gdd_hist_MAM_var
  fout_MAM->rcm_hist_MAM_var = rcm_hist_MAM_var
  fout_MAM->av_MAM_99p = av_MAM_99p
  fout_MAM->gdd_MAM_99p_rmse = gdd_MAM_99p_rmse
  fout_MAM->rcm_MAM_99p_rmse = rcm_MAM_99p_rmse
  fout_MAM->obs_MAM_99p = obs_MAM_99p
  fout_MAM->gdd_hist_MAM_99p = gdd_hist_MAM_99p
  fout_MAM->rcm_hist_MAM_99p = rcm_hist_MAM_99p
  fout_MAM->av_MAM_01p = av_MAM_01p
  fout_MAM->gdd_MAM_01p_rmse = gdd_MAM_01p_rmse
  fout_MAM->rcm_MAM_01p_rmse = rcm_MAM_01p_rmse
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

  fout_JJA = addfile(fout_name_JJA, "c")
  fout_JJA->av_JJA_avg = av_JJA_avg
  fout_JJA->gdd_JJA_avg_rmse = gdd_JJA_avg_rmse
  fout_JJA->rcm_JJA_avg_rmse = rcm_JJA_avg_rmse
  fout_JJA->obs_JJA_avg = obs_JJA_avg
  fout_JJA->gdd_hist_JJA_avg = gdd_hist_JJA_avg
  fout_JJA->rcm_hist_JJA_avg = rcm_hist_JJA_avg
  fout_JJA->av_JJA_var = av_JJA_var
  fout_JJA->gdd_JJA_var_rmse = gdd_JJA_var_rmse
  fout_JJA->rcm_JJA_var_rmse = rcm_JJA_var_rmse
  fout_JJA->obs_JJA_var = obs_JJA_var
  fout_JJA->gdd_hist_JJA_var = gdd_hist_JJA_var
  fout_JJA->rcm_hist_JJA_var = rcm_hist_JJA_var
  fout_JJA->av_JJA_99p = av_JJA_99p
  fout_JJA->gdd_JJA_99p_rmse = gdd_JJA_99p_rmse
  fout_JJA->rcm_JJA_99p_rmse = rcm_JJA_99p_rmse
  fout_JJA->obs_JJA_99p = obs_JJA_99p
  fout_JJA->gdd_hist_JJA_99p = gdd_hist_JJA_99p
  fout_JJA->rcm_hist_JJA_99p = rcm_hist_JJA_99p
  fout_JJA->av_JJA_01p = av_JJA_01p
  fout_JJA->gdd_JJA_01p_rmse = gdd_JJA_01p_rmse
  fout_JJA->rcm_JJA_01p_rmse = rcm_JJA_01p_rmse
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

  fout_SON = addfile(fout_name_SON, "c")
  fout_SON->av_SON_avg = av_SON_avg
  fout_SON->gdd_SON_avg_rmse = gdd_SON_avg_rmse
  fout_SON->rcm_SON_avg_rmse = rcm_SON_avg_rmse
  fout_SON->obs_SON_avg = obs_SON_avg
  fout_SON->gdd_hist_SON_avg = gdd_hist_SON_avg
  fout_SON->rcm_hist_SON_avg = rcm_hist_SON_avg
  fout_SON->av_SON_var = av_SON_var
  fout_SON->gdd_SON_var_rmse = gdd_SON_var_rmse
  fout_SON->rcm_SON_var_rmse = rcm_SON_var_rmse
  fout_SON->obs_SON_var = obs_SON_var
  fout_SON->gdd_hist_SON_var = gdd_hist_SON_var
  fout_SON->rcm_hist_SON_var = rcm_hist_SON_var
  fout_SON->av_SON_99p = av_SON_99p
  fout_SON->gdd_SON_99p_rmse = gdd_SON_99p_rmse
  fout_SON->rcm_SON_99p_rmse = rcm_SON_99p_rmse
  fout_SON->obs_SON_99p = obs_SON_99p
  fout_SON->gdd_hist_SON_99p = gdd_hist_SON_99p
  fout_SON->rcm_hist_SON_99p = rcm_hist_SON_99p
  fout_SON->av_SON_01p = av_SON_01p
  fout_SON->gdd_SON_01p_rmse = gdd_SON_01p_rmse
  fout_SON->rcm_SON_01p_rmse = rcm_SON_01p_rmse
  fout_SON->obs_SON_01p = obs_SON_01p
  fout_SON->gdd_hist_SON_01p = gdd_hist_SON_01p
  fout_SON->rcm_hist_SON_01p = rcm_hist_SON_01p

  delete(fout_SON)
  print(systemfunc("date"))

end