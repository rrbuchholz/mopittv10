;Original by Merritt Deeter circa 03.2022
;modifications by Sara Martinez-Alonso 08.2024
;

pro val_L2_v9_noaa

  ; revised to add extra cloud diagnostics (MOPCLD radiance ratio and
  ; MODIS cloud fraction) in output files

  ; updated for V8
  ; - include cloud index for use in filtering later
  ; - common output format w/ HIPPO validation output files
  ; - only validate through end of 2017

  ; ?????? specify new thresholds for number of flasks per profile, etc.?????????

  nflaskmin = 5

  ; new complete list of NOAA sites (as of June, 2018), used for V9 OPS validation
  sitecodes = ['aao','acg','act','bne','car','cma','crv','dnd','esp','etl','haa','hfm','hil','hip','lef','nha','nsa','pfa','rta','sca','sgp','tgc','thd','tom','wbi','wgc']
  ; partial list
  ;sitecodes = ['car','cma','crv','dnd','esp','etl','haa','hfm','hil','hip','lef','nha','nsa','pfa','rta','sca','sgp','tgc','thd','tom','wbi','wgc']
  ; partial list for running on mopfl
  ;sitecodes = ['crv','dnd','esp','etl','haa','hfm','hil','hip','lef','nha','nsa','pfa','rta','sca','sgp','tgc','thd','tom','wbi','wgc']
  ; partial list for running on mopfl
  ;sitecodes = ['sca','sgp','tgc','thd','tom','wbi','wgc']


  ; for testing Gene's corrected version of MOPFAS (validation-mode run finished 4/9/20)
  ;sitecodes = ['aao','bne','car','cma','dnd','esp','etl','haa','hfm','hil','lef','nha','pfa','rta','sca','sgp','tgc','thd','wbi','wgc']
  ;sitecodes = ['bne','car','cma','dnd','esp','etl','haa','hil','lef','nha','pfa','rta','sca','sgp','tgc','thd','wbi','wgc']
  ;sitecodes = ['wgc']
  ;sitecodes = ['aao']
  ;sitecodes = ['aao','bne','hfm']
  ;sitecodes = ['hfm']

  ; 8 sites for analyzing thresholds for northern U.S. and Canada
  ;sitecodes = ['bne','car','etl','dnd','lef','pfa','sgp','wbi']

  ; for initial V9 validation runs
  ;sitecodes = ['aao','bne','car','cma','dnd','esp','etl','haa','hfm','hil','lef','nha','pfa','rta','sca','sgp','tgc','thd','wbi','wgc']

  ;sitecodes = ['car']
  ;sitecodes = ['wgc']

  ; RTA / 200 km radius
  ;sitecodes = ['rta']
  ;sitecodes = ['haa']

  nsites = n_elements(sitecodes)

  ; set V8mode to 'T' only when processing V8 L2 files

  ;V8mode = 'T'
  V8mode = 'F'
  missing_val = -999.

  junk = ''
  isprofl = fltarr(2,35)

  ; thresholds for accepting MOPITT retrievals
  dlatmax = 2.5
  dlonmax = 2.5
  ;distmax = 100.
  distmax = 50.
  ;distmax = 200.
  ;distmax = 30.
  dthrsmax = 12.

  ; set threshold pressure: discard in-situ profiles with no upper-trop data
  ;p_bot_thr = 750.
  ;p_top_thr = 450.
  ; 500 hPa threshold for RTA only
  ;p_top_thr = 500.
  ;p_bot_thr = 700.
  ; thresholds for field campaigns
  ;p_top_thr = 300.
  ;p_bot_thr = 850.

  ;log10e = alog10(exp(1.))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; begin processing

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  for isite = 0, nsites-1 do begin

    print, sitecodes(isite)

    ; default threshold pressure values for lowest/highest in-situ levels
    p_top_thr = 450.
    p_bot_thr = 750.

    if (sitecodes(isite) eq 'rta') then begin
      p_top_thr = 500.
      p_bot_thr = 700.
    endif

    if (sitecodes(isite) eq 'sgp' or sitecodes(isite) eq 'lef' or sitecodes(isite) eq 'esp') then begin
      p_top_thr = 550.
      p_bot_thr = 850.
    endif

    ; updated NOAA profiles (June, 2018)
    spawnstr =  'ls /MOPITT/project/mopsips/data/val/cmdl/profile/PROFILES_FOR_V8_VALIDATION/INTERPOLATED_PROFILES/' + sitecodes(isite) + '/*.asc'

    spawn, spawnstr, valfiles

    nvalfiles = n_elements(valfiles)

    ;  print, nvalfiles

    if (nvalfiles lt 1) then continue

    for ivalfile = 0, nvalfiles-1 do begin

      ;    print, valfiles(ivalfile)

      ; get date and time from file name

      tmp = strsplit(valfiles(ivalfile),'_',/extract)
      ntmp = n_elements(tmp)
      datestr = tmp(ntmp-1)
      profyr = strmid(datestr,0,4)
      profmo = strmid(datestr,5,2)
      profdy = strmid(datestr,8,2)
      profhr = strmid(datestr,11,2)
      profmn = strmid(datestr,13,2)

      ;    if (fix(profyr) lt 2000 or (fix(profyr) eq 2000 and fix(profmo) lt 3)) then continue

      ; only validate through end of 2017
      ;    if (fix(profyr) lt 2000 or fix(profyr) ge 2018 or (fix(profyr) eq 2000 and fix(profmo) lt 3)) then continue
      ; only validate even-numbered years through end of 2018
      ;    if (fix(profyr) lt 2000 or fix(profyr) ge 2019 or (fix(profyr) eq 2000 and fix(profmo) lt 3) or (fix(profyr) mod 2) ne 0) then continue
      ;    if (fix(profyr) lt 2000 or fix(profyr) ge 2018 or (fix(profyr) eq 2000 and fix(profmo) lt 3) or (fix(profyr) mod 2) ne 0) then continue
      ; only validate odd-numbered years through end of 2018
      ;    if (fix(profyr) lt 2000 or fix(profyr) ge 2019 or (fix(profyr) eq 2000 and fix(profmo) lt 3) or (fix(profyr) mod 2) ne 1) then continue

      ; only validate through end of 2018
      ;    if (fix(profyr) lt 2000 or fix(profyr) ge 2019 or (fix(profyr) eq 2000 and fix(profmo) lt 3)) then continue
      ; only validate years 2010-2015
      if (fix(profyr) lt 2010 or fix(profyr) gt 2015) then continue

      ; validate odd- and even-numbered years through end of 2018
      ;    if (fix(profyr) lt 2000 or fix(profyr) ge 2019 or (fix(profyr) eq 2000 and fix(profmo) lt 3) ) then continue

      ; only validate 02, 03, 04, 16, 17, and 18
      ;    if (fix(profyr) ne 2002 and fix(profyr) ne 2003 and fix(profyr) ne 2004 and fix(profyr) ne 2016 and fix(profyr) ne 2017 and fix(profyr) ne 2018) then continue

      ; read in-situ profile

      openr, 1, valfiles(ivalfile)
      readf, 1, junk
      readf, 1, junk
      tmp = strsplit(junk,/extract)
      proflat = tmp(0)
      proflon = tmp(1)
      p_obs_top = float(tmp(3))
      p_obs_bot = float(tmp(2))
      nflask = fix(tmp(4))
      readf, 1, junk
      readf, 1, junk
      readf, 1, junk

      readf, 1, isprofl
      close, 1

      ; correct for longitude values > 180.

      if (proflon gt 180.) then begin
        proflon = proflon - 360.
      endif

      ; only continue if p_min (top of profile) is less than p_thr

      ;    if (p_min gt p_thr) then continue
      ;    if (p_obs_top gt p_top_thr or p_obs_bot lt p_bot_thr) then continue
      if (p_obs_top gt p_top_thr or p_obs_bot lt p_bot_thr or nflask lt nflaskmin) then continue

      ; valprs increases from 0.2 to 1060 mb
      valprs = reform(isprofl(0,*))
      valvmr = reform(isprofl(1,*))

      ;;;;;; new code added March, 2018 for calcg moist-air mole fraction ;;;;;;

      spawn, 'ls /MOPITT/project/datasets/merra2-nc4/' + profyr + profmo + '/' + 'svc_MERRA2_???.inst6_3d_ana_Np.' + profyr + profmo + profdy + '.nc4', allfiles

      ncfile = allfiles(0)
      if (file_test(ncfile) ne 1) then begin
        print, 'merra file not found'
        stop
      endif

      ;    print, ncfile

      id = NCDF_OPEN(ncfile)
      ; pressure levs vary from 1000. to 0.1 hPa (42 levels)
      NCDF_VARGET, id, 'lev', lev
      ;print, levcc
      ; latitude grid ranges from -90 to 90 degs (361 lats)
      NCDF_VARGET, id, 'lat', lat
      ;print, latcc
      ; longitude grid ranges from -180 to 179.375 degs (576 lons)
      NCDF_VARGET, id, 'lon', lon
      ;
      ; specific humidity (kg/kg) is dimensioned nlon, nlat, nlev, ntime
      NCDF_VARGET, id, 'QV', spechum
      NCDF_CLOSE, id

      nlev = n_elements(lev)

      dlat = abs(lat - proflat)
      ilat = where(dlat eq min(dlat))
      ;print, lat(ilat(0))

      dlon = abs(lon - proflon)
      ilon = where(dlon eq min(dlon))
      ;print, lon(ilon(0))

      if (min(spechum(ilon(0),ilat(0),*,*)) lt 0.) then begin
        print, 'missing value found in specific humidity profile'
        print, ncfile
        print, proflat, proflon
        print, ilat(0), ilon(0)
        stop
      endif

      vmr = fltarr(nlev)
      ; compute daily mean H2O VMR profile (ppv)
      for ilev = 0, nlev-1 do begin
        tmp = reform(spechum(ilon(0),ilat(0),ilev,0:3))
        ival = where(tmp ge 0. and tmp lt 0.1,nval)
        if (nval lt 1) then begin
          vmr(ilev) = 0.
        endif else begin
          vmr(ilev) = mean(tmp(ival))/0.622
        endelse

      endfor

      ; interpolate MERRA-2 H2O VMR profile to validation profile
      ; grid (can't interpolate to in-situ levs at 1020, 1040, or 1060 hPa)

      valprs32 = valprs(0:31)
      vmrh2o = interpol(vmr,lev,valprs32)

      ; convert dry-air mole fraction VMR to moist-air mole fraction VMR

      for jlev = 0, 31 do begin
        valvmr(jlev) = valvmr(jlev)*(1. - vmrh2o(jlev))
      endfor

      valvmr(32) = valvmr(32)*(1. - vmrh2o(31))
      valvmr(33) = valvmr(33)*(1. - vmrh2o(31))
      valvmr(34) = valvmr(34)*(1. - vmrh2o(31))

      ;;;;;;;;;;;;;;;;;;;;; end of new code ;;;;;;;;;;;;;;;;;;;;

      ; find matching MOP02 files

      ; TIR-only RADFIX optimization tests w/ final V8 MOPFAS files
      ;    spawnstr =  'ls /MOPITT/VALIDATION/ArchiveTW/L2_geoBox_opt8/' + profyr + profmo + '/' + profmo + profdy + '/MOP02T-*L2V17.*.1.he5'
      ;    spawnstr =  'ls /MOPITT/VALIDATION/ArchiveTW/L2_geoBox_opt9/' + profyr + profmo + '/' + profmo + profdy + '/MOP02T-*L2V17.*.1.he5'
      ;    spawnstr =  'ls /MOPITT/VALIDATION/ArchiveTW/L2_geoBox_opt10/' + profyr + profmo + '/' + profmo + profdy + '/MOP02T-*L2V17.*.1.he5'

      ; NIR-only RADFIX optimization tests w/ final V8 MOPFAS files
      ;   spawnstr =  'ls /MOPITT/VALIDATION/ArchiveNIR/L2_opt1_thr1.000_modis6/' + profyr + profmo + '/' + profmo + profdy + '/MOP02N-*L2V17.*.2.he5'
      ;   spawnstr =  'ls /MOPITT/VALIDATION/ArchiveNIR/L2_opt2_thr1.000_modis6/' + profyr + profmo + '/' + profmo + profdy + '/MOP02N-*L2V17.*.2.he5'
      ;   spawnstr =  'ls /MOPITT/VALIDATION/ArchiveNIR/L2_opt3_thr1.000_modis6/' + profyr + profmo + '/' + profmo + profdy + '/MOP02N-*L2V17.*.2.he5'
      ;   spawnstr =  'ls /MOPITT/VALIDATION/ArchiveNIR/L2_opt4_thr1.000_modis6/' + profyr + profmo + '/' + profmo + profdy + '/MOP02N-*L2V17.*.2.he5'

      ; JNT RADFIX optimization tests w/ final V8 MOPFAS files
      ;   spawnstr =  'ls /MOPITT/VALIDATION/ArchiveJNT/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02J-*L2V17.*.3.he5'

      ; V7T OPS
      ;    spawnstr =  'ls /MOPITT/V7T/Archive/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02T-*L2V17.*.1.he5'
      ; V7N OPS
      ;    spawnstr =  'ls /MOPITT/V7N/Archive/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02N-*L2V17.*.2.he5'
      ; V7J OPS
      ;    spawnstr =  'ls /MOPITT/V7J/Archive/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02J-*L2V17.*.3.he5'

      ;;;;;;;;;;;;;;;;;;;; V8 OPS ;;;;;;;;;;;;;;;;

      ;    spawnstr =  'ls /MOPITT/V8T/Archive/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02T-*L2V18.*.1.he5'
      ;    spawnstr =  'ls /MOPITT/V8N/Archive/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02N-*L2V18.*.2.he5'
      ;    spawnstr =  'ls /MOPITT/V8J/Archive/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02J-*L2V18.*.3.he5'

      ;;;;; experimental version using Gene's corrected MOPFAS and
      ;;;;; revised RADFIX (time-dep. radfix terms all set to 0)

      ;    spawnstr =  'ls /MOPITT/VALIDATION/ArchivePMCerr/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02T-*L2V18.*.1.he5'

      ; validation-mode run performed w/ cloud detection disabled

      ;    spawnstr =  'ls /MOPITT/VALIDATION/ArchiveV94cldfree/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02T-*L2V19.4.1.he5'

      ; V9 validation-mode radfix-optimization experiments

      ;    spawnstr =  'ls /MOPITT/VALIDATION/ArchiveV9/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02T-*L2V19.5.1.he5'
      ;    spawnstr =  'ls /MOPITT/VALIDATION/ArchiveV9/L2-2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02T-*L2V19.5.1.he5'
      ;    spawnstr =  'ls /MOPITT/VALIDATION/ArchiveV9/L2-3/' + profyr + profmo + '/' + profmo + profdy + '/MOP02T-*L2V19.5.1.he5'
      ;    spawnstr =  'ls /MOPITT/VALIDATION/ArchiveV9/L2-4/' + profyr + profmo + '/' + profmo + profdy + '/MOP02T-*L2V19.5.1.he5'

      ;    spawnstr =  'ls /MOPITT/VALIDATION/ArchiveV9N/L2-4/' + profyr + profmo + '/' + profmo + profdy + '/MOP02N-*L2V19.5.2.he5'

      ;    spawnstr =  'ls /MOPITT/VALIDATION/ArchiveV9J/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02J-*L2V19.5.3.he5'
      ;    spawnstr =  'ls /MOPITT/VALIDATION/ArchiveV9T/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02T-*L2V19.5.1.he5'
      ;    spawnstr =  'ls /MOPITT/VALIDATION/ArchiveV9J/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02J-*L2V19.5.3.he5'
      ; reprocessed V9J results due to incorrect cloud thresholds in Config file
      ;    spawnstr =  'ls /MOPITT/VALIDATION/ArchiveV9J/L2-6/' + profyr + profmo + '/' + profmo + profdy + '/MOP02J-*L2V19.5.3.he5'

      ; 'Archival' V9 files
      ;    spawnstr =  'ls /MOPITT/V9T/Archive/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02T-*L2V19.9.1.he5'
      ;    spawnstr =  'ls /MOPITT/V9N/Archive/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02N-*L2V19.9.2.he5'
      ;    spawnstr =  'ls /MOPITT/DEV/ArchiveV9T/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02T-*L2V19.9.1.he5'

      ; Experimental V9 files
      ;    spawnstr =  'ls /MOPITT/V9T/Archive/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02T-*L2V19.9.1.he5'
      spawnstr =  'ls /MOPITT/DEV/Archive6N9/L2/' + profyr + profmo + '/' + profmo + profdy + '/MOP02N-*L2V19.9.2.he5'
      ;

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      spawn, spawnstr, l2files

      if (l2files(0) eq '') then continue

      ;    print, l2files
      ;    print, n_elements(l2files)

      nl2files = n_elements(l2files)

      if (nl2files lt 1) then continue

      ; create file for individual comparisons

      ; TIR-only RADFIX optimization tests w/ final V8 MOPFAS files
      ;    outfile = 'val_L2_v8_output/radfix_opt8/val_L2_v7.L2V17.9x.1.' + sitecodes(isite) + '.' +  profyr + profmo + profdy + '.50km.dat'
      ;    outfile = 'val_L2_radfix_optmz/opt8/val_L2_v8.L2V17.9x.1.' + sitecodes(isite) + '.' +  profyr + profmo + profdy + '.50km.dat'
      ;    outfile = 'val_L2_radfix_optmz/opt9/val_L2_v8.L2V17.9x.1.' + sitecodes(isite) + '.' +  profyr + profmo + profdy + '.50km.dat'
      ;    outfile = 'val_L2_radfix_optmz/opt10/val_L2_v8.L2V17.9x.1.' + sitecodes(isite) + '.' +  profyr + profmo + profdy + '.50km.dat'

      ; NIR-only RADFIX optimization tests w/ final V8 MOPFAS files
      ;    outfile = 'val_L2_radfix_optmz/radfix_nir_opt1_thr1.000_modis6/val_L2_v7.L2V17.9x.2.' + sitecodes(isite) + '.' +  profyr + profmo + profdy + '.50km.dat'
      ;    outfile = 'val_L2_radfix_optmz/radfix_nir_opt2_thr1.000_modis6/val_L2_v7.L2V17.9x.2.' + sitecodes(isite) + '.' +  profyr + profmo + profdy + '.50km.dat'
      ;    outfile = 'val_L2_radfix_optmz/radfix_nir_opt3_thr1.000_modis6/val_L2_v7.L2V17.9x.2.' + sitecodes(isite) + '.' +  profyr + profmo + profdy + '.50km.dat'
      ;    outfile = 'val_L2_radfix_optmz/radfix_nir_opt4_thr1.000_modis6/val_L2_v7.L2V17.9x.2.' + sitecodes(isite) + '.' +  profyr + profmo + profdy + '.50km.dat'

      ; JNT RADFIX optimization tests w/ final V8 MOPFAS files
      ;    outfile = 'val_L2_radfix_optmz/radfix_jnt_opt1_thr1.000_modis6/val_L2_v7.L2V17.9x.3.' + sitecodes(isite) + '.' +  profyr + profmo + profdy + '.50km.dat'

      ;    outfile = 'val_L2_radfix_optmz/v7t_ops/val_L2_v7.L2V17.8.1.' + sitecodes(isite) + '.' +  profyr + profmo + profdy + '.50km.dat'
      ;    outfile = 'val_L2_radfix_optmz/v7n_ops/val_L2_v7.L2V17.8.2.' + sitecodes(isite) + '.' +  profyr + profmo + profdy + '.50km.dat'
      ;    outfile = 'val_L2_radfix_optmz/v7j_ops/val_L2_v7.L2V17.8.3.' + sitecodes(isite) + '.' +  profyr + profmo + profdy + '.50km.dat'

      ;;;;;;;;;;;;;;;;;;;; V8 OPS ;;;;;;;;;;;;;;;;

      ;    outfile = 'val_L2_ops/v8t_ops/val_L2_v8.L2V18.0.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;    outfile = 'val_L2_ops/v8n_ops/val_L2_v8.L2V18.0.2.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;    outfile = 'val_L2_ops/v8j_ops/val_L2_v8.L2V18.0.3.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'

      ; 200 km radius
      ;    outfile = 'val_L2_ops/v8t_ops/val_L2_v8.L2V18.0.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.200km.dat'



      ;    outfile = 'val_L2_mopfas_corr/v8t/val_L2_v8.L2V18.1.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;
      ;    outfile = 'val_L2_ops/v7t_ops/val_L2_v8.L2V17.x.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'

      ; validation-mode expt to analyze threshold-dependence of validation results

      ;    outfile = 'val_L2_valmode/v9t_valmode_xpt1/val_L2_v9.L2V19.4.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'

      ; validation-mode radfix-optimization experiments
      ;    outfile = 'val_L2_valmode/v9t_valmode_radfix1/val_L2_v9.L2V19.5.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;    outfile = 'val_L2_valmode/v9t_valmode_radfix2/val_L2_v9.L2V19.5.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;    outfile = 'val_L2_valmode/v9t_valmode_cldthr2/val_L2_v9.L2V19.5.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;    outfile = 'val_L2_valmode/v9t_valmode_radfix3/val_L2_v9.L2V19.5.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;    outfile = 'val_L2_valmode/v9n_valmode_radfix3/val_L2_v9.L2V19.5.3.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;    outfile = 'val_L2_valmode/v9j_valmode_radfix3/val_L2_v9.L2V19.5.3.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;    outfile = 'val_L2_valmode/v9j_valmode_radfix3/val_L2_v9.L2V19.5.3.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'

      ;    outfile = 'val_L2_valmode/v9t_valmode_radfix4/val_L2_v9.L2V19.5.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;    outfile = 'val_L2_valmode/v9n_valmode_radfix4/val_L2_v9.L2V19.5.2.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;    outfile = 'val_L2_valmode/v9j_valmode_radfix4/val_L2_v9.L2V19.5.3.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'

      ; 'Archival' V9 files
      ;    outfile = 'val_L2_ops/L2V19.9.1/val_L2_v9.L2V19.9.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;    outfile = 'val_L2_ops/L2V19.9.1b/val_L2_v9.L2V19.9.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;    outfile = 'val_L2_ops/L2V19.9.1c/val_L2_v9.L2V19.9.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;    outfile = 'val_L2_ops/L2V19.9.1c_fullmission/val_L2_v9.L2V19.9.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;    outfile = 'val_L2_ops/L2V19.9.2_fullmission/val_L2_v9.L2V19.9.2.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;    outfile = 'val_L2_ops/L2V19.9.2b_fullmission/val_L2_v9.L2V19.9.2.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'

      ; experimental V9 files
      outfile = 'val_L2_ops/L2V19.9.2_cal2/val_L2_v9.L2V19.9.2.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'

      ; identically processed V8 files
      ;    outfile = 'val_L2_ops/v8t_ops/val_L2_v9.L2V18.0.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'
      ;    outfile = 'val_L2_ops/v8n_ops/val_L2_v9.L2V18.0.2.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.50km.dat'

      openw, 1, outfile

      printf, 1, format='(2f8.1,5i6)', proflat, proflon, profyr, profmo, profdy, profhr, profmn

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      ;;;;;;;;; extract relevant info from V7 MOP02 files ;;;;;;;;;;;;

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      for il2file = 0, nl2files-1 do begin

        ;      print, l2files(il2file)

        if (file_test(l2files(il2file)) ne 1) then continue

        file_id = H5F_OPEN(l2files(il2file))

        if (file_id lt 0) then continue

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Geolocation Fields/Latitude')
        moplat = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Geolocation Fields/Longitude')
        moplon = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        H5F_CLOSE, file_id

        ; first locate retrievals in 5 deg by 5 deg rect box around val site

        ibox = where(abs(moplat - proflat) lt dlatmax and abs(moplon - proflon) lt dlonmax, nbox)

        print, 'nbox = ', nbox

        if (nbox lt 1) then continue

        file_id = H5F_OPEN(l2files(il2file))

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Geolocation Fields/SecondsinDay')
        secs = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/SwathIndex')
        pxsttrk = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/SurfaceIndex')
        isfc = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/PressureGrid')
        prs = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/SurfacePressure')
        psfc = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/SolarZenithAngle')
        sza = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/SatelliteZenithAngle')
        satza = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/DegreesofFreedomforSignal')
        dfs = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/APrioriCOMixingRatioProfile')
        approfl = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/APrioriCOSurfaceMixingRatio')
        apsfcmr = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/RetrievedCOMixingRatioProfile')
        rtvprofl = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/RetrievedCOSurfaceMixingRatio')
        rtvsfcmr = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/RetrievedCOTotalColumn')
        rtvcolm = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/APrioriCOTotalColumn')
        apcolm = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/RetrievalAveragingKernelMatrix')
        avkrn = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/TotalColumnAveragingKernel')
        colm_avkrn = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/AveragingKernelRowSums')
        avkrn_sums = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/Level1RadiancesandErrors')
        rads_errs = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/WaterVaporColumn')
        wvcolm = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/RetrievalAnomalyDiagnostic')
        anom_flags = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/CloudDescription')
        icld = H5D_Read(dataset_id)
        H5D_CLOSE, dataset_id

        ; new cloud diagnostics

        if (V8mode ne 'T') then begin

          dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/MODISCloudDiagnostics')
          modiscld = H5D_Read(dataset_id)
          H5D_CLOSE, dataset_id

          dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/MOPCldRadRatio')
          mopcldratio = H5D_Read(dataset_id)
          H5D_CLOSE, dataset_id

        endif
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        H5F_CLOSE, file_id

        rad_5A = reform(rads_errs(0,3,*))
        rad_uncy_5A = reform(rads_errs(1,3,*))
        rad_6A = reform(rads_errs(0,9,*))
        rad_uncy_6A = reform(rads_errs(1,9,*))
        rad_6D = reform(rads_errs(0,11,*))
        rad_uncy_6D = reform(rads_errs(1,11,*))

        snr5a = rad_5A/rad_uncy_5A
        snr6a = rad_6A/rad_uncy_6A
        snr6r = rad_6A/rad_uncy_6D

        inight = where(rad_6A lt 0. or rad_uncy_6A lt 0.,nnight)
        if (nnight gt 0) then snr6a(inight) = -999.

        inight = where(rad_6A lt 0. or rad_uncy_6D lt 0.,nnight)
        if (nnight gt 0) then snr6r(inight) = -999.

        if (V8mode ne 'T') then begin

          ; 'test 3' clear-fraction
          modisclrfrac = reform(modiscld(4,*))/100.

        endif


        for j = 0, nbox-1 do begin

          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

          ;;;;;;;;;; test proximity of MOPITT obs to val site ;;;;;;;;;;;;

          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

          ; calculate distance from each obs to val site

          dist = distance(moplat(ibox(j)), moplon(ibox(j)), proflat, proflon)

          ; calculate time offset in hrs

          dthrs = secs(ibox(j))/3600. - (float(profhr) + float(profmn)/60.)

          if (dist gt distmax or abs(dthrs) gt dthrsmax) then continue

          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

          ;;;;;;;;;;;;;;;;;  standard case: psfc > 900 mb ;;;;;;;;;;;;;;;;

          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

          if (psfc(ibox(j)) gt prs(0)) then begin

            prtv = [psfc(ibox(j)),prs(0:8)]
            ak1 = transpose(reform(avkrn(0:9,0:9,ibox(j)),10,10))

            ; convert both a priori profile and retrieval to log-VMR

            if (min([apsfcmr(0,ibox(j)),reform(approfl(0,0:8,ibox(j)))]) lt 0.) then begin
              print, 'negative values in a.p. VMR profile'
              stop
            endif

            if (min([rtvsfcmr(0,ibox(j)),reform(rtvprofl(0,0:8,ibox(j)))]) lt 0.) then begin
              print, 'negative values in retrieved VMR profile'
              stop
            endif

            ap1 = alog10([apsfcmr(0,ibox(j)),reform(approfl(0,0:8,ibox(j)))])
            rtv1 = alog10([rtvsfcmr(0,ibox(j)),reform(rtvprofl(0,0:8,ibox(j)))])

            ; instead of interpolating, average VMR values in layer above each level

            valvmrint = fltarr(10)
            valvmrint(*) = -999.

            for ilev = 0, 8 do begin
              ilyr = where(valprs le prtv(ilev) and valprs gt prtv(ilev+1),nlyr)
              if (nlyr lt 1) then begin
                ilyr = where(valprs gt prtv(ilev),nlyr)
                valvmrint(ilev) = valvmr(ilyr(0))
              endif else begin
                valvmrint(ilev) = total(valvmr(ilyr))/nlyr
              endelse
            endfor

            ; 100 hPa retrieval represents layer from 100 hPa to 50 hPa (i.e. 70 and 100 hPa levels)
            ilyr100 = where(valprs gt 50. and valprs le 100.,nlyr)
            valvmrint(9) = total(valvmr(ilyr100))/nlyr

            if (min(valvmrint) lt 0.) then begin
              print, 'negative values in retrieved VMR profile'
              stop
            endif

            logvalvmr = alog10(valvmrint)

            simprof = ap1 + ak1 ## transpose(logvalvmr - ap1)

            colm_ap = apcolm(ibox(j))

            ak_colm = reform(colm_avkrn(0:9,ibox(j)))

            colm_sim = colm_ap + ( ak_colm ## transpose(logvalvmr - ap1) )

            akrowsum = reform(avkrn_sums(0:9,ibox(j)))

            ; common output format w/ V8 NOAA validation files

            ;          printf, 1, format='(4i4,3f8.1,4e11.3,f7.4,1x,e10.3,1x,e10.3,1x,e10.3,5i3)', pxsttrk(0,ibox(j)), pxsttrk(1,ibox(j)), isfc(ibox(j)), icld(ibox(j)), psfc(ibox(j)), sza(ibox(j)), dist, rtvcolm(0,ibox(j)), colm_sim, apcolm(ibox(j)), wvcolm(ibox(j)), dfs(ibox(j)), snr5a(ibox(j)), snr6a(ibox(j)), snr6r(ibox(j)), anom_flags(0:4,ibox(j))
            ;          printf, 1, format='(4i4,3f8.1,4e11.3,f7.4,1x,e10.3,1x,e10.3,1x,e10.3,5i3,1x,f9.4,1x,f9.4)', pxsttrk(0,ibox(j)), pxsttrk(1,ibox(j)), isfc(ibox(j)), icld(ibox(j)), psfc(ibox(j)), sza(ibox(j)), dist, rtvcolm(0,ibox(j)), colm_sim, apcolm(ibox(j)), wvcolm(ibox(j)), dfs(ibox(j)), snr5a(ibox(j)), snr6a(ibox(j)), snr6r(ibox(j)), anom_flags(0:4,ibox(j)), modisclrfrac(ibox(j)), mopcldratio(ibox(j))

            if (V8mode ne 'T') then begin

              printf, 1, format='(4i4,3f8.1,4e11.3,f7.4,1x,e10.3,1x,e10.3,1x,e10.3,5i3,1x,f9.4,1x,f9.4)', pxsttrk(0,ibox(j)), pxsttrk(1,ibox(j)), isfc(ibox(j)), icld(ibox(j)), psfc(ibox(j)), sza(ibox(j)), dist, rtvcolm(0,ibox(j)), colm_sim, apcolm(ibox(j)), wvcolm(ibox(j)), dfs(ibox(j)), snr5a(ibox(j)), snr6a(ibox(j)), snr6r(ibox(j)), anom_flags(0:4,ibox(j)), modisclrfrac(ibox(j)), mopcldratio(ibox(j))

            endif else begin

              printf, 1, format='(4i4,3f8.1,4e11.3,f7.4,1x,e10.3,1x,e10.3,1x,e10.3,5i3,1x,f9.4,1x,f9.4)', pxsttrk(0,ibox(j)), pxsttrk(1,ibox(j)), isfc(ibox(j)), icld(ibox(j)), psfc(ibox(j)), sza(ibox(j)), dist, rtvcolm(0,ibox(j)), colm_sim, apcolm(ibox(j)), wvcolm(ibox(j)), dfs(ibox(j)), snr5a(ibox(j)), snr6a(ibox(j)), snr6r(ibox(j)), anom_flags(0:4,ibox(j)), missing_val, missing_val

            endelse

            printf, 1, format='(10f10.4)', rtv1
            printf, 1, format='(10f10.4)', simprof
            printf, 1, format='(10f10.4)', ap1
            printf, 1, format='(10f10.4)', logvalvmr
            printf, 1, format='(10f10.4)', akrowsum

          endif else begin

            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

            ;;;;;;;;;;;;;;;;;  900 mb > psfc > 800 mb ;;;;;;;;;;;;;;;;

            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

            if (psfc(ibox(j)) lt prs(0) and psfc(ibox(j)) gt prs(1)) then begin

              ;print, 'psfc = ' + strtrim(psfc(ibox(j)),2)

              prtv = [psfc(ibox(j)),prs(1:8)]

              ak1 = transpose(reform(avkrn(1:9,1:9,ibox(j)),9,9))

              if (min([apsfcmr(0,ibox(j)),reform(approfl(0,1:8,ibox(j)))]) lt 0.) then begin
                print, 'negative values in a.p. VMR profile'
                stop
              endif

              if (min([rtvsfcmr(0,ibox(j)),reform(rtvprofl(0,1:8,ibox(j)))]) lt 0.) then begin
                print, 'negative values in retrieved VMR profile'
                stop
              endif

              ap1 = alog10([apsfcmr(0,ibox(j)),reform(approfl(0,1:8,ibox(j)))])
              rtv1 = alog10([rtvsfcmr(0,ibox(j)),reform(rtvprofl(0,1:8,ibox(j)))])

              ; instead of interpolating, average VMR values in layer above each level

              valvmrint = fltarr(9)
              valvmrint(*) = -999.

              for ilev = 0, 7 do begin
                ilyr = where(valprs le prtv(ilev) and valprs gt prtv(ilev+1),nlyr)
                if (nlyr lt 1) then begin
                  ilyr = where(valprs gt prtv(ilev),nlyr)
                  valvmrint(ilev) = valvmr(ilyr(0))
                endif else begin
                  valvmrint(ilev) = total(valvmr(ilyr))/nlyr
                endelse
              endfor

              ; 100 hPa retrieval represents layer from 100 hPa to 50 hPa (i.e. 70 and 100 hPa levels)
              ilyr100 = where(valprs gt 50. and valprs le 100.,nlyr)
              valvmrint(8) = total(valvmr(ilyr100))/nlyr

              if (min(valvmrint) lt 0.) then begin
                print, 'negative values in retrieved VMR profile'
                stop
              endif

              logvalvmr = alog10(valvmrint)

              simprof = ap1 + ak1 ## transpose(logvalvmr - ap1)

              colm_ap = apcolm(ibox(j))

              ak_colm = reform(colm_avkrn(1:9,ibox(j)))

              colm_sim = colm_ap + ( ak_colm ## transpose(logvalvmr - ap1) )

              rtv1_10lv = [rtv1(0), -9.999, rtv1(1:8)]
              simprof_10lv = [simprof(0), -9.999, simprof(1:8)]
              ap1_10lv = [ap1(0), -9.999, ap1(1:8)]
              logvalvmr_10lv = [logvalvmr(0), -9.999, logvalvmr(1:8)]

              akrowsum_10lv = [avkrn_sums(1,ibox(j)),-9.999,reform(avkrn_sums(2:9,ibox(j)))]

              ; common output format w/ V8 NOAA validation files

              ;            printf, 1, format='(4i4,3f8.1,4e11.3,f7.4,1x,e10.3,1x,e10.3,1x,e10.3,5i3)', pxsttrk(0,ibox(j)), pxsttrk(1,ibox(j)), isfc(ibox(j)), icld(ibox(j)), psfc(ibox(j)), sza(ibox(j)), dist, rtvcolm(0,ibox(j)), colm_sim, apcolm(ibox(j)), wvcolm(ibox(j)), dfs(ibox(j)), snr5a(ibox(j)), snr6a(ibox(j)), snr6r(ibox(j)), anom_flags(0:4,ibox(j))
              ;            printf, 1, format='(4i4,3f8.1,4e11.3,f7.4,1x,e10.3,1x,e10.3,1x,e10.3,5i3,1x,f9.4,1x,f9.4)', pxsttrk(0,ibox(j)), pxsttrk(1,ibox(j)), isfc(ibox(j)), icld(ibox(j)), psfc(ibox(j)), sza(ibox(j)), dist, rtvcolm(0,ibox(j)), colm_sim, apcolm(ibox(j)), wvcolm(ibox(j)), dfs(ibox(j)), snr5a(ibox(j)), snr6a(ibox(j)), snr6r(ibox(j)), anom_flags(0:4,ibox(j)), modisclrfrac(ibox(j)), mopcldratio(ibox(j))

              if (V8mode ne 'T') then begin

                printf, 1, format='(4i4,3f8.1,4e11.3,f7.4,1x,e10.3,1x,e10.3,1x,e10.3,5i3,1x,f9.4,1x,f9.4)', pxsttrk(0,ibox(j)), pxsttrk(1,ibox(j)), isfc(ibox(j)), icld(ibox(j)), psfc(ibox(j)), sza(ibox(j)), dist, rtvcolm(0,ibox(j)), colm_sim, apcolm(ibox(j)), wvcolm(ibox(j)), dfs(ibox(j)), snr5a(ibox(j)), snr6a(ibox(j)), snr6r(ibox(j)), anom_flags(0:4,ibox(j)), modisclrfrac(ibox(j)), mopcldratio(ibox(j))

              endif else begin

                printf, 1, format='(4i4,3f8.1,4e11.3,f7.4,1x,e10.3,1x,e10.3,1x,e10.3,5i3,1x,f9.4,1x,f9.4)', pxsttrk(0,ibox(j)), pxsttrk(1,ibox(j)), isfc(ibox(j)), icld(ibox(j)), psfc(ibox(j)), sza(ibox(j)), dist, rtvcolm(0,ibox(j)), colm_sim, apcolm(ibox(j)), wvcolm(ibox(j)), dfs(ibox(j)), snr5a(ibox(j)), snr6a(ibox(j)), snr6r(ibox(j)), anom_flags(0:4,ibox(j)), missing_val, missing_val

              endelse

              printf, 1, format='(10f10.4)', rtv1_10lv
              printf, 1, format='(10f10.4)', simprof_10lv
              printf, 1, format='(10f10.4)', ap1_10lv
              printf, 1, format='(10f10.4)', logvalvmr_10lv
              printf, 1, format='(10f10.4)', akrowsum_10lv

            endif else begin

              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

              ;;;;;;;;;;;;;;;;;  800 mb > psfc > 700 mb ;;;;;;;;;;;;;;;;

              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

              if (psfc(ibox(j)) lt prs(1) and psfc(ibox(j)) gt prs(2)) then begin

                ;print, 'psfc = ' + strtrim(psfc(ibox(j)),2)

                prtv = [psfc(ibox(j)),prs(2:8)]

                ak1 = transpose(reform(avkrn(2:9,2:9,ibox(j)),8,8))

                if (min([apsfcmr(0,ibox(j)),reform(approfl(0,2:8,ibox(j)))]) lt 0.) then begin
                  print, 'negative values in a.p. VMR profile'
                  stop
                endif

                if (min([rtvsfcmr(0,ibox(j)),reform(rtvprofl(0,2:8,ibox(j)))]) lt 0.) then begin
                  print, 'negative values in retrieved VMR profile'
                  stop
                endif

                ap1 = alog10([apsfcmr(0,ibox(j)),reform(approfl(0,2:8,ibox(j)))])
                rtv1 = alog10([rtvsfcmr(0,ibox(j)),reform(rtvprofl(0,2:8,ibox(j)))])

                ; instead of interpolating, average VMR values in layer above each level

                valvmrint = fltarr(8)
                valvmrint(*) = -999.

                for ilev = 0, 6 do begin
                  ilyr = where(valprs le prtv(ilev) and valprs gt prtv(ilev+1),nlyr)
                  if (nlyr lt 1) then begin
                    ilyr = where(valprs gt prtv(ilev),nlyr)
                    valvmrint(ilev) = valvmr(ilyr(0))
                  endif else begin
                    valvmrint(ilev) = total(valvmr(ilyr))/nlyr
                  endelse
                endfor

                ; 100 hPa retrieval represents layer from 100 hPa to 50 hPa (i.e. 70 and 100 hPa levels)
                ilyr100 = where(valprs gt 50. and valprs le 100.,nlyr)
                valvmrint(7) = total(valvmr(ilyr100))/nlyr

                if (min(valvmrint) lt 0.) then begin
                  print, 'negative values in retrieved VMR profile'
                  stop
                endif

                logvalvmr = alog10(valvmrint)

                simprof = ap1 + ak1 ## transpose(logvalvmr - ap1)

                colm_ap = apcolm(ibox(j))

                ak_colm = reform(colm_avkrn(2:9,ibox(j)))

                colm_sim = colm_ap + ( ak_colm ## transpose(logvalvmr - ap1) )

                ;              akrowsum = reform(avkrn_sums(0:9,ibox(j)))
                akrowsum_10lv = [avkrn_sums(2,ibox(j)),-9.999,-9.999,reform(avkrn_sums(3:9,ibox(j)))]

                rtv1_10lv = [rtv1(0),-9.999, -9.999, rtv1(1:7)]
                simprof_10lv = [simprof(0),-9.999, -9.999, simprof(1:7)]
                ap1_10lv = [ap1(0), -9.999, -9.999, ap1(1:7)]
                logvalvmr_10lv = [logvalvmr(0), -9.999, -9.999, logvalvmr(1:7)]

                ; common output format w/ V8 NOAA validation files

                ;              printf, 1, format='(4i4,3f8.1,4e11.3,f7.4,1x,e10.3,1x,e10.3,1x,e10.3,5i3)', pxsttrk(0,ibox(j)), pxsttrk(1,ibox(j)), isfc(ibox(j)), icld(ibox(j)), psfc(ibox(j)), sza(ibox(j)), dist, rtvcolm(0,ibox(j)), colm_sim, apcolm(ibox(j)), wvcolm(ibox(j)), dfs(ibox(j)), snr5a(ibox(j)), snr6a(ibox(j)), snr6r(ibox(j)), anom_flags(0:4,ibox(j))
                ;              printf, 1, format='(4i4,3f8.1,4e11.3,f7.4,1x,e10.3,1x,e10.3,1x,e10.3,5i3,1x,f9.4,1x,f9.4)', pxsttrk(0,ibox(j)), pxsttrk(1,ibox(j)), isfc(ibox(j)), icld(ibox(j)), psfc(ibox(j)), sza(ibox(j)), dist, rtvcolm(0,ibox(j)), colm_sim, apcolm(ibox(j)), wvcolm(ibox(j)), dfs(ibox(j)), snr5a(ibox(j)), snr6a(ibox(j)), snr6r(ibox(j)), anom_flags(0:4,ibox(j)), modisclrfrac(ibox(j)), mopcldratio(ibox(j))

                if (V8mode ne 'T') then begin

                  printf, 1, format='(4i4,3f8.1,4e11.3,f7.4,1x,e10.3,1x,e10.3,1x,e10.3,5i3,1x,f9.4,1x,f9.4)', pxsttrk(0,ibox(j)), pxsttrk(1,ibox(j)), isfc(ibox(j)), icld(ibox(j)), psfc(ibox(j)), sza(ibox(j)), dist, rtvcolm(0,ibox(j)), colm_sim, apcolm(ibox(j)), wvcolm(ibox(j)), dfs(ibox(j)), snr5a(ibox(j)), snr6a(ibox(j)), snr6r(ibox(j)), anom_flags(0:4,ibox(j)), modisclrfrac(ibox(j)), mopcldratio(ibox(j))

                endif else begin

                  printf, 1, format='(4i4,3f8.1,4e11.3,f7.4,1x,e10.3,1x,e10.3,1x,e10.3,5i3,1x,f9.4,1x,f9.4)', pxsttrk(0,ibox(j)), pxsttrk(1,ibox(j)), isfc(ibox(j)), icld(ibox(j)), psfc(ibox(j)), sza(ibox(j)), dist, rtvcolm(0,ibox(j)), colm_sim, apcolm(ibox(j)), wvcolm(ibox(j)), dfs(ibox(j)), snr5a(ibox(j)), snr6a(ibox(j)), snr6r(ibox(j)), anom_flags(0:4,ibox(j)), missing_val, missing_val

                endelse


                printf, 1, format='(10f10.4)', rtv1_10lv
                printf, 1, format='(10f10.4)', simprof_10lv
                printf, 1, format='(10f10.4)', ap1_10lv
                printf, 1, format='(10f10.4)', logvalvmr_10lv
                printf, 1, format='(10f10.4)', akrowsum_10lv

              endif

            endelse

          endelse

        endfor

      endfor

      close, 1

      spawn, 'wc -l ' + outfile, returnstring

      if (returnstring(0) le 2) then begin
        spawn, 'rm -f ' + outfile
      endif

    endfor

  endfor

  return
end 
