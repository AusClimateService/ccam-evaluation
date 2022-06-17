; plot Added Value (AV)

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
  rad = 4.0*atan(1.0)/180.0
  re  = 6371220.0
  rr  = re*rad

  f = addfile("../calculated/"+run_name+"_"+var+"_bias_rmse_monthly_means_awap_grid.nc", "r")

  obs = f->obs_var_month
  rcm = f->rcm_var_month
  gdd = f->gdd_var_month

  new_time = cd_convert(obs&time, "days since 0001-01-01 00:00:00")

  delete(obs&time)
  delete(gdd&time)
  delete(rcm&time)
  obs&time = new_time
  rcm&time = new_time
  gdd&time = new_time
  
; calculate seasonal/annual
  obs_DJF = month_to_season(obs, "DJF")
  rcm_DJF = month_to_season(rcm, "DJF")
  gdd_DJF = month_to_season(gdd, "DJF")

  obs_MAM = month_to_season(obs, "MAM")
  rcm_MAM = month_to_season(rcm, "MAM")
  gdd_MAM = month_to_season(gdd, "MAM")

  obs_JJA = month_to_season(obs, "JJA")
  rcm_JJA = month_to_season(rcm, "JJA")
  gdd_JJA = month_to_season(gdd, "JJA")

  obs_SON = month_to_season(obs, "SON")
  rcm_SON = month_to_season(rcm, "SON")
  gdd_SON = month_to_season(gdd, "SON")

  obs_ann = month_to_annual(obs, 1)
  rcm_ann = month_to_annual(rcm, 1)
  gdd_ann = month_to_annual(gdd, 1)

  obs_ann!0 = "time"
  obs_ann&time = obs_JJA&time

  rcm_ann!0 = "time"
  rcm_ann&time = rcm_JJA&time

  gdd_ann!0 = "time"
  gdd_ann&time = gdd_JJA&time

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

; Observations
  obs_area_avg = wgt_areaave_Wrap(obs, weights, 1.0, 0)
  obs_area_avg_std = stddev(obs_area_avg)
  obs_time_avg = dim_avg_n_Wrap(obs, 0)
  obs_time_std = stddev(obs_time_avg)

  obs_dims = dimsizes(obs(0::12,:,:))

  obs_mon = new((/12, obs_dims(0), obs_dims(1), obs_dims(2)/),typeof(obs))
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
  obs_mon_std = dim_stddev_n_Wrap(obs_mon_avg, (/1, 2/))
  obs_mon_area_avg = wgt_areaave_Wrap(obs_mon, weights, 1.0, 0)
  obs_mon_area_avg_std = dim_stddev_n_Wrap(obs_mon_area_avg, 1)

  obs_ann_area_avg = wgt_areaave_Wrap(obs_ann, weights, 1.0, 0)
  obs_ann_area_avg_std = stddev(obs_ann_area_avg)
  obs_ann_time_avg = dim_avg_n_Wrap(obs_ann, 0)
  obs_ann_time_std = stddev(obs_ann_time_avg)

; calculate seasonal area and time averages
  obs_DJF_avg = dim_avg_n_Wrap(obs_DJF, 0)
  obs_DJF_std = stddev(obs_DJF_avg)
  obs_DJF_area_avg = wgt_areaave_Wrap(obs_DJF, weights, 1.0, 0)
  obs_DJF_area_avg_std = stddev(obs_DJF_area_avg)
  obs_MAM_avg = dim_avg_n_Wrap(obs_MAM, 0)
  obs_MAM_std = stddev(obs_MAM_avg)
  obs_MAM_area_avg = wgt_areaave_Wrap(obs_MAM, weights, 1.0, 0)
  obs_MAM_area_avg_std = stddev(obs_MAM_area_avg)
  obs_JJA_avg = dim_avg_n_Wrap(obs_JJA, 0)
  obs_JJA_std = stddev(obs_JJA_avg)
  obs_JJA_area_avg = wgt_areaave_Wrap(obs_JJA, weights, 1.0, 0)
  obs_JJA_area_avg_std = stddev(obs_JJA_area_avg)
  obs_SON_avg = dim_avg_n_Wrap(obs_SON, 0)
  obs_SON_std = stddev(obs_SON_avg)
  obs_SON_area_avg = wgt_areaave_Wrap(obs_SON, weights, 1.0, 0)
  obs_SON_area_avg_std = stddev(obs_SON_area_avg)

; generate x-axis for time series
  obs_date = cd_calendar(obs&time, -1)
  xaxis = yyyymm_to_yyyyfrac(obs_date, 0)
  xaxis_ann = ispan(yrStrt, yrLast, 1)

; calculate regression
  obs_rc_mon = new(dimsizes(obs_mon_area_avg(:,0)), double)
  obs_rc_mon_data = new(dimsizes(obs_mon_area_avg), double)
  obs_yint_mon = new(dimsizes(obs_mon_area_avg(:,0)), double)
  obs_rc_mon_stats = new(dimsizes(obs_mon_area_avg(:,0)), double)

  do nc = 0, 11
    obs_rc_mon(nc) = regCoef(obs_mon_area_avg&time, obs_mon_area_avg(nc,:))
    obs_yint_mon(nc) = obs_rc_mon@yintercept
    obs_rc_mon_data(nc,:) = obs_rc_mon(nc)*obs_mon_area_avg&time+obs_yint_mon(nc)
    obs_rc_mon_stats(nc) = regline_stats(obs_mon_area_avg&time, obs_mon_area_avg(nc,:))
  end do
  obs_rc_mon = obs_rc_mon*365
  obs_rc_mon@units = obs_mon_area_avg@units+"/year"

  obs_rc_DJF = regCoef(obs_DJF_area_avg&time, obs_DJF_area_avg)
  obs_rc_DJF_data = obs_rc_DJF*obs_DJF_area_avg&time+obs_rc_DJF@yintercept
  obs_rc_DJF = obs_rc_DJF*365
  obs_rc_DJF@units = obs_DJF_area_avg@units+"/year"
  obs_rc_DJF_stats = regline_stats(obs_DJF_area_avg&time, obs_DJF_area_avg)

  obs_rc_MAM = regCoef(obs_MAM_area_avg&time, obs_MAM_area_avg)
  obs_rc_MAM_data = obs_rc_MAM*obs_MAM_area_avg&time+obs_rc_MAM@yintercept
  obs_rc_MAM = obs_rc_MAM*365
  obs_rc_MAM@units = obs_MAM_area_avg@units+"/year"
  obs_rc_MAM_stats = regline_stats(obs_MAM_area_avg&time, obs_MAM_area_avg)

  obs_rc_JJA = regCoef(obs_JJA_area_avg&time, obs_JJA_area_avg)
  obs_rc_JJA_data = obs_rc_JJA*obs_JJA_area_avg&time+obs_rc_JJA@yintercept
  obs_rc_JJA = obs_rc_JJA*365
  obs_rc_JJA@units = obs_JJA_area_avg@units+"/year"
  obs_rc_JJA_stats = regline_stats(obs_JJA_area_avg&time, obs_JJA_area_avg)

  obs_rc_SON = regCoef(obs_SON_area_avg&time, obs_SON_area_avg)
  obs_rc_SON_data = obs_rc_SON*obs_SON_area_avg&time+obs_rc_SON@yintercept
  obs_rc_SON = obs_rc_SON*365
  obs_rc_SON@units = obs_SON_area_avg@units+"/year"
  obs_rc_SON_stats = regline_stats(obs_SON_area_avg&time, obs_SON_area_avg)

  obs_rc_ANN = regCoef(obs_ann_area_avg&time, obs_ann_area_avg)
  obs_rc_ANN_data = obs_rc_ANN*obs_ann_area_avg&time+obs_rc_ANN@yintercept
  obs_rc_ANN = obs_rc_ANN*365
  obs_rc_ANN@units = obs_ann_area_avg@units+"/year"
  obs_rc_ANN_stats = regline_stats(obs_ann_area_avg&time, obs_ann_area_avg)

  obs_rc_MON = regCoef(obs_area_avg&time, obs_area_avg)
  obs_rc_MON_data = obs_rc_MON*obs_area_avg&time+obs_rc_MON@yintercept
  obs_rc_MON = obs_rc_MON*365
  obs_rc_MON@units = obs_area_avg@units+"/year"
  obs_rc_MON_stats = regline_stats(obs_area_avg&time, obs_area_avg)

; RCM
  rcm_area_avg = wgt_areaave_Wrap(rcm, weights, 1.0, 0)
  rcm_area_avg_std = stddev(rcm_area_avg)
  rcm_time_avg = dim_avg_n_Wrap(rcm, 0)
  rcm_time_std = stddev(rcm_time_avg)

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
  rcm_mon_std = dim_stddev_n_Wrap(rcm_mon_avg, (/1, 2/))
  rcm_mon_area_avg = wgt_areaave_Wrap(rcm_mon, weights, 1.0, 0)
  rcm_mon_area_avg_std = dim_stddev_n_Wrap(rcm_mon_area_avg, 1)

  rcm_ann_area_avg = wgt_areaave_Wrap(rcm_ann, weights, 1.0, 0)
  rcm_ann_area_avg_std = stddev(rcm_ann_area_avg)
  rcm_ann_time_avg = dim_avg_n_Wrap(rcm_ann, 0)
  rcm_ann_time_std = stddev(rcm_ann_time_avg)

; calculate seasonal area and time averages
  rcm_DJF_avg = dim_avg_n_Wrap(rcm_DJF, 0)
  rcm_DJF_std = stddev(rcm_DJF_avg)
  rcm_DJF_area_avg = wgt_areaave_Wrap(rcm_DJF, weights, 1.0, 0)
  rcm_DJF_area_avg_std = stddev(rcm_DJF_area_avg)
  rcm_MAM_avg = dim_avg_n_Wrap(rcm_MAM, 0)
  rcm_MAM_std = stddev(rcm_MAM_avg)
  rcm_MAM_area_avg = wgt_areaave_Wrap(rcm_MAM, weights, 1.0, 0)
  rcm_MAM_area_avg_std = stddev(rcm_MAM_area_avg)
  rcm_JJA_avg = dim_avg_n_Wrap(rcm_JJA, 0)
  rcm_JJA_std = stddev(rcm_JJA_avg)
  rcm_JJA_area_avg = wgt_areaave_Wrap(rcm_JJA, weights, 1.0, 0)
  rcm_JJA_area_avg_std = stddev(rcm_JJA_area_avg)
  rcm_SON_avg = dim_avg_n_Wrap(rcm_SON, 0)
  rcm_SON_std = stddev(rcm_SON_avg)
  rcm_SON_area_avg = wgt_areaave_Wrap(rcm_SON, weights, 1.0, 0)
  rcm_SON_area_avg_std = stddev(rcm_SON_area_avg)

; calculate regression
  rcm_rc_mon = new(dimsizes(rcm_mon_area_avg(:,0)), double)
  rcm_rc_mon_data = new(dimsizes(rcm_mon_area_avg), double)
  rcm_yint_mon = new(dimsizes(rcm_mon_area_avg(:,0)), double)
  rcm_rc_mon_stats = new(dimsizes(rcm_mon_area_avg(:,0)), double)

  do nc = 0, 11
    rcm_rc_mon(nc) = regCoef(rcm_mon_area_avg&time, rcm_mon_area_avg(nc,:))
    rcm_yint_mon(nc) = rcm_rc_mon@yintercept
    rcm_rc_mon_data(nc,:) = rcm_rc_mon(nc)*rcm_mon_area_avg&time+rcm_yint_mon(nc)
    rcm_rc_mon_stats(nc) = regline_stats(rcm_mon_area_avg&time, rcm_mon_area_avg(nc,:))
  end do
  rcm_rc_mon = rcm_rc_mon*365
  rcm_rc_mon@units = rcm_mon_area_avg@units+"/year"

  rcm_rc_DJF = regCoef(rcm_DJF_area_avg&time, rcm_DJF_area_avg)
  rcm_rc_DJF_data = rcm_rc_DJF*rcm_DJF_area_avg&time+rcm_rc_DJF@yintercept
  rcm_rc_DJF = rcm_rc_DJF*365
  rcm_rc_DJF@units = rcm_DJF_area_avg@units+"/year"
  rcm_rc_DJF_stats = regline_stats(rcm_DJF_area_avg&time, rcm_DJF_area_avg)

  rcm_rc_MAM = regCoef(rcm_MAM_area_avg&time, rcm_MAM_area_avg)
  rcm_rc_MAM_data = rcm_rc_MAM*rcm_MAM_area_avg&time+rcm_rc_MAM@yintercept
  rcm_rc_MAM = rcm_rc_MAM*365
  rcm_rc_MAM@units = rcm_MAM_area_avg@units+"/year"
  rcm_rc_MAM_stats = regline_stats(rcm_MAM_area_avg&time, rcm_MAM_area_avg)

  rcm_rc_JJA = regCoef(rcm_JJA_area_avg&time, rcm_JJA_area_avg)
  rcm_rc_JJA_data = rcm_rc_JJA*rcm_JJA_area_avg&time+rcm_rc_JJA@yintercept
  rcm_rc_JJA = rcm_rc_JJA*365
  rcm_rc_JJA@units = rcm_JJA_area_avg@units+"/year"
  rcm_rc_JJA_stats = regline_stats(rcm_JJA_area_avg&time, rcm_JJA_area_avg)

  rcm_rc_SON = regCoef(rcm_SON_area_avg&time, rcm_SON_area_avg)
  rcm_rc_SON_data = rcm_rc_SON*rcm_SON_area_avg&time+rcm_rc_SON@yintercept
  rcm_rc_SON = rcm_rc_SON*365
  rcm_rc_SON@units = rcm_SON_area_avg@units+"/year"
  rcm_rc_SON_stats = regline_stats(rcm_SON_area_avg&time, rcm_SON_area_avg)

  rcm_rc_ANN = regCoef(rcm_ann_area_avg&time, rcm_ann_area_avg)
  rcm_rc_ANN_data = rcm_rc_ANN*rcm_ann_area_avg&time+rcm_rc_ANN@yintercept
  rcm_rc_ANN = rcm_rc_ANN*365
  rcm_rc_ANN@units = rcm_ann_area_avg@units+"/year"
  rcm_rc_ANN_stats = regline_stats(rcm_ann_area_avg&time, rcm_ann_area_avg)

  rcm_rc_MON = regCoef(rcm_area_avg&time, rcm_area_avg)
  rcm_rc_MON_data = rcm_rc_MON*rcm_area_avg&time+rcm_rc_MON@yintercept
  rcm_rc_MON = rcm_rc_MON*365
  rcm_rc_MON@units = rcm_area_avg@units+"/year"
  rcm_rc_MON_stats = regline_stats(rcm_area_avg&time, rcm_area_avg)

; GDD
  gdd_area_avg = wgt_areaave_Wrap(gdd, weights, 1.0, 0)
  gdd_area_avg_std = stddev(gdd_area_avg)
  gdd_time_avg = dim_avg_n_Wrap(gdd, 0)
  gdd_time_std = stddev(gdd_time_avg)

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
  gdd_mon_std = dim_stddev_n_Wrap(gdd_mon_avg, (/1, 2/))
  gdd_mon_area_avg = wgt_areaave_Wrap(gdd_mon, weights, 1.0, 0)
  gdd_mon_area_avg_std = dim_stddev_n_Wrap(gdd_mon_area_avg, 1)

  gdd_ann_area_avg = wgt_areaave_Wrap(gdd_ann, weights, 1.0, 0)
  gdd_ann_area_avg_std = stddev(gdd_ann_area_avg)
  gdd_ann_time_avg = dim_avg_n_Wrap(gdd_ann, 0)
  gdd_ann_time_std = stddev(gdd_ann_time_avg)

; calculate seasonal area and time averages
  gdd_DJF_avg = dim_avg_n_Wrap(gdd_DJF, 0)
  gdd_DJF_std = stddev(gdd_DJF_avg)
  gdd_DJF_area_avg = wgt_areaave_Wrap(gdd_DJF, weights, 1.0, 0)
  gdd_DJF_area_avg_std = stddev(gdd_DJF_area_avg)
  gdd_MAM_avg = dim_avg_n_Wrap(gdd_MAM, 0)
  gdd_MAM_std = stddev(gdd_MAM_avg)
  gdd_MAM_area_avg = wgt_areaave_Wrap(gdd_MAM, weights, 1.0, 0)
  gdd_MAM_area_avg_std = stddev(gdd_MAM_area_avg)
  gdd_JJA_avg = dim_avg_n_Wrap(gdd_JJA, 0)
  gdd_JJA_std = stddev(gdd_JJA_avg)
  gdd_JJA_area_avg = wgt_areaave_Wrap(gdd_JJA, weights, 1.0, 0)
  gdd_JJA_area_avg_std = stddev(gdd_JJA_area_avg)
  gdd_SON_avg = dim_avg_n_Wrap(gdd_SON, 0)
  gdd_SON_std = stddev(gdd_SON_avg)
  gdd_SON_area_avg = wgt_areaave_Wrap(gdd_SON, weights, 1.0, 0)
  gdd_SON_area_avg_std = stddev(gdd_SON_area_avg)

; calculate regression
  gdd_rc_mon = new(dimsizes(gdd_mon_area_avg(:,0)), double)
  gdd_rc_mon_data = new(dimsizes(gdd_mon_area_avg), double)
  gdd_yint_mon = new(dimsizes(gdd_mon_area_avg(:,0)), double)
  gdd_rc_mon_stats = new(dimsizes(gdd_mon_area_avg(:,0)), double)

  do nc = 0, 11
    gdd_rc_mon(nc) = regCoef(gdd_mon_area_avg&time, gdd_mon_area_avg(nc,:))
    gdd_yint_mon(nc) = gdd_rc_mon@yintercept
    gdd_rc_mon_data(nc,:) = gdd_rc_mon(nc)*gdd_mon_area_avg&time+gdd_yint_mon(nc)
    gdd_rc_mon_stats(nc) = regline_stats(gdd_mon_area_avg&time, gdd_mon_area_avg(nc,:))
  end do
  gdd_rc_mon = gdd_rc_mon*365
  gdd_rc_mon@units = gdd_mon_area_avg@units+"/year"

  gdd_rc_DJF = regCoef(gdd_DJF_area_avg&time, gdd_DJF_area_avg)
  gdd_rc_DJF_data = gdd_rc_DJF*gdd_DJF_area_avg&time+gdd_rc_DJF@yintercept
  gdd_rc_DJF = gdd_rc_DJF*365
  gdd_rc_DJF@units = gdd_DJF_area_avg@units+"/year"
  gdd_rc_DJF_stats = regline_stats(gdd_DJF_area_avg&time, gdd_DJF_area_avg)

  gdd_rc_MAM = regCoef(gdd_MAM_area_avg&time, gdd_MAM_area_avg)
  gdd_rc_MAM_data = gdd_rc_MAM*gdd_MAM_area_avg&time+gdd_rc_MAM@yintercept
  gdd_rc_MAM = gdd_rc_MAM*365
  gdd_rc_MAM@units = gdd_MAM_area_avg@units+"/year"
  gdd_rc_MAM_stats = regline_stats(gdd_MAM_area_avg&time, gdd_MAM_area_avg)

  gdd_rc_JJA = regCoef(gdd_JJA_area_avg&time, gdd_JJA_area_avg)
  gdd_rc_JJA_data = gdd_rc_JJA*gdd_JJA_area_avg&time+gdd_rc_JJA@yintercept
  gdd_rc_JJA = gdd_rc_JJA*365
  gdd_rc_JJA@units = gdd_JJA_area_avg@units+"/year"
  gdd_rc_JJA_stats = regline_stats(gdd_JJA_area_avg&time, gdd_JJA_area_avg)

  gdd_rc_SON = regCoef(gdd_SON_area_avg&time, gdd_SON_area_avg)
  gdd_rc_SON_data = gdd_rc_SON*gdd_SON_area_avg&time+gdd_rc_SON@yintercept
  gdd_rc_SON = gdd_rc_SON*365
  gdd_rc_SON@units = gdd_SON_area_avg@units+"/year"
  gdd_rc_SON_stats = regline_stats(gdd_SON_area_avg&time, gdd_SON_area_avg)

  gdd_rc_ANN = regCoef(gdd_ann_area_avg&time, gdd_ann_area_avg)
  gdd_rc_ANN_data = gdd_rc_ANN*gdd_ann_area_avg&time+gdd_rc_ANN@yintercept
  gdd_rc_ANN = gdd_rc_ANN*365
  gdd_rc_ANN@units = gdd_ann_area_avg@units+"/year"
  gdd_rc_ANN_stats = regline_stats(gdd_ann_area_avg&time, gdd_ann_area_avg)

  gdd_rc_MON = regCoef(gdd_area_avg&time, gdd_area_avg)
  gdd_rc_MON_data = gdd_rc_MON*gdd_area_avg&time+gdd_rc_MON@yintercept
  gdd_rc_MON = gdd_rc_MON*365
  gdd_rc_MON@units = gdd_area_avg@units+"/year"
  gdd_rc_MON_stats = regline_stats(gdd_area_avg&time, gdd_area_avg)

; plot
  rcm_name = "../plots_seasonal/"+run_name+"_"+var+"_annual_seasonal_trends"

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

; time series
  resxy                      = True
  resxy@gsnFrame             = False
  resxy@gsnDraw              = False
  resxy@gsnMaximize          = False
  resxy@xyMarkLineMode       = "Lines"
  resxy@xyMonoDashPattern    = True
  resxy@xyLineThicknessF     = 2.0
  resxy@gsnLeftStringFontHeightF = 0.025
  resxy@pmLegendDisplayMode    = "NoCreate"         ; Turn on the legend
  resxy@xyMonoLineColor       = True
  resxy@xyLineColor           = "DeepSkyBlue"

  delete(resxy@xyLineColor)
  resxy@xyMonoLineColor = True
  resxy@xyLineColor = (/"grey40"/)
  resxy@gsnLeftString = ""

  rline = True
  rline@gsLineColor       = "black" ;73
  rline@gsLineDashPattern = 0
  rline@gsLineThicknessF  = 4

  rline_obs = True
  rline_obs@gsLineColor       = "red" ;73
  rline_obs@gsLineDashPattern = 0
  rline_obs@gsLineThicknessF  = 4

  rline_gdd = True
  rline_gdd@gsLineColor       = "blue" ;73
  rline_gdd@gsLineDashPattern = 0
  rline_gdd@gsLineThicknessF  = 4

  resxy_obs = rline_obs
  resxy_obs@gsLineColor = "hotpink"
  resxy_obs@gsLineThicknessF  = 2

  resxy_gdd = rline_gdd
  resxy_gdd@gsLineColor = "lightblue"
  resxy_gdd@gsLineThicknessF  = 2

  wks0 = gsn_open_wks("pdf", rcm_name)
  plot0 = new(6, graphic)
  plot1 = new(dimsizes(plot0), graphic)
  plot2 = new(dimsizes(plot0), graphic)
  regl0 = new(dimsizes(plot0), graphic)
  regl_obs = new(dimsizes(plot0), graphic)
  regl_gdd = new(dimsizes(plot0), graphic)
  cmap_cmocean_balance = read_colormap_file("cmocean_balance")
  cmap_MPL_Reds = read_colormap_file("MPL_Reds")

  min_DJF = new(3, float)
  min_DJF(0) = tofloat(min(rcm_DJF_area_avg))
  min_DJF(1) = tofloat(min(obs_DJF_area_avg))
  min_DJF(2) = tofloat(min(gdd_DJF_area_avg))

  max_DJF = new(3, float)
  max_DJF(0) = tofloat(max(rcm_DJF_area_avg))
  max_DJF(1) = tofloat(max(obs_DJF_area_avg))
  max_DJF(2) = tofloat(max(gdd_DJF_area_avg))

  resxy@trYMinF = min(min_DJF)
  resxy@trYMaxF = max(max_DJF)
  resxy@tiYAxisString = var+" DJF"
  resxy@gsnLeftString = "RCM (black) SD="+sprintf("%5.4f", rcm_DJF_area_avg_std)+", RC="+sprintf("%5.4f", rcm_rc_DJF)+"~F34~1~F21~"+sprintf("%5.4f", rcm_rc_DJF_stats@b95(1)*365-rcm_rc_DJF)+"~C~"+ \
  "Obs (red) SD="+sprintf("%5.4f", obs_DJF_area_avg_std)+", RC="+sprintf("%5.4f", obs_rc_DJF)+"~F34~1~F21~"+sprintf("%5.4f", obs_rc_DJF_stats@b95(1)*365-obs_rc_DJF)+"~C~"+\
  "GDD (blue) SD="+sprintf("%5.4f", gdd_DJF_area_avg_std)+", RC="+sprintf("%5.4f", gdd_rc_DJF)+"~F34~1~F21~"+sprintf("%5.4f", gdd_rc_DJF_stats@b95(1)*365-gdd_rc_DJF)
  plot0(0) = gsn_csm_xy(wks0, xaxis_ann, rcm_DJF_area_avg, resxy)
  plot1(0) = gsn_add_polyline(wks0, plot0(0), xaxis_ann, obs_DJF_area_avg, resxy_obs)
  plot2(0) = gsn_add_polyline(wks0, plot0(0), xaxis_ann, gdd_DJF_area_avg, resxy_gdd)
  regl0(0) = gsn_add_polyline(wks0, plot0(0), xaxis_ann, rcm_rc_DJF_data, rline)
  regl_obs(0) = gsn_add_polyline(wks0, plot0(0), xaxis_ann, obs_rc_DJF_data, rline_obs)
  regl_gdd(0) = gsn_add_polyline(wks0, plot0(0), xaxis_ann, gdd_rc_DJF_data, rline_gdd)

  min_MAM = new(3, float)
  min_MAM(0) = tofloat(min(rcm_MAM_area_avg))
  min_MAM(1) = tofloat(min(obs_MAM_area_avg))
  min_MAM(2) = tofloat(min(gdd_MAM_area_avg))

  max_MAM = new(3, float)
  max_MAM(0) = tofloat(max(rcm_MAM_area_avg))
  max_MAM(1) = tofloat(max(obs_MAM_area_avg))
  max_MAM(2) = tofloat(max(gdd_MAM_area_avg))

  resxy@trYMinF = min(min_MAM)
  resxy@trYMaxF = max(max_MAM)
  resxy@tiYAxisString = var+" MAM"
  resxy@gsnLeftString = "RCM (black) SD="+sprintf("%5.4f", rcm_MAM_area_avg_std)+", RC="+sprintf("%5.4f", rcm_rc_MAM)+"~F34~1~F21~"+sprintf("%5.4f", rcm_rc_MAM_stats@b95(1)*365-rcm_rc_MAM)+"~C~"+ \
  "Obs (red) SD="+sprintf("%5.4f", obs_MAM_area_avg_std)+", RC="+sprintf("%5.4f", obs_rc_MAM)+"~F34~1~F21~"+sprintf("%5.4f", obs_rc_MAM_stats@b95(1)*365-obs_rc_MAM)+"~C~"+\
  "GDD (blue) SD="+sprintf("%5.4f", gdd_MAM_area_avg_std)+", RC="+sprintf("%5.4f", gdd_rc_MAM)+"~F34~1~F21~"+sprintf("%5.4f", gdd_rc_MAM_stats@b95(1)*365-gdd_rc_MAM)
  plot0(1) = gsn_csm_xy(wks0, xaxis_ann, rcm_MAM_area_avg, resxy)
  plot1(1) = gsn_add_polyline(wks0, plot0(1), xaxis_ann, obs_MAM_area_avg, resxy_obs)
  plot2(1) = gsn_add_polyline(wks0, plot0(1), xaxis_ann, gdd_MAM_area_avg, resxy_gdd)
  regl0(1) = gsn_add_polyline(wks0, plot0(1), xaxis_ann, rcm_rc_MAM_data, rline)
  regl_obs(1) = gsn_add_polyline(wks0, plot0(1), xaxis_ann, obs_rc_MAM_data, rline_obs)
  regl_gdd(1) = gsn_add_polyline(wks0, plot0(1), xaxis_ann, gdd_rc_MAM_data, rline_gdd)

  min_JJA = new(3, float)
  min_JJA(0) = tofloat(min(rcm_JJA_area_avg))
  min_JJA(1) = tofloat(min(obs_JJA_area_avg))
  min_JJA(2) = tofloat(min(gdd_JJA_area_avg))

  max_JJA = new(3, float)
  max_JJA(0) = tofloat(max(rcm_JJA_area_avg))
  max_JJA(1) = tofloat(max(obs_JJA_area_avg))
  max_JJA(2) = tofloat(max(gdd_JJA_area_avg))

  resxy@trYMinF = min(min_JJA)
  resxy@trYMaxF = max(max_JJA)
  resxy@tiYAxisString = var+" JJA"
  resxy@gsnLeftString = "RCM (black) SD="+sprintf("%5.4f", rcm_JJA_area_avg_std)+", RC="+sprintf("%5.4f", rcm_rc_JJA)+"~F34~1~F21~"+sprintf("%5.4f", rcm_rc_JJA_stats@b95(1)*365-rcm_rc_JJA)+"~C~"+ \
  "Obs (red) SD="+sprintf("%5.4f", obs_JJA_area_avg_std)+", RC="+sprintf("%5.4f", obs_rc_JJA)+"~F34~1~F21~"+sprintf("%5.4f", obs_rc_JJA_stats@b95(1)*365-obs_rc_JJA)+"~C~"+\
  "GDD (blue) SD="+sprintf("%5.4f", gdd_JJA_area_avg_std)+", RC="+sprintf("%5.4f", gdd_rc_JJA)+"~F34~1~F21~"+sprintf("%5.4f", gdd_rc_JJA_stats@b95(1)*365-gdd_rc_JJA)
  plot0(2) = gsn_csm_xy(wks0, xaxis_ann, rcm_JJA_area_avg, resxy)
  plot1(2) = gsn_add_polyline(wks0, plot0(2), xaxis_ann, obs_JJA_area_avg, resxy_obs)
  plot2(2) = gsn_add_polyline(wks0, plot0(2), xaxis_ann, gdd_JJA_area_avg, resxy_gdd)
  regl0(2) = gsn_add_polyline(wks0, plot0(2), xaxis_ann, rcm_rc_JJA_data, rline)
  regl_obs(2) = gsn_add_polyline(wks0, plot0(2), xaxis_ann, obs_rc_JJA_data, rline_obs)
  regl_gdd(2) = gsn_add_polyline(wks0, plot0(2), xaxis_ann, gdd_rc_JJA_data, rline_gdd)

  min_SON = new(3, float)
  min_SON(0) = tofloat(min(rcm_SON_area_avg))
  min_SON(1) = tofloat(min(obs_SON_area_avg))
  min_SON(2) = tofloat(min(gdd_SON_area_avg))

  max_SON = new(3, float)
  max_SON(0) = tofloat(max(rcm_SON_area_avg))
  max_SON(1) = tofloat(max(obs_SON_area_avg))
  max_SON(2) = tofloat(max(gdd_SON_area_avg))

  resxy@trYMinF = min(min_SON)
  resxy@trYMaxF = max(max_SON)
  resxy@tiYAxisString = var+" SON"
  resxy@gsnLeftString = "RCM (black) SD="+sprintf("%5.4f", rcm_SON_area_avg_std)+", RC="+sprintf("%5.4f", rcm_rc_SON)+"~F34~1~F21~"+sprintf("%5.4f", rcm_rc_SON_stats@b95(1)*365-rcm_rc_SON)+"~C~"+ \
  "Obs (red) SD="+sprintf("%5.4f", obs_SON_area_avg_std)+", RC="+sprintf("%5.4f", obs_rc_SON)+"~F34~1~F21~"+sprintf("%5.4f", obs_rc_SON_stats@b95(1)*365-obs_rc_SON)+"~C~"+\
  "GDD (blue) SD="+sprintf("%5.4f", gdd_SON_area_avg_std)+", RC="+sprintf("%5.4f", gdd_rc_SON)+"~F34~1~F21~"+sprintf("%5.4f", gdd_rc_SON_stats@b95(1)*365-gdd_rc_SON)
  plot0(3) = gsn_csm_xy(wks0, xaxis_ann, rcm_SON_area_avg, resxy)
  plot1(3) = gsn_add_polyline(wks0, plot0(3), xaxis_ann, obs_SON_area_avg, resxy_obs)
  plot2(3) = gsn_add_polyline(wks0, plot0(3), xaxis_ann, gdd_SON_area_avg, resxy_gdd)
  regl0(3) = gsn_add_polyline(wks0, plot0(3), xaxis_ann, rcm_rc_SON_data, rline)
  regl_obs(3) = gsn_add_polyline(wks0, plot0(3), xaxis_ann, obs_rc_SON_data, rline_obs)
  regl_gdd(3) = gsn_add_polyline(wks0, plot0(3), xaxis_ann, gdd_rc_SON_data, rline_gdd)

  min_MON = new(3, float)
  min_MON(0) = tofloat(min(rcm_area_avg))
  min_MON(1) = tofloat(min(obs_area_avg))
  min_MON(2) = tofloat(min(gdd_area_avg))

  max_MON = new(3, float)
  max_MON(0) = tofloat(max(rcm_area_avg))
  max_MON(1) = tofloat(max(obs_area_avg))
  max_MON(2) = tofloat(max(gdd_area_avg))

  resxy@trYMinF = min(min_MON)
  resxy@trYMaxF = max(max_MON)
  resxy@tiYAxisString = var+" MON"
  resxy@gsnLeftString = "RCM SD="+sprintf("%5.4f", rcm_area_avg_std)+", RC="+sprintf("%5.4f", rcm_rc_MON)+"~F34~1~F21~"+sprintf("%5.4f", rcm_rc_MON_stats@b95(1)*365-rcm_rc_MON)+"~C~"+ \
  "Obs SD="+sprintf("%5.4f", obs_area_avg_std)+", RC="+sprintf("%5.4f", obs_rc_MON)+"~F34~1~F21~"+sprintf("%5.4f", obs_rc_MON_stats@b95(1)*365-obs_rc_MON)+"~C~"+\
  "GDD SD="+sprintf("%5.4f", gdd_area_avg_std)+", RC="+sprintf("%5.4f", gdd_rc_MON)+"~F34~1~F21~"+sprintf("%5.4f", gdd_rc_MON_stats@b95(1)*365-gdd_rc_MON)
  plot0(4) = gsn_csm_xy(wks0, xaxis, rcm_area_avg, resxy)
  plot1(4) = gsn_add_polyline(wks0, plot0(4), xaxis, obs_area_avg, resxy_obs)
  plot2(4) = gsn_add_polyline(wks0, plot0(4), xaxis, gdd_area_avg, resxy_gdd)
  regl0(4) = gsn_add_polyline(wks0, plot0(4), xaxis, rcm_rc_MON_data, rline)
  regl_obs(4) = gsn_add_polyline(wks0, plot0(4), xaxis, obs_rc_MON_data, rline_obs)
  regl_gdd(4) = gsn_add_polyline(wks0, plot0(4), xaxis, gdd_rc_MON_data, rline_gdd)

  min_ANN = new(3, float)
  min_ANN(0) = tofloat(min(rcm_ann_area_avg))
  min_ANN(1) = tofloat(min(obs_ann_area_avg))
  min_ANN(2) = tofloat(min(gdd_ann_area_avg))

  max_ANN = new(3, float)
  max_ANN(0) = tofloat(max(rcm_ann_area_avg))
  max_ANN(1) = tofloat(max(obs_ann_area_avg))
  max_ANN(2) = tofloat(max(gdd_ann_area_avg))

  resxy@trYMinF = min(min_ANN)
  resxy@trYMaxF = max(max_ANN)
  resxy@tiYAxisString = var+" ANN"
  resxy@gsnLeftString = "RCM SD="+sprintf("%5.4f", rcm_ann_area_avg_std)+", RC="+sprintf("%5.4f", rcm_rc_ANN)+"~F34~1~F21~"+sprintf("%5.4f", rcm_rc_ANN_stats@b95(1)*365-rcm_rc_ANN)+"~C~"+ \
  "Obs SD="+sprintf("%5.4f", obs_ann_area_avg_std)+", RC="+sprintf("%5.4f", obs_rc_ANN)+"~F34~1~F21~"+sprintf("%5.4f", obs_rc_ANN_stats@b95(1)*365-obs_rc_ANN)+"~C~"+\
  "GDD SD="+sprintf("%5.4f", gdd_ann_area_avg_std)+", RC="+sprintf("%5.4f", gdd_rc_ANN)+"~F34~1~F21~"+sprintf("%5.4f", gdd_rc_ANN_stats@b95(1)*365-gdd_rc_ANN)
  plot0(5) = gsn_csm_xy(wks0, xaxis_ann, rcm_ann_area_avg, resxy)
  plot1(5) = gsn_add_polyline(wks0, plot0(5), xaxis_ann, obs_ann_area_avg, resxy_obs)
  plot2(5) = gsn_add_polyline(wks0, plot0(5), xaxis_ann, gdd_ann_area_avg, resxy_gdd)
  regl0(5) = gsn_add_polyline(wks0, plot0(5), xaxis_ann, rcm_rc_ANN_data, rline)
  regl_obs(5) = gsn_add_polyline(wks0, plot0(5), xaxis_ann, obs_rc_ANN_data, rline_obs)
  regl_gdd(5) = gsn_add_polyline(wks0, plot0(5), xaxis_ann, gdd_rc_ANN_data, rline_gdd)
  
  units = rcm_mon_area_avg@units
; Panel plots
  resP                    = True
  resP@gsnPanelLabelBar = False
  resP@gsnMaximize = True
  resP@gsnPanelLabelBar = False
  resP@gsnPanelMainString = run_name+" "+var+" Aus area avg. "+yrStrt+"-"+yrLast+"~C~"+info+" ("+units+")"
  gsn_panel(wks0, plot0, (/3, 2/), resP)
end