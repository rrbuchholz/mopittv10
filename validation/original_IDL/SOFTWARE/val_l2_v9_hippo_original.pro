;Original by Merritt Deeter circa 03.2022
;modifications by Sara Martinez-Alonso 08.2024
;

pro val_L2_v9_hippo

  ; revised to add extra cloud diagnostics (MOPCLD radiance ratio and
  ; MODIS cloud fraction) in output files

  ; updated for V8
  ; - include cloud index for use in filtering later
  ; - common output format w/ NOAA validation output files

  ;sitecodes = ['2009hippo1qcls','2009hippo2qcls','2010hippo3qcls','2011hippo4qcls','2011hippo5qcls']
  ;sitecodes = ['2009hippo1qcls','2009hippo2qcls','2010hippo3qcls','2011hippo4qcls','2011hippo5qcls','ACRIDICON']

  ; HIPPO, ACRIDICON and ATOM (phases 1 and 2)
  ;sitecodes = ['2009hippo1qcls','2009hippo2qcls','2010hippo3qcls','2011hippo4qcls','2011hippo5qcls','ACRIDICON','AToM_QCLS_2016','AToM_QCLS_2017']

  ; ATOM (phases 1 and 2) (release 1/16/18)
  ;sitecodes = ['AToM_QCLS_2016','AToM_QCLS_2017']

  ; repeat ATOM (release 12/9/18)
  ;sitecodes = ['ATom_QCLS_2016_tmp','ATom_QCLS_2017a_tmp','ATom_QCLS_2017b_tmp','ATom_QCLS_2018_tmp']

  ; MODIS 6 vs MODIS 6.1 cloud mask tests
  ;sitecodes = ['2011hippo5qcls']

  ; HIPPO 1 and 2 only
  ;sitecodes = ['2009hippo1qcls','2009hippo2qcls']

  ;
  ; ACRIDICON only
  ;sitecodes = ['ACRIDICON']

  ; HIPPO and ATOM
  ;sitecodes = ['2009hippo1qcls','2009hippo2qcls','2010hippo3qcls','2011hippo4qcls','2011hippo5qcls','ATom_QCLS_2016_tmp','ATom_QCLS_2017a_tmp','ATom_QCLS_2017b','ATom_QCLS_2018_tmp']
  ;sitecodes = ['ATom_QCLS_2017b_tmp']
  sitecodes = ['2009hippo1qcls','2009hippo2qcls','2010hippo3qcls','2011hippo4qcls','2011hippo5qcls','ATom_QCLS_2016_tmp','ATom_QCLS_2017a_tmp','ATom_QCLS_2017b_tmp','ATom_QCLS_2018_tmp']

  ; HIPPO, ATom and ACRIDICON
  ;sitecodes = ['2009hippo1qcls','2009hippo2qcls','2010hippo3qcls','2011hippo4qcls','2011hippo5qcls','ATom_QCLS_2016_tmp','ATom_QCLS_2017a_tmp','ATom_QCLS_2017b_tmp','ATom_QCLS_2018_tmp','ACRIDICON']

  ; new V9 experiment to test effect of V9 L1 files
  ;sitecodes = ['2009hippo1qcls']
  ;sitecodes = ['ATom_QCLS_2018_tmp']

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  V8mode = 'T'
  ;V8mode = 'F'
  missing_val = -999.

  ; KORUS-AQ
  ;sitecodes = ['2016korusaq']

  ; for tests
  ;sitecodes = ['2009hippo1qcls']

  nsites = n_elements(sitecodes)

  junk = ''
  isprofl = fltarr(2,35)

  ; thresholds for accepting MOPITT retrievals
  dlatmax = 2.5
  dlonmax = 2.5

  distmax = 200.
  ;distmax = 100.

  ; HIPPO and ATom 'experimental' runs
  ;p_bot_thr = 800.
  ;p_top_thr = 250.
  ;distmax = 200.
  ;distmax = 100.

  if (sitecodes(0) eq '2016korusaq') then begin
    ; decrease distmax for KORUS-AQ
    distmax = 100.
  endif

  ;dthrsmax = 12.
  ; for ACRIDICON
  dthrsmax = 12.

  ;; set threshold pressure: discard in-situ profiles with no upper-trop data
  ;p_bot_thr = 800.
  ;p_top_thr = 400.
  ;;p_top_thr = 200.

  ; for ACRIDICON

  ;if (sitecodes(0) eq 'ACRIDICON') then begin
  ;  p_bot_thr = 800.
  ;  p_top_thr = 450.
  ;endif

  ;log10e = alog10(exp(1.))


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; begin processing

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  for isite = 0, nsites-1 do begin

    ;; set threshold pressure: discard in-situ profiles with no upper-trop data
    p_bot_thr = 800.
    p_top_thr = 400.
    ;p_top_thr = 200.

    ; for ACRIDICON

    if (sitecodes(isite) eq 'ACRIDICON') then begin
      p_bot_thr = 800.
      p_top_thr = 450.
    endif

    if (sitecodes(isite) eq 'ACRIDICON') then begin
      spawnstr = 'ls /home/mnd/amazon_studies/acridicon/INTERPOLATED_PROFILES/*.txt'
    endif else begin

      if (sitecodes(isite) eq '2016korusaq') then begin
        spawnstr = 'ls /MOPITT/project/mopsips/data/val/campaigns/camchem/' + sitecodes(isite) + '/INTERPOLATED_PROFILES/*.???'
      endif else begin

        spawnstr = 'ls /MOPITT/project/mopsips/data/val/campaigns/camchem/' + sitecodes(isite) + '/*.???'

      endelse

    endelse


    spawn, spawnstr, valfiles

    nvalfiles = n_elements(valfiles)

    print, nvalfiles

    if (nvalfiles lt 1) then continue

    for ivalfile = 0, nvalfiles-1 do begin

      print, valfiles(ivalfile)

      ; get date and time from file name

      tmp = strsplit(valfiles(ivalfile),'_',/extract)
      ntmp = n_elements(tmp)

      if (sitecodes(isite) eq 'ACRIDICON' or sitecodes(isite) eq '2016korusaq') then begin

        datestr = tmp(ntmp-2)
        profyr = strmid(datestr,9,4)
        profmo = strmid(datestr,14,2)
        profdy = strmid(datestr,17,2)
        profhr = strmid(datestr,20,2)
        profmn = strmid(datestr,22,2)

      endif else begin

        ;      if (sitecodes(isite) eq 'AToM_NOAA_2016' or sitecodes(isite) eq 'AToM_NOAA_2017' or sitecodes(isite) eq 'AToM_QCLS_2016' or sitecodes(isite) eq 'AToM_QCLS_2017') then begin
        ;      if (sitecodes(isite) eq 'AToM_NOAA_2016' or sitecodes(isite) eq 'AToM_NOAA_2017' or sitecodes(isite) eq 'ATom_QCLS_2016' or sitecodes(isite) eq 'ATom_QCLS_2017a' or sitecodes(isite) eq 'ATom_QCLS_2017b' or sitecodes(isite) eq 'ATom_QCLS_2018') then begin
        if (sitecodes(isite) eq 'AToM_NOAA_2016' or sitecodes(isite) eq 'AToM_NOAA_2017' or sitecodes(isite) eq 'ATom_QCLS_2016' or sitecodes(isite) eq 'ATom_QCLS_2017a' or sitecodes(isite) eq 'ATom_QCLS_2017b' or sitecodes(isite) eq 'ATom_QCLS_2018' or sitecodes(isite) eq 'ATom_QCLS_2016_tmp' or sitecodes(isite) eq 'ATom_QCLS_2017a_tmp' or sitecodes(isite) eq 'ATom_QCLS_2017b_tmp' or sitecodes(isite) eq 'ATom_QCLS_2018_tmp') then begin

          datestr = tmp(ntmp-2)

          if (sitecodes(isite) eq 'ATom_QCLS_2017a' or sitecodes(isite) eq 'ATom_QCLS_2017b') then begin
            ; remove first character because of presence of 'a' or 'b' in sitecode
            datetmp = datestr
            datestr = strmid(datetmp,1,21)

          endif

          if (sitecodes(isite) eq 'ATom_QCLS_2016_tmp' or sitecodes(isite) eq 'ATom_QCLS_2017a_tmp' or sitecodes(isite) eq 'ATom_QCLS_2017b_tmp' or sitecodes(isite) eq 'ATom_QCLS_2018_tmp') then begin

            ; add dummy character so that yr, mo, and dy can still be extracted
            ; using same code below
            datetmp = datestr
            datestr = 'x' + datetmp

          endif

          profyr = strmid(datestr,5,4)
          profmo = strmid(datestr,10,2)
          profdy = strmid(datestr,13,2)
          profhr = strmid(datestr,16,2)
          profmn = strmid(datestr,18,2)

        endif else begin

          datestr = tmp(ntmp-1)
          profyr = strmid(datestr,0,4)
          profmo = strmid(datestr,5,2)
          profdy = strmid(datestr,8,2)
          profhr = strmid(datestr,11,2)
          profmn = strmid(datestr,13,2)

        endelse

      endelse

      ; change date and time if profhr > 23

      if (fix(profhr) ge 24) then begin

        jday1 = julday(fix(profmo),fix(profdy),fix(profyr))
        jday2 = jday1 + 1L
        caldat, jday2, profmo1,profdy1,profyr1

        profyr = strtrim(profyr1,2)

        if (profmo1 lt 10) then profmo = '0' + strtrim(profmo1,2)
        if (profmo1 ge 10) then profmo = strtrim(profmo1,2)

        if (profdy1 lt 10) then profdy = '0' + strtrim(profdy1,2)
        if (profdy1 ge 10) then profdy = strtrim(profdy1,2)

        profhr_fix = fix(profhr) - 24
        if (profhr_fix lt 10) then profhr = '0' + strtrim(profhr_fix,2)
        if (profhr_fix ge 10) then profhr = strtrim(profhr_fix,2)

      endif

      ; read in-situ profile

      openr, 1, valfiles(ivalfile)

      ;    if (sitecodes(isite) eq 'ACRIDICON' or sitecodes(isite) eq '2016korusaq' or sitecodes(isite) eq 'AToM_NOAA_2016' or sitecodes(isite) eq 'AToM_NOAA_2017' or sitecodes(isite) eq 'AToM_QCLS_2016' or sitecodes(isite) eq 'AToM_QCLS_2017') then begin
      ;    if (sitecodes(isite) eq 'ACRIDICON' or sitecodes(isite) eq '2016korusaq' or sitecodes(isite) eq 'AToM_NOAA_2016' or sitecodes(isite) eq 'AToM_NOAA_2017' or sitecodes(isite) eq 'ATom_QCLS_2016' or sitecodes(isite) eq 'ATom_QCLS_2017a' or sitecodes(isite) eq 'ATom_QCLS_2017b' or sitecodes(isite) eq 'ATom_QCLS_2018') then begin
      if (sitecodes(isite) eq 'ACRIDICON' or sitecodes(isite) eq '2016korusaq' or sitecodes(isite) eq 'AToM_NOAA_2016' or sitecodes(isite) eq 'AToM_NOAA_2017' or sitecodes(isite) eq 'ATom_QCLS_2016' or sitecodes(isite) eq 'ATom_QCLS_2017a' or sitecodes(isite) eq 'ATom_QCLS_2017b' or sitecodes(isite) eq 'ATom_QCLS_2018' or sitecodes(isite) eq 'ATom_QCLS_2016_tmp' or sitecodes(isite) eq 'ATom_QCLS_2017a_tmp' or sitecodes(isite) eq 'ATom_QCLS_2017b_tmp' or sitecodes(isite) eq 'ATom_QCLS_2018_tmp') then begin
        readf, 1, junk
        readf, 1, junk
        readf, 1, junk
      endif else begin
        readf, 1, junk
        readf, 1, junk
      endelse

      tmp = strsplit(junk,/extract)
      proflat = tmp(0)
      proflon = tmp(1)
      p_obs_top = float(tmp(3))
      p_obs_bot = float(tmp(2))
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

      if (p_obs_top gt p_top_thr or p_obs_bot lt p_bot_thr) then continue

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

      print, ncfile

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

      ; convert CO dry-air mole fraction VMR to CO moist-air mole fraction VMR

      for jlev = 0, 31 do begin
        valvmr(jlev) = valvmr(jlev)*(1. - vmrh2o(jlev))
      endfor

      valvmr(32) = valvmr(32)*(1. - vmrh2o(31))
      valvmr(33) = valvmr(33)*(1. - vmrh2o(31))
      valvmr(34) = valvmr(34)*(1. - vmrh2o(31))

      ;;;;;;;;;;;;;;;;;;;;; end of new code ;;;;;;;;;;;;;;;;;;;;

      ; file1 contains MOPITT data for same day as in-situ obs

      mprofyr = profyr
      mprofmo = profmo
      mprofdy = profdy


      ;;;;;;;;;;;;;;;;;;;; V9* ;;;;;;;;;;;;;;;;

      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV9/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.3.1.he5'
      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV94/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.4.1.he5'
      spawnstr =  'ls /MOPITT/V8T/Archive/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V18.0.1.he5'

      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV95T/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.5.1.he5'
      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV95T/L2-5/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.5.1.he5'
      ; new 'radfix4' run completed 10/4/20
      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV95T/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.5.1.he5'

      ; first 'V9 OPS' run - used old V8 L1 files
      ;     spawnstr =  'ls /MOPITT/TEST/ArchiveV95T/L2-V9-1/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.9.1.he5'
      ; new V9 experiment to test effect of V9 L1 files (200901 only)
      ;     spawnstr =  'ls /MOPITT/V9T/Archive/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.9.1.he5'


      ; NIR-only
      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV94N/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02N-*L2V19.4.2.he5'
      ;    spawnstr =  'ls /MOPITT/V8N/Archive/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02N-*L2V18.0.2.he5'

      ; JNT
      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV94J/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02J-*L2V19.4.3.he5'
      ;    spawnstr =  'ls /MOPITT/V8J/Archive/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02J-*L2V18.0.3.he5'

      ; 'Archival' V9 files
      ;    spawnstr =  'ls /MOPITT/V9T/Archive/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.9.1.he5'


      spawn, spawnstr, files

      file1 = files(0)

      jday1 = julday(fix(profmo),fix(profdy),fix(profyr))

      ; file2 contains MOPITT data for day before in-situ obs

      jday2 = jday1 - 1L
      caldat, jday2, profmo1,profdy1,profyr1

      mprofyr = strtrim(profyr1,2)

      if (profmo1 lt 10) then mprofmo = '0' + strtrim(profmo1,2)
      if (profmo1 ge 10) then mprofmo = strtrim(profmo1,2)

      if (profdy1 lt 10) then mprofdy = '0' + strtrim(profdy1,2)
      if (profdy1 ge 10) then mprofdy = strtrim(profdy1,2)


      ;;;;;;;;;;;;;;;;;;;; V9* ;;;;;;;;;;;;;;;;

      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV9/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.3.1.he5'
      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV94/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.4.1.he5'
      spawnstr =  'ls /MOPITT/V8T/Archive/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V18.0.1.he5'

      ; first 'V9 OPS' run - used old V8 L1 files
      ;     spawnstr =  'ls /MOPITT/TEST/ArchiveV95T/L2-V9-1/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.9.1.he5'
      ; new V9 experiment to test effect of V9 L1 files (200901 only)
      ;     spawnstr =  'ls /MOPITT/V9T/Archive/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.9.1.he5'

      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV95T/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.5.1.he5'
      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV95T/L2-5/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.5.1.he5'
      ; new 'radfix4' run completed 10/4/20
      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV95T/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.5.1.he5'

      ; NIR-only
      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV94N/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02N-*L2V19.4.2.he5'
      ;    spawnstr =  'ls /MOPITT/V8N/Archive/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02N-*L2V18.0.2.he5'

      ; JNT
      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV94J/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02J-*L2V19.4.3.he5'
      ;    spawnstr =  'ls /MOPITT/V8J/Archive/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02J-*L2V18.0.3.he5'

      ; 'Archival' V9 files
      ;    spawnstr =  'ls /MOPITT/V9T/Archive/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.9.1.he5'

      spawn, spawnstr, files

      file2 = files(0)

      ; file3 contains MOPITT data for day after in-situ obs

      jday2 = jday1 + 1L
      caldat, jday2, profmo1,profdy1,profyr1

      mprofyr = strtrim(profyr1,2)

      if (profmo1 lt 10) then mprofmo = '0' + strtrim(profmo1,2)
      if (profmo1 ge 10) then mprofmo = strtrim(profmo1,2)

      if (profdy1 lt 10) then mprofdy = '0' + strtrim(profdy1,2)
      if (profdy1 ge 10) then mprofdy = strtrim(profdy1,2)


      ;;;;;;;;;;;;;;;;;;;; V9* ;;;;;;;;;;;;;;;;

      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV9/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.3.1.he5'
      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV94/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.4.1.he5'
      spawnstr =  'ls /MOPITT/V8T/Archive/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V18.0.1.he5'

      ; first 'V9 OPS' run - used old V8 L1 files
      ;     spawnstr =  'ls /MOPITT/TEST/ArchiveV95T/L2-V9-1/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.9.1.he5'
      ; new V9 experiment to test effect of V9 L1 files (200901 only)
      ;     spawnstr =  'ls /MOPITT/V9T/Archive/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.9.1.he5'

      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV95T/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.5.1.he5'
      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV95T/L2-5/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.5.1.he5'
      ; new 'radfix4' run completed 10/4/20
      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV95T/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.5.1.he5'

      ; NIR-only
      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV94N/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02N-*L2V19.4.2.he5'
      ;    spawnstr =  'ls /MOPITT/V8N/Archive/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02N-*L2V18.0.2.he5'

      ; JNT
      ;    spawnstr =  'ls /MOPITT/TEST/ArchiveV94J/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02J-*L2V19.4.3.he5'
      ;    spawnstr =  'ls /MOPITT/V8J/Archive/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02J-*L2V18.0.3.he5'

      ; 'Archival' V9 files
      ;    spawnstr =  'ls /MOPITT/V9T/Archive/L2/' + mprofyr + mprofmo + '/' + mprofmo + mprofdy + '/MOP02T-*L2V19.9.1.he5'

      spawn, spawnstr, files

      file3 = files(0)

      l2files = [file1,file2,file3]

      print, l2files(0)
      print, l2files(1)
      print, l2files(2)

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


      ;;;;;;;;;;;;;;;;;;;; V9* ;;;;;;;;;;;;;;;;

      ;    outfile = 'val_L2_v9_xpt1/L2V19.3.1/val_L2_v9.L2V19.3.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.200km.dat'
      ;    outfile = 'val_L2_v9_xpt1/L2V19.4.1/val_L2_v9.L2V19.4.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.200km.dat'
      ;    outfile = 'val_L2_v9_xpt1/V8T_ops/val_L2_v9.L2V18.0.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.200km.dat'
      ;    outfile = 'val_L2_v9_radfix2/L2V19.5.1/val_L2_v9.L2V19.5.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.200km.dat'
      ;    outfile = 'val_L2_v9_radfix3/L2V19.5.1/val_L2_v9.L2V19.5.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.200km.dat'
      ;    outfile = 'val_L2_v9_radfix4/L2V19.5.1/val_L2_v9.L2V19.5.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.200km.dat'

      ;    outfile = 'val_L2_v9_xpt1/L2V19.4.2/val_L2_v9.L2V19.4.2.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.200km.dat'
      ;    outfile = 'val_L2_v9_xpt1/V8N_ops/val_L2_v9.L2V18.0.2.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.200km.dat'

      ;    outfile = 'val_L2_v9_xpt1/L2V19.4.3/val_L2_v9.L2V19.4.3.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.200km.dat'
      ;    outfile = 'val_L2_v9_xpt1/V8J_ops/val_L2_v9.L2V18.0.3.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.200km.dat'

      ;    outfile = 'val_L2_v9_L1xpt/L2V19.9.1/val_L2_v9.L2V19.9.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.200km.dat'
      ; first 'V9 OPS' run - used old V8 L1 files
      ;    outfile = 'val_L2_v9_ops/L2V_V9_1/val_L2_v9.L2V19.9.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.200km.dat'

      ; 'Archival' V9 files
      ;    outfile = 'val_L2_ops/L2V19.9.1/val_L2_v9.L2V19.9.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.200km.dat'
      ;    outfile = 'val_L2_ops/L2V19.9.1c_fullmission/val_L2_v9.L2V19.9.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.200km.dat'
      ; identically processed V8 files
      outfile = 'val_L2_ops/v8t_ops/val_L2_v9.L2V18.0.1.' + sitecodes(isite) + '.' + profyr + profmo + profdy + '.' + profhr + profmn + '.200km.dat'

      openw, 1, outfile

      ; new format 9/10/12

      printf, 1, format='(2f8.1,5i6)', proflat, proflon, profyr, profmo, profdy, profhr, profmn

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      ;;;;;;;;;;; extract relevant info from MOP02 files ;;;;;;;;;;;;;

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      for il2file = 0, 2 do begin

        print, l2files(il2file)

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

        ;      modisclrfrac = reform(modiscld(2,*))/100.

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

          if (il2file eq 0) then dthrs =  secs(ibox(j))/3600.        - (float(profhr) + float(profmn)/60.)
          if (il2file eq 1) then dthrs = (secs(ibox(j))/3600. - 24.) - (float(profhr) + float(profmn)/60.)
          if (il2file eq 2) then dthrs = (secs(ibox(j))/3600. + 24.) - (float(profhr) + float(profmn)/60.)

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

            ; instead of interpolating, average VMR values in layer above each retrieval level

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
              print, 'negv values in valvmrint'
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

            ; add MODIS and MOPCLD cloud diagnostics
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

          endif

          ; next MOPITT pixel
        endfor

        ; next MOP02 file
      endfor

      close, 1

      spawn, 'wc -l ' + outfile, returnstring

      if (returnstring(0) lt 2) then begin
        spawn, 'rm -f ' + outfile
      endif

      ; next in-situ profile
    endfor

    ; next validation site
  endfor

  return
end 
