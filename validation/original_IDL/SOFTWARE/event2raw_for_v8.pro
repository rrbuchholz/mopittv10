; Reformat the CMDL *_01D2_event.co files (for 1999-2005), 
;   saving only data without any problems (1st flag).
;   non-background data is not filtered out (CMDL's 2nd flag).
;
;Original code from Louisa Emmons
;Modified by Sara Martinez-Alonso 06.2012
;to read new NOAA event files (for 2008-2012)
;only profiles reaching from P>=750 to P<=450 and withough gaps >=200 hPa are kept
;;Modified by Sara Martinez-Alonso 03.2014
;to read new NOAA event files (for 2012-2014), which have different format
;;Modified by Sara Martinez-Alonso 11.2016
;to read new event files
;hil site differs from all other sites in format
;HIL 2014 02 18 19 52 09  3052-02 A  40.0700  -87.9100  6979.92   364493       co     CCGG   144.080 ..P (17 variables)
;AAO 2009 09 18 18 05 28  3156-03 A  40.7000  -90.4100  3132.40   195.00  2937.40   283877       co     CCGG    89.850 ..P  (19 variable)



@gap_function.pro

pro event2raw_for_v8

;;;;;;;;;;;;;;;;;;CHANGE AS NEEDED;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;this is for files in NOAA_74525860
;sites = ['car','pfa','rta']
;filehead='/exports/home/sma/Desktop/NOAA_VALIDATION/NOAA_74525860/'
;nsites=2

;;this is for files in NOAA_99811703
;sites=['bne', 'car', 'cma', 'dnd', 'esp', 'etl', 'hfm', 'nha', 'pfa', 'rta', 'tgc', 'thd', 'wbi']
;filehead='/exports/home/sma/Desktop/NOAA_VALIDATION/NOAA_99811703/'
;nsites=12

;;this is for files in NOAA_7517020
;sites=   ['aao', 'bne', 'car', 'cma', 'crv', 'dnd', 'esp', 'etl', 'haa', 'hfm', 'hil', 'lef', 'nha', 'pfa', 'rta', 'sca', 'sgp', 'tgc', 'thd', 'wbi', 'wgc']
;alldata= [    1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1]	;0=get only data >=01.01.2012, 1=get all data    
;filehead='/home/sma/NOAA_VALIDATION/PROFILES_FOR_V7_VALIDATION/'						;when reading from my own directories
;;filehead='/project/MOPITT/project/mopsips/data/val/cmdl/profile/co/'						;when reading from the group's directories
;nsites=21-1

;;this is for files in NOAA_52349859
;sites=   ['aao', 'acg', 'act', 'bne', 'car', 'cma', 'crv', 'dnd', 'esp', 'etl', 'haa', 'hil', 'hip', 'lef', 'nha', 'nsa', 'pfa', 'rta', 'sca', 'sgp', 'tgc', 'thd', 'tom', 'wbi']
;alldata= [    1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1]	;0=get only data >=01.01.2012, 1=get all data    
;filehead='/home/sma/NOAA_VALIDATION/NOAA_52349859/'						;when reading from my own directories
;;filehead='/project/MOPITT/project/mopsips/data/val/cmdl/profile/co/'						;when reading from the group's directories
;nsites=n_elements(sites)-1

;;this is for files in NOAA_78221407
;sites=   ['acg', 'act', 'bne', 'car', 'cma', 'crv', 'dnd', 'eco', 'esp', 'etl', 'haa', 'hil', 'lef', 'nha', 'pfa', 'rta', 'sca', 'sgp', 'tgc', 'thd', 'wbi', 'wgc']
;alldata= [    1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1]	;0=get only data >=01.01.2012, 1=get all data    
;filehead='/home/sma/Desktop/NOAA_78221407/'						;when reading from my own directories
;;filehead='/project/MOPITT/project/mopsips/data/val/cmdl/profile/co/'						;when reading from the group's directories
;nsites=n_elements(sites)-1

;this is for files in NOAA_55374648
sites=   ['car', 'cma', 'esp', 'etl', 'hil', 'lef', 'nha', 'nsk', 'pfa', 'rta', 'sca', 'sgp', 'tgc', 'thd', 'wbi']
alldata= [    1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1]	;0=get only data >=01.01.2012, 1=get all data    
filehead='/home/sma/NOAA_VALIDATION/NOAA_55374648/'						;when reading from my own directories
;filehead='/project/MOPITT/project/mopsips/data/val/cmdl/profile/co/'						;when reading from the group's directories
nsites=n_elements(sites)-1

;Criteria used to filter the data. The values 2000, 0, and 1000 are used not to discard any profiles on account of these thresholds
minp=2000	;450.
maxp=0		;750.
deltap=1000	;200.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dd=' '

for isite=0,nsites do begin

  site = sites[isite]

  ;Read CMDL data
  acfile=filehead+'co_'+site+'_aircraft-pfp_1_ccgg_event.txt'
  ;acfile=filehead+'merge_'+site+'_aircraft-pfp_1_ccgg_event.txt'

  spawn, 'wc -l ' + acfile, dd
  nada=strsplit(dd, /extract)
  ndat=fix(nada(0))					;total number of lines in event file
  print, '******** ', acfile

  ;Read ac file
  openr,1,acfile
  readf, 1, dd	;read first comment line which contains the number of comment lines
  nada=strsplit(dd,/extract)
  ncommentlines=fix(nada(2))
  for kk=0, ncommentlines-2 do readf, 1, dd		;skips comment lines
  ndat=ndat-ncommentlines
  sdum=' '
  co_cmdl=fltarr(ndat)
  lat_cmdl=fltarr(ndat)
  lon_cmdl=fltarr(ndat)
  alt_cmdl=fltarr(ndat)
  pres_cmdl=fltarr(ndat)
  jday=fltarr(ndat)
  month=fltarr(ndat)
  day=fltarr(ndat)
  year=fltarr(ndat)
  secs=fltarr(ndat)
  hrmn=strarr(ndat)
  i=0L
  while not eof(1) do begin
   readf,1,sdum
   dataline = strsplit(sdum,/extract)
   yy=FLOAT(dataline[1])
   if ((dataline[0] eq Strupcase(site)) and (alldata(isite) eq 0 and yy ge 2012)) or $
      ((dataline[0] eq Strupcase(site)) and (alldata(isite) eq 1)) then begin
    if Strupcase(site) eq 'ZZZ' then begin	;'HIL' then begin	;for hil data only
     ;variables are arranged as follows:
     ;# data_fields: sample_site_code sample_year sample_month sample_day sample_hour sample_minute sample_seconds sample_id sample_method sample_latitude sample_longitude sample_altitude 
     ;event_number parameter_formula analysis_group_abbr analysis_value analysis_flag
     year[i]=FLOAT(dataline[1])
     month[i]=FIX(dataline[2])
     day[i]=FIX(dataline[3])
     hrmn[i] = String(dataline[4],dataline[5])
     secs[i]=Float(dataline[4])*3600. + Float(dataline[5])*60.
     lat_cmdl[i] = Float(dataline[9])		;21])
     lon_cmdl[i] = Float(dataline[10])		;22])
     alt_cmdl[i] = Float(dataline[23])		;[11]) ;alt in m
     ;pres_cmdl[i] = Float(dataline[21])
    
 ;   if (Strmid(dataline[13],0,1) eq '.') then co_cmdl[i]=dataline[11] $
     if (Strmid(dataline[16],0,1) eq '.') then co_cmdl[i]=dataline[15] $
     else co_cmdl[i] = -999.99

     pres_cmdl[i] = pres_alt(alt_cmdl[i])
     jday[i]=Julday(month[i],day[i],year[i]) - Julday(12,31,year[i]-1)
     i=i+1L   
    endif else begin	;for all data but hil data
     ;;variables are arranged as follows:
     ;;# data_fields: sample_site_code sample_year sample_month sample_day sample_hour sample_minute sample_seconds sample_id sample_method sample_latitude sample_longitude sample_altitude 
     ;;sample_elevation sample_intake_height event_number parameter_formula analysis_group_abbr analysis_value analysis_flag

     ;# data_fields: sample_site_code sample_year sample_month sample_day sample_hour sample_minute sample_seconds sample_id sample_method parameter_formula analysis_group_abbr $
     ;analysis_value analysis_uncertainty analysis_flag analysis_instrument analysis_year analysis_month analysis_day analysis_hour analysis_minute analysis_seconds $
     ;sample_latitude sample_longitude sample_altitude sample_elevation sample_intake_height event_number

     year[i]=FLOAT(dataline[1])
     month[i]=FIX(dataline[2])
     day[i]=FIX(dataline[3])
     hrmn[i] = String(dataline[4],dataline[5])
     secs[i]=Float(dataline[4])*3600. + Float(dataline[5])*60.
     lat_cmdl[i] = Float(dataline[21])	;[9])	
     lon_cmdl[i] = Float(dataline[22])	;[10])
     alt_cmdl[i] = Float(dataline[23])    ;alt in m	[11])
     ;pres_cmdl[i] = Float(dataline[21])
    
     if (Strmid(dataline[13],0,1) eq '.') then co_cmdl[i]=dataline[11] $
     ;if (Strmid(dataline[18],0,1) eq '.') then co_cmdl[i]=dataline[17] $
     else co_cmdl[i] = -999.99

     if alt_cmdl[i] eq -9999.99 then co_cmdl[i] = -999.99	;files processed for v7 validation have in some cases sample_altitude=-9999.99 

     pres_cmdl[i] = pres_alt(alt_cmdl[i])
     jday[i]=Julday(month[i],day[i],year[i]) - Julday(12,31,year[i]-1)
     i=i+1L   
    endelse
   endif
  endwhile
  close,1

  ndat = i

  ; write separate files for each day
  j1=0
  newday:

  jdayflt = jday[j1]
  for j=j1+1,ndat-1 do begin
   ;print,j,jdayflt,jday[j]
   if (jday[j] ne jdayflt) then break
  endfor
  j2=j-1
  indflt = indgen(j2-j1+1)+j1
  ;print,jday[indflt]

  ac_lat = Median(lat_cmdl[indflt])
  ac_lon = Median(lon_cmdl[indflt])
  if (ac_lat eq 0 or ac_lon eq 0) then begin
   print,ac_lat,ac_lon
   read,ac_lat,ac_lon,prompt='Enter lat,lon'
  endif

  date1 = String(year[j1],month[j1],day[j1],hrmn[j1],format='(i4,"-",i2.2,"-",i2.2,".",a4)')

; filter profiles
  phigh=where(pres_cmdl[indflt] ge maxp and co_cmdl[indflt] gt 0., phcount)
  plow= where(pres_cmdl[indflt] le minp and co_cmdl[indflt] gt 0., plcount)
  co_cmdl2=co_cmdl[indflt]
  pres_cmdl2=pres_cmdl[indflt]
  minp2=minp
  maxp2=maxp
  deltap2=deltap
  gap=gap_function(co_cmdl2, pres_cmdl2, minp2, maxp2, deltap2)
  if phcount gt 0 and plcount gt 0 and gap eq 0 then begin
    ;;;;;;;;;;;;;;;;;;CHANGE AS NEEDED;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    result=file_test(site, /directory)
    if result eq 0 then spawn, 'mkdir '+site
    outfile=filehead+'RAW/'+site+'/'+site+'_raw_'+date1+'.asc'							;when writting in my own directories
    ;outfile= '/project/MOPITT/project/mopsips/data/val/cmdl/profile/asc/'+site+'/'+site+'_raw_'+date1+'.asc'	;when writting in the group's directories
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    openw,2,outfile
    printf,2, acfile
    printf,2, String(ac_lat,ac_lon,format='(2f7.1," (Median lat_N,lon_E)")')
    printf,2, 'Year, JulDay, Secs, Mon, Day, Lat_N, Lon_E, Alt_m, Pres_mb, CO_ppbv '
    for i=j1,j2 do printf,2, format='(i6,i5,i7,2(i4),f8.2,f9.2,f8.0,f8.1,f10.2)', $
     year[i], jday[i], secs[i], month[i], day[i], lat_cmdl[i], lon_cmdl[i], alt_cmdl[i], $
     pres_cmdl[i], co_cmdl[i]
    close,2
    
  endif else begin
  
    ;print, 'I DID NOT SAVE FILE '+filehead+'RAW/'+site+'/'+site+'_raw_'+date1+'.asc', phcount, plcount, gap, co_cmdl[indflt]
    ;if phcount ne 0 or plcount ne 0 or gap ne 0 or total(co_cmdl[indflt]) ge 0 then stop
  
  endelse
  ;print,'wrote: ',outfile

  j1=j2+1
  if (j2 lt ndat-1) then goto, newday

 skipfile:

endfor 

end 
