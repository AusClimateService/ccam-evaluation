; plot climpact difference with agcd

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
  rad    = 4.0*atan(1.0)/180.0
  re     = 6371220.0
  rr     = re*rad

  ; obs 
  of = addfile("/g/data/xv83/bxn599/CaRSA/climpact_agcd/climpact_output_"+yrStrt+"-"+yrLast+"/"+var+"_MON"+fileo, "r")
  og = addfile("/g/data/xv83/bxn599/CaRSA/climpact_agcd/climpact_output_"+yrStrt+"-"+yrLast+"/"+var+"_ANN"+fileo, "r")
  obs = of->$var$
  obs_ann = og->$var$

  ; land sea mask file (AWAP grid)
  f2 = addfile("/scratch/e53/mxt599/esci/sftrf_AWAP0.05_NRMv3.nc", "r")
  lsmask = f2->AUS

  ; RCM
  f=addfile("../calculated/climpact_output_"+yrStrt+"-"+yrLast+"/"+var+"_MON"+filen, "r")
  g=addfile("../calculated/climpact_output_"+yrStrt+"-"+yrLast+"/"+var+"_ANN"+filen, "r")

  rcm = f->$var$
  rcm_ann = g->$var$

  units = rcm@units

  ; GDD
  gf=addfile("/g/data/xv83/bxn599/CaRSA/climpact_era5_reanalysis/climpact_output_"+yrStrt+"-"+yrLast+"/"+var+"_MON"+fileg, "r")
  gg=addfile("/g/data/xv83/bxn599/CaRSA/climpact_era5_reanalysis/climpact_output_"+yrStrt+"-"+yrLast+"/"+var+"_ANN"+fileg, "r")

  gdd = gf->$var$
  gdd_ann = gg->$var$

  ; select aus region
  rcm_aus = rcm(:,{-44.5:-10},{112:156.25})
  rcm_ann_aus = rcm_ann(:,{-44.5:-10},{112:156.25})
  rcm_aus!1 = "lat"
  rcm_aus!2 = "lon"
  rcm_ann_aus!1 = "lat"
  rcm_ann_aus!2 = "lon"
  delete(rcm)
  delete(rcm_ann)

  gdd_aus = gdd(:,{-44.5:-10},{112:156.25})
  gdd_ann_aus = gdd_ann(:,{-44.5:-10},{112:156.25})
  gdd_aus!1 = "lat"
  gdd_aus!2 = "lon"
  gdd_ann_aus!1 = "lat"
  gdd_ann_aus!2 = "lon"
  delete(gdd)
  delete(gdd_ann)

  ; regrid rcm/gdd to obs grid
  print("Regridding")
  newlat = fspan(-44.5, -10., dimsizes(obs&lat)) ; 691
  newlon = fspan(112., 156.25, dimsizes(obs&lon)) ; 886
  newlat@units = "degrees_north"
  newlon@units = "degrees_east"

  rcm_regrid = linint2_Wrap(rcm_aus&lon, rcm_aus&lat, rcm_aus, False, newlon, newlat, 0)
  rcm_regrid!1   ="lat"
  rcm_regrid!2   = "lon"
  rcm_regrid&lat = newlat
  rcm_regrid&lon = newlon
  delete(rcm_aus)
  rcm = rcm_regrid
  delete(rcm_regrid)

  rcm_ann_regrid = linint2_Wrap(rcm_ann_aus&lon, rcm_ann_aus&lat, rcm_ann_aus, False, newlon, newlat, 0)
  rcm_ann_regrid!1   ="lat"
  rcm_ann_regrid!2   = "lon"
  rcm_ann_regrid&lat = newlat
  rcm_ann_regrid&lon = newlon
  delete(rcm_ann_aus)
  rcm_ann = rcm_ann_regrid
  delete(rcm_ann_regrid)

  gdd_regrid = linint2_Wrap(gdd_aus&lon, gdd_aus&lat, gdd_aus, False, newlon, newlat, 0)
  gdd_regrid!1   ="lat"
  gdd_regrid!2   = "lon"
  gdd_regrid&lat = newlat
  gdd_regrid&lon = newlon
  delete(gdd_aus)
  gdd = gdd_regrid
  delete(gdd_regrid)

  gdd_ann_regrid = linint2_Wrap(gdd_ann_aus&lon, gdd_ann_aus&lat, gdd_ann_aus, False, newlon, newlat, 0)
  gdd_ann_regrid!1   ="lat"
  gdd_ann_regrid!2   = "lon"
  gdd_ann_regrid&lat = newlat
  gdd_ann_regrid&lon = newlon
  delete(gdd_ann_aus)
  gdd_ann = gdd_ann_regrid
  delete(gdd_ann_regrid)

  print("Finished interpolation, masking data")
  rcm_mask = rcm
  rcm_mask = mask(rcm, conform(rcm, lsmask, (/1, 2/)), 1)
  delete(rcm)
  rcm = rcm_mask
  delete(rcm_mask)

  rcm_ann_mask = rcm_ann
  rcm_ann_mask = mask(rcm_ann, conform(rcm_ann, lsmask, (/1, 2/)), 1)
  delete(rcm_ann)
  rcm_ann = rcm_ann_mask
  delete(rcm_ann_mask)

  obs_mask = obs
  obs_mask = mask(obs, conform(obs, lsmask, (/1, 2/)), 1)
  delete(obs)
  obs = obs_mask
  delete(obs_mask)

  obs_ann_mask = obs_ann
  obs_ann_mask = mask(obs_ann, conform(obs_ann, lsmask, (/1, 2/)), 1)
  delete(obs_ann)
  obs_ann = obs_ann_mask
  delete(obs_ann_mask)

  gdd_mask = gdd
  gdd_mask = mask(gdd, conform(gdd, lsmask, (/1, 2/)), 1)
  delete(gdd)
  gdd = gdd_mask
  delete(gdd_mask)

  gdd_ann_mask = gdd_ann
  gdd_ann_mask = mask(gdd_ann, conform(gdd_ann, lsmask, (/1, 2/)), 1)
  delete(gdd_ann)
  gdd_ann = gdd_ann_mask
  delete(gdd_ann_mask)

; calculate seasonal/annual
  obs_DJF = month_to_season(obs, "DJF")
  obs_DJF_avg = dim_avg_n_Wrap(obs_DJF, 0)
  rcm_DJF = month_to_season(rcm, "DJF")
  rcm_DJF_avg = dim_avg_n_Wrap(rcm_DJF, 0)
  gdd_DJF = month_to_season(gdd, "DJF")
  gdd_DJF_avg = dim_avg_n_Wrap(gdd_DJF, 0)

  obs_MAM = month_to_season(obs, "MAM")
  obs_MAM_avg = dim_avg_n_Wrap(obs_MAM, 0)
  rcm_MAM = month_to_season(rcm, "MAM")
  rcm_MAM_avg = dim_avg_n_Wrap(rcm_MAM, 0)
  gdd_MAM = month_to_season(gdd, "MAM")
  gdd_MAM_avg = dim_avg_n_Wrap(gdd_MAM, 0)

  obs_JJA = month_to_season(obs, "JJA")
  obs_JJA_avg = dim_avg_n_Wrap(obs_JJA, 0)
  rcm_JJA = month_to_season(rcm, "JJA")
  rcm_JJA_avg = dim_avg_n_Wrap(rcm_JJA, 0)
  gdd_JJA = month_to_season(gdd, "JJA")
  gdd_JJA_avg = dim_avg_n_Wrap(gdd_JJA, 0)

  obs_SON = month_to_season(obs, "SON")
  obs_SON_avg = dim_avg_n_Wrap(obs_SON, 0)
  rcm_SON = month_to_season(rcm, "SON")
  rcm_SON_avg = dim_avg_n_Wrap(rcm_SON, 0)
  gdd_SON = month_to_season(gdd, "SON")
  gdd_SON_avg = dim_avg_n_Wrap(gdd_SON, 0)

  obs_ann_avg = dim_avg_n_Wrap(obs_ann, 0)
  rcm_ann_avg = dim_avg_n_Wrap(rcm_ann, 0)
  gdd_ann_avg = dim_avg_n_Wrap(gdd_ann, 0)
  ;obs_ann = month_to_annual(obs, 1)
  ;rcm_ann = month_to_annual(rcm, 1)
  ;gdd_ann = month_to_annual(gdd, 1)

  ; area average for time series
  lat = obs&lat
  lon = obs&lon
  nlat = dimsizes(lat)

  dlon   = abs(lon(2)-lon(1))*rr
  dx     = dlon*cos(lat*rad)
  dy     = new (nlat, typeof(dx))
  dy(0)  = abs(lat(2)-lat(1))*rr
  dy(1:nlat-2)  = abs(lat(2:nlat-1)-lat(0:nlat-3))*rr*0.5   
  dy(nlat-1)    = abs(lat(nlat-1)-lat(nlat-2))*rr

  weights = dx*dy

  mon = new(12, string)
  mon(0) = "JAN"
  mon(1) = "FEB"
  mon(2) = "MAR"
  mon(3) = "APR"
  mon(4) = "MAY"
  mon(5) = "JUN"
  mon(6) = "JUL"
  mon(7) = "AUG"
  mon(8) = "SEP"
  mon(9) = "OCT"
  mon(10) = "NOV"
  mon(11) = "DEC"
  
; Observations
  obs_dims = dimsizes(obs(0::12,:,:))

  obs_mon = new((/12, obs_dims(0), obs_dims(1), obs_dims(2)/),typeof(obs))

  obs_mon(0,:,:,:) = obs(0::12,:,:)
  obs_mon(1,:,:,:) = obs(1::12,:,:)
  obs_mon(2,:,:,:) = obs(2::12,:,:)
  obs_mon(3,:,:,:) = obs(3::12,:,:)
  obs_mon(4,:,:,:) = obs(4::12,:,:)
  obs_mon(5,:,:,:) = obs(5::12,:,:)
  obs_mon(6,:,:,:) = obs(6::12,:,:)
  obs_mon(7,:,:,:) = obs(7::12,:,:)
  obs_mon(8,:,:,:) = obs(8::12,:,:)
  obs_mon(9,:,:,:) = obs(9::12,:,:)
  obs_mon(10,:,:,:) = obs(10::12,:,:)
  obs_mon(11,:,:,:) = obs(11::12,:,:)
  obs_mon_avg = dim_avg_n_Wrap(obs_mon, 1)
  obs_avg = dim_avg_n_Wrap(obs, 0)

; RCM
  rcm_dims = dimsizes(rcm(0::12,:,:))

  rcm_mon = new((/12, rcm_dims(0), rcm_dims(1), rcm_dims(2)/),typeof(rcm))

  rcm_mon(0,:,:,:) = rcm(0::12,:,:)
  rcm_mon(1,:,:,:) = rcm(1::12,:,:)
  rcm_mon(2,:,:,:) = rcm(2::12,:,:)
  rcm_mon(3,:,:,:) = rcm(3::12,:,:)
  rcm_mon(4,:,:,:) = rcm(4::12,:,:)
  rcm_mon(5,:,:,:) = rcm(5::12,:,:)
  rcm_mon(6,:,:,:) = rcm(6::12,:,:)
  rcm_mon(7,:,:,:) = rcm(7::12,:,:)
  rcm_mon(8,:,:,:) = rcm(8::12,:,:)
  rcm_mon(9,:,:,:) = rcm(9::12,:,:)
  rcm_mon(10,:,:,:) = rcm(10::12,:,:)
  rcm_mon(11,:,:,:) = rcm(11::12,:,:)
  rcm_mon_avg = dim_avg_n_Wrap(rcm_mon, 1)
  rcm_avg = dim_avg_n_Wrap(rcm, 0)

; GDD
  gdd_dims = dimsizes(gdd(0::12,:,:))

  gdd_mon = new((/12, gdd_dims(0), gdd_dims(1), gdd_dims(2)/),typeof(gdd))

  gdd_mon(0,:,:,:) = gdd(0::12,:,:)
  gdd_mon(1,:,:,:) = gdd(1::12,:,:)
  gdd_mon(2,:,:,:) = gdd(2::12,:,:)
  gdd_mon(3,:,:,:) = gdd(3::12,:,:)
  gdd_mon(4,:,:,:) = gdd(4::12,:,:)
  gdd_mon(5,:,:,:) = gdd(5::12,:,:)
  gdd_mon(6,:,:,:) = gdd(6::12,:,:)
  gdd_mon(7,:,:,:) = gdd(7::12,:,:)
  gdd_mon(8,:,:,:) = gdd(8::12,:,:)
  gdd_mon(9,:,:,:) = gdd(9::12,:,:)
  gdd_mon(10,:,:,:) = gdd(10::12,:,:)
  gdd_mon(11,:,:,:) = gdd(11::12,:,:)
  gdd_mon_avg = dim_avg_n_Wrap(gdd_mon, 1)
  gdd_avg = dim_avg_n_Wrap(gdd, 0)

; calculate bias (RCM minus Obs/RCM minus GDD)
  rcm_obs_DJF_bias = rcm_DJF_avg
  rcm_obs_DJF_bias = rcm_DJF_avg - obs_DJF_avg
  rcm_obs_MAM_bias = rcm_MAM_avg
  rcm_obs_MAM_bias = rcm_MAM_avg - obs_MAM_avg
  rcm_obs_JJA_bias = rcm_JJA_avg
  rcm_obs_JJA_bias = rcm_JJA_avg - obs_JJA_avg
  rcm_obs_SON_bias = rcm_SON_avg
  rcm_obs_SON_bias = rcm_SON_avg - obs_SON_avg
  rcm_obs_mon_bias = rcm_mon_avg
  rcm_obs_mon_bias = rcm_mon_avg - obs_mon_avg
  rcm_obs_ann_bias = rcm_ann_avg
  rcm_obs_ann_bias = rcm_ann_avg - obs_ann_avg
  rcm_obs_all_mon_bias = rcm_avg
  rcm_obs_all_mon_bias = rcm_avg - obs_avg

  rcm_gdd_DJF_bias = rcm_DJF_avg
  rcm_gdd_DJF_bias = rcm_DJF_avg - gdd_DJF_avg
  rcm_gdd_MAM_bias = rcm_MAM_avg
  rcm_gdd_MAM_bias = rcm_MAM_avg - gdd_MAM_avg
  rcm_gdd_JJA_bias = rcm_JJA_avg
  rcm_gdd_JJA_bias = rcm_JJA_avg - gdd_JJA_avg
  rcm_gdd_SON_bias = rcm_SON_avg
  rcm_gdd_SON_bias = rcm_SON_avg - gdd_SON_avg
  rcm_gdd_mon_bias = rcm_mon_avg
  rcm_gdd_mon_bias = rcm_mon_avg - gdd_mon_avg
  rcm_gdd_ann_bias = rcm_ann_avg
  rcm_gdd_ann_bias = rcm_ann_avg - gdd_ann_avg
  rcm_gdd_all_mon_bias = rcm_avg
  rcm_gdd_all_mon_bias = rcm_avg - gdd_avg

; calculate rmse
  rcm_obs_DJF_rmse = dim_rmsd_n_Wrap(rcm_DJF, obs_DJF, 0)
  rcm_obs_MAM_rmse = dim_rmsd_n_Wrap(rcm_MAM, obs_MAM, 0)
  rcm_obs_JJA_rmse = dim_rmsd_n_Wrap(rcm_JJA, obs_JJA, 0)
  rcm_obs_SON_rmse = dim_rmsd_n_Wrap(rcm_SON, obs_SON, 0)
  rcm_obs_mon_rmse = dim_rmsd_n_Wrap(rcm_mon, obs_mon, 1)
  rcm_obs_ann_rmse = dim_rmsd_n_Wrap(rcm_ann, obs_ann, 0)
  rcm_obs_all_mon_rmse = dim_rmsd_n_Wrap(rcm, obs, 0)

  rcm_gdd_DJF_rmse = dim_rmsd_n_Wrap(rcm_DJF, gdd_DJF, 0)
  rcm_gdd_MAM_rmse = dim_rmsd_n_Wrap(rcm_MAM, gdd_MAM, 0)
  rcm_gdd_JJA_rmse = dim_rmsd_n_Wrap(rcm_JJA, gdd_JJA, 0)
  rcm_gdd_SON_rmse = dim_rmsd_n_Wrap(rcm_SON, gdd_SON, 0)
  rcm_gdd_mon_rmse = dim_rmsd_n_Wrap(rcm_mon, gdd_mon, 1)
  rcm_gdd_ann_rmse = dim_rmsd_n_Wrap(rcm_ann, gdd_ann, 0)
  rcm_gdd_all_mon_rmse = dim_rmsd_n_Wrap(rcm, gdd, 0)

; OLD calculation code OLD calculation code
; OLD calculation code OLD calculation code
; OLD calculation code OLD calculation code
  ;; calculate difference with agcd
  ;  data = rcm
  ;  data_ann = rcm_ann
  ;
  ;  data = rcm - obs
  ;  data_ann = rcm_ann - obs_ann
  ;
  ;  ; area average for time series
  ;  lat = data&lat
  ;  lon = data&lon
  ;  nlat = dimsizes(lat)
  ;
  ;  dlon   = abs(lon(2)-lon(1))*rr
  ;  dx     = dlon*cos(lat*rad)
  ;  dy     = new (nlat, typeof(dx))
  ;  dy(0)  = abs(lat(2)-lat(1))*rr
  ;  dy(1:nlat-2)  = abs(lat(2:nlat-1)-lat(0:nlat-3))*rr*0.5   
  ;  dy(nlat-1)    = abs(lat(nlat-1)-lat(nlat-2))*rr
  ;
  ;  data_wgt = dx*dy
  ;
  ;  data_area_avg = wgt_areaave_Wrap(data, data_wgt, 1.0, 0) ; output has time dimension
  ;  data_area_avg_std = stddev(data_area_avg)
  ;  data_time_avg = dim_avg_n_Wrap(data, 0)
  ;  data_time_std = stddev(data_time_avg)
  ;
  ;  data_dims = dimsizes(data(0::12,:,:))
  ;
  ;  data_mon = new((/12, data_dims(0), data_dims(1), data_dims(2)/),typeof(data))
  ;  mon = new(12, string)
  ;  mon(0) = "JAN"
  ;  mon(1) = "FEB"
  ;  mon(2) = "MAR"
  ;  mon(3) = "APR"
  ;  mon(4) = "MAY"
  ;  mon(5) = "JUN"
  ;  mon(6) = "JUL"
  ;  mon(7) = "AUG"
  ;  mon(8) = "SEP"
  ;  mon(9) = "OCT"
  ;  mon(10) = "NOV"
  ;  mon(11) = "DEC"
  ;
  ;  data_mon(0,:,:,:) = data(0::12,:,:)
  ;  data_mon(1,:,:,:) = data(1::12,:,:)
  ;  data_mon(2,:,:,:) = data(2::12,:,:)
  ;  data_mon(3,:,:,:) = data(3::12,:,:)
  ;  data_mon(4,:,:,:) = data(4::12,:,:)
  ;  data_mon(5,:,:,:) = data(5::12,:,:)
  ;  data_mon(6,:,:,:) = data(6::12,:,:)
  ;  data_mon(7,:,:,:) = data(7::12,:,:)
  ;  data_mon(8,:,:,:) = data(8::12,:,:)
  ;  data_mon(9,:,:,:) = data(9::12,:,:)
  ;  data_mon(10,:,:,:) = data(10::12,:,:)
  ;  data_mon(11,:,:,:) = data(11::12,:,:)
  ;
  ;  data_mon_avg = dim_avg_n_Wrap(data_mon, 1)
  ;  data_mon_std = dim_stddev_n_Wrap(data_mon_avg, (/1, 2/))
  ;  data_mon_area_avg = wgt_areaave_Wrap(data_mon, data_wgt, 1.0, 0)
  ;  data_mon_area_avg_std = dim_stddev_n_Wrap(data_mon_area_avg, 1)
  ;
  ;  data_ann_area_avg = wgt_areaave_Wrap(data_ann, data_wgt, 1.0, 0)
  ;  data_ann_area_avg_std = stddev(data_ann_area_avg)
  ;  data_ann_time_avg = dim_avg_n_Wrap(data_ann, 0)
  ;  data_ann_time_std = stddev(data_ann_time_avg)
  ;
  ;; calculate seasonal
  ;  data_DJF = month_to_season(data, "DJF")
  ;  data_DJF_avg = dim_avg_n_Wrap(data_DJF, 0)
  ;  data_DJF_std = stddev(data_DJF_avg)
  ;  data_DJF_area_avg = wgt_areaave_Wrap(data_DJF, data_wgt, 1.0, 0)
  ;  data_DJF_area_avg_std = stddev(data_DJF_area_avg)
  ;  data_MAM = month_to_season(data, "MAM")
  ;  data_MAM_avg = dim_avg_n_Wrap(data_MAM, 0)
  ;  data_MAM_std = stddev(data_MAM_avg)
  ;  data_MAM_area_avg = wgt_areaave_Wrap(data_MAM, data_wgt, 1.0, 0)
  ;  data_MAM_area_avg_std = stddev(data_MAM_area_avg)
  ;  data_JJA = month_to_season(data, "JJA")
  ;  data_JJA_avg = dim_avg_n_Wrap(data_JJA, 0)
  ;  data_JJA_std = stddev(data_JJA_avg)
  ;  data_JJA_area_avg = wgt_areaave_Wrap(data_JJA, data_wgt, 1.0, 0)
  ;  data_JJA_area_avg_std = stddev(data_JJA_area_avg)
  ;  data_SON = month_to_season(data, "SON")
  ;  data_SON_avg = dim_avg_n_Wrap(data_SON, 0)
  ;  data_SON_std = stddev(data_SON_avg)
  ;  data_SON_area_avg = wgt_areaave_Wrap(data_SON, data_wgt, 1.0, 0)
  ;  data_SON_area_avg_std = stddev(data_SON_area_avg)
  ;
  ;; generate x-axis for time series
  ;  data_date = cd_calendar(data&time, -1)
  ;  data_ann_date = cd_calendar(data_ann&time, -1)/100
  ;  xaxis = yyyymm_to_yyyyfrac(data_date, 0)
  ;  xaxis_ann = data_ann_date
  ;
  ;; calculate regression
  ;  rc_mon = new(dimsizes(data_mon_area_avg(:,0)), double)
  ;  rc_mon_data = new(dimsizes(data_mon_area_avg), double)
  ;  yint_mon = new(dimsizes(data_mon_area_avg(:,0)), double)
  ;
  ;  do nc = 0, 11
  ;    rc_mon(nc) = regCoef(data_mon_area_avg&time, data_mon_area_avg(nc,:))
  ;    yint_mon(nc) = rc_mon@yintercept
  ;    rc_mon_data(nc,:) = rc_mon(nc)*data_mon_area_avg&time+yint_mon(nc)
  ;  end do
  ;    rc_mon = rc_mon*365
  ;    rc_mon@units = data_mon_area_avg@units+"/year"
  ;
  ;  rc_DJF = regCoef(data_DJF_area_avg&time, data_DJF_area_avg)
  ;  rc_DJF_data = rc_DJF*data_DJF_area_avg&time+rc_DJF@yintercept
  ;  rc_DJF = rc_DJF*365
  ;  rc_DJF@units = data_DJF_area_avg@units+"/year"
  ;
  ;  rc_MAM = regCoef(data_MAM_area_avg&time, data_MAM_area_avg)
  ;  rc_MAM_data = rc_MAM*data_MAM_area_avg&time+rc_MAM@yintercept
  ;  rc_MAM = rc_MAM*365
  ;  rc_MAM@units = data_MAM_area_avg@units+"/year"
  ;
  ;  rc_JJA = regCoef(data_JJA_area_avg&time, data_JJA_area_avg)
  ;  rc_JJA_data = rc_JJA*data_JJA_area_avg&time+rc_JJA@yintercept
  ;  rc_JJA = rc_JJA*365
  ;  rc_JJA@units = data_JJA_area_avg@units+"/year"
  ;
  ;  rc_SON = regCoef(data_SON_area_avg&time, data_SON_area_avg)
  ;  rc_SON_data = rc_SON*data_SON_area_avg&time+rc_SON@yintercept
  ;  rc_SON = rc_SON*365
  ;  rc_SON@units = data_SON_area_avg@units+"/year"
  ;
  ;  rc_ANN = regCoef(data_ann_area_avg&time, data_ann_area_avg)
  ;  rc_ANN_data = rc_ANN*data_ann_area_avg&time+rc_ANN@yintercept
  ;  rc_ANN = rc_ANN*365
  ;  rc_ANN@units = data_ann_area_avg@units+"/year"
  ;
  ;  rc_MON = regCoef(data_area_avg&time, data_area_avg)
  ;  rc_MON_data = rc_MON*data_area_avg&time+rc_MON@yintercept
  ;  rc_MON = rc_MON*365
  ;  rc_MON@units = data_area_avg@units+"/year"

; plot
  ;plot_name = "../plots_seasonal/"+run_name+"_rcm_obs_climpact_"+var+"_seasonal_annual_bias_rmse"
  obs_name = "../plots_seasonal/"+run_name+"_rcm_obs_climpact_"+var+"_seasonal_annual_bias_rmse"
  gdd_name = "../plots_seasonal/"+run_name+"_rcm_gdd_climpact_"+var+"_seasonal_annual_bias_rmse"

  print(systemfunc("date"))
  print("Plotting")

; plot
; resources
  res = True
  res@gsnSpreadColors      = True         ; spread out color table
  res@gsnMaximize          = False
  res@gsnFrame             = False
  res@gsnDraw              = False
  res@gsnAddCyclic         = False        ; plotted dataa are not cyclic
  res@lbLabelBarOn         = True        ; turn off individual lb's
  res@lbLabelAutoStride    = True
  res@gsnRightString       = ""
  res@tiYAxisString        = ""                  ; yaxis string
  res@tiXAxisString        = ""  ; xaxis string
  res@lbOrientation        = "Horizontal"
  res@pmTickMarkDisplayMode= "Always"
  res@gsnStringFontHeightF = 0.025
  res@tmXBLabelFontHeightF = 0.025
  res@tmYLLabelFontHeightF = 0.025
  res@tiXAxisFontHeightF   = 0.025
  res@tiYAxisFontHeightF   = 0.025
  ;res@tiXAxisOffsetYF      = 0.014
  res@tmXBLabelDeltaF      = -0.5
  res@tiYAxisOffsetXF      = 0.012
  res@tiMainFontHeightF    = 0.025
;  res@vpWidthF             = 0.7
;  res@vpHeightF            = 0.35
  res@tiMainFont           = 25
  res@tiMainOffsetYF       = -0.01
  res@tmXBLabelsOn         = True
  res@tmXBTickSpacingF     = 10.0
  res@gsnLeftStringOrthogonalPosF = 0.03
  res@gsnRightStringOrthogonalPosF = -0.03
  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  ;res@lbLabelStride        = 5
  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels
  res@mpMinLatF = -45.
  res@mpMaxLatF = -10.
  res@mpMinLonF = 112.
  res@mpMaxLonF = 156.25
  res@pmLabelBarOrthogonalPosF = 0.1
  res@trYReverse = True
  res@tmLabelAutoStride = True
  res@tmXTOn = False
  res@tmXBMinorOn = False
  res@tmYLLabelsOn = True
  res@tmXBLabelsOn = True
  res@lbLabelsOn = True
   res@cnFillMode = "CellFill" ; for faster plotting

;  wks = gsn_open_wks("pdf", plot_name)
;  plot0 = new(18, graphic)
;  plot1 = new(18, graphic)
;  regl = new(dimsizes(plot1), graphic)
;  cmap_cmocean_balance = read_colormap_file("cmocean_balance")
;  cmap_MPL_Reds = read_colormap_file("MPL_Reds")

  wks0 = gsn_open_wks("pdf", obs_name)
  wks1 = gsn_open_wks("pdf", gdd_name)
  plot0 = new(18, graphic)
  plot1 = new(18, graphic)
  plot2 = new(18, graphic)
  plot3 = new(18, graphic)
  cmap_cmocean_balance = read_colormap_file("cmocean_balance")
  cmap_MPL_Reds = read_colormap_file("MPL_Reds")

if var.eq."prcptot".or.var.eq."r10mm".or.var.eq."r20mm".or.var.eq."r30mm".or.var.eq."rx1day".or.var.eq."rx5day".or.var.eq."rx7day" then
  res@cnFillPalette = cmap_cmocean_balance(::-1,:) ; reverse the colourmap
else
  res@cnFillPalette = cmap_cmocean_balance
end if

; area weights
  lat = rcm_obs_mon_bias&lat
  lon = rcm_obs_mon_bias&lon
  nlat = dimsizes(lat)

  dlon   = abs(lon(2)-lon(1))*rr
  dx     = dlon*cos(lat*rad)
  dy     = new (nlat, typeof(dx))
  dy(0)  = abs(lat(2)-lat(1))*rr
  dy(1:nlat-2)  = abs(lat(2:nlat-1)-lat(0:nlat-3))*rr*0.5   
  dy(nlat-1)    = abs(lat(nlat-1)-lat(nlat-2))*rr

  data_wgt = dx*dy

; BIAS
  do n=0,11
    aavg = wgt_areaave_Wrap(rcm_obs_mon_bias(n,:,:), data_wgt, 1.0, 0)
    sd = stddev(rcm_obs_mon_bias(n,:,:))
    tp = num(.not.ismissing(rcm_obs_mon_bias(n,:,:)))
    pp = num(where(rcm_obs_mon_bias(n,:,:).gt.0, 1, 0))
    np = num(where(rcm_obs_mon_bias(n,:,:).lt.0, 1, 0))
    res@gsnLeftString = var+" "+mon(n)+", ~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np

    stats = stat_dispersion(rcm_obs_mon_bias, False)
    dmin = stats(3)
    dmax = stats(13)
    mmin = stats(2)
    mmax = stats(14)

    ; calculate which is larger
    if dmin .eq. dmax then
      if abs(mmin) .gt. abs(mmax) then
        mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
      else if abs(mmax) .gt. abs(mmin) then
        mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
      end if
      end if
    else
      if abs(dmin) .gt. abs(dmax) then
        mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
      else if abs(dmax) .gt. abs(dmin) then
        mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
      end if
      end if
    end if

    res@cnMinLevelValF = mnmxint(0)
    res@cnMaxLevelValF = mnmxint(1)
    res@cnLevelSpacingF = mnmxint(2)
    plot0(n) = gsn_csm_contour_map_ce(wks0, rcm_obs_mon_bias(n,:,:), res)
    delete(aavg)
    delete(sd)
    delete([/tp, pp, np/])
  end do

  ; append seasons into 1 large array
  season0 = array_append_record(rcm_obs_DJF_bias, rcm_obs_MAM_bias, 0)
  season1 = array_append_record(season0, rcm_obs_JJA_bias, 0)
  season =  array_append_record(season1, rcm_obs_SON_bias, 0)

  stats = stat_dispersion(season, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)

  ; calculate which is larger and use the same scale for all seasons
  if dmin .eq. dmax then
    if abs(mmin) .gt. abs(mmax) then
      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
    else if abs(mmax) .gt. abs(mmin) then
      mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
    end if
    end if
  else
    if abs(dmin) .gt. abs(dmax) then
      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
    else if abs(dmax) .gt. abs(dmin) then
      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
    end if
    end if
  end if
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_obs_DJF_bias, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_DJF_bias)
  tp = num(.not.ismissing(rcm_obs_DJF_bias))
  pp = num(where(rcm_obs_DJF_bias.gt.0, 1, 0))
  np = num(where(rcm_obs_DJF_bias.lt.0, 1, 0))
  res@gsnLeftString = var+" DJF, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(12) = gsn_csm_contour_map_ce(wks0, rcm_obs_DJF_bias, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  aavg = wgt_areaave_Wrap(rcm_obs_MAM_bias, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_MAM_bias)
  tp = num(.not.ismissing(rcm_obs_MAM_bias))
  pp = num(where(rcm_obs_MAM_bias.gt.0, 1, 0))
  np = num(where(rcm_obs_MAM_bias.lt.0, 1, 0))
  res@gsnLeftString = var+" MAM, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(13) = gsn_csm_contour_map_ce(wks0, rcm_obs_MAM_bias, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  aavg = wgt_areaave_Wrap(rcm_obs_JJA_bias, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_JJA_bias)
  tp = num(.not.ismissing(rcm_obs_JJA_bias))
  pp = num(where(rcm_obs_JJA_bias.gt.0, 1, 0))
  np = num(where(rcm_obs_JJA_bias.lt.0, 1, 0))
  res@gsnLeftString = var+" JJA, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(14) = gsn_csm_contour_map_ce(wks0, rcm_obs_JJA_bias, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  aavg = wgt_areaave_Wrap(rcm_obs_SON_bias, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_SON_bias)
  tp = num(.not.ismissing(rcm_obs_SON_bias))
  pp = num(where(rcm_obs_SON_bias.gt.0, 1, 0))
  np = num(where(rcm_obs_SON_bias.lt.0, 1, 0))
  res@gsnLeftString = var+" SON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(15) = gsn_csm_contour_map_ce(wks0, rcm_obs_SON_bias, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  stats = stat_dispersion(rcm_obs_all_mon_bias, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)
  ; calculate which is larger
  if dmin .eq. dmax then
    if abs(mmin) .gt. abs(mmax) then
      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
    else if abs(mmax) .gt. abs(mmin) then
      mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
    end if
    end if
  else
    if abs(dmin) .gt. abs(dmax) then
      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
    else if abs(dmax) .gt. abs(dmin) then
      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
    end if
    end if
  end if
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_obs_all_mon_bias, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_all_mon_bias)
  tp = num(.not.ismissing(rcm_obs_all_mon_bias))
  pp = num(where(rcm_obs_all_mon_bias.gt.0, 1, 0))
  np = num(where(rcm_obs_all_mon_bias.lt.0, 1, 0))
  res@gsnLeftString = var+" MON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(16) = gsn_csm_contour_map_ce(wks0, rcm_obs_all_mon_bias, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  stats = stat_dispersion(rcm_obs_ann_bias, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)
  ; calculate which is larger
  if dmin .eq. dmax then
    if abs(mmin) .gt. abs(mmax) then
      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
    else if abs(mmax) .gt. abs(mmin) then
      mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
    end if
    end if
  else
    if abs(dmin) .gt. abs(dmax) then
      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
    else if abs(dmax) .gt. abs(dmin) then
      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
    end if
    end if
  end if
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_obs_ann_bias, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_ann_bias)
  tp = num(.not.ismissing(rcm_obs_ann_bias))
  pp = num(where(rcm_obs_ann_bias.gt.0, 1, 0))
  np = num(where(rcm_obs_ann_bias.lt.0, 1, 0))
  res@gsnLeftString = var+" ANN, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(17) = gsn_csm_contour_map_ce(wks0, rcm_obs_ann_bias, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])
  
; RMSE
  do n=0,11
    aavg = wgt_areaave_Wrap(rcm_obs_mon_rmse(n,:,:), data_wgt, 1.0, 0)
    sd = stddev((rcm_obs_mon_rmse(n,:,:)))
    res@gsnLeftString = var+" "+mon(n)+", ~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)

    stats = stat_dispersion(rcm_obs_mon_rmse, False)
    dmin = stats(3)
    dmax = stats(13)
    mmin = stats(2)
    mmax = stats(14)

    ; calculate which is larger
    if dmin .eq. dmax then
      if abs(mmin) .gt. abs(mmax) then
        mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
      else if abs(mmax) .gt. abs(mmin) then
        mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
      end if
      end if
    else
      if abs(dmin) .gt. abs(dmax) then
        mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
      else if abs(dmax) .gt. abs(dmin) then
        mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
      end if
      end if
    end if

    res@cnMinLevelValF = 0;mnmxint(0)
    res@cnMaxLevelValF = mnmxint(1)
    res@cnLevelSpacingF = mnmxint(2)

    plot1(n) = gsn_csm_contour_map_ce(wks0, rcm_obs_mon_rmse(n,:,:), res)
    delete(aavg)
    delete(sd)
  end do

  ; append seasons into 1 large array
  season0 = array_append_record(rcm_obs_DJF_rmse, rcm_obs_MAM_rmse, 0)
  season1 = array_append_record(season0, rcm_obs_JJA_rmse, 0)
  season =  array_append_record(season1, rcm_obs_SON_rmse, 0)

  stats = stat_dispersion(season, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)

  ; calculate which is larger and use the same scale for all seasons
  if dmin .eq. dmax then
    if abs(mmin) .gt. abs(mmax) then
      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
    else if abs(mmax) .gt. abs(mmin) then
      mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
    end if
    end if
  else
    if abs(dmin) .gt. abs(dmax) then
      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
    else if abs(dmax) .gt. abs(dmin) then
      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
    end if
    end if
  end if
  res@cnMinLevelValF = 0;mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_obs_DJF_rmse, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_DJF_rmse)
  res@gsnLeftString = var+" DJF, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot1(12) = gsn_csm_contour_map_ce(wks0, rcm_obs_DJF_rmse, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(rcm_obs_MAM_rmse, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_MAM_rmse)
  res@gsnLeftString = var+" MAM, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot1(13) = gsn_csm_contour_map_ce(wks0, rcm_obs_MAM_rmse, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(rcm_obs_JJA_rmse, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_JJA_rmse)
  res@gsnLeftString = var+" JJA, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot1(14) = gsn_csm_contour_map_ce(wks0, rcm_obs_JJA_rmse, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(rcm_obs_SON_rmse, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_SON_rmse)
  res@gsnLeftString = var+" SON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot1(15) = gsn_csm_contour_map_ce(wks0, rcm_obs_SON_rmse, res)
  delete(aavg)
  delete(sd)

  stats = stat_dispersion(rcm_obs_all_mon_rmse, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)
  ; calculate which is larger
  if dmin .eq. dmax then
    if abs(mmin) .gt. abs(mmax) then
      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
    else if abs(mmax) .gt. abs(mmin) then
      mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
    end if
    end if
  else
    if abs(dmin) .gt. abs(dmax) then
      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
    else if abs(dmax) .gt. abs(dmin) then
      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
    end if
    end if
  end if
  res@cnMinLevelValF = 0;mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_obs_all_mon_rmse, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_all_mon_rmse)
  res@gsnLeftString = var+" MON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot1(16) = gsn_csm_contour_map_ce(wks0, rcm_obs_all_mon_rmse, res)
  delete(aavg)
  delete(sd)

  stats = stat_dispersion(rcm_obs_ann_rmse, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)
  ; calculate which is larger
  if dmin .eq. dmax then
    if abs(mmin) .gt. abs(mmax) then
      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
    else if abs(mmax) .gt. abs(mmin) then
      mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
    end if
    end if
  else
    if abs(dmin) .gt. abs(dmax) then
      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
    else if abs(dmax) .gt. abs(dmin) then
      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
    end if
    end if
  end if
  res@cnMinLevelValF = 0;mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_obs_ann_rmse, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_ann_rmse)
  res@gsnLeftString = var+" ANN, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot1(17) = gsn_csm_contour_map_ce(wks0, rcm_obs_ann_rmse, res)
  delete(aavg)
  delete(sd)
  units = rcm_obs_ann_bias@units

; Panel plots
  resP                    = True
  resP@gsnPanelMainString = "Bias: RCM-Obs. "+var+" "+yrStrt+"-"+yrLast+"~C~"+info+" ("+units+")"
  resP@gsnPanelLabelBar = False
  resP@gsnMaximize = True
  gsn_panel(wks0, (/plot0(12), plot0(13), plot0(14), plot0(15), plot0(17)/), (/1, 5/), resP)
  resP@gsnPanelLabelBar = False
  resP@gsnPanelMainString = "RMSE: RCM-Obs. "+var+" "+yrStrt+"-"+yrLast+"~C~"+info
  gsn_panel(wks0, (/plot1(12), plot1(13), plot1(14), plot1(15), plot1(17)/), (/1, 5/), resP)

; GDD
if var.eq."pr" then
  res@cnFillPalette = cmap_cmocean_balance(::-1,:) ; reverse the colourmap
else
  res@cnFillPalette = cmap_cmocean_balance
end if
  
  do n=0,11
    aavg = wgt_areaave_Wrap(rcm_gdd_mon_bias(n,:,:), data_wgt, 1.0, 0)
    sd = stddev(rcm_gdd_mon_bias(n,:,:))
    tp = num(.not.ismissing(rcm_gdd_mon_bias(n,:,:)))
    pp = num(where(rcm_gdd_mon_bias(n,:,:).gt.0, 1, 0))
    np = num(where(rcm_gdd_mon_bias(n,:,:).lt.0, 1, 0))
    res@gsnLeftString = var+" "+mon(n)+", ~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np

    stats = stat_dispersion(rcm_gdd_mon_bias, False)
    dmin = stats(3)
    dmax = stats(13)
    mmin = stats(2)
    mmax = stats(14)

    ; calculate which is larger
    if dmin .eq. dmax then
      if abs(mmin) .gt. abs(mmax) then
        mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
      else if abs(mmax) .gt. abs(mmin) then
        mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
      end if
      end if
    else
      if abs(dmin) .gt. abs(dmax) then
        mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
      else if abs(dmax) .gt. abs(dmin) then
        mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
      end if
      end if
    end if

    res@cnMinLevelValF = mnmxint(0)
    res@cnMaxLevelValF = mnmxint(1)
    res@cnLevelSpacingF = mnmxint(2)

    plot2(n) = gsn_csm_contour_map_ce(wks1, rcm_gdd_mon_bias(n,:,:), res)
    delete(aavg)
    delete(sd)
    delete([/tp, pp, np/])
  end do

  ; append seasons into 1 large array
  season0 = array_append_record(rcm_gdd_DJF_bias, rcm_gdd_MAM_bias, 0)
  season1 = array_append_record(season0, rcm_gdd_JJA_bias, 0)
  season =  array_append_record(season1, rcm_gdd_SON_bias, 0)

  stats = stat_dispersion(season, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)

  ; calculate which is larger and use the same scale for all seasons
  if dmin .eq. dmax then
    if abs(mmin) .gt. abs(mmax) then
      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
    else if abs(mmax) .gt. abs(mmin) then
      mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
    end if
    end if
  else
    if abs(dmin) .gt. abs(dmax) then
      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
    else if abs(dmax) .gt. abs(dmin) then
      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
    end if
    end if
  end if
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_gdd_DJF_bias, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_DJF_bias)
  tp = num(.not.ismissing(rcm_gdd_DJF_bias))
  pp = num(where(rcm_gdd_DJF_bias.gt.0, 1, 0))
  np = num(where(rcm_gdd_DJF_bias.lt.0, 1, 0))
  res@gsnLeftString = var+" DJF, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot2(12) = gsn_csm_contour_map_ce(wks1, rcm_gdd_DJF_bias, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  aavg = wgt_areaave_Wrap(rcm_gdd_MAM_bias, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_MAM_bias)
  tp = num(.not.ismissing(rcm_gdd_MAM_bias))
  pp = num(where(rcm_gdd_MAM_bias.gt.0, 1, 0))
  np = num(where(rcm_gdd_MAM_bias.lt.0, 1, 0))
  res@gsnLeftString = var+" MAM, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot2(13) = gsn_csm_contour_map_ce(wks1, rcm_gdd_MAM_bias, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  aavg = wgt_areaave_Wrap(rcm_gdd_JJA_bias, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_JJA_bias)
  tp = num(.not.ismissing(rcm_gdd_JJA_bias))
  pp = num(where(rcm_gdd_JJA_bias.gt.0, 1, 0))
  np = num(where(rcm_gdd_JJA_bias.lt.0, 1, 0))
  res@gsnLeftString = var+" JJA, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot2(14) = gsn_csm_contour_map_ce(wks1, rcm_gdd_JJA_bias, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  aavg = wgt_areaave_Wrap(rcm_gdd_SON_bias, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_SON_bias)
  tp = num(.not.ismissing(rcm_gdd_SON_bias))
  pp = num(where(rcm_gdd_SON_bias.gt.0, 1, 0))
  np = num(where(rcm_gdd_SON_bias.lt.0, 1, 0))
  res@gsnLeftString = var+" SON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot2(15) = gsn_csm_contour_map_ce(wks1, rcm_gdd_SON_bias, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  stats = stat_dispersion(rcm_gdd_all_mon_bias, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)
  ; calculate which is larger
  if dmin .eq. dmax then
    if abs(mmin) .gt. abs(mmax) then
      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
    else if abs(mmax) .gt. abs(mmin) then
      mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
    end if
    end if
  else
    if abs(dmin) .gt. abs(dmax) then
      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
    else if abs(dmax) .gt. abs(dmin) then
      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
    end if
    end if
  end if
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_gdd_all_mon_bias, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_all_mon_bias)
  tp = num(.not.ismissing(rcm_gdd_all_mon_bias))
  pp = num(where(rcm_gdd_all_mon_bias.gt.0, 1, 0))
  np = num(where(rcm_gdd_all_mon_bias.lt.0, 1, 0))
  res@gsnLeftString = var+" MON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot2(16) = gsn_csm_contour_map_ce(wks1, rcm_gdd_all_mon_bias, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  stats = stat_dispersion(rcm_gdd_ann_bias, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)
  ; calculate which is larger
  if dmin .eq. dmax then
    if abs(mmin) .gt. abs(mmax) then
      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
    else if abs(mmax) .gt. abs(mmin) then
      mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
    end if
    end if
  else
    if abs(dmin) .gt. abs(dmax) then
      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
    else if abs(dmax) .gt. abs(dmin) then
      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
    end if
    end if
  end if
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_gdd_ann_bias, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_ann_bias)
  tp = num(.not.ismissing(rcm_gdd_ann_bias))
  pp = num(where(rcm_gdd_ann_bias.gt.0, 1, 0))
  np = num(where(rcm_gdd_ann_bias.lt.0, 1, 0))
  res@gsnLeftString = var+" ANN, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot2(17) = gsn_csm_contour_map_ce(wks1, rcm_gdd_ann_bias, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])
  
  do n=0,11
    aavg = wgt_areaave_Wrap(rcm_gdd_mon_rmse(n,:,:), data_wgt, 1.0, 0)
    sd = stddev(rcm_gdd_mon_rmse(n,:,:))
    res@gsnLeftString = var+" "+mon(n)+", ~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)

    stats = stat_dispersion(rcm_gdd_mon_rmse, False)
    dmin = stats(3)
    dmax = stats(13)
    mmin = stats(2)
    mmax = stats(14)

    ; calculate which is larger
    if dmin .eq. dmax then
      if abs(mmin) .gt. abs(mmax) then
        mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
      else if abs(mmax) .gt. abs(mmin) then
        mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
      end if
      end if
    else
      if abs(dmin) .gt. abs(dmax) then
        mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
      else if abs(dmax) .gt. abs(dmin) then
        mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
      end if
      end if
    end if

    res@cnMinLevelValF = 0;mnmxint(0)
    res@cnMaxLevelValF = mnmxint(1)
    res@cnLevelSpacingF = mnmxint(2)

    plot3(n) = gsn_csm_contour_map_ce(wks1, rcm_gdd_mon_rmse(n,:,:), res)
    delete(aavg)
    delete(sd)
  end do

  ; append seasons into 1 large array
  season0 = array_append_record(rcm_gdd_DJF_rmse, rcm_gdd_MAM_rmse, 0)
  season1 = array_append_record(season0, rcm_gdd_JJA_rmse, 0)
  season =  array_append_record(season1, rcm_gdd_SON_rmse, 0)

  stats = stat_dispersion(season, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)

  ; calculate which is larger and use the same scale for all seasons
  if dmin .eq. dmax then
    if abs(mmin) .gt. abs(mmax) then
      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
    else if abs(mmax) .gt. abs(mmin) then
      mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
    end if
    end if
  else
    if abs(dmin) .gt. abs(dmax) then
      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
    else if abs(dmax) .gt. abs(dmin) then
      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
    end if
    end if
  end if
  res@cnMinLevelValF = 0;mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_gdd_DJF_rmse, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_DJF_rmse)
  res@gsnLeftString = var+" DJF, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot3(12) = gsn_csm_contour_map_ce(wks1, rcm_gdd_DJF_rmse, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(rcm_gdd_MAM_rmse, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_MAM_rmse)
  res@gsnLeftString = var+" MAM, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot3(13) = gsn_csm_contour_map_ce(wks1, rcm_gdd_MAM_rmse, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(rcm_gdd_JJA_rmse, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_JJA_rmse)
  res@gsnLeftString = var+" JJA, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot3(14) = gsn_csm_contour_map_ce(wks1, rcm_gdd_JJA_rmse, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(rcm_gdd_SON_rmse, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_SON_rmse)
  res@gsnLeftString = var+" SON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot3(15) = gsn_csm_contour_map_ce(wks1, rcm_gdd_SON_rmse, res)
  delete(aavg)
  delete(sd)

  stats = stat_dispersion(rcm_gdd_all_mon_rmse, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)

  ; calculate which is larger and use the same scale for all seasons
  if dmin .eq. dmax then
    if abs(mmin) .gt. abs(mmax) then
      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
    else if abs(mmax) .gt. abs(mmin) then
      mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
    end if
    end if
  else
    if abs(dmin) .gt. abs(dmax) then
      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
    else if abs(dmax) .gt. abs(dmin) then
      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
    end if
    end if
  end if
  res@cnMinLevelValF = 0;mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_gdd_all_mon_rmse, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_all_mon_rmse)
  res@gsnLeftString = var+" MON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot3(16) = gsn_csm_contour_map_ce(wks1, rcm_gdd_all_mon_rmse, res)
  delete(aavg)
  delete(sd)

  stats = stat_dispersion(rcm_gdd_ann_rmse, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)

  ; calculate which is larger and use the same scale for all seasons
  if dmin .eq. dmax then
    if abs(mmin) .gt. abs(mmax) then
      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
    else if abs(mmax) .gt. abs(mmin) then
      mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
    end if
    end if
  else
    if abs(dmin) .gt. abs(dmax) then
      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
    else if abs(dmax) .gt. abs(dmin) then
      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
    end if
    end if
  end if
  res@cnMinLevelValF = 0;mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)
  
  aavg = wgt_areaave_Wrap(rcm_gdd_ann_rmse, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_ann_rmse)
  res@gsnLeftString = var+" ANN, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot3(17) = gsn_csm_contour_map_ce(wks1, rcm_gdd_ann_rmse, res)
  delete(aavg)
  delete(sd)

  units = rcm_gdd_ann_bias@units
; Panel plots
  resP                    = True
  resP@gsnPanelMainString = "Bias: RCM-GDD "+var+" "+yrStrt+"-"+yrLast+"~C~"+info+" ("+units+")"
  resP@gsnPanelLabelBar = False
  resP@gsnMaximize = True
  gsn_panel(wks1, (/plot2(12), plot2(13), plot2(14), plot2(15), plot2(17)/), (/1, 5/), resP)
  resP@gsnPanelLabelBar = False
  resP@gsnPanelMainString = "RMSE: RCM-GDD "+var+" "+yrStrt+"-"+yrLast+"~C~"+info
  gsn_panel(wks1, (/plot3(12), plot3(13), plot3(14), plot3(15), plot3(17)/), (/1, 5/), resP)

; OLD plot code OLD plot code OLD plot code
; OLD plot code OLD plot code OLD plot code
; OLD plot code OLD plot code OLD plot code
  ;  do n=0,11
  ;    aavg = avg(data_mon_area_avg(n,:))
  ;    res@gsnLeftString = var+" "+mon(n)+" avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", data_mon_std(n))
  ;    ;symMinMaxPlt(data_mon_avg(n,:,:), 18, True, res)
  ;    stats = stat_dispersion(data_mon_avg(n,:,:), False)
  ;    dmin = stats(3)
  ;    dmax = stats(13)
  ;    mmin = stats(2)
  ;    mmax = stats(14)
  ;
  ;    ; calculate which is larger
  ;    if dmin .eq. dmax then
  ;      if abs(mmin) .gt. abs(mmax) then
  ;        mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
  ;      else if abs(mmax) .gt. abs(mmin) then
  ;        mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
  ;      end if
  ;      end if
  ;    else
  ;      if abs(dmin) .gt. abs(dmax) then
  ;        mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
  ;      else if abs(dmax) .gt. abs(dmin) then
  ;        mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
  ;      end if
  ;      end if
  ;    end if
  ;;    if abs(dmin) .gt. abs(dmax) then
  ;;      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
  ;;    else if abs(dmax) .gt. abs(dmin) then
  ;;      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
  ;;    end if
  ;;    end if
  ;;    print("10th: "+(dmin))
  ;;    print("90th: "+(dmax))
  ;;    print("min: "+(stats(2)))
  ;;    print("max: "+(stats(14)))
  ;;    print(mnmxint)
  ;    res@cnMinLevelValF = mnmxint(0)
  ;    res@cnMaxLevelValF = mnmxint(1)
  ;    res@cnLevelSpacingF = mnmxint(2)
  ;    plot0(n) = gsn_csm_contour_map_ce(wks, data_mon_avg(n,:,:), res)
  ;    delete(aavg)
  ;  end do
  ;
  ;  ; append seasons into 1 large array
  ;  season0 = array_append_record(data_DJF_avg, data_MAM_avg, 0)
  ;  season1 = array_append_record(season0, data_JJA_avg, 0)
  ;  season =  array_append_record(season1, data_SON_avg, 0)
  ;
  ;  stats = stat_dispersion(season, False)
  ;  dmin = stats(3)
  ;  dmax = stats(13)
  ;  mmin = stats(2)
  ;  mmax = stats(14)
  ;
  ;  ; calculate which is larger and use the same scale for all seasons
  ;  if dmin .eq. dmax then
  ;    if abs(mmin) .gt. abs(mmax) then
  ;      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
  ;    else if abs(mmax) .gt. abs(mmin) then
  ;      mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
  ;    end if
  ;    end if
  ;  else
  ;    if abs(dmin) .gt. abs(dmax) then
  ;      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
  ;    else if abs(dmax) .gt. abs(dmin) then
  ;      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
  ;    end if
  ;    end if
  ;  end if
  ;  res@cnMinLevelValF = mnmxint(0)
  ;  res@cnMaxLevelValF = mnmxint(1)
  ;  res@cnLevelSpacingF = mnmxint(2)
  ;
  ;  aavg = avg(data_DJF_area_avg)
  ;  res@gsnLeftString = var+" DJF avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", data_DJF_std)
  ;  plot0(12) = gsn_csm_contour_map_ce(wks, data_DJF_avg, res)
  ;  delete(aavg)
  ;
  ;  aavg = avg(data_MAM_area_avg)
  ;  res@gsnLeftString = var+" MAM avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", data_MAM_std)
  ;  plot0(13) = gsn_csm_contour_map_ce(wks, data_MAM_avg, res)
  ;  delete(aavg)
  ;
  ;  aavg = avg(data_JJA_area_avg)
  ;  res@gsnLeftString = var+" JJA avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", data_JJA_std)
  ;  plot0(14) = gsn_csm_contour_map_ce(wks, data_JJA_avg, res)
  ;  delete(aavg)
  ;
  ;  aavg = avg(data_SON_area_avg)
  ;  res@gsnLeftString = var+" SON avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", data_SON_std)
  ;  plot0(15) = gsn_csm_contour_map_ce(wks, data_SON_avg, res)
  ;  delete(aavg)
  ;
  ;  aavg = avg(data_area_avg)
  ;  res@gsnLeftString = var+" MON avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", data_time_std)
  ;  ;symMinMaxPlt(data_time_avg, 18, True, res)
  ;  stats = stat_dispersion(data_time_avg, False)
  ;  dmin = stats(3)
  ;  dmax = stats(13)
  ;  mmin = stats(2)
  ;  mmax = stats(14)
  ;  ; calculate which is larger
  ;  if dmin .eq. dmax then
  ;    if abs(mmin) .gt. abs(mmax) then
  ;      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
  ;    else if abs(mmax) .gt. abs(mmin) then
  ;      mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
  ;    end if
  ;    end if
  ;  else
  ;    if abs(dmin) .gt. abs(dmax) then
  ;      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
  ;    else if abs(dmax) .gt. abs(dmin) then
  ;      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
  ;    end if
  ;    end if
  ;  end if
  ;  res@cnMinLevelValF = mnmxint(0)
  ;  res@cnMaxLevelValF = mnmxint(1)
  ;  res@cnLevelSpacingF = mnmxint(2)
  ;  plot0(16) = gsn_csm_contour_map_ce(wks, data_time_avg, res)
  ;  delete(aavg)
  ;
  ;  aavg = avg(data_ann_area_avg)
  ;  res@gsnLeftString = var+" ANN avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", data_ann_time_std)
  ;  ;symMinMaxPlt(data_ann_time_avg, 18, True, res)
  ;  stats = stat_dispersion(data_ann_time_avg, False)
  ;  dmin = stats(3)
  ;  dmax = stats(13)
  ;  mmin = stats(2)
  ;  mmax = stats(14)
  ;  ; calculate which is larger
  ;  if dmin .eq. dmax then
  ;    if abs(mmin) .gt. abs(mmax) then
  ;      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
  ;    else if abs(mmax) .gt. abs(mmin) then
  ;      mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
  ;    end if
  ;    end if
  ;  else
  ;    if abs(dmin) .gt. abs(dmax) then
  ;      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
  ;    else if abs(dmax) .gt. abs(dmin) then
  ;      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
  ;    end if
  ;    end if
  ;  end if
  ;  res@cnMinLevelValF = mnmxint(0)
  ;  res@cnMaxLevelValF = mnmxint(1)
  ;  res@cnLevelSpacingF = mnmxint(2)
  ;  plot0(17) = gsn_csm_contour_map_ce(wks, data_ann_time_avg, res)
  ;  delete(aavg)
  ;
  ;; time series
  ;  resxy                      = True
  ;  resxy@gsnFrame             = False
  ;  resxy@gsnDraw              = False
  ;  resxy@gsnMaximize          = False
  ;  resxy@xyMarkLineMode       = "Lines"
  ;  resxy@xyMonoDashPattern    = True
  ;  resxy@xyLineThicknessF     = 2.0
  ;  resxy@gsnLeftStringFontHeightF = 0.025
  ;  resxy@pmLegendDisplayMode    = "NoCreate"         ; Turn on the legend
  ;  resxy@xyMonoLineColor       = True
  ;  resxy@xyLineColor           = "DeepSkyBlue"
  ;
  ;  delete(resxy@xyLineColor)
  ;  resxy@xyMonoLineColor = True
  ;  resxy@xyLineColor = (/"black"/)
  ;  resxy@gsnLeftString = ""
  ;
  ;  rline = True
  ;  rline@gsLineColor       = "red" ;73
  ;  rline@gsLineDashPattern = 0
  ;  rline@gsLineThicknessF  = 4
  ;
  ;  do n=0,11
  ;    resxy@tiYAxisString = var+" "+mon(n)
  ;    resxy@gsnLeftString = "SD="+sprintf("%5.4f", data_mon_area_avg_std(n))+", RC="+sprintf("%5.4f", rc_mon(n))
  ;    plot1(n) = gsn_csm_xy(wks, xaxis_ann, data_mon_area_avg(n,:), resxy)
  ;    regl(n) = gsn_add_polyline(wks, plot1(n), xaxis_ann, rc_mon_data(n,:), rline)
  ;  end do
  ;
  ;  resxy@tiYAxisString = var+" DJF"
  ;  resxy@gsnLeftString = "SD="+sprintf("%5.4f", data_DJF_area_avg_std)+", RC="+sprintf("%5.4f", rc_DJF)
  ;  plot1(12) = gsn_csm_xy(wks, xaxis_ann, data_DJF_area_avg, resxy)
  ;  regl(12) = gsn_add_polyline(wks, plot1(12), xaxis_ann, rc_DJF_data, rline)
  ;
  ;  resxy@tiYAxisString = var+" MAM"
  ;  resxy@gsnLeftString = "SD="+sprintf("%5.4f", data_MAM_area_avg_std)+", RC="+sprintf("%5.4f", rc_MAM)
  ;  plot1(13) = gsn_csm_xy(wks, xaxis_ann, data_MAM_area_avg, resxy)
  ;  regl(13) = gsn_add_polyline(wks, plot1(13), xaxis_ann, rc_MAM_data, rline)
  ;
  ;  resxy@tiYAxisString = var+" JJA"
  ;  resxy@gsnLeftString = "SD="+sprintf("%5.4f", data_JJA_area_avg_std)+", RC="+sprintf("%5.4f", rc_JJA)
  ;  plot1(14) = gsn_csm_xy(wks, xaxis_ann, data_JJA_area_avg, resxy)
  ;  regl(14) = gsn_add_polyline(wks, plot1(14), xaxis_ann, rc_JJA_data, rline)
  ;
  ;  resxy@tiYAxisString = var+" SON"
  ;  resxy@gsnLeftString = "SD="+sprintf("%5.4f", data_SON_area_avg_std)+", RC="+sprintf("%5.4f", rc_SON)
  ;  plot1(15) = gsn_csm_xy(wks, xaxis_ann, data_SON_area_avg, resxy)
  ;  regl(15) = gsn_add_polyline(wks, plot1(15), xaxis_ann, rc_SON_data, rline)
  ;
  ;  resxy@tiYAxisString = var+" MON"
  ;  resxy@gsnLeftString = "SD="+sprintf("%5.4f", data_area_avg_std)+", RC="+sprintf("%5.4f", rc_MON)
  ;  plot1(16) = gsn_csm_xy(wks, xaxis, data_area_avg, resxy)
  ;  regl(16) = gsn_add_polyline(wks, plot1(16), xaxis, rc_MON_data, rline)
  ;
  ;  resxy@tiYAxisString = var+" ANN"
  ;  resxy@gsnLeftString = "SD="+sprintf("%5.4f", data_ann_area_avg_std)+", RC="+sprintf("%5.4f", rc_ANN)
  ;  plot1(17) = gsn_csm_xy(wks, xaxis_ann, data_ann_area_avg, resxy)
  ;  regl(17) = gsn_add_polyline(wks, plot1(17), xaxis_ann, rc_ANN_data, rline)
  ;
  ;; Panel plots
  ;  resP                    = True
  ;  resP@gsnPanelMainString = "Bias: RCM-Obs "+" "+var+" "+yrStrt+"-"+yrLast+"~C~"+info+" ("+units+")"
  ;  resP@gsnPanelLabelBar = False
  ;  resP@gsnMaximize = True
  ;  gsn_panel(wks, (/plot0(12), plot0(13), plot0(14), plot0(15), plot0(17)/), (/1, 5/), resP)
  ;  resP@gsnPanelLabelBar = False
  ;  resP@gsnPanelMainString = "Bias: RCM-Obs "+" "+var+" Aus area avg. "+yrStrt+"-"+yrLast+"~C~"+info+" ("+units+")"
  ;  gsn_panel(wks, (/plot1(12), plot1(13), plot1(14), plot1(15), plot1(17)/), (/1, 5/), resP)
end