; Average aircraft profiles to MOPITT 35 levels,
; extrapolation with MOPITT a priori MOZART climatology
;
; Louisa Emmons
; modifications by Sara Martinez-Alonso 9.2011
; modifications by Sara Martinez-Alonso 12.2012 to use CAM-Chem/MERRA monthly means available for 2000-2009
; modifications by Sara Martinez-Alonso 1.2013 to print the lat/lon of the measured profiles with two decimals in the .asc files
; 

pro make_valprof_hippo_CAMChem_new_output_format

;********** Change as needed **************************
site='hippo5'
yyyy='2011'
directory='HIPPO_5'
whichco=4	;4=CO_QCLS 5=CO_RAF
if whichco eq 4 then whichcostr='co_qcls'
if whichco eq 5 then whichcostr='co_raf'
inputfile='/exports/home/sma/HIPPO_1-5_1s/'+directory+'/hippo5_*.txt'
;use outfolder only when writting output files to /project/MOPITT/project/mopsips/data/val/campaigns/camchem/
outfolder='2011hippo5qcls'	;2009hippo1qcls  2009hippo2qcls  2010hippo3qcls  2011hippo4qcls  2011hippo5qcls
;****LOOK FOR OUTFOLDER AND CHANGE FILES'S DESTINATION ACCORDINGLY************* 
;******************************************************

set_plot,'ps'
;psfile=   '/exports/home/sma/CAM-Chem_forV6/HIPPO_1-5_1s/'+directory+'/'+site+'_'+whichcostr+'.ps'		;when writting in my own directories
psfile=   '/project/MOPITT/project/mopsips/data/val/campaigns/camchem/'+outfolder+'/'+site+'_'+whichcostr+'.ps'	;when writting in the group's directories
device,/port,/inch,xoff=1,yoff=1,xsiz=6.5,ysiz=9,file=psfile
!p.font=0
!p.multi=[0,3,2]
!p.charsize=1.2

;;-------------------------------------------------------------------------
;; Read MOZART file (MOPITT a priori)
;;-------------------------------------------------------------------------
; print,mozfile
; nc_id=ncdf_open(mozfile)
; ncdf_varget,nc_id,'lat',mozlat
; ncdf_varget,nc_id,'lon',mozlon
; ncdf_varget,nc_id,'lev',mozlev
; ncdf_varget,nc_id,'month',mozmonth
; nlat=n_elements(mozlat)
; nlon=n_elements(mozlon)
; nlev=n_elements(mozlev)
; ntim=n_elements(mozmonth)
; ncdf_varget,nc_id,'CO', co_moz
; ncdf_varget,nc_id,'T',temp_moz
; ncdf_close,nc_id
;;-------------------------------------------------------------------------

;read CAM-Chem monthly mean
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
 ;if yyyy eq 2011 then begin	;2011 only has data till August
 ; nada=fltarr(144, 96, 56, 12)
 ; nada(*,*,*,0:7)=co_all
 ; co_all=nada
 ; nada(*,*,*,0:7)=temp
 ; temp=nada
 ; nada=fltarr(144, 96, 12)
 ; nada(*,*,0:7)=psurf
 ; psurf=nada
 ; nada=strarr(12)
 ; nada(0:7)=strtrim(string(mozdate),2)
 ; mozdate=nada
 ;endif
 co_moz=co_all
 temp_moz=temp
 pres_prof=fltarr(nlev)
;

; get array of the aircraft profiles
cofiles = File_search(inputfile,count=nfiles)

for ifile = 0,nfiles-1 do begin

 ;get date and seconds of day from filename
 cofile = cofiles[ifile]
 pos1 = strpos(cofile,yyyy)
 yrmonday = Strmid(cofile,pos1,8)
 time = Strmid(cofile,pos1+9,4)			;5) use 4 instead because time in the hippo .txt files is hhmm

 yr = strmid(yrmonday,0,4)
 mon = strmid(yrmonday,4,2)
 day = strmid(yrmonday,6,2)

 print,cofile
 print,yr,' ',mon,' ',day,' ',time

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
 readf,1,sdum
 readf,1,sdum
 readf,1,sdum
 for i=0,ndata-1 do begin
  readf,1,sdum
  cols = strsplit(sdum,/extract)
  secs[i] = cols[0]
  lat[i] = cols[1]
  lon[i] = cols[2]
  pres_ac[i] = cols[3]			;4]
  co_ac[i] = cols[whichco]
 endfor
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

  ; find lat,lon,month for CAM-Chem/MERRA profile
  imzlat = (ac_lat + 90.)*((nlat-1)/180.)
  if (ac_lon lt 0) then ac_lon = ac_lon+360.
  imzlon = ac_lon * (nlon/360.)
  ilat = ROUND(imzlat)
  ilon = ROUND(imzlon)
  itim = mon-1
  datelab = Strtrim(mozdate[itim])
  print,'A/C: ',ac_lat,ac_lon,mon
  print,'MOZ: ',mozlat[ilat],mozlon[ilon],mozdate[itim]

;from the version which used MOZART
;; This is how we did it originally (i.e., in 2011): we extrapolated the HIPPO profiles using MOZART's a priori
;; as used by MOPITT:
;; pres_prof = mozlev	;mozlev is the pressure grid read from the climatology file - per Louisa's 2011 email
;; However, from Louisa's 2012 email: "The MOPITT apriori file does not have P0,PS, hyam, hybm, so we had to use 'lev'.  It would 
;; be better to calculate the pressures. In this case the pressures will be different for every profile (because PS
;; is different for each grid box."
;; Hence, now we use MOZART monthly means instead and recalculate pressure level accordingly:
;  pres_prof=(hyam*p0 + hybm*psurf(ilon,ilat,itim)) * 0.01			;hPa (from read_moz_co.pro)
;  co_prof = Reform(co_moz[ilon,ilat,*,itim]) * 1.e9  ;ppbv			;per Louisa's email
;  temp_prof = Reform(temp_moz[ilon,ilat,*,itim])				;per Louisa's email
;  zmid = alt_pres(pres_prof)/1000.   ;altitude in km

;from the original, but using CAM-Chem/MERRA this time
  pres_prof = mozlev
  co_prof = Reform(co_moz[ilon,ilat,*,itim]) * 1.e9  ;ppbv	;itim was iday in the original
  temp_prof = Reform(temp_moz[ilon,ilat,*,itim])		;itim was iday in the original
  zmid = alt_pres(pres_prof)/1000.   ;altitude in km

  ;print,'Z: ',zmid
  ;troppr = pres_alt(troplev[itim]*1000.)  ;tropopause ht in mbar
  ; calc tropopause height from T
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

  ; Average in situ layers to MOPITT 35 levels
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
;              and co_ac gt 0,nalt)			;(sma) the original
               and finite(co_ac, /nan) eq 0, nalt)	;(sma) to avoid including NaN values 
    if (nalt gt 0) then co_avg[i] = Mean(co_ac[ind]) 
  endfor
print, '***co_avg***', co_avg
help, co_avg
  ; final CO profile is binned aircraft data, extrapolated 
  ;  above to tropopause with value at highest alt of obs, 
  ;  in stratosphere with CAM-Chem/MERRA,
  ;  and below with value at lowest alt of obs.
  print,' Averaged data: ',co_avg

  ; find indices for lowest and highest alts of data, and tropopause
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

  	; Below ac data: use lowest alt valid data
  	;  find missing points after good data (lowest alts of profile)
  	for i=ibot+1,34 do co_avg[i] = co_avg[ibot]

  	; Above tropopause: use CAM-Chem/MERRA
  	for i=0,itrp-1 do begin
  	 if (moplev[i] lt pres_prof[0]) then co_avg[i] = co_prof[0] else begin
  	  indmoz = where(pres_prof gt moplevi[i] and pres_prof le moplevi[i+1])
  	  if (indmoz[0] ge 0) then co_avg[i] = Mean(co_prof[indmoz])
  	 endelse
  	endfor

  	; Above ac data and below 2 levels below tropopause: 
  	;   use averaged aircaft data at highest altitude
  	for i=itrp+2,itop-1 do co_avg[i] = co_avg[itop]

  	; Interpolate over missing data
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
	 xtitle = 'CO (ppbv)', psym=1, symsize=0.7, $
	 title=date1
	xyouts,!x.crange[1],0.15,String(ac_lat,ac_lon,format='(f5.0,"N,",f5.0,"E")'),align=1.,charsize=0.8
	oplot,[0,xmax],[troppr,troppr],linest=1

	oplot,co_avg,moplev, psym=-4, symsize=0.9, thick=2

	A = FINDGEN(17) * (!PI*2/16.) 
	USERSYM, COS(A), SIN(A), /FILL
	oplot,co_ac,pres_ac, psym=8, symsize=0.7

	xyouts,0.5,0.98,Strupcase(site)+' '+strupcase(whichcostr)+', CAM-Chem/MERRA monthly mean', $
	  /norm,charsize=1.,align=0.5

	print,date1,' ',datelab
;	outfile = '/exports/home/sma/CAM-Chem_forV6/HIPPO_1-5_1s/'+directory+'/INTERPOLATED_PROFILES/'+ $	;when writting in my own directories
	outfile = '/project/MOPITT/project/mopsips/data/val/campaigns/camchem/'+outfolder+'/'+ $		;when writting in the group's directories
        site+'_'+whichcostr+'_'+date1+'.asc'
	openw,2,outfile
	printf,2, cofile
	printf,2, String(ac_lat,ac_lon,prmax,prmin,ngood,format='(2f7.2,2f6.0,i4," (lat_N,lon_E,presmax_mbar,presmin_mbar, Ndata)")')
	printf,2, strupcase(whichcostr)+' extrapolated with CAM-Chem/MERRA monthly mean for month# '+datelab+ $
	  String(mozlat[ilat],mozlon[ilon],format='(f7.1," N, ",f7.1," E")')
	printf,2, 'averaged to MOPITT 35 levels'
	printf,2, '      pres_mb      CO_ppbv'
	for i=0,34 do printf,2,moplev[i] ,co_avg[i]
	close,2
	print,'wrote: ',outfile

	skipday:
  endif ;if ngood gt 0 then begin
endfor  ;ifil

device,/close
print,psfile

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
