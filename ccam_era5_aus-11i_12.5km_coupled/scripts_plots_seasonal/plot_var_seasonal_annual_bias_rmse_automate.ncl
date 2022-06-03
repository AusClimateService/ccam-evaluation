; plot seasonal bias and rmse

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

  obs_ann = month_to_annual(obs, 1)
  obs_ann_avg = dim_avg_n_Wrap(obs_ann, 0)
  rcm_ann = month_to_annual(rcm, 1)
  rcm_ann_avg = dim_avg_n_Wrap(rcm_ann, 0)
  gdd_ann = month_to_annual(gdd, 1)
  gdd_ann_avg = dim_avg_n_Wrap(gdd_ann, 0)

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

; plot
  obs_name = "../plots_seasonal/"+run_name+"_rcm_obs_"+var+"_seasonal_annual_bias_rmse"
  gdd_name = "../plots_seasonal/"+run_name+"_rcm_gdd_"+var+"_seasonal_annual_bias_rmse"

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

  wks0 = gsn_open_wks("pdf", obs_name)
  wks1 = gsn_open_wks("pdf", gdd_name)
  plot0 = new(18, graphic)
  plot1 = new(18, graphic)
  plot2 = new(18, graphic)
  plot3 = new(18, graphic)
  cmap_cmocean_balance = read_colormap_file("cmocean_balance")
  cmap_MPL_Reds = read_colormap_file("MPL_Reds")

if var.eq."pr" then
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
end