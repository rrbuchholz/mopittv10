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
;
;10.2021 Sara Martinez-Alonso: modify code to use OBSPACK files, which have a different format that files from previous (non-official) releases 

@gap_function.pro

pro event2raw_for_OBSPACK_files_GE2012_with_horizontal_distance

openw, 123, 'horizontal_distance.txt'
set_plot, 'ps'

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

;;this is for files in NOAA_55374648
;sites=   ['car', 'cma', 'esp', 'etl', 'hil', 'lef', 'nha', 'nsk', 'pfa', 'rta', 'sca', 'sgp', 'tgc', 'thd', 'wbi']
;alldata= [    1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,     1]	;0=get only data >=01.01.2012, 1=get all data    
;filehead='/home/sma/NOAA_VALIDATION/NOAA_55374648/'						;when reading from my own directories
;;filehead='/project/MOPITT/project/mopsips/data/val/cmdl/profile/co/'						;when reading from the group's directories
;nsites=n_elements(sites)-1

;this is for files in OBSPACK_MULTI-SPECIES_1_CCGGAIRCRAFTFLASK_v2.0_2021-02-09
;co_aao_aircraft-pfp_1_ccgg_Event.txt*
;co_acg_aircraft-pfp_1_ccgg_Event.txt*
;co_act_aircraft-pfp_1_ccgg_Event.txt*
;co_bao_aircraft-pfp_1_ccgg_Event.txt*
;co_bgi_aircraft-pfp_1_ccgg_Event.txt*
;co_bld_aircraft-pfp_1_ccgg_Event.txt*
;co_bne_aircraft-pfp_1_ccgg_Event.txt*
;co_car_aircraft-pfp_1_ccgg_Event.txt*
;co_cma_aircraft-pfp_1_ccgg_Event.txt*
;co_cob_aircraft-pfp_1_ccgg_Event.txt*
;co_crv_aircraft-pfp_1_ccgg_Event.txt*
;co_dnd_aircraft-pfp_1_ccgg_Event.txt*
;co_eco_aircraft-pfp_1_ccgg_Event.txt*
;co_esp_aircraft-pfp_1_ccgg_Event.txt*
;co_etl_aircraft-pfp_1_ccgg_Event.txt*
;co_ftl_aircraft-pfp_1_ccgg_Event.txt*
;co_fwi_aircraft-pfp_1_ccgg_Event.txt*
;co_haa_aircraft-pfp_1_ccgg_Event.txt*
;co_hfm_aircraft-pfp_1_ccgg_Event.txt*
;co_hil_aircraft-pfp_1_ccgg_Event.txt*
;co_hip_aircraft-pfp_1_ccgg_Event.txt*
;co_how_aircraft-pfp_1_ccgg_Event.txt*
;co_inx_aircraft-pfp_1_ccgg_Event.txt*
;co_lef_aircraft-pfp_1_ccgg_Event.txt*
;co_mci_aircraft-pfp_1_ccgg_Event.txt*
;co_mls_aircraft-pfp_1_ccgg_Event.txt*
;co_mmp_aircraft-pfp_1_ccgg_Event.txt*
;co_mow_aircraft-pfp_1_ccgg_Event.txt*
;co_mrc_aircraft-pfp_1_ccgg_Event.txt*
;co_msc_aircraft-pfp_1_ccgg_Event.txt*
;co_nha_aircraft-pfp_1_ccgg_Event.txt*
;co_nsa_aircraft-pfp_1_ccgg_Event.txt*
;co_oil_aircraft-pfp_1_ccgg_Event.txt*
;co_pfa_aircraft-pfp_1_ccgg_Event.txt*
;co_rta_aircraft-pfp_1_ccgg_Event.txt*
;co_s2k_aircraft-pfp_1_ccgg_Event.txt*
;co_sam_aircraft-pfp_1_ccgg_Event.txt*
;co_san_aircraft-pfp_1_ccgg_Event.txt*
;co_sca_aircraft-pfp_1_ccgg_Event.txt*
;co_sgp_aircraft-pfp_1_ccgg_Event.txt*
;co_tgc_aircraft-pfp_1_ccgg_Event.txt*
;co_thd_aircraft-pfp_1_ccgg_Event.txt*
;co_tom_aircraft-pfp_1_ccgg_Event.txt*
;co_ulb_aircraft-pfp_1_ccgg_Event.txt*
;co_wbi_aircraft-pfp_1_ccgg_Event.txt*
;co_wgc_aircraft-pfp_1_ccgg_Event.txt*
;
sites=['aao','acg','act','bao','bgi','bld','bne','car','cma','cob','crv','dnd','eco','esp','etl','ftl','fwi','haa','hfm','hil','hip','how','inx','lef','mci','mls','mmp','mow', $
'mrc','msc','nha','nsa','oil','pfa','rta','s2k','sam','san','sca','sgp','tgc','thd','tom','ulb','wbi','wgc']
alldata=intarr(n_elements(sites))
alldata(*)=0				;0=get only data >=01.01.2012, 1=get all data 
filehead='/home/sma/NOAA_VALIDATION/OBSPACK_MULTI-SPECIES_1_CCGGAIRCRAFTFLASK_v2.0_2021-02-09/obspack_multi-species_1_CCGGAircraftFlask_v2.0_2021-02-09/data/txt/' ;when reading from my own directories
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

  acfile=filehead+'co_'+site+'_aircraft-pfp_1_ccgg_Event.txt'
  ;acfile=filehead+'merge_'+site+'_aircraft-pfp_1_ccgg_event.txt'

  spawn, 'wc -l ' + acfile, dd
  nada=strsplit(dd, /extract)
  ndat=fix(nada(0))					;total number of lines in event file
  print, '******** ', acfile

  ;Read ac file
  openr,1,acfile
  readf, 1, dd	;read first comment line which contains the number of comment lines
  nada=strsplit(dd,/extract)
  ncommentlines=fix(nada(3))
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
   dataline = strsplit(sdum,/extract, ',')
   yy=float(strmid(dataline(0),0,4))
   if ((alldata(isite) eq 0 and yy ge 2012)) or $
      ((alldata(isite) eq 1)) then begin
     year[i]=float(strmid(dataline(0),0,4))
     month[i]=float(strmid(dataline(0),5,2))
     day[i]=fix(strmid(dataline(0),8,2))
     hrmn[i]=string(strmid(dataline(0),11,2), strmid(dataline(0),14,2))
     secs[i]=float(strmid(dataline(0),11,2))*3600. + Float(strmid(dataline(0),14,2))*60.
     lat_cmdl[i]=float(dataline(3))
     lon_cmdl[i]=float(dataline(4))
     alt_cmdl[i]=float(dataline(5))
     ;pres_cmdl[i] = Float(dataline[21])
    
     if (Strmid(dataline[8],0,1) eq '.') then co_cmdl[i]=dataline[2] $
     else co_cmdl[i] = -999.99

     if alt_cmdl[i] eq -999.999 then co_cmdl[i] = -999.99	;files processed for v7 validation have in some cases sample_altitude=-9999.99 

     pres_cmdl[i] = pres_alt(alt_cmdl[i])
     jday[i]=Julday(month[i],day[i],year[i]) - Julday(12,31,year[i]-1)
     i=i+1L
   endif
  endwhile
  close,1

  ndat = i

  if ndat eq 0 then goto, skipfile	;this event file had no data >=2012

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
    outfile=filehead+'RAW_WITH_HORIZONTAL_DISTANCE/'+site+'/'+site+'_raw_'+date1+'.asc'							;when writting in my own directories
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
    
    ;plot lat vs lon
    keepmeco=co_cmdl(j1:j2)
    keepmelon=lon_cmdl(j1:j2)
    keepmelat=lat_cmdl(j1:j2)
    keepme=where(finite(keepmeco, /nan) ne 1 and keepmeco gt 0)
    device, file=strmid(strtrim(file_basename(outfile),2), 0, strlen(file_basename(outfile))-4) +'_lat-lon.eps', /helvetica, /inches, ysize=11, xsize=8.5, font_size=20, /TT_FONT, /COLOR, /encapsul
    plot, keepmelon(keepme), keepmelat(keepme), title=strtrim(file_basename(outfile),2), xtitle='Longitude', ytitle='Latitude', xstyle=1, ystyle=1, psym=-4, symsize=1

    ;diagonalkm=round(earthdist(!x.crange(0), !y.crange(0), !x.crange(1), !y.crange(1)))	;distance in km
    diagonalkm=round(distance(!y.crange(0), !x.crange(0), !y.crange(1), !x.crange(1)))	;distance in km    

    xyouts, !x.crange(0)+((!x.crange(1)-!x.crange(0))*0.05), !y.crange(1)-((!y.crange(1)-!y.crange(0))*0.05), strtrim(string(diagonalkm),2)+' km', color=0, charsize=1

    device, /close
    spawn, 'mogrify -format png -density 300x300 '+ strmid(strtrim(file_basename(outfile),2), 0, strlen(file_basename(outfile))-4) +'_lat-lon.eps -define png:format=png32'	;for transparent background
    spawn, 'rm '+strmid(strtrim(file_basename(outfile),2), 0, strlen(file_basename(outfile))-4) +'_lat-lon.eps'
    
    printf, 123, site, diagonalkm
    
    
  endif else begin
  
    ;print, 'I DID NOT SAVE FILE '+filehead+'RAW/'+site+'/'+site+'_raw_'+date1+'.asc', phcount, plcount, gap, co_cmdl[indflt]
    ;if phcount ne 0 or plcount ne 0 or gap ne 0 or total(co_cmdl[indflt]) ge 0 then stop
  
  endelse
  ;print,'wrote: ',outfile

  j1=j2+1
  if (j2 lt ndat-1) then goto, newday

 skipfile:

endfor 

close, 123
set_plot, 'x'

stop

end 
