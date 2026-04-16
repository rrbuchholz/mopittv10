pro xtract_inst_nz_5D6D7D_timeseries

; writes out noise values for 5D, 6D, and 7D (for paper)

; only writes out noise values for 6A and 6D

; extracts timeseries of daily-mean noise values for 7D

; first generate temp output file with noise values

;openw, 1, 'nz_7d_2000.dat'
;openw, 1, 'nz_7d_2001.dat'
;openw, 1, 'nz_7d_2009.dat'
;openw, 1, 'nz_7d_2011.dat'

;openw, 1, 'inst_nz_2000.dat'
;openw, 1, 'inst_nz_mission.dat'
;openw, 1, 'inst_nz_2012.v4.dat'
;openw, 1, 'inst_nz_2012.v5t.dat'
;openw, 1, 'inst_nz_2014.v5t.dat'
;openw, 1, 'inst_nz_2011.v5t.dat'
;openw, 1, 'inst_nz_2013.v5t.dat'

; w/ revised 7D mean daily position noise values
;openw, 1, 'inst_nz_2011.v5t.new7d.dat'
;openw, 1, 'inst_nz_whole_mission.v5t.new7d.dat'
;openw, 1, 'inst_ch6nz_whole_mission.v5n.dat'
;openw, 1, 'inst_nz_5D6D7D_whole_mission.v6.dat'
;openw, 1, 'inst_nz_5D6D7D_whole_mission.v7.dat'
;openw, 1, 'inst_nz_5D6D7D_whole_mission.v8.dat'
;openw, 1, 'inst_nz_5D6D7D_2016.v7.dat'
;openw, 1, 'inst_nz_5D6D7D_2016_2017.v7.dat'

;openw, 1, 'inst_nz_5D6D7D_2018.v8.dat'
;openw, 1, 'inst_nz_5D6D7D_2019.v8.dat'
;openw, 1, 'inst_nz_5D6D7D_2020.v8.dat'
;openw, 1, 'inst_nz_5D6D7D_202004.v8.dat'
;openw, 1, 'inst_nz_5D6D7D_2019_2020.v8.dat'
;openw, 1, 'inst_nz_5D6D7D_202003_202004.v8.dat'

openw, 1, 'inst_nz_5D6D7D_whole_mission.v9.dat'

;for iyr = 2000, 2011 do begin
;for iyr = 2011, 2011 do begin
;for iyr = 2012, 2012 do begin
;for iyr = 2013, 2013 do begin
;for iyr = 2014, 2014 do begin
;for iyr = 2000, 2000 do begin
;for iyr = 2001, 2001 do begin
;for iyr = 2011, 2011 do begin
;for iyr = 2009, 2009 do begin

;for iyr = 2000, 2015 do begin
;for iyr = 2016, 2016 do begin
;for iyr = 2016, 2017 do begin


;for iyr = 2000, 2018 do begin
;for iyr = 2018, 2018 do begin
;for iyr = 2019, 2019 do begin
;for iyr = 2020, 2020 do begin
;for iyr = 2019, 2020 do begin

; V9  
for iyr = 2000, 2021 do begin

  yrstr = strtrim(iyr,2)

  for imo = 1, 12 do begin
;  for imo = 3, 4 do begin
;  for imo = 4, 4 do begin
    if (imo lt 10) then mostr = '0' + strtrim(imo,2)
    if (imo ge 10) then mostr = strtrim(imo,2)

    for idy = 1, 31 do begin
    if (idy lt 10) then dystr = '0' + strtrim(idy,2)
    if (idy ge 10) then dystr = strtrim(idy,2)

;    spawnstr = 'ls /MOPITT/V4/Archive/L1/' + yrstr + mostr + '/' + mostr + dystr + '/' + 'MOP01-*.hdf'
;    spawnstr = 'ls /MOPITT/V5T/Archive/L1/' + yrstr + mostr + '/' + mostr + dystr + '/' + 'MOP01-*.hdf'
;    spawnstr = 'ls /MOPITT/V6T/Archive/L1/' + yrstr + mostr + '/' + mostr + dystr + '/' + 'MOP01-*.he5'
;    spawnstr = 'ls /MOPITT/V7T/Archive/L1/' + yrstr + mostr + '/' + mostr + dystr + '/' + 'MOP01-*.he5'
;    spawnstr = 'ls /MOPITT/V8T/Archive/L1/' + yrstr + mostr + '/' + mostr + dystr + '/' + 'MOP01-*.he5'
    spawnstr = 'ls /MOPITT/V9T/Archive/L1/' + yrstr + mostr + '/' + mostr + dystr + '/' + 'MOP01-*.he5'

    spawn, spawnstr, mop01files

    infile = mop01files(0)

; confirm presence of corresponding mop02file (discards days immed'y after hot cals, etc)

;    spawnstr = 'ls /MOPITT/V8T/Archive/L2/' + yrstr + mostr + '/' + mostr + dystr + '/' + 'MOP02T-*.he5'

;    spawn, spawnstr, mop02files
        
;    testfile = mop02files(0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    if (file_test(infile) eq 0) then continue
;    if (file_test(infile) eq 0 or file_test(testfile) eq 0) then continue

    file_id = H5F_OPEN(infile)

    dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP01/Data Fields/DailyMeanNoise')
    daily_nz = H5D_Read(dataset_id)
    H5D_CLOSE, dataset_id

    dataset_id = H5D_OPEN(file_id, '/HDFEOS/SWATHS/MOP01/Data Fields/DailyMeanPositionNoise')
    daily_pos_nz = H5D_Read(dataset_id)
    H5D_CLOSE, dataset_id

    H5F_CLOSE, file_id

    print, yrstr, mostr, dystr

; channel 5 and 6 noise values from Daily Mean Noise (dimensioned 2,8,4)
;    daily_nz = get_sd(infile, 'Daily Mean Noise')
; actual 7A and 7D noise values are extracted from Daily Mean Position Noise (dimensioned 5,2,2,4)
;    daily_pos_nz = get_sd(infile, 'Daily Mean Position Noise')

    daily_nz_7d = fltarr(4)

    for ipx = 0, 3 do begin
      daily_nz_7d(ipx) = total(daily_pos_nz(0:4,1,1,ipx))/5.
    endfor

; print out instrumental-noise values for 5A, 5D, and 7D
;    printf, 1, format='(i4,2(1x,i2),12(1x,e9.2))', yrstr, mostr, dystr, daily_nz(0,4,0:3), daily_nz(1,4,0:3), daily_nz(1,6,0:3)
;    printf, 1, format='(i4,2(1x,i2),12(1x,e9.2))', yrstr, mostr, dystr, daily_nz(0,4,0:3), daily_nz(1,4,0:3), daily_nz_7d(0:3)

; print out instrumental-noise values for 5D, 6D and 7D

    printf, 1, format='(i4,2(1x,i2),12(1x,e9.2))', yrstr, mostr, dystr, daily_nz(1,4,0:3), daily_nz(1,5,0:3), daily_nz_7d(0:3)

    endfor

  endfor
endfor

close, 1

return
end
