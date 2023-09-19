load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
  rad    = 4.0*atan(1.0)/180.0
  re     = 6371220.0
  rr     = re*rad

  maskf = addfile("/g/data/xv83/users/bxn599/CaRSA/mask_files/barpa_15_masks.nc","r")
  aus_mask = maskf->australia_mask

  fhistl = systemfunc("ls /g/data/ia39/australian-climate-service/release/CORDEX-CMIP6/output/AUS-15/BOM/EC-Earth-Consortium-EC-Earth3/historical/r1i1p1f1/BOM-BARPA-R/v1/mon/pr/*.nc")
  fsspl = systemfunc("ls /g/data/ia39/australian-climate-service/release/CORDEX-CMIP6/output/AUS-15/BOM/EC-Earth-Consortium-EC-Earth3/ssp370/r1i1p1f1/BOM-BARPA-R/v1/mon/pr/*.nc")

  hist = addfiles(fhistl, "r")
  pr_hist = hist[:]->pr
  pr_hist = pr_hist*86400
  pr_hist@units = "mm/day"
  pr_hist = mask(pr_hist, aus_mask, 0)

  date_hist = cd_calendar(pr_hist&time, -1)
  st0 = ind(date_hist.eq.199501)
  ed0 = ind(date_hist.eq.201412)

  pr_hist_res = pr_hist(st0:ed0,{-44.5:-10.02},{111.9:156.3})
  pr_hist_res_avg = dim_avg_n_Wrap(pr_hist_res, 0)
  pr_hist_res_all_avg = avg(pr_hist_res)

  lat   = pr_hist_res&lat
  lon   = pr_hist_res&lon
  jlat  = dimsizes( lat )
  dlon   = abs(lon(2)-lon(1))*rr
  dx     = dlon*cos(lat*rad)
;                                     lat can have variable spacing
  dy     = new ( jlat, typeof(dx))
                                                            ; close enough
  dy(0)  = abs(lat(2)-lat(1))*rr
  dy(1:jlat-2)  = abs(lat(2:jlat-1)-lat(0:jlat-3))*rr*0.5   
  dy(jlat-1)    = abs(lat(jlat-1)-lat(jlat-2))*rr

  area   = dx*dy                                ; cell area function of latitude only

  clat   = cos(lat*rad)

  pr_hist_res_avg_area = wgt_areaave_Wrap(pr_hist_res_avg, area, 1.0, 1)
  pr_hist_res_avg_clat = wgt_areaave_Wrap(pr_hist_res_avg, clat, 1.0, 1)

  fut = addfiles(fsspl, "r")
  pr_fut = fut[:]->pr
  pr_fut = pr_fut*86400
  pr_fut@units = "mm/day"
  pr_fut = mask(pr_fut, aus_mask, 0)

  date_fut = cd_calendar(pr_fut&time, -1)
  st1 = ind(date_fut.eq.202001)
  ed1 = ind(date_fut.eq.203912)
  st2 = ind(date_fut.eq.204001)
  ed2 = ind(date_fut.eq.205912)
  st3 = ind(date_fut.eq.206001)
  ed3 = ind(date_fut.eq.207912)
  st4 = ind(date_fut.eq.208001)
  ed4 = ind(date_fut.eq.209912)

  pr_fut_res1 = pr_fut(st1:ed1,{-44.5:-10.02},{111.9:156.3})
  pr_fut_res1_avg = dim_avg_n_Wrap(pr_fut_res1, 0)
  pr_fut_res1_all_avg = avg(pr_fut_res1)
  pr_fut_res1_avg_area = wgt_areaave_Wrap(pr_fut_res1_avg, area, 1.0, 1)
  pr_fut_res1_avg_clat = wgt_areaave_Wrap(pr_fut_res1_avg, clat, 1.0, 1)

  pr_fut_res2 = pr_fut(st2:ed2,{-44.5:-10.02},{111.9:156.3})
  pr_fut_res2_avg = dim_avg_n_Wrap(pr_fut_res2, 0)
  pr_fut_res2_all_avg = avg(pr_fut_res2)
  pr_fut_res2_avg_area = wgt_areaave_Wrap(pr_fut_res2_avg, area, 1.0, 1)
  pr_fut_res2_avg_clat = wgt_areaave_Wrap(pr_fut_res2_avg, clat, 1.0, 1)

  pr_fut_res3 = pr_fut(st3:ed3,{-44.5:-10.02},{111.9:156.3})
  pr_fut_res3_avg = dim_avg_n_Wrap(pr_fut_res3, 0)
  pr_fut_res3_all_avg = avg(pr_fut_res3)
  pr_fut_res3_avg_area = wgt_areaave_Wrap(pr_fut_res3_avg, area, 1.0, 1)
  pr_fut_res3_avg_clat = wgt_areaave_Wrap(pr_fut_res3_avg, clat, 1.0, 1)

  pr_fut_res4 = pr_fut(st4:ed4,{-44.5:-10.02},{111.9:156.3})
  pr_fut_res4_avg = dim_avg_n_Wrap(pr_fut_res4, 0)
  pr_fut_res4_all_avg = avg(pr_fut_res4)
  pr_fut_res4_avg_area = wgt_areaave_Wrap(pr_fut_res4_avg, area, 1.0, 1)
  pr_fut_res4_avg_clat = wgt_areaave_Wrap(pr_fut_res4_avg, clat, 1.0, 1)

  printVarSummary(pr_hist_res_avg)
  printVarSummary(pr_fut_res1_avg)
  printVarSummary(pr_fut_res2_avg)
  printVarSummary(pr_fut_res3_avg)
  printVarSummary(pr_fut_res4_avg)

; time avg before spatial
  print("time avg before spatial")
  pr_diff1 = pr_fut_res1_avg
  pr_diff1 = (pr_fut_res1_avg - pr_hist_res_avg)/pr_hist_res_avg*100
  pr_diff1_avg = avg(pr_diff1)
  print(pr_diff1_avg)

  pr_diff2 = pr_fut_res2_avg
  pr_diff2 = (pr_fut_res2_avg - pr_hist_res_avg)/pr_hist_res_avg*100
  pr_diff2_avg = avg(pr_diff2)
  print(pr_diff2_avg)

  pr_diff3 = pr_fut_res3_avg
  pr_diff3 = (pr_fut_res3_avg - pr_hist_res_avg)/pr_hist_res_avg*100
  pr_diff3_avg = avg(pr_diff3)
  print(pr_diff3_avg)

  pr_diff4 = pr_fut_res4_avg
  pr_diff4 = (pr_fut_res4_avg - pr_hist_res_avg)/pr_hist_res_avg*100
  pr_diff4_avg = avg(pr_diff4)
  print(pr_diff4_avg)

; average all at once
;  print("average all at once")
;  diff_all_avg1 = pr_fut_res1_all_avg
;  diff_all_avg1 = (pr_fut_res1_all_avg - pr_hist_res_all_avg)/pr_hist_res_all_avg*100
;  print(diff_all_avg1)
;
;  diff_all_avg2 = pr_fut_res2_all_avg
;  diff_all_avg2 = (pr_fut_res2_all_avg - pr_hist_res_all_avg)/pr_hist_res_all_avg*100
;  print(diff_all_avg2)
;
;  diff_all_avg3 = pr_fut_res3_all_avg
;  diff_all_avg3 = (pr_fut_res3_all_avg - pr_hist_res_all_avg)/pr_hist_res_all_avg*100
;  print(diff_all_avg3)
;
;  diff_all_avg4 = pr_fut_res4_all_avg
;  diff_all_avg4 = (pr_fut_res4_all_avg - pr_hist_res_all_avg)/pr_hist_res_all_avg*100
;  print(diff_all_avg4)
;
;; grid cell weighting
;  print("grid cell weighting")
;  diff_area_avg1 = pr_fut_res1_avg_area
;  diff_area_avg1 = (pr_fut_res1_avg_area - pr_hist_res_avg_area)/pr_hist_res_avg_area*100
;  print(diff_area_avg1)
;
;  diff_area_avg2 = pr_fut_res2_avg_area
;  diff_area_avg2 = (pr_fut_res2_avg_area - pr_hist_res_avg_area)/pr_hist_res_avg_area*100
;  print(diff_area_avg2)
;
;  diff_area_avg3 = pr_fut_res3_avg_area
;  diff_area_avg3 = (pr_fut_res3_avg_area - pr_hist_res_avg_area)/pr_hist_res_avg_area*100
;  print(diff_area_avg3)
;
;  diff_area_avg4 = pr_fut_res4_avg_area
;  diff_area_avg4 = (pr_fut_res4_avg_area - pr_hist_res_avg_area)/pr_hist_res_avg_area*100
;  print(diff_area_avg4)
;
;; cosine of latitudes
;  print("cosine of latitudes")
;  diff_clat_avg1 = pr_fut_res1_avg_clat
;  diff_clat_avg1 = (pr_fut_res1_avg_clat - pr_hist_res_avg_clat)/pr_hist_res_avg_clat*100
;  print(diff_clat_avg1)
;
;  diff_clat_avg2 = pr_fut_res2_avg_clat
;  diff_clat_avg2 = (pr_fut_res2_avg_clat - pr_hist_res_avg_clat)/pr_hist_res_avg_clat*100
;  print(diff_clat_avg2)
;
;  diff_clat_avg3 = pr_fut_res3_avg_clat
;  diff_clat_avg3 = (pr_fut_res3_avg_clat - pr_hist_res_avg_clat)/pr_hist_res_avg_clat*100
;  print(diff_clat_avg3)
;
;  diff_clat_avg4 = pr_fut_res4_avg_clat
;  diff_clat_avg4 = (pr_fut_res4_avg_clat - pr_hist_res_avg_clat)/pr_hist_res_avg_clat*100
;  print(diff_clat_avg4)


end