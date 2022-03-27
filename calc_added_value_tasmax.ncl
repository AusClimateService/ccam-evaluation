; calculate Added Value (AV)

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/scratch/q49/bxn599/CaRSA/rav_ncl/percentiles.ncl"

begin
  var = "tasmax" ; daily maximum temperature
  season = "annual"
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

  fout_name = "CCAM_ACCESS1-0_"+hist_start+"-"+hist_end+"_"+fut_start+"-"+fut_end+"_"+var+"_"+season+"_added_value.nc"

  yyyy_hist = ispan(hist_start, hist_end, 1)
  yyyy_fut = ispan(fut_start, fut_end, 1)
  ls_gdd_hist = systemfunc("ls /g/data/rr3/publications/CMIP5/output1/CSIRO-BOM/ACCESS1-0/historical/day/atmos/day/r1i1p1/latest/tasmax/tasmax*.nc")
  ls_gdd_fut = systemfunc("ls /g/data/rr3/publications/CMIP5/output1/CSIRO-BOM/ACCESS1-0/rcp85/day/atmos/day/r1i1p1/latest/tasmax/tasmax*.nc")
  ls_rcm_hist = "/scratch/e53/mxt599/esci/ccam_access1-0_aus_12km/regrid/tasmax_AUS-12_CSIRO-BOM-ACCESS1-0_historical_r1i1p1_CSIRO-CCAM_r4602_day_"+yyyy_hist+"0101-"+yyyy_hist+"1231.nc"
  ls_rcm_fut = "/scratch/e53/mxt599/esci/ccam_access1-0_aus_12km/regrid/tasmax_AUS-12_CSIRO-BOM-ACCESS1-0_rcp85_r1i1p1_CSIRO-CCAM_r4602_day_"+yyyy_fut+"0101-"+yyyy_fut+"1231.nc"
  ls_obs = "/g/data/zv2/agcd/v1/tmax/mean/r005/01day/agcd_v1_tmax_mean_r005_daily_"+yyyy_hist+".nc"

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
  gdd_hist = ifile_gdd_hist[:]->tasmax
  if gdd_hist@units .eq. "K" then
    gdd_hist = gdd_hist-273.15
    gdd_hist@units = "degC"
  end if
  gdd_hist_date = cd_calendar(gdd_hist&time, -2)
  gdd_hist_st0 = ind(gdd_hist_date.eq.hist_start_day)
  gdd_hist_ed0 = ind(gdd_hist_date.eq.hist_end_day)
  gdd_hist_ = gdd_hist(gdd_hist_st0:gdd_hist_ed0,{-45:-10},{110.625:157.5}) ; restrict to aus region
  delete(gdd_hist)
  gdd_hist = gdd_hist_
  delete(gdd_hist_)

  gdd_fut = ifile_gdd_fut[:]->tasmax
  if gdd_fut@units .eq. "K" then
    gdd_fut = gdd_fut-273.15
    gdd_fut@units = "degC"
  end if
  gdd_fut_date = cd_calendar(gdd_fut&time, -2)
  gdd_fut_st0 = ind(gdd_fut_date.eq.fut_start_day)
  gdd_fut_ed0 = ind(gdd_fut_date.eq.fut_end_day)
  gdd_fut_ = gdd_fut(gdd_fut_st0:gdd_fut_ed0,{-45:-10},{110.625:157.5}) ; restrict to aus region
  delete(gdd_fut)
  gdd_fut = gdd_fut_
  delete(gdd_fut_)

  rcm_hist = ifile_rcm_hist[:]->tasmax
  if rcm_hist@units .eq. "K" then
    rcm_hist = rcm_hist-273.15
    rcm_hist@units = "degC"
  end if

  rcm_fut = ifile_rcm_fut[:]->tasmax
  if rcm_fut@units .eq. "K" then
    rcm_fut = rcm_fut-273.15
    rcm_fut@units = "degC"
  end if

  obs = ifile_obs[:]->tmax
  if obs@units .eq. "K" then
    obs = obs-273.15
    obs@units = "degC"
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

; create new arrays for statistics
  rcm_hist_avg = new((/window, nlat, nlon/), float) ; average
  rcm_hist_avg!0 = "year"
  rcm_hist_avg!1 = "lat"
  rcm_hist_avg!2 = "lon"
  rcm_hist_avg&year = hist_years
  rcm_hist_avg&lat = lat
  rcm_hist_avg&lon = lon
  rcm_hist_var = new((/window, nlat, nlon/), float) ; variance
  rcm_hist_var!0 = "year"
  rcm_hist_var!1 = "lat"
  rcm_hist_var!2 = "lon"
  rcm_hist_var&year = hist_years
  rcm_hist_var&lat = lat
  rcm_hist_var&lon = lon
  rcm_hist_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  rcm_hist_99p!0 = "year"
  rcm_hist_99p!1 = "lat"
  rcm_hist_99p!2 = "lon"
  rcm_hist_99p&year = hist_years
  rcm_hist_99p&lat = lat
  rcm_hist_99p&lon = lon
  rcm_hist_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  rcm_hist_01p!0 = "year"
  rcm_hist_01p!1 = "lat"
  rcm_hist_01p!2 = "lon"
  rcm_hist_01p&year = hist_years
  rcm_hist_01p&lat = lat
  rcm_hist_01p&lon = lon

  rcm_fut_avg = new((/window, nlat, nlon/), float) ; average
  rcm_fut_avg!0 = "year"
  rcm_fut_avg!1 = "lat"
  rcm_fut_avg!2 = "lon"
  rcm_fut_avg&year = fut_years
  rcm_fut_avg&lat = lat
  rcm_fut_avg&lon = lon
  rcm_fut_var = new((/window, nlat, nlon/), float) ; variance
  rcm_fut_var!0 = "year"
  rcm_fut_var!1 = "lat"
  rcm_fut_var!2 = "lon"
  rcm_fut_var&year = fut_years
  rcm_fut_var&lat = lat
  rcm_fut_var&lon = lon
  rcm_fut_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  rcm_fut_99p!0 = "year"
  rcm_fut_99p!1 = "lat"
  rcm_fut_99p!2 = "lon"
  rcm_fut_99p&year = fut_years
  rcm_fut_99p&lat = lat
  rcm_fut_99p&lon = lon
  rcm_fut_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  rcm_fut_01p!0 = "year"
  rcm_fut_01p!1 = "lat"
  rcm_fut_01p!2 = "lon"
  rcm_fut_01p&year = fut_years
  rcm_fut_01p&lat = lat
  rcm_fut_01p&lon = lon

  gdd_hist_avg = new((/window, nlat, nlon/), float) ; average
  gdd_hist_avg!0 = "year"
  gdd_hist_avg!1 = "lat"
  gdd_hist_avg!2 = "lon"
  gdd_hist_avg&year = hist_years
  gdd_hist_avg&lat = lat
  gdd_hist_avg&lon = lon
  gdd_hist_var = new((/window, nlat, nlon/), float) ; variance
  gdd_hist_var!0 = "year"
  gdd_hist_var!1 = "lat"
  gdd_hist_var!2 = "lon"
  gdd_hist_var&year = hist_years
  gdd_hist_var&lat = lat
  gdd_hist_var&lon = lon
  gdd_hist_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  gdd_hist_99p!0 = "year"
  gdd_hist_99p!1 = "lat"
  gdd_hist_99p!2 = "lon"
  gdd_hist_99p&year = hist_years
  gdd_hist_99p&lat = lat
  gdd_hist_99p&lon = lon
  gdd_hist_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  gdd_hist_01p!0 = "year"
  gdd_hist_01p!1 = "lat"
  gdd_hist_01p!2 = "lon"
  gdd_hist_01p&year = hist_years
  gdd_hist_01p&lat = lat
  gdd_hist_01p&lon = lon

  gdd_fut_avg = new((/window, nlat, nlon/), float) ; average
  gdd_fut_avg!0 = "year"
  gdd_fut_avg!1 = "lat"
  gdd_fut_avg!2 = "lon"
  gdd_fut_avg&year = fut_years
  gdd_fut_avg&lat = lat
  gdd_fut_avg&lon = lon
  gdd_fut_var = new((/window, nlat, nlon/), float) ; variance
  gdd_fut_var!0 = "year"
  gdd_fut_var!1 = "lat"
  gdd_fut_var!2 = "lon"
  gdd_fut_var&year = fut_years
  gdd_fut_var&lat = lat
  gdd_fut_var&lon = lon
  gdd_fut_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  gdd_fut_99p!0 = "year"
  gdd_fut_99p!1 = "lat"
  gdd_fut_99p!2 = "lon"
  gdd_fut_99p&year = fut_years
  gdd_fut_99p&lat = lat
  gdd_fut_99p&lon = lon
  gdd_fut_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  gdd_fut_01p!0 = "year"
  gdd_fut_01p!1 = "lat"
  gdd_fut_01p!2 = "lon"
  gdd_fut_01p&year = fut_years
  gdd_fut_01p&lat = lat
  gdd_fut_01p&lon = lon

  obs_avg = new((/window, nlat, nlon/), float) ; average
  obs_avg!0 = "year"
  obs_avg!1 = "lat"
  obs_avg!2 = "lon"
  obs_avg&year = hist_years
  obs_avg&lat = lat
  obs_avg&lon = lon
  obs_var = new((/window, nlat, nlon/), float) ; variance
  obs_var!0 = "year"
  obs_var!1 = "lat"
  obs_var!2 = "lon"
  obs_var&year = hist_years
  obs_var&lat = lat
  obs_var&lon = lon
  obs_99p = new((/window, nlat, nlon/), float) ; 99th percentile 
  obs_99p!0 = "year"
  obs_99p!1 = "lat"
  obs_99p!2 = "lon"
  obs_99p&year = hist_years
  obs_99p&lat = lat
  obs_99p&lon = lon
  obs_01p = new((/window, nlat, nlon/), float) ; 1th percentile
  obs_01p!0 = "year"
  obs_01p!1 = "lat"
  obs_01p!2 = "lon"
  obs_01p&year = hist_years
  obs_01p&lat = lat
  obs_01p&lon = lon

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

    ; calculate stats
    rcm_hist_temp_avg = dim_avg_n_Wrap(rcm_hist_temp, 0)
    rcm_hist_temp_var = dim_variance_n_Wrap(rcm_hist_temp, 0)
    rcm_hist_temp_99p = percent_to_value_2d(rcm_hist_temp, 99)
    rcm_hist_temp_01p = percent_to_value_2d(rcm_hist_temp, 1)

    rcm_fut_temp_avg = dim_avg_n_Wrap(rcm_fut_temp, 0)
    rcm_fut_temp_var = dim_variance_n_Wrap(rcm_fut_temp, 0)
    rcm_fut_temp_99p = percent_to_value_2d(rcm_fut_temp, 99)
    rcm_fut_temp_01p = percent_to_value_2d(rcm_fut_temp, 1)

    gdd_hist_temp_avg = dim_avg_n_Wrap(gdd_hist_temp, 0)
    gdd_hist_temp_var = dim_variance_n_Wrap(gdd_hist_temp, 0)
    gdd_hist_temp_99p = percent_to_value_2d(gdd_hist_temp, 99)
    gdd_hist_temp_01p = percent_to_value_2d(gdd_hist_temp, 1)

    gdd_fut_temp_avg = dim_avg_n_Wrap(gdd_fut_temp, 0)
    gdd_fut_temp_var = dim_variance_n_Wrap(gdd_fut_temp, 0)
    gdd_fut_temp_99p = percent_to_value_2d(gdd_fut_temp, 99)
    gdd_fut_temp_01p = percent_to_value_2d(gdd_fut_temp, 1)

    obs_temp_avg = dim_avg_n_Wrap(obs_temp, 0)
    obs_temp_var = dim_variance_n_Wrap(obs_temp, 0)
    obs_temp_99p = percent_to_value_2d(obs_temp, 99)
    obs_temp_01p = percent_to_value_2d(obs_temp, 1)

    ; put into array
    rcm_hist_avg(nyrc,:,:) = (/rcm_hist_temp_avg/)
    rcm_hist_var(nyrc,:,:) = (/rcm_hist_temp_var/)
    rcm_hist_99p(nyrc,:,:) = (/rcm_hist_temp_99p/)
    rcm_hist_01p(nyrc,:,:) = (/rcm_hist_temp_01p/)
    rcm_fut_avg(nyrc,:,:) = (/rcm_fut_temp_avg/)
    rcm_fut_var(nyrc,:,:) = (/rcm_fut_temp_var/)
    rcm_fut_99p(nyrc,:,:) = (/rcm_fut_temp_99p/)
    rcm_fut_01p(nyrc,:,:) = (/rcm_fut_temp_01p/)
    gdd_hist_avg(nyrc,:,:) = (/gdd_hist_temp_avg/)
    gdd_hist_var(nyrc,:,:) = (/gdd_hist_temp_var/)
    gdd_hist_99p(nyrc,:,:) = (/gdd_hist_temp_99p/)
    gdd_hist_01p(nyrc,:,:) = (/gdd_hist_temp_01p/)
    gdd_fut_avg(nyrc,:,:) = (/gdd_fut_temp_avg/)
    gdd_fut_var(nyrc,:,:) = (/gdd_fut_temp_var/)
    gdd_fut_99p(nyrc,:,:) = (/gdd_fut_temp_99p/)
    gdd_fut_01p(nyrc,:,:) = (/gdd_fut_temp_01p/)
    obs_avg(nyrc,:,:) = (/obs_temp_avg/)
    obs_var(nyrc,:,:) = (/obs_temp_var/)
    obs_99p(nyrc,:,:) = (/obs_temp_99p/)
    obs_01p(nyrc,:,:) = (/obs_temp_01p/)

    delete([/rcm_hist_temp, rcm_fut_temp, gdd_hist_temp, gdd_fut_temp, obs_temp, rcm_hist_temp_avg, rcm_hist_temp_var, rcm_hist_temp_99p, rcm_hist_temp_01p/])
    delete([/rcm_fut_temp_avg, rcm_fut_temp_var, rcm_fut_temp_99p, rcm_fut_temp_01p, gdd_hist_temp_avg, gdd_hist_temp_var, gdd_hist_temp_99p, gdd_hist_temp_01p/])
    delete([/gdd_fut_temp_avg, gdd_fut_temp_var, gdd_fut_temp_99p, gdd_fut_temp_01p, obs_temp_avg, obs_temp_var, obs_temp_99p, obs_temp_01p/])
    delete([/hist_yr_sel, hist_yrs, fut_yrs, fut_yr_sel/])
  end do

;******************************
;******************************
  print(systemfunc("date"))
  print("Finished looping over years, calculating AV, PAV, RAV")

  ; calculate avg, variance, percentiles annual mean
  rcm_hist_avg_clm = dim_avg_n_Wrap(rcm_hist_avg, 0)
  rcm_hist_var_clm = dim_avg_n_Wrap(rcm_hist_var, 0)
  rcm_hist_99p_clm = dim_avg_n_Wrap(rcm_hist_99p, 0)
  rcm_hist_01p_clm = dim_avg_n_Wrap(rcm_hist_01p, 0)

  rcm_fut_avg_clm = dim_avg_n_Wrap(rcm_fut_avg, 0)
  rcm_fut_var_clm = dim_avg_n_Wrap(rcm_fut_var, 0)
  rcm_fut_99p_clm = dim_avg_n_Wrap(rcm_fut_99p, 0)
  rcm_fut_01p_clm = dim_avg_n_Wrap(rcm_fut_01p, 0)

  gdd_hist_avg_clm = dim_avg_n_Wrap(gdd_hist_avg, 0)
  gdd_hist_var_clm = dim_avg_n_Wrap(gdd_hist_var, 0)
  gdd_hist_99p_clm = dim_avg_n_Wrap(gdd_hist_99p, 0)
  gdd_hist_01p_clm = dim_avg_n_Wrap(gdd_hist_01p, 0)

  gdd_fut_avg_clm = dim_avg_n_Wrap(gdd_fut_avg, 0)
  gdd_fut_var_clm = dim_avg_n_Wrap(gdd_fut_var, 0)
  gdd_fut_99p_clm = dim_avg_n_Wrap(gdd_fut_99p, 0)
  gdd_fut_01p_clm = dim_avg_n_Wrap(gdd_fut_01p, 0)

  obs_avg_clm = dim_avg_n_Wrap(obs_avg, 0)
  obs_var_clm = dim_avg_n_Wrap(obs_var, 0)
  obs_99p_clm = dim_avg_n_Wrap(obs_99p, 0)
  obs_01p_clm = dim_avg_n_Wrap(obs_01p, 0)

  ; calculate Added Value (AV) for avg, variance, percentiles
  rcm_avg_rmse = rcm_hist_avg_clm
  rcm_avg_rmse = sqrt((rcm_hist_avg_clm - obs_avg_clm)^2)
  rcm_var_rmse = rcm_hist_var_clm
  rcm_var_rmse = sqrt((rcm_hist_var_clm - obs_var_clm)^2)
  rcm_99p_rmse = rcm_hist_99p_clm
  rcm_99p_rmse = sqrt((rcm_hist_99p_clm - obs_99p_clm)^2)
  rcm_01p_rmse = rcm_hist_01p_clm
  rcm_01p_rmse = sqrt((rcm_hist_01p_clm - obs_01p_clm)^2)

  gdd_avg_rmse = gdd_hist_avg_clm
  gdd_avg_rmse = sqrt((gdd_hist_avg_clm - obs_avg_clm)^2)
  gdd_var_rmse = gdd_hist_var_clm
  gdd_var_rmse = sqrt((gdd_hist_var_clm - obs_var_clm)^2)
  gdd_99p_rmse = gdd_hist_99p_clm
  gdd_99p_rmse = sqrt((gdd_hist_99p_clm - obs_99p_clm)^2)
  gdd_01p_rmse = gdd_hist_01p_clm
  gdd_01p_rmse = sqrt((gdd_hist_01p_clm - obs_01p_clm)^2)

  av_avg = gdd_avg_rmse
  av_avg = gdd_avg_rmse - rcm_avg_rmse
  av_var = gdd_var_rmse
  av_var = gdd_var_rmse - rcm_var_rmse
  av_99p = gdd_99p_rmse
  av_99p = gdd_99p_rmse - rcm_99p_rmse
  av_01p = gdd_01p_rmse
  av_01p = gdd_01p_rmse - rcm_01p_rmse

  ; calculate rmse using ncl function (uses annual time series data)
  rcm_avg_rmse_ncl = dim_rmsd_n_Wrap(obs_avg, rcm_hist_avg, 0)
  rcm_var_rmse_ncl = dim_rmsd_n_Wrap(obs_var, rcm_hist_var, 0)
  rcm_99p_rmse_ncl = dim_rmsd_n_Wrap(obs_99p, rcm_hist_99p, 0)
  rcm_01p_rmse_ncl = dim_rmsd_n_Wrap(obs_01p, rcm_hist_01p, 0)

  gdd_avg_rmse_ncl = dim_rmsd_n_Wrap(obs_avg, gdd_hist_avg, 0)
  gdd_var_rmse_ncl = dim_rmsd_n_Wrap(obs_var, gdd_hist_var, 0)
  gdd_99p_rmse_ncl = dim_rmsd_n_Wrap(obs_99p, gdd_hist_99p, 0)
  gdd_01p_rmse_ncl = dim_rmsd_n_Wrap(obs_01p, gdd_hist_01p, 0)

  av_avg_ncl = gdd_avg_rmse_ncl
  av_avg_ncl = gdd_avg_rmse_ncl - rcm_avg_rmse_ncl
  av_var_ncl = gdd_var_rmse_ncl
  av_var_ncl = gdd_var_rmse_ncl - rcm_var_rmse_ncl
  av_99p_ncl = gdd_99p_rmse_ncl
  av_99p_ncl = gdd_99p_rmse_ncl - rcm_99p_rmse_ncl
  av_01p_ncl = gdd_01p_rmse_ncl
  av_01p_ncl = gdd_01p_rmse_ncl - rcm_01p_rmse_ncl

  ; calculate Potential Added Value (PAV)
  rcm_avg_cc = rcm_fut_avg_clm
  rcm_avg_cc = rcm_fut_avg_clm - rcm_hist_avg_clm
  rcm_var_cc = rcm_fut_var_clm
  rcm_var_cc = rcm_fut_var_clm - rcm_hist_var_clm
  rcm_99p_cc = rcm_fut_99p_clm
  rcm_99p_cc = rcm_fut_99p_clm - rcm_hist_99p_clm
  rcm_01p_cc = rcm_fut_01p_clm
  rcm_01p_cc = rcm_fut_01p_clm - rcm_hist_01p_clm

  gdd_avg_cc = gdd_fut_avg_clm
  gdd_avg_cc = gdd_fut_avg_clm - gdd_hist_avg_clm
  gdd_var_cc = gdd_fut_var_clm
  gdd_var_cc = gdd_fut_var_clm - gdd_hist_var_clm
  gdd_99p_cc = gdd_fut_99p_clm
  gdd_99p_cc = gdd_fut_99p_clm - gdd_hist_99p_clm
  gdd_01p_cc = gdd_fut_01p_clm
  gdd_01p_cc = gdd_fut_01p_clm - gdd_hist_01p_clm

  pav_avg = rcm_avg_cc
  pav_avg = rcm_avg_cc - gdd_avg_cc
  pav_var = rcm_var_cc
  pav_var = rcm_var_cc - gdd_var_cc
  pav_99p = rcm_99p_cc
  pav_99p = rcm_99p_cc - gdd_99p_cc
  pav_01p = rcm_01p_cc
  pav_01p = rcm_01p_cc - gdd_01p_cc

  ; calculate Realised Added Value (RAV)
  obs_avg_variance = dim_variance_n_Wrap(obs_avg, 0)
  obs_var_variance = dim_variance_n_Wrap(obs_var, 0)
  obs_99p_variance = dim_variance_n_Wrap(obs_99p, 0)
  obs_01p_variance = dim_variance_n_Wrap(obs_01p, 0)

  rav_avg = av_avg
  rav_avg = (av_avg * abs(pav_avg))/obs_avg_variance
  rav_var = av_var
  rav_var = (av_var * abs(pav_var))/obs_var_variance
  rav_99p = av_99p
  rav_99p = (av_99p * abs(pav_99p))/obs_99p_variance
  rav_01p = av_01p
  rav_01p = (av_01p * abs(pav_01p))/obs_01p_variance

  print(systemfunc("date"))
  print("Outputting data")
  fout = addfile(fout_name, "c")
  fout->av_avg = av_avg
  fout->gdd_avg_rmse = gdd_avg_rmse
  fout->rcm_avg_rmse = rcm_avg_rmse
  fout->av_avg_ncl = av_avg_ncl
  fout->gdd_avg_rmse_ncl = gdd_avg_rmse_ncl
  fout->rcm_avg_rmse_ncl = rcm_avg_rmse_ncl
  fout->pav_avg = pav_avg
  fout->rav_avg = rav_avg
  fout->obs_avg_variance = obs_avg_variance
  fout->gdd_avg_cc = gdd_avg_cc
  fout->rcm_avg_cc = rcm_avg_cc
  fout->obs_avg_clm = obs_avg_clm
  fout->gdd_hist_avg_clm = gdd_hist_avg_clm
  fout->gdd_fut_avg_clm = gdd_fut_avg_clm
  fout->rcm_hist_avg_clm = rcm_hist_avg_clm
  fout->rcm_fut_avg_clm = rcm_fut_avg_clm

  fout->av_var = av_var
  fout->gdd_var_rmse = gdd_var_rmse
  fout->rcm_var_rmse = rcm_var_rmse
  fout->av_var_ncl = av_var_ncl
  fout->gdd_var_rmse_ncl = gdd_var_rmse_ncl
  fout->rcm_var_rmse_ncl = rcm_var_rmse_ncl
  fout->pav_var = pav_var
  fout->rav_var = rav_var
  fout->obs_var_variance = obs_var_variance
  fout->gdd_var_cc = gdd_var_cc
  fout->rcm_var_cc = rcm_var_cc
  fout->obs_var_clm = obs_var_clm
  fout->gdd_hist_var_clm = gdd_hist_var_clm
  fout->gdd_fut_var_clm = gdd_fut_var_clm
  fout->rcm_hist_var_clm = rcm_hist_var_clm
  fout->rcm_fut_var_clm = rcm_fut_var_clm

  fout->av_99p = av_99p
  fout->gdd_99p_rmse = gdd_99p_rmse
  fout->rcm_99p_rmse = rcm_99p_rmse
  fout->av_99p_ncl = av_99p_ncl
  fout->gdd_99p_rmse_ncl = gdd_99p_rmse_ncl
  fout->rcm_99p_rmse_ncl = rcm_99p_rmse_ncl
  fout->pav_99p = pav_99p
  fout->rav_99p = rav_99p
  fout->obs_99p_variance = obs_99p_variance
  fout->gdd_99p_cc = gdd_99p_cc
  fout->rcm_99p_cc = rcm_99p_cc
  fout->obs_99p_clm = obs_99p_clm
  fout->gdd_hist_99p_clm = gdd_hist_99p_clm
  fout->gdd_fut_99p_clm = gdd_fut_99p_clm
  fout->rcm_hist_99p_clm = rcm_hist_99p_clm
  fout->rcm_fut_99p_clm = rcm_fut_99p_clm

  fout->av_01p = av_01p
  fout->gdd_01p_rmse = gdd_01p_rmse
  fout->rcm_01p_rmse = rcm_01p_rmse
  fout->av_01p_ncl = av_01p_ncl
  fout->gdd_01p_rmse_ncl = gdd_01p_rmse_ncl
  fout->rcm_01p_rmse_ncl = rcm_01p_rmse_ncl
  fout->pav_01p = pav_01p
  fout->rav_01p = rav_01p
  fout->obs_01p_variance = obs_01p_variance
  fout->gdd_01p_cc = gdd_01p_cc
  fout->rcm_01p_cc = rcm_01p_cc
  fout->obs_01p_clm = obs_01p_clm
  fout->gdd_hist_01p_clm = gdd_hist_01p_clm
  fout->gdd_fut_01p_clm = gdd_fut_01p_clm
  fout->rcm_hist_01p_clm = rcm_hist_01p_clm
  fout->rcm_fut_01p_clm = rcm_fut_01p_clm

  print(systemfunc("date"))
end