; plot seasonal bias and rmse

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
  rad = 4.0*atan(1.0)/180.0
  re  = 6371220.0
  rr  = re*rad

  f = addfile("../calculated/"+run_name+"_"+var+"_bias_rmse_monthly_means_no_agcd_awap_grid.nc", "r")

  rcm = f->rcm_var_month
  gdd_ = f->gdd_var_month
  gdd = tofloat(gdd_)
  copy_VarMeta(gdd_, gdd)
  delete(gdd_)

  new_time = cd_convert(rcm&time, "days since 0001-01-01 00:00:00")

  delete(gdd&time)
  delete(rcm&time)
  rcm&time = new_time
  gdd&time = new_time
  
; calculate seasonal/annual
  rcm_DJF = month_to_season(rcm, "DJF")
  rcm_DJF_avg = dim_avg_n_Wrap(rcm_DJF, 0)
  rcm_DJF_var = dim_variance_n_Wrap(rcm_DJF, 0)
  gdd_DJF = month_to_season(gdd, "DJF")
  gdd_DJF_avg = dim_avg_n_Wrap(gdd_DJF, 0)
  gdd_DJF_var = dim_variance_n_Wrap(gdd_DJF, 0)

  rcm_MAM = month_to_season(rcm, "MAM")
  rcm_MAM_avg = dim_avg_n_Wrap(rcm_MAM, 0)
  rcm_MAM_var = dim_variance_n_Wrap(rcm_MAM, 0)
  gdd_MAM = month_to_season(gdd, "MAM")
  gdd_MAM_avg = dim_avg_n_Wrap(gdd_MAM, 0)
  gdd_MAM_var = dim_variance_n_Wrap(gdd_MAM, 0)

  rcm_JJA = month_to_season(rcm, "JJA")
  rcm_JJA_avg = dim_avg_n_Wrap(rcm_JJA, 0)
  rcm_JJA_var = dim_variance_n_Wrap(rcm_JJA, 0)
  gdd_JJA = month_to_season(gdd, "JJA")
  gdd_JJA_avg = dim_avg_n_Wrap(gdd_JJA, 0)
  gdd_JJA_var = dim_variance_n_Wrap(gdd_JJA, 0)

  rcm_SON = month_to_season(rcm, "SON")
  rcm_SON_avg = dim_avg_n_Wrap(rcm_SON, 0)
  rcm_SON_var = dim_variance_n_Wrap(rcm_SON, 0)
  gdd_SON = month_to_season(gdd, "SON")
  gdd_SON_avg = dim_avg_n_Wrap(gdd_SON, 0)
  gdd_SON_var = dim_variance_n_Wrap(gdd_SON, 0)

  rcm_ann = month_to_annual(rcm, 1)
  rcm_ann_avg = dim_avg_n_Wrap(rcm_ann, 0)
  rcm_ann_var = dim_variance_n_Wrap(rcm_ann, 0)
  gdd_ann = month_to_annual(gdd, 1)
  gdd_ann_avg = dim_avg_n_Wrap(gdd_ann, 0)
  gdd_ann_var = dim_variance_n_Wrap(gdd_ann, 0)

  rcm_ann!0 = "time"
  rcm_ann&time = rcm_JJA&time

  gdd_ann!0 = "time"
  gdd_ann&time = gdd_JJA&time

  ; area average for time series
  lat = rcm&lat
  lon = rcm&lon
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
  rcm_mon_var = dim_variance_n_Wrap(rcm_mon, 1)
  rcm_avg = dim_avg_n_Wrap(rcm, 0)
  rcm_var = dim_variance_n_Wrap(rcm, 0)

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
  gdd_mon_var = dim_variance_n_Wrap(gdd_mon, 1)
  gdd_avg = dim_avg_n_Wrap(gdd, 0)
  gdd_var = dim_variance_n_Wrap(gdd, 0)

; plot
  gdd_name = "../plots/"+run_name+"_gdd_"+var+"_monthly_seasonal_average_variance"
  rcm_name = "../plots/"+run_name+"_rcm_"+var+"_monthly_seasonal_average_variance"

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

  wks1 = gsn_open_wks("pdf", gdd_name)
  wks2 = gsn_open_wks("pdf", rcm_name)
  plot2 = new(18, graphic)
  plot3 = new(18, graphic)
  plot4 = new(18, graphic)
  plot5 = new(18, graphic)
  cmap_cmocean_balance = read_colormap_file("cmocean_balance")
  cmap_MPL_Reds = read_colormap_file("MPL_Reds")

if var.eq."pr" then
  res@cnFillPalette = cmap_cmocean_balance(::-1,:) ; reverse the colourmap
else
  res@cnFillPalette = cmap_cmocean_balance
end if

; area weights
  lat = rcm_mon_avg&lat
  lon = rcm_mon_avg&lon
  nlat = dimsizes(lat)

  dlon   = abs(lon(2)-lon(1))*rr
  dx     = dlon*cos(lat*rad)
  dy     = new (nlat, typeof(dx))
  dy(0)  = abs(lat(2)-lat(1))*rr
  dy(1:nlat-2)  = abs(lat(2:nlat-1)-lat(0:nlat-3))*rr*0.5   
  dy(nlat-1)    = abs(lat(nlat-1)-lat(nlat-2))*rr

  data_wgt = dx*dy

; GDD avg
if var.eq."pr" then
  res@cnFillPalette = cmap_cmocean_balance(::-1,:) ; reverse the colourmap
else
  res@cnFillPalette = cmap_cmocean_balance
end if
  
  do n=0,11
    aavg = wgt_areaave_Wrap(gdd_mon_avg(n,:,:), data_wgt, 1.0, 0)
    sd = stddev(gdd_mon_avg(n,:,:))
    res@gsnLeftString = var+" "+mon(n)+" avg, ~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)

    stats = stat_dispersion(gdd_mon_avg, False)
    dmin = stats(3)
    dmax = stats(13)
    mmin = stats(2)
    mmax = stats(14)

    ; calculate which is larger
    mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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

    res@cnMinLevelValF = mnmxint(0)
    res@cnMaxLevelValF = mnmxint(1)
    res@cnLevelSpacingF = mnmxint(2)

    plot2(n) = gsn_csm_contour_map_ce(wks1, gdd_mon_avg(n,:,:), res)
    delete(aavg)
    delete(sd)
  end do

  ; append seasons into 1 large array
  season0 = array_append_record(gdd_DJF_avg, gdd_MAM_avg, 0)
  season1 = array_append_record(season0, gdd_JJA_avg, 0)
  season =  array_append_record(season1, gdd_SON_avg, 0)

  stats = stat_dispersion(season, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)

  ; calculate which is larger and use the same scale for all seasons
  mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(gdd_DJF_avg, data_wgt, 1.0, 0)
  sd = stddev(gdd_DJF_avg)
  res@gsnLeftString = var+" DJF avg, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot2(12) = gsn_csm_contour_map_ce(wks1, gdd_DJF_avg, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(gdd_MAM_avg, data_wgt, 1.0, 0)
  sd = stddev(gdd_MAM_avg)
  res@gsnLeftString = var+" MAM avg, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot2(13) = gsn_csm_contour_map_ce(wks1, gdd_MAM_avg, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(gdd_JJA_avg, data_wgt, 1.0, 0)
  sd = stddev(gdd_JJA_avg)
  res@gsnLeftString = var+" JJA avg, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot2(14) = gsn_csm_contour_map_ce(wks1, gdd_JJA_avg, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(gdd_SON_avg, data_wgt, 1.0, 0)
  sd = stddev(gdd_SON_avg)
  res@gsnLeftString = var+" SON avg, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot2(15) = gsn_csm_contour_map_ce(wks1, gdd_SON_avg, res)
  delete(aavg)
  delete(sd)

  stats = stat_dispersion(gdd_avg, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)
  ; calculate which is larger
  mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(gdd_avg, data_wgt, 1.0, 0)
  sd = stddev(gdd_avg)
  res@gsnLeftString = var+" MON avg, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot2(16) = gsn_csm_contour_map_ce(wks1, gdd_avg, res)
  delete(aavg)
  delete(sd)

  stats = stat_dispersion(gdd_ann_avg, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)
  ; calculate which is larger
  mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(gdd_ann_avg, data_wgt, 1.0, 0)
  sd = stddev(gdd_ann_avg)
  res@gsnLeftString = var+" ANN avg, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot2(17) = gsn_csm_contour_map_ce(wks1, gdd_ann_avg, res)
  delete(aavg)
  delete(sd)
  delete([/stats, dmin, dmax, mmin, mmax, mnmxint, res@cnMinLevelValF, res@cnMaxLevelValF, res@cnLevelSpacingF, season0, season1, season/])
  
  ; variance
  do n=0,11
    aavg = wgt_areaave_Wrap(gdd_mon_var(n,:,:), data_wgt, 1.0, 0)
    sd = stddev(gdd_mon_var(n,:,:))
    res@gsnLeftString = var+" "+mon(n)+" variance, ~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)

    stats = stat_dispersion(gdd_mon_var, False)
    dmin = stats(3)
    dmax = stats(13)
    mmin = stats(2)
    mmax = stats(14)

    ; calculate which is larger
    mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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

    res@cnMinLevelValF = mnmxint(0)
    res@cnMaxLevelValF = mnmxint(1)
    res@cnLevelSpacingF = mnmxint(2)

    plot3(n) = gsn_csm_contour_map_ce(wks1, gdd_mon_var(n,:,:), res)
    delete(aavg)
    delete(sd)
  end do

  ; append seasons into 1 large array
  season0 = array_append_record(gdd_DJF_var, gdd_MAM_var, 0)
  season1 = array_append_record(season0, gdd_JJA_var, 0)
  season =  array_append_record(season1, gdd_SON_var, 0)

  stats = stat_dispersion(season, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)

  ; calculate which is larger and use the same scale for all seasons
  mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(gdd_DJF_var, data_wgt, 1.0, 0)
  sd = stddev(gdd_DJF_var)
  res@gsnLeftString = var+" DJF variance, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot3(12) = gsn_csm_contour_map_ce(wks1, gdd_DJF_var, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(gdd_MAM_var, data_wgt, 1.0, 0)
  sd = stddev(gdd_MAM_var)
  res@gsnLeftString = var+" MAM variance, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot3(13) = gsn_csm_contour_map_ce(wks1, gdd_MAM_var, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(gdd_JJA_var, data_wgt, 1.0, 0)
  sd = stddev(gdd_JJA_var)
  res@gsnLeftString = var+" JJA variance, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot3(14) = gsn_csm_contour_map_ce(wks1, gdd_JJA_var, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(gdd_SON_var, data_wgt, 1.0, 0)
  sd = stddev(gdd_SON_var)
  res@gsnLeftString = var+" SON variance, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot3(15) = gsn_csm_contour_map_ce(wks1, gdd_SON_var, res)
  delete(aavg)
  delete(sd)

  stats = stat_dispersion(gdd_var, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)

  ; calculate which is larger and use the same scale for all seasons
  mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(gdd_var, data_wgt, 1.0, 0)
  sd = stddev(gdd_var)
  res@gsnLeftString = var+" MON variance, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot3(16) = gsn_csm_contour_map_ce(wks1, gdd_var, res)
  delete(aavg)
  delete(sd)

  stats = stat_dispersion(gdd_ann_var, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)

  ; calculate which is larger and use the same scale for all seasons
  mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)
  
  aavg = wgt_areaave_Wrap(gdd_ann_var, data_wgt, 1.0, 0)
  sd = stddev(gdd_ann_var)
  res@gsnLeftString = var+" ANN variance, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot3(17) = gsn_csm_contour_map_ce(wks1, gdd_ann_var, res)
  delete(aavg)
  delete(sd)
  delete([/stats, dmin, dmax, mmin, mmax, mnmxint, res@cnMinLevelValF, res@cnMaxLevelValF, res@cnLevelSpacingF, season0, season1, season/])

  units = gdd_ann_avg@units
; Panel plots
  resP                    = True
  resP@gsnPanelMainString = "GDD "+var+" average "+yrStrt+"-"+yrLast+"~C~"+info+" ("+units+")"
  resP@gsnPanelLabelBar = False
  resP@gsnMaximize = True
  gsn_panel(wks1, plot2, (/5, 4/), resP)
  resP@gsnPanelLabelBar = False
  resP@gsnPanelMainString = "GDD "+var+" variance "+yrStrt+"-"+yrLast+"~C~"+info
  gsn_panel(wks1, plot3, (/5, 4/), resP)

; rcm avg
  do n=0,11
    aavg = wgt_areaave_Wrap(rcm_mon_avg(n,:,:), data_wgt, 1.0, 0)
    sd = stddev(rcm_mon_avg(n,:,:))
    res@gsnLeftString = var+" "+mon(n)+" avg, ~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)

    stats = stat_dispersion(rcm_mon_avg, False)
    dmin = stats(3)
    dmax = stats(13)
    mmin = stats(2)
    mmax = stats(14)

    ; calculate which is larger
    mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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

    res@cnMinLevelValF = mnmxint(0)
    res@cnMaxLevelValF = mnmxint(1)
    res@cnLevelSpacingF = mnmxint(2)
    plot4(n) = gsn_csm_contour_map_ce(wks2, rcm_mon_avg(n,:,:), res)
    delete(aavg)
    delete(sd)
  end do

  ; append seasons into 1 large array
  season0 = array_append_record(rcm_DJF_avg, rcm_MAM_avg, 0)
  season1 = array_append_record(season0, rcm_JJA_avg, 0)
  season =  array_append_record(season1, rcm_SON_avg, 0)

  stats = stat_dispersion(season, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)

  ; calculate which is larger and use the same scale for all seasons
  mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_DJF_avg, data_wgt, 1.0, 0)
  sd = stddev(rcm_DJF_avg)
  res@gsnLeftString = var+" DJF avg, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot4(12) = gsn_csm_contour_map_ce(wks2, rcm_DJF_avg, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(rcm_MAM_avg, data_wgt, 1.0, 0)
  sd = stddev(rcm_MAM_avg)
  res@gsnLeftString = var+" MAM avg, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot4(13) = gsn_csm_contour_map_ce(wks2, rcm_MAM_avg, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(rcm_JJA_avg, data_wgt, 1.0, 0)
  sd = stddev(rcm_JJA_avg)
  res@gsnLeftString = var+" JJA avg, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot4(14) = gsn_csm_contour_map_ce(wks2, rcm_JJA_avg, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(rcm_SON_avg, data_wgt, 1.0, 0)
  sd = stddev(rcm_SON_avg)
  res@gsnLeftString = var+" SON avg, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot4(15) = gsn_csm_contour_map_ce(wks2, rcm_SON_avg, res)
  delete(aavg)
  delete(sd)

  stats = stat_dispersion(rcm_avg, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)
  ; calculate which is larger
  mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_avg, data_wgt, 1.0, 0)
  sd = stddev(rcm_avg)
  res@gsnLeftString = var+" MON avg, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot4(16) = gsn_csm_contour_map_ce(wks2, rcm_avg, res)
  delete(aavg)
  delete(sd)

  stats = stat_dispersion(rcm_ann_avg, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)
  ; calculate which is larger
  mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_ann_avg, data_wgt, 1.0, 0)
  sd = stddev(rcm_ann_avg)
  res@gsnLeftString = var+" ANN avg, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot4(17) = gsn_csm_contour_map_ce(wks2, rcm_ann_avg, res)
  delete(aavg)
  delete(sd)
  delete([/stats, dmin, dmax, mmin, mmax, mnmxint, res@cnMinLevelValF, res@cnMaxLevelValF, res@cnLevelSpacingF, season0, season1, season/])
  
; rcm variance
  do n=0,11
    aavg = wgt_areaave_Wrap(rcm_mon_var(n,:,:), data_wgt, 1.0, 0)
    sd = stddev((rcm_mon_var(n,:,:)))
    res@gsnLeftString = var+" "+mon(n)+" variance, ~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)

    stats = stat_dispersion(rcm_mon_var, False)
    dmin = stats(3)
    dmax = stats(13)
    mmin = stats(2)
    mmax = stats(14)

    ; calculate which is larger
    mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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

    res@cnMinLevelValF = mnmxint(0)
    res@cnMaxLevelValF = mnmxint(1)
    res@cnLevelSpacingF = mnmxint(2)

    plot5(n) = gsn_csm_contour_map_ce(wks2, rcm_mon_var(n,:,:), res)
    delete(aavg)
    delete(sd)
  end do

  ; append seasons into 1 large array
  season0 = array_append_record(rcm_DJF_var, rcm_MAM_var, 0)
  season1 = array_append_record(season0, rcm_JJA_var, 0)
  season =  array_append_record(season1, rcm_SON_var, 0)

  stats = stat_dispersion(season, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)

  ; calculate which is larger and use the same scale for all seasons
  mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_DJF_var, data_wgt, 1.0, 0)
  sd = stddev(rcm_DJF_var)
  res@gsnLeftString = var+" DJF variance, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot5(12) = gsn_csm_contour_map_ce(wks2, rcm_DJF_var, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(rcm_MAM_var, data_wgt, 1.0, 0)
  sd = stddev(rcm_MAM_var)
  res@gsnLeftString = var+" MAM variance, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot5(13) = gsn_csm_contour_map_ce(wks2, rcm_MAM_var, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(rcm_JJA_var, data_wgt, 1.0, 0)
  sd = stddev(rcm_JJA_var)
  res@gsnLeftString = var+" JJA variance, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot5(14) = gsn_csm_contour_map_ce(wks2, rcm_JJA_var, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(rcm_SON_var, data_wgt, 1.0, 0)
  sd = stddev(rcm_SON_var)
  res@gsnLeftString = var+" SON variance, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot5(15) = gsn_csm_contour_map_ce(wks2, rcm_SON_var, res)
  delete(aavg)
  delete(sd)

  stats = stat_dispersion(rcm_var, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)
  ; calculate which is larger
  mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_var, data_wgt, 1.0, 0)
  sd = stddev(rcm_var)
  res@gsnLeftString = var+" MON variance, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot5(16) = gsn_csm_contour_map_ce(wks2, rcm_var, res)
  delete(aavg)
  delete(sd)

  stats = stat_dispersion(rcm_ann_var, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)
  ; calculate which is larger
  mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)

  aavg = wgt_areaave_Wrap(rcm_ann_var, data_wgt, 1.0, 0)
  sd = stddev(rcm_ann_var)
  res@gsnLeftString = var+" ANN variance, ~C~AA="+ sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot5(17) = gsn_csm_contour_map_ce(wks2, rcm_ann_var, res)
  delete(aavg)
  delete(sd)
  delete([/stats, dmin, dmax, mmin, mmax, mnmxint, res@cnMinLevelValF, res@cnMaxLevelValF, res@cnLevelSpacingF, season0, season1, season/])
  units = rcm_ann_avg@units

; Panel plots
  resP                    = True
  resP@gsnPanelMainString = "RCM. "+var+" average "+yrStrt+"-"+yrLast+"~C~"+info+" ("+units+")"
  resP@gsnPanelLabelBar = False
  resP@gsnMaximize = True
  gsn_panel(wks2, plot4, (/5, 4/), resP)
  resP@gsnPanelLabelBar = False
  resP@gsnPanelMainString = "RCM. "+var+" variance "+yrStrt+"-"+yrLast+"~C~"+info
  gsn_panel(wks2, plot5, (/5, 4/), resP)
end