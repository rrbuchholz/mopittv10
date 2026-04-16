;Sara Martinez-Alonso 04.2011, 8.2011, 9.2012, 7.2014
;
;hippo_reader_1-5_1s_with_filtering_for_20121129.pro
;
;'NA' values in original hippo file are replaced with 'NaN' 
;some tag names originally included '.' which are replaced with '_'
;two tag names = 'UIC'; the second one is renamed 'UIC2'
;two tag names = 'VIC'; the second one is renamed 'VIC2' 
;
;rejecting profiles lacking measurements at P>=maxp and/or P<=minp hPa
;as well as profiles with gaps over >=deltap hPa
;
;producing .txt file for each accepted profile with:
; PSXC(mb), static pressure corrected for airflow effects
; CO_QCLS (ppbv)
; CO_RAF (ppbv) 
;
;the name of the output files (site_YYYYMMDD.hhmm.txt) have 
;the date of the beginning of the profile (which is the same for the entire profile), 
;for consistency with make_valprof_hippo.pro they have 
;the time of the beginning of the profile, 
;also for consistency with make_valprof_hippo.pro the plots show
;the coordinates of the central point of the profile, (but not a mean)
;
;producing also a plot per profile (P vs CO) and a map with the location
;of all the profiles
;
;sema 09.2012: code modified to accomodate the format of HIPPO-1..HIPPO-5 released on 
;08.27.2012 ("alpha version of RELEASE").
;
;sema 07.2014: code modified to accomodate the format of HIPPO-1..HIPPO-5 released on 
;11.29.2012.


@gap_fill_function
@gap_function

;inputfile='/home/sma/HIPPO/HIPPO_1_merge.tbl'
inputfile=' '
read, inputfile, prompt='Input filename (e.g., HIPPO_x_merge_20120827.tbl): '

spawn, 'wc -l '+inputfile, d
id=strsplit(d,/extract)
ilines=long(id(0))

;*****************Criteria used to filter the data*******************************
minp=400.
maxp=800.
deltap=200.
;********************************************************************************

;Year flt DOY UTC AKRD SSRD ATX DPXC PLWCC GGALT GGLAT GGLON GGSPD GGTRK UIC VIC WIC MR PALT PALTF PCAB_SP2 PITCH PSXC QCXC RHUM RICE ROLL TASX TCAB THETA THETAE THETAV TTX UXC XMACH2 CONC1DC_LWO CONC2C_LWO DBAR1DC_LWO CONCD_LWI 
;DBARD_LWI CONCU_RWI CONCU100_RWI CONCU500_RWI CO2_AO2 O2_AO2 APO_AO2 CH4_QCLS N2O_QCLS CO_QCLS CO2_OMS CO2_QCLS CO_RAF O3_ppb BC_ng_kg BC_ng_m3 N2O_UGC N2Oe_UGC SF6_UGC SF6e_UGC CH4_UGC CH4e_UGC H2_UGC H2e_UGC CO_UGC COe_UGC H2O_UWV 
;H2Oe_UWV O3_UO3 O3e_UO3 H2Oppmv_vxl N2O_P N2Oe_P SF6_P SF6e_P CFC_11_P CFC_11e_P CFC_12_P CFC_12e_P CFC_113_P CFC_113e_P Halon_1211_P Halon_1211e_P H2_P H2e_P CH4_P CH4e_P CO_P COe_P PAN_P PANe_P UTSTART_CCG UTSTOP_CCG CO2_CCG 
;CH4_CCG CO_CCG H2_CCG N2O_CCG SF6_CCG CO2isoC13_SIL CO2isoO18_SIL CH4isoC13_SIL n.prof Dist


template={year:0, flt:0l, DOY:0l, UTC:0l, AKRD:0.0d, SSRD:0.0d, ATX:0.0d, DPXC:0.0d, PLWCC:0.0d, GGALT:0.0d, GGLAT:0.0d, $
GGLON:0.0d, GGSPD:0.0d, GGTRK:0.0d, UIC:0.0d, VIC:0.0d, WIC:0.0d, MR:0.0d, PALT:0.0d, PALTF:0.0d, PCAB_SP2:0.0d, pitch:0.0d, $
PSXC:0.0d, QCXC:0.0d, RHUM:0.0d, RICE:0.0d, ROLL:0.0d, TASX:0.0d, TCAB:0.0d, $
THETA:0.0d, THETAE:0.0d, THETAV:0.0d, TTX:0.0d, UXC:0.0d, XMACH2:0.0d, CONC1DC_LWO:0.0d, CONC2C_LWO:0.0d, DBAR1DC_LWO:0.0d, CONCD_LWI:0.0d, $
DBARD_LWI:0.0d, CONCU_RWI:0.0d, CONCU100_RWI:0.0d, CONCU500_RWI:0.0d, CO2_AO2:0.0d, O2_AO2:0.0d, APO_AO2:0.0d, $
CH4_QCLS:0.0d, N2O_QCLS:0.0d, CO_QCLS:0.0d, CO2_OMS:0.0d, CO2_QCLS:0.0d, CO_RAF:0.0d, O3_ppb:0.0d, BC_ng_kg:0.0d, BC_ng_m3:0.0d, N2O_UGC:0.0d, $
N2Oe_UGC:0.0d, SF6_UGC:0.0d, SF6e_UGC:0.0d, CH4_UGC:0.0d, CH4e_UGC:0.0d, H2_UGC:0.0d, H2e_UGC:0.0d, CO_UGC:0.0d, COe_UGC:0.0d, H2O_UWV:0.0d, $
H2Oe_UWV:0.0d, O3_UO3:0.0d, O3e_UO3:0.0d, H2Oppmv_vxl:0.0d, N2O_P:0.0d, N2Oe_P:0.0d, SF6_P:0.0d, SF6e_P:0.0d, $
CFC_11_P:0.0d, CFC_11e_P:0.0d, CFC_12_P:0.0d, CFC_12e_P:0.0d, CFC_113_P:0.0d, CFC_113e_P:0.0d, Halon_1211_P:0.0d, Halon_1211e_P:0.0d, H2_P:0.0d, H2e_P:0.0d, $
CH4_P:0.0d, CH4e_P:0.0d, CO_P:0.0d, COe_P:0.0d, PAN_P:0.0d, PANe_P:0.0d, UTSTART_CCG:0.0d, UTSTOP_CCG:0.0d, CO2_CCG:0.0d, CH4_CCG:0.0d, $
CO_CCG:0.0d, H2_CCG:0.0d, N2O_CCG:0.0d, SF6_CCG:0.0d, CO2isoC13_SIL:0.0d, CO2isoO18_SIL:0.0d, CH4isoC13_SIL:0.0d, n_prof:0l, Dist:0.0d}

;the original "n.prof" has been changed to "n_prof" to avoid similarity with IDL structure naming format
;originally there were two "PLWCC" which here are renamed "PLWCC1" and "PLWCC2"
;"WIC", "Cabin_pressure_torris", "CONC1DC_LWO", "CONC2C_LWO", "DBAR1DC_LWO", "DBARD_LWI", "CONC1DC_LCO", "CONC2C_LCO", "CONCD_LOI",
;"Pressure_vxl", ;"CO2isoC13_SIL", ;"CO2isoO18_SIL", "CH4isoC13_SIL" always are "NA" so I do not really know if they are 0.0d or what

data=replicate(template, ilines-1)

;replicate input file changing "NA" into "NaN" 
inputfile2=strmid(file_basename(inputfile), 0, strlen(file_basename(inputfile))-4)+'_NA-to-NaN.tbl'
header=' '
openr, 1, inputfile
openw, 2, inputfile2
readf, 1, header
header2=strsplit(header, /extract)

kk=where(header2 eq 'n.prof')
header2(kk)='n_prof'
kk=where(header2 eq 'PLWCC')
;header2(kk(1))='PLWCC2'

printf, 2, format='(109(a,x))', header2
line=' '
for i=0, ilines-2 do begin			;skip header
 readf, 1, line
 line2=strsplit(line, /extract)
 line2(where(line2 eq 'NA'))='NaN'		;!values.f_nan
 printf, 2, format='(109(a,x))', line2
endfor
close, 1
close, 2

;read input file
openr, 2, inputfile2
header2=' '
readf, 2, header2
readf, 2, data
close, 2

;set printing environment
;!p.multi=[0,1,5,0,1]
!x.omargin=[2,2]
!y.omargin=[2,2]
red = fltarr(6)
green = fltarr(6)
blue = fltarr(6)
; for color (black, red, green, purp, cyan, orange)
red   =       [0.,  1.,  0.,    0.5,   0.,  1.]
green =       [0.,  0.,  0.5,   0.,    1.,  0.5]
blue  =       [0.,  0.,  0.,    1.,    1.,  0.]
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

;;plot CH4 vs GPS latitude
;device, file='hippo_ch4.eps', /helvetica, /inches, xsize=11, ysize=8.5, font_size=20, /TT_FONT, /COLOR, /encapsul
;plot, data.gglat, data.CH4_QCLS, title=strtrim(file_basename(inputfile),2) , xtitle='Latitude', ytitle='CH!B4!N (ppbv)', color=0, psym=-3
;oplot, data.gglat, data.CH4_UGC, color=1, psym=1, symsize=0.5
;oplot, data.gglat, data.CH4_P, color=2, psym=1, symsize=0.5
;xyouts, -63, 1990, 'QCLS', color=0
;xyouts, -63, 1970, 'UCATS', color=1
;xyouts, -63, 1950, 'PANTHER ECD', color=2 
;device, /close
;spawn, 'epstopdf hippo_ch4.eps'

;;plot CO vs GPS latitude
;device, file='hippo_co.eps', /helvetica, /inches, xsize=11, ysize=8.5, font_size=20, /TT_FONT, /COLOR, /encapsul
;plot, data.gglat, data.CO_QCLS, title=strtrim(file_basename(inputfile),2) , xtitle='Latitude', ytitle='CO (ppbv)', color=0, psym=-3
;oplot, data.gglat, data.CO_RAF, color=5, psym=-3, symsize=0.5
;oplot, data.gglat, data.CO_P, color=2, psym=1, symsize=0.5
;xyouts, -63, 185, 'QCLS', color=0
;xyouts, -63, 175, 'RAF VUV', color=3
;xyouts, -63, 165, 'PANTHER ECD', color=2 
;device, /close
;spawn, 'epstopdf hippo_co.eps'

if (strmid(file_basename(inputfile),6,1) eq '1' or strmid(file_basename(inputfile),6,1) eq '2') then iYYYY=2009
if (strmid(file_basename(inputfile),6,1) eq '3') then iYYYY=2010
if (strmid(file_basename(inputfile),6,1) eq '4' or strmid(file_basename(inputfile),6,1) eq '5') then iYYYY=2011

;separate file into profiles
;file contains several flights (data.flt) which themselves contain profiles (data.n_prof)
;data.n_prof=0 indicate flat (in elevation) profiles
minflt=min(data.flt, max=maxflt, /NaN)
minprof=min(data.n_prof, max=maxprof, /NaN)

;to map profile position on map
lalat=fltarr(maxprof) & lalat(*)=!values.f_nan	;only good profiles will get actual values to be mapped
lalon=fltarr(maxprof) & lalon(*)=!values.f_nan	

for profile=1, maxprof do begin
    nada=where(data.n_prof eq profile, counter)
    if counter le 0 then print, '***no data for profile ', profile
    if counter gt 0 then begin
      flight=data[nada(0)].flt
;this file will have all the info in the original
      outputfile=strmid(file_basename(inputfile2), 0, strlen(file_basename(inputfile2))-4)+ $
      '_flt#'+strtrim(string(flight),2)+'_prof#'+strtrim(string(profile),2)+'.tbl'
      ;print, outputfile
      openw, 1, outputfile
      printf, 1, header
      for i=0, n_elements(data[nada])-1 do printf, 1, format='(3(i0,x),104(d0,x),(i0,x),(d0,x))', data[nada(i)]
      close, 1
;this file will have time, lat, lon, P, CO from QCLS, and CO from RAF
      centralpoint=fix(counter/2)
      jday=julday(1,1,iyyyy)
      caldat, jday-1+data[nada(0)].doy, im, id, iy	;this is to get month, day, and year of the begining of the profile
      mm=strtrim(string(im),2) & dd=strtrim(string(id),2) & yy=strtrim(string(iy),2)
      if im lt 10 then mm='0'+mm
      if id lt 10 then dd='0'+dd
      time=data[nada(0)].utc	;using time of the begining of the profile like make_valprof_hippo.pro 
      ihour=long(time/(60.*60.))
      iminute= (time-(ihour*60.*60.))/60.
      hour=strtrim(string(ihour),2)
      if ihour lt 10 then hour='0'+hour
      minute=strtrim(string(long(iminute)),2)
      if iminute lt 10. then minute='0'+minute
;number of hours and minutes since the middle of the flight; hours may be > 24
      outputfile='hippo'+string(strmid(file_basename(inputfile),6,1))+'_'+yy+mm+dd+'.'+hour+minute+'.txt'
      print, outputfile
      openw, 1, outputfile 
      printf, 1, 'UTC          lat        lon         PSXC       CO_QCLS      CO_RAF      
      printf, 1, 'seconds      degrees    degrees     hPa        ppbv         ppbv
      printf, 1, '-----------------------------------------------------------------------------'   
      phigh=where(data[nada].psxc ge maxp, phcount)	;varies with profile
      plow= where(data[nada].psxc le minp, plcount)	;varies with profile
;filter QCLS data
      if phcount eq 0 or plcount eq 0 $			;if there is no data at all at P>=maxp or P<=minp 
      or total(data[nada(phigh)].co_qcls, /nan) eq 0. $	;if there is no CO data at P>=maxp
      or total(data[nada(plow)].co_qcls,  /nan) eq 0. $ ;if there is no CO data at P<=minp
      then begin
        print, '***Incomplete CO_QCLS in ', outputfile
        data[nada].co_qcls=!values.f_nan		;fill entire profile with NaN
        outputfile=outputfile+'_rejected'
      endif else begin
        gap=gap_function(data[nada].co_qcls, data[nada].psxc, minp, maxp, deltap)
        if gap eq 1 then begin				;if there is in CO data a gap>=deltap
          print, '***Gap in CO_QCLS in ', outputfile
          data[nada].co_qcls=!values.f_nan		;fill entire profile with NaN
          outputfile=outputfile+'_rejected'
        endif
      endelse
;filter RAF data
      if phcount eq 0 or plcount eq 0 $			;if there is no data at all at P>=maxp or P<=minp 
      or total(data[nada(phigh)].co_raf, /nan) eq 0. $	;if there is no CO data at P>=maxp
      or total(data[nada(plow)].co_raf,  /nan) eq 0. $	;if there is no CO data at P<=minp
      then begin
        print, '***Incomplete CO_RAF in ', outputfile
        data[nada].co_raf=!values.f_nan			;fill entire profile with NaN
        outputfile=outputfile+'_rejected'
      endif else begin
        gap=gap_function(data[nada].co_raf, data[nada].psxc, minp, maxp, deltap)
        if gap eq 1 then begin				;if there is in CO data a gap>=deltap
          print, '***Gap in CO_RAF in ', outputfile
          data[nada].co_raf=!values.f_nan		;fill entire profile with NaN
          outputfile=outputfile+'_rejected'
        endif
      endelse
; 
;the original
;     for i=0, n_elements(data[nada])-1 do printf, 1, format='(6(f0,x))', data[nada(i)].utc, data[nada(i)].gglat, $
;     data[nada(i)].gglon, data[nada(i)].PSXC, data[nada(i)].CO_QCLS, data[nada(i)].CO_RAF
;and this is not to write CO_RAF
      for i=0, n_elements(data[nada])-1 do printf, 1, format='(5(f0,x))', data[nada(i)].utc, data[nada(i)].gglat, $
      data[nada(i)].gglon, data[nada(i)].PSXC, data[nada(i)].CO_QCLS
;
      noqcls=where(finite(data[nada].CO_QCLS, /NaN), cnoqcls)
      noraf= where(finite(data[nada].CO_RAF,  /NaN), cnoraf)
      alldata=[data[nada].CO_QCLS, data[nada].CO_RAF]
      noco=where(finite(alldata, /NaN), cnoco)
      close, 1
      if cnoco ge counter*2 then print, '***No CO measurements in ', outputfile
      if cnoco lt counter*2 then begin			;plot CO vs P for each profile if there are CO data
        allpsxc=[data[nada].PSXC, data[nada].PSXC]        
        minx=min(alldata, max=maxx, /nan) & xlabel=minx+(0.1*(maxx-minx))
        miny=min(allpsxc, max=maxy, /nan) & ylabel=maxy-(0.1*(maxy-miny))
        device, file=outputfile+'.eps', /helvetica, /inches, xsize=11, ysize=8.5, font_size=20, /TT_FONT, /COLOR, /encapsul
        if counter*2 gt cnoco then plot, alldata, allpsxc, title=outputfile, $	;xstyle=2, ystyle=2, $
        subtitle=strtrim(string(data[nada(centralpoint)].gglat),2)+', '+strtrim(string(data[nada(centralpoint)].gglon),2), $
        xtitle='CO (ppbv)', ytitle='PSXC (hPa)', color=0, psym=3		;, yrange=[1060., 100.]
        if counter gt cnoqcls then oplot, data[nada].CO_QCLS, data[nada].PSXC, color=5, psym=-3, symsize=0.5
        if counter gt cnoraf  then oplot, data[nada].CO_RAF,  data[nada].PSXC, color=2, psym=-3, symsize=0.5
        xyouts, xlabel, ylabel,                    'QCLS', color=5
        xyouts, xlabel, ylabel-(0.05*(maxy-miny)), 'RAF',  color=2
        device, /close
        spawn, 'epstopdf '+outputfile+'.eps'
;        lalat(profile)=data[nada(centralpoint)].gglat
;        lalon(profile)=data[nada(centralpoint)].gglon
;print, profile, lalat(profile), lalon(profile)
        lalat(profile-1)=data[nada(centralpoint)].gglat
        lalon(profile-1)=data[nada(centralpoint)].gglon
print, profile, lalat(profile-1), lalon(profile-1)
      endif			;if cnoco lt counter*2
    endif			;if counter gt 0
endfor
;merge all the .pdf files in the directory
;spawn, 'ls -ltr -1 *.pdf', list
spawn, 'ls -l -1 *.pdf', list
ifiles=n_elements(list)
d=' '
allfiles=' '
for i=0, ifiles-1 do begin
  d=strsplit(list[i], /extract)
  allfiles=allfiles+d(8)+' '
endfor
spawn, 'gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=output.pdf '+allfiles
spawn, 'mv output.pdf '+file_basename(inputfile)+'.pdf'

;plot profile position on map
device, file=file_basename(inputfile)+'_map.eps', /helvetica, /inches, xsize=11, ysize=7, font_size=20, /TT_FONT, /COLOR, /encapsul
map_set, /cylindrical, /noborder, /noerase, xmargin=!x.margin, ymargin=!y.margin, /clip, limit=[-90, -180, 90, 180]
map_continents, /continents, /hires, limit=[-90, -180, 90, 180], mlinethick=2
map_grid, /box_axes, label=1, charsize=1, latdel=30, londel=30, glinestyle=0
oplot, lalon, lalat, psym=4, color=1
device, /close
spawn, 'epstopdf '+file_basename(inputfile)+'_map.eps'
spawn, 'rm *.eps'
spawn, 'rm *txt.pdf'
spawn, 'rm *rejected.pdf'
set_plot, 'x'

end
