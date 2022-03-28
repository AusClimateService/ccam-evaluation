; calculate Added Value (AV)

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/scratch/q49/bxn599/CaRSA/rav_ncl/percentiles.ncl"

begin
  var = "pr" ; daily rainfall
  season = "seasonal"
  statistic = "99"
  hist_start = 1986
  hist_start_day = 19860101
  hist_end = 2005
  hist_end_day = 20051231
  fut_start = 2080
  fut_start_day = 20800101
  fut_end = 2099
  fut_end_day = 20991231
  window = hist_end - hist_start + 1

  fout_name_DJF = "CCAM_ACCESS1-0_"+hist_start+"-"+hist_end+"_"+fut_start+"-"+fut_end+"_"+var+"_DJF_added_value.nc"
  fout_name_MAM = "CCAM_ACCESS1-0_"+hist_start+"-"+hist_end+"_"+fut_start+"-"+fut_end+"_"+var+"_MAM_added_value.nc"
  fout_name_JJA = "CCAM_ACCESS1-0_"+hist_start+"-"+hist_end+"_"+fut_start+"-"+fut_end+"_"+var+"_JJA_added_value.nc"
  fout_name_SON = "CCAM_ACCESS1-0_"+hist_start+"-"+hist_end+"_"+fut_start+"-"+fut_end+"_"+var+"_SON_added_value.nc"

  yyyy_hist = ispan(hist_start, hist_end, 1)
  yyyy_fut = ispan(fut_start, fut_end, 1)
  ls_gdd_hist = systemfunc("ls /g/data/rr3/publications/CMIP5/output1/CSIRO-BOM/ACCESS1-0/historical/day/atmos/day/r1i1p1/latest/pr/pr*.nc")
  ls_gdd_fut = systemfunc("ls /g/data/rr3/publications/CMIP5/output1/CSIRO-BOM/ACCESS1-0/rcp85/day/atmos/day/r1i1p1/latest/pr/pr*.nc")
  ls_rcm_hist = "/scratch/e53/mxt599/esci/ccam_access1-0_aus_12km/regrid/pr_AUS-12_CSIRO-BOM-ACCESS1-0_historical_r1i1p1_CSIRO-CCAM_r4602_day_"+yyyy_hist+"0101-"+yyyy_hist+"1231.nc"
  ls_rcm_fut = "/scratch/e53/mxt599/esci/ccam_access1-0_aus_12km/regrid/pr_AUS-12_CSIRO-BOM-ACCESS1-0_rcp85_r1i1p1_CSIRO-CCAM_r4602_day_"+yyyy_fut+"0101-"+yyyy_fut+"1231.nc"
  ls_obs = "/g/data/zv2/agcd/v1/precip/calib/r005/01day/agcd_v1_precip_calib_r005_daily_"+yyyy_hist+".nc"

  ifile_gdd_hist = addfiles(ls_gdd_hist, "r")
  ifile_gdd_fut = addfiles(ls_gdd_fut, "r")
  ifile_rcm_hist = addfiles(ls_rcm_hist, "r")
  ifile_rcm_fut = addfiles(ls_rcm_fut, "r")
  ifile_obs = addfiles(ls_obs, "r")

  ; land sea mask file
  f2 = addfile("/scratch/e53/mxt599/esci/sftrf_AWAP0.05_NRMv3.nc", "r")
  lsmask = f2->AUS

;******************************
;******************************
  print(systemfunc("date"))
  print("Reading files, restrict to hist/fut periods")
  gdd_hist = ifile_gdd_hist[:]->pr
  if gdd_hist@units .eq. "kg/m2/s" .or. gdd_hist@units .eq."kg m-2 s-1" then
    gdd_hist = gdd_hist*86400
    gdd_hist@units = "mm/day"
  end if
  gdd_hist_date = cd_calendar(gdd_hist&time, -2)
  gdd_hist_st0 = ind(gdd_hist_date.eq.hist_start_day)
  gdd_hist_ed0 = ind(gdd_hist_date.eq.hist_end_day)
  gdd_hist_ = gdd_hist(gdd_hist_st0:gdd_hist_ed0,{-45:-10},{110.625:157.5}) ; restrict to aus region
  delete(gdd_hist)
  gdd_hist = gdd_hist_
  delete(gdd_hist_)

  gdd_fut = ifile_gdd_fut[:]->pr
  if gdd_fut@units .eq. "kg/m2/s" .or. gdd_fut@units .eq."kg m-2 s-1" then
    gdd_fut = gdd_fut*86400
    gdd_fut@units = "mm/day"
  end if
  gdd_fut_date = cd_calendar(gdd_fut&time, -2)
  gdd_fut_st0 = ind(gdd_fut_date.eq.fut_start_day)
  gdd_fut_ed0 = ind(gdd_fut_date.eq.fut_end_day)
  gdd_fut_ = gdd_fut(gdd_fut_st0:gdd_fut_ed0,{-45:-10},{110.625:157.5}) ; restrict to aus region
  delete(gdd_fut)
  gdd_fut = gdd_fut_
  delete(gdd_fut_)

  rcm_hist = ifile_rcm_hist[:]->pr
  if rcm_hist@units .eq. "kg/m2/s" .or. rcm_hist@units .eq."kg m-2 s-1" then
    rcm_hist = rcm_hist*86400
    rcm_hist@units = "mm/day"
  end if

  rcm_fut = ifile_rcm_fut[:]->pr
  if rcm_fut@units .eq. "kg/m2/s" .or. rcm_fut@units .eq."kg m-2 s-1" then
    rcm_fut = rcm_fut*86400
    rcm_fut@units = "mm/day"
  end if

  obs = ifile_obs[:]->precip
  if obs@units .eq. "kg/m2/s" .or. obs@units .eq."kg m-2 s-1" then
    obs = obs*86400
    obs@units = "mm/day"
  else if obs@units .eq. "mm" then
    obs@units = "mm/day"
  end if
  end if

;******************************
;******************************
  print(systemfunc("date"))
  print("Finished reading files, starting interpolation")
  ; interpolate to common grid
  newlat = fspan(-44.5, -10., 691)
  newlon = fspan(112., 156.25, 886)
  newlat@units = "degrees_north"
  newlon@units = "degrees_east"

  gdd_hist_regrid = linint2_Wrap(gdd_hist&lon, gdd_hist&lat, gdd_hist, False, newlon, newlat, 0)
  gdd_hist_regrid!1   ="lat"
  gdd_hist_regrid!2   = "lon"
  gdd_hist_regrid&lat = newlat
  gdd_hist_regrid&lon = newlon
  delete(gdd_hist)
  gdd_hist = gdd_hist_regrid
  delete(gdd_hist_regrid)

  gdd_fut_regrid = linint2_Wrap(gdd_fut&lon, gdd_fut&lat, gdd_fut, False, newlon, newlat, 0)
  gdd_fut_regrid!1   ="lat"
  gdd_fut_regrid!2   = "lon"
  gdd_fut_regrid&lat = newlat
  gdd_fut_regrid&lon = newlon
  delete(gdd_fut)
  gdd_fut = gdd_fut_regrid
  delete(gdd_fut_regrid)

;******************************
;******************************
  print(systemfunc("date"))
  print("Finished interpolation, masking data")
  rcm_hist_mask = rcm_hist
  rcm_hist_mask = mask(rcm_hist, conform(rcm_hist, lsmask, (/1,2/)), 1)
  delete(rcm_hist)
  rcm_hist = rcm_hist_mask
  delete(rcm_hist_mask)

  rcm_fut_mask = rcm_fut
  rcm_fut_mask = mask(rcm_fut, conform(rcm_fut, lsmask, (/1,2/)), 1)
  delete(rcm_fut)
  rcm_fut = rcm_fut_mask
  delete(rcm_fut_mask)

  gdd_hist_mask = gdd_hist
  gdd_hist_mask = mask(gdd_hist, conform(gdd_hist, lsmask, (/1,2/)), 1)
  delete(gdd_hist)
  gdd_hist = gdd_hist_mask
  delete(gdd_hist_mask)

  gdd_fut_mask = gdd_fut
  gdd_fut_mask = mask(gdd_fut, conform(gdd_fut, lsmask, (/1,2/)), 1)
  delete(gdd_fut)
  gdd_fut = gdd_fut_mask
  delete(gdd_fut_mask)

  obs_mask = obs
  obs_mask = mask(obs, conform(obs, lsmask, (/1,2/)), 1)
  delete(obs)
  obs = obs_mask
  delete(obs_mask)

  asciiwrite("obs_all_months", obs(:,{-37.5},{145}))
  asciiwrite("rcm_hist_all_months", rcm_hist(:,{-37.5},{145}))
  asciiwrite("rcm_fut_all_months", rcm_fut(:,{-37.5},{145}))
  asciiwrite("gdd_hist_all_months", gdd_hist(:,{-37.5},{145}))
  asciiwrite("gdd_fut_all_months", gdd_fut(:,{-37.5},{145}))

;******************************
;******************************
  print(systemfunc("date"))
  print("Finished masking, starting statistics calculation")

  hist_date = cd_calendar(rcm_hist&time, -2)
  hist_year = hist_date/10000
  hist_years = ispan(min(hist_year), max(hist_year), 1)

  fut_date = cd_calendar(rcm_fut&time, -2)
  fut_year = fut_date/10000
  fut_years = ispan(min(fut_year), max(fut_year), 1)

  lat = rcm_hist&lat
  lon = rcm_hist&lon
  nlat = dimsizes(lat)
  nlon = dimsizes(lon)

; shift December months a year forward for DJF calculation. e.g., Dec86 becomes Dec87 so DJF87 is actually Dec86, JF87
  opt = 0
  opt@return_type = "float"
  hist_date_all = cd_calendar(rcm_hist&time, 0)
  hist_date_new = hist_date_all
  hist_date_new(:,0) = where(hist_date_all(:,1).eq.12, hist_date_new(:,0)+1, hist_date_new(:,0))
  hist_time_new = cd_inv_calendar(hist_date_new(:,0), hist_date_new(:,1), hist_date_new(:,2), hist_date_new(:,3), hist_date_new(:,4), hist_date_new(:,5), rcm_hist&time@units, opt)

  fut_date_all = cd_calendar(rcm_fut&time, 0)
  fut_date_new = fut_date_all
  fut_date_new(:,0) = where(fut_date_all(:,1).eq.12, fut_date_new(:,0)+1, fut_date_new(:,0))
  fut_time_new = cd_inv_calendar(fut_date_new(:,0), fut_date_new(:,1), fut_date_new(:,2), fut_date_new(:,3), fut_date_new(:,4), fut_date_new(:,5), rcm_fut&time@units, opt)

  rcm_hist&time = hist_time_new
  gdd_hist&time = hist_time_new
  obs&time = hist_time_new
  rcm_fut&time = fut_time_new
  gdd_fut&time = fut_time_new

; create new arrays for statistics
  rcm_hist_DJF_avg = new((/window, nlat, nlon/), float) ; average
  rcm_hist_DJF_avg!0 = "year"
  rcm_hist_DJF_avg!1 = "lat"
  rcm_hist_DJF_avg!2 = "lon"
  rcm_hist_DJF_avg&year = hist_years
  rcm_hist_DJF_avg&lat = lat
  rcm_hist_DJF_avg&lon = lon
  rcm_hist_DJF_var = new((/window, nlat, nlon/), float) ; variance
  rcm_hist_DJF_var!0 = "year"
  rcm_hist_DJF_var!1 = "lat"
  rcm_hist_DJF_var!2 = "lon"
  rcm_hist_DJF_var&year = hist_years
  rcm_hist_DJF_var&lat = lat
  rcm_hist_DJF_var&lon = lon
  rcm_hist_DJF_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  rcm_hist_DJF_99p!0 = "year"
  rcm_hist_DJF_99p!1 = "lat"
  rcm_hist_DJF_99p!2 = "lon"
  rcm_hist_DJF_99p&year = hist_years
  rcm_hist_DJF_99p&lat = lat
  rcm_hist_DJF_99p&lon = lon
  rcm_hist_DJF_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  rcm_hist_DJF_01p!0 = "year"
  rcm_hist_DJF_01p!1 = "lat"
  rcm_hist_DJF_01p!2 = "lon"
  rcm_hist_DJF_01p&year = hist_years
  rcm_hist_DJF_01p&lat = lat
  rcm_hist_DJF_01p&lon = lon

  rcm_hist_MAM_avg = new((/window, nlat, nlon/), float) ; average
  rcm_hist_MAM_avg!0 = "year"
  rcm_hist_MAM_avg!1 = "lat"
  rcm_hist_MAM_avg!2 = "lon"
  rcm_hist_MAM_avg&year = hist_years
  rcm_hist_MAM_avg&lat = lat
  rcm_hist_MAM_avg&lon = lon
  rcm_hist_MAM_var = new((/window, nlat, nlon/), float) ; variance
  rcm_hist_MAM_var!0 = "year"
  rcm_hist_MAM_var!1 = "lat"
  rcm_hist_MAM_var!2 = "lon"
  rcm_hist_MAM_var&year = hist_years
  rcm_hist_MAM_var&lat = lat
  rcm_hist_MAM_var&lon = lon
  rcm_hist_MAM_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  rcm_hist_MAM_99p!0 = "year"
  rcm_hist_MAM_99p!1 = "lat"
  rcm_hist_MAM_99p!2 = "lon"
  rcm_hist_MAM_99p&year = hist_years
  rcm_hist_MAM_99p&lat = lat
  rcm_hist_MAM_99p&lon = lon
  rcm_hist_MAM_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  rcm_hist_MAM_01p!0 = "year"
  rcm_hist_MAM_01p!1 = "lat"
  rcm_hist_MAM_01p!2 = "lon"
  rcm_hist_MAM_01p&year = hist_years
  rcm_hist_MAM_01p&lat = lat
  rcm_hist_MAM_01p&lon = lon

  rcm_hist_JJA_avg = new((/window, nlat, nlon/), float) ; average
  rcm_hist_JJA_avg!0 = "year"
  rcm_hist_JJA_avg!1 = "lat"
  rcm_hist_JJA_avg!2 = "lon"
  rcm_hist_JJA_avg&year = hist_years
  rcm_hist_JJA_avg&lat = lat
  rcm_hist_JJA_avg&lon = lon
  rcm_hist_JJA_var = new((/window, nlat, nlon/), float) ; variance
  rcm_hist_JJA_var!0 = "year"
  rcm_hist_JJA_var!1 = "lat"
  rcm_hist_JJA_var!2 = "lon"
  rcm_hist_JJA_var&year = hist_years
  rcm_hist_JJA_var&lat = lat
  rcm_hist_JJA_var&lon = lon
  rcm_hist_JJA_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  rcm_hist_JJA_99p!0 = "year"
  rcm_hist_JJA_99p!1 = "lat"
  rcm_hist_JJA_99p!2 = "lon"
  rcm_hist_JJA_99p&year = hist_years
  rcm_hist_JJA_99p&lat = lat
  rcm_hist_JJA_99p&lon = lon
  rcm_hist_JJA_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  rcm_hist_JJA_01p!0 = "year"
  rcm_hist_JJA_01p!1 = "lat"
  rcm_hist_JJA_01p!2 = "lon"
  rcm_hist_JJA_01p&year = hist_years
  rcm_hist_JJA_01p&lat = lat
  rcm_hist_JJA_01p&lon = lon

  rcm_hist_SON_avg = new((/window, nlat, nlon/), float) ; average
  rcm_hist_SON_avg!0 = "year"
  rcm_hist_SON_avg!1 = "lat"
  rcm_hist_SON_avg!2 = "lon"
  rcm_hist_SON_avg&year = hist_years
  rcm_hist_SON_avg&lat = lat
  rcm_hist_SON_avg&lon = lon
  rcm_hist_SON_var = new((/window, nlat, nlon/), float) ; variance
  rcm_hist_SON_var!0 = "year"
  rcm_hist_SON_var!1 = "lat"
  rcm_hist_SON_var!2 = "lon"
  rcm_hist_SON_var&year = hist_years
  rcm_hist_SON_var&lat = lat
  rcm_hist_SON_var&lon = lon
  rcm_hist_SON_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  rcm_hist_SON_99p!0 = "year"
  rcm_hist_SON_99p!1 = "lat"
  rcm_hist_SON_99p!2 = "lon"
  rcm_hist_SON_99p&year = hist_years
  rcm_hist_SON_99p&lat = lat
  rcm_hist_SON_99p&lon = lon
  rcm_hist_SON_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  rcm_hist_SON_01p!0 = "year"
  rcm_hist_SON_01p!1 = "lat"
  rcm_hist_SON_01p!2 = "lon"
  rcm_hist_SON_01p&year = hist_years
  rcm_hist_SON_01p&lat = lat
  rcm_hist_SON_01p&lon = lon

  rcm_fut_DJF_avg = new((/window, nlat, nlon/), float) ; average
  rcm_fut_DJF_avg!0 = "year"
  rcm_fut_DJF_avg!1 = "lat"
  rcm_fut_DJF_avg!2 = "lon"
  rcm_fut_DJF_avg&year = fut_years
  rcm_fut_DJF_avg&lat = lat
  rcm_fut_DJF_avg&lon = lon
  rcm_fut_DJF_var = new((/window, nlat, nlon/), float) ; variance
  rcm_fut_DJF_var!0 = "year"
  rcm_fut_DJF_var!1 = "lat"
  rcm_fut_DJF_var!2 = "lon"
  rcm_fut_DJF_var&year = fut_years
  rcm_fut_DJF_var&lat = lat
  rcm_fut_DJF_var&lon = lon
  rcm_fut_DJF_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  rcm_fut_DJF_99p!0 = "year"
  rcm_fut_DJF_99p!1 = "lat"
  rcm_fut_DJF_99p!2 = "lon"
  rcm_fut_DJF_99p&year = fut_years
  rcm_fut_DJF_99p&lat = lat
  rcm_fut_DJF_99p&lon = lon
  rcm_fut_DJF_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  rcm_fut_DJF_01p!0 = "year"
  rcm_fut_DJF_01p!1 = "lat"
  rcm_fut_DJF_01p!2 = "lon"
  rcm_fut_DJF_01p&year = fut_years
  rcm_fut_DJF_01p&lat = lat
  rcm_fut_DJF_01p&lon = lon

  rcm_fut_MAM_avg = new((/window, nlat, nlon/), float) ; average
  rcm_fut_MAM_avg!0 = "year"
  rcm_fut_MAM_avg!1 = "lat"
  rcm_fut_MAM_avg!2 = "lon"
  rcm_fut_MAM_avg&year = fut_years
  rcm_fut_MAM_avg&lat = lat
  rcm_fut_MAM_avg&lon = lon
  rcm_fut_MAM_var = new((/window, nlat, nlon/), float) ; variance
  rcm_fut_MAM_var!0 = "year"
  rcm_fut_MAM_var!1 = "lat"
  rcm_fut_MAM_var!2 = "lon"
  rcm_fut_MAM_var&year = fut_years
  rcm_fut_MAM_var&lat = lat
  rcm_fut_MAM_var&lon = lon
  rcm_fut_MAM_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  rcm_fut_MAM_99p!0 = "year"
  rcm_fut_MAM_99p!1 = "lat"
  rcm_fut_MAM_99p!2 = "lon"
  rcm_fut_MAM_99p&year = fut_years
  rcm_fut_MAM_99p&lat = lat
  rcm_fut_MAM_99p&lon = lon
  rcm_fut_MAM_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  rcm_fut_MAM_01p!0 = "year"
  rcm_fut_MAM_01p!1 = "lat"
  rcm_fut_MAM_01p!2 = "lon"
  rcm_fut_MAM_01p&year = fut_years
  rcm_fut_MAM_01p&lat = lat
  rcm_fut_MAM_01p&lon = lon

  rcm_fut_JJA_avg = new((/window, nlat, nlon/), float) ; average
  rcm_fut_JJA_avg!0 = "year"
  rcm_fut_JJA_avg!1 = "lat"
  rcm_fut_JJA_avg!2 = "lon"
  rcm_fut_JJA_avg&year = fut_years
  rcm_fut_JJA_avg&lat = lat
  rcm_fut_JJA_avg&lon = lon
  rcm_fut_JJA_var = new((/window, nlat, nlon/), float) ; variance
  rcm_fut_JJA_var!0 = "year"
  rcm_fut_JJA_var!1 = "lat"
  rcm_fut_JJA_var!2 = "lon"
  rcm_fut_JJA_var&year = fut_years
  rcm_fut_JJA_var&lat = lat
  rcm_fut_JJA_var&lon = lon
  rcm_fut_JJA_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  rcm_fut_JJA_99p!0 = "year"
  rcm_fut_JJA_99p!1 = "lat"
  rcm_fut_JJA_99p!2 = "lon"
  rcm_fut_JJA_99p&year = fut_years
  rcm_fut_JJA_99p&lat = lat
  rcm_fut_JJA_99p&lon = lon
  rcm_fut_JJA_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  rcm_fut_JJA_01p!0 = "year"
  rcm_fut_JJA_01p!1 = "lat"
  rcm_fut_JJA_01p!2 = "lon"
  rcm_fut_JJA_01p&year = fut_years
  rcm_fut_JJA_01p&lat = lat
  rcm_fut_JJA_01p&lon = lon

  rcm_fut_SON_avg = new((/window, nlat, nlon/), float) ; average
  rcm_fut_SON_avg!0 = "year"
  rcm_fut_SON_avg!1 = "lat"
  rcm_fut_SON_avg!2 = "lon"
  rcm_fut_SON_avg&year = fut_years
  rcm_fut_SON_avg&lat = lat
  rcm_fut_SON_avg&lon = lon
  rcm_fut_SON_var = new((/window, nlat, nlon/), float) ; variance
  rcm_fut_SON_var!0 = "year"
  rcm_fut_SON_var!1 = "lat"
  rcm_fut_SON_var!2 = "lon"
  rcm_fut_SON_var&year = fut_years
  rcm_fut_SON_var&lat = lat
  rcm_fut_SON_var&lon = lon
  rcm_fut_SON_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  rcm_fut_SON_99p!0 = "year"
  rcm_fut_SON_99p!1 = "lat"
  rcm_fut_SON_99p!2 = "lon"
  rcm_fut_SON_99p&year = fut_years
  rcm_fut_SON_99p&lat = lat
  rcm_fut_SON_99p&lon = lon
  rcm_fut_SON_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  rcm_fut_SON_01p!0 = "year"
  rcm_fut_SON_01p!1 = "lat"
  rcm_fut_SON_01p!2 = "lon"
  rcm_fut_SON_01p&year = fut_years
  rcm_fut_SON_01p&lat = lat
  rcm_fut_SON_01p&lon = lon

  gdd_hist_DJF_avg = new((/window, nlat, nlon/), float) ; average
  gdd_hist_DJF_avg!0 = "year"
  gdd_hist_DJF_avg!1 = "lat"
  gdd_hist_DJF_avg!2 = "lon"
  gdd_hist_DJF_avg&year = hist_years
  gdd_hist_DJF_avg&lat = lat
  gdd_hist_DJF_avg&lon = lon
  gdd_hist_DJF_var = new((/window, nlat, nlon/), float) ; variance
  gdd_hist_DJF_var!0 = "year"
  gdd_hist_DJF_var!1 = "lat"
  gdd_hist_DJF_var!2 = "lon"
  gdd_hist_DJF_var&year = hist_years
  gdd_hist_DJF_var&lat = lat
  gdd_hist_DJF_var&lon = lon
  gdd_hist_DJF_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  gdd_hist_DJF_99p!0 = "year"
  gdd_hist_DJF_99p!1 = "lat"
  gdd_hist_DJF_99p!2 = "lon"
  gdd_hist_DJF_99p&year = hist_years
  gdd_hist_DJF_99p&lat = lat
  gdd_hist_DJF_99p&lon = lon
  gdd_hist_DJF_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  gdd_hist_DJF_01p!0 = "year"
  gdd_hist_DJF_01p!1 = "lat"
  gdd_hist_DJF_01p!2 = "lon"
  gdd_hist_DJF_01p&year = hist_years
  gdd_hist_DJF_01p&lat = lat
  gdd_hist_DJF_01p&lon = lon

  gdd_hist_MAM_avg = new((/window, nlat, nlon/), float) ; average
  gdd_hist_MAM_avg!0 = "year"
  gdd_hist_MAM_avg!1 = "lat"
  gdd_hist_MAM_avg!2 = "lon"
  gdd_hist_MAM_avg&year = hist_years
  gdd_hist_MAM_avg&lat = lat
  gdd_hist_MAM_avg&lon = lon
  gdd_hist_MAM_var = new((/window, nlat, nlon/), float) ; variance
  gdd_hist_MAM_var!0 = "year"
  gdd_hist_MAM_var!1 = "lat"
  gdd_hist_MAM_var!2 = "lon"
  gdd_hist_MAM_var&year = hist_years
  gdd_hist_MAM_var&lat = lat
  gdd_hist_MAM_var&lon = lon
  gdd_hist_MAM_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  gdd_hist_MAM_99p!0 = "year"
  gdd_hist_MAM_99p!1 = "lat"
  gdd_hist_MAM_99p!2 = "lon"
  gdd_hist_MAM_99p&year = hist_years
  gdd_hist_MAM_99p&lat = lat
  gdd_hist_MAM_99p&lon = lon
  gdd_hist_MAM_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  gdd_hist_MAM_01p!0 = "year"
  gdd_hist_MAM_01p!1 = "lat"
  gdd_hist_MAM_01p!2 = "lon"
  gdd_hist_MAM_01p&year = hist_years
  gdd_hist_MAM_01p&lat = lat
  gdd_hist_MAM_01p&lon = lon

  gdd_hist_JJA_avg = new((/window, nlat, nlon/), float) ; average
  gdd_hist_JJA_avg!0 = "year"
  gdd_hist_JJA_avg!1 = "lat"
  gdd_hist_JJA_avg!2 = "lon"
  gdd_hist_JJA_avg&year = hist_years
  gdd_hist_JJA_avg&lat = lat
  gdd_hist_JJA_avg&lon = lon
  gdd_hist_JJA_var = new((/window, nlat, nlon/), float) ; variance
  gdd_hist_JJA_var!0 = "year"
  gdd_hist_JJA_var!1 = "lat"
  gdd_hist_JJA_var!2 = "lon"
  gdd_hist_JJA_var&year = hist_years
  gdd_hist_JJA_var&lat = lat
  gdd_hist_JJA_var&lon = lon
  gdd_hist_JJA_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  gdd_hist_JJA_99p!0 = "year"
  gdd_hist_JJA_99p!1 = "lat"
  gdd_hist_JJA_99p!2 = "lon"
  gdd_hist_JJA_99p&year = hist_years
  gdd_hist_JJA_99p&lat = lat
  gdd_hist_JJA_99p&lon = lon
  gdd_hist_JJA_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  gdd_hist_JJA_01p!0 = "year"
  gdd_hist_JJA_01p!1 = "lat"
  gdd_hist_JJA_01p!2 = "lon"
  gdd_hist_JJA_01p&year = hist_years
  gdd_hist_JJA_01p&lat = lat
  gdd_hist_JJA_01p&lon = lon

  gdd_hist_SON_avg = new((/window, nlat, nlon/), float) ; average
  gdd_hist_SON_avg!0 = "year"
  gdd_hist_SON_avg!1 = "lat"
  gdd_hist_SON_avg!2 = "lon"
  gdd_hist_SON_avg&year = hist_years
  gdd_hist_SON_avg&lat = lat
  gdd_hist_SON_avg&lon = lon
  gdd_hist_SON_var = new((/window, nlat, nlon/), float) ; variance
  gdd_hist_SON_var!0 = "year"
  gdd_hist_SON_var!1 = "lat"
  gdd_hist_SON_var!2 = "lon"
  gdd_hist_SON_var&year = hist_years
  gdd_hist_SON_var&lat = lat
  gdd_hist_SON_var&lon = lon
  gdd_hist_SON_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  gdd_hist_SON_99p!0 = "year"
  gdd_hist_SON_99p!1 = "lat"
  gdd_hist_SON_99p!2 = "lon"
  gdd_hist_SON_99p&year = hist_years
  gdd_hist_SON_99p&lat = lat
  gdd_hist_SON_99p&lon = lon
  gdd_hist_SON_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  gdd_hist_SON_01p!0 = "year"
  gdd_hist_SON_01p!1 = "lat"
  gdd_hist_SON_01p!2 = "lon"
  gdd_hist_SON_01p&year = hist_years
  gdd_hist_SON_01p&lat = lat
  gdd_hist_SON_01p&lon = lon

  gdd_fut_DJF_avg = new((/window, nlat, nlon/), float) ; average
  gdd_fut_DJF_avg!0 = "year"
  gdd_fut_DJF_avg!1 = "lat"
  gdd_fut_DJF_avg!2 = "lon"
  gdd_fut_DJF_avg&year = fut_years
  gdd_fut_DJF_avg&lat = lat
  gdd_fut_DJF_avg&lon = lon
  gdd_fut_DJF_var = new((/window, nlat, nlon/), float) ; variance
  gdd_fut_DJF_var!0 = "year"
  gdd_fut_DJF_var!1 = "lat"
  gdd_fut_DJF_var!2 = "lon"
  gdd_fut_DJF_var&year = fut_years
  gdd_fut_DJF_var&lat = lat
  gdd_fut_DJF_var&lon = lon
  gdd_fut_DJF_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  gdd_fut_DJF_99p!0 = "year"
  gdd_fut_DJF_99p!1 = "lat"
  gdd_fut_DJF_99p!2 = "lon"
  gdd_fut_DJF_99p&year = fut_years
  gdd_fut_DJF_99p&lat = lat
  gdd_fut_DJF_99p&lon = lon
  gdd_fut_DJF_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  gdd_fut_DJF_01p!0 = "year"
  gdd_fut_DJF_01p!1 = "lat"
  gdd_fut_DJF_01p!2 = "lon"
  gdd_fut_DJF_01p&year = fut_years
  gdd_fut_DJF_01p&lat = lat
  gdd_fut_DJF_01p&lon = lon

  gdd_fut_MAM_avg = new((/window, nlat, nlon/), float) ; average
  gdd_fut_MAM_avg!0 = "year"
  gdd_fut_MAM_avg!1 = "lat"
  gdd_fut_MAM_avg!2 = "lon"
  gdd_fut_MAM_avg&year = fut_years
  gdd_fut_MAM_avg&lat = lat
  gdd_fut_MAM_avg&lon = lon
  gdd_fut_MAM_var = new((/window, nlat, nlon/), float) ; variance
  gdd_fut_MAM_var!0 = "year"
  gdd_fut_MAM_var!1 = "lat"
  gdd_fut_MAM_var!2 = "lon"
  gdd_fut_MAM_var&year = fut_years
  gdd_fut_MAM_var&lat = lat
  gdd_fut_MAM_var&lon = lon
  gdd_fut_MAM_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  gdd_fut_MAM_99p!0 = "year"
  gdd_fut_MAM_99p!1 = "lat"
  gdd_fut_MAM_99p!2 = "lon"
  gdd_fut_MAM_99p&year = fut_years
  gdd_fut_MAM_99p&lat = lat
  gdd_fut_MAM_99p&lon = lon
  gdd_fut_MAM_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  gdd_fut_MAM_01p!0 = "year"
  gdd_fut_MAM_01p!1 = "lat"
  gdd_fut_MAM_01p!2 = "lon"
  gdd_fut_MAM_01p&year = fut_years
  gdd_fut_MAM_01p&lat = lat
  gdd_fut_MAM_01p&lon = lon

  gdd_fut_JJA_avg = new((/window, nlat, nlon/), float) ; average
  gdd_fut_JJA_avg!0 = "year"
  gdd_fut_JJA_avg!1 = "lat"
  gdd_fut_JJA_avg!2 = "lon"
  gdd_fut_JJA_avg&year = fut_years
  gdd_fut_JJA_avg&lat = lat
  gdd_fut_JJA_avg&lon = lon
  gdd_fut_JJA_var = new((/window, nlat, nlon/), float) ; variance
  gdd_fut_JJA_var!0 = "year"
  gdd_fut_JJA_var!1 = "lat"
  gdd_fut_JJA_var!2 = "lon"
  gdd_fut_JJA_var&year = fut_years
  gdd_fut_JJA_var&lat = lat
  gdd_fut_JJA_var&lon = lon
  gdd_fut_JJA_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  gdd_fut_JJA_99p!0 = "year"
  gdd_fut_JJA_99p!1 = "lat"
  gdd_fut_JJA_99p!2 = "lon"
  gdd_fut_JJA_99p&year = fut_years
  gdd_fut_JJA_99p&lat = lat
  gdd_fut_JJA_99p&lon = lon
  gdd_fut_JJA_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  gdd_fut_JJA_01p!0 = "year"
  gdd_fut_JJA_01p!1 = "lat"
  gdd_fut_JJA_01p!2 = "lon"
  gdd_fut_JJA_01p&year = fut_years
  gdd_fut_JJA_01p&lat = lat
  gdd_fut_JJA_01p&lon = lon

  gdd_fut_SON_avg = new((/window, nlat, nlon/), float) ; average
  gdd_fut_SON_avg!0 = "year"
  gdd_fut_SON_avg!1 = "lat"
  gdd_fut_SON_avg!2 = "lon"
  gdd_fut_SON_avg&year = fut_years
  gdd_fut_SON_avg&lat = lat
  gdd_fut_SON_avg&lon = lon
  gdd_fut_SON_var = new((/window, nlat, nlon/), float) ; variance
  gdd_fut_SON_var!0 = "year"
  gdd_fut_SON_var!1 = "lat"
  gdd_fut_SON_var!2 = "lon"
  gdd_fut_SON_var&year = fut_years
  gdd_fut_SON_var&lat = lat
  gdd_fut_SON_var&lon = lon
  gdd_fut_SON_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  gdd_fut_SON_99p!0 = "year"
  gdd_fut_SON_99p!1 = "lat"
  gdd_fut_SON_99p!2 = "lon"
  gdd_fut_SON_99p&year = fut_years
  gdd_fut_SON_99p&lat = lat
  gdd_fut_SON_99p&lon = lon
  gdd_fut_SON_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  gdd_fut_SON_01p!0 = "year"
  gdd_fut_SON_01p!1 = "lat"
  gdd_fut_SON_01p!2 = "lon"
  gdd_fut_SON_01p&year = fut_years
  gdd_fut_SON_01p&lat = lat
  gdd_fut_SON_01p&lon = lon

  obs_DJF_avg = new((/window, nlat, nlon/), float) ; average
  obs_DJF_avg!0 = "year"
  obs_DJF_avg!1 = "lat"
  obs_DJF_avg!2 = "lon"
  obs_DJF_avg&year = hist_years
  obs_DJF_avg&lat = lat
  obs_DJF_avg&lon = lon
  obs_DJF_var = new((/window, nlat, nlon/), float) ; variance
  obs_DJF_var!0 = "year"
  obs_DJF_var!1 = "lat"
  obs_DJF_var!2 = "lon"
  obs_DJF_var&year = hist_years
  obs_DJF_var&lat = lat
  obs_DJF_var&lon = lon
  obs_DJF_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_DJF_99p!0 = "year"
  obs_DJF_99p!1 = "lat"
  obs_DJF_99p!2 = "lon"
  obs_DJF_99p&year = hist_years
  obs_DJF_99p&lat = lat
  obs_DJF_99p&lon = lon
  obs_DJF_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_DJF_01p!0 = "year"
  obs_DJF_01p!1 = "lat"
  obs_DJF_01p!2 = "lon"
  obs_DJF_01p&year = hist_years
  obs_DJF_01p&lat = lat
  obs_DJF_01p&lon = lon

  obs_MAM_avg = new((/window, nlat, nlon/), float) ; average
  obs_MAM_avg!0 = "year"
  obs_MAM_avg!1 = "lat"
  obs_MAM_avg!2 = "lon"
  obs_MAM_avg&year = hist_years
  obs_MAM_avg&lat = lat
  obs_MAM_avg&lon = lon
  obs_MAM_var = new((/window, nlat, nlon/), float) ; variance
  obs_MAM_var!0 = "year"
  obs_MAM_var!1 = "lat"
  obs_MAM_var!2 = "lon"
  obs_MAM_var&year = hist_years
  obs_MAM_var&lat = lat
  obs_MAM_var&lon = lon
  obs_MAM_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_MAM_99p!0 = "year"
  obs_MAM_99p!1 = "lat"
  obs_MAM_99p!2 = "lon"
  obs_MAM_99p&year = hist_years
  obs_MAM_99p&lat = lat
  obs_MAM_99p&lon = lon
  obs_MAM_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_MAM_01p!0 = "year"
  obs_MAM_01p!1 = "lat"
  obs_MAM_01p!2 = "lon"
  obs_MAM_01p&year = hist_years
  obs_MAM_01p&lat = lat
  obs_MAM_01p&lon = lon

  obs_JJA_avg = new((/window, nlat, nlon/), float) ; average
  obs_JJA_avg!0 = "year"
  obs_JJA_avg!1 = "lat"
  obs_JJA_avg!2 = "lon"
  obs_JJA_avg&year = hist_years
  obs_JJA_avg&lat = lat
  obs_JJA_avg&lon = lon
  obs_JJA_var = new((/window, nlat, nlon/), float) ; variance
  obs_JJA_var!0 = "year"
  obs_JJA_var!1 = "lat"
  obs_JJA_var!2 = "lon"
  obs_JJA_var&year = hist_years
  obs_JJA_var&lat = lat
  obs_JJA_var&lon = lon
  obs_JJA_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_JJA_99p!0 = "year"
  obs_JJA_99p!1 = "lat"
  obs_JJA_99p!2 = "lon"
  obs_JJA_99p&year = hist_years
  obs_JJA_99p&lat = lat
  obs_JJA_99p&lon = lon
  obs_JJA_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_JJA_01p!0 = "year"
  obs_JJA_01p!1 = "lat"
  obs_JJA_01p!2 = "lon"
  obs_JJA_01p&year = hist_years
  obs_JJA_01p&lat = lat
  obs_JJA_01p&lon = lon

  obs_SON_avg = new((/window, nlat, nlon/), float) ; average
  obs_SON_avg!0 = "year"
  obs_SON_avg!1 = "lat"
  obs_SON_avg!2 = "lon"
  obs_SON_avg&year = hist_years
  obs_SON_avg&lat = lat
  obs_SON_avg&lon = lon
  obs_SON_var = new((/window, nlat, nlon/), float) ; variance
  obs_SON_var!0 = "year"
  obs_SON_var!1 = "lat"
  obs_SON_var!2 = "lon"
  obs_SON_var&year = hist_years
  obs_SON_var&lat = lat
  obs_SON_var&lon = lon
  obs_SON_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_SON_99p!0 = "year"
  obs_SON_99p!1 = "lat"
  obs_SON_99p!2 = "lon"
  obs_SON_99p&year = hist_years
  obs_SON_99p&lat = lat
  obs_SON_99p&lon = lon
  obs_SON_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_SON_01p!0 = "year"
  obs_SON_01p!1 = "lat"
  obs_SON_01p!2 = "lon"
  obs_SON_01p&year = hist_years
  obs_SON_01p&lat = lat
  obs_SON_01p&lon = lon

;******************************
;******************************
  print(systemfunc("date"))
  print("Looping over years")
  do nyrc=0, window-1
    print(nyrc)
    print(systemfunc("date"))
    hist_yrs = min(hist_year)+nyrc
    hist_yr_sel = ind(hist_year.eq.hist_yrs)
    fut_yrs = min(fut_year)+nyrc
    fut_yr_sel = ind(fut_year.eq.fut_yrs)

    rcm_hist_temp = rcm_hist(hist_yr_sel,:,:)
    rcm_fut_temp = rcm_fut(fut_yr_sel,:,:)
    gdd_hist_temp = gdd_hist(hist_yr_sel,:,:)
    gdd_fut_temp = gdd_fut(fut_yr_sel,:,:)
    obs_temp = obs(hist_yr_sel,:,:)

; select seasons. December has been shifted to be the same year as JF
    hist_date_sel = cd_calendar(rcm_hist_temp&time, 0)
    hist_date_mth = hist_date_sel(:,1)

    hist_date_DJF = ind(hist_date_mth.eq.1.or.hist_date_mth.eq.2.or.hist_date_mth.eq.12)
    hist_date_MAM = ind(hist_date_mth.eq.3.or.hist_date_mth.eq.4.or.hist_date_mth.eq.5)
    hist_date_JJA = ind(hist_date_mth.eq.6.or.hist_date_mth.eq.7.or.hist_date_mth.eq.8)
    hist_date_SON = ind(hist_date_mth.eq.9.or.hist_date_mth.eq.10.or.hist_date_mth.eq.11)

    fut_date_sel = cd_calendar(rcm_fut_temp&time, 0)
    fut_date_mth = fut_date_sel(:,1)

    fut_date_DJF = ind(fut_date_mth.eq.1.or.fut_date_mth.eq.2.or.fut_date_mth.eq.12)
    fut_date_MAM = ind(fut_date_mth.eq.3.or.fut_date_mth.eq.4.or.fut_date_mth.eq.5)
    fut_date_JJA = ind(fut_date_mth.eq.6.or.fut_date_mth.eq.7.or.fut_date_mth.eq.8)
    fut_date_SON = ind(fut_date_mth.eq.9.or.fut_date_mth.eq.10.or.fut_date_mth.eq.11)

    rcm_hist_temp_DJF = rcm_hist_temp(hist_date_DJF,:,:)
    rcm_hist_temp_MAM = rcm_hist_temp(hist_date_MAM,:,:)
    rcm_hist_temp_JJA = rcm_hist_temp(hist_date_JJA,:,:)
    rcm_hist_temp_SON = rcm_hist_temp(hist_date_SON,:,:)

    rcm_fut_temp_DJF = rcm_fut_temp(fut_date_DJF,:,:)
    rcm_fut_temp_MAM = rcm_fut_temp(fut_date_MAM,:,:)
    rcm_fut_temp_JJA = rcm_fut_temp(fut_date_JJA,:,:)
    rcm_fut_temp_SON = rcm_fut_temp(fut_date_SON,:,:)

    gdd_hist_temp_DJF = gdd_hist_temp(hist_date_DJF,:,:)
    gdd_hist_temp_MAM = gdd_hist_temp(hist_date_MAM,:,:)
    gdd_hist_temp_JJA = gdd_hist_temp(hist_date_JJA,:,:)
    gdd_hist_temp_SON = gdd_hist_temp(hist_date_SON,:,:)

    gdd_fut_temp_DJF = gdd_fut_temp(fut_date_DJF,:,:)
    gdd_fut_temp_MAM = gdd_fut_temp(fut_date_MAM,:,:)
    gdd_fut_temp_JJA = gdd_fut_temp(fut_date_JJA,:,:)
    gdd_fut_temp_SON = gdd_fut_temp(fut_date_SON,:,:)

    obs_temp_DJF = obs_temp(hist_date_DJF,:,:)
    obs_temp_MAM = obs_temp(hist_date_MAM,:,:)
    obs_temp_JJA = obs_temp(hist_date_JJA,:,:)
    obs_temp_SON = obs_temp(hist_date_SON,:,:)

; calculate stats
    rcm_hist_temp_DJF_avg = dim_avg_n_Wrap(rcm_hist_temp_DJF, 0)
    rcm_hist_temp_DJF_var = dim_variance_n_Wrap(rcm_hist_temp_DJF, 0)
    rcm_hist_temp_DJF_99p = percent_to_value_2d(rcm_hist_temp_DJF, 99)
    rcm_hist_temp_DJF_01p = percent_to_value_2d(rcm_hist_temp_DJF, 1)
    rcm_hist_temp_MAM_avg = dim_avg_n_Wrap(rcm_hist_temp_MAM, 0)
    rcm_hist_temp_MAM_var = dim_variance_n_Wrap(rcm_hist_temp_MAM, 0)
    rcm_hist_temp_MAM_99p = percent_to_value_2d(rcm_hist_temp_MAM, 99)
    rcm_hist_temp_MAM_01p = percent_to_value_2d(rcm_hist_temp_MAM, 1)
    rcm_hist_temp_JJA_avg = dim_avg_n_Wrap(rcm_hist_temp_JJA, 0)
    rcm_hist_temp_JJA_var = dim_variance_n_Wrap(rcm_hist_temp_JJA, 0)
    rcm_hist_temp_JJA_99p = percent_to_value_2d(rcm_hist_temp_JJA, 99)
    rcm_hist_temp_JJA_01p = percent_to_value_2d(rcm_hist_temp_JJA, 1)
    rcm_hist_temp_SON_avg = dim_avg_n_Wrap(rcm_hist_temp_SON, 0)
    rcm_hist_temp_SON_var = dim_variance_n_Wrap(rcm_hist_temp_SON, 0)
    rcm_hist_temp_SON_99p = percent_to_value_2d(rcm_hist_temp_SON, 99)
    rcm_hist_temp_SON_01p = percent_to_value_2d(rcm_hist_temp_SON, 1)

    rcm_fut_temp_DJF_avg = dim_avg_n_Wrap(rcm_fut_temp_DJF, 0)
    rcm_fut_temp_DJF_var = dim_variance_n_Wrap(rcm_fut_temp_DJF, 0)
    rcm_fut_temp_DJF_99p = percent_to_value_2d(rcm_fut_temp_DJF, 99)
    rcm_fut_temp_DJF_01p = percent_to_value_2d(rcm_fut_temp_DJF, 1)
    rcm_fut_temp_MAM_avg = dim_avg_n_Wrap(rcm_fut_temp_MAM, 0)
    rcm_fut_temp_MAM_var = dim_variance_n_Wrap(rcm_fut_temp_MAM, 0)
    rcm_fut_temp_MAM_99p = percent_to_value_2d(rcm_fut_temp_MAM, 99)
    rcm_fut_temp_MAM_01p = percent_to_value_2d(rcm_fut_temp_MAM, 1)
    rcm_fut_temp_JJA_avg = dim_avg_n_Wrap(rcm_fut_temp_JJA, 0)
    rcm_fut_temp_JJA_var = dim_variance_n_Wrap(rcm_fut_temp_JJA, 0)
    rcm_fut_temp_JJA_99p = percent_to_value_2d(rcm_fut_temp_JJA, 99)
    rcm_fut_temp_JJA_01p = percent_to_value_2d(rcm_fut_temp_JJA, 1)
    rcm_fut_temp_SON_avg = dim_avg_n_Wrap(rcm_fut_temp_SON, 0)
    rcm_fut_temp_SON_var = dim_variance_n_Wrap(rcm_fut_temp_SON, 0)
    rcm_fut_temp_SON_99p = percent_to_value_2d(rcm_fut_temp_SON, 99)
    rcm_fut_temp_SON_01p = percent_to_value_2d(rcm_fut_temp_SON, 1)

    gdd_hist_temp_DJF_avg = dim_avg_n_Wrap(gdd_hist_temp_DJF, 0)
    gdd_hist_temp_DJF_var = dim_variance_n_Wrap(gdd_hist_temp_DJF, 0)
    gdd_hist_temp_DJF_99p = percent_to_value_2d(gdd_hist_temp_DJF, 99)
    gdd_hist_temp_DJF_01p = percent_to_value_2d(gdd_hist_temp_DJF, 1)
    gdd_hist_temp_MAM_avg = dim_avg_n_Wrap(gdd_hist_temp_MAM, 0)
    gdd_hist_temp_MAM_var = dim_variance_n_Wrap(gdd_hist_temp_MAM, 0)
    gdd_hist_temp_MAM_99p = percent_to_value_2d(gdd_hist_temp_MAM, 99)
    gdd_hist_temp_MAM_01p = percent_to_value_2d(gdd_hist_temp_MAM, 1)
    gdd_hist_temp_JJA_avg = dim_avg_n_Wrap(gdd_hist_temp_JJA, 0)
    gdd_hist_temp_JJA_var = dim_variance_n_Wrap(gdd_hist_temp_JJA, 0)
    gdd_hist_temp_JJA_99p = percent_to_value_2d(gdd_hist_temp_JJA, 99)
    gdd_hist_temp_JJA_01p = percent_to_value_2d(gdd_hist_temp_JJA, 1)
    gdd_hist_temp_SON_avg = dim_avg_n_Wrap(gdd_hist_temp_SON, 0)
    gdd_hist_temp_SON_var = dim_variance_n_Wrap(gdd_hist_temp_SON, 0)
    gdd_hist_temp_SON_99p = percent_to_value_2d(gdd_hist_temp_SON, 99)
    gdd_hist_temp_SON_01p = percent_to_value_2d(gdd_hist_temp_SON, 1)

    gdd_fut_temp_DJF_avg = dim_avg_n_Wrap(gdd_fut_temp_DJF, 0)
    gdd_fut_temp_DJF_var = dim_variance_n_Wrap(gdd_fut_temp_DJF, 0)
    gdd_fut_temp_DJF_99p = percent_to_value_2d(gdd_fut_temp_DJF, 99)
    gdd_fut_temp_DJF_01p = percent_to_value_2d(gdd_fut_temp_DJF, 1)
    gdd_fut_temp_MAM_avg = dim_avg_n_Wrap(gdd_fut_temp_MAM, 0)
    gdd_fut_temp_MAM_var = dim_variance_n_Wrap(gdd_fut_temp_MAM, 0)
    gdd_fut_temp_MAM_99p = percent_to_value_2d(gdd_fut_temp_MAM, 99)
    gdd_fut_temp_MAM_01p = percent_to_value_2d(gdd_fut_temp_MAM, 1)
    gdd_fut_temp_JJA_avg = dim_avg_n_Wrap(gdd_fut_temp_JJA, 0)
    gdd_fut_temp_JJA_var = dim_variance_n_Wrap(gdd_fut_temp_JJA, 0)
    gdd_fut_temp_JJA_99p = percent_to_value_2d(gdd_fut_temp_JJA, 99)
    gdd_fut_temp_JJA_01p = percent_to_value_2d(gdd_fut_temp_JJA, 1)
    gdd_fut_temp_SON_avg = dim_avg_n_Wrap(gdd_fut_temp_SON, 0)
    gdd_fut_temp_SON_var = dim_variance_n_Wrap(gdd_fut_temp_SON, 0)
    gdd_fut_temp_SON_99p = percent_to_value_2d(gdd_fut_temp_SON, 99)
    gdd_fut_temp_SON_01p = percent_to_value_2d(gdd_fut_temp_SON, 1)

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

; put into array
    rcm_hist_DJF_avg(nyrc,:,:) = (/rcm_hist_temp_DJF_avg/)
    rcm_hist_DJF_var(nyrc,:,:) = (/rcm_hist_temp_DJF_var/)
    rcm_hist_DJF_99p(nyrc,:,:) = (/rcm_hist_temp_DJF_99p/)
    rcm_hist_DJF_01p(nyrc,:,:) = (/rcm_hist_temp_DJF_01p/)
    rcm_hist_MAM_avg(nyrc,:,:) = (/rcm_hist_temp_MAM_avg/)
    rcm_hist_MAM_var(nyrc,:,:) = (/rcm_hist_temp_MAM_var/)
    rcm_hist_MAM_99p(nyrc,:,:) = (/rcm_hist_temp_MAM_99p/)
    rcm_hist_MAM_01p(nyrc,:,:) = (/rcm_hist_temp_MAM_01p/)
    rcm_hist_JJA_avg(nyrc,:,:) = (/rcm_hist_temp_JJA_avg/)
    rcm_hist_JJA_var(nyrc,:,:) = (/rcm_hist_temp_JJA_var/)
    rcm_hist_JJA_99p(nyrc,:,:) = (/rcm_hist_temp_JJA_99p/)
    rcm_hist_JJA_01p(nyrc,:,:) = (/rcm_hist_temp_JJA_01p/)
    rcm_hist_SON_avg(nyrc,:,:) = (/rcm_hist_temp_SON_avg/)
    rcm_hist_SON_var(nyrc,:,:) = (/rcm_hist_temp_SON_var/)
    rcm_hist_SON_99p(nyrc,:,:) = (/rcm_hist_temp_SON_99p/)
    rcm_hist_SON_01p(nyrc,:,:) = (/rcm_hist_temp_SON_01p/)

    rcm_fut_DJF_avg(nyrc,:,:) = (/rcm_fut_temp_DJF_avg/)
    rcm_fut_DJF_var(nyrc,:,:) = (/rcm_fut_temp_DJF_var/)
    rcm_fut_DJF_99p(nyrc,:,:) = (/rcm_fut_temp_DJF_99p/)
    rcm_fut_DJF_01p(nyrc,:,:) = (/rcm_fut_temp_DJF_01p/)
    rcm_fut_MAM_avg(nyrc,:,:) = (/rcm_fut_temp_MAM_avg/)
    rcm_fut_MAM_var(nyrc,:,:) = (/rcm_fut_temp_MAM_var/)
    rcm_fut_MAM_99p(nyrc,:,:) = (/rcm_fut_temp_MAM_99p/)
    rcm_fut_MAM_01p(nyrc,:,:) = (/rcm_fut_temp_MAM_01p/)
    rcm_fut_JJA_avg(nyrc,:,:) = (/rcm_fut_temp_JJA_avg/)
    rcm_fut_JJA_var(nyrc,:,:) = (/rcm_fut_temp_JJA_var/)
    rcm_fut_JJA_99p(nyrc,:,:) = (/rcm_fut_temp_JJA_99p/)
    rcm_fut_JJA_01p(nyrc,:,:) = (/rcm_fut_temp_JJA_01p/)
    rcm_fut_SON_avg(nyrc,:,:) = (/rcm_fut_temp_SON_avg/)
    rcm_fut_SON_var(nyrc,:,:) = (/rcm_fut_temp_SON_var/)
    rcm_fut_SON_99p(nyrc,:,:) = (/rcm_fut_temp_SON_99p/)
    rcm_fut_SON_01p(nyrc,:,:) = (/rcm_fut_temp_SON_01p/)

    gdd_hist_DJF_avg(nyrc,:,:) = (/gdd_hist_temp_DJF_avg/)
    gdd_hist_DJF_var(nyrc,:,:) = (/gdd_hist_temp_DJF_var/)
    gdd_hist_DJF_99p(nyrc,:,:) = (/gdd_hist_temp_DJF_99p/)
    gdd_hist_DJF_01p(nyrc,:,:) = (/gdd_hist_temp_DJF_01p/)
    gdd_hist_MAM_avg(nyrc,:,:) = (/gdd_hist_temp_MAM_avg/)
    gdd_hist_MAM_var(nyrc,:,:) = (/gdd_hist_temp_MAM_var/)
    gdd_hist_MAM_99p(nyrc,:,:) = (/gdd_hist_temp_MAM_99p/)
    gdd_hist_MAM_01p(nyrc,:,:) = (/gdd_hist_temp_MAM_01p/)
    gdd_hist_JJA_avg(nyrc,:,:) = (/gdd_hist_temp_JJA_avg/)
    gdd_hist_JJA_var(nyrc,:,:) = (/gdd_hist_temp_JJA_var/)
    gdd_hist_JJA_99p(nyrc,:,:) = (/gdd_hist_temp_JJA_99p/)
    gdd_hist_JJA_01p(nyrc,:,:) = (/gdd_hist_temp_JJA_01p/)
    gdd_hist_SON_avg(nyrc,:,:) = (/gdd_hist_temp_SON_avg/)
    gdd_hist_SON_var(nyrc,:,:) = (/gdd_hist_temp_SON_var/)
    gdd_hist_SON_99p(nyrc,:,:) = (/gdd_hist_temp_SON_99p/)
    gdd_hist_SON_01p(nyrc,:,:) = (/gdd_hist_temp_SON_01p/)

    gdd_fut_DJF_avg(nyrc,:,:) = (/gdd_fut_temp_DJF_avg/)
    gdd_fut_DJF_var(nyrc,:,:) = (/gdd_fut_temp_DJF_var/)
    gdd_fut_DJF_99p(nyrc,:,:) = (/gdd_fut_temp_DJF_99p/)
    gdd_fut_DJF_01p(nyrc,:,:) = (/gdd_fut_temp_DJF_01p/)
    gdd_fut_MAM_avg(nyrc,:,:) = (/gdd_fut_temp_MAM_avg/)
    gdd_fut_MAM_var(nyrc,:,:) = (/gdd_fut_temp_MAM_var/)
    gdd_fut_MAM_99p(nyrc,:,:) = (/gdd_fut_temp_MAM_99p/)
    gdd_fut_MAM_01p(nyrc,:,:) = (/gdd_fut_temp_MAM_01p/)
    gdd_fut_JJA_avg(nyrc,:,:) = (/gdd_fut_temp_JJA_avg/)
    gdd_fut_JJA_var(nyrc,:,:) = (/gdd_fut_temp_JJA_var/)
    gdd_fut_JJA_99p(nyrc,:,:) = (/gdd_fut_temp_JJA_99p/)
    gdd_fut_JJA_01p(nyrc,:,:) = (/gdd_fut_temp_JJA_01p/)
    gdd_fut_SON_avg(nyrc,:,:) = (/gdd_fut_temp_SON_avg/)
    gdd_fut_SON_var(nyrc,:,:) = (/gdd_fut_temp_SON_var/)
    gdd_fut_SON_99p(nyrc,:,:) = (/gdd_fut_temp_SON_99p/)
    gdd_fut_SON_01p(nyrc,:,:) = (/gdd_fut_temp_SON_01p/)

    obs_DJF_avg(nyrc,:,:) = (/obs_temp_DJF_avg/)
    obs_DJF_var(nyrc,:,:) = (/obs_temp_DJF_var/)
    obs_DJF_99p(nyrc,:,:) = (/obs_temp_DJF_99p/)
    obs_DJF_01p(nyrc,:,:) = (/obs_temp_DJF_01p/)
    obs_MAM_avg(nyrc,:,:) = (/obs_temp_MAM_avg/)
    obs_MAM_var(nyrc,:,:) = (/obs_temp_MAM_var/)
    obs_MAM_99p(nyrc,:,:) = (/obs_temp_MAM_99p/)
    obs_MAM_01p(nyrc,:,:) = (/obs_temp_MAM_01p/)
    obs_JJA_avg(nyrc,:,:) = (/obs_temp_JJA_avg/)
    obs_JJA_var(nyrc,:,:) = (/obs_temp_JJA_var/)
    obs_JJA_99p(nyrc,:,:) = (/obs_temp_JJA_99p/)
    obs_JJA_01p(nyrc,:,:) = (/obs_temp_JJA_01p/)
    obs_SON_avg(nyrc,:,:) = (/obs_temp_SON_avg/)
    obs_SON_var(nyrc,:,:) = (/obs_temp_SON_var/)
    obs_SON_99p(nyrc,:,:) = (/obs_temp_SON_99p/)
    obs_SON_01p(nyrc,:,:) = (/obs_temp_SON_01p/)

; delete
    delete([/rcm_hist_temp, rcm_fut_temp, gdd_hist_temp, gdd_fut_temp, obs_temp, rcm_hist_temp_DJF_avg, rcm_hist_temp_DJF_var, rcm_hist_temp_DJF_99p, rcm_hist_temp_DJF_01p/])
    delete([/rcm_fut_temp_DJF_avg, rcm_fut_temp_DJF_var, rcm_fut_temp_DJF_99p, rcm_fut_temp_DJF_01p, gdd_hist_temp_DJF_avg, gdd_hist_temp_DJF_var, gdd_hist_temp_DJF_99p, gdd_hist_temp_DJF_01p/])
    delete([/gdd_fut_temp_DJF_avg, gdd_fut_temp_DJF_var, gdd_fut_temp_DJF_99p, gdd_fut_temp_DJF_01p, obs_temp_DJF_avg, obs_temp_DJF_var, obs_temp_DJF_99p, obs_temp_DJF_01p/])
    delete([/hist_yr_sel, hist_yrs, fut_yrs, fut_yr_sel, rcm_hist_temp_DJF, rcm_hist_temp_MAM, rcm_hist_temp_JJA, rcm_hist_temp_SON/])
    delete([/rcm_fut_temp_DJF, rcm_fut_temp_MAM, rcm_fut_temp_JJA, rcm_fut_temp_SON, gdd_hist_temp_DJF, gdd_hist_temp_MAM, gdd_hist_temp_JJA, gdd_hist_temp_SON/])
    delete([/gdd_fut_temp_DJF, gdd_fut_temp_MAM, gdd_fut_temp_JJA, gdd_fut_temp_SON, obs_temp_DJF, obs_temp_MAM, obs_temp_JJA, obs_temp_SON/])
    delete([/rcm_hist_temp_MAM_avg, rcm_hist_temp_MAM_var, rcm_hist_temp_MAM_99p, rcm_hist_temp_MAM_01p/])
    delete([/rcm_fut_temp_MAM_avg, rcm_fut_temp_MAM_var, rcm_fut_temp_MAM_99p, rcm_fut_temp_MAM_01p, gdd_hist_temp_MAM_avg, gdd_hist_temp_MAM_var, gdd_hist_temp_MAM_99p, gdd_hist_temp_MAM_01p/])
    delete([/gdd_fut_temp_MAM_avg, gdd_fut_temp_MAM_var, gdd_fut_temp_MAM_99p, gdd_fut_temp_MAM_01p, obs_temp_MAM_avg, obs_temp_MAM_var, obs_temp_MAM_99p, obs_temp_MAM_01p/])
    delete([/rcm_hist_temp_JJA_avg, rcm_hist_temp_JJA_var, rcm_hist_temp_JJA_99p, rcm_hist_temp_JJA_01p/])
    delete([/rcm_fut_temp_JJA_avg, rcm_fut_temp_JJA_var, rcm_fut_temp_JJA_99p, rcm_fut_temp_JJA_01p, gdd_hist_temp_JJA_avg, gdd_hist_temp_JJA_var, gdd_hist_temp_JJA_99p, gdd_hist_temp_JJA_01p/])
    delete([/gdd_fut_temp_JJA_avg, gdd_fut_temp_JJA_var, gdd_fut_temp_JJA_99p, gdd_fut_temp_JJA_01p, obs_temp_JJA_avg, obs_temp_JJA_var, obs_temp_JJA_99p, obs_temp_JJA_01p/])
    delete([/rcm_hist_temp_SON_avg, rcm_hist_temp_SON_var, rcm_hist_temp_SON_99p, rcm_hist_temp_SON_01p/])
    delete([/rcm_fut_temp_SON_avg, rcm_fut_temp_SON_var, rcm_fut_temp_SON_99p, rcm_fut_temp_SON_01p, gdd_hist_temp_SON_avg, gdd_hist_temp_SON_var, gdd_hist_temp_SON_99p, gdd_hist_temp_SON_01p/])
    delete([/gdd_fut_temp_SON_avg, gdd_fut_temp_SON_var, gdd_fut_temp_SON_99p, gdd_fut_temp_SON_01p, obs_temp_SON_avg, obs_temp_SON_var, obs_temp_SON_99p, obs_temp_SON_01p/])
    delete([/fut_date_sel, fut_date_mth, hist_date_sel, hist_date_mth, fut_date_DJF, fut_date_MAM, fut_date_JJA, fut_date_SON, hist_date_DJF, hist_date_MAM, hist_date_JJA, hist_date_SON/])
  end do

;******************************
;******************************
  print(systemfunc("date"))
  print("Finished looping over years, calculating AV, PAV, RAV")

  asciiwrite("rcm_hist_DJF_avg", rcm_hist_DJF_avg(:,{-37.5},{145}))
  asciiwrite("rcm_hist_MAM_avg", rcm_hist_MAM_avg(:,{-37.5},{145}))
  asciiwrite("rcm_hist_JJA_avg", rcm_hist_JJA_avg(:,{-37.5},{145}))
  asciiwrite("rcm_hist_SON_avg", rcm_hist_SON_avg(:,{-37.5},{145}))
  asciiwrite("rcm_fut_DJF_avg", rcm_fut_DJF_avg(:,{-37.5},{145}))
  asciiwrite("rcm_fut_MAM_avg", rcm_fut_MAM_avg(:,{-37.5},{145}))
  asciiwrite("rcm_fut_JJA_avg", rcm_fut_JJA_avg(:,{-37.5},{145}))
  asciiwrite("rcm_fut_SON_avg", rcm_fut_SON_avg(:,{-37.5},{145}))
  asciiwrite("gdd_hist_DJF_avg", gdd_hist_DJF_avg(:,{-37.5},{145}))
  asciiwrite("gdd_hist_MAM_avg", gdd_hist_MAM_avg(:,{-37.5},{145}))
  asciiwrite("gdd_hist_JJA_avg", gdd_hist_JJA_avg(:,{-37.5},{145}))
  asciiwrite("gdd_hist_SON_avg", gdd_hist_SON_avg(:,{-37.5},{145}))
  asciiwrite("gdd_fut_DJF_avg", gdd_fut_DJF_avg(:,{-37.5},{145}))
  asciiwrite("gdd_fut_MAM_avg", gdd_fut_MAM_avg(:,{-37.5},{145}))
  asciiwrite("gdd_fut_JJA_avg", gdd_fut_JJA_avg(:,{-37.5},{145}))
  asciiwrite("gdd_fut_SON_avg", gdd_fut_SON_avg(:,{-37.5},{145}))
  asciiwrite("obs_DJF_avg", obs_DJF_avg(:,{-37.5},{145}))
  asciiwrite("obs_MAM_avg", obs_MAM_avg(:,{-37.5},{145}))
  asciiwrite("obs_JJA_avg", obs_JJA_avg(:,{-37.5},{145}))
  asciiwrite("obs_SON_avg", obs_SON_avg(:,{-37.5},{145}))

; calculate avg, variance, percentiles annual mean
  rcm_hist_DJF_avg_clm = dim_avg_n_Wrap(rcm_hist_DJF_avg, 0)
  rcm_hist_DJF_var_clm = dim_avg_n_Wrap(rcm_hist_DJF_var, 0)
  rcm_hist_DJF_99p_clm = dim_avg_n_Wrap(rcm_hist_DJF_99p, 0)
  rcm_hist_DJF_01p_clm = dim_avg_n_Wrap(rcm_hist_DJF_01p, 0)
  rcm_hist_MAM_avg_clm = dim_avg_n_Wrap(rcm_hist_MAM_avg, 0)
  rcm_hist_MAM_var_clm = dim_avg_n_Wrap(rcm_hist_MAM_var, 0)
  rcm_hist_MAM_99p_clm = dim_avg_n_Wrap(rcm_hist_MAM_99p, 0)
  rcm_hist_MAM_01p_clm = dim_avg_n_Wrap(rcm_hist_MAM_01p, 0)
  rcm_hist_JJA_avg_clm = dim_avg_n_Wrap(rcm_hist_JJA_avg, 0)
  rcm_hist_JJA_var_clm = dim_avg_n_Wrap(rcm_hist_JJA_var, 0)
  rcm_hist_JJA_99p_clm = dim_avg_n_Wrap(rcm_hist_JJA_99p, 0)
  rcm_hist_JJA_01p_clm = dim_avg_n_Wrap(rcm_hist_JJA_01p, 0)
  rcm_hist_SON_avg_clm = dim_avg_n_Wrap(rcm_hist_SON_avg, 0)
  rcm_hist_SON_var_clm = dim_avg_n_Wrap(rcm_hist_SON_var, 0)
  rcm_hist_SON_99p_clm = dim_avg_n_Wrap(rcm_hist_SON_99p, 0)
  rcm_hist_SON_01p_clm = dim_avg_n_Wrap(rcm_hist_SON_01p, 0)

  rcm_fut_DJF_avg_clm = dim_avg_n_Wrap(rcm_fut_DJF_avg, 0)
  rcm_fut_DJF_var_clm = dim_avg_n_Wrap(rcm_fut_DJF_var, 0)
  rcm_fut_DJF_99p_clm = dim_avg_n_Wrap(rcm_fut_DJF_99p, 0)
  rcm_fut_DJF_01p_clm = dim_avg_n_Wrap(rcm_fut_DJF_01p, 0)
  rcm_fut_MAM_avg_clm = dim_avg_n_Wrap(rcm_fut_MAM_avg, 0)
  rcm_fut_MAM_var_clm = dim_avg_n_Wrap(rcm_fut_MAM_var, 0)
  rcm_fut_MAM_99p_clm = dim_avg_n_Wrap(rcm_fut_MAM_99p, 0)
  rcm_fut_MAM_01p_clm = dim_avg_n_Wrap(rcm_fut_MAM_01p, 0)
  rcm_fut_JJA_avg_clm = dim_avg_n_Wrap(rcm_fut_JJA_avg, 0)
  rcm_fut_JJA_var_clm = dim_avg_n_Wrap(rcm_fut_JJA_var, 0)
  rcm_fut_JJA_99p_clm = dim_avg_n_Wrap(rcm_fut_JJA_99p, 0)
  rcm_fut_JJA_01p_clm = dim_avg_n_Wrap(rcm_fut_JJA_01p, 0)
  rcm_fut_SON_avg_clm = dim_avg_n_Wrap(rcm_fut_SON_avg, 0)
  rcm_fut_SON_var_clm = dim_avg_n_Wrap(rcm_fut_SON_var, 0)
  rcm_fut_SON_99p_clm = dim_avg_n_Wrap(rcm_fut_SON_99p, 0)
  rcm_fut_SON_01p_clm = dim_avg_n_Wrap(rcm_fut_SON_01p, 0)

  gdd_hist_DJF_avg_clm = dim_avg_n_Wrap(gdd_hist_DJF_avg, 0)
  gdd_hist_DJF_var_clm = dim_avg_n_Wrap(gdd_hist_DJF_var, 0)
  gdd_hist_DJF_99p_clm = dim_avg_n_Wrap(gdd_hist_DJF_99p, 0)
  gdd_hist_DJF_01p_clm = dim_avg_n_Wrap(gdd_hist_DJF_01p, 0)
  gdd_hist_MAM_avg_clm = dim_avg_n_Wrap(gdd_hist_MAM_avg, 0)
  gdd_hist_MAM_var_clm = dim_avg_n_Wrap(gdd_hist_MAM_var, 0)
  gdd_hist_MAM_99p_clm = dim_avg_n_Wrap(gdd_hist_MAM_99p, 0)
  gdd_hist_MAM_01p_clm = dim_avg_n_Wrap(gdd_hist_MAM_01p, 0)
  gdd_hist_JJA_avg_clm = dim_avg_n_Wrap(gdd_hist_JJA_avg, 0)
  gdd_hist_JJA_var_clm = dim_avg_n_Wrap(gdd_hist_JJA_var, 0)
  gdd_hist_JJA_99p_clm = dim_avg_n_Wrap(gdd_hist_JJA_99p, 0)
  gdd_hist_JJA_01p_clm = dim_avg_n_Wrap(gdd_hist_JJA_01p, 0)
  gdd_hist_SON_avg_clm = dim_avg_n_Wrap(gdd_hist_SON_avg, 0)
  gdd_hist_SON_var_clm = dim_avg_n_Wrap(gdd_hist_SON_var, 0)
  gdd_hist_SON_99p_clm = dim_avg_n_Wrap(gdd_hist_SON_99p, 0)
  gdd_hist_SON_01p_clm = dim_avg_n_Wrap(gdd_hist_SON_01p, 0)

  gdd_fut_DJF_avg_clm = dim_avg_n_Wrap(gdd_fut_DJF_avg, 0)
  gdd_fut_DJF_var_clm = dim_avg_n_Wrap(gdd_fut_DJF_var, 0)
  gdd_fut_DJF_99p_clm = dim_avg_n_Wrap(gdd_fut_DJF_99p, 0)
  gdd_fut_DJF_01p_clm = dim_avg_n_Wrap(gdd_fut_DJF_01p, 0)
  gdd_fut_MAM_avg_clm = dim_avg_n_Wrap(gdd_fut_MAM_avg, 0)
  gdd_fut_MAM_var_clm = dim_avg_n_Wrap(gdd_fut_MAM_var, 0)
  gdd_fut_MAM_99p_clm = dim_avg_n_Wrap(gdd_fut_MAM_99p, 0)
  gdd_fut_MAM_01p_clm = dim_avg_n_Wrap(gdd_fut_MAM_01p, 0)
  gdd_fut_JJA_avg_clm = dim_avg_n_Wrap(gdd_fut_JJA_avg, 0)
  gdd_fut_JJA_var_clm = dim_avg_n_Wrap(gdd_fut_JJA_var, 0)
  gdd_fut_JJA_99p_clm = dim_avg_n_Wrap(gdd_fut_JJA_99p, 0)
  gdd_fut_JJA_01p_clm = dim_avg_n_Wrap(gdd_fut_JJA_01p, 0)
  gdd_fut_SON_avg_clm = dim_avg_n_Wrap(gdd_fut_SON_avg, 0)
  gdd_fut_SON_var_clm = dim_avg_n_Wrap(gdd_fut_SON_var, 0)
  gdd_fut_SON_99p_clm = dim_avg_n_Wrap(gdd_fut_SON_99p, 0)
  gdd_fut_SON_01p_clm = dim_avg_n_Wrap(gdd_fut_SON_01p, 0)

  obs_DJF_avg_clm = dim_avg_n_Wrap(obs_DJF_avg, 0)
  obs_DJF_var_clm = dim_avg_n_Wrap(obs_DJF_var, 0)
  obs_DJF_99p_clm = dim_avg_n_Wrap(obs_DJF_99p, 0)
  obs_DJF_01p_clm = dim_avg_n_Wrap(obs_DJF_01p, 0)
  obs_MAM_avg_clm = dim_avg_n_Wrap(obs_MAM_avg, 0)
  obs_MAM_var_clm = dim_avg_n_Wrap(obs_MAM_var, 0)
  obs_MAM_99p_clm = dim_avg_n_Wrap(obs_MAM_99p, 0)
  obs_MAM_01p_clm = dim_avg_n_Wrap(obs_MAM_01p, 0)
  obs_JJA_avg_clm = dim_avg_n_Wrap(obs_JJA_avg, 0)
  obs_JJA_var_clm = dim_avg_n_Wrap(obs_JJA_var, 0)
  obs_JJA_99p_clm = dim_avg_n_Wrap(obs_JJA_99p, 0)
  obs_JJA_01p_clm = dim_avg_n_Wrap(obs_JJA_01p, 0)
  obs_SON_avg_clm = dim_avg_n_Wrap(obs_SON_avg, 0)
  obs_SON_var_clm = dim_avg_n_Wrap(obs_SON_var, 0)
  obs_SON_99p_clm = dim_avg_n_Wrap(obs_SON_99p, 0)
  obs_SON_01p_clm = dim_avg_n_Wrap(obs_SON_01p, 0)

; calculate Added Value (AV) for avg, variance, percentiles
  rcm_DJF_avg_rmse = rcm_hist_DJF_avg_clm
  rcm_DJF_avg_rmse = sqrt((rcm_hist_DJF_avg_clm - obs_DJF_avg_clm)^2)
  rcm_DJF_var_rmse = rcm_hist_DJF_var_clm
  rcm_DJF_var_rmse = sqrt((rcm_hist_DJF_var_clm - obs_DJF_var_clm)^2)
  rcm_DJF_99p_rmse = rcm_hist_DJF_99p_clm
  rcm_DJF_99p_rmse = sqrt((rcm_hist_DJF_99p_clm - obs_DJF_99p_clm)^2)
  rcm_DJF_01p_rmse = rcm_hist_DJF_01p_clm
  rcm_DJF_01p_rmse = sqrt((rcm_hist_DJF_01p_clm - obs_DJF_01p_clm)^2)
  rcm_MAM_avg_rmse = rcm_hist_MAM_avg_clm
  rcm_MAM_avg_rmse = sqrt((rcm_hist_MAM_avg_clm - obs_MAM_avg_clm)^2)
  rcm_MAM_var_rmse = rcm_hist_MAM_var_clm
  rcm_MAM_var_rmse = sqrt((rcm_hist_MAM_var_clm - obs_MAM_var_clm)^2)
  rcm_MAM_99p_rmse = rcm_hist_MAM_99p_clm
  rcm_MAM_99p_rmse = sqrt((rcm_hist_MAM_99p_clm - obs_MAM_99p_clm)^2)
  rcm_MAM_01p_rmse = rcm_hist_MAM_01p_clm
  rcm_MAM_01p_rmse = sqrt((rcm_hist_MAM_01p_clm - obs_MAM_01p_clm)^2)
  rcm_JJA_avg_rmse = rcm_hist_JJA_avg_clm
  rcm_JJA_avg_rmse = sqrt((rcm_hist_JJA_avg_clm - obs_JJA_avg_clm)^2)
  rcm_JJA_var_rmse = rcm_hist_JJA_var_clm
  rcm_JJA_var_rmse = sqrt((rcm_hist_JJA_var_clm - obs_JJA_var_clm)^2)
  rcm_JJA_99p_rmse = rcm_hist_JJA_99p_clm
  rcm_JJA_99p_rmse = sqrt((rcm_hist_JJA_99p_clm - obs_JJA_99p_clm)^2)
  rcm_JJA_01p_rmse = rcm_hist_JJA_01p_clm
  rcm_JJA_01p_rmse = sqrt((rcm_hist_JJA_01p_clm - obs_JJA_01p_clm)^2)
  rcm_SON_avg_rmse = rcm_hist_SON_avg_clm
  rcm_SON_avg_rmse = sqrt((rcm_hist_SON_avg_clm - obs_SON_avg_clm)^2)
  rcm_SON_var_rmse = rcm_hist_SON_var_clm
  rcm_SON_var_rmse = sqrt((rcm_hist_SON_var_clm - obs_SON_var_clm)^2)
  rcm_SON_99p_rmse = rcm_hist_SON_99p_clm
  rcm_SON_99p_rmse = sqrt((rcm_hist_SON_99p_clm - obs_SON_99p_clm)^2)
  rcm_SON_01p_rmse = rcm_hist_SON_01p_clm
  rcm_SON_01p_rmse = sqrt((rcm_hist_SON_01p_clm - obs_SON_01p_clm)^2)

  gdd_DJF_avg_rmse = gdd_hist_DJF_avg_clm
  gdd_DJF_avg_rmse = sqrt((gdd_hist_DJF_avg_clm - obs_DJF_avg_clm)^2)
  gdd_DJF_var_rmse = gdd_hist_DJF_var_clm
  gdd_DJF_var_rmse = sqrt((gdd_hist_DJF_var_clm - obs_DJF_var_clm)^2)
  gdd_DJF_99p_rmse = gdd_hist_DJF_99p_clm
  gdd_DJF_99p_rmse = sqrt((gdd_hist_DJF_99p_clm - obs_DJF_99p_clm)^2)
  gdd_DJF_01p_rmse = gdd_hist_DJF_01p_clm
  gdd_DJF_01p_rmse = sqrt((gdd_hist_DJF_01p_clm - obs_DJF_01p_clm)^2)
  gdd_MAM_avg_rmse = gdd_hist_MAM_avg_clm
  gdd_MAM_avg_rmse = sqrt((gdd_hist_MAM_avg_clm - obs_MAM_avg_clm)^2)
  gdd_MAM_var_rmse = gdd_hist_MAM_var_clm
  gdd_MAM_var_rmse = sqrt((gdd_hist_MAM_var_clm - obs_MAM_var_clm)^2)
  gdd_MAM_99p_rmse = gdd_hist_MAM_99p_clm
  gdd_MAM_99p_rmse = sqrt((gdd_hist_MAM_99p_clm - obs_MAM_99p_clm)^2)
  gdd_MAM_01p_rmse = gdd_hist_MAM_01p_clm
  gdd_MAM_01p_rmse = sqrt((gdd_hist_MAM_01p_clm - obs_MAM_01p_clm)^2)
  gdd_JJA_avg_rmse = gdd_hist_JJA_avg_clm
  gdd_JJA_avg_rmse = sqrt((gdd_hist_JJA_avg_clm - obs_JJA_avg_clm)^2)
  gdd_JJA_var_rmse = gdd_hist_JJA_var_clm
  gdd_JJA_var_rmse = sqrt((gdd_hist_JJA_var_clm - obs_JJA_var_clm)^2)
  gdd_JJA_99p_rmse = gdd_hist_JJA_99p_clm
  gdd_JJA_99p_rmse = sqrt((gdd_hist_JJA_99p_clm - obs_JJA_99p_clm)^2)
  gdd_JJA_01p_rmse = gdd_hist_JJA_01p_clm
  gdd_JJA_01p_rmse = sqrt((gdd_hist_JJA_01p_clm - obs_JJA_01p_clm)^2)
  gdd_SON_avg_rmse = gdd_hist_SON_avg_clm
  gdd_SON_avg_rmse = sqrt((gdd_hist_SON_avg_clm - obs_SON_avg_clm)^2)
  gdd_SON_var_rmse = gdd_hist_SON_var_clm
  gdd_SON_var_rmse = sqrt((gdd_hist_SON_var_clm - obs_SON_var_clm)^2)
  gdd_SON_99p_rmse = gdd_hist_SON_99p_clm
  gdd_SON_99p_rmse = sqrt((gdd_hist_SON_99p_clm - obs_SON_99p_clm)^2)
  gdd_SON_01p_rmse = gdd_hist_SON_01p_clm
  gdd_SON_01p_rmse = sqrt((gdd_hist_SON_01p_clm - obs_SON_01p_clm)^2)

  av_DJF_avg = gdd_DJF_avg_rmse
  av_DJF_avg = gdd_DJF_avg_rmse - rcm_DJF_avg_rmse
  av_DJF_var = gdd_DJF_var_rmse
  av_DJF_var = gdd_DJF_var_rmse - rcm_DJF_var_rmse
  av_DJF_99p = gdd_DJF_99p_rmse
  av_DJF_99p = gdd_DJF_99p_rmse - rcm_DJF_99p_rmse
  av_DJF_01p = gdd_DJF_01p_rmse
  av_DJF_01p = gdd_DJF_01p_rmse - rcm_DJF_01p_rmse
  av_MAM_avg = gdd_MAM_avg_rmse
  av_MAM_avg = gdd_MAM_avg_rmse - rcm_MAM_avg_rmse
  av_MAM_var = gdd_MAM_var_rmse
  av_MAM_var = gdd_MAM_var_rmse - rcm_MAM_var_rmse
  av_MAM_99p = gdd_MAM_99p_rmse
  av_MAM_99p = gdd_MAM_99p_rmse - rcm_MAM_99p_rmse
  av_MAM_01p = gdd_MAM_01p_rmse
  av_MAM_01p = gdd_MAM_01p_rmse - rcm_MAM_01p_rmse
  av_JJA_avg = gdd_JJA_avg_rmse
  av_JJA_avg = gdd_JJA_avg_rmse - rcm_JJA_avg_rmse
  av_JJA_var = gdd_JJA_var_rmse
  av_JJA_var = gdd_JJA_var_rmse - rcm_JJA_var_rmse
  av_JJA_99p = gdd_JJA_99p_rmse
  av_JJA_99p = gdd_JJA_99p_rmse - rcm_JJA_99p_rmse
  av_JJA_01p = gdd_JJA_01p_rmse
  av_JJA_01p = gdd_JJA_01p_rmse - rcm_JJA_01p_rmse
  av_SON_avg = gdd_SON_avg_rmse
  av_SON_avg = gdd_SON_avg_rmse - rcm_SON_avg_rmse
  av_SON_var = gdd_SON_var_rmse
  av_SON_var = gdd_SON_var_rmse - rcm_SON_var_rmse
  av_SON_99p = gdd_SON_99p_rmse
  av_SON_99p = gdd_SON_99p_rmse - rcm_SON_99p_rmse
  av_SON_01p = gdd_SON_01p_rmse
  av_SON_01p = gdd_SON_01p_rmse - rcm_SON_01p_rmse

  ; calculate rmse using ncl function (uses annual time series data)
  rcm_DJF_avg_rmse_ncl = dim_rmsd_n_Wrap(obs_DJF_avg, rcm_hist_DJF_avg, 0)
  rcm_DJF_var_rmse_ncl = dim_rmsd_n_Wrap(obs_DJF_var, rcm_hist_DJF_var, 0)
  rcm_DJF_99p_rmse_ncl = dim_rmsd_n_Wrap(obs_DJF_99p, rcm_hist_DJF_99p, 0)
  rcm_DJF_01p_rmse_ncl = dim_rmsd_n_Wrap(obs_DJF_01p, rcm_hist_DJF_01p, 0)
  rcm_MAM_avg_rmse_ncl = dim_rmsd_n_Wrap(obs_MAM_avg, rcm_hist_MAM_avg, 0)
  rcm_MAM_var_rmse_ncl = dim_rmsd_n_Wrap(obs_MAM_var, rcm_hist_MAM_var, 0)
  rcm_MAM_99p_rmse_ncl = dim_rmsd_n_Wrap(obs_MAM_99p, rcm_hist_MAM_99p, 0)
  rcm_MAM_01p_rmse_ncl = dim_rmsd_n_Wrap(obs_MAM_01p, rcm_hist_MAM_01p, 0)
  rcm_JJA_avg_rmse_ncl = dim_rmsd_n_Wrap(obs_JJA_avg, rcm_hist_JJA_avg, 0)
  rcm_JJA_var_rmse_ncl = dim_rmsd_n_Wrap(obs_JJA_var, rcm_hist_JJA_var, 0)
  rcm_JJA_99p_rmse_ncl = dim_rmsd_n_Wrap(obs_JJA_99p, rcm_hist_JJA_99p, 0)
  rcm_JJA_01p_rmse_ncl = dim_rmsd_n_Wrap(obs_JJA_01p, rcm_hist_JJA_01p, 0)
  rcm_SON_avg_rmse_ncl = dim_rmsd_n_Wrap(obs_SON_avg, rcm_hist_SON_avg, 0)
  rcm_SON_var_rmse_ncl = dim_rmsd_n_Wrap(obs_SON_var, rcm_hist_SON_var, 0)
  rcm_SON_99p_rmse_ncl = dim_rmsd_n_Wrap(obs_SON_99p, rcm_hist_SON_99p, 0)
  rcm_SON_01p_rmse_ncl = dim_rmsd_n_Wrap(obs_SON_01p, rcm_hist_SON_01p, 0)

  gdd_DJF_avg_rmse_ncl = dim_rmsd_n_Wrap(obs_DJF_avg, gdd_hist_DJF_avg, 0)
  gdd_DJF_var_rmse_ncl = dim_rmsd_n_Wrap(obs_DJF_var, gdd_hist_DJF_var, 0)
  gdd_DJF_99p_rmse_ncl = dim_rmsd_n_Wrap(obs_DJF_99p, gdd_hist_DJF_99p, 0)
  gdd_DJF_01p_rmse_ncl = dim_rmsd_n_Wrap(obs_DJF_01p, gdd_hist_DJF_01p, 0)
  gdd_MAM_avg_rmse_ncl = dim_rmsd_n_Wrap(obs_MAM_avg, gdd_hist_MAM_avg, 0)
  gdd_MAM_var_rmse_ncl = dim_rmsd_n_Wrap(obs_MAM_var, gdd_hist_MAM_var, 0)
  gdd_MAM_99p_rmse_ncl = dim_rmsd_n_Wrap(obs_MAM_99p, gdd_hist_MAM_99p, 0)
  gdd_MAM_01p_rmse_ncl = dim_rmsd_n_Wrap(obs_MAM_01p, gdd_hist_MAM_01p, 0)
  gdd_JJA_avg_rmse_ncl = dim_rmsd_n_Wrap(obs_JJA_avg, gdd_hist_JJA_avg, 0)
  gdd_JJA_var_rmse_ncl = dim_rmsd_n_Wrap(obs_JJA_var, gdd_hist_JJA_var, 0)
  gdd_JJA_99p_rmse_ncl = dim_rmsd_n_Wrap(obs_JJA_99p, gdd_hist_JJA_99p, 0)
  gdd_JJA_01p_rmse_ncl = dim_rmsd_n_Wrap(obs_JJA_01p, gdd_hist_JJA_01p, 0)
  gdd_SON_avg_rmse_ncl = dim_rmsd_n_Wrap(obs_SON_avg, gdd_hist_SON_avg, 0)
  gdd_SON_var_rmse_ncl = dim_rmsd_n_Wrap(obs_SON_var, gdd_hist_SON_var, 0)
  gdd_SON_99p_rmse_ncl = dim_rmsd_n_Wrap(obs_SON_99p, gdd_hist_SON_99p, 0)
  gdd_SON_01p_rmse_ncl = dim_rmsd_n_Wrap(obs_SON_01p, gdd_hist_SON_01p, 0)

  av_DJF_avg_ncl = gdd_DJF_avg_rmse_ncl
  av_DJF_avg_ncl = gdd_DJF_avg_rmse_ncl - rcm_DJF_avg_rmse_ncl
  av_DJF_var_ncl = gdd_DJF_var_rmse_ncl
  av_DJF_var_ncl = gdd_DJF_var_rmse_ncl - rcm_DJF_var_rmse_ncl
  av_DJF_99p_ncl = gdd_DJF_99p_rmse_ncl
  av_DJF_99p_ncl = gdd_DJF_99p_rmse_ncl - rcm_DJF_99p_rmse_ncl
  av_DJF_01p_ncl = gdd_DJF_01p_rmse_ncl
  av_DJF_01p_ncl = gdd_DJF_01p_rmse_ncl - rcm_DJF_01p_rmse_ncl
  av_MAM_avg_ncl = gdd_MAM_avg_rmse_ncl
  av_MAM_avg_ncl = gdd_MAM_avg_rmse_ncl - rcm_MAM_avg_rmse_ncl
  av_MAM_var_ncl = gdd_MAM_var_rmse_ncl
  av_MAM_var_ncl = gdd_MAM_var_rmse_ncl - rcm_MAM_var_rmse_ncl
  av_MAM_99p_ncl = gdd_MAM_99p_rmse_ncl
  av_MAM_99p_ncl = gdd_MAM_99p_rmse_ncl - rcm_MAM_99p_rmse_ncl
  av_MAM_01p_ncl = gdd_MAM_01p_rmse_ncl
  av_MAM_01p_ncl = gdd_MAM_01p_rmse_ncl - rcm_MAM_01p_rmse_ncl
  av_JJA_avg_ncl = gdd_JJA_avg_rmse_ncl
  av_JJA_avg_ncl = gdd_JJA_avg_rmse_ncl - rcm_JJA_avg_rmse_ncl
  av_JJA_var_ncl = gdd_JJA_var_rmse_ncl
  av_JJA_var_ncl = gdd_JJA_var_rmse_ncl - rcm_JJA_var_rmse_ncl
  av_JJA_99p_ncl = gdd_JJA_99p_rmse_ncl
  av_JJA_99p_ncl = gdd_JJA_99p_rmse_ncl - rcm_JJA_99p_rmse_ncl
  av_JJA_01p_ncl = gdd_JJA_01p_rmse_ncl
  av_JJA_01p_ncl = gdd_JJA_01p_rmse_ncl - rcm_JJA_01p_rmse_ncl
  av_SON_avg_ncl = gdd_SON_avg_rmse_ncl
  av_SON_avg_ncl = gdd_SON_avg_rmse_ncl - rcm_SON_avg_rmse_ncl
  av_SON_var_ncl = gdd_SON_var_rmse_ncl
  av_SON_var_ncl = gdd_SON_var_rmse_ncl - rcm_SON_var_rmse_ncl
  av_SON_99p_ncl = gdd_SON_99p_rmse_ncl
  av_SON_99p_ncl = gdd_SON_99p_rmse_ncl - rcm_SON_99p_rmse_ncl
  av_SON_01p_ncl = gdd_SON_01p_rmse_ncl
  av_SON_01p_ncl = gdd_SON_01p_rmse_ncl - rcm_SON_01p_rmse_ncl

  ; calculate Potential Added Value (PAV)
  rcm_DJF_avg_cc = rcm_fut_DJF_avg_clm
  rcm_DJF_avg_cc = rcm_fut_DJF_avg_clm - rcm_hist_DJF_avg_clm
  rcm_DJF_var_cc = rcm_fut_DJF_var_clm
  rcm_DJF_var_cc = rcm_fut_DJF_var_clm - rcm_hist_DJF_var_clm
  rcm_DJF_99p_cc = rcm_fut_DJF_99p_clm
  rcm_DJF_99p_cc = rcm_fut_DJF_99p_clm - rcm_hist_DJF_99p_clm
  rcm_DJF_01p_cc = rcm_fut_DJF_01p_clm
  rcm_DJF_01p_cc = rcm_fut_DJF_01p_clm - rcm_hist_DJF_01p_clm
  rcm_MAM_avg_cc = rcm_fut_MAM_avg_clm
  rcm_MAM_avg_cc = rcm_fut_MAM_avg_clm - rcm_hist_MAM_avg_clm
  rcm_MAM_var_cc = rcm_fut_MAM_var_clm
  rcm_MAM_var_cc = rcm_fut_MAM_var_clm - rcm_hist_MAM_var_clm
  rcm_MAM_99p_cc = rcm_fut_MAM_99p_clm
  rcm_MAM_99p_cc = rcm_fut_MAM_99p_clm - rcm_hist_MAM_99p_clm
  rcm_MAM_01p_cc = rcm_fut_MAM_01p_clm
  rcm_MAM_01p_cc = rcm_fut_MAM_01p_clm - rcm_hist_MAM_01p_clm
  rcm_JJA_avg_cc = rcm_fut_JJA_avg_clm
  rcm_JJA_avg_cc = rcm_fut_JJA_avg_clm - rcm_hist_JJA_avg_clm
  rcm_JJA_var_cc = rcm_fut_JJA_var_clm
  rcm_JJA_var_cc = rcm_fut_JJA_var_clm - rcm_hist_JJA_var_clm
  rcm_JJA_99p_cc = rcm_fut_JJA_99p_clm
  rcm_JJA_99p_cc = rcm_fut_JJA_99p_clm - rcm_hist_JJA_99p_clm
  rcm_JJA_01p_cc = rcm_fut_JJA_01p_clm
  rcm_JJA_01p_cc = rcm_fut_JJA_01p_clm - rcm_hist_JJA_01p_clm
  rcm_SON_avg_cc = rcm_fut_SON_avg_clm
  rcm_SON_avg_cc = rcm_fut_SON_avg_clm - rcm_hist_SON_avg_clm
  rcm_SON_var_cc = rcm_fut_SON_var_clm
  rcm_SON_var_cc = rcm_fut_SON_var_clm - rcm_hist_SON_var_clm
  rcm_SON_99p_cc = rcm_fut_SON_99p_clm
  rcm_SON_99p_cc = rcm_fut_SON_99p_clm - rcm_hist_SON_99p_clm
  rcm_SON_01p_cc = rcm_fut_SON_01p_clm
  rcm_SON_01p_cc = rcm_fut_SON_01p_clm - rcm_hist_SON_01p_clm

  gdd_DJF_avg_cc = gdd_fut_DJF_avg_clm
  gdd_DJF_avg_cc = gdd_fut_DJF_avg_clm - gdd_hist_DJF_avg_clm
  gdd_DJF_var_cc = gdd_fut_DJF_var_clm
  gdd_DJF_var_cc = gdd_fut_DJF_var_clm - gdd_hist_DJF_var_clm
  gdd_DJF_99p_cc = gdd_fut_DJF_99p_clm
  gdd_DJF_99p_cc = gdd_fut_DJF_99p_clm - gdd_hist_DJF_99p_clm
  gdd_DJF_01p_cc = gdd_fut_DJF_01p_clm
  gdd_DJF_01p_cc = gdd_fut_DJF_01p_clm - gdd_hist_DJF_01p_clm
  gdd_MAM_avg_cc = gdd_fut_MAM_avg_clm
  gdd_MAM_avg_cc = gdd_fut_MAM_avg_clm - gdd_hist_MAM_avg_clm
  gdd_MAM_var_cc = gdd_fut_MAM_var_clm
  gdd_MAM_var_cc = gdd_fut_MAM_var_clm - gdd_hist_MAM_var_clm
  gdd_MAM_99p_cc = gdd_fut_MAM_99p_clm
  gdd_MAM_99p_cc = gdd_fut_MAM_99p_clm - gdd_hist_MAM_99p_clm
  gdd_MAM_01p_cc = gdd_fut_MAM_01p_clm
  gdd_MAM_01p_cc = gdd_fut_MAM_01p_clm - gdd_hist_MAM_01p_clm
  gdd_JJA_avg_cc = gdd_fut_JJA_avg_clm
  gdd_JJA_avg_cc = gdd_fut_JJA_avg_clm - gdd_hist_JJA_avg_clm
  gdd_JJA_var_cc = gdd_fut_JJA_var_clm
  gdd_JJA_var_cc = gdd_fut_JJA_var_clm - gdd_hist_JJA_var_clm
  gdd_JJA_99p_cc = gdd_fut_JJA_99p_clm
  gdd_JJA_99p_cc = gdd_fut_JJA_99p_clm - gdd_hist_JJA_99p_clm
  gdd_JJA_01p_cc = gdd_fut_JJA_01p_clm
  gdd_JJA_01p_cc = gdd_fut_JJA_01p_clm - gdd_hist_JJA_01p_clm
  gdd_SON_avg_cc = gdd_fut_SON_avg_clm
  gdd_SON_avg_cc = gdd_fut_SON_avg_clm - gdd_hist_SON_avg_clm
  gdd_SON_var_cc = gdd_fut_SON_var_clm
  gdd_SON_var_cc = gdd_fut_SON_var_clm - gdd_hist_SON_var_clm
  gdd_SON_99p_cc = gdd_fut_SON_99p_clm
  gdd_SON_99p_cc = gdd_fut_SON_99p_clm - gdd_hist_SON_99p_clm
  gdd_SON_01p_cc = gdd_fut_SON_01p_clm
  gdd_SON_01p_cc = gdd_fut_SON_01p_clm - gdd_hist_SON_01p_clm

  pav_DJF_avg = rcm_DJF_avg_cc
  pav_DJF_avg = rcm_DJF_avg_cc - gdd_DJF_avg_cc
  pav_DJF_var = rcm_DJF_var_cc
  pav_DJF_var = rcm_DJF_var_cc - gdd_DJF_var_cc
  pav_DJF_99p = rcm_DJF_99p_cc
  pav_DJF_99p = rcm_DJF_99p_cc - gdd_DJF_99p_cc
  pav_DJF_01p = rcm_DJF_01p_cc
  pav_DJF_01p = rcm_DJF_01p_cc - gdd_DJF_01p_cc
  pav_MAM_avg = rcm_MAM_avg_cc
  pav_MAM_avg = rcm_MAM_avg_cc - gdd_MAM_avg_cc
  pav_MAM_var = rcm_MAM_var_cc
  pav_MAM_var = rcm_MAM_var_cc - gdd_MAM_var_cc
  pav_MAM_99p = rcm_MAM_99p_cc
  pav_MAM_99p = rcm_MAM_99p_cc - gdd_MAM_99p_cc
  pav_MAM_01p = rcm_MAM_01p_cc
  pav_MAM_01p = rcm_MAM_01p_cc - gdd_MAM_01p_cc
  pav_JJA_avg = rcm_JJA_avg_cc
  pav_JJA_avg = rcm_JJA_avg_cc - gdd_JJA_avg_cc
  pav_JJA_var = rcm_JJA_var_cc
  pav_JJA_var = rcm_JJA_var_cc - gdd_JJA_var_cc
  pav_JJA_99p = rcm_JJA_99p_cc
  pav_JJA_99p = rcm_JJA_99p_cc - gdd_JJA_99p_cc
  pav_JJA_01p = rcm_JJA_01p_cc
  pav_JJA_01p = rcm_JJA_01p_cc - gdd_JJA_01p_cc
  pav_SON_avg = rcm_SON_avg_cc
  pav_SON_avg = rcm_SON_avg_cc - gdd_SON_avg_cc
  pav_SON_var = rcm_SON_var_cc
  pav_SON_var = rcm_SON_var_cc - gdd_SON_var_cc
  pav_SON_99p = rcm_SON_99p_cc
  pav_SON_99p = rcm_SON_99p_cc - gdd_SON_99p_cc
  pav_SON_01p = rcm_SON_01p_cc
  pav_SON_01p = rcm_SON_01p_cc - gdd_SON_01p_cc

  ; calculate Realised Added Value (RAV)
  obs_DJF_avg_variance = dim_variance_n_Wrap(obs_DJF_avg, 0)
  obs_DJF_var_variance = dim_variance_n_Wrap(obs_DJF_var, 0)
  obs_DJF_99p_variance = dim_variance_n_Wrap(obs_DJF_99p, 0)
  obs_DJF_01p_variance = dim_variance_n_Wrap(obs_DJF_01p, 0)
  obs_MAM_avg_variance = dim_variance_n_Wrap(obs_MAM_avg, 0)
  obs_MAM_var_variance = dim_variance_n_Wrap(obs_MAM_var, 0)
  obs_MAM_99p_variance = dim_variance_n_Wrap(obs_MAM_99p, 0)
  obs_MAM_01p_variance = dim_variance_n_Wrap(obs_MAM_01p, 0)
  obs_JJA_avg_variance = dim_variance_n_Wrap(obs_JJA_avg, 0)
  obs_JJA_var_variance = dim_variance_n_Wrap(obs_JJA_var, 0)
  obs_JJA_99p_variance = dim_variance_n_Wrap(obs_JJA_99p, 0)
  obs_JJA_01p_variance = dim_variance_n_Wrap(obs_JJA_01p, 0)
  obs_SON_avg_variance = dim_variance_n_Wrap(obs_SON_avg, 0)
  obs_SON_var_variance = dim_variance_n_Wrap(obs_SON_var, 0)
  obs_SON_99p_variance = dim_variance_n_Wrap(obs_SON_99p, 0)
  obs_SON_01p_variance = dim_variance_n_Wrap(obs_SON_01p, 0)

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

  rav_DJF_avg = av_DJF_avg
  rav_DJF_avg = (av_DJF_avg * abs(pav_DJF_avg))/obs_DJF_avg_variance
  rav_DJF_var = av_DJF_var
  rav_DJF_var = (av_DJF_var * abs(pav_DJF_var))/obs_DJF_var_variance
  rav_DJF_99p = av_DJF_99p
  rav_DJF_99p = (av_DJF_99p * abs(pav_DJF_99p))/obs_DJF_99p_variance
  rav_DJF_01p = av_DJF_01p
  rav_DJF_01p = (av_DJF_01p * abs(pav_DJF_01p))/obs_DJF_01p_variance
  rav_MAM_avg = av_MAM_avg
  rav_MAM_avg = (av_MAM_avg * abs(pav_MAM_avg))/obs_MAM_avg_variance
  rav_MAM_var = av_MAM_var
  rav_MAM_var = (av_MAM_var * abs(pav_MAM_var))/obs_MAM_var_variance
  rav_MAM_99p = av_MAM_99p
  rav_MAM_99p = (av_MAM_99p * abs(pav_MAM_99p))/obs_MAM_99p_variance
  rav_MAM_01p = av_MAM_01p
  rav_MAM_01p = (av_MAM_01p * abs(pav_MAM_01p))/obs_MAM_01p_variance
  rav_JJA_avg = av_JJA_avg
  rav_JJA_avg = (av_JJA_avg * abs(pav_JJA_avg))/obs_JJA_avg_variance
  rav_JJA_var = av_JJA_var
  rav_JJA_var = (av_JJA_var * abs(pav_JJA_var))/obs_JJA_var_variance
  rav_JJA_99p = av_JJA_99p
  rav_JJA_99p = (av_JJA_99p * abs(pav_JJA_99p))/obs_JJA_99p_variance
  rav_JJA_01p = av_JJA_01p
  rav_JJA_01p = (av_JJA_01p * abs(pav_JJA_01p))/obs_JJA_01p_variance
  rav_SON_avg = av_SON_avg
  rav_SON_avg = (av_SON_avg * abs(pav_SON_avg))/obs_SON_avg_variance
  rav_SON_var = av_SON_var
  rav_SON_var = (av_SON_var * abs(pav_SON_var))/obs_SON_var_variance
  rav_SON_99p = av_SON_99p
  rav_SON_99p = (av_SON_99p * abs(pav_SON_99p))/obs_SON_99p_variance
  rav_SON_01p = av_SON_01p
  rav_SON_01p = (av_SON_01p * abs(pav_SON_01p))/obs_SON_01p_variance

  print(systemfunc("date"))
  print("Outputting data")
  fout_DJF = addfile(fout_name_DJF, "c")
  fout_DJF->av_DJF_avg = av_DJF_avg
  fout_DJF->gdd_DJF_avg_rmse = gdd_DJF_avg_rmse
  fout_DJF->rcm_DJF_avg_rmse = rcm_DJF_avg_rmse
  fout_DJF->av_DJF_avg_ncl = av_DJF_avg_ncl
  fout_DJF->gdd_DJF_avg_rmse_ncl = gdd_DJF_avg_rmse_ncl
  fout_DJF->rcm_DJF_avg_rmse_ncl = rcm_DJF_avg_rmse_ncl
  fout_DJF->pav_DJF_avg = pav_DJF_avg
  fout_DJF->rav_DJF_avg = rav_DJF_avg
  fout_DJF->obs_DJF_avg_variance = obs_DJF_avg_variance
  fout_DJF->gdd_DJF_avg_cc = gdd_DJF_avg_cc
  fout_DJF->rcm_DJF_avg_cc = rcm_DJF_avg_cc
  fout_DJF->obs_DJF_avg_clm = obs_DJF_avg_clm
  fout_DJF->gdd_hist_DJF_avg_clm = gdd_hist_DJF_avg_clm
  fout_DJF->gdd_fut_DJF_avg_clm = gdd_fut_DJF_avg_clm
  fout_DJF->rcm_hist_DJF_avg_clm = rcm_hist_DJF_avg_clm
  fout_DJF->rcm_fut_DJF_avg_clm = rcm_fut_DJF_avg_clm
  fout_DJF->av_DJF_var = av_DJF_var
  fout_DJF->gdd_DJF_var_rmse = gdd_DJF_var_rmse
  fout_DJF->rcm_DJF_var_rmse = rcm_DJF_var_rmse
  fout_DJF->av_DJF_var_ncl = av_DJF_var_ncl
  fout_DJF->gdd_DJF_var_rmse_ncl = gdd_DJF_var_rmse_ncl
  fout_DJF->rcm_DJF_var_rmse_ncl = rcm_DJF_var_rmse_ncl
  fout_DJF->pav_DJF_var = pav_DJF_var
  fout_DJF->rav_DJF_var = rav_DJF_var
  fout_DJF->obs_DJF_var_variance = obs_DJF_var_variance
  fout_DJF->gdd_DJF_var_cc = gdd_DJF_var_cc
  fout_DJF->rcm_DJF_var_cc = rcm_DJF_var_cc
  fout_DJF->obs_DJF_var_clm = obs_DJF_var_clm
  fout_DJF->gdd_hist_DJF_var_clm = gdd_hist_DJF_var_clm
  fout_DJF->gdd_fut_DJF_var_clm = gdd_fut_DJF_var_clm
  fout_DJF->rcm_hist_DJF_var_clm = rcm_hist_DJF_var_clm
  fout_DJF->rcm_fut_DJF_var_clm = rcm_fut_DJF_var_clm
  fout_DJF->av_DJF_99p = av_DJF_99p
  fout_DJF->gdd_DJF_99p_rmse = gdd_DJF_99p_rmse
  fout_DJF->rcm_DJF_99p_rmse = rcm_DJF_99p_rmse
  fout_DJF->av_DJF_99p_ncl = av_DJF_99p_ncl
  fout_DJF->gdd_DJF_99p_rmse_ncl = gdd_DJF_99p_rmse_ncl
  fout_DJF->rcm_DJF_99p_rmse_ncl = rcm_DJF_99p_rmse_ncl
  fout_DJF->pav_DJF_99p = pav_DJF_99p
  fout_DJF->rav_DJF_99p = rav_DJF_99p
  fout_DJF->obs_DJF_99p_variance = obs_DJF_99p_variance
  fout_DJF->gdd_DJF_99p_cc = gdd_DJF_99p_cc
  fout_DJF->rcm_DJF_99p_cc = rcm_DJF_99p_cc
  fout_DJF->obs_DJF_99p_clm = obs_DJF_99p_clm
  fout_DJF->gdd_hist_DJF_99p_clm = gdd_hist_DJF_99p_clm
  fout_DJF->gdd_fut_DJF_99p_clm = gdd_fut_DJF_99p_clm
  fout_DJF->rcm_hist_DJF_99p_clm = rcm_hist_DJF_99p_clm
  fout_DJF->rcm_fut_DJF_99p_clm = rcm_fut_DJF_99p_clm
  fout_DJF->av_DJF_01p = av_DJF_01p
  fout_DJF->gdd_DJF_01p_rmse = gdd_DJF_01p_rmse
  fout_DJF->rcm_DJF_01p_rmse = rcm_DJF_01p_rmse
  fout_DJF->av_DJF_01p_ncl = av_DJF_01p_ncl
  fout_DJF->gdd_DJF_01p_rmse_ncl = gdd_DJF_01p_rmse_ncl
  fout_DJF->rcm_DJF_01p_rmse_ncl = rcm_DJF_01p_rmse_ncl
  fout_DJF->pav_DJF_01p = pav_DJF_01p
  fout_DJF->rav_DJF_01p = rav_DJF_01p
  fout_DJF->obs_DJF_01p_variance = obs_DJF_01p_variance
  fout_DJF->gdd_DJF_01p_cc = gdd_DJF_01p_cc
  fout_DJF->rcm_DJF_01p_cc = rcm_DJF_01p_cc
  fout_DJF->obs_DJF_01p_clm = obs_DJF_01p_clm
  fout_DJF->gdd_hist_DJF_01p_clm = gdd_hist_DJF_01p_clm
  fout_DJF->gdd_fut_DJF_01p_clm = gdd_fut_DJF_01p_clm
  fout_DJF->rcm_hist_DJF_01p_clm = rcm_hist_DJF_01p_clm
  fout_DJF->rcm_fut_DJF_01p_clm = rcm_fut_DJF_01p_clm

  fout_MAM = addfile(fout_name_MAM, "c")
  fout_MAM->av_MAM_avg = av_MAM_avg
  fout_MAM->gdd_MAM_avg_rmse = gdd_MAM_avg_rmse
  fout_MAM->rcm_MAM_avg_rmse = rcm_MAM_avg_rmse
  fout_MAM->av_MAM_avg_ncl = av_MAM_avg_ncl
  fout_MAM->gdd_MAM_avg_rmse_ncl = gdd_MAM_avg_rmse_ncl
  fout_MAM->rcm_MAM_avg_rmse_ncl = rcm_MAM_avg_rmse_ncl
  fout_MAM->pav_MAM_avg = pav_MAM_avg
  fout_MAM->rav_MAM_avg = rav_MAM_avg
  fout_MAM->obs_MAM_avg_variance = obs_MAM_avg_variance
  fout_MAM->gdd_MAM_avg_cc = gdd_MAM_avg_cc
  fout_MAM->rcm_MAM_avg_cc = rcm_MAM_avg_cc
  fout_MAM->obs_MAM_avg_clm = obs_MAM_avg_clm
  fout_MAM->gdd_hist_MAM_avg_clm = gdd_hist_MAM_avg_clm
  fout_MAM->gdd_fut_MAM_avg_clm = gdd_fut_MAM_avg_clm
  fout_MAM->rcm_hist_MAM_avg_clm = rcm_hist_MAM_avg_clm
  fout_MAM->rcm_fut_MAM_avg_clm = rcm_fut_MAM_avg_clm
  fout_MAM->av_MAM_var = av_MAM_var
  fout_MAM->gdd_MAM_var_rmse = gdd_MAM_var_rmse
  fout_MAM->rcm_MAM_var_rmse = rcm_MAM_var_rmse
  fout_MAM->av_MAM_var_ncl = av_MAM_var_ncl
  fout_MAM->gdd_MAM_var_rmse_ncl = gdd_MAM_var_rmse_ncl
  fout_MAM->rcm_MAM_var_rmse_ncl = rcm_MAM_var_rmse_ncl
  fout_MAM->pav_MAM_var = pav_MAM_var
  fout_MAM->rav_MAM_var = rav_MAM_var
  fout_MAM->obs_MAM_var_variance = obs_MAM_var_variance
  fout_MAM->gdd_MAM_var_cc = gdd_MAM_var_cc
  fout_MAM->rcm_MAM_var_cc = rcm_MAM_var_cc
  fout_MAM->obs_MAM_var_clm = obs_MAM_var_clm
  fout_MAM->gdd_hist_MAM_var_clm = gdd_hist_MAM_var_clm
  fout_MAM->gdd_fut_MAM_var_clm = gdd_fut_MAM_var_clm
  fout_MAM->rcm_hist_MAM_var_clm = rcm_hist_MAM_var_clm
  fout_MAM->rcm_fut_MAM_var_clm = rcm_fut_MAM_var_clm
  fout_MAM->av_MAM_99p = av_MAM_99p
  fout_MAM->gdd_MAM_99p_rmse = gdd_MAM_99p_rmse
  fout_MAM->rcm_MAM_99p_rmse = rcm_MAM_99p_rmse
  fout_MAM->av_MAM_99p_ncl = av_MAM_99p_ncl
  fout_MAM->gdd_MAM_99p_rmse_ncl = gdd_MAM_99p_rmse_ncl
  fout_MAM->rcm_MAM_99p_rmse_ncl = rcm_MAM_99p_rmse_ncl
  fout_MAM->pav_MAM_99p = pav_MAM_99p
  fout_MAM->rav_MAM_99p = rav_MAM_99p
  fout_MAM->obs_MAM_99p_variance = obs_MAM_99p_variance
  fout_MAM->gdd_MAM_99p_cc = gdd_MAM_99p_cc
  fout_MAM->rcm_MAM_99p_cc = rcm_MAM_99p_cc
  fout_MAM->obs_MAM_99p_clm = obs_MAM_99p_clm
  fout_MAM->gdd_hist_MAM_99p_clm = gdd_hist_MAM_99p_clm
  fout_MAM->gdd_fut_MAM_99p_clm = gdd_fut_MAM_99p_clm
  fout_MAM->rcm_hist_MAM_99p_clm = rcm_hist_MAM_99p_clm
  fout_MAM->rcm_fut_MAM_99p_clm = rcm_fut_MAM_99p_clm
  fout_MAM->av_MAM_01p = av_MAM_01p
  fout_MAM->gdd_MAM_01p_rmse = gdd_MAM_01p_rmse
  fout_MAM->rcm_MAM_01p_rmse = rcm_MAM_01p_rmse
  fout_MAM->av_MAM_01p_ncl = av_MAM_01p_ncl
  fout_MAM->gdd_MAM_01p_rmse_ncl = gdd_MAM_01p_rmse_ncl
  fout_MAM->rcm_MAM_01p_rmse_ncl = rcm_MAM_01p_rmse_ncl
  fout_MAM->pav_MAM_01p = pav_MAM_01p
  fout_MAM->rav_MAM_01p = rav_MAM_01p
  fout_MAM->obs_MAM_01p_variance = obs_MAM_01p_variance
  fout_MAM->gdd_MAM_01p_cc = gdd_MAM_01p_cc
  fout_MAM->rcm_MAM_01p_cc = rcm_MAM_01p_cc
  fout_MAM->obs_MAM_01p_clm = obs_MAM_01p_clm
  fout_MAM->gdd_hist_MAM_01p_clm = gdd_hist_MAM_01p_clm
  fout_MAM->gdd_fut_MAM_01p_clm = gdd_fut_MAM_01p_clm
  fout_MAM->rcm_hist_MAM_01p_clm = rcm_hist_MAM_01p_clm
  fout_MAM->rcm_fut_MAM_01p_clm = rcm_fut_MAM_01p_clm

  fout_JJA = addfile(fout_name_JJA, "c")
  fout_JJA->av_JJA_avg = av_JJA_avg
  fout_JJA->gdd_JJA_avg_rmse = gdd_JJA_avg_rmse
  fout_JJA->rcm_JJA_avg_rmse = rcm_JJA_avg_rmse
  fout_JJA->av_JJA_avg_ncl = av_JJA_avg_ncl
  fout_JJA->gdd_JJA_avg_rmse_ncl = gdd_JJA_avg_rmse_ncl
  fout_JJA->rcm_JJA_avg_rmse_ncl = rcm_JJA_avg_rmse_ncl
  fout_JJA->pav_JJA_avg = pav_JJA_avg
  fout_JJA->rav_JJA_avg = rav_JJA_avg
  fout_JJA->obs_JJA_avg_variance = obs_JJA_avg_variance
  fout_JJA->gdd_JJA_avg_cc = gdd_JJA_avg_cc
  fout_JJA->rcm_JJA_avg_cc = rcm_JJA_avg_cc
  fout_JJA->obs_JJA_avg_clm = obs_JJA_avg_clm
  fout_JJA->gdd_hist_JJA_avg_clm = gdd_hist_JJA_avg_clm
  fout_JJA->gdd_fut_JJA_avg_clm = gdd_fut_JJA_avg_clm
  fout_JJA->rcm_hist_JJA_avg_clm = rcm_hist_JJA_avg_clm
  fout_JJA->rcm_fut_JJA_avg_clm = rcm_fut_JJA_avg_clm
  fout_JJA->av_JJA_var = av_JJA_var
  fout_JJA->gdd_JJA_var_rmse = gdd_JJA_var_rmse
  fout_JJA->rcm_JJA_var_rmse = rcm_JJA_var_rmse
  fout_JJA->av_JJA_var_ncl = av_JJA_var_ncl
  fout_JJA->gdd_JJA_var_rmse_ncl = gdd_JJA_var_rmse_ncl
  fout_JJA->rcm_JJA_var_rmse_ncl = rcm_JJA_var_rmse_ncl
  fout_JJA->pav_JJA_var = pav_JJA_var
  fout_JJA->rav_JJA_var = rav_JJA_var
  fout_JJA->obs_JJA_var_variance = obs_JJA_var_variance
  fout_JJA->gdd_JJA_var_cc = gdd_JJA_var_cc
  fout_JJA->rcm_JJA_var_cc = rcm_JJA_var_cc
  fout_JJA->obs_JJA_var_clm = obs_JJA_var_clm
  fout_JJA->gdd_hist_JJA_var_clm = gdd_hist_JJA_var_clm
  fout_JJA->gdd_fut_JJA_var_clm = gdd_fut_JJA_var_clm
  fout_JJA->rcm_hist_JJA_var_clm = rcm_hist_JJA_var_clm
  fout_JJA->rcm_fut_JJA_var_clm = rcm_fut_JJA_var_clm
  fout_JJA->av_JJA_99p = av_JJA_99p
  fout_JJA->gdd_JJA_99p_rmse = gdd_JJA_99p_rmse
  fout_JJA->rcm_JJA_99p_rmse = rcm_JJA_99p_rmse
  fout_JJA->av_JJA_99p_ncl = av_JJA_99p_ncl
  fout_JJA->gdd_JJA_99p_rmse_ncl = gdd_JJA_99p_rmse_ncl
  fout_JJA->rcm_JJA_99p_rmse_ncl = rcm_JJA_99p_rmse_ncl
  fout_JJA->pav_JJA_99p = pav_JJA_99p
  fout_JJA->rav_JJA_99p = rav_JJA_99p
  fout_JJA->obs_JJA_99p_variance = obs_JJA_99p_variance
  fout_JJA->gdd_JJA_99p_cc = gdd_JJA_99p_cc
  fout_JJA->rcm_JJA_99p_cc = rcm_JJA_99p_cc
  fout_JJA->obs_JJA_99p_clm = obs_JJA_99p_clm
  fout_JJA->gdd_hist_JJA_99p_clm = gdd_hist_JJA_99p_clm
  fout_JJA->gdd_fut_JJA_99p_clm = gdd_fut_JJA_99p_clm
  fout_JJA->rcm_hist_JJA_99p_clm = rcm_hist_JJA_99p_clm
  fout_JJA->rcm_fut_JJA_99p_clm = rcm_fut_JJA_99p_clm
  fout_JJA->av_JJA_01p = av_JJA_01p
  fout_JJA->gdd_JJA_01p_rmse = gdd_JJA_01p_rmse
  fout_JJA->rcm_JJA_01p_rmse = rcm_JJA_01p_rmse
  fout_JJA->av_JJA_01p_ncl = av_JJA_01p_ncl
  fout_JJA->gdd_JJA_01p_rmse_ncl = gdd_JJA_01p_rmse_ncl
  fout_JJA->rcm_JJA_01p_rmse_ncl = rcm_JJA_01p_rmse_ncl
  fout_JJA->pav_JJA_01p = pav_JJA_01p
  fout_JJA->rav_JJA_01p = rav_JJA_01p
  fout_JJA->obs_JJA_01p_variance = obs_JJA_01p_variance
  fout_JJA->gdd_JJA_01p_cc = gdd_JJA_01p_cc
  fout_JJA->rcm_JJA_01p_cc = rcm_JJA_01p_cc
  fout_JJA->obs_JJA_01p_clm = obs_JJA_01p_clm
  fout_JJA->gdd_hist_JJA_01p_clm = gdd_hist_JJA_01p_clm
  fout_JJA->gdd_fut_JJA_01p_clm = gdd_fut_JJA_01p_clm
  fout_JJA->rcm_hist_JJA_01p_clm = rcm_hist_JJA_01p_clm
  fout_JJA->rcm_fut_JJA_01p_clm = rcm_fut_JJA_01p_clm

  fout_SON = addfile(fout_name_SON, "c")
  fout_SON->av_SON_avg = av_SON_avg
  fout_SON->gdd_SON_avg_rmse = gdd_SON_avg_rmse
  fout_SON->rcm_SON_avg_rmse = rcm_SON_avg_rmse
  fout_SON->av_SON_avg_ncl = av_SON_avg_ncl
  fout_SON->gdd_SON_avg_rmse_ncl = gdd_SON_avg_rmse_ncl
  fout_SON->rcm_SON_avg_rmse_ncl = rcm_SON_avg_rmse_ncl
  fout_SON->pav_SON_avg = pav_SON_avg
  fout_SON->rav_SON_avg = rav_SON_avg
  fout_SON->obs_SON_avg_variance = obs_SON_avg_variance
  fout_SON->gdd_SON_avg_cc = gdd_SON_avg_cc
  fout_SON->rcm_SON_avg_cc = rcm_SON_avg_cc
  fout_SON->obs_SON_avg_clm = obs_SON_avg_clm
  fout_SON->gdd_hist_SON_avg_clm = gdd_hist_SON_avg_clm
  fout_SON->gdd_fut_SON_avg_clm = gdd_fut_SON_avg_clm
  fout_SON->rcm_hist_SON_avg_clm = rcm_hist_SON_avg_clm
  fout_SON->rcm_fut_SON_avg_clm = rcm_fut_SON_avg_clm
  fout_SON->av_SON_var = av_SON_var
  fout_SON->gdd_SON_var_rmse = gdd_SON_var_rmse
  fout_SON->rcm_SON_var_rmse = rcm_SON_var_rmse
  fout_SON->av_SON_var_ncl = av_SON_var_ncl
  fout_SON->gdd_SON_var_rmse_ncl = gdd_SON_var_rmse_ncl
  fout_SON->rcm_SON_var_rmse_ncl = rcm_SON_var_rmse_ncl
  fout_SON->pav_SON_var = pav_SON_var
  fout_SON->rav_SON_var = rav_SON_var
  fout_SON->obs_SON_var_variance = obs_SON_var_variance
  fout_SON->gdd_SON_var_cc = gdd_SON_var_cc
  fout_SON->rcm_SON_var_cc = rcm_SON_var_cc
  fout_SON->obs_SON_var_clm = obs_SON_var_clm
  fout_SON->gdd_hist_SON_var_clm = gdd_hist_SON_var_clm
  fout_SON->gdd_fut_SON_var_clm = gdd_fut_SON_var_clm
  fout_SON->rcm_hist_SON_var_clm = rcm_hist_SON_var_clm
  fout_SON->rcm_fut_SON_var_clm = rcm_fut_SON_var_clm
  fout_SON->av_SON_99p = av_SON_99p
  fout_SON->gdd_SON_99p_rmse = gdd_SON_99p_rmse
  fout_SON->rcm_SON_99p_rmse = rcm_SON_99p_rmse
  fout_SON->av_SON_99p_ncl = av_SON_99p_ncl
  fout_SON->gdd_SON_99p_rmse_ncl = gdd_SON_99p_rmse_ncl
  fout_SON->rcm_SON_99p_rmse_ncl = rcm_SON_99p_rmse_ncl
  fout_SON->pav_SON_99p = pav_SON_99p
  fout_SON->rav_SON_99p = rav_SON_99p
  fout_SON->obs_SON_99p_variance = obs_SON_99p_variance
  fout_SON->gdd_SON_99p_cc = gdd_SON_99p_cc
  fout_SON->rcm_SON_99p_cc = rcm_SON_99p_cc
  fout_SON->obs_SON_99p_clm = obs_SON_99p_clm
  fout_SON->gdd_hist_SON_99p_clm = gdd_hist_SON_99p_clm
  fout_SON->gdd_fut_SON_99p_clm = gdd_fut_SON_99p_clm
  fout_SON->rcm_hist_SON_99p_clm = rcm_hist_SON_99p_clm
  fout_SON->rcm_fut_SON_99p_clm = rcm_fut_SON_99p_clm
  fout_SON->av_SON_01p = av_SON_01p
  fout_SON->gdd_SON_01p_rmse = gdd_SON_01p_rmse
  fout_SON->rcm_SON_01p_rmse = rcm_SON_01p_rmse
  fout_SON->av_SON_01p_ncl = av_SON_01p_ncl
  fout_SON->gdd_SON_01p_rmse_ncl = gdd_SON_01p_rmse_ncl
  fout_SON->rcm_SON_01p_rmse_ncl = rcm_SON_01p_rmse_ncl
  fout_SON->pav_SON_01p = pav_SON_01p
  fout_SON->rav_SON_01p = rav_SON_01p
  fout_SON->obs_SON_01p_variance = obs_SON_01p_variance
  fout_SON->gdd_SON_01p_cc = gdd_SON_01p_cc
  fout_SON->rcm_SON_01p_cc = rcm_SON_01p_cc
  fout_SON->obs_SON_01p_clm = obs_SON_01p_clm
  fout_SON->gdd_hist_SON_01p_clm = gdd_hist_SON_01p_clm
  fout_SON->gdd_fut_SON_01p_clm = gdd_fut_SON_01p_clm
  fout_SON->rcm_hist_SON_01p_clm = rcm_hist_SON_01p_clm
  fout_SON->rcm_fut_SON_01p_clm = rcm_fut_SON_01p_clm
  print(systemfunc("date"))
end