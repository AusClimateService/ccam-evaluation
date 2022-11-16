; plot climpact variables

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
  rad    = 4.0*atan(1.0)/180.0
  re     = 6371220.0
  rr     = re*rad

  ; obs 
  ;of = addfile("/g/data/xv83/bxn599/CaRSA/climpact_agcd/climpact_output_"+yrStrt+"-"+yrLast+"/"+var+"_MON"+fileo, "r")
  ;obs = of->$var$

  ; land sea mask file (AWAP grid)
  f2 = addfile("/scratch/e53/mxt599/esci/sftrf_AWAP0.05_NRMv3.nc", "r")
  lsmask = f2->AUS

  f=addfile("../calculated/climpact_output_"+yrStrt+"-"+yrLast+"/"+var+"_MON"+filen, "r")
  g=addfile("../calculated/climpact_output_"+yrStrt+"-"+yrLast+"/"+var+"_ANN"+filen, "r")

  data = f->$var$
  data_ann = g->$var$
  units = data@units

  data!1 = "lat"
  data!2 = "lon"
  data_ann!1 = "lat"
  data_ann!2 = "lon"

  ; select aus region
  data_aus = data(:,{-44.5:-10},{112:156.25})
  data_ann_aus = data_ann(:,{-44.5:-10},{112:156.25})
  delete(data)
  delete(data_ann)

  ; regrid data to obs grid
  print("Regridding")
  newlat = fspan(-44.5, -10., dimsizes(lsmask&lat)) ; 691
  newlon = fspan(112., 156.25, dimsizes(lsmask&lon)) ; 886
  newlat@units = "degrees_north"
  newlon@units = "degrees_east"

  data_regrid = linint2_Wrap(data_aus&lon, data_aus&lat, data_aus, False, newlon, newlat, 0)
  data_regrid!1   ="lat"
  data_regrid!2   = "lon"
  data_regrid&lat = newlat
  data_regrid&lon = newlon
  delete(data_aus)
  data = data_regrid
  delete(data_regrid)

  data_ann_regrid = linint2_Wrap(data_ann_aus&lon, data_ann_aus&lat, data_ann_aus, False, newlon, newlat, 0)
  data_ann_regrid!1   ="lat"
  data_ann_regrid!2   = "lon"
  data_ann_regrid&lat = newlat
  data_ann_regrid&lon = newlon
  delete(data_ann_aus)
  data_ann = data_ann_regrid
  delete(data_ann_regrid)

  print("Finished interpolation, masking data")
  data_mask = data
  data_mask = mask(data, conform(data, lsmask, (/1, 2/)), 1)
  delete(data)
  data = data_mask
  delete(data_mask)

  data_ann_mask = data_ann
  data_ann_mask = mask(data_ann, conform(data_ann, lsmask, (/1, 2/)), 1)
  delete(data_ann)
  data_ann = data_ann_mask
  delete(data_ann_mask)

  ; area average for time series
  lat = data&lat
  lon = data&lon
  nlat = dimsizes(lat)

  dlon   = abs(lon(2)-lon(1))*rr
  dx     = dlon*cos(lat*rad)
  dy     = new (nlat, typeof(dx))
  dy(0)  = abs(lat(2)-lat(1))*rr
  dy(1:nlat-2)  = abs(lat(2:nlat-1)-lat(0:nlat-3))*rr*0.5   
  dy(nlat-1)    = abs(lat(nlat-1)-lat(nlat-2))*rr

  data_wgt = dx*dy

  data_area_avg = wgt_areaave_Wrap(data, data_wgt, 1.0, 0)
  data_area_avg_std = stddev(data_area_avg)
  data_time_avg = dim_avg_n_Wrap(data, 0)

  data_dims = dimsizes(data(0::12,:,:))

  data_mon = new((/12, data_dims(0), data_dims(1), data_dims(2)/),typeof(data))
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

  data_mon(0,:,:,:) = data(0::12,:,:)
  data_mon(1,:,:,:) = data(1::12,:,:)
  data_mon(2,:,:,:) = data(2::12,:,:)
  data_mon(3,:,:,:) = data(3::12,:,:)
  data_mon(4,:,:,:) = data(4::12,:,:)
  data_mon(5,:,:,:) = data(5::12,:,:)
  data_mon(6,:,:,:) = data(6::12,:,:)
  data_mon(7,:,:,:) = data(7::12,:,:)
  data_mon(8,:,:,:) = data(8::12,:,:)
  data_mon(9,:,:,:) = data(9::12,:,:)
  data_mon(10,:,:,:) = data(10::12,:,:)
  data_mon(11,:,:,:) = data(11::12,:,:)

  data_mon_avg = dim_avg_n_Wrap(data_mon, 1)
  data_mon_area_avg = wgt_areaave_Wrap(data_mon, data_wgt, 1.0, 0)
  data_mon_area_avg_std = dim_stddev_n_Wrap(data_mon_area_avg, 1)

  data_ann_area_avg = wgt_areaave_Wrap(data_ann, data_wgt, 1.0, 0)
  data_ann_area_avg_std = stddev(data_ann_area_avg)
  data_ann_time_avg = dim_avg_n_Wrap(data_ann, 0)

; calculate seasonal
  data_DJF = month_to_season(data, "DJF")
  data_DJF_avg = dim_avg_n_Wrap(data_DJF, 0)
  data_DJF_area_avg = wgt_areaave_Wrap(data_DJF, data_wgt, 1.0, 0)
  data_DJF_area_avg_std = stddev(data_DJF_area_avg)
  data_MAM = month_to_season(data, "MAM")
  data_MAM_avg = dim_avg_n_Wrap(data_MAM, 0)
  data_MAM_area_avg = wgt_areaave_Wrap(data_MAM, data_wgt, 1.0, 0)
  data_MAM_area_avg_std = stddev(data_MAM_area_avg)
  data_JJA = month_to_season(data, "JJA")
  data_JJA_avg = dim_avg_n_Wrap(data_JJA, 0)
  data_JJA_area_avg = wgt_areaave_Wrap(data_JJA, data_wgt, 1.0, 0)
  data_JJA_area_avg_std = stddev(data_JJA_area_avg)
  data_SON = month_to_season(data, "SON")
  data_SON_avg = dim_avg_n_Wrap(data_SON, 0)
  data_SON_area_avg = wgt_areaave_Wrap(data_SON, data_wgt, 1.0, 0)
  data_SON_area_avg_std = stddev(data_SON_area_avg)

; generate x-axis for time series
  data_date = cd_calendar(data&time, -1)
  data_ann_date = cd_calendar(data_ann&time, -1)/100
  xaxis = yyyymm_to_yyyyfrac(data_date, 0)
  xaxis_ann = data_ann_date

; calculate regression
  rc_mon = new(dimsizes(data_mon_area_avg(:,0)), double)
  rc_mon_data = new(dimsizes(data_mon_area_avg), double)
  yint_mon = new(dimsizes(data_mon_area_avg(:,0)), double)

  do nc = 0, 11
    rc_mon(nc) = regCoef(data_mon_area_avg&time, data_mon_area_avg(nc,:))
    yint_mon(nc) = rc_mon@yintercept
    rc_mon_data(nc,:) = rc_mon(nc)*data_mon_area_avg&time+yint_mon(nc)
  end do
    rc_mon = rc_mon*365
    rc_mon@units = data_mon_area_avg@units+"/year"

  rc_DJF = regCoef(data_DJF_area_avg&time, data_DJF_area_avg)
  rc_DJF_data = rc_DJF*data_DJF_area_avg&time+rc_DJF@yintercept
  rc_DJF = rc_DJF*365
  rc_DJF@units = data_DJF_area_avg@units+"/year"

  rc_MAM = regCoef(data_MAM_area_avg&time, data_MAM_area_avg)
  rc_MAM_data = rc_MAM*data_MAM_area_avg&time+rc_MAM@yintercept
  rc_MAM = rc_MAM*365
  rc_MAM@units = data_MAM_area_avg@units+"/year"

  rc_JJA = regCoef(data_JJA_area_avg&time, data_JJA_area_avg)
  rc_JJA_data = rc_JJA*data_JJA_area_avg&time+rc_JJA@yintercept
  rc_JJA = rc_JJA*365
  rc_JJA@units = data_JJA_area_avg@units+"/year"

  rc_SON = regCoef(data_SON_area_avg&time, data_SON_area_avg)
  rc_SON_data = rc_SON*data_SON_area_avg&time+rc_SON@yintercept
  rc_SON = rc_SON*365
  rc_SON@units = data_SON_area_avg@units+"/year"

  rc_ANN = regCoef(data_ann_area_avg&time, data_ann_area_avg)
  rc_ANN_data = rc_ANN*data_ann_area_avg&time+rc_ANN@yintercept
  rc_ANN = rc_ANN*365
  rc_ANN@units = data_ann_area_avg@units+"/year"

  rc_MON = regCoef(data_area_avg&time, data_area_avg)
  rc_MON_data = rc_MON*data_area_avg&time+rc_MON@yintercept
  rc_MON = rc_MON*365
  rc_MON@units = data_area_avg@units+"/year"

; plot
  plot_name = "../plots/"+run_name+"_climpact_"+var

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

  wks = gsn_open_wks("pdf", plot_name)
  plot0 = new(18, graphic)
  plot1 = new(18, graphic)
  regl = new(dimsizes(plot1), graphic)
  cmap_cmocean_balance = read_colormap_file("cmocean_balance")
  cmap_MPL_Reds = read_colormap_file("MPL_Reds")

if var.eq."prcptot".or.var.eq."r10mm".or.var.eq."r20mm".or.var.eq."r30mm".or.var.eq."rx1day".or.var.eq."rx5day".or.var.eq."rx7day" then
  res@cnFillPalette = cmap_cmocean_balance(::-1,:) ; reverse the colourmap
else
  res@cnFillPalette = cmap_cmocean_balance
end if
  
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

  do n=0,11
    aavg = wgt_areaave_Wrap(data_mon_avg(n,:,:), data_wgt, 1.0, 0)
    sd = stddev(data_mon_avg(n,:,:))
    res@gsnLeftString = var+" "+mon(n)+" avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
    plot0(n) = gsn_csm_contour_map_ce(wks, data_mon_avg(n,:,:), res)
    delete(aavg)
    delete(sd)
  end do

  aavg = wgt_areaave_Wrap(data_DJF_avg, data_wgt, 1.0, 0)
  sd = stddev(data_DJF_avg)
  res@gsnLeftString = var+" DJF avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot0(12) = gsn_csm_contour_map_ce(wks, data_DJF_avg, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(data_MAM_avg, data_wgt, 1.0, 0)
  sd = stddev(data_MAM_avg)
  res@gsnLeftString = var+" MAM avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot0(13) = gsn_csm_contour_map_ce(wks, data_MAM_avg, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(data_JJA_avg, data_wgt, 1.0, 0)
  sd = stddev(data_JJA_avg)
  res@gsnLeftString = var+" JJA avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot0(14) = gsn_csm_contour_map_ce(wks, data_JJA_avg, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(data_SON_avg, data_wgt, 1.0, 0)
  sd = stddev(data_SON_avg)
  res@gsnLeftString = var+" SON avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot0(15) = gsn_csm_contour_map_ce(wks, data_SON_avg, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(data_time_avg, data_wgt, 1.0, 0)
  sd = stddev(data_time_avg)
  res@gsnLeftString = var+" MON avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot0(16) = gsn_csm_contour_map_ce(wks, data_time_avg, res)
  delete(aavg)
  delete(sd)

  aavg = wgt_areaave_Wrap(data_ann_time_avg, data_wgt, 1.0, 0)
  sd = stddev(data_ann_time_avg)
  res@gsnLeftString = var+" ANN avg,~C~AA="+sprintf("%5.4f", aavg)+", SD="+sprintf("%5.4f", sd)
  plot0(17) = gsn_csm_contour_map_ce(wks, data_ann_time_avg, res)
  delete(aavg)
  delete(sd)

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
  resxy@xyLineColor = (/"black"/)
  resxy@gsnLeftString = ""

  rline = True
  rline@gsLineColor       = "red" ;73
  rline@gsLineDashPattern = 0
  rline@gsLineThicknessF  = 4

  do n=0,11
    resxy@tiYAxisString = var+" "+mon(n)
    resxy@gsnLeftString = "SD="+sprintf("%5.4f", data_mon_area_avg_std(n))+", RC="+sprintf("%5.4f", rc_mon(n))
    plot1(n) = gsn_csm_xy(wks, xaxis_ann, data_mon_area_avg(n,:), resxy)
    regl(n) = gsn_add_polyline(wks, plot1(n), xaxis_ann, rc_mon_data(n,:), rline)
  end do

  resxy@tiYAxisString = var+" DJF"
  resxy@gsnLeftString = "SD="+sprintf("%5.4f", data_DJF_area_avg_std)+", RC="+sprintf("%5.4f", rc_DJF)
  plot1(12) = gsn_csm_xy(wks, xaxis_ann, data_DJF_area_avg, resxy)
  regl(12) = gsn_add_polyline(wks, plot1(12), xaxis_ann, rc_DJF_data, rline)

  resxy@tiYAxisString = var+" MAM"
  resxy@gsnLeftString = "SD="+sprintf("%5.4f", data_MAM_area_avg_std)+", RC="+sprintf("%5.4f", rc_MAM)
  plot1(13) = gsn_csm_xy(wks, xaxis_ann, data_MAM_area_avg, resxy)
  regl(13) = gsn_add_polyline(wks, plot1(13), xaxis_ann, rc_MAM_data, rline)

  resxy@tiYAxisString = var+" JJA"
  resxy@gsnLeftString = "SD="+sprintf("%5.4f", data_JJA_area_avg_std)+", RC="+sprintf("%5.4f", rc_JJA)
  plot1(14) = gsn_csm_xy(wks, xaxis_ann, data_JJA_area_avg, resxy)
  regl(14) = gsn_add_polyline(wks, plot1(14), xaxis_ann, rc_JJA_data, rline)

  resxy@tiYAxisString = var+" SON"
  resxy@gsnLeftString = "SD="+sprintf("%5.4f", data_SON_area_avg_std)+", RC="+sprintf("%5.4f", rc_SON)
  plot1(15) = gsn_csm_xy(wks, xaxis_ann, data_SON_area_avg, resxy)
  regl(15) = gsn_add_polyline(wks, plot1(15), xaxis_ann, rc_SON_data, rline)

  resxy@tiYAxisString = var+" MON"
  resxy@gsnLeftString = "SD="+sprintf("%5.4f", data_area_avg_std)+", RC="+sprintf("%5.4f", rc_MON)
  plot1(16) = gsn_csm_xy(wks, xaxis, data_area_avg, resxy)
  regl(16) = gsn_add_polyline(wks, plot1(16), xaxis, rc_MON_data, rline)

  resxy@tiYAxisString = var+" ANN"
  resxy@gsnLeftString = "SD="+sprintf("%5.4f", data_ann_area_avg_std)+", RC="+sprintf("%5.4f", rc_ANN)
  plot1(17) = gsn_csm_xy(wks, xaxis_ann, data_ann_area_avg, resxy)
  regl(17) = gsn_add_polyline(wks, plot1(17), xaxis_ann, rc_ANN_data, rline)

; Panel plots
  resP                    = True
  resP@gsnPanelMainString = run_name+" "+var+" "+yrStrt+"-"+yrLast+"~C~"+info+" ("+units+")"
  resP@gsnPanelLabelBar = False
  resP@gsnMaximize = True
  gsn_panel(wks, plot0, (/5, 4/), resP)
  resP@gsnPanelLabelBar = False
  resP@gsnPanelMainString = run_name+" "+var+" Aus area avg. "+yrStrt+"-"+yrLast+"~C~"+info+" ("+units+")"
  gsn_panel(wks, plot1, (/5, 4/), resP)
end