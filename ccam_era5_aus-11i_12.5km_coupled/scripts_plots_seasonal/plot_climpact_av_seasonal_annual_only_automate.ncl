; plot climpact Added Value (AV)

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
  rad    = 4.0*atan(1.0)/180.0
  re     = 6371220.0
  rr     = re*rad

  f0=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_JAN_added_value.nc", "r")
  f1=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_FEB_added_value.nc", "r")
  f2=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_MAR_added_value.nc", "r")
  f3=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_APR_added_value.nc", "r")
  f4=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_MAY_added_value.nc", "r")
  f5=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_JUN_added_value.nc", "r")
  f6=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_JUL_added_value.nc", "r")
  f7=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_AUG_added_value.nc", "r")
  f8=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_SEP_added_value.nc", "r")
  f9=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_OCT_added_value.nc", "r")
  f10=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_NOV_added_value.nc", "r")
  f11=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_DEC_added_value.nc", "r")
  f12=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_DJF_added_value.nc", "r")
  f13=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_MAM_added_value.nc", "r")
  f14=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_JJA_added_value.nc", "r")
  f15=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_SON_added_value.nc", "r")
  f16=addfile("../calculated/"+run_name+"_"+yrStrt+"-"+yrLast+"_climpact_"+var+"_ANN_added_value.nc", "r")

  av_JAN_avg = f0->av_JAN_avg
  av_JAN_var = f0->av_JAN_var
  av_JAN_99p = f0->av_JAN_99p
  av_JAN_01p = f0->av_JAN_01p

  av_FEB_avg = f1->av_FEB_avg
  av_FEB_var = f1->av_FEB_var
  av_FEB_99p = f1->av_FEB_99p
  av_FEB_01p = f1->av_FEB_01p

  av_MAR_avg = f2->av_MAR_avg
  av_MAR_var = f2->av_MAR_var
  av_MAR_99p = f2->av_MAR_99p
  av_MAR_01p = f2->av_MAR_01p

  av_APR_avg = f3->av_APR_avg
  av_APR_var = f3->av_APR_var
  av_APR_99p = f3->av_APR_99p
  av_APR_01p = f3->av_APR_01p

  av_MAY_avg = f4->av_MAY_avg
  av_MAY_var = f4->av_MAY_var
  av_MAY_99p = f4->av_MAY_99p
  av_MAY_01p = f4->av_MAY_01p

  av_JUN_avg = f5->av_JUN_avg
  av_JUN_var = f5->av_JUN_var
  av_JUN_99p = f5->av_JUN_99p
  av_JUN_01p = f5->av_JUN_01p

  av_JUL_avg = f6->av_JUL_avg
  av_JUL_var = f6->av_JUL_var
  av_JUL_99p = f6->av_JUL_99p
  av_JUL_01p = f6->av_JUL_01p

  av_AUG_avg = f7->av_AUG_avg
  av_AUG_var = f7->av_AUG_var
  av_AUG_99p = f7->av_AUG_99p
  av_AUG_01p = f7->av_AUG_01p

  av_SEP_avg = f8->av_SEP_avg
  av_SEP_var = f8->av_SEP_var
  av_SEP_99p = f8->av_SEP_99p
  av_SEP_01p = f8->av_SEP_01p

  av_OCT_avg = f9->av_OCT_avg
  av_OCT_var = f9->av_OCT_var
  av_OCT_99p = f9->av_OCT_99p
  av_OCT_01p = f9->av_OCT_01p

  av_NOV_avg = f10->av_NOV_avg
  av_NOV_var = f10->av_NOV_var
  av_NOV_99p = f10->av_NOV_99p
  av_NOV_01p = f10->av_NOV_01p

  av_DEC_avg = f11->av_DEC_avg
  av_DEC_var = f11->av_DEC_var
  av_DEC_99p = f11->av_DEC_99p
  av_DEC_01p = f11->av_DEC_01p

  av_DJF_avg = f12->av_DJF_avg
  av_DJF_var = f12->av_DJF_var
  av_DJF_99p = f12->av_DJF_99p
  av_DJF_01p = f12->av_DJF_01p

  av_MAM_avg = f13->av_MAM_avg
  av_MAM_var = f13->av_MAM_var
  av_MAM_99p = f13->av_MAM_99p
  av_MAM_01p = f13->av_MAM_01p

  av_JJA_avg = f14->av_JJA_avg
  av_JJA_var = f14->av_JJA_var
  av_JJA_99p = f14->av_JJA_99p
  av_JJA_01p = f14->av_JJA_01p

  av_SON_avg = f15->av_SON_avg
  av_SON_var = f15->av_SON_var
  av_SON_99p = f15->av_SON_99p
  av_SON_01p = f15->av_SON_01p

  av_ANN_avg = f16->av_ANN_avg
  av_ANN_var = f16->av_ANN_var
  av_ANN_99p = f16->av_ANN_99p
  av_ANN_01p = f16->av_ANN_01p

  data_dims = dimsizes(av_ANN_avg)

  data_mon_avg = new((/12, data_dims(0), data_dims(1)/), typeof(av_JAN_avg))
  data_mon_var = new((/12, data_dims(0), data_dims(1)/), typeof(av_JAN_var))
  data_mon_99p = new((/12, data_dims(0), data_dims(1)/), typeof(av_JAN_99p))
  data_mon_01p = new((/12, data_dims(0), data_dims(1)/), typeof(av_JAN_01p))

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

  data_mon_avg(0,:,:) = av_JAN_avg
  data_mon_avg(1,:,:) = av_FEB_avg
  data_mon_avg(2,:,:) = av_MAR_avg
  data_mon_avg(3,:,:) = av_APR_avg
  data_mon_avg(4,:,:) = av_MAY_avg
  data_mon_avg(5,:,:) = av_JUN_avg
  data_mon_avg(6,:,:) = av_JUL_avg
  data_mon_avg(7,:,:) = av_AUG_avg
  data_mon_avg(8,:,:) = av_SEP_avg
  data_mon_avg(9,:,:) = av_OCT_avg
  data_mon_avg(10,:,:) = av_NOV_avg
  data_mon_avg(11,:,:) = av_DEC_avg

  data_mon_var(0,:,:) = av_JAN_var
  data_mon_var(1,:,:) = av_FEB_var
  data_mon_var(2,:,:) = av_MAR_var
  data_mon_var(3,:,:) = av_APR_var
  data_mon_var(4,:,:) = av_MAY_var
  data_mon_var(5,:,:) = av_JUN_var
  data_mon_var(6,:,:) = av_JUL_var
  data_mon_var(7,:,:) = av_AUG_var
  data_mon_var(8,:,:) = av_SEP_var
  data_mon_var(9,:,:) = av_OCT_var
  data_mon_var(10,:,:) = av_NOV_var
  data_mon_var(11,:,:) = av_DEC_var

  data_mon_99p(0,:,:) = av_JAN_99p
  data_mon_99p(1,:,:) = av_FEB_99p
  data_mon_99p(2,:,:) = av_MAR_99p
  data_mon_99p(3,:,:) = av_APR_99p
  data_mon_99p(4,:,:) = av_MAY_99p
  data_mon_99p(5,:,:) = av_JUN_99p
  data_mon_99p(6,:,:) = av_JUL_99p
  data_mon_99p(7,:,:) = av_AUG_99p
  data_mon_99p(8,:,:) = av_SEP_99p
  data_mon_99p(9,:,:) = av_OCT_99p
  data_mon_99p(10,:,:) = av_NOV_99p
  data_mon_99p(11,:,:) = av_DEC_99p

  data_mon_01p(0,:,:) = av_JAN_01p
  data_mon_01p(1,:,:) = av_FEB_01p
  data_mon_01p(2,:,:) = av_MAR_01p
  data_mon_01p(3,:,:) = av_APR_01p
  data_mon_01p(4,:,:) = av_MAY_01p
  data_mon_01p(5,:,:) = av_JUN_01p
  data_mon_01p(6,:,:) = av_JUL_01p
  data_mon_01p(7,:,:) = av_AUG_01p
  data_mon_01p(8,:,:) = av_SEP_01p
  data_mon_01p(9,:,:) = av_OCT_01p
  data_mon_01p(10,:,:) = av_NOV_01p
  data_mon_01p(11,:,:) = av_DEC_01p

; plot
  plot_name0 = "../plots_seasonal/"+run_name+"_climpact_"+var+"_avg_added_value_seasonal_annual_only"
  plot_name1 = "../plots_seasonal/"+run_name+"_climpact_"+var+"_var_added_value_seasonal_annual_only"
;  plot_name2 = "../plots_seasonal/"+run_name+"_climpact_"+var+"_99p_added_value_seasonal_annual_only"
;  plot_name3 = "../plots_seasonal/"+run_name+"_climpact_"+var+"_01p_added_value_seasonal_annual_only"

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

  wks0 = gsn_open_wks("pdf", plot_name0) ; average
  wks1 = gsn_open_wks("pdf", plot_name1) ; variance
;  wks2 = gsn_open_wks("pdf", plot_name2) ; 99 percentile
;  wks3 = gsn_open_wks("pdf", plot_name3) ; 01 percentile

  plot0 = new(17, graphic)
  plot1 = new(17, graphic)
;  plot2 = new(17, graphic)
;  plot3 = new(17, graphic)
  cmap_cmocean_balance = read_colormap_file("cmocean_balance")
  cmap_MPL_Reds = read_colormap_file("MPL_Reds")
  res@cnFillPalette = cmap_cmocean_balance
  
; area weights
  lat = data_mon_avg&lat
  lon = data_mon_avg&lon
  nlat = dimsizes(lat)

  dlon   = abs(lon(2)-lon(1))*rr
  dx     = dlon*cos(lat*rad)
  dy     = new (nlat, typeof(dx))
  dy(0)  = abs(lat(2)-lat(1))*rr
  dy(1:nlat-2)  = abs(lat(2:nlat-1)-lat(0:nlat-3))*rr*0.5   
  dy(nlat-1)    = abs(lat(nlat-1)-lat(nlat-2))*rr

  data_wgt = dx*dy

; average
  do n=0,11
    aavg = wgt_areaave_Wrap(data_mon_avg(n,:,:), data_wgt, 1.0, 0)
    sd = stddev(data_mon_avg(n,:,:))
    tp = num(.not.ismissing(data_mon_avg(n,:,:)))
    pp = num(where(data_mon_avg(n,:,:).gt.0, 1, 0))
    np = num(where(data_mon_avg(n,:,:).lt.0, 1, 0))
    res@gsnLeftString = var+" "+mon(n)+" avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np

    stats = stat_dispersion(data_mon_avg, False)
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

    plot0(n) = gsn_csm_contour_map_ce(wks0, data_mon_avg(n,:,:), res)
    delete(aavg)
    delete(sd)
    delete([/tp, pp, np/])
  end do

  ; append seasons into 1 large array
  season0 = array_append_record(av_DJF_avg, av_MAM_avg, 0)
  season1 = array_append_record(season0, av_JJA_avg, 0)
  season =  array_append_record(season1, av_SON_avg, 0)

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

  aavg = wgt_areaave_Wrap(av_DJF_avg, data_wgt, 1.0, 0)
  sd = stddev(av_DJF_avg)
  tp = num(.not.ismissing(av_DJF_avg))
  pp = num(where(av_DJF_avg.gt.0, 1, 0))
  np = num(where(av_DJF_avg.lt.0, 1, 0))
  res@gsnLeftString = var+" DJF avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(12) = gsn_csm_contour_map_ce(wks0, av_DJF_avg, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  aavg = wgt_areaave_Wrap(av_MAM_avg, data_wgt, 1.0, 0)
  sd = stddev(av_MAM_avg)
  tp = num(.not.ismissing(av_MAM_avg))
  pp = num(where(av_MAM_avg.gt.0, 1, 0))
  np = num(where(av_MAM_avg.lt.0, 1, 0))
  res@gsnLeftString = var+" MAM avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(13) = gsn_csm_contour_map_ce(wks0, av_MAM_avg, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  aavg = wgt_areaave_Wrap(av_JJA_avg, data_wgt, 1.0, 0)
  sd = stddev(av_JJA_avg)
  tp = num(.not.ismissing(av_JJA_avg))
  pp = num(where(av_JJA_avg.gt.0, 1, 0))
  np = num(where(av_JJA_avg.lt.0, 1, 0))
  res@gsnLeftString = var+" JJA avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(14) = gsn_csm_contour_map_ce(wks0, av_JJA_avg, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  aavg = wgt_areaave_Wrap(av_SON_avg, data_wgt, 1.0, 0)
  sd = stddev(av_SON_avg)
  tp = num(.not.ismissing(av_SON_avg))
  pp = num(where(av_SON_avg.gt.0, 1, 0))
  np = num(where(av_SON_avg.lt.0, 1, 0))
  res@gsnLeftString = var+" SON avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(15) = gsn_csm_contour_map_ce(wks0, av_SON_avg, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  stats = stat_dispersion(av_ANN_avg, False)
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

  aavg = wgt_areaave_Wrap(av_ANN_avg, data_wgt, 1.0, 0)
  sd = stddev(av_ANN_avg)
  tp = num(.not.ismissing(av_ANN_avg))
  pp = num(where(av_ANN_avg.gt.0, 1, 0))
  np = num(where(av_ANN_avg.lt.0, 1, 0))
  res@gsnLeftString = var+" ANN avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot0(16) = gsn_csm_contour_map_ce(wks0, av_ANN_avg, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  ; Panel plots
  resP                    = True
  resP@gsnPanelMainString = run_name+" "+var+" "+yrStrt+"-"+yrLast+"~C~average added value"+"~C~"+info
  resP@gsnPanelLabelBar = False
  resP@gsnMaximize = True
  resP@gsnPanelMainFontHeightF = 0.01
  gsn_panel(wks0, plot0(12:16), (/1, 5/), resP)
  delete(wks0)

; variance
  do n=0,11
    aavg = wgt_areaave_Wrap(data_mon_var(n,:,:), data_wgt, 1.0, 0)
    sd = stddev(data_mon_var(n,:,:))
    tp = num(.not.ismissing(data_mon_var(n,:,:)))
    pp = num(where(data_mon_var(n,:,:).gt.0, 1, 0))
    np = num(where(data_mon_var(n,:,:).lt.0, 1, 0))
    res@gsnLeftString = var+" "+mon(n)+" var,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np

    stats = stat_dispersion(data_mon_var, False)
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

    plot1(n) = gsn_csm_contour_map_ce(wks1, data_mon_var(n,:,:), res)
    delete(aavg)
    delete(sd)
    delete([/tp, pp, np/])
  end do

  ; append seasons into 1 large array
  delete([/season0, season1, season/])
  season0 = array_append_record(av_DJF_var, av_MAM_var, 0)
  season1 = array_append_record(season0, av_JJA_var, 0)
  season =  array_append_record(season1, av_SON_var, 0)

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

  aavg = wgt_areaave_Wrap(av_DJF_var, data_wgt, 1.0, 0)
  sd = stddev(av_DJF_var)
  tp = num(.not.ismissing(av_DJF_var))
  pp = num(where(av_DJF_var.gt.0, 1, 0))
  np = num(where(av_DJF_var.lt.0, 1, 0))
  res@gsnLeftString = var+" DJF var,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(12) = gsn_csm_contour_map_ce(wks1, av_DJF_var, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  aavg = wgt_areaave_Wrap(av_MAM_var, data_wgt, 1.0, 0)
  sd = stddev(av_MAM_var)
  tp = num(.not.ismissing(av_MAM_var))
  pp = num(where(av_MAM_var.gt.0, 1, 0))
  np = num(where(av_MAM_var.lt.0, 1, 0))
  res@gsnLeftString = var+" MAM var,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(13) = gsn_csm_contour_map_ce(wks1, av_MAM_var, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  aavg = wgt_areaave_Wrap(av_JJA_var, data_wgt, 1.0, 0)
  sd = stddev(av_JJA_var)
  tp = num(.not.ismissing(av_JJA_var))
  pp = num(where(av_JJA_var.gt.0, 1, 0))
  np = num(where(av_JJA_var.lt.0, 1, 0))
  res@gsnLeftString = var+" JJA var,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(14) = gsn_csm_contour_map_ce(wks1, av_JJA_var, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  aavg = wgt_areaave_Wrap(av_SON_var, data_wgt, 1.0, 0)
  sd = stddev(av_SON_var)
  tp = num(.not.ismissing(av_SON_var))
  pp = num(where(av_SON_var.gt.0, 1, 0))
  np = num(where(av_SON_var.lt.0, 1, 0))
  res@gsnLeftString = var+" SON var,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(15) = gsn_csm_contour_map_ce(wks1, av_SON_var, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  stats = stat_dispersion(av_ANN_var, False)
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
  
  aavg = wgt_areaave_Wrap(av_ANN_var, data_wgt, 1.0, 0)
  sd = stddev(av_ANN_var)
  tp = num(.not.ismissing(av_ANN_var))
  pp = num(where(av_ANN_var.gt.0, 1, 0))
  np = num(where(av_ANN_var.lt.0, 1, 0))
  res@gsnLeftString = var+" ANN var,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)+"~C~PP="+pp+"/"+tp+", NP="+np
  plot1(16) = gsn_csm_contour_map_ce(wks1, av_ANN_var, res)
  delete(aavg)
  delete(sd)
  delete([/tp, pp, np/])

  ; Panel plots
  resP@gsnPanelMainString = run_name+" "+var+" "+yrStrt+"-"+yrLast+"~C~variance added value"+"~C~"+info
  gsn_panel(wks1, plot1(12:16), (/1, 5/), resP)
  delete(wks1)

; 99 percentile
;  do n=0,11
;    res@gsnLeftString = var+" "+mon(n)+" 99p"
;
;    stats = stat_dispersion(data_mon_99p, False)
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
;
;    res@cnMinLevelValF = mnmxint(0)
;    res@cnMaxLevelValF = mnmxint(1)
;    res@cnLevelSpacingF = mnmxint(2)
;
;    plot2(n) = gsn_csm_contour_map_ce(wks2, data_mon_99p(n,:,:), res)
;  end do
;
;  ; append seasons into 1 large array
;  delete([/season0, season1, season/])
;  season0 = array_append_record(av_DJF_99p, av_MAM_99p, 0)
;  season1 = array_append_record(season0, av_JJA_99p, 0)
;  season =  array_append_record(season1, av_SON_99p, 0)
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
;  res@gsnLeftString = var+" DJF 99p"
;  plot2(12) = gsn_csm_contour_map_ce(wks2, av_DJF_99p, res)
;
;  res@gsnLeftString = var+" MAM 99p"
;  plot2(13) = gsn_csm_contour_map_ce(wks2, av_MAM_99p, res)
;
;  res@gsnLeftString = var+" JJA 99p"
;  plot2(14) = gsn_csm_contour_map_ce(wks2, av_JJA_99p, res)
;
;  res@gsnLeftString = var+" SON 99p"
;  plot2(15) = gsn_csm_contour_map_ce(wks2, av_SON_99p, res)
;
;  stats = stat_dispersion(av_ANN_99p, False)
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
  ;
;  res@gsnLeftString = var+" ANN 99p"
;  plot2(16) = gsn_csm_contour_map_ce(wks2, av_ANN_99p, res)
;
;  ; Panel plots
;  resP@gsnPanelMainString = run_name+" "+var+" "+yrStrt+"-"+yrLast+"~C~99th percentile added value"+"~C~"+info
;  gsn_panel(wks2, plot2(12:16), (/1, 5/), resP)
;  delete(wks2)
;
;; 01 percentile
;  do n=0,11
;    res@gsnLeftString = var+" "+mon(n)+" 01p"
;
;    stats = stat_dispersion(data_mon_01p, False)
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
;
;    res@cnMinLevelValF = mnmxint(0)
;    res@cnMaxLevelValF = mnmxint(1)
;    res@cnLevelSpacingF = mnmxint(2)
    ;
;    plot3(n) = gsn_csm_contour_map_ce(wks3, data_mon_01p(n,:,:), res)
;  end do
;
;  ; append seasons into 1 large array
;  delete([/season0, season1, season/])
;  season0 = array_append_record(av_DJF_01p, av_MAM_01p, 0)
;  season1 = array_append_record(season0, av_JJA_01p, 0)
;  season =  array_append_record(season1, av_SON_01p, 0)
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
;  res@gsnLeftString = var+" DJF 01p"
;  plot3(12) = gsn_csm_contour_map_ce(wks3, av_DJF_01p, res)
;
;  res@gsnLeftString = var+" MAM 01p"
;  plot3(13) = gsn_csm_contour_map_ce(wks3, av_MAM_01p, res)
;
;  res@gsnLeftString = var+" JJA 01p"
;  plot3(14) = gsn_csm_contour_map_ce(wks3, av_JJA_01p, res)
;
;  res@gsnLeftString = var+" SON 01p"
;  plot3(15) = gsn_csm_contour_map_ce(wks3, av_SON_01p, res)
;
;  stats = stat_dispersion(av_ANN_01p, False)
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
  ;
;  res@gsnLeftString = var+" ANN 01p"
;  plot3(16) = gsn_csm_contour_map_ce(wks3, av_ANN_01p, res)
;
;  ; Panel plots
;  resP@gsnPanelMainString = run_name+" "+var+" "+yrStrt+"-"+yrLast+"~C~01th percentile added value"+"~C~"+info
;  gsn_panel(wks3, plot3(12:16), (/1, 5/), resP)
;  delete(wks3)
end