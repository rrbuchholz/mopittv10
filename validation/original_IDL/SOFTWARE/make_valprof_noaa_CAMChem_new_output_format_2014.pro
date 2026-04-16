; Average aircraft profiles to MOPITT 35 levels,
; extrapolation with MOPITT a priori MOZART climatology
;
; Louisa Emmons
; modifications by Sara Martinez-Alonso 9.2011 to use HIPPO profiles
; modifications by Sara Martinez-Alonso 6.2012 to use NOAA profiles
; modifications by Sara Martinez-Alonso 12.2012 to use CAM-Chem/MERRA climatology
; modifications by Sara Martinez-Alonso 1.2013 to print the lat/lon of the measured profiles with two decimals in the .asc files
; modifications by Sara Martinez-Alonso 3.2014 to use newly available NOAA data and not to create .ps files for years with no data

pro make_valprof_noaa_CAMChem_new_output_format_2014

;;;;;;;;;;;;;;;;;;CHANGE AS NEEDED;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;this is for files that predate NOAA_74525860 and NOAA_99811703 - ***RUN FIRST***
;sites = ['bne', 'car', 'cma', 'dnd', 'esp', 'etl', 'haa', 'hfm', 'nha', 'pfa', 'rta', 'sca', 'tgc', 'thd', 'vaa', 'wbi']
;inputhead0='/project/MOPITT/project/mopsips/data/val/cmdl/profile/asc/'
;outputhead='/exports/home/sma/CAM-Chem_forV6/NOAA_VALIDATION/OLDER-FILES/INTERPOLATED_PROFILES/'		;when writting in my own directories
;outputhead='/project/MOPITT/project/mopsips/data/val/cmdl/profile/camchem/'					;when writting in the group's directories
;nsites=15

;this is for files in NOAA_74525860 - will overwrite obsolete files that predate NOAA_74525860
;sites = ['car','pfa','rta']
;inputhead0='/exports/home/sma/NOAA_VALIDATION/NOAA_74525860/RAW/'
;outputhead='/exports/home/sma/CAM-Chem_forV6/NOAA_VALIDATION/NOAA_74525860/INTERPOLATED_PROFILES/'		;when writting in my own directories
;outputhead='/project/MOPITT/project/mopsips/data/val/cmdl/profile/camchem/'					;when writting in the group's directories
;nsites=2

;this is for files in NOAA_99811703 - will overwrite obsolete files that predate NOAA_74525860
;sites=['bne', 'car', 'cma', 'dnd', 'esp', 'etl', 'hfm', 'nha', 'pfa', 'rta', 'tgc', 'thd', 'wbi']
;inputhead0='/exports/home/sma/NOAA_VALIDATION/NOAA_99811703/RAW/'
;outputhead='/exports/home/sma/CAM-Chem_forV6/NOAA_VALIDATION/NOAA_99811703/INTERPOLATED_PROFILES/'		;when writting in my own directories
;outputhead='/project/MOPITT/project/mopsips/data/val/cmdl/profile/camchem/'					;when writting in the group's directories
;nsites=12

;;this is for files in NOAA_7517020
;sites=   ['car', 'cma', 'dnd', 'esp', 'etl', 'nha', 'pfa', 'rta', 'sca', 'tgc', 'thd', 'wbi', 'hil', 'sgp']
;inputhead0='/exports/home/sma/NOAA_VALIDATION/NOAA_7517020/RAW/'								;when reading from my own directories
;;inputhead0='/project/MOPITT/project/mopsips/data/val/cmdl/profile/asc/'					;when reading from the group's directories
;outputhead='/exports/home/sma/NOAA_VALIDATION/NOAA_7517020/INTERPOLATED_PROFILES_NO-NAN-BUG/'						;when writting in my own directories
;;outputhead='/project/MOPITT/project/mopsips/data/val/cmdl/profile/camchem/'					;when writting in the group's directories
;nsites=13

;;this is for v7 files
;sites=   ['aao', 'bne', 'car', 'cma', 'crv', 'dnd', 'esp', 'etl', 'haa', 'hfm', 'hil', 'lef', 'nha', 'pfa', 'rta', 'sca', 'sgp', 'tgc', 'thd', 'wbi', 'wgc']
;inputhead0='/exports/home/sma/NOAA_VALIDATION/PROFILES_FOR_V7_VALIDATION/RAW/'								;when reading from my own directories
;;inputhead0='/project/MOPITT/project/mopsips/data/val/cmdl/profile/asc/'					;when reading from the group's directories
;outputhead='/exports/home/sma/NOAA_VALIDATION/PROFILES_FOR_V7_VALIDATION/INTERPOLATED_PROFILES/'						;when writting in my own directories
;;outputhead='/project/MOPITT/project/mopsips/data/val/cmdl/profile/camchem/'					;when writting in the group's directories
;nsites=21-1

;;this is for v8 files
;sites=   ['aao', 'acg', 'act', 'bne', 'car', 'cma', 'crv', 'dnd', 'esp', 'etl', 'haa', 'hil', 'hip', 'lef', 'nha', 'nsa', 'pfa', 'rta', 'sca', 'sgp', 'tgc', 'thd', 'tom', 'wbi']
;inputhead0='/exports/home/sma/NOAA_VALIDATION/NOAA_52349859/RAW/'						;when reading from my own directories
;;inputhead0='/project/MOPITT/project/mopsips/data/val/cmdl/profile/asc/'					;when reading from the group's directories
;outputhead='/exports/home/sma/NOAA_VALIDATION/NOAA_52349859/INTERPOLATED_PROFILES/'				;when writting in my own directories
;;outputhead='/project/MOPITT/project/mopsips/data/val/cmdl/profile/camchem/'					;when writting in the group's directories
;nsites=n_elements(sites)-1

;;this is for v9 files
;sites=    ['acg', 'act', 'bne', 'car', 'cma', 'crv', 'dnd', 'eco', 'esp', 'etl', 'haa', 'hil', 'lef', 'nha', 'pfa', 'rta', 'sca', 'sgp', 'tgc', 'thd', 'wbi', 'wgc']
;inputhead0='/home/sma/Desktop/NOAA_78221407/RAW/'						;when reading from my own directories
;;inputhead0='/project/MOPITT/project/mopsips/data/val/cmdl/profile/asc/'					;when reading from the group's directories
;outputhead='/home/sma/Desktop/NOAA_78221407/INTERPOLATED_PROFILES/'				;when writting in my own directories
;;outputhead='/project/MOPITT/project/mopsips/data/val/cmdl/profile/camchem/'					;when writting in the group's directories
;nsites=n_elements(sites)-1

;;this is for NOAA_55374648 files
;sites=   ['car', 'cma', 'esp', 'etl', 'hil', 'lef', 'nha', 'nsk', 'pfa', 'rta', 'sca', 'sgp', 'tgc', 'thd', 'wbi']
;inputhead0='/exports/home/sma/NOAA_VALIDATION/NOAA_55374648/RAW/'						;when reading from my own directories
;;inputhead0='/project/MOPITT/project/mopsips/data/val/cmdl/profile/asc/'					;when reading from the group's directories
;outputhead='/exports/home/sma/NOAA_VALIDATION/NOAA_55374648/INTERPOLATED_PROFILES/'				;when writting in my own directories
;;outputhead='/project/MOPITT/project/mopsips/data/val/cmdl/profile/camchem/'					;when writting in the group's directories
;nsites=n_elements(sites)-1

;;this is for OBSPACK_MULTI-SPECIES_1_CCGGAIRCRAFTFLASK_v2.0_2021-02-09 files
;sites=   ['aao','acg','act','bao','bgi','bld','bne','car','cma','cob','crv','dnd','eco','esp','etl','ftl','fwi','haa','hfm','hil','hip','how','inx','lef','mci','mls','mmp','mow', $
;'mrc','msc','nha','nsa','oil','pfa','rta','s2k','sam','san','sca','sgp','tgc','thd','tom','ulb','wbi','wgc']
;inputhead0='/home/sma/NOAA_VALIDATION/OBSPACK_MULTI-SPECIES_1_CCGGAIRCRAFTFLASK_v2.0_2021-02-09/obspack_multi-species_1_CCGGAircraftFlask_v2.0_2021-02-09/data/txt/RAW/' ;when reading from my own directories
;;inputhead0='/project/MOPITT/project/mopsips/data/val/cmdl/profile/asc/'					;when reading from the group's directories
;outputhead='/home/sma/NOAA_VALIDATION/OBSPACK_MULTI-SPECIES_1_CCGGAIRCRAFTFLASK_v2.0_2021-02-09/obspack_multi-species_1_CCGGAircraftFlask_v2.0_2021-02-09/data/txt/INTERPOLATED_PROFILES/' ;when writting in my own directories
;;outputhead='/project/MOPITT/project/mopsips/data/val/cmdl/profile/camchem/'					;when writting in the group's directories
;nsites=n_elements(sites)-1

;this is for files in NOAA_2023-08-23_DATASET
sites=   ['aao', 'bao', 'bgi', 'bne', 'car', 'cma', 'dnd', 'esp', 'etl', 'ftl', 'fwi', 'haa', 'hfm', 'hil', 'how', 'inx', 'lef', $
          'mmp', 'mow', 'nha', 'nsk', 'oil', 'pfa', 'rta', 'san', 'sca', 'sgp', 'tgc', 'thd', 'ulb', 'wbi', 'wgc']
inputhead0='/home/sma/NOAA_VALIDATION/NOAA_2023-08-23_DATASET/co_aircraft-pfp_ccgg_text/RAW/'
outputhead='/home/sma/NOAA_VALIDATION/NOAA_2023-08-23_DATASET/co_aircraft-pfp_ccgg_text/INTERPOLATED_PROFILES/'
filehead='/home/sma/NOAA_VALIDATION/NOAA_2023-08-23_DATASET/co_aircraft-pfp_ccgg_text/'						;when reading from my own directories
nsites=n_elements(sites)-1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
set_plot,'ps'

for yyyy=1990, 2021 do begin		;MOZART files only available till 2011
; ;read MOZART file for year yyyy
 syr = Strtrim(string(yyyy),2)
; year = yyyy

 mozfile='/exports/home/sma/CAM-Chem_forV6/MOPV6_apriori_CAMchemMERRA_avg2000-2009_c20120820.nc'
 print,mozfile
 nc_id=ncdf_open(mozfile)
 ncdf_varget,nc_id,'lat',mozlat			;[96]
 ncdf_varget,nc_id,'lon',mozlon			;[144]
 ncdf_varget,nc_id,'lev',mozlev			;[35]
 ncdf_varget,nc_id,'month',mozdate		;[12]
 ;ncdf_varget,nc_id,'time',moztime		;[12]
 ;ncdf_varget,nc_id,'date',mozdate		;[12]
 ;ncdf_varget,nc_id,'hyam',hyam			;[56]
 ;ncdf_varget,nc_id,'hybm',hybm			;[56]
 ;ncdf_varget,nc_id,'P0',p0			;[1]
 ;ncdf_varget,nc_id,'PS',psurf			;[144,96,12]
 ncdf_varget,nc_id,'T',temp			;[144,96,35,12]
 ncdf_varget,nc_id,'CO', co_all			;[144,96,35,12]
 ncdf_close,nc_id
 nlat=n_elements(mozlat)
 nlon=n_elements(mozlon)
 nlev=n_elements(mozlev)
 ;ntim=n_elements(moztime)
 mozdate=strtrim(string(mozdate),2)
; if yyyy eq 2011 then begin	;2011 only has data till August
;  nada=fltarr(144, 96, 56, 12)
;  nada(*,*,*,0:7)=co_all
;  co_all=nada
;  nada(*,*,*,0:7)=temp
;  temp=nada
;  nada=fltarr(144, 96, 12)
;  nada(*,*,0:7)=psurf
;  psurf=nada
;  nada=strarr(12)
;  nada(0:7)=strtrim(string(mozdate),2)
;  mozdate=nada
; endif
 co_moz=co_all
 temp_moz=temp
 pres_prof=fltarr(nlev)
 for isite=0,nsites do begin
  site = sites[isite]
  ;if nsites eq 15 then inputhead =inputhead0+site+'/'	;because only older raw files are organized in separate directories, according to site
  ;if nsites eq 21-1 then inputhead =inputhead0+site+'/'
  ;;if nsites ne 15 then inputhead =inputhead0  
  ;;if nsites ne 15 then inputhead =inputhead0+site+'/'   ;NOAA_7517020 will also be organized in separate directories, according to site 
  ;if nsites ne 15 and nsites ne 21-1 then inputhead =inputhead0
  inputhead =inputhead0+site+'/'
  inputfile=inputhead+site+'_raw_'+syr+'*.asc'
  ;
  ;check if there are files for isite and yyyy. If not, no empty .ps file will be produced
  cofiles = File_search(inputfile,count=nfiles)
  if fix(strmid(file_basename(cofiles(0)), 8, 4)) ne yyyy then continue
  ;
  
  result=file_test(outputhead+site+'/', /directory)
  if result eq 0 then spawn, 'mkdir '+outputhead+site
  ;
  psfile=outputhead+site+'/'+site+'_'+syr+'.ps'
  device,/port,/inch,xoff=1,yoff=1,xsiz=6.5,ysiz=9,file=psfile
  !p.font=0
  !p.multi=[0,3,2]
  !p.charsize=1.2
  ;get array of the aircraft profiles
  cofiles = File_search(inputfile,count=nfiles)
  for ifile = 0,nfiles-1 do begin
   cofile = cofiles[ifile]
   print,cofile
   spawn, 'wc -l '+cofile, d
   id=strsplit(d,/extract)
   ilines=long(id(0))
   ndata=ilines-3 
   ;ndata = nlines(cofile)-3
   co_ac = fltarr(ndata)
   pres_ac = fltarr(ndata)
   secs = fltarr(ndata)
   lat = fltarr(ndata)
   lon = fltarr(ndata)
   ;read aircraft file
   openr,1,cofile
   sdum=' '
   for kk=0, 2 do readf,1,sdum	;read header lines
   for i=0,ndata-1 do begin
    readf,1,sdum
    cols = strsplit(sdum,/extract)
    yr=cols(0)
    secs[i] = cols[2]
    mon=cols(3)
    if strlen(mon) eq 1 then mon='0'+mon
    day=cols(4)
    if strlen(day) eq 1 then day='0'+day
    lat[i] = cols[5]
    lon[i] = cols[6]
    pres_ac[i] = cols[8]
    co_ac[i] = cols[9]
   endfor
   time=strtrim(string(secs(0)),2)
   print,yr,' ',mon,' ',day,' ',time
   close,1
   ;ac_lat = Mean(lat)			;do for consistency
   ;ac_lon = Mean(lon)			;this would not work if profile crosses +-180 longitude meridian
   ;ac_sec = Mean(secs)			;ac_sec was never used
   ac_lon=lon (fix(ndata/2))		;use lon of the point in the center of the profile
   ac_lat=lat (fix(ndata/2))		;do for consistency
   prmin = Min(pres_ac, max=prmax, /nan)
   print,ac_lat,ac_lon,prmin,prmax
   hour = Floor(secs[0]/3600)
   minutes = Floor((secs[0]-(hour*3600))/60)
   hrmin = String(hour,minutes,format='(i2.2,i2.2)')
   date1 = yr+'-'+mon+'-'+day+'.'+hrmin
   print,date1,secs[0]
   ;find lat,lon,month for mozart profile
   imzlat = (ac_lat + 90.)*((nlat-1)/180.)
   if (ac_lon lt 0) then ac_lon = ac_lon+360.
   imzlon = ac_lon * (nlon/360.)
   ilat = ROUND(imzlat)
   ilon = ROUND(imzlon)
   print,'extracting MOZART for: ',mozlat[ilat],mozlon[ilon]
   itim = mon-1
   print,'A/C: ',ac_lat,ac_lon,mon
   print,'MOZ: ',mozlat[ilat],mozlon[ilon],'   ', mozdate(itim)

;from the version which used MOZART
;; This is how we did it originally (i.e., in 2011): we extrapolated the HIPPO profiles using MOZART's a priori
;; as used by MOPITT:
;; pres_prof = mozlev	;mozlev is the pressure grid read from the climatology file - per Louisa's email
;; However, from Louisa's 2012 email: "The MOPITT apriori file does not have P0,PS, hyam, hybm, so we had to use 'lev'.  It would 
;; be better to calculate the pressures. In this case the pressures will be different for every profile (because PS
;; is different for each grid box."
;; Hence, now we use MOZART monthly means instead and recalculate pressure level accordingly:
;; P[ilon,ilat,ilev,itim] = P0 * hyam[ilev] + PS[ilon,ilat,itim] * hybm[ilev] 	
;; pres_prof=(hyam*p0 + hybm*psurf(ilon,ilat,itim)) * 0.01			;hPa (from read_moz_co.pro)
;; co_prof = Reform(co_moz[ilon,ilat,*,itim]) * 1.e9  ;ppbv			;per Louisa's email
;; temp_prof = Reform(temp_moz[ilon,ilat,*,itim])				;per Louisa's email
;; zmid = alt_pres(pres_prof)/1000.   ;altitude in km

;from the original, but using CAM-Chem/MERRA this time
   pres_prof = mozlev
   co_prof = Reform(co_moz[ilon,ilat,*,itim]) * 1.e9  ;ppbv	;itim was iday in the original
   temp_prof = Reform(temp_moz[ilon,ilat,*,itim])		;itim was iday in the original
   zmid = alt_pres(pres_prof)/1000.   ;altitude in km

   ;print,'Z: ',zmid
   ;troppr = pres_alt(troplev[itim]*1000.)  ;tropopause ht in mbar
   ;calc tropopause height from T
   for k=nlev-1,2,-1 do begin
    if (zmid[k] lt 6) then continue
    if (zmid[k] gt 18) then break
    dtdz = (temp_prof[k] - temp_prof[k-1])/ (zmid[k-1] - zmid[k])
    ;print,'dtdz: ',k,dtdz
    ztrop = k
    if (dtdz le 2) then break
   endfor
   troppr = pres_prof[ztrop]
   print,'Tropopause (k,km,mb): ',ztrop,zmid[ztrop],troppr
   ;Average in situ layers to MOPITT 35 levels
   moplev = [0.2,     1.0,     3.0,     7.0,    10.0,    20.0,    30.0,  40.0, $
     50.0,    70.0,   100.0,   150.0,   200.0,   250.0,   300.0,   350.0, $
    400.0,   450.0,   500.0,   550.0,   600.0,   650.0,   700.0,   750.0, $
    800.0,   850.0,   875.0,   900.0,   925.0,   950.0,   975.0,  1000.0, $
   1020.0,  1040.0,  1060.0]
   moplevi = moplev - 0.5*(moplev-shift(moplev,1))
   moplevi[0] = 0.1
   moplevi = [moplevi,moplev[34]]	;moplevi is a fltarr(36), form 0.1 to 1060., with values in the middle of moplev values
   ;print,moplevi
   co_avg = fltarr(35)
   for i=0,34 do begin
    ind = where(pres_ac gt moplevi[i] and pres_ac le moplevi[i+1] $
    and co_ac gt 0,nalt)			;(sma) the original
    ;and finite(co_ac, /nan) eq 0, nalt)	;(sma) to avoid including NaN values --> BUG
    if (nalt gt 0) then co_avg[i] = Mean(co_ac[ind]) 
   endfor
   print, '***co_avg***', co_avg
   help, co_avg
   ;final CO profile is binned aircraft data, extrapolated 
   ;above to tropopause with value at highest alt of obs, 
   ;in stratosphere with MOZART,
   ;and below with value at lowest alt of obs.
   print,' Averaged data: ',co_avg
   ;find indices for lowest and highest alts of data, and tropopause
   inddat = where(co_avg gt 0,ngood) 
   ibot = inddat[ngood-1]
   itop = inddat[0]
   print,'bot: ',ibot,moplev[ibot],co_avg[ibot]
   print,'top: ',itop,moplev[itop],co_avg[itop]
   ;*********check if there are not CO data
   if ngood gt 0 then begin
    ind = where(moplev gt troppr)
    itrp = ind[0] < (itop-1)
    print,'tropopause: ',itrp,moplev[itrp],troppr  ;,troplev[itim]
    ;Below ac data: use lowest alt valid data
    ;find missing points after good data (lowest alts of profile)
    for i=ibot+1,34 do co_avg[i] = co_avg[ibot]
    ;Above tropopause: use MOZART
    for i=0,itrp-1 do begin
     if (moplev[i] lt pres_prof[0]) then co_avg[i] = co_prof[0] else begin
      indmoz = where(pres_prof gt moplevi[i] and pres_prof le moplevi[i+1])
      if (indmoz[0] ge 0) then co_avg[i] = Mean(co_prof[indmoz])
     endelse
    endfor
    ;Above ac data and below 2 levels below tropopause: 
    ;use averaged aircaft data at highest altitude
    for i=itrp+2,itop-1 do co_avg[i] = co_avg[itop]
    ;Interpolate over missing data
    ind = where(co_avg gt 0, npt)
    if (npt lt 35) then begin
     dat1 = co_avg[ind]
     pr1 = moplev[ind]
     co_avg = Interpol(dat1,pr1,moplev)
    endif
    print,'CO_avg: ',co_avg
    xmax=Max([co_avg,co_ac], /nan)
    !y.margin=[4,4]
    plot,co_prof,pres_prof, /ylog, /ystyle, xrange=[0,xmax], yrange=[1000,100], $	;(sma) yrange=[1100,0.1]
    xtitle = 'CO (ppbv)', psym=1, symsize=0.7, title=date1
    xyouts,!x.crange[1],0.15,String(ac_lat,ac_lon,format='(f5.0,"N,",f5.0,"E")'),align=1.,charsize=0.8
    oplot,[0,xmax],[troppr,troppr],linest=1
    oplot,co_avg,moplev, psym=-4, symsize=0.9, thick=2
    A = FINDGEN(17) * (!PI*2/16.) 
    USERSYM, COS(A), SIN(A), /FILL
    oplot,co_ac,pres_ac, psym=8, symsize=0.7
    xyouts,0.5,0.98,Strupcase(site)+' '+'NOAA profiles'+' extrapolated with CAM-Chem/MERRA monthly mean', /norm,charsize=1.,align=0.5
    print,date1,' ',mozdate(itim)
    outfile = outputhead+site+'/'+site+'_'+date1+'.asc'
    openw,2,outfile
    printf,2, cofile
    printf,2, String(ac_lat,ac_lon,prmax,prmin,ngood,format='(2f7.2,2f6.0,i4," (lat_N,lon_E,presmax_mbar,presmin_mbar, Ndata)")')
    printf,2, 'extrapolated with CAM-Chem/MERRA monthly mean for month# '+mozdate(itim)+ $
    String(mozlat[ilat],mozlon[ilon],format='(f7.1," N, ",f7.1," E")')
    printf,2, 'averaged to MOPITT 35 levels'
    printf,2, '      pres_mb      CO_ppbv'
    for i=0,34 do printf,2,moplev[i] ,co_avg[i]
    close,2
    print,'wrote: ',outfile
    skipday:
   endif  ;if ngood gt 0 then begin
  endfor  ;ifil
  device,/close
  print,psfile
 endfor		;for isite=0,nsites do begin
endfor		;for yyyy=2008, 2012 do begin

end 
;---------------------
; Convert pressure in hPa (mbar) to altitude in meters
; using NACA Standard Atmosphere
; (from NCAR/RAF Bulletin #9, Appendix B:
;    http://raf.atd.ucar.edu/Bulletins/b9appdx_B.html#ALTITUDE)
;    PALT = (Tref/gamma) [1.0 -(Ps/Pref)x]
;
; L. Emmons, 8 Aug 2001.
function alt_pres, pres
pref = 1013.246  ;mbar  reference pressure
tref = 288.15    ;K  reference temperature
gamma = 0.0065   ;K/m  lapse rate
x = 0.190284     ;R gamma/g  (dry air)
palt_m = (tref/gamma) * (1.0 - (pres/pref)^x)
return, palt_m
end
