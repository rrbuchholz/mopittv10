;Sara Martinez-Alonso 07.2019, 12.2019
;.run ATom_ORNL-DAAC_reader.pro

;@gap_fill_function
@gap_function

;inputfile='/home/sma/Desktop/ATom_VS_TROPOMI/ORNL-DAAC_NC_FILE_OUTPUT/ORNL_DAAC_06.17.2019_UPDATE/ATom_merge_1581/data/MER-1HZ_DC8_ATom-4.nc'
;inputfile='/home/sma/Desktop/ATom_VS_TROPOMI/ATom_merge_1581/data/MER10_DC8_ATom-4.nc'	;this is the file Kathryn McKain originally recommended
;inputfile='/home/sma/Desktop/ATom_VS_TROPOMI/ATom_merge_1581/MER-1HZ_DC8_ATom-4.nc'
inputfile='/home/sma/ATom_2019-11-25/MER-1HZ_DC8_ATom-4.nc'
instrument='CO_X'	;'NOAA_Picarro'

;this will be needed to plot the second vertical axis
ypticks=['0','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20']
plevs=fltarr(21)
levsptokm=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
nyticks=12
;e=2.71828
;for iz=0, 20 do plevs(iz)=alog(1013.)-(levsptokm(iz)/7.0)
;plevs=e^plevs
;

;*****************Criteria used to filter the data*******************************
minp=400.
maxp=800.
deltap=200.
;********************************************************************************

;set printing environment
;!p.multi=[0,1,5,0,1]
!x.omargin=[2,2]
!y.omargin=[2,2]
red = fltarr(24)
green = fltarr(24)
blue = fltarr(24)
;for color (black, purp, dark b, blue, cyan, dark g, green, yellow, orange, red, drak gray, gray, black, purp, dark b, blue, cyan, dark g, green, yellow, orange, red, drak gray, gray)
red   =       [0.,   0.5,  0.,    0.,    0.,    0.,     0.,    1.,     1.,    1.,   0.5, 0.75, 0.,   0.5,  0.,    0.,    0.,    0.,     0.,    1.,     1.,    1.,   0.5, 0.75]
green =       [0.,   0.,   0.,    0.,    1.,    0.75,   1.,    1.,     0.5,   0.,   0.5, 0.75, 0.,   0.,   0.,    0.,    1.,    0.75,   1.,    1.,     0.5,   0.,   0.5, 0.75]
blue  =       [0.,   1.,   0.5,   1.,    1.,    0.,     0.,    0.,     0.,    0.,   0.5, 0.75, 0.,   1.,   0.5,   1.,    1.,    0.,     0.,    0.,     0.,    0.,   0.5, 0.75]
tvlct, 255*red, 255*green, 255*blue
; prints to a postcript file
set_plot, 'ps'
!P.FONT=1		;por postcript output
!p.charthick=3
!p.thick=3
!x.thick=3
!y.thick=3
!x.style=1
!y.style=1

d=' '
print, inputfile

;read variables
nc_id=ncdf_open(inputfile)
parentId = NCDF_GROUPSINQ(nc_id) ;get the parent directory ID's

ncdf_varget,nc_id,'CO.X', co_x

;for i=0, 23 do begin & PRODUCT_NOMENCLATURE=ncdf_groupname(ParentID[i]) &  print, i, PRODUCT_NOMENCLATURE & endfor
;
;x=17							;PRODUCT_NOMENCLATURE=NOAA_Picarro
;PRODUCT_NOMENCLATURE=ncdf_groupname(ParentID[x])	
;;print, PRODUCT_NOMENCLATURE
;SUPPORT_ID = ncdf_groupsinq(ParentID[x])
;ncdf_varget,ParentID[x],'CO_NOAA', co 
;
;x=9							;PRODUCT_NOMENCLATURE=Influences
;PRODUCT_NOMENCLATURE=ncdf_groupname(ParentID[x])
;print, PRODUCT_NOMENCLATURE
;SUPPORT_ID = ncdf_groupsinq(ParentID[x])
;ncdf_varget,ParentID[x],'Lat', lat
;ncdf_varget,ParentID[x],'Lon', lon
;ncdf_varget,ParentID[x],'Pres', pres
;ncdf_varget,ParentID[x],'Julian_Day', jd
;
;x=8							;PRODUCT_NOMENCLATURE=Hskping
x=19	;19 for ATom-4	;20 for ATom-2,3	;22 for ATom-1
PRODUCT_NOMENCLATURE=ncdf_groupname(ParentID[x])
;print, PRODUCT_NOMENCLATURE
SUPPORT_ID = ncdf_groupsinq(ParentID[x])
;ncdf_varget,ParentID[x],'HAE_GPS_Altitude', alt
ncdf_varget,ParentID[x],'Day_Of_Year', doy
;
ncdf_varget,nc_id,'UTC_Start', utc_start		;same values as utc_stop
ncdf_varget,nc_id,'Flight_ID', flightid
ncdf_varget,nc_id,'time', time				;time in seconds since Jan 1 2016
jd=(time/86400.)+julday(1,1,2016,0,0,0)

;
;x=23	;22 in 1 HZ file	;23 in 10s file							;PRODUCT_NOMENCLATURE=PFP
;PRODUCT_NOMENCLATURE=ncdf_groupname(ParentID[x])	
;;print, PRODUCT_NOMENCLATURE
;SUPPORT_ID = ncdf_groupsinq(ParentID[x])
;ncdf_varget,ParentID[x],'prof.no', prof
;ncdf_varget,ParentID[x],'Dist', dist
ncdf_varget,nc_id,'prof.no', prof
ncdf_varget,nc_id,'Dist', dist
;
x=0							;PRODUCT_NOMENCLATURE=MMS, Kathryn McKain recommended to get lat, lon, P, alt from here
PRODUCT_NOMENCLATURE=ncdf_groupname(ParentID[x])
;print, PRODUCT_NOMENCLATURE
SUPPORT_ID = ncdf_groupsinq(ParentID[x])
ncdf_varget,ParentID[x],'G_LAT', lat
ncdf_varget,ParentID[x],'G_LONG', lon
ncdf_varget,ParentID[x],'P', pres
ncdf_varget,ParentID[x],'G_ALT', alt
;
ncdf_close,nc_id
;

;clean variables
doy=doy*1.
doynanme=where(doy eq -99999.0, counter)
if counter gt 0 then doy(doynanme)=!values.f_nan
;
conanme=where(co_x eq -99999.0, counter)
if counter gt 0 then co_x(conanme)=!values.f_nan
;
jdnanme=where(jd eq -99999.0, counter)
if counter gt 0 then jd(jdnanme)=!values.f_nan
;
utcnanme=where(utc_start eq -99999.0, counter)
if counter gt 0 then utc_start(utcnanme)=!values.f_nan
;
prof=prof*1.0
profnanme=where(prof eq -99999.0, counter)
if counter gt 0 then prof(profnanme)=!values.f_nan
;
latnanme=where(lat eq -99999.0, counter)
if counter gt 0 then lat(latnanme)=!values.f_nan
;
lonnanme=where(lon eq -99999.0, counter)
if counter gt 0 then lon(lonnanme)=!values.f_nan
;
pnanme=where(pres eq -99999.0, counter)
if counter gt 0 then pres(pnanme)=!values.f_nan
;
altnanme=where(alt eq -99999.0, counter)
if counter gt 0 then alt(altnanme)=!values.f_nan
;

help, conanme, jdnanme, utcnanme, profnanme, latnanme, lonnanme, pnanme, altnanme

template={UTC:0.0d, JDAY:0.0d, LATITUDE:0.0d, LONGITUDE:0.0d, Pressure_Altitude:0.0d, P:0.0d, CO_data:0.0d, yyyymmdd:0.0d, prof_no:0.0d, rf:0.0d, dist:0.0d, doy:0.0d}
data=replicate(template, n_elements(co_x))
;syy=strtrim(string(yy),2)
;smm=strtrim(string(mm),2)
;smm(where(mm lt 10))='0'+smm
;yyyymmdd=strtrim(string(yy),2)+
data.utc=utc_start
data.jday=jd
data.latitude=lat
data.longitude=lon
data.pressure_altitude=alt/1000.	;from m to km
data.p=pres
data.co_data=co_x
data.dist=dist
data.prof_no=prof
data.doy=doy

;separate flights
dist0=where(data.dist eq 0)
dist0shifted=shift(dist0, 1)			;this is because more than one data point mau have distance=0
print, dist0					;this is because more than one data point mau have distance=0
morethanone=where(abs(dist0-dist0shifted) gt 1)	;this is because more than one data point mau have distance=0
dist0=dist0(morethanone)			;this is because more than one data point mau have distance=0
print, dist0					;this is because more than one data point mau have distance=0

nflights=n_elements(dist0)

maxpressure=max(data.P, min=minpressure)

data_backup=data

for flight=0, nflights-2 do begin
 print, flight
 goodflight_start=data(dist0(flight)).jday
 goodflight_end=  data(dist0(flight+1)-1).jday
 goodflight=where(data.jday ge goodflight_start and data.jday le goodflight_end)
 help, goodflight
 
 if n_elements(goodflight) le 1 then continue
 
 data=data_backup(goodflight)

 ;get number of profiles in this flight
 max_prof_no=max(data.prof_no)
 min_prof_no=min(data.prof_no)
 nprofiles=max_prof_no-min_prof_no+1

 ;to map profile position on map
 lalat=fltarr(nprofiles) & lalat(*)=!values.f_nan	;only good profiles will get actual values to be mapped
 lalon=fltarr(nprofiles) & lalon(*)=!values.f_nan

 rejected=intarr(nprofiles) & rejected(*)=0	;1=rejected profile

 for profile=min_prof_no, max_prof_no do begin
    ;if profile eq 0 then continue		;this because Roisisn's 10 s. file has profiles # -2, -1, 1, 2, ..., 13
    if profile eq -1 then continue		;bad profile, in my experience
    goodprofile=where(data.prof_no eq profile, counter)
    ;
    if counter le 0 then print, '***no data for profile ', data(profile).prof_no
    if counter le 0 then continue
    if counter gt 1 then begin		;0 then begin
      ;this file will have time, lat, lon, P, CO
      centralpoint=fix(counter/2)
      time=data[goodprofile(0)].utc	;using time of the begining of the profile like make_valprof_hippo.pro 
      ihour=long(time/(60.*60.))
      iminute= (time-(ihour*60.*60.))/60.
      hour=strtrim(string(ihour),2)
      if ihour lt 10 then hour='0'+hour
      minute=strtrim(string(long(iminute)),2)
      if iminute lt 10. then minute='0'+minute
      ;number of hours and minutes since the middle of the flight; hours may be > 24

      ;
      caldat, data(goodprofile(0)).jday, imm, idd, iyy
      mm=strtrim(string(imm),2)
      if imm lt 10 then mm='0'+mm
      dd=strtrim(string(idd),2)      
      if idd lt 10 then dd='0'+dd
      yy=strtrim(string(iyy),2)      

      outputfile='ATom'+'_raw_'+yy+'-'+mm+'-'+dd+'.'+hour+minute+'.asc'
      outputfile0=outputfile	;so pdf file name will not include "rejected"
      print, outputfile
      openw, 1, outputfile 
      printf, 1, inputfile
      ac_lat = Median(data(goodprofile).latitude)
      ac_lon = Median(data(goodprofile).longitude)      
      printf,1, String(ac_lat,ac_lon,format='(2f7.1," (Median lat_N,lon_E)")')
      printf,1, 'Year, JulDay, Secs, Mon, Day, Lat_N, Lon_E, Alt_m, Pres_mb, '+instrument+'_ppb'
;
      ;filter by min, max P, gaps in profile
      phigh=where(data[goodprofile].P ge maxp, phcount)	;varies with profile
      plow= where(data[goodprofile].P le minp, plcount)	;varies with profile
      ;filter CO data
      if phcount eq 0 or plcount eq 0 $			;if there is no data at all at P>=maxp or P<=minp 
      or total(data[goodprofile(phigh)].CO_data, /nan) eq 0. $	;if there is no CO data at P>=maxp
      or total(data[goodprofile(plow)].CO_data,  /nan) eq 0. $	;if there is no CO data at P<=minp
      then begin
        print, '***Incomplete '+instrument+' in ', outputfile
        ;data[goodprofile].CO_data=!values.f_nan		;fill entire profile with NaN
        spawn, 'mv '+outputfile+' '+outputfile+'_rejected'
        outputfile=outputfile+'_rejected'
        rejected(profile)=1
      endif else begin
       gap=gap_function(data[goodprofile].CO_data, data[goodprofile].P, minp, maxp, deltap)
        if gap eq 1 then begin				;if there is in CO data a gap>=deltap
          print, '***Gap in '+instrument+' in ', outputfile
          ;data[goodprofile].CO_data=!values.f_nan		;fill entire profile with NaN
          spawn, 'mv '+outputfile+' '+outputfile+'_rejected'
          outputfile=outputfile+'_rejected'
          rejected(profile)=1
        endif
      endelse
; 
      for i=0, n_elements(data[goodprofile])-1 do printf,1, format='(i6,f5.0,i7,2(i4),f8.2,f9.2,f8.0,f8.1,f10.2)', $	;,f10.2)', $
      fix(yy), data[goodprofile(i)].doy, data[goodprofile(i)].utc, fix(mm), fix(dd), data[goodprofile(i)].latitude, data[goodprofile(i)].longitude, data[goodprofile(i)].Pressure_Altitude*1000., $
      data[goodprofile(i)].P, data[goodprofile(i)].CO_data
      nodacom=where(finite(data[goodprofile].CO_data, /NaN), cnodacom)
      noco=where(finite(data[goodprofile].CO_data, /NaN), cnoco)
      sico=where(finite(data[goodprofile].CO_data, /NaN) eq 0, csico)
      close, 1
      
      if csico lt 4 then spawn, 'mv '+outputfile+' '+outputfile+'_rejected'
      if cnoco ge counter then print, '***No CO measurements in ', outputfile
      if cnoco eq cnoco then begin	;if cnoco lt counter then begin			;plot CO vs P for each profile if there are CO data
        ;minx=min(data[goodprofile].CO_data, max=maxx, /nan) & xlabel=maxx-(0.2*(maxx-minx))
        ;miny=min(data[goodprofile].P, max=maxy, /nan) & ylabel=miny+(0.1*(maxy-miny))
        device, file=outputfile+'.eps', /helvetica, /inches, ysize=11, xsize=8.5, font_size=20, /TT_FONT, /COLOR, /encapsul
        plot, data[goodprofile].CO_data, data[goodprofile].P, /nodata, title=outputfile, ystyle=9, $	;xstyle=2, ystyle=2, $
        subtitle=strtrim(string(data[goodprofile(centralpoint)].latitude),2)+', '+strtrim(string(data[goodprofile(centralpoint)].longitude),2), $
        xtitle='CO_X (ppbv)', ytitle='Pressure (hPa)', color=0, yrange=[maxpressure, minpressure], xrange=[0, 300]
        ;
        ;plot second Y axis with height
        ind_1 = where(finite(data(goodprofile).Pressure_Altitude), counter1)
        ind_2 = where(finite(data(goodprofile).P), counter2)
        index = setintersection(ind_1, ind_2)
        result=poly_fit(data(goodprofile(index)).Pressure_Altitude, data(goodprofile(index)).P, 1)
        for iz=0, 20 do plevs(iz)=result(0)+(levsptokm(iz)*result(1))
        ;axis, yaxis=1, ystyle=1, color=10, ythick=2						;re-plotting altitude axis in white  
        if total(data(goodprofile(index)).Pressure_Altitude, /nan) gt 0 then axis, yaxis=1, yticks=nyticks, ytickname=ypticks, ytickv=plevs, ytitle='Altitude (km)', charsize=1, yminor=10
	if total(data(goodprofile(index)).Pressure_Altitude, /nan) le 0 then axis, yaxis=1, yticks=nyticks, ytickname=REPLICATE(' ', nyticks+1), ytitle='Altitude Unavailable', charsize=1, yminor=10
        ;
        if strmid(outputfile, strlen(outputfile)-8, strlen(outputfile)-1) ne 'rejected' then begin
	  oplot, data[goodprofile].CO_data, data[goodprofile].P, color=6, psym=-4, symsize=0.5
        endif
        if strmid(outputfile, strlen(outputfile)-8, strlen(outputfile)-1) eq 'rejected' then begin
	  oplot, data[goodprofile].CO_data, data[goodprofile].P, color=0, psym=-4, symsize=0.5
          ;xyouts, xlabel, ylabel, 'Rejected Profile', color=9
        endif
	xyouts, !x.crange(0)+((!x.crange(1)-!x.crange(0))*0.05), !y.crange(1)-((!y.crange(1)-!y.crange(0))*0.05), 'CO_X   ', color=6, charsize=1
	;oplot, data[goodprofile].CO_UCATS, data[goodprofile].P, color=1, psym=-4, symsize=0.5
        ;xyouts, xlabel, ylabel,                    'UCATS', color=6
        device, /close
        ;spawn, 'epstopdf '+outputfile+'.eps'

        spawn, 'convert -density 300x300 -flatten '+outputfile+'.eps -resize 900x900 '+outputfile+'.png'
        ;spawn, 'rm '+outputfile+'.eps'
        lalat(profile)=data[goodprofile(centralpoint)].latitude
        lalon(profile)=data[goodprofile(centralpoint)].longitude
        print, profile, lalat(profile), lalon(profile)
      endif			;if cnoco lt counter*2
    endif			;if counter gt 0
 endfor

 badprofiles=where(rejected eq 1, counter)

 ;plot CO vs pressure
 device, file=strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_CO-P.eps', /helvetica, /inches, ysize=11, xsize=8.5, font_size=20, /TT_FONT, /COLOR, /encapsul
 plot, data.CO_data, data.P, /nodata, yrange=[maxpressure, minpressure], title=strtrim(file_basename(outputfile0),2) , xtitle='CO (ppbv)', ytitle='Pressure (hPa)', color=0, ystyle=9, xrange=[0,300]
 ;
 ;plot second Y axis with height
 ;axis, yaxis=1, ystyle=1, color=10, ythick=2						;re-plotting altitude axis in white  
 axis, yaxis=1, yticks=nyticks, ytickname=ypticks, ytickv=plevs, ytitle='Altitude (km)', charsize=1, yminor=10
 ;
 oplot, data.CO_data, data.P, color=6, psym=1, symsize=0.5
 xyouts, !x.crange(0)+((!x.crange(1)-!x.crange(0))*0.05), !y.crange(1)-((!y.crange(1)-!y.crange(0))*0.05), 'CO_X   ', color=6, charsize=1
 ;

;;;;;;;;
; if counter gt 0 then begin
;  for i=0, counter-1 do begin
;    rejectme=where(data.prof_no eq data(profilestart(badprofiles(i))).prof_no, counter2)
;    if counter2 gt 0 then oplot, data(rejectme).CO_data, data(rejectme).P, color=0, psym=1, symsize=0.5
;  endfor
; endif
;;;;;;;;

 device, /close
 ;spawn, 'epstopdf '+strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_CO-P.eps'
 spawn, 'convert -density 300x300 -flatten '+strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_CO-P.eps -resize 900x900 '+ $
 strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_CO-P.png'
 ;spawn, 'rm '+strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_CO-P.eps'

 ;plot elevation vs time
 device, file=strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_UTC-alt.eps', /helvetica, /inches, ysize=11, xsize=8.5, font_size=20, /TT_FONT, /COLOR, /encapsul

 finiteutc=finite(data.utc, /nan)
 wfiniteutc=where(finiteutc eq 0, finiteutccounter)
 finitealt=finite(data.Pressure_Altitude, /nan)
 wfinitealt=where(finitealt eq 0, finitealtcounter)
 if finiteutccounter eq 0 or finitealtcounter eq 0 then goto, jump13
 plot, data.utc, data.Pressure_Altitude, /nodata, title=strtrim(file_basename(outputfile0),2) , xtitle='UTC', ytitle='Altitude (km)', color=0

 ;highligth flat portions of the flight
 oplot, data.utc, data.Pressure_Altitude, color=6, psym=1, symsize=0.5
 blackme=where(data.prof_no lt 0)
 oplot, data(blackme).utc, data(blackme).Pressure_Altitude, color=0, psym=1, symsize=0.5
 
;;;;;;;;;;
; profilestart2=profilestart(sort(profilestart))
; for profile=0, nprofiles-1 do begin
;    if profile le 11 then psymbol=4
;    if profile gt 11 then psymbol=6
;    goodprofile=where(data.prof_no eq data(profilestart2(profile)).prof_no, counterx)
;    if counterx le 0 then continue
;    oplot, [data(goodprofile).utc], [data(goodprofile).Pressure_Altitude], color=profile, psym=psymbol
; endfor
;
; if counter gt 0 then begin
;  for i=0, counter-1 do begin
;    rejectme=where(data.prof_no eq data(profilestart(badprofiles(i))).prof_no, counter2)
;    if counter2 gt 0 then oplot, data(rejectme).utc, data(rejectme).Pressure_Altitude, color=0, psym=1, symsize=0.5
;  endfor
; endif
;;;;;;;;;;

 jump13:

 device, /close
 ;spawn, 'epstopdf '+strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_UTC-alt.eps'
 spawn, 'convert -density 300x300 -flatten '+strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_UTC-alt.eps -resize 900x900 '+ $
 strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_UTC-alt.png'
 ;spawn, 'rm '+strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_UTC-alt.eps'

 ;plot lat vs lon
 device, file=strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_lat-lon.eps', /helvetica, /inches, ysize=11, xsize=8.5, font_size=20, /TT_FONT, /COLOR, /encapsul
 plot, data.longitude, data.latitude, /nodata, title=strtrim(file_basename(outputfile0),2) , xtitle='Longitude', ytitle='Latitude', color=0
 oplot, data.longitude, data.latitude, color=6, psym=1, symsize=0.5
 device, /close
; spawn, 'epstopdf '+strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_lat-lon.eps'
 spawn, 'convert -density 300x300 -flatten '+strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_lat-lon.eps -resize 900x900 '+ $
 strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_lat-lon.png'

 ;plot profile position on map
 device, file=strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_map.eps', /helvetica, /inches, ysize=11, xsize=8.5, font_size=20, /TT_FONT, /COLOR, /encapsul
 ;map_set, /cylindrical, /noborder, /noerase, xmargin=!x.margin, ymargin=!y.margin, /clip, limit=[38, -78, 41, -75], /isotropic, title=strtrim(file_basename(outputfile0),2)+'!C' 	;for Baltimore, Washington D.C.
 ;map_continents, /usa, /hires, limit=[38, -78, 41, -75], mlinethick=2								;for Baltimore, Washington D.C.
 minlat=min(data.latitude, max=maxlat)
 minlon=min(data.longitude, max=maxlon)
 roundfactor=(maxlat-minlat)/5
 rminlat=floor(minlat)	;round(minlat/roundfactor)*roundfactor
 rmaxlat=ceil(maxlat)	;round(maxlat/roundfactor)*roundfactor
 rminlon=floor(minlon)	;round((minlon)/roundfactor)*roundfactor
 rmaxlon=ceil(maxlon)	;round((maxlon)/roundfactor)*roundfactor
 ;if rmaxlat-rminlat lt 3. then begin
 ;  rmaxlat=rmaxlat+3
 ;  rminlat=rminlat-3
 ;endif
 ;if rmaxlon-rminlon lt 3. then begin
 ;  rmaxlon=rmaxlon+3
 ;  rminlon=rminlon-3
 ;endif

 map_set, /cylindrical, /noborder, /noerase, xmargin=!x.margin, ymargin=!y.margin, /clip, limit=[rminlat, rminlon, rmaxlat, rmaxlon], /isotropic, title=strtrim(file_basename(outputfile0),2)+'!C'
 map_continents, /hires, limit=[rminlat, rminlon, rmaxlat, rmaxlon], mlinethick=2, fill_continents=1, color=11 
 map_grid, /box_axes, label=1, charsize=1, latdel=5, londel=5, glinestyle=0
 oplot, lalon, lalat, psym=4, color=6
 if counter gt 0 then oplot, lalon(badprofiles), lalat(badprofiles), psym=4, color=9
 device, /close
 ;spawn, 'epstopdf '+strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_map.eps'
 spawn, 'convert -density 300x300 -flatten '+strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_map.eps -resize 900x900 '+ $
 strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_map.png'
 ;spawn, 'rm '+strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_map.eps'

; ;map individual profiles
; device, file=strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4) +'_mapofprofiles.eps', /helvetica, /inches, ysize=11, xsize=8.5, font_size=20, /TT_FONT, /COLOR, /encapsul
; plot, data.longitude, data.latitude, xtitle='Longitude', ytitle='Latitude', /isotropic, title=strtrim(file_basename(outputfile0),2) 

; profilestart2=profilestart(sort(profilestart))
 
; for profile=0, nprofiles-1 do begin
;    if profile le 11 then psymbol=4
;    if profile gt 11 then psymbol=6
;    goodprofile=where(data.prof_no eq data(profilestart2(profile)).prof_no, counter)
;    if counter le 0 then continue
;    oplot, [data(goodprofile).longitude], [data(goodprofile).latitude], color=profile, psym=psymbol
;    xyouts, !x.crange(0)+((!x.crange(1)-!x.crange(0))*0.1), !y.crange(1)-((!y.crange(1)-!y.crange(0))*(0.05*(profile+1))), strtrim(string(profile+1),2), color=profile, charsize=1
; endfor
; device, /close
 
 ;;merge all the relevant .pdf files in the directory
 ;;spawn, 'ls -ltr -1 *.pdf', list
 ;;spawn, 'ls -l -1 '+strmid(strtrim(file_basename(outputfile0),2), 0, strlen(file_basename(outputfile0))-4)+'*.pdf', list
 
 spawn, 'ls -l -1 ATom*'+'*'+'-'+'*'+'-'+'*'+'*.eps', list		;spawn, 'ls -l -1 ATom*'+yy+'-'+mm+'-'+dd+'*.eps', list
 ifiles=n_elements(list)
 d=' '
 allfiles=' '
 for i=0, ifiles-1 do begin
  d=strsplit(list[i], /extract)
  allfiles=allfiles+d(8)+' '
 endfor

;endfor
 spawn, 'gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=output.pdf '+allfiles	;this does not work with .png files
 spawn, 'mv output.pdf '+file_basename(outputfile0)+'.pdf'

 spawn, 'rm *.eps'
 spawn, 'rm *asc*png'

 ;spawn, 'rm *txt.pdf'
 ;spawn, 'rm *rejected.pdf'
 ;spawn, 'rm *_CO-P.pdf'
 ;spawn, 'rm *_UTC-alt.pdf'
 ;;spawn, 'rm *_lat-lon.pdf'
 ;spawn, 'rm *_map.pdf'

 data=data_backup
endfor	;rf (flight) loop

end
