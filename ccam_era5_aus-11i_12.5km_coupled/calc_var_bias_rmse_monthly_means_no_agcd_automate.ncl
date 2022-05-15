; calculates monthly mean bias/rmse between CCAM and ERA5 data only. NO AGCD data!
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/g/data/xv83/bxn599/CaRSA/rav_ncl/percentiles.ncl"

begin
  print(systemfunc("date"))

  foutname = "../calculated/"+run_name+"_"+var+"_bias_rmse_monthly_means_no_agcd_awap_grid.nc"

  if (fileexists(foutname)) then
    print("Output file appears to exist already, exiting...")
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
  
  ls_rcm_var = ls_rcm+yyyymm+".nc"
  ls_gdd_var = ls_gdd+yyyy+".nc"

  f_rcm_var = addfiles(ls_rcm_var, "r")
  f_gdd_var = addfiles(ls_gdd_var, "r")

  rcm_time = f_rcm_var[:]->time
  rcm_date = cd_calendar(rcm_time, -2)
  rcm_start = ind(rcm_date.eq.yyyymmdd_start)
  rcm_end = ind(rcm_date.eq.yyyymmdd_end)

  rcm_var_daily_ = f_rcm_var[:]->$rcm_var_name$(:,{-44.5:-10},{112:156.25}) ; use all time steps because raw RCM output is from 19800102 to 20200101, NOT 19800101 to 20191213
  if rcm_var_daily_@units .eq. "kg/m2/s" .or. rcm_var_daily_@units .eq."kg m-2 s-1" then
    rcm_var_daily_ = rcm_var_daily_*86400
    rcm_var_daily_@units = "mm/day"
  else if rcm_var_daily_@units .eq. "K" .or. rcm_var_daily_@units .eq. "degK" then
    rcm_var_daily_ = rcm_var_daily_ - 273.15
    rcm_var_daily_@units = "degC"
  else if rcm_var_daily_@units .eq. "degrees_Celsius" .or. rcm_var_daily_@units .eq. "Celsius" .or. rcm_var_daily_@units .eq. "C" then
    rcm_var_daily_@units = "degC"
  end if
  end if
  end if
  rcm_var_daily_!1 = "lat"
  rcm_var_daily_!2 = "lon"
  delete([/rcm_time, rcm_date, rcm_start, rcm_end/])

  time =  rcm_var_daily_&time
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
  delete(rcm_var_daily_&time)
  rcm_var_daily_&time = new_time
  rcm_time = rcm_var_daily_&time
  rcm_date = cd_calendar(rcm_time, -2)
  rcm_start = ind(rcm_date.eq.yyyymmdd_start)
  rcm_end = ind(rcm_date.eq.yyyymmdd_end)
  rcm_var_daily = rcm_var_daily_(rcm_start:rcm_end,:,:)

  delete([/rcm_time, rcm_date, rcm_start, rcm_end, rcm_var_daily_/])
  gdd_time = f_gdd_var[:]->time
  gdd_date = cd_calendar(gdd_time, -2)
  gdd_start = ind(gdd_date.eq.yyyymmdd_start)
  gdd_end = ind(gdd_date.eq.yyyymmdd_end)

  gdd_var_daily = f_gdd_var[:]->$gdd_var_name$(gdd_start:gdd_end,{-44.5:-10},{112:156.25})
  if gdd_var_daily@units .eq. "kg/m2/s" .or. gdd_var_daily@units .eq."kg m-2 s-1" then
    gdd_var_daily = gdd_var_daily*86400
    gdd_var_daily@units = "mm/day"
  else if gdd_var_daily@units .eq. "m" then
    gdd_var_daily = gdd_var_daily*1000
    gdd_var_daily@units = "mm/day"
  else if gdd_var_daily@units .eq. "K" .or. gdd_var_daily@units .eq. "degK" then
    gdd_var_daily = gdd_var_daily - 273.15
    gdd_var_daily@units = "degC"
  else if gdd_var_daily@units .eq. "degrees_Celsius" .or. gdd_var_daily@units .eq. "Celsius" .or. gdd_var_daily@units .eq. "C" then
    gdd_var_daily@units = "degC"
  end if
  end if
  end if
  end if
  gdd_var_daily!1 = "lat"
  gdd_var_daily!2 = "lon"
  delete([/gdd_time, gdd_date, gdd_start, gdd_end/])

  print(systemfunc("date"))
  print("Calculating climatology")
; calculate climatology
  rcm_var_month_ = calculate_monthly_values(rcm_var_daily, "avg", 0, False) ; monthly average
  gdd_var_month_ = calculate_monthly_values(gdd_var_daily, "avg", 0, False) ; monthly average

; regrid rcm and gdd. this is regridded to the obs grid i.e., compare rcm_regrid with obs
  print(systemfunc("date"))
  print("Regridding monthly data")
  newlat = fspan(-44.5, -10., dimsizes(lsmask&lat)) ; 691
  newlon = fspan(112., 156.25, dimsizes(lsmask&lon)) ; 886
  newlat@units = "degrees_north"
  newlon@units = "degrees_east"

  rcm_regrid = linint2_Wrap(rcm_var_month_&lon, rcm_var_month_&lat, rcm_var_month_, False, newlon, newlat, 0)
  rcm_regrid!1   = "lat"
  rcm_regrid!2   = "lon"
  rcm_regrid&lat = newlat
  rcm_regrid&lon = newlon

  gdd_regrid = linint2_Wrap(gdd_var_month_&lon, gdd_var_month_&lat, gdd_var_month_, False, newlon, newlat, 0)
  gdd_regrid!1   = "lat"
  gdd_regrid!2   = "lon"
  gdd_regrid&lat = newlat
  gdd_regrid&lon = newlon

  print(systemfunc("date"))
  print("Finished regridding")
  gdd_var_month = gdd_regrid
  ;gdd_var_month = mask(gdd_regrid, conform(gdd_regrid, lsmask, (/1, 2/)), 1) ; don't mask out data
  delete(gdd_regrid)

  rcm_var_month = rcm_regrid
  ;rcm_var_month = mask(rcm_regrid, conform(rcm_regrid, lsmask, (/1, 2/)), 1)
  delete(rcm_regrid)

  rcm_var_ann = month_to_annual(rcm_var_month, 1)
  gdd_var_ann = month_to_annual(gdd_var_month, 1)

  rcm_var_ann_avg = dim_avg_n_Wrap(rcm_var_ann, 0)
  gdd_var_ann_avg = dim_avg_n_Wrap(gdd_var_ann, 0)

; calculate bias (difference between rcm annual avg and gdd annual avg)
  bias = rcm_var_ann_avg
  bias = rcm_var_ann_avg - gdd_var_ann_avg

; calculate rmse
  rmse = dim_rmsd_n_Wrap(rcm_var_ann, gdd_var_ann, 0)

; save to file
  setfileoption("nc","Format","LargeFile")
  fout = addfile(foutname, "c")
  fout->bias_awap_grid = bias
  fout->rmse_awap_grid = rmse
  fout->rcm_var_month = rcm_var_month
  fout->gdd_var_month = gdd_var_month

  print(systemfunc("date"))
end