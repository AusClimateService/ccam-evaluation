; script to perform simple evaluations of CCAM output
; plots timeseries of raw, mean, min, max, stddev
; spatial plot of first time step

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
; temporary variables (clean up so ncl reads from command line arguments)
;  path="/scratch/e53/mxt599/cordex_aus_25km_coupled/daily_v6/"
;  var_path="tasmax_surf."
;  var="tasmax"
; temporary variables (clean up so ncl reads from command line arguments)

  rad    = 4.0*atan(1.0)/180.0
  re     = 6371220.0
  rr     = re*rad

  fl = systemfunc("ls "+path+var_path+"ccam_25.km.*.nc")

  f = addfiles(fl, "r")
  ListSetType(f, "cat")
  data = f[:]->$var$

  data_loc = data(:,0,0)
  data_avg = dim_avg_n_Wrap(data, (/1,2/))
  data_min = dim_min_n_Wrap(data, (/1,2/))
  data_max = dim_max_n_Wrap(data, (/1,2/))
  data_std = dim_stddev_n_Wrap(data, (/1,2/))

  data_map = data(0,:,:)

  time = data&time
  date = cd_calendar(time, 0)
  datedd = cd_calendar(time, -2)
  date_start = datedd(0)
  date_end = datedd(dimsizes(datedd)-1)
  year = date(:,0)
  year_start = min(year)
  year_end = max(year)

  xaxis = fspan(year_start, year_end, dimsizes(time))

  data_stats = new((/3, dimsizes(data_avg)/), float)
  data_stats(0,:) = data_min
  data_stats(1,:) = data_avg
  data_stats(2,:) = data_max

; plot resources
  res = True
  res@gsnSpreadColors      = True
  res@gsnMaximize          = False
  res@gsnFrame             = False
  res@gsnDraw              = False
  res@gsnAddCyclic         = False
  res@lbLabelBarOn         = True
  res@lbLabelAutoStride    = True
  res@gsnRightString       = ""
  res@tiYAxisString        = ""
  res@tiXAxisString        = ""
  res@lbOrientation        = "Horizontal"
  res@pmTickMarkDisplayMode= "Always"
  res@tmXBLabelDeltaF      = -0.5
  res@vpWidthF             = 0.6
  res@vpHeightF            = 0.55
  res@tiMainOffsetYF       = -0.01
  res@tmXBLabelsOn         = True
  res@tmXBTickSpacingF     = 10.0
  res@gsnLeftStringOrthogonalPosF = 0.03
  res@gsnLeftStringFontHeightF = 0.018
;  res@gsnRightStringOrthogonalPosF = -0.03
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnFillOn             = True
  res@cnLinesOn            = False
  res@cnLineLabelsOn       = False
  res@mpMinLatF = min(data_map&lat);-45.
  res@mpMaxLatF = max(data_map&lat);-10.
  res@mpMinLonF = min(data_map&lon);112.
  res@mpMaxLonF = max(data_map&lon);156.25
  res@mpCenterLonF = (max(data_map&lon) - min(data_map&lon))/2.
;  res@pmLabelBarOrthogonalPosF = 0.1
  res@trYReverse = True
  res@tmLabelAutoStride = True
  res@tmXTOn = False
  res@tmXBMinorOn = False
  res@tmYLLabelsOn = True
  res@tmXBLabelsOn = True
  res@lbLabelsOn = True
;  res@cnFillMode = "CellFill" ; for faster plotting
  cmap_cmocean_balance = read_colormap_file("cmocean_balance")
  res@cnFillPalette = cmap_cmocean_balance
  res@mpShapeMode = "FreeAspect"

; time series
  resxy                      = True
  resxy@gsnFrame             = False
  resxy@gsnDraw              = False
  resxy@gsnMaximize          = False
  resxy@xyMarkLineMode       = "Lines"
  resxy@xyMonoDashPattern    = True
  resxy@xyLineThicknessF     = 1.0
  ;resxy@gsnLeftStringFontHeightF = 0.025
  resxy@pmLegendDisplayMode    = "NoCreate"
  resxy@xyMonoLineColor       = True
  resxy@trXMinF = year_start
  resxy@trXMaxF = year_end
  resxy@xyMonoLineColor = True
  resxy@gsnLeftString = ""

  wks = gsn_open_wks("pdf", var+"_eval")
  plot = new(4, graphic)

  resxy@xyLineColor           = "DodgerBlue3"
  resxy@tiYAxisString = data_avg@units
  resxy@gsnLeftString = var+" at first grid point, "+date_start+"-"+date_end
  plot(0) = gsn_csm_xy(wks, xaxis, data_loc, resxy)

  resxy@xyMonoLineColor       = False
  resxy@xyLineColors = (/"orange", "DodgerBlue3", "ForestGreen"/)
  resxy@gsnLeftString = var+" mean/min/max, "+date_start+"-"+date_end
  plot(1) = gsn_csm_xy(wks, xaxis, data_stats, resxy)

  resxy@xyMonoLineColor       = True
  resxy@xyLineColor           = "DodgerBlue3"
  resxy@tiYAxisString = data_avg@units
  resxy@gsnLeftString = var+" stdev, "+date_start+"-"+date_end
  plot(2) = gsn_csm_xy(wks, xaxis, data_std, resxy)

  res@gsnLeftString = var+" at first timestep ("+data_map@units+"), "+date_start
  plot(3) = gsn_csm_contour_map_ce(wks, data_map, res)

  resP                    = True
  resP@gsnPanelMainString = ""
  resP@gsnPanelLabelBar = False
  resP@gsnMaximize = True
  gsn_panel(wks, plot, (/2, 2/), resP)
end