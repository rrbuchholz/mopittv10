pro plot_mn_dfs_colm_pxl_timeseries

; plot timeseries of daily-mean DFS and total column

;psfile = 'plot_mn_dfs_pxl_timeseries.2000_2014.v6t.eps'
;infile = 'xtract_mn_dfs_pxl.whole_mission.v6t.dat'
;scene_lbl = 'V6T, Ocean scenes, 60S:60N'
;spawn, 'wc -l xtract_mn_dfs_pxl.whole_mission.v6t.dat', tmpvec

;psfile = 'plot_mn_dfs_colm_pxl_timeseries.2000_2014.v6t.eps'
;psfile = 'plot_mn_dfs_colm_pxl_timeseries.2000_2014.v6t.ps'
;infile = 'xtract_mn_dfs_colm_pxl.whole_mission.v6t.dat'
;scene_lbl = 'V6T, Ocean scenes, 60S:60N'
;spawn, 'wc -l xtract_mn_dfs_colm_pxl.whole_mission.v6t.dat', tmpvec

;psfile = 'plot_mn_dfs_colm_pxl_timeseries.2000_2016.v7t.ps'
;infile = 'xtract_mn_dfs_colm_pxl.whole_mission.v7t.dat'
;spawn, 'wc -l xtract_mn_dfs_colm_pxl.whole_mission.v7t.dat', tmpvec

;psfile = 'plot_mn_dfs_colm_pxl_timeseries.2000_2018.v8t.eps'
;infile = 'xtract_mn_dfs_colm_pxl.whole_mission.v8t.dat'
;spawn, 'wc -l xtract_mn_dfs_colm_pxl.whole_mission.v8t.dat', tmpvec

psfile = 'plot_mn_dfs_colm_pxl_timeseries.2000_2020.v8t.eps'
infile = 'xtract_mn_dfs_colm_pxl.whole_mission.v8t.dat'
spawn, 'wc -l xtract_mn_dfs_colm_pxl.whole_mission.v8t.dat', tmpvec

ndates = long(tmpvec(0))
;data = fltarr(7,ndates)
;data = fltarr(15,ndates)
data = fltarr(27,ndates)
openr, 1, infile
readf, 1, data
close, 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!p.font = 0
!p.charsize=1.5
!p.symsize=0.1
!p.thick = 3.
!x.thick = 3.
!y.thick = 3.
;!p.multi=[0,1,4]
!p.multi=[0,1,2]
;!p.multi=[0,1,3]

;out = 'ps'
out = 'eps'

if (out eq 'ps') then begin
  set_plot, 'ps'
;  device, filename=psfile, /portrait, $
;       /inches, ysize=8.0, xsize=7.0, yoffset=1.0, xoffset=0.5
  device, filename=psfile, /portrait, /helvetica, /color, $
        /inches, ysize=9.5, xsize=7.5, yoffset=0., xoffset=0.7
endif
;
if (out eq 'eps') then begin
  set_plot, 'ps'
;  device, filename=psfile, /portrait, /encapsulated, $
;       /inches, ysize=7.0, xsize=4.5
  device, filename=psfile, /portrait, /encapsulated, /helvetica, /color, $
        /inches, ysize=9.5, xsize=7.5
endif

;loadct, 39
myct, 39, ncolors = 200
; colors 0-17 are reserved
colmin=25
colmax=216

;colortab=[25,50,150,250]
colortab=[30,60,140,210]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

yr = round(reform(data(0,*)))
mo = round(reform(data(1,*)))
dy = round(reform(data(2,*)))

jdates = fltarr(ndates)

for idy = 0, ndates-1 do begin
  jdates(idy) = julday(mo(idy),dy(idy),yr(idy))
endfor

;plotdates = timegen(start=julday(1,1,2000),final=julday(6,1,2011),units='Days')
;plotdates = timegen(start=julday(1,1,2014),final=julday(1,1,2015),units='Days')
;plotdates = timegen(start=julday(1,1,2000),final=julday(1,1,2015),units='Days')
;plotdates = timegen(start=julday(1,1,2000),final=julday(1,1,2017),units='Days')
plotdates = timegen(start=julday(1,1,2000),final=julday(1,1,2020),units='Days')

; number of labeled ticks on time axis
nyrs = 4
nyrsminor = 5*4

nplotdates = n_elements(plotdates)
dmy_data = fltarr(nplotdates)
dmy_data(*) = 0.

; Create format strings for a two-level axis:

;dummy = LABEL_DATE(DATE_FORMAT=['%M%Y'])
dummy = LABEL_DATE(DATE_FORMAT=['%Y'])

; plot daily mean DFS values (global)

;plot, plotdates, dmy_data, yrange=[0.5,1.5], ystyle=1, ytitle='DFS (Daily Mean)', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = nyrs, xminor = 12, yticks=2, yminor=5, /nodata, color=1

;for ipx = 0, 3 do begin
;  oplot, jdates, reform(data(ipx+3,*)), color=colortab(ipx)
;endfor

; add labels

;xverts = 0.16 + [-0.03, -0.03, 0.03, 0.03]
;yverts = 0.95 + [0.02,-0.02,-0.02, 0.02]

;polyfill, xverts, yverts, /norm, color=0
;plots, [xverts(0:3),xverts(0)], [yverts(0:3),yverts(0)], /norm, color=1

;xyouts, .14, .94, /norm, charsize=1.5, '5A', color=1

; add legend

;xverts = 0.84 + [-0.06,-0.06, 0.06, 0.06]
;yverts = 0.893 + [0.065,-0.065,-0.065, 0.065]

;polyfill, xverts, yverts, /norm, color=0

;plots, [xverts(0:3),xverts(0)], [yverts(0:3),yverts(0)], /norm, color=1

;xyouts, .8, .93, /norm, charsize=1.2, color=colortab(0), 'Pixel 1'
;xyouts, .8, .90, /norm, charsize=1.2, color=colortab(1), 'Pixel 2'
;xyouts, .8, .87, /norm, charsize=1.2, color=colortab(2), 'Pixel 3'
;xyouts, .8, .84, /norm, charsize=1.2, color=colortab(3), 'Pixel 4'

;xyouts, .4, .94, /norm, charsize=1.2, color=colortab(0), 'Pixel 1'
;xyouts, .55, .94, /norm, charsize=1.2, color=colortab(1), 'Pixel 2'
;xyouts, .7, .94, /norm, charsize=1.2, color=colortab(2), 'Pixel 3'
;xyouts, .85, .94, /norm, charsize=1.2, color=colortab(3), 'Pixel 4'

;xyouts, .13, .7333, /norm, charsize=1.2, color=1, 'V6T, Ocean scenes, Global'

; plot daily mean DFS values (60S:60N)

plot, plotdates, dmy_data, yrange=[0.5,1.5], ystyle=1, ytitle='DFS (Daily Mean)', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = nyrs, xminor = nyrsminor, yticks=2, yminor=5, /nodata, color=1

for ipx = 0, 3 do begin
  oplot, jdates, reform(data(ipx+7,*)), color=colortab(ipx)
endfor

dfs_mn = (reform(data(7,*)) + reform(data(8,*)) + reform(data(9,*)) + reform(data(10,*)))/4.
oplot, jdates, dfs_mn, color=13


xyouts, .22, .61, /norm, charsize=1.2, color=colortab(0), 'Pixel 1'
xyouts, .36, .61, /norm, charsize=1.2, color=colortab(1), 'Pixel 2'
xyouts, .50, .61, /norm, charsize=1.2, color=colortab(2), 'Pixel 3'
xyouts, .64, .61, /norm, charsize=1.2, color=colortab(3), 'Pixel 4'
xyouts, .77, .61, /norm, charsize=1.2, color=13, 'Mean'

;xyouts, .22, .65, /norm, charsize=1.2, color=1, 'V7T, Ocean scenes, 60S:60N'
xyouts, .22, .65, /norm, charsize=1.2, color=1, 'V8T, Ocean scenes, 60S:60N'

; plot daily mean DFS values (30S:30N)

;plot, plotdates, dmy_data, yrange=[0.5,1.5], ystyle=1, ytitle='DFS (Daily Mean)', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = nyrs, xminor = 12, yticks=2, yminor=5, /nodata, color=1

;for ipx = 0, 3 do begin
;  oplot, jdates, reform(data(ipx+11,*)), color=colortab(ipx)
;endfor

;xyouts, .13, .0667, /norm, charsize=1.2, color=1, 'V6T, Ocean scenes, 30S:30N'

;;;;;;;;;;;;;;;;;; now plot CO total column ;;;;;;;;;;;;;;;;;;

plot, plotdates, dmy_data, yrange=[1.e18,2.e18], ystyle=1, ytitle='CO Total Column (Daily Mean)', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = nyrs, xminor = nyrsminor, yticks=2, yminor=5, /nodata, color=1

for ipx = 0, 3 do begin
  oplot, jdates, reform(data(ipx+19,*)), color=colortab(ipx)
endfor

; next page: Tropics

; plot daily mean DFS values (30S:30N)

plot, plotdates, dmy_data, yrange=[0.5,1.5], ystyle=1, ytitle='DFS (Daily Mean)', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = nyrs, xminor = nyrsminor, yticks=2, yminor=5, /nodata, color=1

for ipx = 0, 3 do begin
  oplot, jdates, reform(data(ipx+11,*)), color=colortab(ipx)
endfor

dfs_mn = (reform(data(11,*)) + reform(data(12,*)) + reform(data(13,*)) + reform(data(14,*)))/4.
oplot, jdates, dfs_mn, color=13

xyouts, .22, .61, /norm, charsize=1.2, color=colortab(0), 'Pixel 1'
xyouts, .36, .61, /norm, charsize=1.2, color=colortab(1), 'Pixel 2'
xyouts, .50, .61, /norm, charsize=1.2, color=colortab(2), 'Pixel 3'
xyouts, .64, .61, /norm, charsize=1.2, color=colortab(3), 'Pixel 4'
xyouts, .77, .61, /norm, charsize=1.2, color=13, 'Mean'

;xyouts, .22, .65, /norm, charsize=1.2, color=1, 'V7T, Ocean scenes, 30S:30N'
xyouts, .22, .65, /norm, charsize=1.2, color=1, 'V8T, Ocean scenes, 30S:30N'

;;;;;;;;;;;;;;;;;; now plot CO total column ;;;;;;;;;;;;;;;;;;

plot, plotdates, dmy_data, yrange=[1.e18,2.e18], ystyle=1, ytitle='CO Total Column (Daily Mean)', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = nyrs, xminor = nyrsminor, yticks=2, yminor=5, /nodata, color=1

for ipx = 0, 3 do begin
  oplot, jdates, reform(data(ipx+23,*)), color=colortab(ipx)
endfor



if (out ne 'x') then device, /close


return
end
