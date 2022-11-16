; plot seasonal bias and rmse

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
  rad = 4.0*atan(1.0)/180.0
  re  = 6371220.0
  rr  = re*rad

  uf = addfile("../calculated/"+run_name+"_"+varv+"_bias_rmse_monthly_means_no_agcd_awap_grid.nc", "r")
  vf = addfile("../calculated/"+run_name+"_"+varu+"_bias_rmse_monthly_means_no_agcd_awap_grid.nc", "r")
  pf = addfile("../calculated/"+run_name+"_"+varp+"_bias_rmse_monthly_means_no_agcd_awap_grid.nc", "r")

  rcm_ua = uf->rcm_var_month
  gdd_ua_ = uf->gdd_var_month
  gdd_ua = tofloat(gdd_ua_)
  copy_VarMeta(gdd_ua_, gdd_ua)
  delete(gdd_ua_)

  rcm_va = vf->rcm_var_month
  gdd_va_ = vf->gdd_var_month
  gdd_va = tofloat(gdd_va_)
  copy_VarMeta(gdd_va_, gdd_va)
  delete(gdd_va_)

  rcm_psl = pf->rcm_var_month
  rcm_psl = rcm_psl/100
  rcm_psl@units = "hPa"
  gdd_psl_ = pf->gdd_var_month
  gdd_psl = tofloat(gdd_psl_)
  copy_VarMeta(gdd_psl_, gdd_psl)
  delete(gdd_psl_)
  gdd_psl = gdd_psl/100
  gdd_psl@units = "hPa"

  new_time = cd_convert(rcm_ua&time, "days since 0001-01-01 00:00:00")

  delete(gdd_ua&time)
  delete(rcm_ua&time)
  rcm_ua&time = new_time
  gdd_ua&time = new_time
  delete(gdd_va&time)
  delete(rcm_va&time)
  rcm_va&time = new_time
  gdd_va&time = new_time
  delete(gdd_psl&time)
  delete(rcm_psl&time)
  rcm_psl&time = new_time
  gdd_psl&time = new_time
  
; calculate seasonal/annual
  rcm_ua_DJF = month_to_season(rcm_ua, "DJF")
  rcm_ua_DJF_avg = dim_avg_n_Wrap(rcm_ua_DJF, 0)
  rcm_ua_DJF_var = dim_variance_n_Wrap(rcm_ua_DJF, 0)
  gdd_ua_DJF = month_to_season(gdd_ua, "DJF")
  gdd_ua_DJF_avg = dim_avg_n_Wrap(gdd_ua_DJF, 0)
  gdd_ua_DJF_var = dim_variance_n_Wrap(gdd_ua_DJF, 0)

  rcm_ua_MAM = month_to_season(rcm_ua, "MAM")
  rcm_ua_MAM_avg = dim_avg_n_Wrap(rcm_ua_MAM, 0)
  rcm_ua_MAM_var = dim_variance_n_Wrap(rcm_ua_MAM, 0)
  gdd_ua_MAM = month_to_season(gdd_ua, "MAM")
  gdd_ua_MAM_avg = dim_avg_n_Wrap(gdd_ua_MAM, 0)
  gdd_ua_MAM_var = dim_variance_n_Wrap(gdd_ua_MAM, 0)

  rcm_ua_JJA = month_to_season(rcm_ua, "JJA")
  rcm_ua_JJA_avg = dim_avg_n_Wrap(rcm_ua_JJA, 0)
  rcm_ua_JJA_var = dim_variance_n_Wrap(rcm_ua_JJA, 0)
  gdd_ua_JJA = month_to_season(gdd_ua, "JJA")
  gdd_ua_JJA_avg = dim_avg_n_Wrap(gdd_ua_JJA, 0)
  gdd_ua_JJA_var = dim_variance_n_Wrap(gdd_ua_JJA, 0)

  rcm_ua_SON = month_to_season(rcm_ua, "SON")
  rcm_ua_SON_avg = dim_avg_n_Wrap(rcm_ua_SON, 0)
  rcm_ua_SON_var = dim_variance_n_Wrap(rcm_ua_SON, 0)
  gdd_ua_SON = month_to_season(gdd_ua, "SON")
  gdd_ua_SON_avg = dim_avg_n_Wrap(gdd_ua_SON, 0)
  gdd_ua_SON_var = dim_variance_n_Wrap(gdd_ua_SON, 0)

  rcm_ua_ann = month_to_annual(rcm_ua, 1)
  rcm_ua_ann_avg = dim_avg_n_Wrap(rcm_ua_ann, 0)
  rcm_ua_ann_var = dim_variance_n_Wrap(rcm_ua_ann, 0)
  gdd_ua_ann = month_to_annual(gdd_ua, 1)
  gdd_ua_ann_avg = dim_avg_n_Wrap(gdd_ua_ann, 0)
  gdd_ua_ann_var = dim_variance_n_Wrap(gdd_ua_ann, 0)

  rcm_ua_ann!0 = "time"
  rcm_ua_ann&time = rcm_ua_JJA&time

  gdd_ua_ann!0 = "time"
  gdd_ua_ann&time = gdd_ua_JJA&time

  rcm_va_DJF = month_to_season(rcm_va, "DJF")
  rcm_va_DJF_avg = dim_avg_n_Wrap(rcm_va_DJF, 0)
  rcm_va_DJF_var = dim_variance_n_Wrap(rcm_va_DJF, 0)
  gdd_va_DJF = month_to_season(gdd_va, "DJF")
  gdd_va_DJF_avg = dim_avg_n_Wrap(gdd_va_DJF, 0)
  gdd_va_DJF_var = dim_variance_n_Wrap(gdd_va_DJF, 0)

  rcm_va_MAM = month_to_season(rcm_va, "MAM")
  rcm_va_MAM_avg = dim_avg_n_Wrap(rcm_va_MAM, 0)
  rcm_va_MAM_var = dim_variance_n_Wrap(rcm_va_MAM, 0)
  gdd_va_MAM = month_to_season(gdd_va, "MAM")
  gdd_va_MAM_avg = dim_avg_n_Wrap(gdd_va_MAM, 0)
  gdd_va_MAM_var = dim_variance_n_Wrap(gdd_va_MAM, 0)

  rcm_va_JJA = month_to_season(rcm_va, "JJA")
  rcm_va_JJA_avg = dim_avg_n_Wrap(rcm_va_JJA, 0)
  rcm_va_JJA_var = dim_variance_n_Wrap(rcm_va_JJA, 0)
  gdd_va_JJA = month_to_season(gdd_va, "JJA")
  gdd_va_JJA_avg = dim_avg_n_Wrap(gdd_va_JJA, 0)
  gdd_va_JJA_var = dim_variance_n_Wrap(gdd_va_JJA, 0)

  rcm_va_SON = month_to_season(rcm_va, "SON")
  rcm_va_SON_avg = dim_avg_n_Wrap(rcm_va_SON, 0)
  rcm_va_SON_var = dim_variance_n_Wrap(rcm_va_SON, 0)
  gdd_va_SON = month_to_season(gdd_va, "SON")
  gdd_va_SON_avg = dim_avg_n_Wrap(gdd_va_SON, 0)
  gdd_va_SON_var = dim_variance_n_Wrap(gdd_va_SON, 0)

  rcm_va_ann = month_to_annual(rcm_va, 1)
  rcm_va_ann_avg = dim_avg_n_Wrap(rcm_va_ann, 0)
  rcm_va_ann_var = dim_variance_n_Wrap(rcm_va_ann, 0)
  gdd_va_ann = month_to_annual(gdd_va, 1)
  gdd_va_ann_avg = dim_avg_n_Wrap(gdd_va_ann, 0)
  gdd_va_ann_var = dim_variance_n_Wrap(gdd_va_ann, 0)

  rcm_va_ann!0 = "time"
  rcm_va_ann&time = rcm_va_JJA&time

  gdd_va_ann!0 = "time"
  gdd_va_ann&time = gdd_va_JJA&time

  rcm_psl_DJF = month_to_season(rcm_psl, "DJF")
  rcm_psl_DJF_avg = dim_avg_n_Wrap(rcm_psl_DJF, 0)
  rcm_psl_DJF_var = dim_variance_n_Wrap(rcm_psl_DJF, 0)
  gdd_psl_DJF = month_to_season(gdd_psl, "DJF")
  gdd_psl_DJF_avg = dim_avg_n_Wrap(gdd_psl_DJF, 0)
  gdd_psl_DJF_var = dim_variance_n_Wrap(gdd_psl_DJF, 0)

  rcm_psl_MAM = month_to_season(rcm_psl, "MAM")
  rcm_psl_MAM_avg = dim_avg_n_Wrap(rcm_psl_MAM, 0)
  rcm_psl_MAM_var = dim_variance_n_Wrap(rcm_psl_MAM, 0)
  gdd_psl_MAM = month_to_season(gdd_psl, "MAM")
  gdd_psl_MAM_avg = dim_avg_n_Wrap(gdd_psl_MAM, 0)
  gdd_psl_MAM_var = dim_variance_n_Wrap(gdd_psl_MAM, 0)

  rcm_psl_JJA = month_to_season(rcm_psl, "JJA")
  rcm_psl_JJA_avg = dim_avg_n_Wrap(rcm_psl_JJA, 0)
  rcm_psl_JJA_var = dim_variance_n_Wrap(rcm_psl_JJA, 0)
  gdd_psl_JJA = month_to_season(gdd_psl, "JJA")
  gdd_psl_JJA_avg = dim_avg_n_Wrap(gdd_psl_JJA, 0)
  gdd_psl_JJA_var = dim_variance_n_Wrap(gdd_psl_JJA, 0)

  rcm_psl_SON = month_to_season(rcm_psl, "SON")
  rcm_psl_SON_avg = dim_avg_n_Wrap(rcm_psl_SON, 0)
  rcm_psl_SON_var = dim_variance_n_Wrap(rcm_psl_SON, 0)
  gdd_psl_SON = month_to_season(gdd_psl, "SON")
  gdd_psl_SON_avg = dim_avg_n_Wrap(gdd_psl_SON, 0)
  gdd_psl_SON_var = dim_variance_n_Wrap(gdd_psl_SON, 0)

  rcm_psl_ann = month_to_annual(rcm_psl, 1)
  rcm_psl_ann_avg = dim_avg_n_Wrap(rcm_psl_ann, 0)
  rcm_psl_ann_var = dim_variance_n_Wrap(rcm_psl_ann, 0)
  gdd_psl_ann = month_to_annual(gdd_psl, 1)
  gdd_psl_ann_avg = dim_avg_n_Wrap(gdd_psl_ann, 0)
  gdd_psl_ann_var = dim_variance_n_Wrap(gdd_psl_ann, 0)

  rcm_psl_ann!0 = "time"
  rcm_psl_ann&time = rcm_psl_JJA&time

  gdd_psl_ann!0 = "time"
  gdd_psl_ann&time = gdd_psl_JJA&time

  ; area average for time series
  lat = rcm_ua&lat
  lon = rcm_ua&lon
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
  rcm_ua_dims = dimsizes(rcm_ua(0::12,:,:))

  rcm_ua_mon = new((/12, rcm_ua_dims(0), rcm_ua_dims(1), rcm_ua_dims(2)/),typeof(rcm_ua))

  rcm_ua_mon(0,:,:,:) = rcm_ua(0::12,:,:)
  rcm_ua_mon(1,:,:,:) = rcm_ua(1::12,:,:)
  rcm_ua_mon(2,:,:,:) = rcm_ua(2::12,:,:)
  rcm_ua_mon(3,:,:,:) = rcm_ua(3::12,:,:)
  rcm_ua_mon(4,:,:,:) = rcm_ua(4::12,:,:)
  rcm_ua_mon(5,:,:,:) = rcm_ua(5::12,:,:)
  rcm_ua_mon(6,:,:,:) = rcm_ua(6::12,:,:)
  rcm_ua_mon(7,:,:,:) = rcm_ua(7::12,:,:)
  rcm_ua_mon(8,:,:,:) = rcm_ua(8::12,:,:)
  rcm_ua_mon(9,:,:,:) = rcm_ua(9::12,:,:)
  rcm_ua_mon(10,:,:,:) = rcm_ua(10::12,:,:)
  rcm_ua_mon(11,:,:,:) = rcm_ua(11::12,:,:)
  rcm_ua_mon_avg = dim_avg_n_Wrap(rcm_ua_mon, 1)
  rcm_ua_mon_var = dim_variance_n_Wrap(rcm_ua_mon, 1)
  rcm_ua_avg = dim_avg_n_Wrap(rcm_ua, 0)
  rcm_ua_var = dim_variance_n_Wrap(rcm_ua, 0)

  rcm_va_dims = dimsizes(rcm_va(0::12,:,:))

  rcm_va_mon = new((/12, rcm_va_dims(0), rcm_va_dims(1), rcm_va_dims(2)/),typeof(rcm_va))

  rcm_va_mon(0,:,:,:) = rcm_va(0::12,:,:)
  rcm_va_mon(1,:,:,:) = rcm_va(1::12,:,:)
  rcm_va_mon(2,:,:,:) = rcm_va(2::12,:,:)
  rcm_va_mon(3,:,:,:) = rcm_va(3::12,:,:)
  rcm_va_mon(4,:,:,:) = rcm_va(4::12,:,:)
  rcm_va_mon(5,:,:,:) = rcm_va(5::12,:,:)
  rcm_va_mon(6,:,:,:) = rcm_va(6::12,:,:)
  rcm_va_mon(7,:,:,:) = rcm_va(7::12,:,:)
  rcm_va_mon(8,:,:,:) = rcm_va(8::12,:,:)
  rcm_va_mon(9,:,:,:) = rcm_va(9::12,:,:)
  rcm_va_mon(10,:,:,:) = rcm_va(10::12,:,:)
  rcm_va_mon(11,:,:,:) = rcm_va(11::12,:,:)
  rcm_va_mon_avg = dim_avg_n_Wrap(rcm_va_mon, 1)
  rcm_va_mon_var = dim_variance_n_Wrap(rcm_va_mon, 1)
  rcm_va_avg = dim_avg_n_Wrap(rcm_va, 0)
  rcm_va_var = dim_variance_n_Wrap(rcm_va, 0)

  rcm_psl_dims = dimsizes(rcm_psl(0::12,:,:))

  rcm_psl_mon = new((/12, rcm_psl_dims(0), rcm_psl_dims(1), rcm_psl_dims(2)/),typeof(rcm_psl))

  rcm_psl_mon(0,:,:,:) = rcm_psl(0::12,:,:)
  rcm_psl_mon(1,:,:,:) = rcm_psl(1::12,:,:)
  rcm_psl_mon(2,:,:,:) = rcm_psl(2::12,:,:)
  rcm_psl_mon(3,:,:,:) = rcm_psl(3::12,:,:)
  rcm_psl_mon(4,:,:,:) = rcm_psl(4::12,:,:)
  rcm_psl_mon(5,:,:,:) = rcm_psl(5::12,:,:)
  rcm_psl_mon(6,:,:,:) = rcm_psl(6::12,:,:)
  rcm_psl_mon(7,:,:,:) = rcm_psl(7::12,:,:)
  rcm_psl_mon(8,:,:,:) = rcm_psl(8::12,:,:)
  rcm_psl_mon(9,:,:,:) = rcm_psl(9::12,:,:)
  rcm_psl_mon(10,:,:,:) = rcm_psl(10::12,:,:)
  rcm_psl_mon(11,:,:,:) = rcm_psl(11::12,:,:)
  rcm_psl_mon_avg = dim_avg_n_Wrap(rcm_psl_mon, 1)
  rcm_psl_mon_var = dim_variance_n_Wrap(rcm_psl_mon, 1)
  rcm_psl_avg = dim_avg_n_Wrap(rcm_psl, 0)
  rcm_psl_var = dim_variance_n_Wrap(rcm_psl, 0)

; GDD
  gdd_ua_dims = dimsizes(gdd_ua(0::12,:,:))

  gdd_ua_mon = new((/12, gdd_ua_dims(0), gdd_ua_dims(1), gdd_ua_dims(2)/),typeof(gdd_ua))

  gdd_ua_mon(0,:,:,:) = gdd_ua(0::12,:,:)
  gdd_ua_mon(1,:,:,:) = gdd_ua(1::12,:,:)
  gdd_ua_mon(2,:,:,:) = gdd_ua(2::12,:,:)
  gdd_ua_mon(3,:,:,:) = gdd_ua(3::12,:,:)
  gdd_ua_mon(4,:,:,:) = gdd_ua(4::12,:,:)
  gdd_ua_mon(5,:,:,:) = gdd_ua(5::12,:,:)
  gdd_ua_mon(6,:,:,:) = gdd_ua(6::12,:,:)
  gdd_ua_mon(7,:,:,:) = gdd_ua(7::12,:,:)
  gdd_ua_mon(8,:,:,:) = gdd_ua(8::12,:,:)
  gdd_ua_mon(9,:,:,:) = gdd_ua(9::12,:,:)
  gdd_ua_mon(10,:,:,:) = gdd_ua(10::12,:,:)
  gdd_ua_mon(11,:,:,:) = gdd_ua(11::12,:,:)
  gdd_ua_mon_avg = dim_avg_n_Wrap(gdd_ua_mon, 1)
  gdd_ua_mon_var = dim_variance_n_Wrap(gdd_ua_mon, 1)
  gdd_ua_avg = dim_avg_n_Wrap(gdd_ua, 0)
  gdd_ua_var = dim_variance_n_Wrap(gdd_ua, 0)

  gdd_va_dims = dimsizes(gdd_va(0::12,:,:))

  gdd_va_mon = new((/12, gdd_va_dims(0), gdd_va_dims(1), gdd_va_dims(2)/),typeof(gdd_va))

  gdd_va_mon(0,:,:,:) = gdd_va(0::12,:,:)
  gdd_va_mon(1,:,:,:) = gdd_va(1::12,:,:)
  gdd_va_mon(2,:,:,:) = gdd_va(2::12,:,:)
  gdd_va_mon(3,:,:,:) = gdd_va(3::12,:,:)
  gdd_va_mon(4,:,:,:) = gdd_va(4::12,:,:)
  gdd_va_mon(5,:,:,:) = gdd_va(5::12,:,:)
  gdd_va_mon(6,:,:,:) = gdd_va(6::12,:,:)
  gdd_va_mon(7,:,:,:) = gdd_va(7::12,:,:)
  gdd_va_mon(8,:,:,:) = gdd_va(8::12,:,:)
  gdd_va_mon(9,:,:,:) = gdd_va(9::12,:,:)
  gdd_va_mon(10,:,:,:) = gdd_va(10::12,:,:)
  gdd_va_mon(11,:,:,:) = gdd_va(11::12,:,:)
  gdd_va_mon_avg = dim_avg_n_Wrap(gdd_va_mon, 1)
  gdd_va_mon_var = dim_variance_n_Wrap(gdd_va_mon, 1)
  gdd_va_avg = dim_avg_n_Wrap(gdd_va, 0)
  gdd_va_var = dim_variance_n_Wrap(gdd_va, 0)

  gdd_psl_dims = dimsizes(gdd_psl(0::12,:,:))

  gdd_psl_mon = new((/12, gdd_psl_dims(0), gdd_psl_dims(1), gdd_psl_dims(2)/),typeof(gdd_psl))

  gdd_psl_mon(0,:,:,:) = gdd_psl(0::12,:,:)
  gdd_psl_mon(1,:,:,:) = gdd_psl(1::12,:,:)
  gdd_psl_mon(2,:,:,:) = gdd_psl(2::12,:,:)
  gdd_psl_mon(3,:,:,:) = gdd_psl(3::12,:,:)
  gdd_psl_mon(4,:,:,:) = gdd_psl(4::12,:,:)
  gdd_psl_mon(5,:,:,:) = gdd_psl(5::12,:,:)
  gdd_psl_mon(6,:,:,:) = gdd_psl(6::12,:,:)
  gdd_psl_mon(7,:,:,:) = gdd_psl(7::12,:,:)
  gdd_psl_mon(8,:,:,:) = gdd_psl(8::12,:,:)
  gdd_psl_mon(9,:,:,:) = gdd_psl(9::12,:,:)
  gdd_psl_mon(10,:,:,:) = gdd_psl(10::12,:,:)
  gdd_psl_mon(11,:,:,:) = gdd_psl(11::12,:,:)
  gdd_psl_mon_avg = dim_avg_n_Wrap(gdd_psl_mon, 1)
  gdd_psl_mon_var = dim_variance_n_Wrap(gdd_psl_mon, 1)
  gdd_psl_avg = dim_avg_n_Wrap(gdd_psl, 0)
  gdd_psl_var = dim_variance_n_Wrap(gdd_psl, 0)

; plot
  plot_name = "../plots_seasonal/"+run_name+"_gdd_rcm_"+varu+"_"+varv+"_"+varp+"_seasonal_annual_average"
  cmap_cmocean_balance = read_colormap_file("cmocean_balance")

  print(systemfunc("date"))
  print("Plotting")

; plot
; resources
        res                = True
        res@gsnDraw        = False
        res@gsnFrame       = False 
        res@gsnMaximize    = True 
        res@tmXTOn         = False
        res@tmYROn         = False
        res@gsnLeftString  = ""
        res@gsnRightString = ""
        
;;set map;;
        mpres                             = res
        mpres@mpDataSetName               = "Earth..4"
        mpres@mpDataBaseVersion           = "HighRes"
        ;mpres@mpOutlineOn                 = True
        ;mpres@mpOutlineSpecifiers         = (/"China:states","Taiwan"/)
        ;mpres@mpGeophysicalLineThicknessF = 2
        ;mpres@mpNationalLineThicknessF    = 2
        mpres@mpFillDrawOrder             = "PostDraw"
        mpres@mpFillOn                    = False
        ;mpres@mpFillAreaSpecifiers        = (/"water",       "land" /)
        ;mpres@mpSpecifiedFillColors       = (/"deepskyblue2","white"/)
;       mpres@mpSpecifiedFillColors      = (/100,0/)
        ;mpres@mpMaskAreaSpecifiers        = (/"China:states","Taiwan"/)

;;set area;;
        mpres@mpMinLatF                   = -45.
        mpres@mpMaxLatF                   = -10. 
        mpres@mpMinLonF                   = 112.
        mpres@mpMaxLonF                   = 156.25

;;set contour;;
        cnres                             = res
        cnres@cnFillDrawOrder             = "PreDraw"
        cnres@cnFillOn                    = True
        cnres@cnLinesOn                   = False
        cnres@pmLabelBarWidthF            = 0.4
        cnres@pmLabelBarHeightF           = 0.05
        cnres@pmLabelBarOrthogonalPosF    = 0.1
        cnres@lbLabelFontHeightF          = 0.015
        ;cnres@lbLabelAngleF               = 45
; Older way to subset a color map
;       cnres@cnFillPalette               = "BkBlAqGrYeOrReViWh200"
;       cnres@gsnSpreadColorStart         = 50
;       cnres@gsnSpreadColorEnd           = 120

; Newer way to subset a color map
        cnres@cnFillPalette               = cmap_cmocean_balance
 
        cnres@gsnLeftString               = "Pressure"
        
;;set vector;;
        res_vc                            = res
        res_vc@vcGlyphStyle               = "LineArrow"
        res_vc@vcLineArrowThicknessF      = 1

;;wind barb resources don't apply
;;      res_vc@vcGlyphStyle               = "WindBarb"
;;      res_vc@vcWindBarbLineThicknessF   = 5
;;      res_vc@vcWindBarbColor            = "Gray40"

        res_vc@vcRefAnnoOn               = True
        res_vc@vcRefMagnitudeF           = 8.0 
        ;res_vc@vcRefAnnoString1          = "8.0"
        res_vc@vcRefLengthF              = 0.045           ; define length of vec ref
        res_vc@vcMinDistanceF            = 0.05
        res_vc@vcRefAnnoSide             = "Top"
        res_vc@vcRefAnnoString2On        = False
        res_vc@vcRefAnnoPerimOn          = False
        res_vc@vcRefAnnoOrthogonalPosF   = -0.135
        res_vc@vcRefAnnoParallelPosF     = 0.995
        ;res_vc@vcRefAnnoBackgroundColor  = "Purple"
        res_vc@vcVectorDrawOrder         = "PostDraw"
        res_vc@gsnRightString            = "Wind"

  wks1 = gsn_open_wks("pdf", plot_name)
  plot2 = new(15, graphic)
  plot3 = new(15, graphic)
  plot4 = new(15, graphic)
  plot5 = new(15, graphic)
  map0 = new(15, graphic)
  contour0 = new(15, graphic)
  vector0 = new(15, graphic)
  map1 = new(15, graphic)
  contour1 = new(15, graphic)
  vector1 = new(15, graphic)
  map2 = new(15, graphic)
  contour2 = new(15, graphic)
  vector2 = new(15, graphic)
  map3 = new(15, graphic)
  contour3 = new(15, graphic)
  vector3 = new(15, graphic)
  cmap_cmocean_balance = read_colormap_file("cmocean_balance")
  cmap_MPL_Reds = read_colormap_file("MPL_Reds")

; GDD avg
  
;  do n=0,11
;    cnres@gsnLeftString = mon(n)+" avg"
;
;    stats = stat_dispersion(gdd_psl_mon_avg, False)
;    dmin = stats(3)
;    dmax = stats(13)
;    mmin = stats(2)
;    mmax = stats(14)
;
;    ; calculate which is larger
;    mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
;;    if dmin .eq. dmax then
;;      if abs(mmin) .gt. abs(mmax) then
;;        mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
;;      else if abs(mmax) .gt. abs(mmin) then
;;        mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
;;      end if
;;      end if
;;    else
;;      if abs(dmin) .gt. abs(dmax) then
;;        mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
;;      else if abs(dmax) .gt. abs(dmin) then
;;        mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
;;      end if
;;      end if
;;    end if
;
;    cnres@cnMinLevelValF = mnmxint(0)
;    cnres@cnMaxLevelValF = mnmxint(1)
;    cnres@cnLevelSpacingF = mnmxint(2)
;    ;;plot;;
;    map0(n)     = gsn_csm_map(wks1,mpres)
;    contour0(n) = gsn_csm_contour(wks1,gdd_psl_mon_avg(n,:,:),cnres)
;    vector0(n)  = gsn_csm_vector(wks1,gdd_ua_mon_avg(n,:,:),gdd_va_mon_avg(n,:,:),res_vc)
;    overlay(map0(n),contour0(n))
;    overlay(map0(n),vector0(n))
;    ;plot2(n) = gsn_csm_vector_scalar_map_ce(wks1, gdd_ua_mon_avg(n,:,:), gdd_va_mon_avg(n,:,:), gdd_psl_mon_avg(n,:,:), res)
;  end do

  ; append gdd and rcm seasons into 1 large array
  print("appending season arrays")
  season0 = array_append_record(gdd_psl_DJF_avg, gdd_psl_MAM_avg, 0)
  season1 = array_append_record(season0, gdd_psl_JJA_avg, 0)
  season2 =  array_append_record(season1, gdd_psl_SON_avg, 0)
  rcm_psl_MAM_avg_float = dble2flt(rcm_psl_MAM_avg)
  copy_VarMeta(rcm_psl_MAM_avg, rcm_psl_MAM_avg_float)
  rcm_psl_JJA_avg_float = dble2flt(rcm_psl_JJA_avg)
  copy_VarMeta(rcm_psl_JJA_avg, rcm_psl_JJA_avg_float)
  rcm_psl_SON_avg_float = dble2flt(rcm_psl_SON_avg)
  copy_VarMeta(rcm_psl_SON_avg, rcm_psl_SON_avg_float)
  rcm_psl_DJF_avg_float = dble2flt(rcm_psl_DJF_avg)
  copy_VarMeta(rcm_psl_DJF_avg, rcm_psl_DJF_avg_float)
  season3 = array_append_record(season2, rcm_psl_DJF_avg_float, 0)
  season4 = array_append_record(season3, rcm_psl_MAM_avg_float, 0)
  season5 =  array_append_record(season4, rcm_psl_JJA_avg_float, 0)
  season =  array_append_record(season5, rcm_psl_SON_avg_float, 0)

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
  cnres@cnLevelSelectionMode = "ManualLevels"
  cnres@cnMinLevelValF = mnmxint(0)
  cnres@cnMaxLevelValF = mnmxint(1)
  cnres@cnLevelSpacingF = mnmxint(2)

  cnres@gsnLeftString = "GDD DJF avg"
    map0(0)     = gsn_csm_map(wks1,mpres)
    contour0(0) = gsn_csm_contour(wks1,gdd_psl_DJF_avg,cnres)
    vector0(0)  = gsn_csm_vector(wks1,gdd_ua_DJF_avg,gdd_va_DJF_avg,res_vc)
    overlay(map0(0),contour0(0))
    overlay(map0(0),vector0(0))
  ;plot2(0) = gsn_csm_vector_scalar_map_ce(wks1, gdd_ua_DJF_avg, gdd_va_DJF_avg, gdd_psl_DJF_avg, res)

  cnres@gsnLeftString = "GDD MAM avg"
    map0(1)     = gsn_csm_map(wks1,mpres)
    contour0(1) = gsn_csm_contour(wks1,gdd_psl_MAM_avg,cnres)
    vector0(1)  = gsn_csm_vector(wks1,gdd_ua_MAM_avg,gdd_va_MAM_avg,res_vc)
    overlay(map0(1),contour0(1))
    overlay(map0(1),vector0(1))
  ;plot2(1) = gsn_csm_vector_scalar_map_ce(wks1, gdd_ua_MAM_avg, gdd_va_MAM_avg, gdd_psl_MAM_avg, res)

  cnres@gsnLeftString = "GDD JJA avg"
    map0(2)     = gsn_csm_map(wks1,mpres)
    contour0(2) = gsn_csm_contour(wks1,gdd_psl_JJA_avg,cnres)
    vector0(2)  = gsn_csm_vector(wks1,gdd_ua_JJA_avg,gdd_va_JJA_avg,res_vc)
    overlay(map0(2),contour0(2))
    overlay(map0(2),vector0(2))
  ;plot2(2) = gsn_csm_vector_scalar_map_ce(wks1, gdd_ua_JJA_avg, gdd_va_JJA_avg, gdd_psl_JJA_avg, res)

  cnres@gsnLeftString = "GDD SON avg"
    map0(3)     = gsn_csm_map(wks1,mpres)
    contour0(3) = gsn_csm_contour(wks1,gdd_psl_SON_avg,cnres)
    vector0(3)  = gsn_csm_vector(wks1,gdd_ua_SON_avg,gdd_va_SON_avg,res_vc)
    overlay(map0(3),contour0(3))
    overlay(map0(3),vector0(3))
  ;plot2(3) = gsn_csm_vector_scalar_map_ce(wks1, gdd_ua_SON_avg, gdd_va_SON_avg, gdd_psl_SON_avg, res)
;
; RCM
  cnres@gsnLeftString = "RCM DJF avg"
  map0(5)     = gsn_csm_map(wks1,mpres)
  contour0(5) = gsn_csm_contour(wks1,rcm_psl_DJF_avg,cnres)
  vector0(5)  = gsn_csm_vector(wks1,rcm_ua_DJF_avg,rcm_va_DJF_avg,res_vc)
  overlay(map0(5),contour0(5))
  overlay(map0(5),vector0(5))
  ;plot4(4) = gsn_csm_vector_scalar_map_ce(wks1, rcm_ua_DJF_avg, rcm_va_DJF_avg, rcm_psl_DJF_avg, res)

  cnres@gsnLeftString = "RCM MAM avg"
  map0(6)     = gsn_csm_map(wks1,mpres)
  contour0(6) = gsn_csm_contour(wks1,rcm_psl_MAM_avg,cnres)
  vector0(6)  = gsn_csm_vector(wks1,rcm_ua_MAM_avg,rcm_va_MAM_avg,res_vc)
  overlay(map0(6),contour0(6))
  overlay(map0(6),vector0(6))
  ;plot4(5) = gsn_csm_vector_scalar_map_ce(wks1, rcm_ua_MAM_avg, rcm_va_MAM_avg, rcm_psl_MAM_avg, res)

  cnres@gsnLeftString = "RCM JJA avg"
  map0(7)     = gsn_csm_map(wks1,mpres)
  contour0(7) = gsn_csm_contour(wks1,rcm_psl_JJA_avg,cnres)
  vector0(7)  = gsn_csm_vector(wks1,rcm_ua_JJA_avg,rcm_va_JJA_avg,res_vc)
  overlay(map0(7),contour0(7))
  overlay(map0(7),vector0(7))
  ;plot4(6) = gsn_csm_vector_scalar_map_ce(wks1, rcm_ua_JJA_avg, rcm_va_JJA_avg, rcm_psl_JJA_avg, res)

  cnres@gsnLeftString = "RCM SON avg"
  map0(8)     = gsn_csm_map(wks1,mpres)
  contour0(8) = gsn_csm_contour(wks1,rcm_psl_SON_avg,cnres)
  vector0(8)  = gsn_csm_vector(wks1,rcm_ua_SON_avg,rcm_va_SON_avg,res_vc)
  overlay(map0(8),contour0(8))
  overlay(map0(8),vector0(8))
  ;plot4(7) = gsn_csm_vector_scalar_map_ce(wks1, rcm_ua_SON_avg, rcm_va_SON_avg, rcm_psl_SON_avg, res)


;  stats = stat_dispersion(gdd_psl_avg, False)
;  dmin = stats(3)
;  dmax = stats(13)
;  mmin = stats(2)
;  mmax = stats(14)
;  ; calculate which is larger
;  mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
;;  if dmin .eq. dmax then
;;    if abs(mmin) .gt. abs(mmax) then
;;      mnmxint = nice_mnmxintvl(mmin, abs(mmin), 18, False)
;;    else if abs(mmax) .gt. abs(mmin) then
;;      mnmxint = nice_mnmxintvl(abs(mmax)*(-1), abs(mmax), 18, False)
;;    end if
;;    end if
;;  else
;;    if abs(dmin) .gt. abs(dmax) then
;;      mnmxint = nice_mnmxintvl(dmin, abs(dmin), 18, False)
;;    else if abs(dmax) .gt. abs(dmin) then
;;      mnmxint = nice_mnmxintvl(abs(dmax)*(-1), abs(dmax), 18, False)
;;    end if
;;    end if
;;  end if
;  cnres@cnMinLevelValF = mnmxint(0)
;  cnres@cnMaxLevelValF = mnmxint(1)
;  cnres@cnLevelSpacingF = mnmxint(2)
;
;  cnres@gsnLeftString = "MON avg"
;    map0(16)     = gsn_csm_map(wks1,mpres)
;    contour0(16) = gsn_csm_contour(wks1,gdd_psl_avg,cnres)
;    vector0(16)  = gsn_csm_vector(wks1,gdd_ua_avg,gdd_va_avg,res_vc)
;    overlay(map0(16),contour0(16))
;    overlay(map0(16),vector0(16))
;  ;plot2(16) = gsn_csm_vector_scalar_map_ce(wks1, gdd_ua_avg, gdd_va_avg, gdd_psl_avg, res)
  print("appending annual arrays")
  rcm_psl_ann_avg_float = dble2flt(rcm_psl_ann_avg)
  copy_VarMeta(rcm_psl_ann_avg, rcm_psl_ann_avg_float)
  annual = array_append_record(gdd_psl_ann_avg, rcm_psl_ann_avg_float, 0)

  stats = stat_dispersion(annual, False)
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
  cnres@cnMinLevelValF = mnmxint(0)
  cnres@cnMaxLevelValF = mnmxint(1)
  cnres@cnLevelSpacingF = mnmxint(2)

  cnres@gsnLeftString = "GDD ANN avg"
  map0(4)     = gsn_csm_map(wks1,mpres)
  contour0(4) = gsn_csm_contour(wks1,gdd_psl_ann_avg,cnres)
  vector0(4)  = gsn_csm_vector(wks1,gdd_ua_ann_avg,gdd_va_ann_avg,res_vc)
  overlay(map0(4),contour0(4))
  overlay(map0(4),vector0(4))
  ;plot2(4) = gsn_csm_vector_scalar_map_ce(wks1, gdd_ua_ann_avg, gdd_va_ann_avg, gdd_psl_ann_avg, res)

  cnres@gsnLeftString = "RCM ANN avg"
  map0(9)     = gsn_csm_map(wks1,mpres)
  contour0(9) = gsn_csm_contour(wks1,rcm_psl_ann_avg,cnres)
  vector0(9)  = gsn_csm_vector(wks1,rcm_ua_ann_avg,rcm_va_ann_avg,res_vc)
  overlay(map0(9),contour0(9))
  overlay(map0(9),vector0(9))
  ;plot4(9) = gsn_csm_vector_scalar_map_ce(wks1, rcm_ua_ann_avg, rcm_va_ann_avg, rcm_psl_ann_avg, res)
  delete([/stats, dmin, dmax, mmin, mmax, mnmxint, cnres@cnMinLevelValF, cnres@cnMaxLevelValF, cnres@cnLevelSpacingF, season0, season1, season/])

; difference
  psl_ann_avg_diff = rcm_psl_ann_avg
  psl_ann_avg_diff = rcm_psl_ann_avg - gdd_psl_ann_avg
  ua_ann_avg_diff = rcm_ua_ann_avg
  ua_ann_avg_diff = rcm_ua_ann_avg - gdd_ua_ann_avg
  va_ann_avg_diff = rcm_va_ann_avg
  va_ann_avg_diff = rcm_va_ann_avg - gdd_va_ann_avg

  psl_DJF_avg_diff = rcm_psl_DJF_avg
  psl_DJF_avg_diff = rcm_psl_DJF_avg - gdd_psl_DJF_avg
  ua_DJF_avg_diff = rcm_ua_DJF_avg
  ua_DJF_avg_diff = rcm_ua_DJF_avg - gdd_ua_DJF_avg
  va_DJF_avg_diff = rcm_va_DJF_avg
  va_DJF_avg_diff = rcm_va_DJF_avg - gdd_va_DJF_avg

  psl_MAM_avg_diff = rcm_psl_MAM_avg
  psl_MAM_avg_diff = rcm_psl_MAM_avg - gdd_psl_MAM_avg
  ua_MAM_avg_diff = rcm_ua_MAM_avg
  ua_MAM_avg_diff = rcm_ua_MAM_avg - gdd_ua_MAM_avg
  va_MAM_avg_diff = rcm_va_MAM_avg
  va_MAM_avg_diff = rcm_va_MAM_avg - gdd_va_MAM_avg

  psl_JJA_avg_diff = rcm_psl_JJA_avg
  psl_JJA_avg_diff = rcm_psl_JJA_avg - gdd_psl_JJA_avg
  ua_JJA_avg_diff = rcm_ua_JJA_avg
  ua_JJA_avg_diff = rcm_ua_JJA_avg - gdd_ua_JJA_avg
  va_JJA_avg_diff = rcm_va_JJA_avg
  va_JJA_avg_diff = rcm_va_JJA_avg - gdd_va_JJA_avg

  psl_SON_avg_diff = rcm_psl_SON_avg
  psl_SON_avg_diff = rcm_psl_SON_avg - gdd_psl_SON_avg
  ua_SON_avg_diff = rcm_ua_SON_avg
  ua_SON_avg_diff = rcm_ua_SON_avg - gdd_ua_SON_avg
  va_SON_avg_diff = rcm_va_SON_avg
  va_SON_avg_diff = rcm_va_SON_avg - gdd_va_SON_avg

  seasonal0 = array_append_record(psl_DJF_avg_diff, psl_MAM_avg_diff, 0)
  seasonal1 = array_append_record(seasonal0, psl_JJA_avg_diff, 0)
  seasonal = array_append_record(seasonal1, psl_SON_avg_diff, 0)

  stats = stat_dispersion(seasonal, False)
  dmin = stats(3)
  dmax = stats(13)
  mmin = stats(2)
  mmax = stats(14)
  ; calculate which is larger
  mnmxint = nice_mnmxintvl(mmin, mmax, 18, False)
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
  cnres@cnMinLevelValF = mnmxint(0)
  cnres@cnMaxLevelValF = mnmxint(1)
  cnres@cnLevelSpacingF = mnmxint(2)

  res_vc@vcRefMagnitudeF           = 2.0 
  cnres@gsnLeftString = "RCM-GDD DJF avg"
  map0(10)     = gsn_csm_map(wks1,mpres)
  contour0(10) = gsn_csm_contour(wks1,psl_DJF_avg_diff,cnres)
  vector0(10)  = gsn_csm_vector(wks1,ua_DJF_avg_diff,va_DJF_avg_diff,res_vc)
  overlay(map0(10),contour0(10))
  overlay(map0(10),vector0(10))

  cnres@gsnLeftString = "RCM-GDD MAM avg"
  map0(11)     = gsn_csm_map(wks1,mpres)
  contour0(11) = gsn_csm_contour(wks1,psl_MAM_avg_diff,cnres)
  vector0(11)  = gsn_csm_vector(wks1,ua_MAM_avg_diff,va_MAM_avg_diff,res_vc)
  overlay(map0(11),contour0(11))
  overlay(map0(11),vector0(11))

  cnres@gsnLeftString = "RCM-GDD JJA avg"
  map0(12)     = gsn_csm_map(wks1,mpres)
  contour0(12) = gsn_csm_contour(wks1,psl_JJA_avg_diff,cnres)
  vector0(12)  = gsn_csm_vector(wks1,ua_JJA_avg_diff,va_JJA_avg_diff,res_vc)
  overlay(map0(12),contour0(12))
  overlay(map0(12),vector0(12))

  cnres@gsnLeftString = "RCM-GDD SON avg"
  map0(13)     = gsn_csm_map(wks1,mpres)
  contour0(13) = gsn_csm_contour(wks1,psl_SON_avg_diff,cnres)
  vector0(13)  = gsn_csm_vector(wks1,ua_SON_avg_diff,va_SON_avg_diff,res_vc)
  overlay(map0(13),contour0(13))
  overlay(map0(13),vector0(13))

  cnres@gsnLeftString = "RCM-GDD ANN avg"
  map0(14)     = gsn_csm_map(wks1,mpres)
  contour0(14) = gsn_csm_contour(wks1,psl_ann_avg_diff,cnres)
  vector0(14)  = gsn_csm_vector(wks1,ua_ann_avg_diff,va_ann_avg_diff,res_vc)
  overlay(map0(14),contour0(14))
  overlay(map0(14),vector0(14))

  units = gdd_psl_ann_avg@units
; Panel plots
  resP                    = True
  resP@gsnPanelMainString = "Average "+yrStrt+"-"+yrLast+"~C~"+info+" ("+units+")"
  resP@gsnPanelLabelBar = False
  resP@gsnMaximize = True
  gsn_panel(wks1, map0, (/3, 5/), resP)

  fout = addfile("../calculated/plots/plot_"+var+"_seasonal_annual_average_no_agcd_vectors_automate.nc", "c")
  fout->psl_ann_avg_diff = psl_ann_avg_diff
  fout->psl_DJF_avg_diff = psl_DJF_avg_diff
  fout->psl_MAM_avg_diff = psl_MAM_avg_diff
  fout->psl_JJA_avg_diff = psl_JJA_avg_diff
  fout->psl_SON_avg_diff = psl_SON_avg_diff
  fout->ua_ann_avg_diff = ua_ann_avg_diff
  fout->ua_DJF_avg_diff = ua_DJF_avg_diff
  fout->ua_MAM_avg_diff = ua_MAM_avg_diff
  fout->ua_JJA_avg_diff = ua_JJA_avg_diff
  fout->ua_SON_avg_diff = ua_SON_avg_diff
  fout->va_ann_avg_diff = va_ann_avg_diff
  fout->va_DJF_avg_diff = va_DJF_avg_diff
  fout->va_MAM_avg_diff = va_MAM_avg_diff
  fout->va_JJA_avg_diff = va_JJA_avg_diff
  fout->va_SON_avg_diff = va_SON_avg_diff
end