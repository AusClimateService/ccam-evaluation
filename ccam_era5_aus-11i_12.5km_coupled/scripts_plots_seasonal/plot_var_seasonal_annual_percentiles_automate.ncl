; plot seasonal bias and rmse

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/g/data/xv83/bxn599/CaRSA/rav_ncl/percentiles.ncl"

begin
  rad = 4.0*atan(1.0)/180.0
  re  = 6371220.0
  rr  = re*rad

  f = addfile("../calculated/"+run_name+"_"+var+"_bias_rmse_monthly_means_awap_grid.nc", "r")

  obs_ = f->obs_var_month
  obs = tofloat(obs_)
  copy_VarMeta(obs_, obs)
  delete(obs_)
  rcm_ = f->rcm_var_month
  rcm = tofloat(rcm_)
  copy_VarMeta(rcm_, rcm)
  delete(rcm_)
  gdd_ = f->gdd_var_month
  gdd = tofloat(gdd_)
  copy_VarMeta(gdd_, gdd)
  delete(gdd_)

  new_time = cd_convert(obs&time, "days since 0001-01-01 00:00:00")

  delete(obs&time)
  delete(gdd&time)
  delete(rcm&time)
  obs&time = new_time
  rcm&time = new_time
  gdd&time = new_time
  
; calculate seasonal/annual
  obs_DJF = month_to_season(obs, "DJF")
  obs_DJF_99p = percent_to_value_2d(obs_DJF, 99)
  obs_DJF_01p = percent_to_value_2d(obs_DJF, 1)
  rcm_DJF = month_to_season(rcm, "DJF")
  rcm_DJF_99p = percent_to_value_2d(rcm_DJF, 99)
  rcm_DJF_01p = percent_to_value_2d(rcm_DJF, 1)
  gdd_DJF = month_to_season(gdd, "DJF")
  gdd_DJF_99p = percent_to_value_2d(gdd_DJF, 99)
  gdd_DJF_01p = percent_to_value_2d(gdd_DJF, 1)

  obs_MAM = month_to_season(obs, "MAM")
  obs_MAM_99p = percent_to_value_2d(obs_MAM, 99)
  obs_MAM_01p = percent_to_value_2d(obs_MAM, 1)
  rcm_MAM = month_to_season(rcm, "MAM")
  rcm_MAM_99p = percent_to_value_2d(rcm_MAM, 99)
  rcm_MAM_01p = percent_to_value_2d(rcm_MAM, 1)
  gdd_MAM = month_to_season(gdd, "MAM")
  gdd_MAM_99p = percent_to_value_2d(gdd_MAM, 99)
  gdd_MAM_01p = percent_to_value_2d(gdd_MAM, 1)

  obs_JJA = month_to_season(obs, "JJA")
  obs_JJA_99p = percent_to_value_2d(obs_JJA, 99)
  obs_JJA_01p = percent_to_value_2d(obs_JJA, 1)
  rcm_JJA = month_to_season(rcm, "JJA")
  rcm_JJA_99p = percent_to_value_2d(rcm_JJA, 99)
  rcm_JJA_01p = percent_to_value_2d(rcm_JJA, 1)
  gdd_JJA = month_to_season(gdd, "JJA")
  gdd_JJA_99p = percent_to_value_2d(gdd_JJA, 99)
  gdd_JJA_01p = percent_to_value_2d(gdd_JJA, 1)

  obs_SON = month_to_season(obs, "SON")
  obs_SON_99p = percent_to_value_2d(obs_SON, 99)
  obs_SON_01p = percent_to_value_2d(obs_SON, 1)
  rcm_SON = month_to_season(rcm, "SON")
  rcm_SON_99p = percent_to_value_2d(rcm_SON, 99)
  rcm_SON_01p = percent_to_value_2d(rcm_SON, 1)
  gdd_SON = month_to_season(gdd, "SON")
  gdd_SON_99p = percent_to_value_2d(gdd_SON, 99)
  gdd_SON_01p = percent_to_value_2d(gdd_SON, 1)

  obs_ann = month_to_annual(obs, 1)
  obs_ann_99p = percent_to_value_2d(obs_ann, 99)
  obs_ann_01p = percent_to_value_2d(obs_ann, 1)
  rcm_ann = month_to_annual(rcm, 1)
  rcm_ann_99p = percent_to_value_2d(rcm_ann, 99)
  rcm_ann_01p = percent_to_value_2d(rcm_ann, 1)
  gdd_ann = month_to_annual(gdd, 1)
  gdd_ann_99p = percent_to_value_2d(gdd_ann, 99)
  gdd_ann_01p = percent_to_value_2d(gdd_ann, 1)

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

; calculate 99th percentile difference (RCM minus Obs/RCM minus GDD)
  rcm_obs_DJF_99p = rcm_DJF_99p
  rcm_obs_DJF_99p = rcm_DJF_99p - obs_DJF_99p
  rcm_obs_MAM_99p = rcm_MAM_99p
  rcm_obs_MAM_99p = rcm_MAM_99p - obs_MAM_99p
  rcm_obs_JJA_99p = rcm_JJA_99p
  rcm_obs_JJA_99p = rcm_JJA_99p - obs_JJA_99p
  rcm_obs_SON_99p = rcm_SON_99p
  rcm_obs_SON_99p = rcm_SON_99p - obs_SON_99p
  rcm_obs_ann_99p = rcm_ann_99p
  rcm_obs_ann_99p = rcm_ann_99p - obs_ann_99p

  rcm_gdd_DJF_99p = rcm_DJF_99p
  rcm_gdd_DJF_99p = rcm_DJF_99p - gdd_DJF_99p
  rcm_gdd_MAM_99p = rcm_MAM_99p
  rcm_gdd_MAM_99p = rcm_MAM_99p - gdd_MAM_99p
  rcm_gdd_JJA_99p = rcm_JJA_99p
  rcm_gdd_JJA_99p = rcm_JJA_99p - gdd_JJA_99p
  rcm_gdd_SON_99p = rcm_SON_99p
  rcm_gdd_SON_99p = rcm_SON_99p - gdd_SON_99p
  rcm_gdd_ann_99p = rcm_ann_99p
  rcm_gdd_ann_99p = rcm_ann_99p - gdd_ann_99p

  gdd_obs_DJF_99p = gdd_DJF_99p
  gdd_obs_DJF_99p = gdd_DJF_99p - obs_DJF_99p
  gdd_obs_MAM_99p = gdd_MAM_99p
  gdd_obs_MAM_99p = gdd_MAM_99p - obs_MAM_99p
  gdd_obs_JJA_99p = gdd_JJA_99p
  gdd_obs_JJA_99p = gdd_JJA_99p - obs_JJA_99p
  gdd_obs_SON_99p = gdd_SON_99p
  gdd_obs_SON_99p = gdd_SON_99p - obs_SON_99p
  gdd_obs_ann_99p = gdd_ann_99p
  gdd_obs_ann_99p = gdd_ann_99p - obs_ann_99p

; calculate 01th percentile difference (RCM minus Obs/RCM minus GDD)
  rcm_obs_DJF_01p = rcm_DJF_01p
  rcm_obs_DJF_01p = rcm_DJF_01p - obs_DJF_01p
  rcm_obs_MAM_01p = rcm_MAM_01p
  rcm_obs_MAM_01p = rcm_MAM_01p - obs_MAM_01p
  rcm_obs_JJA_01p = rcm_JJA_01p
  rcm_obs_JJA_01p = rcm_JJA_01p - obs_JJA_01p
  rcm_obs_SON_01p = rcm_SON_01p
  rcm_obs_SON_01p = rcm_SON_01p - obs_SON_01p
  rcm_obs_ann_01p = rcm_ann_01p
  rcm_obs_ann_01p = rcm_ann_01p - obs_ann_01p

  rcm_gdd_DJF_01p = rcm_DJF_01p
  rcm_gdd_DJF_01p = rcm_DJF_01p - gdd_DJF_01p
  rcm_gdd_MAM_01p = rcm_MAM_01p
  rcm_gdd_MAM_01p = rcm_MAM_01p - gdd_MAM_01p
  rcm_gdd_JJA_01p = rcm_JJA_01p
  rcm_gdd_JJA_01p = rcm_JJA_01p - gdd_JJA_01p
  rcm_gdd_SON_01p = rcm_SON_01p
  rcm_gdd_SON_01p = rcm_SON_01p - gdd_SON_01p
  rcm_gdd_ann_01p = rcm_ann_01p
  rcm_gdd_ann_01p = rcm_ann_01p - gdd_ann_01p

  gdd_obs_DJF_01p = gdd_DJF_01p
  gdd_obs_DJF_01p = gdd_DJF_01p - obs_DJF_01p
  gdd_obs_MAM_01p = gdd_MAM_01p
  gdd_obs_MAM_01p = gdd_MAM_01p - obs_MAM_01p
  gdd_obs_JJA_01p = gdd_JJA_01p
  gdd_obs_JJA_01p = gdd_JJA_01p - obs_JJA_01p
  gdd_obs_SON_01p = gdd_SON_01p
  gdd_obs_SON_01p = gdd_SON_01p - obs_SON_01p
  gdd_obs_ann_01p = gdd_ann_01p
  gdd_obs_ann_01p = gdd_ann_01p - obs_ann_01p

; plot
  plot_name = "../plots_seasonal/"+run_name+"_rcm_obs_gdd_"+var+"_seasonal_annual_percentiles"

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
;  res@cnFillMode = "CellFill" ; for faster plotting

  wks0 = gsn_open_wks("pdf", plot_name)
  plot0 = new(30, graphic)
  plot1 = new(30, graphic)
  cmap_cmocean_balance = read_colormap_file("cmocean_balance") ; blue to red
  cmap_cmocean_ice = read_colormap_file("cmocean_ice") ; black to blue to white
  cmap_cmocean_amp = read_colormap_file("cmocean_amp") ; white to red to black
  ;cmap_cmocean_thermal = read_colormap_file("cmocean_thermal") ; purple to red to yellow
  ;cmap_cmocean_dense = read_colormap_file("cmocean_dense") ; white to purple

if var.eq."pr" then
  res@cnFillPalette = cmap_cmocean_ice(::-1,:) ; reverse the colourmap to white to blue
else
  res@cnFillPalette = cmap_cmocean_amp
end if

; area weights
  lat = rcm_obs_ann_99p&lat
  lon = rcm_obs_ann_99p&lon
  nlat = dimsizes(lat)

  dlon   = abs(lon(2)-lon(1))*rr
  dx     = dlon*cos(lat*rad)
  dy     = new (nlat, typeof(dx))
  dy(0)  = abs(lat(2)-lat(1))*rr
  dy(1:nlat-2)  = abs(lat(2:nlat-1)-lat(0:nlat-3))*rr*0.5   
  dy(nlat-1)    = abs(lat(nlat-1)-lat(nlat-2))*rr

  data_wgt = dx*dy

  print("appending season arrays")

  DJF0 = array_append_record(gdd_DJF_99p, rcm_DJF_99p, 0)
  DJF = array_append_record(DJF0, obs_DJF_99p, 0)

  stats_DJF = stat_dispersion(DJF, False)
  dmin_DJF = stats_DJF(3)
  dmax_DJF = stats_DJF(13)
  mmin_DJF = stats_DJF(2)
  mmax_DJF = stats_DJF(14)

  MAM0 = array_append_record(gdd_MAM_99p, rcm_MAM_99p, 0)
  MAM = array_append_record(MAM0, obs_MAM_99p, 0)

  stats_MAM = stat_dispersion(MAM, False)
  dmin_MAM = stats_MAM(3)
  dmax_MAM = stats_MAM(13)
  mmin_MAM = stats_MAM(2)
  mmax_MAM = stats_MAM(14)

  JJA0 = array_append_record(gdd_JJA_99p, rcm_JJA_99p, 0)
  JJA = array_append_record(JJA0, obs_JJA_99p, 0)

  stats_JJA = stat_dispersion(JJA, False)
  dmin_JJA = stats_JJA(3)
  dmax_JJA = stats_JJA(13)
  mmin_JJA = stats_JJA(2)
  mmax_JJA = stats_JJA(14)

  SON0 = array_append_record(gdd_SON_99p, rcm_SON_99p, 0)
  SON = array_append_record(SON0, obs_SON_99p, 0)

  stats_SON = stat_dispersion(SON, False)
  dmin_SON = stats_SON(3)
  dmax_SON = stats_SON(13)
  mmin_SON = stats_SON(2)
  mmax_SON = stats_SON(14)

  ann0 = array_append_record(gdd_ann_99p, rcm_ann_99p, 0)
  ann = array_append_record(ann0, obs_ann_99p, 0)

  stats_ann = stat_dispersion(ann, False)
  dmin_ann = stats_ann(3)
  dmax_ann = stats_ann(13)
  mmin_ann = stats_ann(2)
  mmax_ann = stats_ann(14)

  ; calculate which is larger and use the same scale for all seasons
if var.eq."pr" then
  mnmxint_DJF = nice_mnmxintvl(dmin_DJF, dmax_DJF, 18, False)
  mnmxint_MAM = nice_mnmxintvl(dmin_MAM, dmax_MAM, 18, False)
  mnmxint_JJA = nice_mnmxintvl(dmin_JJA, dmax_JJA, 18, False)
  mnmxint_SON = nice_mnmxintvl(dmin_SON, dmax_SON, 18, False)
  mnmxint_ann = nice_mnmxintvl(dmin_ann, dmax_ann, 18, False)
else
  mnmxint_DJF = nice_mnmxintvl(mmin_DJF, mmax_DJF, 18, False)
  mnmxint_MAM = nice_mnmxintvl(mmin_MAM, mmax_MAM, 18, False)
  mnmxint_JJA = nice_mnmxintvl(mmin_JJA, mmax_JJA, 18, False)
  mnmxint_SON = nice_mnmxintvl(mmin_SON, mmax_SON, 18, False)
  mnmxint_ann = nice_mnmxintvl(mmin_ann, mmax_ann, 18, False)
end if
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
  res@cnMinLevelValF = mnmxint_DJF(0)
  res@cnMaxLevelValF = mnmxint_DJF(1)
  res@cnLevelSpacingF = mnmxint_DJF(2)

; OBS
  aavg = wgt_areaave_Wrap(obs_DJF_99p, data_wgt, 1.0, 0)
  sd = stddev(obs_DJF_99p)
  tp = num(.not.ismissing(obs_DJF_99p))
  pp = num(where(obs_DJF_99p.gt.0, 1, 0))
  np = num(where(obs_DJF_99p.lt.0, 1, 0))
  res@gsnLeftString = "OBS DJF, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(0) = gsn_csm_contour_map_ce(wks0, obs_DJF_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_MAM(0)
  res@cnMaxLevelValF = mnmxint_MAM(1)
  res@cnLevelSpacingF = mnmxint_MAM(2)
  aavg = wgt_areaave_Wrap(obs_MAM_99p, data_wgt, 1.0, 0)
  sd = stddev(obs_MAM_99p)
  tp = num(.not.ismissing(obs_MAM_99p))
  pp = num(where(obs_MAM_99p.gt.0, 1, 0))
  np = num(where(obs_MAM_99p.lt.0, 1, 0))
  res@gsnLeftString = "OBS MAM, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(1) = gsn_csm_contour_map_ce(wks0, obs_MAM_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_JJA(0)
  res@cnMaxLevelValF = mnmxint_JJA(1)
  res@cnLevelSpacingF = mnmxint_JJA(2)
  aavg = wgt_areaave_Wrap(obs_JJA_99p, data_wgt, 1.0, 0)
  sd = stddev(obs_JJA_99p)
  tp = num(.not.ismissing(obs_JJA_99p))
  pp = num(where(obs_JJA_99p.gt.0, 1, 0))
  np = num(where(obs_JJA_99p.lt.0, 1, 0))
  res@gsnLeftString = "OBS JJA, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(2) = gsn_csm_contour_map_ce(wks0, obs_JJA_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_SON(0)
  res@cnMaxLevelValF = mnmxint_SON(1)
  res@cnLevelSpacingF = mnmxint_SON(2)
  aavg = wgt_areaave_Wrap(obs_SON_99p, data_wgt, 1.0, 0)
  sd = stddev(obs_SON_99p)
  tp = num(.not.ismissing(obs_SON_99p))
  pp = num(where(obs_SON_99p.gt.0, 1, 0))
  np = num(where(obs_SON_99p.lt.0, 1, 0))
  res@gsnLeftString = "OBS SON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(3) = gsn_csm_contour_map_ce(wks0, obs_SON_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_ann(0)
  res@cnMaxLevelValF = mnmxint_ann(1)
  res@cnLevelSpacingF = mnmxint_ann(2)
  aavg = wgt_areaave_Wrap(obs_ann_99p, data_wgt, 1.0, 0)
  sd = stddev(obs_ann_99p)
  tp = num(.not.ismissing(obs_ann_99p))
  pp = num(where(obs_ann_99p.gt.0, 1, 0))
  np = num(where(obs_ann_99p.lt.0, 1, 0))
  res@gsnLeftString = "OBS ANN, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(4) = gsn_csm_contour_map_ce(wks0, obs_ann_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

; GDD
  res@cnMinLevelValF = mnmxint_DJF(0)
  res@cnMaxLevelValF = mnmxint_DJF(1)
  res@cnLevelSpacingF = mnmxint_DJF(2)
  aavg = wgt_areaave_Wrap(gdd_DJF_99p, data_wgt, 1.0, 0)
  sd = stddev(gdd_DJF_99p)
  tp = num(.not.ismissing(gdd_DJF_99p))
  pp = num(where(gdd_DJF_99p.gt.0, 1, 0))
  np = num(where(gdd_DJF_99p.lt.0, 1, 0))
  res@gsnLeftString = "GDD DJF, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(5) = gsn_csm_contour_map_ce(wks0, gdd_DJF_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_MAM(0)
  res@cnMaxLevelValF = mnmxint_MAM(1)
  res@cnLevelSpacingF = mnmxint_MAM(2)
  aavg = wgt_areaave_Wrap(gdd_MAM_99p, data_wgt, 1.0, 0)
  sd = stddev(gdd_MAM_99p)
  tp = num(.not.ismissing(gdd_MAM_99p))
  pp = num(where(gdd_MAM_99p.gt.0, 1, 0))
  np = num(where(gdd_MAM_99p.lt.0, 1, 0))
  res@gsnLeftString = "GDD MAM, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(6) = gsn_csm_contour_map_ce(wks0, gdd_MAM_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_JJA(0)
  res@cnMaxLevelValF = mnmxint_JJA(1)
  res@cnLevelSpacingF = mnmxint_JJA(2)
  aavg = wgt_areaave_Wrap(gdd_JJA_99p, data_wgt, 1.0, 0)
  sd = stddev(gdd_JJA_99p)
  tp = num(.not.ismissing(gdd_JJA_99p))
  pp = num(where(gdd_JJA_99p.gt.0, 1, 0))
  np = num(where(gdd_JJA_99p.lt.0, 1, 0))
  res@gsnLeftString = "GDD JJA, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(7) = gsn_csm_contour_map_ce(wks0, gdd_JJA_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_SON(0)
  res@cnMaxLevelValF = mnmxint_SON(1)
  res@cnLevelSpacingF = mnmxint_SON(2)
  aavg = wgt_areaave_Wrap(gdd_SON_99p, data_wgt, 1.0, 0)
  sd = stddev(gdd_SON_99p)
  tp = num(.not.ismissing(gdd_SON_99p))
  pp = num(where(gdd_SON_99p.gt.0, 1, 0))
  np = num(where(gdd_SON_99p.lt.0, 1, 0))
  res@gsnLeftString = "GDD SON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(8) = gsn_csm_contour_map_ce(wks0, gdd_SON_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_ann(0)
  res@cnMaxLevelValF = mnmxint_ann(1)
  res@cnLevelSpacingF = mnmxint_ann(2)
  aavg = wgt_areaave_Wrap(gdd_ann_99p, data_wgt, 1.0, 0)
  sd = stddev(gdd_ann_99p)
  tp = num(.not.ismissing(gdd_ann_99p))
  pp = num(where(gdd_ann_99p.gt.0, 1, 0))
  np = num(where(gdd_ann_99p.lt.0, 1, 0))
  res@gsnLeftString = "GDD ANN, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(9) = gsn_csm_contour_map_ce(wks0, gdd_ann_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])
  
; RCM
  res@cnMinLevelValF = mnmxint_DJF(0)
  res@cnMaxLevelValF = mnmxint_DJF(1)
  res@cnLevelSpacingF = mnmxint_DJF(2)
  aavg = wgt_areaave_Wrap(rcm_DJF_99p, data_wgt, 1.0, 0)
  sd = stddev(rcm_DJF_99p)
  tp = num(.not.ismissing(rcm_DJF_99p))
  pp = num(where(rcm_DJF_99p.gt.0, 1, 0))
  np = num(where(rcm_DJF_99p.lt.0, 1, 0))
  res@gsnLeftString = "RCM DJF, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(10) = gsn_csm_contour_map_ce(wks0, rcm_DJF_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_MAM(0)
  res@cnMaxLevelValF = mnmxint_MAM(1)
  res@cnLevelSpacingF = mnmxint_MAM(2)
  aavg = wgt_areaave_Wrap(rcm_MAM_99p, data_wgt, 1.0, 0)
  sd = stddev(rcm_MAM_99p)
  tp = num(.not.ismissing(rcm_MAM_99p))
  pp = num(where(rcm_MAM_99p.gt.0, 1, 0))
  np = num(where(rcm_MAM_99p.lt.0, 1, 0))
  res@gsnLeftString = "RCM MAM, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(11) = gsn_csm_contour_map_ce(wks0, rcm_MAM_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_JJA(0)
  res@cnMaxLevelValF = mnmxint_JJA(1)
  res@cnLevelSpacingF = mnmxint_JJA(2)
  aavg = wgt_areaave_Wrap(rcm_JJA_99p, data_wgt, 1.0, 0)
  sd = stddev(rcm_JJA_99p)
  tp = num(.not.ismissing(rcm_JJA_99p))
  pp = num(where(rcm_JJA_99p.gt.0, 1, 0))
  np = num(where(rcm_JJA_99p.lt.0, 1, 0))
  res@gsnLeftString = "RCM JJA, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(12) = gsn_csm_contour_map_ce(wks0, rcm_JJA_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_SON(0)
  res@cnMaxLevelValF = mnmxint_SON(1)
  res@cnLevelSpacingF = mnmxint_SON(2)
  aavg = wgt_areaave_Wrap(rcm_SON_99p, data_wgt, 1.0, 0)
  sd = stddev(rcm_SON_99p)
  tp = num(.not.ismissing(rcm_SON_99p))
  pp = num(where(rcm_SON_99p.gt.0, 1, 0))
  np = num(where(rcm_SON_99p.lt.0, 1, 0))
  res@gsnLeftString = "RCM SON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(13) = gsn_csm_contour_map_ce(wks0, rcm_SON_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_ann(0)
  res@cnMaxLevelValF = mnmxint_ann(1)
  res@cnLevelSpacingF = mnmxint_ann(2)
  aavg = wgt_areaave_Wrap(rcm_ann_99p, data_wgt, 1.0, 0)
  sd = stddev(rcm_ann_99p)
  tp = num(.not.ismissing(rcm_ann_99p))
  pp = num(where(rcm_ann_99p.gt.0, 1, 0))
  np = num(where(rcm_ann_99p.lt.0, 1, 0))
  res@gsnLeftString = "RCM ANN, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(14) = gsn_csm_contour_map_ce(wks0, rcm_ann_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])
  delete([/res@cnMinLevelValF, res@cnMaxLevelValF, res@cnLevelSpacingF/])
  delete([/stats_DJF, dmin_DJF, dmax_DJF, mmin_DJF, mmax_DJF, mnmxint_DJF/])
  delete([/stats_MAM, dmin_MAM, dmax_MAM, mmin_MAM, mmax_MAM, mnmxint_MAM/])
  delete([/stats_JJA, dmin_JJA, dmax_JJA, mmin_JJA, mmax_JJA, mnmxint_JJA/])
  delete([/stats_SON, dmin_SON, dmax_SON, mmin_SON, mmax_SON, mnmxint_SON/])
  delete([/stats_ann, dmin_ann, dmax_ann, mmin_ann, mmax_ann, mnmxint_ann/])

;  seasonal0 = array_append_record(rcm_gdd_DJF_99p, rcm_gdd_MAM_99p, 0)
;  seasonal1 = array_append_record(seasonal0, rcm_gdd_JJA_99p, 0)
;  seasonal2 = array_append_record(seasonal1, rcm_gdd_SON_99p, 0)
;  seasonal3 = array_append_record(seasonal2, rcm_gdd_ann_99p, 0)
;  seasonal4 = array_append_record(seasonal3, rcm_obs_DJF_99p, 0)
;  seasonal5 = array_append_record(seasonal4, rcm_obs_MAM_99p, 0)
;  seasonal6 = array_append_record(seasonal5, rcm_obs_JJA_99p, 0)
;  seasonal7 = array_append_record(seasonal6, rcm_obs_SON_99p, 0)
;  seasonal8 = array_append_record(seasonal7, rcm_obs_ann_99p, 0)
;  seasonal9 = array_append_record(seasonal8, gdd_obs_DJF_99p, 0)
;  seasonal10 = array_append_record(seasonal9, gdd_obs_MAM_99p, 0)
;  seasonal11 = array_append_record(seasonal10, gdd_obs_JJA_99p, 0)
;  seasonal12 = array_append_record(seasonal11, gdd_obs_SON_99p, 0)
;  seasonal = array_append_record(seasonal12, gdd_obs_ann_99p, 0)
;
;  stats = stat_dispersion(seasonal, False)
;  dmin = stats(3)
;  dmax = stats(13)
;  mmin = stats(2)
;  mmax = stats(14)
;  ; calculate which is larger
;  mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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

; append seasonal difference arrays
  DJF0 = array_append_record(rcm_gdd_DJF_99p, rcm_obs_DJF_99p, 0)
  DJF = array_append_record(DJF0, gdd_obs_DJF_99p, 0)

  stats_DJF = stat_dispersion(DJF, False)
  dmin_DJF = stats_DJF(3)
  dmax_DJF = stats_DJF(13)
  mmin_DJF = stats_DJF(2)
  mmax_DJF = stats_DJF(14)

  MAM0 = array_append_record(rcm_gdd_MAM_99p, rcm_obs_MAM_99p, 0)
  MAM = array_append_record(MAM0, gdd_obs_MAM_99p, 0)

  stats_MAM = stat_dispersion(MAM, False)
  dmin_MAM = stats_MAM(3)
  dmax_MAM = stats_MAM(13)
  mmin_MAM = stats_MAM(2)
  mmax_MAM = stats_MAM(14)

  JJA0 = array_append_record(rcm_gdd_JJA_99p, rcm_obs_JJA_99p, 0)
  JJA = array_append_record(JJA0, gdd_obs_JJA_99p, 0)

  stats_JJA = stat_dispersion(JJA, False)
  dmin_JJA = stats_JJA(3)
  dmax_JJA = stats_JJA(13)
  mmin_JJA = stats_JJA(2)
  mmax_JJA = stats_JJA(14)

  SON0 = array_append_record(rcm_gdd_SON_99p, rcm_obs_SON_99p, 0)
  SON = array_append_record(SON0, gdd_obs_SON_99p, 0)

  stats_SON = stat_dispersion(SON, False)
  dmin_SON = stats_SON(3)
  dmax_SON = stats_SON(13)
  mmin_SON = stats_SON(2)
  mmax_SON = stats_SON(14)

  ann0 = array_append_record(rcm_gdd_ann_99p, rcm_obs_ann_99p, 0)
  ann = array_append_record(ann0, gdd_obs_ann_99p, 0)

  stats_ann = stat_dispersion(ann, False)
  dmin_ann = stats_ann(3)
  dmax_ann = stats_ann(13)
  mmin_ann = stats_ann(2)
  mmax_ann = stats_ann(14)

  ; calculate which is larger and use the same scale for all seasons
;  mnmxint_DJF = nice_mnmxintvl(dmin_DJF, dmax_DJF, 18, False)
;  mnmxint_MAM = nice_mnmxintvl(dmin_MAM, dmax_MAM, 18, False)
;  mnmxint_JJA = nice_mnmxintvl(dmin_JJA, dmax_JJA, 18, False)
;  mnmxint_SON = nice_mnmxintvl(dmin_SON, dmax_SON, 18, False)
;  mnmxint_ann = nice_mnmxintvl(dmin_ann, dmax_ann, 18, False)

;  if dmin_DJF .eq. dmax_DJF then
;    if abs(mmin_DJF) .gt. abs(mmax_DJF) then
;      mnmxint_DJF = nice_mnmxintvl(mmin_DJF, abs(mmin_DJF), 18, False)
;    else if abs(mmax_DJF) .gt. abs(mmin_DJF) then
;      mnmxint_DJF = nice_mnmxintvl(abs(mmax_DJF)*(-1), abs(mmax_DJF), 18, False)
;    end if
;    end if
;  else
    if abs(dmin_DJF) .gt. abs(dmax_DJF) then
      mnmxint_DJF = nice_mnmxintvl(dmin_DJF, abs(dmin_DJF), 18, False)
    else if abs(dmax_DJF) .gt. abs(dmin_DJF) then
      mnmxint_DJF = nice_mnmxintvl(abs(dmax_DJF)*(-1), abs(dmax_DJF), 18, False)
    end if
    end if
;  end if

;  if dmin_MAM .eq. dmax_MAM then
;    if abs(mmin_MAM) .gt. abs(mmax_MAM) then
;      mnmxint_MAM = nice_mnmxintvl(mmin_MAM, abs(mmin_MAM), 18, False)
;    else if abs(mmax_MAM) .gt. abs(mmin_MAM) then
;      mnmxint_MAM = nice_mnmxintvl(abs(mmax_MAM)*(-1), abs(mmax_MAM), 18, False)
;    end if
;    end if
;  else
    if abs(dmin_MAM) .gt. abs(dmax_MAM) then
      mnmxint_MAM = nice_mnmxintvl(dmin_MAM, abs(dmin_MAM), 18, False)
    else if abs(dmax_MAM) .gt. abs(dmin_MAM) then
      mnmxint_MAM = nice_mnmxintvl(abs(dmax_MAM)*(-1), abs(dmax_MAM), 18, False)
    end if
    end if
;  end if

;  if dmin_JJA .eq. dmax_JJA then
;    if abs(mmin_JJA) .gt. abs(mmax_JJA) then
;      mnmxint_JJA = nice_mnmxintvl(mmin_JJA, abs(mmin_JJA), 18, False)
;    else if abs(mmax_JJA) .gt. abs(mmin_JJA) then
;      mnmxint_JJA = nice_mnmxintvl(abs(mmax_JJA)*(-1), abs(mmax_JJA), 18, False)
;    end if
;    end if
;  else
    if abs(dmin_JJA) .gt. abs(dmax_JJA) then
      mnmxint_JJA = nice_mnmxintvl(dmin_JJA, abs(dmin_JJA), 18, False)
    else if abs(dmax_JJA) .gt. abs(dmin_JJA) then
      mnmxint_JJA = nice_mnmxintvl(abs(dmax_JJA)*(-1), abs(dmax_JJA), 18, False)
    end if
    end if
;  end if

;  if dmin_SON .eq. dmax_SON then
;    if abs(mmin_SON) .gt. abs(mmax_SON) then
;      mnmxint_SON = nice_mnmxintvl(mmin_SON, abs(mmin_SON), 18, False)
;    else if abs(mmax_SON) .gt. abs(mmin_SON) then
;      mnmxint_SON = nice_mnmxintvl(abs(mmax_SON)*(-1), abs(mmax_SON), 18, False)
;    end if
;    end if
;  else
    if abs(dmin_SON) .gt. abs(dmax_SON) then
      mnmxint_SON = nice_mnmxintvl(dmin_SON, abs(dmin_SON), 18, False)
    else if abs(dmax_SON) .gt. abs(dmin_SON) then
      mnmxint_SON = nice_mnmxintvl(abs(dmax_SON)*(-1), abs(dmax_SON), 18, False)
    end if
    end if
;  end if

;  if dmin_ann .eq. dmax_ann then
;    if abs(mmin_ann) .gt. abs(mmax_ann) then
;      mnmxint_ann = nice_mnmxintvl(mmin_ann, abs(mmin_ann), 18, False)
;    else if abs(mmax_ann) .gt. abs(mmin_ann) then
;      mnmxint_ann = nice_mnmxintvl(abs(mmax_ann)*(-1), abs(mmax_ann), 18, False)
;    end if
;    end if
;  else
    if abs(dmin_ann) .gt. abs(dmax_ann) then
      mnmxint_ann = nice_mnmxintvl(dmin_ann, abs(dmin_ann), 18, False)
    else if abs(dmax_ann) .gt. abs(dmin_ann) then
      mnmxint_ann = nice_mnmxintvl(abs(dmax_ann)*(-1), abs(dmax_ann), 18, False)
    end if
    end if
;  end if

; Difference RCM - OBS average
  delete(res@cnFillPalette)
  if var .eq. "pr" then
    res@cnFillPalette = cmap_cmocean_balance(::-1,:)
  else
    res@cnFillPalette = cmap_cmocean_balance
  end if
  res@cnMinLevelValF = mnmxint_DJF(0)
  res@cnMaxLevelValF = mnmxint_DJF(1)
  res@cnLevelSpacingF = mnmxint_DJF(2)
  aavg = wgt_areaave_Wrap(rcm_obs_DJF_99p, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_DJF_99p)
  tp = num(.not.ismissing(rcm_obs_DJF_99p))
  pp = num(where(rcm_obs_DJF_99p.gt.0, 1, 0))
  np = num(where(rcm_obs_DJF_99p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-OBS DJF, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(15) = gsn_csm_contour_map_ce(wks0, rcm_obs_DJF_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_MAM(0)
  res@cnMaxLevelValF = mnmxint_MAM(1)
  res@cnLevelSpacingF = mnmxint_MAM(2)
  aavg = wgt_areaave_Wrap(rcm_obs_MAM_99p, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_MAM_99p)
  tp = num(.not.ismissing(rcm_obs_MAM_99p))
  pp = num(where(rcm_obs_MAM_99p.gt.0, 1, 0))
  np = num(where(rcm_obs_MAM_99p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-OBS MAM, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(16) = gsn_csm_contour_map_ce(wks0, rcm_obs_MAM_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_JJA(0)
  res@cnMaxLevelValF = mnmxint_JJA(1)
  res@cnLevelSpacingF = mnmxint_JJA(2)
  aavg = wgt_areaave_Wrap(rcm_obs_JJA_99p, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_JJA_99p)
  tp = num(.not.ismissing(rcm_obs_JJA_99p))
  pp = num(where(rcm_obs_JJA_99p.gt.0, 1, 0))
  np = num(where(rcm_obs_JJA_99p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-OBS JJA, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(17) = gsn_csm_contour_map_ce(wks0, rcm_obs_JJA_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_SON(0)
  res@cnMaxLevelValF = mnmxint_SON(1)
  res@cnLevelSpacingF = mnmxint_SON(2)
  aavg = wgt_areaave_Wrap(rcm_obs_SON_99p, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_SON_99p)
  tp = num(.not.ismissing(rcm_obs_SON_99p))
  pp = num(where(rcm_obs_SON_99p.gt.0, 1, 0))
  np = num(where(rcm_obs_SON_99p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-OBS SON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(18) = gsn_csm_contour_map_ce(wks0, rcm_obs_SON_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_ann(0)
  res@cnMaxLevelValF = mnmxint_ann(1)
  res@cnLevelSpacingF = mnmxint_ann(2)
  aavg = wgt_areaave_Wrap(rcm_obs_ann_99p, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_ann_99p)
  tp = num(.not.ismissing(rcm_obs_ann_99p))
  pp = num(where(rcm_obs_ann_99p.gt.0, 1, 0))
  np = num(where(rcm_obs_ann_99p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-OBS ANN, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(19) = gsn_csm_contour_map_ce(wks0, rcm_obs_ann_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

; Difference GDD - OBS average
  res@cnMinLevelValF = mnmxint_DJF(0)
  res@cnMaxLevelValF = mnmxint_DJF(1)
  res@cnLevelSpacingF = mnmxint_DJF(2)
  aavg = wgt_areaave_Wrap(gdd_obs_DJF_99p, data_wgt, 1.0, 0)
  sd = stddev(gdd_obs_DJF_99p)
  tp = num(.not.ismissing(gdd_obs_DJF_99p))
  pp = num(where(gdd_obs_DJF_99p.gt.0, 1, 0))
  np = num(where(gdd_obs_DJF_99p.lt.0, 1, 0))
  res@gsnLeftString = "GDD-OBS DJF, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(20) = gsn_csm_contour_map_ce(wks0, gdd_obs_DJF_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_MAM(0)
  res@cnMaxLevelValF = mnmxint_MAM(1)
  res@cnLevelSpacingF = mnmxint_MAM(2)
  aavg = wgt_areaave_Wrap(gdd_obs_MAM_99p, data_wgt, 1.0, 0)
  sd = stddev(gdd_obs_MAM_99p)
  tp = num(.not.ismissing(gdd_obs_MAM_99p))
  pp = num(where(gdd_obs_MAM_99p.gt.0, 1, 0))
  np = num(where(gdd_obs_MAM_99p.lt.0, 1, 0))
  res@gsnLeftString = "GDD-OBS MAM, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(21) = gsn_csm_contour_map_ce(wks0, gdd_obs_MAM_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_JJA(0)
  res@cnMaxLevelValF = mnmxint_JJA(1)
  res@cnLevelSpacingF = mnmxint_JJA(2)
  aavg = wgt_areaave_Wrap(gdd_obs_JJA_99p, data_wgt, 1.0, 0)
  sd = stddev(gdd_obs_JJA_99p)
  tp = num(.not.ismissing(gdd_obs_JJA_99p))
  pp = num(where(gdd_obs_JJA_99p.gt.0, 1, 0))
  np = num(where(gdd_obs_JJA_99p.lt.0, 1, 0))
  res@gsnLeftString = "GDD-OBS JJA, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(22) = gsn_csm_contour_map_ce(wks0, gdd_obs_JJA_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_SON(0)
  res@cnMaxLevelValF = mnmxint_SON(1)
  res@cnLevelSpacingF = mnmxint_SON(2)
  aavg = wgt_areaave_Wrap(gdd_obs_SON_99p, data_wgt, 1.0, 0)
  sd = stddev(gdd_obs_SON_99p)
  tp = num(.not.ismissing(gdd_obs_SON_99p))
  pp = num(where(gdd_obs_SON_99p.gt.0, 1, 0))
  np = num(where(gdd_obs_SON_99p.lt.0, 1, 0))
  res@gsnLeftString = "GDD-OBS SON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(23) = gsn_csm_contour_map_ce(wks0, gdd_obs_SON_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_ann(0)
  res@cnMaxLevelValF = mnmxint_ann(1)
  res@cnLevelSpacingF = mnmxint_ann(2)
  aavg = wgt_areaave_Wrap(gdd_obs_ann_99p, data_wgt, 1.0, 0)
  sd = stddev(gdd_obs_ann_99p)
  tp = num(.not.ismissing(gdd_obs_ann_99p))
  pp = num(where(gdd_obs_ann_99p.gt.0, 1, 0))
  np = num(where(gdd_obs_ann_99p.lt.0, 1, 0))
  res@gsnLeftString = "GDD-OBS ANN, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(24) = gsn_csm_contour_map_ce(wks0, gdd_obs_ann_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

; Difference RCM - GDD average
  res@cnMinLevelValF = mnmxint_DJF(0)
  res@cnMaxLevelValF = mnmxint_DJF(1)
  res@cnLevelSpacingF = mnmxint_DJF(2)
  aavg = wgt_areaave_Wrap(rcm_gdd_DJF_99p, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_DJF_99p)
  tp = num(.not.ismissing(rcm_gdd_DJF_99p))
  pp = num(where(rcm_gdd_DJF_99p.gt.0, 1, 0))
  np = num(where(rcm_gdd_DJF_99p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-GDD DJF, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(25) = gsn_csm_contour_map_ce(wks0, rcm_gdd_DJF_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_MAM(0)
  res@cnMaxLevelValF = mnmxint_MAM(1)
  res@cnLevelSpacingF = mnmxint_MAM(2)
  aavg = wgt_areaave_Wrap(rcm_gdd_MAM_99p, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_MAM_99p)
  tp = num(.not.ismissing(rcm_gdd_MAM_99p))
  pp = num(where(rcm_gdd_MAM_99p.gt.0, 1, 0))
  np = num(where(rcm_gdd_MAM_99p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-GDD MAM, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(26) = gsn_csm_contour_map_ce(wks0, rcm_gdd_MAM_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_JJA(0)
  res@cnMaxLevelValF = mnmxint_JJA(1)
  res@cnLevelSpacingF = mnmxint_JJA(2)
  aavg = wgt_areaave_Wrap(rcm_gdd_JJA_99p, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_JJA_99p)
  tp = num(.not.ismissing(rcm_gdd_JJA_99p))
  pp = num(where(rcm_gdd_JJA_99p.gt.0, 1, 0))
  np = num(where(rcm_gdd_JJA_99p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-GDD JJA, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(27) = gsn_csm_contour_map_ce(wks0, rcm_gdd_JJA_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_SON(0)
  res@cnMaxLevelValF = mnmxint_SON(1)
  res@cnLevelSpacingF = mnmxint_SON(2)
  aavg = wgt_areaave_Wrap(rcm_gdd_SON_99p, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_SON_99p)
  tp = num(.not.ismissing(rcm_gdd_SON_99p))
  pp = num(where(rcm_gdd_SON_99p.gt.0, 1, 0))
  np = num(where(rcm_gdd_SON_99p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-GDD SON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(28) = gsn_csm_contour_map_ce(wks0, rcm_gdd_SON_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_ann(0)
  res@cnMaxLevelValF = mnmxint_ann(1)
  res@cnLevelSpacingF = mnmxint_ann(2)
  aavg = wgt_areaave_Wrap(rcm_gdd_ann_99p, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_ann_99p)
  tp = num(.not.ismissing(rcm_gdd_ann_99p))
  pp = num(where(rcm_gdd_ann_99p.gt.0, 1, 0))
  np = num(where(rcm_gdd_ann_99p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-GDD ANN, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(29) = gsn_csm_contour_map_ce(wks0, rcm_gdd_ann_99p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  units = gdd_ann_99p@units
; Panel plots
  resP                    = True
  resP@gsnPanelMainString = "99th percentile "+yrStrt+"-"+yrLast+"~C~"+info+" ("+units+")"
  resP@gsnPanelLabelBar = False
  resP@gsnMaximize = True
  gsn_panel(wks0, plot0, (/6, 5/), resP)

;  delete([/seasonal, seasonal0, seasonal1, seasonal2, seasonal3, seasonal4, seasonal5, seasonal6, seasonal7, seasonal8, seasonal9, seasonal10, seasonal11, seasonal12/])
;  delete([/DJF, DJF0, MAM, MAM0, JJA, JJA0, SON, SON0, ann, ann0/])

  delete([/res@cnMinLevelValF, res@cnMaxLevelValF, res@cnLevelSpacingF/])
  delete([/stats_DJF, dmin_DJF, dmax_DJF, mmin_DJF, mmax_DJF, mnmxint_DJF/])
  delete([/stats_MAM, dmin_MAM, dmax_MAM, mmin_MAM, mmax_MAM, mnmxint_MAM/])
  delete([/stats_JJA, dmin_JJA, dmax_JJA, mmin_JJA, mmax_JJA, mnmxint_JJA/])
  delete([/stats_SON, dmin_SON, dmax_SON, mmin_SON, mmax_SON, mnmxint_SON/])
  delete([/stats_ann, dmin_ann, dmax_ann, mmin_ann, mmax_ann, mnmxint_ann/])

; *******************
; *******************
; Variance
; Variance
; Variance
; *******************
; *******************
  print("appending 01th percentile season arrays")

  DJF0 = array_append_record(gdd_DJF_01p, rcm_DJF_01p, 0)
  DJF = array_append_record(DJF0, obs_DJF_01p, 0)

  stats_DJF = stat_dispersion(DJF, False)
  dmin_DJF = stats_DJF(3)
  dmax_DJF = stats_DJF(13)
  mmin_DJF = stats_DJF(2)
  mmax_DJF = stats_DJF(14)

  MAM0 = array_append_record(gdd_MAM_01p, rcm_MAM_01p, 0)
  MAM = array_append_record(MAM0, obs_MAM_01p, 0)

  stats_MAM = stat_dispersion(MAM, False)
  dmin_MAM = stats_MAM(3)
  dmax_MAM = stats_MAM(13)
  mmin_MAM = stats_MAM(2)
  mmax_MAM = stats_MAM(14)

  JJA0 = array_append_record(gdd_JJA_01p, rcm_JJA_01p, 0)
  JJA = array_append_record(JJA0, obs_JJA_01p, 0)

  stats_JJA = stat_dispersion(JJA, False)
  dmin_JJA = stats_JJA(3)
  dmax_JJA = stats_JJA(13)
  mmin_JJA = stats_JJA(2)
  mmax_JJA = stats_JJA(14)

  SON0 = array_append_record(gdd_SON_01p, rcm_SON_01p, 0)
  SON = array_append_record(SON0, obs_SON_01p, 0)

  stats_SON = stat_dispersion(SON, False)
  dmin_SON = stats_SON(3)
  dmax_SON = stats_SON(13)
  mmin_SON = stats_SON(2)
  mmax_SON = stats_SON(14)

  ann0 = array_append_record(gdd_ann_01p, rcm_ann_01p, 0)
  ann = array_append_record(ann0, obs_ann_01p, 0)

  stats_ann = stat_dispersion(ann, False)
  dmin_ann = stats_ann(3)
  dmax_ann = stats_ann(13)
  mmin_ann = stats_ann(2)
  mmax_ann = stats_ann(14)

  ; calculate which is larger and use the same scale for all seasons
;  mnmxint_DJF = nice_mnmxintvl(mmin_DJF, mmax_DJF, 18, False)
;  mnmxint_MAM = nice_mnmxintvl(mmin_MAM, mmax_MAM, 18, False)
;  mnmxint_JJA = nice_mnmxintvl(mmin_JJA, mmax_JJA, 18, False)
;  mnmxint_SON = nice_mnmxintvl(mmin_SON, mmax_SON, 18, False)
;  mnmxint_ann = nice_mnmxintvl(mmin_ann, mmax_ann, 18, False)

  mnmxint_DJF = nice_mnmxintvl(0.0, dmax_DJF, 18, False)
  mnmxint_MAM = nice_mnmxintvl(0.0, dmax_MAM, 18, False)
  mnmxint_JJA = nice_mnmxintvl(0.0, dmax_JJA, 18, False)
  mnmxint_SON = nice_mnmxintvl(0.0, dmax_SON, 18, False)
  mnmxint_ann = nice_mnmxintvl(0.0, dmax_ann, 18, False)

; OBS variance
  delete(res@cnFillPalette)
  if var.eq."pr" then
    res@cnFillPalette = cmap_cmocean_ice(::-1,:) ; reverse the colourmap to white to blue
  else
    res@cnFillPalette = cmap_cmocean_amp
  end if
  res@cnMinLevelValF = mnmxint_DJF(0)
  res@cnMaxLevelValF = mnmxint_DJF(1)
  res@cnLevelSpacingF = mnmxint_DJF(2)
  aavg = wgt_areaave_Wrap(obs_DJF_01p, data_wgt, 1.0, 0)
  sd = stddev(obs_DJF_01p)
  tp = num(.not.ismissing(obs_DJF_01p))
  pp = num(where(obs_DJF_01p.gt.0, 1, 0))
  np = num(where(obs_DJF_01p.lt.0, 1, 0))
  res@gsnLeftString = "OBS DJF, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(0) = gsn_csm_contour_map_ce(wks0, obs_DJF_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_MAM(0)
  res@cnMaxLevelValF = mnmxint_MAM(1)
  res@cnLevelSpacingF = mnmxint_MAM(2)
  aavg = wgt_areaave_Wrap(obs_MAM_01p, data_wgt, 1.0, 0)
  sd = stddev(obs_MAM_01p)
  tp = num(.not.ismissing(obs_MAM_01p))
  pp = num(where(obs_MAM_01p.gt.0, 1, 0))
  np = num(where(obs_MAM_01p.lt.0, 1, 0))
  res@gsnLeftString = "OBS MAM, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(1) = gsn_csm_contour_map_ce(wks0, obs_MAM_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_JJA(0)
  res@cnMaxLevelValF = mnmxint_JJA(1)
  res@cnLevelSpacingF = mnmxint_JJA(2)
  aavg = wgt_areaave_Wrap(obs_JJA_01p, data_wgt, 1.0, 0)
  sd = stddev(obs_JJA_01p)
  tp = num(.not.ismissing(obs_JJA_01p))
  pp = num(where(obs_JJA_01p.gt.0, 1, 0))
  np = num(where(obs_JJA_01p.lt.0, 1, 0))
  res@gsnLeftString = "OBS JJA, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(2) = gsn_csm_contour_map_ce(wks0, obs_JJA_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_SON(0)
  res@cnMaxLevelValF = mnmxint_SON(1)
  res@cnLevelSpacingF = mnmxint_SON(2)
  aavg = wgt_areaave_Wrap(obs_SON_01p, data_wgt, 1.0, 0)
  sd = stddev(obs_SON_01p)
  tp = num(.not.ismissing(obs_SON_01p))
  pp = num(where(obs_SON_01p.gt.0, 1, 0))
  np = num(where(obs_SON_01p.lt.0, 1, 0))
  res@gsnLeftString = "OBS SON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(3) = gsn_csm_contour_map_ce(wks0, obs_SON_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_ann(0)
  res@cnMaxLevelValF = mnmxint_ann(1)
  res@cnLevelSpacingF = mnmxint_ann(2)
  aavg = wgt_areaave_Wrap(obs_ann_01p, data_wgt, 1.0, 0)
  sd = stddev(obs_ann_01p)
  tp = num(.not.ismissing(obs_ann_01p))
  pp = num(where(obs_ann_01p.gt.0, 1, 0))
  np = num(where(obs_ann_01p.lt.0, 1, 0))
  res@gsnLeftString = "OBS ANN, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(4) = gsn_csm_contour_map_ce(wks0, obs_ann_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

; GDD variance
  res@cnMinLevelValF = mnmxint_DJF(0)
  res@cnMaxLevelValF = mnmxint_DJF(1)
  res@cnLevelSpacingF = mnmxint_DJF(2)
  aavg = wgt_areaave_Wrap(gdd_DJF_01p, data_wgt, 1.0, 0)
  sd = stddev(gdd_DJF_01p)
  tp = num(.not.ismissing(gdd_DJF_01p))
  pp = num(where(gdd_DJF_01p.gt.0, 1, 0))
  np = num(where(gdd_DJF_01p.lt.0, 1, 0))
  res@gsnLeftString = "GDD DJF, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(5) = gsn_csm_contour_map_ce(wks0, gdd_DJF_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_MAM(0)
  res@cnMaxLevelValF = mnmxint_MAM(1)
  res@cnLevelSpacingF = mnmxint_MAM(2)
  aavg = wgt_areaave_Wrap(gdd_MAM_01p, data_wgt, 1.0, 0)
  sd = stddev(gdd_MAM_01p)
  tp = num(.not.ismissing(gdd_MAM_01p))
  pp = num(where(gdd_MAM_01p.gt.0, 1, 0))
  np = num(where(gdd_MAM_01p.lt.0, 1, 0))
  res@gsnLeftString = "GDD MAM, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(6) = gsn_csm_contour_map_ce(wks0, gdd_MAM_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_JJA(0)
  res@cnMaxLevelValF = mnmxint_JJA(1)
  res@cnLevelSpacingF = mnmxint_JJA(2)
  aavg = wgt_areaave_Wrap(gdd_JJA_01p, data_wgt, 1.0, 0)
  sd = stddev(gdd_JJA_01p)
  tp = num(.not.ismissing(gdd_JJA_01p))
  pp = num(where(gdd_JJA_01p.gt.0, 1, 0))
  np = num(where(gdd_JJA_01p.lt.0, 1, 0))
  res@gsnLeftString = "GDD JJA, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(7) = gsn_csm_contour_map_ce(wks0, gdd_JJA_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_SON(0)
  res@cnMaxLevelValF = mnmxint_SON(1)
  res@cnLevelSpacingF = mnmxint_SON(2)
  aavg = wgt_areaave_Wrap(gdd_SON_01p, data_wgt, 1.0, 0)
  sd = stddev(gdd_SON_01p)
  tp = num(.not.ismissing(gdd_SON_01p))
  pp = num(where(gdd_SON_01p.gt.0, 1, 0))
  np = num(where(gdd_SON_01p.lt.0, 1, 0))
  res@gsnLeftString = "GDD SON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(8) = gsn_csm_contour_map_ce(wks0, gdd_SON_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_ann(0)
  res@cnMaxLevelValF = mnmxint_ann(1)
  res@cnLevelSpacingF = mnmxint_ann(2)
  aavg = wgt_areaave_Wrap(gdd_ann_01p, data_wgt, 1.0, 0)
  sd = stddev(gdd_ann_01p)
  tp = num(.not.ismissing(gdd_ann_01p))
  pp = num(where(gdd_ann_01p.gt.0, 1, 0))
  np = num(where(gdd_ann_01p.lt.0, 1, 0))
  res@gsnLeftString = "GDD ANN, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(9) = gsn_csm_contour_map_ce(wks0, gdd_ann_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])
  
; RCM variance
  res@cnMinLevelValF = mnmxint_DJF(0)
  res@cnMaxLevelValF = mnmxint_DJF(1)
  res@cnLevelSpacingF = mnmxint_DJF(2)
  aavg = wgt_areaave_Wrap(rcm_DJF_01p, data_wgt, 1.0, 0)
  sd = stddev(rcm_DJF_01p)
  tp = num(.not.ismissing(rcm_DJF_01p))
  pp = num(where(rcm_DJF_01p.gt.0, 1, 0))
  np = num(where(rcm_DJF_01p.lt.0, 1, 0))
  res@gsnLeftString = "RCM DJF, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(10) = gsn_csm_contour_map_ce(wks0, rcm_DJF_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_MAM(0)
  res@cnMaxLevelValF = mnmxint_MAM(1)
  res@cnLevelSpacingF = mnmxint_MAM(2)
  aavg = wgt_areaave_Wrap(rcm_MAM_01p, data_wgt, 1.0, 0)
  sd = stddev(rcm_MAM_01p)
  tp = num(.not.ismissing(rcm_MAM_01p))
  pp = num(where(rcm_MAM_01p.gt.0, 1, 0))
  np = num(where(rcm_MAM_01p.lt.0, 1, 0))
  res@gsnLeftString = "RCM MAM, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(11) = gsn_csm_contour_map_ce(wks0, rcm_MAM_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_JJA(0)
  res@cnMaxLevelValF = mnmxint_JJA(1)
  res@cnLevelSpacingF = mnmxint_JJA(2)
  aavg = wgt_areaave_Wrap(rcm_JJA_01p, data_wgt, 1.0, 0)
  sd = stddev(rcm_JJA_01p)
  tp = num(.not.ismissing(rcm_JJA_01p))
  pp = num(where(rcm_JJA_01p.gt.0, 1, 0))
  np = num(where(rcm_JJA_01p.lt.0, 1, 0))
  res@gsnLeftString = "RCM JJA, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(12) = gsn_csm_contour_map_ce(wks0, rcm_JJA_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_SON(0)
  res@cnMaxLevelValF = mnmxint_SON(1)
  res@cnLevelSpacingF = mnmxint_SON(2)
  aavg = wgt_areaave_Wrap(rcm_SON_01p, data_wgt, 1.0, 0)
  sd = stddev(rcm_SON_01p)
  tp = num(.not.ismissing(rcm_SON_01p))
  pp = num(where(rcm_SON_01p.gt.0, 1, 0))
  np = num(where(rcm_SON_01p.lt.0, 1, 0))
  res@gsnLeftString = "RCM SON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(13) = gsn_csm_contour_map_ce(wks0, rcm_SON_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_ann(0)
  res@cnMaxLevelValF = mnmxint_ann(1)
  res@cnLevelSpacingF = mnmxint_ann(2)
  aavg = wgt_areaave_Wrap(rcm_ann_01p, data_wgt, 1.0, 0)
  sd = stddev(rcm_ann_01p)
  tp = num(.not.ismissing(rcm_ann_01p))
  pp = num(where(rcm_ann_01p.gt.0, 1, 0))
  np = num(where(rcm_ann_01p.lt.0, 1, 0))
  res@gsnLeftString = "RCM ANN, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(14) = gsn_csm_contour_map_ce(wks0, rcm_ann_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])
  delete([/res@cnMinLevelValF, res@cnMaxLevelValF, res@cnLevelSpacingF/])
  delete([/stats_DJF, dmin_DJF, dmax_DJF, mmin_DJF, mmax_DJF, mnmxint_DJF/])
  delete([/stats_MAM, dmin_MAM, dmax_MAM, mmin_MAM, mmax_MAM, mnmxint_MAM/])
  delete([/stats_JJA, dmin_JJA, dmax_JJA, mmin_JJA, mmax_JJA, mnmxint_JJA/])
  delete([/stats_SON, dmin_SON, dmax_SON, mmin_SON, mmax_SON, mnmxint_SON/])
  delete([/stats_ann, dmin_ann, dmax_ann, mmin_ann, mmax_ann, mnmxint_ann/])

; difference RCM-GDD

;  delete([/stats, dmin, dmax, mmin, mmax, mnmxint/])
;  seasonal0 = array_append_record(rcm_gdd_DJF_01p, rcm_gdd_MAM_01p, 0)
;  seasonal1 = array_append_record(seasonal0, rcm_gdd_JJA_01p, 0)
;  seasonal2 = array_append_record(seasonal1, rcm_gdd_SON_01p, 0)
;  seasonal3 = array_append_record(seasonal2, rcm_gdd_ann_01p, 0)
;  seasonal4 = array_append_record(seasonal3, rcm_obs_DJF_01p, 0)
;  seasonal5 = array_append_record(seasonal4, rcm_obs_MAM_01p, 0)
;  seasonal6 = array_append_record(seasonal5, rcm_obs_JJA_01p, 0)
;  seasonal7 = array_append_record(seasonal6, rcm_obs_SON_01p, 0)
;  seasonal8 = array_append_record(seasonal7, rcm_obs_ann_01p, 0)
;  seasonal9 = array_append_record(seasonal8, gdd_obs_DJF_01p, 0)
;  seasonal10 = array_append_record(seasonal9, gdd_obs_MAM_01p, 0)
;  seasonal11 = array_append_record(seasonal10, gdd_obs_JJA_01p, 0)
;  seasonal12 = array_append_record(seasonal11, gdd_obs_SON_01p, 0)
;  seasonal = array_append_record(seasonal12, gdd_obs_ann_01p, 0)
;
;  stats = stat_dispersion(seasonal, False)
;  dmin = stats(3)
;  dmax = stats(13)
;  mmin = stats(2)
;  mmax = stats(14)
;  ; calculate which is larger
;  mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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

; append seasonal arrays
  DJF0 = array_append_record(rcm_gdd_DJF_01p, rcm_obs_DJF_01p, 0)
  DJF = array_append_record(DJF0, gdd_obs_DJF_01p, 0)

  stats_DJF = stat_dispersion(DJF, False)
  dmin_DJF = stats_DJF(3)
  dmax_DJF = stats_DJF(13)
  mmin_DJF = stats_DJF(2)
  mmax_DJF = stats_DJF(14)

  MAM0 = array_append_record(rcm_gdd_MAM_01p, rcm_obs_MAM_01p, 0)
  MAM = array_append_record(MAM0, gdd_obs_MAM_01p, 0)

  stats_MAM = stat_dispersion(MAM, False)
  dmin_MAM = stats_MAM(3)
  dmax_MAM = stats_MAM(13)
  mmin_MAM = stats_MAM(2)
  mmax_MAM = stats_MAM(14)

  JJA0 = array_append_record(rcm_gdd_JJA_01p, rcm_obs_JJA_01p, 0)
  JJA = array_append_record(JJA0, gdd_obs_JJA_01p, 0)

  stats_JJA = stat_dispersion(JJA, False)
  dmin_JJA = stats_JJA(3)
  dmax_JJA = stats_JJA(13)
  mmin_JJA = stats_JJA(2)
  mmax_JJA = stats_JJA(14)

  SON0 = array_append_record(rcm_gdd_SON_01p, rcm_obs_SON_01p, 0)
  SON = array_append_record(SON0, gdd_obs_SON_01p, 0)

  stats_SON = stat_dispersion(SON, False)
  dmin_SON = stats_SON(3)
  dmax_SON = stats_SON(13)
  mmin_SON = stats_SON(2)
  mmax_SON = stats_SON(14)

  ann0 = array_append_record(rcm_gdd_ann_01p, rcm_obs_ann_01p, 0)
  ann = array_append_record(ann0, gdd_obs_ann_01p, 0)

  stats_ann = stat_dispersion(ann, False)
  dmin_ann = stats_ann(3)
  dmax_ann = stats_ann(13)
  mmin_ann = stats_ann(2)
  mmax_ann = stats_ann(14)

  ; calculate which is larger and use the same scale for all seasons
;  mnmxint_DJF = nice_mnmxintvl(dmin_DJF, dmax_DJF, 18, False)
;  mnmxint_MAM = nice_mnmxintvl(dmin_MAM, dmax_MAM, 18, False)
;  mnmxint_JJA = nice_mnmxintvl(dmin_JJA, dmax_JJA, 18, False)
;  mnmxint_SON = nice_mnmxintvl(dmin_SON, dmax_SON, 18, False)
;  mnmxint_ann = nice_mnmxintvl(dmin_ann, dmax_ann, 18, False)

;  if dmin_DJF .eq. dmax_DJF then
;    if abs(mmin_DJF) .gt. abs(mmax_DJF) then
;      mnmxint_DJF = nice_mnmxintvl(mmin_DJF, abs(mmin_DJF), 18, False)
;    else if abs(mmax_DJF) .gt. abs(mmin_DJF) then
;      mnmxint_DJF = nice_mnmxintvl(abs(mmax_DJF)*(-1), abs(mmax_DJF), 18, False)
;    end if
;    end if
;  else
    if abs(dmin_DJF) .gt. abs(dmax_DJF) then
      mnmxint_DJF = nice_mnmxintvl(dmin_DJF, abs(dmin_DJF), 18, False)
    else if abs(dmax_DJF) .gt. abs(dmin_DJF) then
      mnmxint_DJF = nice_mnmxintvl(abs(dmax_DJF)*(-1), abs(dmax_DJF), 18, False)
    end if
    end if
;  end if

;  if dmin_MAM .eq. dmax_MAM then
;    if abs(mmin_MAM) .gt. abs(mmax_MAM) then
;      mnmxint_MAM = nice_mnmxintvl(mmin_MAM, abs(mmin_MAM), 18, False)
;    else if abs(mmax_MAM) .gt. abs(mmin_MAM) then
;      mnmxint_MAM = nice_mnmxintvl(abs(mmax_MAM)*(-1), abs(mmax_MAM), 18, False)
;    end if
;    end if
;  else
    if abs(dmin_MAM) .gt. abs(dmax_MAM) then
      mnmxint_MAM = nice_mnmxintvl(dmin_MAM, abs(dmin_MAM), 18, False)
    else if abs(dmax_MAM) .gt. abs(dmin_MAM) then
      mnmxint_MAM = nice_mnmxintvl(abs(dmax_MAM)*(-1), abs(dmax_MAM), 18, False)
    end if
    end if
;  end if

;  if dmin_JJA .eq. dmax_JJA then
;    if abs(mmin_JJA) .gt. abs(mmax_JJA) then
;      mnmxint_JJA = nice_mnmxintvl(mmin_JJA, abs(mmin_JJA), 18, False)
;    else if abs(mmax_JJA) .gt. abs(mmin_JJA) then
;      mnmxint_JJA = nice_mnmxintvl(abs(mmax_JJA)*(-1), abs(mmax_JJA), 18, False)
;    end if
;    end if
;  else
    if abs(dmin_JJA) .gt. abs(dmax_JJA) then
      mnmxint_JJA = nice_mnmxintvl(dmin_JJA, abs(dmin_JJA), 18, False)
    else if abs(dmax_JJA) .gt. abs(dmin_JJA) then
      mnmxint_JJA = nice_mnmxintvl(abs(dmax_JJA)*(-1), abs(dmax_JJA), 18, False)
    end if
    end if
;  end if

;  if dmin_SON .eq. dmax_SON then
;    if abs(mmin_SON) .gt. abs(mmax_SON) then
;      mnmxint_SON = nice_mnmxintvl(mmin_SON, abs(mmin_SON), 18, False)
;    else if abs(mmax_SON) .gt. abs(mmin_SON) then
;      mnmxint_SON = nice_mnmxintvl(abs(mmax_SON)*(-1), abs(mmax_SON), 18, False)
;    end if
;    end if
;  else
    if abs(dmin_SON) .gt. abs(dmax_SON) then
      mnmxint_SON = nice_mnmxintvl(dmin_SON, abs(dmin_SON), 18, False)
    else if abs(dmax_SON) .gt. abs(dmin_SON) then
      mnmxint_SON = nice_mnmxintvl(abs(dmax_SON)*(-1), abs(dmax_SON), 18, False)
    end if
    end if
;  end if

;  if dmin_ann .eq. dmax_ann then
;    if abs(mmin_ann) .gt. abs(mmax_ann) then
;      mnmxint_ann = nice_mnmxintvl(mmin_ann, abs(mmin_ann), 18, False)
;    else if abs(mmax_ann) .gt. abs(mmin_ann) then
;      mnmxint_ann = nice_mnmxintvl(abs(mmax_ann)*(-1), abs(mmax_ann), 18, False)
;    end if
;    end if
;  else
    if abs(dmin_ann) .gt. abs(dmax_ann) then
      mnmxint_ann = nice_mnmxintvl(dmin_ann, abs(dmin_ann), 18, False)
    else if abs(dmax_ann) .gt. abs(dmin_ann) then
      mnmxint_ann = nice_mnmxintvl(abs(dmax_ann)*(-1), abs(dmax_ann), 18, False)
    end if
    end if
;  end if

; Difference RCM - OBS variance
  delete(res@cnFillPalette)
  if var .eq. "pr" then
    res@cnFillPalette = cmap_cmocean_balance(::-1,:)
  else
    res@cnFillPalette = cmap_cmocean_balance
  end if
  res@cnMinLevelValF = mnmxint_DJF(0)
  res@cnMaxLevelValF = mnmxint_DJF(1)
  res@cnLevelSpacingF = mnmxint_DJF(2)
  aavg = wgt_areaave_Wrap(rcm_obs_DJF_01p, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_DJF_01p)
  tp = num(.not.ismissing(rcm_obs_DJF_01p))
  pp = num(where(rcm_obs_DJF_01p.gt.0, 1, 0))
  np = num(where(rcm_obs_DJF_01p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-OBS DJF, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(15) = gsn_csm_contour_map_ce(wks0, rcm_obs_DJF_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_MAM(0)
  res@cnMaxLevelValF = mnmxint_MAM(1)
  res@cnLevelSpacingF = mnmxint_MAM(2)
  aavg = wgt_areaave_Wrap(rcm_obs_MAM_01p, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_MAM_01p)
  tp = num(.not.ismissing(rcm_obs_MAM_01p))
  pp = num(where(rcm_obs_MAM_01p.gt.0, 1, 0))
  np = num(where(rcm_obs_MAM_01p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-OBS MAM, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(16) = gsn_csm_contour_map_ce(wks0, rcm_obs_MAM_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_JJA(0)
  res@cnMaxLevelValF = mnmxint_JJA(1)
  res@cnLevelSpacingF = mnmxint_JJA(2)
  aavg = wgt_areaave_Wrap(rcm_obs_JJA_01p, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_JJA_01p)
  tp = num(.not.ismissing(rcm_obs_JJA_01p))
  pp = num(where(rcm_obs_JJA_01p.gt.0, 1, 0))
  np = num(where(rcm_obs_JJA_01p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-OBS JJA, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(17) = gsn_csm_contour_map_ce(wks0, rcm_obs_JJA_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_SON(0)
  res@cnMaxLevelValF = mnmxint_SON(1)
  res@cnLevelSpacingF = mnmxint_SON(2)
  aavg = wgt_areaave_Wrap(rcm_obs_SON_01p, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_SON_01p)
  tp = num(.not.ismissing(rcm_obs_SON_01p))
  pp = num(where(rcm_obs_SON_01p.gt.0, 1, 0))
  np = num(where(rcm_obs_SON_01p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-OBS SON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(18) = gsn_csm_contour_map_ce(wks0, rcm_obs_SON_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_ann(0)
  res@cnMaxLevelValF = mnmxint_ann(1)
  res@cnLevelSpacingF = mnmxint_ann(2)
  aavg = wgt_areaave_Wrap(rcm_obs_ann_01p, data_wgt, 1.0, 0)
  sd = stddev(rcm_obs_ann_01p)
  tp = num(.not.ismissing(rcm_obs_ann_01p))
  pp = num(where(rcm_obs_ann_01p.gt.0, 1, 0))
  np = num(where(rcm_obs_ann_01p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-OBS ANN, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(19) = gsn_csm_contour_map_ce(wks0, rcm_obs_ann_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

; Difference GDD - OBS variance
  res@cnMinLevelValF = mnmxint_DJF(0)
  res@cnMaxLevelValF = mnmxint_DJF(1)
  res@cnLevelSpacingF = mnmxint_DJF(2)
  aavg = wgt_areaave_Wrap(gdd_obs_DJF_01p, data_wgt, 1.0, 0)
  sd = stddev(gdd_obs_DJF_01p)
  tp = num(.not.ismissing(gdd_obs_DJF_01p))
  pp = num(where(gdd_obs_DJF_01p.gt.0, 1, 0))
  np = num(where(gdd_obs_DJF_01p.lt.0, 1, 0))
  res@gsnLeftString = "GDD-OBS DJF, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(20) = gsn_csm_contour_map_ce(wks0, gdd_obs_DJF_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_MAM(0)
  res@cnMaxLevelValF = mnmxint_MAM(1)
  res@cnLevelSpacingF = mnmxint_MAM(2)
  aavg = wgt_areaave_Wrap(gdd_obs_MAM_01p, data_wgt, 1.0, 0)
  sd = stddev(gdd_obs_MAM_01p)
  tp = num(.not.ismissing(gdd_obs_MAM_01p))
  pp = num(where(gdd_obs_MAM_01p.gt.0, 1, 0))
  np = num(where(gdd_obs_MAM_01p.lt.0, 1, 0))
  res@gsnLeftString = "GDD-OBS MAM, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(21) = gsn_csm_contour_map_ce(wks0, gdd_obs_MAM_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_JJA(0)
  res@cnMaxLevelValF = mnmxint_JJA(1)
  res@cnLevelSpacingF = mnmxint_JJA(2)
  aavg = wgt_areaave_Wrap(gdd_obs_JJA_01p, data_wgt, 1.0, 0)
  sd = stddev(gdd_obs_JJA_01p)
  tp = num(.not.ismissing(gdd_obs_JJA_01p))
  pp = num(where(gdd_obs_JJA_01p.gt.0, 1, 0))
  np = num(where(gdd_obs_JJA_01p.lt.0, 1, 0))
  res@gsnLeftString = "GDD-OBS JJA, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(22) = gsn_csm_contour_map_ce(wks0, gdd_obs_JJA_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_SON(0)
  res@cnMaxLevelValF = mnmxint_SON(1)
  res@cnLevelSpacingF = mnmxint_SON(2)
  aavg = wgt_areaave_Wrap(gdd_obs_SON_01p, data_wgt, 1.0, 0)
  sd = stddev(gdd_obs_SON_01p)
  tp = num(.not.ismissing(gdd_obs_SON_01p))
  pp = num(where(gdd_obs_SON_01p.gt.0, 1, 0))
  np = num(where(gdd_obs_SON_01p.lt.0, 1, 0))
  res@gsnLeftString = "GDD-OBS SON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(23) = gsn_csm_contour_map_ce(wks0, gdd_obs_SON_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_ann(0)
  res@cnMaxLevelValF = mnmxint_ann(1)
  res@cnLevelSpacingF = mnmxint_ann(2)
  aavg = wgt_areaave_Wrap(gdd_obs_ann_01p, data_wgt, 1.0, 0)
  sd = stddev(gdd_obs_ann_01p)
  tp = num(.not.ismissing(gdd_obs_ann_01p))
  pp = num(where(gdd_obs_ann_01p.gt.0, 1, 0))
  np = num(where(gdd_obs_ann_01p.lt.0, 1, 0))
  res@gsnLeftString = "GDD-OBS ANN, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(24) = gsn_csm_contour_map_ce(wks0, gdd_obs_ann_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

; Difference RCM - GDD variance
  res@cnMinLevelValF = mnmxint_DJF(0)
  res@cnMaxLevelValF = mnmxint_DJF(1)
  res@cnLevelSpacingF = mnmxint_DJF(2)
  aavg = wgt_areaave_Wrap(rcm_gdd_DJF_01p, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_DJF_01p)
  tp = num(.not.ismissing(rcm_gdd_DJF_01p))
  pp = num(where(rcm_gdd_DJF_01p.gt.0, 1, 0))
  np = num(where(rcm_gdd_DJF_01p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-GDD DJF, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(25) = gsn_csm_contour_map_ce(wks0, rcm_gdd_DJF_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_MAM(0)
  res@cnMaxLevelValF = mnmxint_MAM(1)
  res@cnLevelSpacingF = mnmxint_MAM(2)
  aavg = wgt_areaave_Wrap(rcm_gdd_MAM_01p, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_MAM_01p)
  tp = num(.not.ismissing(rcm_gdd_MAM_01p))
  pp = num(where(rcm_gdd_MAM_01p.gt.0, 1, 0))
  np = num(where(rcm_gdd_MAM_01p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-GDD MAM, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(26) = gsn_csm_contour_map_ce(wks0, rcm_gdd_MAM_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_JJA(0)
  res@cnMaxLevelValF = mnmxint_JJA(1)
  res@cnLevelSpacingF = mnmxint_JJA(2)
  aavg = wgt_areaave_Wrap(rcm_gdd_JJA_01p, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_JJA_01p)
  tp = num(.not.ismissing(rcm_gdd_JJA_01p))
  pp = num(where(rcm_gdd_JJA_01p.gt.0, 1, 0))
  np = num(where(rcm_gdd_JJA_01p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-GDD JJA, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(27) = gsn_csm_contour_map_ce(wks0, rcm_gdd_JJA_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_SON(0)
  res@cnMaxLevelValF = mnmxint_SON(1)
  res@cnLevelSpacingF = mnmxint_SON(2)
  aavg = wgt_areaave_Wrap(rcm_gdd_SON_01p, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_SON_01p)
  tp = num(.not.ismissing(rcm_gdd_SON_01p))
  pp = num(where(rcm_gdd_SON_01p.gt.0, 1, 0))
  np = num(where(rcm_gdd_SON_01p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-GDD SON, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(28) = gsn_csm_contour_map_ce(wks0, rcm_gdd_SON_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  res@cnMinLevelValF = mnmxint_ann(0)
  res@cnMaxLevelValF = mnmxint_ann(1)
  res@cnLevelSpacingF = mnmxint_ann(2)
  aavg = wgt_areaave_Wrap(rcm_gdd_ann_01p, data_wgt, 1.0, 0)
  sd = stddev(rcm_gdd_ann_01p)
  tp = num(.not.ismissing(rcm_gdd_ann_01p))
  pp = num(where(rcm_gdd_ann_01p.gt.0, 1, 0))
  np = num(where(rcm_gdd_ann_01p.lt.0, 1, 0))
  res@gsnLeftString = "RCM-GDD ANN, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(29) = gsn_csm_contour_map_ce(wks0, rcm_gdd_ann_01p, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  units = gdd_ann_99p@units
; Panel plots
  resP                    = True
  resP@gsnPanelMainString = "01th percentile "+yrStrt+"-"+yrLast+"~C~"+info+" ("+units+")"
  resP@gsnPanelLabelBar = False
  resP@gsnMaximize = True
  gsn_panel(wks0, plot1, (/6, 5/), resP)

  fout = addfile("../calculated/plots/plot_"+var+"_seasonal_annual_percentiles_automate.nc", "c")
  fout->rcm_obs_ann_99p = rcm_obs_ann_99p
  fout->rcm_obs_DJF_99p = rcm_obs_DJF_99p
  fout->rcm_obs_MAM_99p = rcm_obs_MAM_99p
  fout->rcm_obs_JJA_99p = rcm_obs_JJA_99p
  fout->rcm_obs_SON_99p = rcm_obs_SON_99p
  fout->rcm_gdd_ann_99p = rcm_gdd_ann_99p
  fout->rcm_gdd_DJF_99p = rcm_gdd_DJF_99p
  fout->rcm_gdd_MAM_99p = rcm_gdd_MAM_99p
  fout->rcm_gdd_JJA_99p = rcm_gdd_JJA_99p
  fout->rcm_gdd_SON_99p = rcm_gdd_SON_99p
  fout->rcm_obs_ann_01p = rcm_obs_ann_01p
  fout->rcm_obs_DJF_01p = rcm_obs_DJF_01p
  fout->rcm_obs_MAM_01p = rcm_obs_MAM_01p
  fout->rcm_obs_JJA_01p = rcm_obs_JJA_01p
  fout->rcm_obs_SON_01p = rcm_obs_SON_01p
  fout->rcm_gdd_ann_01p = rcm_gdd_ann_01p
  fout->rcm_gdd_DJF_01p = rcm_gdd_DJF_01p
  fout->rcm_gdd_MAM_01p = rcm_gdd_MAM_01p
  fout->rcm_gdd_JJA_01p = rcm_gdd_JJA_01p
  fout->rcm_gdd_SON_01p = rcm_gdd_SON_01p

end