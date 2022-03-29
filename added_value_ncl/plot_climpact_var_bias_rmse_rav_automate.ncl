; plot Added Value (AV)

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

  yyyymmdd_start = (yyyy_start*10000)+101
  yyyymmdd_end = (yyyy_end*10000)+1231

  print(systemfunc("date"))
  print("Reading data")
  f = addfile(fl, "r")

  bias = f->bias_awap_grid
  rmse = f->rmse_awap_grid

  ; land sea mask file (AWAP grid)
  f2 = addfile("/scratch/e53/mxt599/esci/sftrf_AWAP0.05_NRMv3.nc", "r")
  lsmask0 = f2->AUS

  bias_mask = bias
  bias_mask = mask(bias, conform(bias, lsmask0, (/0, 1/)), 1)
  delete(bias)
  bias = bias_mask
  delete(bias_mask)

  rmse_mask = rmse
  rmse_mask = mask(rmse, conform(rmse, lsmask0, (/0, 1/)), 1)
  delete(rmse)
  rmse = rmse_mask
  delete(rmse_mask)

  av_avg = f->av_avg
  av_avg&lat@units = "degrees_north"
  av_avg&lon@units = "degrees_east"
  gdd_avg_rmse = f->gdd_avg_rmse
  gdd_avg_rmse&lat@units = "degrees_north"
  gdd_avg_rmse&lon@units = "degrees_east"
  rcm_avg_rmse = f->rcm_avg_rmse
  rcm_avg_rmse&lat@units = "degrees_north"
  rcm_avg_rmse&lon@units = "degrees_east"
  av_avg_ncl = f->av_avg_ncl
  av_avg_ncl&lat@units = "degrees_north"
  av_avg_ncl&lon@units = "degrees_east"
  gdd_avg_rmse_ncl = f->gdd_avg_rmse_ncl
  gdd_avg_rmse_ncl&lat@units = "degrees_north"
  gdd_avg_rmse_ncl&lon@units = "degrees_east"
  rcm_avg_rmse_ncl = f->rcm_avg_rmse_ncl
  rcm_avg_rmse_ncl&lat@units = "degrees_north"
  rcm_avg_rmse_ncl&lon@units = "degrees_east"
  obs_avg_variance = f->obs_avg_variance
  obs_avg_variance&lat@units = "degrees_north"
  obs_avg_variance&lon@units = "degrees_east"
  obs_avg_clm = f->obs_avg_clm
  obs_avg_clm&lat@units = "degrees_north"
  obs_avg_clm&lon@units = "degrees_east"
  gdd_avg_clm = f->gdd_avg_clm
  gdd_avg_clm&lat@units = "degrees_north"
  gdd_avg_clm&lon@units = "degrees_east"
  rcm_avg_clm = f->rcm_avg_clm
  rcm_avg_clm&lat@units = "degrees_north"
  rcm_avg_clm&lon@units = "degrees_east"
  av_var = f->av_var
  av_var&lat@units = "degrees_north"
  av_var&lon@units = "degrees_east"
  gdd_var_rmse = f->gdd_var_rmse
  gdd_var_rmse&lat@units = "degrees_north"
  gdd_var_rmse&lon@units = "degrees_east"
  rcm_var_rmse = f->rcm_var_rmse
  rcm_var_rmse&lat@units = "degrees_north"
  rcm_var_rmse&lon@units = "degrees_east"
  av_var_ncl = f->av_var_ncl
  av_var_ncl&lat@units = "degrees_north"
  av_var_ncl&lon@units = "degrees_east"
  gdd_var_rmse_ncl = f->gdd_var_rmse_ncl
  gdd_var_rmse_ncl&lat@units = "degrees_north"
  gdd_var_rmse_ncl&lon@units = "degrees_east"
  rcm_var_rmse_ncl = f->rcm_var_rmse_ncl
  rcm_var_rmse_ncl&lat@units = "degrees_north"
  rcm_var_rmse_ncl&lon@units = "degrees_east"
  obs_var_variance = f->obs_var_variance
  obs_var_variance&lat@units = "degrees_north"
  obs_var_variance&lon@units = "degrees_east"
  obs_var_clm = f->obs_var_clm
  obs_var_clm&lat@units = "degrees_north"
  obs_var_clm&lon@units = "degrees_east"
  gdd_var_clm = f->gdd_var_clm
  gdd_var_clm&lat@units = "degrees_north"
  gdd_var_clm&lon@units = "degrees_east"
  rcm_var_clm = f->rcm_var_clm
  rcm_var_clm&lat@units = "degrees_north"
  rcm_var_clm&lon@units = "degrees_east"
  av_99p = f->av_99p
  av_99p&lat@units = "degrees_north"
  av_99p&lon@units = "degrees_east"
  gdd_99p_rmse = f->gdd_99p_rmse
  gdd_99p_rmse&lat@units = "degrees_north"
  gdd_99p_rmse&lon@units = "degrees_east"
  rcm_99p_rmse = f->rcm_99p_rmse
  rcm_99p_rmse&lat@units = "degrees_north"
  rcm_99p_rmse&lon@units = "degrees_east"
  av_99p_ncl = f->av_99p_ncl
  av_99p_ncl&lat@units = "degrees_north"
  av_99p_ncl&lon@units = "degrees_east"
  gdd_99p_rmse_ncl = f->gdd_99p_rmse_ncl
  gdd_99p_rmse_ncl&lat@units = "degrees_north"
  gdd_99p_rmse_ncl&lon@units = "degrees_east"
  rcm_99p_rmse_ncl = f->rcm_99p_rmse_ncl
  rcm_99p_rmse_ncl&lat@units = "degrees_north"
  rcm_99p_rmse_ncl&lon@units = "degrees_east"
  obs_99p_variance = f->obs_99p_variance
  obs_99p_variance&lat@units = "degrees_north"
  obs_99p_variance&lon@units = "degrees_east"
  obs_99p_clm = f->obs_99p_clm
  obs_99p_clm&lat@units = "degrees_north"
  obs_99p_clm&lon@units = "degrees_east"
  gdd_99p_clm = f->gdd_99p_clm
  gdd_99p_clm&lat@units = "degrees_north"
  gdd_99p_clm&lon@units = "degrees_east"
  rcm_99p_clm = f->rcm_99p_clm
  rcm_99p_clm&lat@units = "degrees_north"
  rcm_99p_clm&lon@units = "degrees_east"
  av_01p = f->av_01p
  av_01p&lat@units = "degrees_north"
  av_01p&lon@units = "degrees_east"
  gdd_01p_rmse = f->gdd_01p_rmse
  gdd_01p_rmse&lat@units = "degrees_north"
  gdd_01p_rmse&lon@units = "degrees_east"
  rcm_01p_rmse = f->rcm_01p_rmse
  rcm_01p_rmse&lat@units = "degrees_north"
  rcm_01p_rmse&lon@units = "degrees_east"
  av_01p_ncl = f->av_01p_ncl
  av_01p_ncl&lat@units = "degrees_north"
  av_01p_ncl&lon@units = "degrees_east"
  gdd_01p_rmse_ncl = f->gdd_01p_rmse_ncl
  gdd_01p_rmse_ncl&lat@units = "degrees_north"
  gdd_01p_rmse_ncl&lon@units = "degrees_east"
  rcm_01p_rmse_ncl = f->rcm_01p_rmse_ncl
  rcm_01p_rmse_ncl&lat@units = "degrees_north"
  rcm_01p_rmse_ncl&lon@units = "degrees_east"
  obs_01p_variance = f->obs_01p_variance
  obs_01p_variance&lat@units = "degrees_north"
  obs_01p_variance&lon@units = "degrees_east"
  obs_01p_clm = f->obs_01p_clm
  obs_01p_clm&lat@units = "degrees_north"
  obs_01p_clm&lon@units = "degrees_east"
  gdd_01p_clm = f->gdd_01p_clm
  gdd_01p_clm&lat@units = "degrees_north"
  gdd_01p_clm&lon@units = "degrees_east"
  rcm_01p_clm = f->rcm_01p_clm
  rcm_01p_clm&lat@units = "degrees_north"
  rcm_01p_clm&lon@units = "degrees_east"

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
  res@vpWidthF             = 0.7
  res@vpHeightF            = 0.35
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

  plot_name = run_name+"_"+var+"_bias_rmse_rav"

  print(systemfunc("date"))
  print("Plotting")
  wks = gsn_open_wks("pdf", plot_name)
  plot0 = new(4, graphic)
  plot1 = new(2, graphic)
  cmap_cmocean_balance = read_colormap_file("cmocean_balance")
  cmap_MPL_Reds = read_colormap_file("MPL_Reds")

  stats = stat_dispersion(rcm_avg_clm, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)

if dmin .eq. dmax then
    if abs(mmin) .gt. abs(mmax) then
      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 20, False)
    else if abs(mmax) .gt. abs(mmin) then
      ;mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 20, False)
      mnmxint = nice_mnmxintvl(mmin, abs(mmax), 20, False)
    end if
    end if
  else
    if abs(dmin) .gt. abs(dmax) then
      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 20, False)
    else if abs(dmax) .gt. abs(dmin) then
      ;mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 20, False)
      mnmxint = nice_mnmxintvl(dmin, abs(dmax), 20, False)
    end if
    end if
  end if
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)
  if var.eq."pr" then
    res@cnFillPalette = cmap_cmocean_balance(::-1,:) ; reverse the colourmap
  else
    res@cnFillPalette = cmap_cmocean_balance
  end if
  res@gsnLeftString = "RCM "+yyyy_start+"-"+yyyy_end+" clim."
  plot0(0) = gsn_csm_contour_map_ce(wks, rcm_avg_clm, res)
  ;draw(plot0(0))
  ;frame(wks)

  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)
  res@gsnLeftString = "GDD "+yyyy_start+"-"+yyyy_end+" clim."
  plot0(1) = gsn_csm_contour_map_ce(wks, gdd_avg_clm, res)
  ;draw(plot0(1))
  ;frame(wks)

  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)
  res@gsnLeftString = "Obs "+yyyy_start+"-"+yyyy_end+" clim."
  plot0(2) = gsn_csm_contour_map_ce(wks, obs_avg_clm, res)
  ;draw(plot0(2))
  ;frame(wks)

  res@cnMinLevelValF       = -1. 
  res@cnMaxLevelValF       = 1.
  res@cnLevelSpacingF      = 0.1
  res@gsnLeftString = "AV"
  delete(res@cnFillPalette)
  res@cnFillPalette = cmap_cmocean_balance
  plot0(3) = gsn_csm_contour_map_ce(wks, av_avg, res)
  ;draw(plot0(5))
  ;frame(wks)

  resP                    = True
  resP@gsnPanelMainString = "CCAM "+run_name+" "+var+" annual mean"
  resP@gsnPanelLabelBar = False
  resP@gsnMaximize = True
  gsn_panel(wks,plot0,(/2, 2/),resP)

  res@gsnLeftString = "Bias "+yyyy_start+"-"+yyyy_end
  if var.eq."pr" then
    res@cnFillPalette = cmap_cmocean_balance(::-1,:) ; reverse the colourmap
  else
    res@cnFillPalette = cmap_cmocean_balance
  end if

  delete(stats)
  stats = stat_dispersion(bias, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)
  
if dmin .eq. dmax then
    if abs(mmin) .gt. abs(mmax) then
      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 20, False)
    else if abs(mmax) .gt. abs(mmin) then
      ;mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 20, False)
      mnmxint = nice_mnmxintvl(mmax, abs(mmax), 20, False)
    end if
    end if
  else
    if abs(dmin) .gt. abs(dmax) then
      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 20, False)
    else if abs(dmax) .gt. abs(dmin) then
      ;mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 20, False)
      mnmxint = nice_mnmxintvl(dmin, abs(dmax), 20, False)
    end if
    end if
  end if
  res@cnMinLevelValF = mnmxint(0)
  res@cnMaxLevelValF = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)
  plot1(0) = gsn_csm_contour_map_ce(wks, bias, res)
  ;draw(plot1(0))
  ;frame(wks)

  res@gsnLeftString = "RMSE "+yyyy_start+"-"+yyyy_end
  delete(res@cnFillPalette)
  res@cnFillPalette = cmap_cmocean_balance
  res@cnMinLevelValF       = 0. 
  res@cnMaxLevelValF       = 2.
  res@cnLevelSpacingF      = 0.1
  res@gsnSpreadColorStart  = 129
  plot1(1) = gsn_csm_contour_map_ce(wks, rmse, res)

  resP                    = True
  resP@gsnPanelMainString = "CCAM "+run_name+" "+var+" annual mean bias and rmse (AWAP grid)"
  resP@gsnPanelLabelBar = False
  gsn_panel(wks,plot1,(/1, 2/),resP)

  print(systemfunc("date"))
end