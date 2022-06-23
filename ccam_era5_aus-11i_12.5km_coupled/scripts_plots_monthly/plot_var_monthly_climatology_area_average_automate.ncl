; plot Added Value (AV)

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
  rad = 4.0*atan(1.0)/180.0
  red  = 6371220.0
  rr  = red*rad

  f = addfile("../calculated/"+run_name+"_"+var+"_bias_rmse_monthly_means_awap_grid.nc", "r")

; mask files
  nrm_maskf = addfile("/g/data/xv83/bxn599/CaRSA/mask_files/sftrf_AWAP0.05_NRMv3.nc", "r")
  ar6_maskf = addfile("/g/data/xv83/bxn599/CaRSA/mask_files/ar6_ipcc_mask.nc", "r")
  ar6 = ar6_maskf->ar6_aus_mask
  wt = nrm_maskf->WT ; wet tropics
  sswfw = nrm_maskf->SSWFW ; southern and south-western flatlands west
  sswfe = nrm_maskf->SSWFE ; southern and south-western flatlands east
  sswf = nrm_maskf->SSWF ; southern and south-western flatlands
  ssvw = nrm_maskf->SSVW ; southern slopes vic west
  ssve = nrm_maskf->SSVE ; southern slopes vic east
  sstw2 = nrm_maskf->SSTW2 ; southern slopes tas west 2
  sstw = nrm_maskf->SSTW ; southern slopes tas west
  sste2 = nrm_maskf->SSTE2 ; southern slopes tas east 2
  sste = nrm_maskf->SSTE ; southern slopes tas east
  ss = nrm_maskf->SS ; southern slopes
  sau = nrm_maskf->SAU ; southern aus, not used
  sa = nrm_maskf->SA ; southern aus
  rw = nrm_maskf->RW ; rangelands west, not used
  rs = nrm_maskf->RS ; rangelands south
  rn = nrm_maskf->RN ; rangelands north
  re = nrm_maskf->RE ; rangelands east, not used
  r = nrm_maskf->R ; rangelands
  nau = nrm_maskf->NAU ; northern aus, not used
  na = nrm_maskf->NA ; northern aus
  mnw = nrm_maskf->MNW ; monsoonal north west
  mne = nrm_maskf->MNE ; monsoonal north east
  mn = nrm_maskf->MN ; monsoonal north
  mb = nrm_maskf->MB ; murray basin
  ecs = nrm_maskf->ECS ; east coast south
  ecn = nrm_maskf->ECN ; east coast north
  ec = nrm_maskf->EC ; east coast
  ea = nrm_maskf->EA ; eastern aus
  cs = nrm_maskf->CS ; central slopes
  aus = nrm_maskf->AUS

; data is already on same grid and ocean has been masked
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

  date = cd_calendar(obs&time, 0)
  year =  floattointeger(date(:,0))
  month = floattointeger(date(:,1))

  dim = days_in_month(year, month)

  dimConform = conform_dims(dimsizes(obs), dim, 0)

  new_time = cd_convert(obs&time, "days since 0001-01-01 00:00:00")

  delete(obs&time)
  delete(gdd&time)
  delete(rcm&time)
  obs&time = new_time
  rcm&time = new_time
  gdd&time = new_time

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
  obs_dims = dimsizes(obs(0::12,:,:))

  obs_mon = new((/12, obs_dims(0), obs_dims(1), obs_dims(2)/),typeof(obs))
  test_mon = new((/12, obs_dims(0), obs_dims(1), obs_dims(2)/),typeof(obs))
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

  if var.eq."pr" then
    obs_mon(0,:,:,:) = obs_mon(0,:,:,:)*31
    obs_mon(1,:,:,:) = obs_mon(1,:,:,:)*dimConform(1::12,:,:) ; for leap years
    obs_mon(2,:,:,:) = obs_mon(2,:,:,:)*31
    obs_mon(3,:,:,:) = obs_mon(3,:,:,:)*30
    obs_mon(4,:,:,:) = obs_mon(4,:,:,:)*31
    obs_mon(5,:,:,:) = obs_mon(5,:,:,:)*30
    obs_mon(6,:,:,:) = obs_mon(6,:,:,:)*31
    obs_mon(7,:,:,:) = obs_mon(7,:,:,:)*31
    obs_mon(8,:,:,:) = obs_mon(8,:,:,:)*30
    obs_mon(9,:,:,:) = obs_mon(9,:,:,:)*31
    obs_mon(10,:,:,:) = obs_mon(10,:,:,:)*30
    obs_mon(11,:,:,:) = obs_mon(11,:,:,:)*31
    obs_mon@units = "mm/month"
  end if

  obs_mon_avg = dim_avg_n_Wrap(obs_mon, 1)
  obs_mon_avg_aus_aave = wgt_areaave_Wrap(obs_mon_avg, weights, 1.0, 0) ; whole of aus area average, monthly climatology

; split into nrm clusters and mask
  ; monthly climatology
  obs_mon_avg_cs = obs_mon_avg
  obs_mon_avg_cs = mask(obs_mon_avg, cs, 1)
  obs_mon_avg_cs_aave = wgt_areaave_Wrap(obs_mon_avg_cs, weights, 1.0, 0)
  obs_mon_avg_ecn = obs_mon_avg
  obs_mon_avg_ecn = mask(obs_mon_avg, ecn, 1)
  obs_mon_avg_ecn_aave = wgt_areaave_Wrap(obs_mon_avg_ecn, weights, 1.0, 0)
  obs_mon_avg_ecs = obs_mon_avg
  obs_mon_avg_ecs = mask(obs_mon_avg, ecs, 1)
  obs_mon_avg_ecs_aave = wgt_areaave_Wrap(obs_mon_avg_ecs, weights, 1.0, 0)
  obs_mon_avg_mne = obs_mon_avg
  obs_mon_avg_mne = mask(obs_mon_avg, mne, 1)
  obs_mon_avg_mne_aave = wgt_areaave_Wrap(obs_mon_avg_mne, weights, 1.0, 0)
  obs_mon_avg_mnw = obs_mon_avg
  obs_mon_avg_mnw = mask(obs_mon_avg, mnw, 1)
  obs_mon_avg_mnw_aave = wgt_areaave_Wrap(obs_mon_avg_mnw, weights, 1.0, 0)
  obs_mon_avg_mb = obs_mon_avg
  obs_mon_avg_mb = mask(obs_mon_avg, mb, 1)
  obs_mon_avg_mb_aave = wgt_areaave_Wrap(obs_mon_avg_mb, weights, 1.0, 0)
  obs_mon_avg_rn = obs_mon_avg
  obs_mon_avg_rn = mask(obs_mon_avg, rn, 1)
  obs_mon_avg_rn_aave = wgt_areaave_Wrap(obs_mon_avg_rn, weights, 1.0, 0)
  obs_mon_avg_rs = obs_mon_avg
  obs_mon_avg_rs = mask(obs_mon_avg, rs, 1)
  obs_mon_avg_rs_aave = wgt_areaave_Wrap(obs_mon_avg_rs, weights, 1.0, 0)
  obs_mon_avg_sste = obs_mon_avg
  obs_mon_avg_sste = mask(obs_mon_avg, sste, 1)
  obs_mon_avg_sste_aave = wgt_areaave_Wrap(obs_mon_avg_sste, weights, 1.0, 0)
  obs_mon_avg_sstw = obs_mon_avg
  obs_mon_avg_sstw = mask(obs_mon_avg, sstw, 1)
  obs_mon_avg_sstw_aave = wgt_areaave_Wrap(obs_mon_avg_sstw, weights, 1.0, 0)
  obs_mon_avg_ssvw = obs_mon_avg
  obs_mon_avg_ssvw = mask(obs_mon_avg, ssvw, 1)
  obs_mon_avg_ssvw_aave = wgt_areaave_Wrap(obs_mon_avg_ssvw, weights, 1.0, 0)
  obs_mon_avg_ssve = obs_mon_avg
  obs_mon_avg_ssve = mask(obs_mon_avg, ssve, 1)
  obs_mon_avg_ssve_aave = wgt_areaave_Wrap(obs_mon_avg_ssve, weights, 1.0, 0)
  obs_mon_avg_sswfe = obs_mon_avg
  obs_mon_avg_sswfe = mask(obs_mon_avg, sswfe, 1)
  obs_mon_avg_sswfe_aave = wgt_areaave_Wrap(obs_mon_avg_sswfe, weights, 1.0, 0)
  obs_mon_avg_sswfw = obs_mon_avg
  obs_mon_avg_sswfw = mask(obs_mon_avg, sswfw, 1)
  obs_mon_avg_sswfw_aave = wgt_areaave_Wrap(obs_mon_avg_sswfw, weights, 1.0, 0)
  obs_mon_avg_wt = obs_mon_avg
  obs_mon_avg_wt = mask(obs_mon_avg, wt, 1)
  obs_mon_avg_wt_aave = wgt_areaave_Wrap(obs_mon_avg_wt, weights, 1.0, 0)
  ; ar6
  obs_mon_avg_ar6_na = obs_mon_avg
  obs_mon_avg_ar6_na = mask(obs_mon_avg, ar6, 39)
  obs_mon_avg_ar6_na_aave = wgt_areaave_Wrap(obs_mon_avg_ar6_na, weights, 1.0, 0)
  obs_mon_avg_ar6_ca = obs_mon_avg
  obs_mon_avg_ar6_ca = mask(obs_mon_avg, ar6, 40)
  obs_mon_avg_ar6_ca_aave = wgt_areaave_Wrap(obs_mon_avg_ar6_ca, weights, 1.0, 0)
  obs_mon_avg_ar6_ea = obs_mon_avg
  obs_mon_avg_ar6_ea = mask(obs_mon_avg, ar6, 41)
  obs_mon_avg_ar6_ea_aave = wgt_areaave_Wrap(obs_mon_avg_ar6_ea, weights, 1.0, 0)
  obs_mon_avg_ar6_sa = obs_mon_avg
  obs_mon_avg_ar6_sa = mask(obs_mon_avg, ar6, 42)
  obs_mon_avg_ar6_sa_aave = wgt_areaave_Wrap(obs_mon_avg_ar6_sa, weights, 1.0, 0)

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

  if var.eq."pr" then
    rcm_mon(0,:,:,:) = rcm_mon(0,:,:,:)*31
    rcm_mon(1,:,:,:) = rcm_mon(1,:,:,:)*dimConform(1::12,:,:) ; for leap years
    rcm_mon(2,:,:,:) = rcm_mon(2,:,:,:)*31
    rcm_mon(3,:,:,:) = rcm_mon(3,:,:,:)*30
    rcm_mon(4,:,:,:) = rcm_mon(4,:,:,:)*31
    rcm_mon(5,:,:,:) = rcm_mon(5,:,:,:)*30
    rcm_mon(6,:,:,:) = rcm_mon(6,:,:,:)*31
    rcm_mon(7,:,:,:) = rcm_mon(7,:,:,:)*31
    rcm_mon(8,:,:,:) = rcm_mon(8,:,:,:)*30
    rcm_mon(9,:,:,:) = rcm_mon(9,:,:,:)*31
    rcm_mon(10,:,:,:) = rcm_mon(10,:,:,:)*30
    rcm_mon(11,:,:,:) = rcm_mon(11,:,:,:)*31
    rcm_mon@units = "mm/month"
  end if

  rcm_mon_avg = dim_avg_n_Wrap(rcm_mon, 1)
  rcm_mon_avg_aus_aave = wgt_areaave_Wrap(rcm_mon_avg, weights, 1.0, 0) ; whole of aus area average, monthly climatology

; split into nrm clusters and mask
  ; monthly climatology
  rcm_mon_avg_cs = rcm_mon_avg
  rcm_mon_avg_cs = mask(rcm_mon_avg, cs, 1)
  rcm_mon_avg_cs_aave = wgt_areaave_Wrap(rcm_mon_avg_cs, weights, 1.0, 0)
  rcm_mon_avg_ecn = rcm_mon_avg
  rcm_mon_avg_ecn = mask(rcm_mon_avg, ecn, 1)
  rcm_mon_avg_ecn_aave = wgt_areaave_Wrap(rcm_mon_avg_ecn, weights, 1.0, 0)
  rcm_mon_avg_ecs = rcm_mon_avg
  rcm_mon_avg_ecs = mask(rcm_mon_avg, ecs, 1)
  rcm_mon_avg_ecs_aave = wgt_areaave_Wrap(rcm_mon_avg_ecs, weights, 1.0, 0)
  rcm_mon_avg_mne = rcm_mon_avg
  rcm_mon_avg_mne = mask(rcm_mon_avg, mne, 1)
  rcm_mon_avg_mne_aave = wgt_areaave_Wrap(rcm_mon_avg_mne, weights, 1.0, 0)
  rcm_mon_avg_mnw = rcm_mon_avg
  rcm_mon_avg_mnw = mask(rcm_mon_avg, mnw, 1)
  rcm_mon_avg_mnw_aave = wgt_areaave_Wrap(rcm_mon_avg_mnw, weights, 1.0, 0)
  rcm_mon_avg_mb = rcm_mon_avg
  rcm_mon_avg_mb = mask(rcm_mon_avg, mb, 1)
  rcm_mon_avg_mb_aave = wgt_areaave_Wrap(rcm_mon_avg_mb, weights, 1.0, 0)
  rcm_mon_avg_rn = rcm_mon_avg
  rcm_mon_avg_rn = mask(rcm_mon_avg, rn, 1)
  rcm_mon_avg_rn_aave = wgt_areaave_Wrap(rcm_mon_avg_rn, weights, 1.0, 0)
  rcm_mon_avg_rs = rcm_mon_avg
  rcm_mon_avg_rs = mask(rcm_mon_avg, rs, 1)
  rcm_mon_avg_rs_aave = wgt_areaave_Wrap(rcm_mon_avg_rs, weights, 1.0, 0)
  rcm_mon_avg_sste = rcm_mon_avg
  rcm_mon_avg_sste = mask(rcm_mon_avg, sste, 1)
  rcm_mon_avg_sste_aave = wgt_areaave_Wrap(rcm_mon_avg_sste, weights, 1.0, 0)
  rcm_mon_avg_sstw = rcm_mon_avg
  rcm_mon_avg_sstw = mask(rcm_mon_avg, sstw, 1)
  rcm_mon_avg_sstw_aave = wgt_areaave_Wrap(rcm_mon_avg_sstw, weights, 1.0, 0)
  rcm_mon_avg_ssvw = rcm_mon_avg
  rcm_mon_avg_ssvw = mask(rcm_mon_avg, ssvw, 1)
  rcm_mon_avg_ssvw_aave = wgt_areaave_Wrap(rcm_mon_avg_ssvw, weights, 1.0, 0)
  rcm_mon_avg_ssve = rcm_mon_avg
  rcm_mon_avg_ssve = mask(rcm_mon_avg, ssve, 1)
  rcm_mon_avg_ssve_aave = wgt_areaave_Wrap(rcm_mon_avg_ssve, weights, 1.0, 0)
  rcm_mon_avg_sswfe = rcm_mon_avg
  rcm_mon_avg_sswfe = mask(rcm_mon_avg, sswfe, 1)
  rcm_mon_avg_sswfe_aave = wgt_areaave_Wrap(rcm_mon_avg_sswfe, weights, 1.0, 0)
  rcm_mon_avg_sswfw = rcm_mon_avg
  rcm_mon_avg_sswfw = mask(rcm_mon_avg, sswfw, 1)
  rcm_mon_avg_sswfw_aave = wgt_areaave_Wrap(rcm_mon_avg_sswfw, weights, 1.0, 0)
  rcm_mon_avg_wt = rcm_mon_avg
  rcm_mon_avg_wt = mask(rcm_mon_avg, wt, 1)
  rcm_mon_avg_wt_aave = wgt_areaave_Wrap(rcm_mon_avg_wt, weights, 1.0, 0)
  ; ar6
  rcm_mon_avg_ar6_na = rcm_mon_avg
  rcm_mon_avg_ar6_na = mask(rcm_mon_avg, ar6, 39)
  rcm_mon_avg_ar6_na_aave = wgt_areaave_Wrap(rcm_mon_avg_ar6_na, weights, 1.0, 0)
  rcm_mon_avg_ar6_ca = rcm_mon_avg
  rcm_mon_avg_ar6_ca = mask(rcm_mon_avg, ar6, 40)
  rcm_mon_avg_ar6_ca_aave = wgt_areaave_Wrap(rcm_mon_avg_ar6_ca, weights, 1.0, 0)
  rcm_mon_avg_ar6_ea = rcm_mon_avg
  rcm_mon_avg_ar6_ea = mask(rcm_mon_avg, ar6, 41)
  rcm_mon_avg_ar6_ea_aave = wgt_areaave_Wrap(rcm_mon_avg_ar6_ea, weights, 1.0, 0)
  rcm_mon_avg_ar6_sa = rcm_mon_avg
  rcm_mon_avg_ar6_sa = mask(rcm_mon_avg, ar6, 42)
  rcm_mon_avg_ar6_sa_aave = wgt_areaave_Wrap(rcm_mon_avg_ar6_sa, weights, 1.0, 0)

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
  
  if var.eq."pr" then
    gdd_mon(0,:,:,:) = gdd_mon(0,:,:,:)*31
    gdd_mon(1,:,:,:) = gdd_mon(1,:,:,:)*dimConform(1::12,:,:) ; for leap years
    gdd_mon(2,:,:,:) = gdd_mon(2,:,:,:)*31
    gdd_mon(3,:,:,:) = gdd_mon(3,:,:,:)*30
    gdd_mon(4,:,:,:) = gdd_mon(4,:,:,:)*31
    gdd_mon(5,:,:,:) = gdd_mon(5,:,:,:)*30
    gdd_mon(6,:,:,:) = gdd_mon(6,:,:,:)*31
    gdd_mon(7,:,:,:) = gdd_mon(7,:,:,:)*31
    gdd_mon(8,:,:,:) = gdd_mon(8,:,:,:)*30
    gdd_mon(9,:,:,:) = gdd_mon(9,:,:,:)*31
    gdd_mon(10,:,:,:) = gdd_mon(10,:,:,:)*30
    gdd_mon(11,:,:,:) = gdd_mon(11,:,:,:)*31
    gdd_mon@units = "mm/month"
  end if

  gdd_mon_avg = dim_avg_n_Wrap(gdd_mon, 1)
  gdd_mon_avg_aus_aave = wgt_areaave_Wrap(gdd_mon_avg, weights, 1.0, 0) ; whole of aus area average, monthly climatology

; split into nrm clusters and mask
  ; monthly climatology
  gdd_mon_avg_cs = gdd_mon_avg
  gdd_mon_avg_cs = mask(gdd_mon_avg, cs, 1)
  gdd_mon_avg_cs_aave = wgt_areaave_Wrap(gdd_mon_avg_cs, weights, 1.0, 0)
  gdd_mon_avg_ecn = gdd_mon_avg
  gdd_mon_avg_ecn = mask(gdd_mon_avg, ecn, 1)
  gdd_mon_avg_ecn_aave = wgt_areaave_Wrap(gdd_mon_avg_ecn, weights, 1.0, 0)
  gdd_mon_avg_ecs = gdd_mon_avg
  gdd_mon_avg_ecs = mask(gdd_mon_avg, ecs, 1)
  gdd_mon_avg_ecs_aave = wgt_areaave_Wrap(gdd_mon_avg_ecs, weights, 1.0, 0)
  gdd_mon_avg_mne = gdd_mon_avg
  gdd_mon_avg_mne = mask(gdd_mon_avg, mne, 1)
  gdd_mon_avg_mne_aave = wgt_areaave_Wrap(gdd_mon_avg_mne, weights, 1.0, 0)
  gdd_mon_avg_mnw = gdd_mon_avg
  gdd_mon_avg_mnw = mask(gdd_mon_avg, mnw, 1)
  gdd_mon_avg_mnw_aave = wgt_areaave_Wrap(gdd_mon_avg_mnw, weights, 1.0, 0)
  gdd_mon_avg_mb = gdd_mon_avg
  gdd_mon_avg_mb = mask(gdd_mon_avg, mb, 1)
  gdd_mon_avg_mb_aave = wgt_areaave_Wrap(gdd_mon_avg_mb, weights, 1.0, 0)
  gdd_mon_avg_rn = gdd_mon_avg
  gdd_mon_avg_rn = mask(gdd_mon_avg, rn, 1)
  gdd_mon_avg_rn_aave = wgt_areaave_Wrap(gdd_mon_avg_rn, weights, 1.0, 0)
  gdd_mon_avg_rs = gdd_mon_avg
  gdd_mon_avg_rs = mask(gdd_mon_avg, rs, 1)
  gdd_mon_avg_rs_aave = wgt_areaave_Wrap(gdd_mon_avg_rs, weights, 1.0, 0)
  gdd_mon_avg_sste = gdd_mon_avg
  gdd_mon_avg_sste = mask(gdd_mon_avg, sste, 1)
  gdd_mon_avg_sste_aave = wgt_areaave_Wrap(gdd_mon_avg_sste, weights, 1.0, 0)
  gdd_mon_avg_sstw = gdd_mon_avg
  gdd_mon_avg_sstw = mask(gdd_mon_avg, sstw, 1)
  gdd_mon_avg_sstw_aave = wgt_areaave_Wrap(gdd_mon_avg_sstw, weights, 1.0, 0)
  gdd_mon_avg_ssvw = gdd_mon_avg
  gdd_mon_avg_ssvw = mask(gdd_mon_avg, ssvw, 1)
  gdd_mon_avg_ssvw_aave = wgt_areaave_Wrap(gdd_mon_avg_ssvw, weights, 1.0, 0)
  gdd_mon_avg_ssve = gdd_mon_avg
  gdd_mon_avg_ssve = mask(gdd_mon_avg, ssve, 1)
  gdd_mon_avg_ssve_aave = wgt_areaave_Wrap(gdd_mon_avg_ssve, weights, 1.0, 0)
  gdd_mon_avg_sswfe = gdd_mon_avg
  gdd_mon_avg_sswfe = mask(gdd_mon_avg, sswfe, 1)
  gdd_mon_avg_sswfe_aave = wgt_areaave_Wrap(gdd_mon_avg_sswfe, weights, 1.0, 0)
  gdd_mon_avg_sswfw = gdd_mon_avg
  gdd_mon_avg_sswfw = mask(gdd_mon_avg, sswfw, 1)
  gdd_mon_avg_sswfw_aave = wgt_areaave_Wrap(gdd_mon_avg_sswfw, weights, 1.0, 0)
  gdd_mon_avg_wt = gdd_mon_avg
  gdd_mon_avg_wt = mask(gdd_mon_avg, wt, 1)
  gdd_mon_avg_wt_aave = wgt_areaave_Wrap(gdd_mon_avg_wt, weights, 1.0, 0)
  ; ar6
  gdd_mon_avg_ar6_na = gdd_mon_avg
  gdd_mon_avg_ar6_na = mask(gdd_mon_avg, ar6, 39)
  gdd_mon_avg_ar6_na_aave = wgt_areaave_Wrap(gdd_mon_avg_ar6_na, weights, 1.0, 0)
  gdd_mon_avg_ar6_ca = gdd_mon_avg
  gdd_mon_avg_ar6_ca = mask(gdd_mon_avg, ar6, 40)
  gdd_mon_avg_ar6_ca_aave = wgt_areaave_Wrap(gdd_mon_avg_ar6_ca, weights, 1.0, 0)
  gdd_mon_avg_ar6_ea = gdd_mon_avg
  gdd_mon_avg_ar6_ea = mask(gdd_mon_avg, ar6, 41)
  gdd_mon_avg_ar6_ea_aave = wgt_areaave_Wrap(gdd_mon_avg_ar6_ea, weights, 1.0, 0)
  gdd_mon_avg_ar6_sa = gdd_mon_avg
  gdd_mon_avg_ar6_sa = mask(gdd_mon_avg, ar6, 42)
  gdd_mon_avg_ar6_sa_aave = wgt_areaave_Wrap(gdd_mon_avg_ar6_sa, weights, 1.0, 0)

; put vars into array for plotting
  data_cs = new((/3, 12/), float)
  data_cs(0,:) = obs_mon_avg_cs_aave
  data_cs(1,:) = rcm_mon_avg_cs_aave
  data_cs(2,:) = gdd_mon_avg_cs_aave
  data_ecn = new((/3, 12/), float)
  data_ecn(0,:) = obs_mon_avg_ecn_aave
  data_ecn(1,:) = rcm_mon_avg_ecn_aave
  data_ecn(2,:) = gdd_mon_avg_ecn_aave
  data_ecs = new((/3, 12/), float)
  data_ecs(0,:) = obs_mon_avg_ecs_aave
  data_ecs(1,:) = rcm_mon_avg_ecs_aave
  data_ecs(2,:) = gdd_mon_avg_ecs_aave
  data_mne = new((/3, 12/), float)
  data_mne(0,:) = obs_mon_avg_mne_aave
  data_mne(1,:) = rcm_mon_avg_mne_aave
  data_mne(2,:) = gdd_mon_avg_mne_aave
  data_mnw = new((/3, 12/), float)
  data_mnw(0,:) = obs_mon_avg_mnw_aave
  data_mnw(1,:) = rcm_mon_avg_mnw_aave
  data_mnw(2,:) = gdd_mon_avg_mnw_aave
  data_mb = new((/3, 12/), float)
  data_mb(0,:) = obs_mon_avg_mb_aave
  data_mb(1,:) = rcm_mon_avg_mb_aave
  data_mb(2,:) = gdd_mon_avg_mb_aave
  data_rn = new((/3, 12/), float)
  data_rn(0,:) = obs_mon_avg_rn_aave
  data_rn(1,:) = rcm_mon_avg_rn_aave
  data_rn(2,:) = gdd_mon_avg_rn_aave
  data_rs = new((/3, 12/), float)
  data_rs(0,:) = obs_mon_avg_rs_aave
  data_rs(1,:) = rcm_mon_avg_rs_aave
  data_rs(2,:) = gdd_mon_avg_rs_aave
  data_sste = new((/3, 12/), float)
  data_sste(0,:) = obs_mon_avg_sste_aave
  data_sste(1,:) = rcm_mon_avg_sste_aave
  data_sste(2,:) = gdd_mon_avg_sste_aave
  data_sstw = new((/3, 12/), float)
  data_sstw(0,:) = obs_mon_avg_sstw_aave
  data_sstw(1,:) = rcm_mon_avg_sstw_aave
  data_sstw(2,:) = gdd_mon_avg_sstw_aave
  data_ssvw = new((/3, 12/), float)
  data_ssvw(0,:) = obs_mon_avg_ssvw_aave
  data_ssvw(1,:) = rcm_mon_avg_ssvw_aave
  data_ssvw(2,:) = gdd_mon_avg_ssvw_aave
  data_ssve = new((/3, 12/), float)
  data_ssve(0,:) = obs_mon_avg_ssve_aave
  data_ssve(1,:) = rcm_mon_avg_ssve_aave
  data_ssve(2,:) = gdd_mon_avg_ssve_aave
  data_sswfe = new((/3, 12/), float)
  data_sswfe(0,:) = obs_mon_avg_sswfe_aave
  data_sswfe(1,:) = rcm_mon_avg_sswfe_aave
  data_sswfe(2,:) = gdd_mon_avg_sswfe_aave
  data_sswfw = new((/3, 12/), float)
  data_sswfw(0,:) = obs_mon_avg_sswfw_aave
  data_sswfw(1,:) = rcm_mon_avg_sswfw_aave
  data_sswfw(2,:) = gdd_mon_avg_sswfw_aave
  data_wt = new((/3, 12/), float)
  data_wt(0,:) = obs_mon_avg_wt_aave
  data_wt(1,:) = rcm_mon_avg_wt_aave
  data_wt(2,:) = gdd_mon_avg_wt_aave
  data_ar6_na = new((/3, 12/), float)
  data_ar6_na(0,:) = obs_mon_avg_ar6_na_aave
  data_ar6_na(1,:) = rcm_mon_avg_ar6_na_aave
  data_ar6_na(2,:) = gdd_mon_avg_ar6_na_aave
  data_ar6_ca = new((/3, 12/), float)
  data_ar6_ca(0,:) = obs_mon_avg_ar6_ca_aave
  data_ar6_ca(1,:) = rcm_mon_avg_ar6_ca_aave
  data_ar6_ca(2,:) = gdd_mon_avg_ar6_ca_aave
  data_ar6_ea = new((/3, 12/), float)
  data_ar6_ea(0,:) = obs_mon_avg_ar6_ea_aave
  data_ar6_ea(1,:) = rcm_mon_avg_ar6_ea_aave
  data_ar6_ea(2,:) = gdd_mon_avg_ar6_ea_aave
  data_ar6_sa = new((/3, 12/), float)
  data_ar6_sa(0,:) = obs_mon_avg_ar6_sa_aave
  data_ar6_sa(1,:) = rcm_mon_avg_ar6_sa_aave
  data_ar6_sa(2,:) = gdd_mon_avg_ar6_sa_aave
  data_aus = new((/3, 12/), float)
  data_aus(0,:) = obs_mon_avg_aus_aave
  data_aus(1,:) = rcm_mon_avg_aus_aave
  data_aus(2,:) = gdd_mon_avg_aus_aave

; plot
  plot_name = "../plots_monthly/"+run_name+"_"+var+"_monthly_climatology_area_average"

  print(systemfunc("date"))
  print("Plotting")

; plot
; resources
; time series
  resxy                      = True
  resxy@gsnFrame             = False
  resxy@gsnDraw              = False
  resxy@gsnMaximize          = False
  resxy@xyMarkLineMode       = "Lines"
  resxy@xyMonoDashPattern    = True
  resxy@xyDashPattern        = 0
  resxy@xyLineThicknessF     = 2.0
  resxy@gsnLeftStringFontHeightF = 0.025
  resxy@pmLegendDisplayMode    = "NoCreate"         ; Turn on the legend
  resxy@xyMonoLineColor       = False
  resxy@xyLineColors           = (/"black", "darkorange", "dodgerblue"/)
  resxy@tmXBMode   = "Explicit"
  resxy@tmXTOn = False

; legend on plot
;  resxy@pmLegendDisplayMode    = "Always"            ; turn on legend
;  resxy@pmLegendSide           = "Top"               ; Change location of 
;  resxy@pmLegendParallelPosF   = .45                 ; move units right
;  resxy@pmLegendOrthogonalPosF = -0.4                ; move units down
;  resxy@pmLegendWidthF         = 0.15                ; Change width and
;  resxy@pmLegendHeightF        = 0.18                ; height of legend.
;  resxy@lgLabelFontHeightF     = .03                 ; change font height
;  resxy@lgTitleOn              = False                ; turn on legend title
;  resxy@lgTitleFontHeightF     = .01                ; font of legend title
;  resxy@xyExplicitLegendLabels = (/"AGCD","CCAM", "ERA5"/)         ; explicit labels

  units = obs_mon_avg_aus_aave@units
  resxy@tiYAxisString = units
;  resxy@tmXBValues = ispan(0,12,1)
;  resxy@tmXBLabels = (/" ", "J","F","M","A","M","J","J","A","S","O","N","D"/)
;
;  wks = gsn_open_wks("pdf", plot_name)
;  plot = new(20, graphic)
;  x = ispan(1, 12, 1)
  resxy@tmXBValues = fspan(0.5, 11.5,12)
  resxy@tmXBLabels = (/"J","F","M","A","M","J","J","A","S","O","N","D"/)

  wks = gsn_open_wks("pdf", plot_name)
  plot = new(20, graphic)
  x = fspan(0.5, 11.5,12)

  resxy@gsnLeftString = "Monsoonal North (West)"
  plot(0) = gsn_csm_xy(wks, x, data_mnw(:,:), resxy)

  resxy@gsnLeftString = "Wet Tropics"
  plot(1) = gsn_csm_xy(wks, x, data_wt(:,:), resxy)

  resxy@gsnLeftString = "Monsoonal North (East)"
  plot(2) = gsn_csm_xy(wks, x, data_mne(:,:), resxy)

  resxy@gsnLeftString = "East Coast (North)"
  plot(3) = gsn_csm_xy(wks, x, data_ecn(:,:), resxy)

  resxy@gsnLeftString = "Rangelands (North)"
  plot(4) = gsn_csm_xy(wks, x, data_rn(:,:), resxy)

  resxy@gsnLeftString = "Rangelands (South)"
  plot(5) = gsn_csm_xy(wks, x, data_rs(:,:), resxy)

  resxy@gsnLeftString = "Central Slopes"
  plot(6) = gsn_csm_xy(wks, x, data_cs(:,:), resxy)

  resxy@gsnLeftString = "East Coast (South)"
  plot(7) = gsn_csm_xy(wks, x, data_ecs(:,:), resxy)

  resxy@gsnLeftString = "Southern and South Western Flatlands (West)"
  plot(8) = gsn_csm_xy(wks, x, data_sswfw(:,:), resxy)

  resxy@gsnLeftString = "Southern and South Western Flatlands (East)"
  plot(9) = gsn_csm_xy(wks, x, data_sswfe(:,:), resxy)

  resxy@gsnLeftString = "Murray Basin"
  plot(10) = gsn_csm_xy(wks, x, data_mb(:,:), resxy)

  resxy@gsnLeftString = "Southern Slopes (Vic West)"
  plot(11) = gsn_csm_xy(wks, x, data_ssvw(:,:), resxy)

  resxy@gsnLeftString = "Southern Slopes (Vic/NSW East)"
  plot(12) = gsn_csm_xy(wks, x, data_ssve(:,:), resxy)

  resxy@gsnLeftString = "Southern Slopes (Tas West)"
  plot(13) = gsn_csm_xy(wks, x, data_sstw(:,:), resxy)

  resxy@gsnLeftString = "Southern Slopes (Tas East)"
  plot(14) = gsn_csm_xy(wks, x, data_sste(:,:), resxy)

  resxy@gsnLeftString = "Australia "
  plot(15) = gsn_csm_xy(wks, x, data_aus(:,:), resxy)

  resxy@gsnLeftString = "AR6 Northern Aus"
  plot(16) = gsn_csm_xy(wks, x, data_ar6_na(:,:), resxy)

  resxy@gsnLeftString = "AR6 Central Aus"
  plot(17) = gsn_csm_xy(wks, x, data_ar6_ca(:,:), resxy)

  resxy@gsnLeftString = "AR6 Eastern Aus"
  plot(18) = gsn_csm_xy(wks, x, data_ar6_ea(:,:), resxy)

  resxy@gsnLeftString = "AR6 Southern Aus "
  plot(19) = gsn_csm_xy(wks, x, data_ar6_sa(:,:), resxy)

; Panel plots
  resP = True
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5
  resP@gsnPanelLabelBar = False
  resP@gsnMaximize = True
  resP@gsnPanelLabelBar = False
  resP@gsnFrame = False     
  resP@gsnPanelMainString = run_name+" "+var+" "+yrStrt+"-"+yrLast+"~C~"+info+" climatology ("+units+")"
  gsn_panel(wks, plot, (/5, 4/), resP)

;***********************************************
; legend resources
;***********************************************
 lgres                    = True
 lgres@vpWidthF           = 0.1                   ; width of legend (NDC)
 lgres@vpHeightF          = 0.15                   ; height of legend (NDC)
 lgres@lgLineColors       = "black"
 lgres@lgPerimOn          = False                 ; turn off perimeter
 lgres@lgDashIndexes      = (/0/)           ; dash indexes
 lgres@lgLineThicknessF   = 2.0
 lgres@lgLineLabelStrings = (/""/)       ; no labels in lines
 lgres@lgLabelFontHeightF = 0.05                   ; change font height
 lgres@lgOrientation = "Vertical"

;**************************************************************
; Draw the legend, indicating the number of items, a label for each
; item, and the X, Y position of the legend in NDC coordinates.
;**************************************************************
  gsn_legend_ndc(wks,1,(/"AGCD"/),0.16,0.83,lgres)
  lgres@lgLineColors = "dodgerblue"
  gsn_legend_ndc(wks,1,(/"ERA5"/),0.3,0.83,lgres)
  lgres@lgLineColors = "darkorange"
  gsn_legend_ndc(wks,1,(/"CCAM"/),0.46,0.83,lgres)
  ;drawNDCGrid(wks)
  frame(wks)
end