pro xtract_mn_dfs_colm_pxl

;  calculates daily-mean DFS by pixel (ocean only) 

;openw, 1, 'xtract_mn_dfs_pxl.whole_mission.v6t.dat'
;openw, 1, 'xtract_mn_dfs_colm_pxl.whole_mission.v6t.dat'
;openw, 1, 'xtract_mn_dfs_colm_pxl.whole_mission.v7t.dat'
;openw, 1, 'xtract_mn_dfs_colm_pxl.whole_mission.v8t.dat'
openw, 1, 'xtract_mn_dfs_colm_pxl.2018_2019.v8t.dat'

;for iyr = 2009, 2009 do begin
;for iyr = 2004, 2004 do begin
;for iyr = 2000, 2014 do begin
;for iyr = 2000, 2016 do begin
;for iyr = 2000, 2017 do begin
for iyr = 2018, 2019 do begin

;for iyr = 2000, 2014 do begin
  yrstr = strtrim(iyr,2)

;  for imo = 1, 1 do begin
  for imo = 1, 12 do begin
    if (imo lt 10) then mostr = '0' + strtrim(imo,2)
    if (imo ge 10) then mostr = strtrim(imo,2)

    for idy = 1, 31 do begin
      if (idy lt 10) then dystr = '0' + strtrim(idy,2)
      if (idy ge 10) then dystr = strtrim(idy,2)

;      spawnstr = 'ls /MOPITT/V6T/Archive/L2/' + yrstr + mostr + '/' + mostr + dystr + '/' + 'MOP02T-*.he5'
;      spawnstr = 'ls /MOPITT/V7T/Archive/L2/' + yrstr + mostr + '/' + mostr + dystr + '/' + 'MOP02T-*.he5'
      spawnstr = 'ls /MOPITT/V8T/Archive/L2/' + yrstr + mostr + '/' + mostr + dystr + '/' + 'MOP02T-*.he5'

      spawn, spawnstr, mop01files
    
      infile = mop01files(0)
      if (file_test(infile) eq 0) then continue

      print, yrstr, mostr, dystr

      file_id = H5F_OPEN(infile)

      dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Geolocation Fields/Latitude')
      lat = H5D_Read(dataset_id)
      H5D_CLOSE, dataset_id

      dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/DegreesofFreedomforSignal')
      dfs = H5D_Read(dataset_id)
      H5D_CLOSE, dataset_id

      dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/RetrievedCOTotalColumn')
      colm = H5D_Read(dataset_id)
      H5D_CLOSE, dataset_id

      dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/SwathIndex')
      pxtrst = H5D_Read(dataset_id)
      H5D_CLOSE, dataset_id

      dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP02/Data Fields/SurfaceIndex')
      sfcindx = H5D_Read(dataset_id)
      H5D_CLOSE, dataset_id

      H5F_CLOSE, file_id

      ipx = reform(pxtrst(0,*))

; calculate DFS and CO total column mean values over ocean for all retrievals, 60S:60N,
; and 30S:30N
      dfs_mn = fltarr(3,4)
      dfs_mn(*) = -9.999

      colm_mn = fltarr(3,4)
      colm_mn(*) = -9.999

      for i = 0, 3 do begin
        igd = where(ipx eq (i+1) and sfcindx eq 0 and dfs ge 0.,ngd)
        if (ngd gt 1) then dfs_mn(0,i) = mean(dfs(igd))
        if (ngd gt 1) then colm_mn(0,i) = mean(colm(0,igd))
        igd = where(ipx eq (i+1) and lat le 60. and lat ge -60. and sfcindx eq 0 and dfs ge 0.,ngd)
        if (ngd gt 1) then dfs_mn(1,i) = mean(dfs(igd))
        if (ngd gt 1) then colm_mn(1,i) = mean(colm(0,igd))
        igd = where(ipx eq (i+1) and lat le 30. and lat ge -30. and sfcindx eq 0 and dfs ge 0.,ngd)
        if (ngd gt 1) then dfs_mn(2,i) = mean(dfs(igd))
        if (ngd gt 1) then colm_mn(2,i) = mean(colm(0,igd))

      endfor

;      printf, 1, format='(i4,2(1x,i2),12(1x,f8.3))', yrstr, mostr, dystr, reform(dfs_mn(0,0:3)),reform(dfs_mn(1,0:3)), reform(dfs_mn(2,0:3))
      printf, 1, format='(i4,2(1x,i2),12(1x,f5.3),12(1x,e9.3))', yrstr, mostr, dystr, reform(dfs_mn(0,0:3)),reform(dfs_mn(1,0:3)), reform(dfs_mn(2,0:3)), reform(colm_mn(0,0:3)),reform(colm_mn(1,0:3)), reform(colm_mn(2,0:3))

    endfor
  endfor
endfor

close, 1

return
end
