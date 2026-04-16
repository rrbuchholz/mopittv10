pro plot_inst_nz_timeseries

;psfile = 'plot_inst_nz_timeseries.eps'
;psfile = 'plot_inst_nz_timeseries.2014.eps'
;psfile = 'plot_inst_nz_timeseries.2000_2014.eps'

;infile = 'inst_nz_mission.dat'
;spawn, 'wc -l inst_nz_mission.dat', tmpvec
;infile = 'inst_nz_2014.v5t.dat'
;spawn, 'wc -l inst_nz_2014.v5t.dat', tmpvec

;spawn, 'cat inst_nz_2000_2010.dat inst_nz_2011.v5t.dat inst_nz_2012.v5t.dat inst_nz_2013.v5t.dat inst_nz_2014.v5t.dat > inst_nz_2000_2014.dat'
;infile = 'inst_nz_2000_2014.dat'
;spawn, 'wc -l inst_nz_2000_2014.dat', tmpvec

;psfile = 'plot_inst_nz_timeseries.whole_mission.eps'
;infile = 'inst_nz_whole_mission.v5t.new7d.dat'
;spawn, 'wc -l inst_nz_whole_mission.v5t.new7d.dat', tmpvec

;psfile = 'plot_inst_nz_5D6D7D_timeseries.whole_mission.eps'
;psfile = 'plot_inst_nz_5D6D7D_timeseries.whole_mission2.eps'
;infile = 'inst_nz_5D6D7D_whole_mission.v6.dat'
;spawn, 'wc -l inst_nz_5D6D7D_whole_mission.v6.dat', tmpvec

;psfile = 'plot_inst_nz_5D6D7D_timeseries.v7.whole_mission.eps'
;infile = 'inst_nz_5D6D7D_2000_2017.v7.dat'
;spawn, 'wc -l inst_nz_5D6D7D_2000_2017.v7.dat', tmpvec

;psfile = 'plot_inst_nz_5D6D7D_timeseries.v8.whole_mission.eps'
;infile = 'inst_nz_5D6D7D_whole_mission.v8.dat'
;spawn, 'wc -l inst_nz_5D6D7D_whole_mission.v8.dat', tmpvec

;psfile = 'plot_inst_nz_5D6D7D_timeseries.v8.2018.eps'
;infile = 'inst_nz_5D6D7D_2018.v8.dat'
;spawn, 'wc -l inst_nz_5D6D7D_2018.v8.dat', tmpvec

;psfile = 'plot_inst_nz_5D6D7D_timeseries.v8.2019.eps'
;infile = 'inst_nz_5D6D7D_2019.v8.dat'
;spawn, 'wc -l inst_nz_5D6D7D_2019.v8.dat', tmpvec

;psfile = 'plot_inst_nz_5D6D7D_timeseries.v8.2018_2019.eps'
;infile = 'inst_nz_5D6D7D_2018_2019.v8.dat'
;spawn, 'wc -l inst_nz_5D6D7D_2018_2019.v8.dat', tmpvec

;psfile = 'plot_inst_nz_5D6D7D_timeseries.v8.2018_2020.eps'
;infile = 'inst_nz_5D6D7D_2018_2020.v8.dat'
;spawn, 'wc -l inst_nz_5D6D7D_2018_2020.v8.dat', tmpvec

;psfile = 'plot_inst_nz_5D6D7D_timeseries.v8.2018_2020.eps'
;infile = 'inst_nz_5D6D7D_2018_2020.v8.dat'
;spawn, 'wc -l inst_nz_5D6D7D_2018_2020.v8.dat', tmpvec

;psfile = 'plot_inst_nz_5D6D7D_timeseries.v8.2019_2020_post_hotcal.eps'
;infile = 'inst_nz_5D6D7D_2018_2020.v8.dat'
;spawn, 'wc -l inst_nz_5D6D7D_2018_2020.v8.dat', tmpvec
;infile = 'inst_nz_5D6D7D_2019_2020.v8.dat'
;spawn, 'wc -l inst_nz_5D6D7D_2019_2020.v8.dat', tmpvec

psfile = 'plot_inst_nz_5D6D7D_timeseries.v9.whole_mission.eps'
infile = 'inst_nz_5D6D7D_whole_mission.v9.dat'
spawn, 'wc -l inst_nz_5D6D7D_whole_mission.v9.dat', tmpvec

ndates = long(tmpvec(0))
data = fltarr(15,ndates)
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
!p.multi=[0,1,3]
;!p.multi=[0,1,2]

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
;plotdates = timegen(start=julday(1,1,2000),final=julday(1,1,2018),units='Days')
;plotdates = timegen(start=julday(1,1,2000),final=julday(1,1,2020),units='Days')

;plotdates = timegen(start=julday(1,1,2019),final=julday(4,1,2019),units='Days')
;plotdates = timegen(start=julday(1,1,2018),final=julday(1,1,2019),units='Days')
;plotdates = timegen(start=julday(1,1,2018),final=julday(1,1,2020),units='Days')
;plotdates = timegen(start=julday(1,1,2019),final=julday(10,1,2019),units='Days')
;plotdates = timegen(start=julday(1,1,2019),final=julday(10,1,2019),units='Days')

;plotdates = timegen(start=julday(1,1,2018),final=julday(1,1,2021),units='Days')
;plotdates = timegen(start=julday(7,1,2019),final=julday(7,1,2020),units='Days')

plotdates = timegen(start=julday(1,1,2000),final=julday(1,1,2024),units='Days')
;nyrs = 24

nplotdates = n_elements(plotdates)
dmy_data = fltarr(nplotdates)
dmy_data(*) = 0.

; Create format strings for a two-level axis:

dummy = LABEL_DATE(DATE_FORMAT=['%M%Y'])
;dummy = LABEL_DATE(DATE_FORMAT=['%Y'])

; first plot 5A noise values
; first plot 5D noise values

;plot, plotdates, dmy_data, yrange=[0.,5.e-5], ystyle=1, ytitle='5A Inst. Noise', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = nyrs, xminor = 12, yticks=5, yminor=5, /nodata, color=1
;plot, plotdates, dmy_data, yrange=[0.,3.e-5], ystyle=1, ytitle='5D Inst. Noise', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = nyrs, xminor = 12, yticks=3, yminor=5, /nodata, color=1
plot, plotdates, dmy_data, yrange=[0.,3.e-5], xstyle=1, ystyle=1, ytitle='5D Inst. Noise (W / m!U2!N Sr)', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = 6, xminor = 4, yticks=3, yminor=5, /nodata, color=1, xmargin=[12,5]
;plot, plotdates, dmy_data, yrange=[0.,5.e-5], ystyle=1, ytitle='5A Inst. Noise', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = 12, yticks=5, yminor=5, /nodata

for ipx = 0, 3 do begin
  oplot, jdates, reform(data(ipx+3,*)), color=colortab(ipx)
endfor

; second plot 5D noise values
; second plot 6D noise values

;plot, plotdates, dmy_data, yrange=[0.,5.e-5], ystyle=1, ytitle='5D Inst. Noise', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = nyrs, xminor = 12, yticks=5, yminor=5, /nodata, color=1
;plot, plotdates, dmy_data, yrange=[0.,2.e-6], ystyle=1, ytitle='6D Inst. Noise', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = nyrs, xminor = 12, yticks=4, yminor=5, /nodata, color=1
plot, plotdates, dmy_data, yrange=[0.,2.e-6], xstyle=1, ystyle=1, ytitle='6D Inst. Noise (W / m!U2!N Sr)', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = 6, xminor = 4, yticks=4, yminor=5, /nodata, color=1, xmargin=[12,5]
;plot, plotdates, dmy_data, yrange=[0.,5.e-5], ystyle=1, ytitle='5D Inst. Noise', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = 12, yticks=5, yminor=5, /nodata

for ipx = 0, 3 do begin
  oplot, jdates, reform(data(ipx+7,*)), color=colortab(ipx)
endfor

; third plot 7D noise values

;plot, plotdates, dmy_data, yrange=[0.,1.e-4], ystyle=1, ytitle='7D Inst. Noise', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = nyrs, xminor = 12, yticks=5, yminor=5, /nodata, color=1
plot, plotdates, dmy_data, yrange=[0.,1.e-4], xstyle=1, ystyle=1, ytitle='7D Inst. Noise (W / m!U2!N Sr)', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = 6, xminor = 4, yticks=5, yminor=5, /nodata, color=1, xmargin=[12,5]
;plot, plotdates, dmy_data, yrange=[0.,1.e-4], ystyle=1, ytitle='7D Inst. Noise', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = 12, yticks=5, yminor=5, /nodata

for ipx = 0, 3 do begin
  oplot, jdates, reform(data(ipx+11,*)), color=colortab(ipx)
endfor

; add labels

xverts = 0.16 + [-0.03, -0.03, 0.03, 0.03]
yverts = 0.93 + [0.02,-0.02,-0.02, 0.02]

polyfill, xverts, yverts, /norm, color=0
plots, [xverts(0:3),xverts(0)], [yverts(0:3),yverts(0)], /norm, color=1

;xyouts, .14, .92, /norm, charsize=1.5, '5A', color=1
xyouts, .14, .92, /norm, charsize=1.5, '5D', color=1

xverts = 0.16 + [-0.03, -0.03, 0.03, 0.03]
yverts = 0.59667 + [0.02,-0.02,-0.02, 0.02]

polyfill, xverts, yverts, /norm, color=0
plots, [xverts(0:3),xverts(0)], [yverts(0:3),yverts(0)], /norm, color=1

;xyouts, .14, .58667, /norm, charsize=1.5, '5D', color=1
xyouts, .14, .58667, /norm, charsize=1.5, '6D', color=1

xverts = 0.16 + [-0.03, -0.03, 0.03, 0.03]
yverts = 0.26333 + [0.02,-0.02,-0.02, 0.02]

polyfill, xverts, yverts, /norm, color=0
plots, [xverts(0:3),xverts(0)], [yverts(0:3),yverts(0)], /norm, color=1

xyouts, .14, .25333, /norm, charsize=1.5, '7D', color=1


; add legend

xverts = 0.84 + [-0.06,-0.06, 0.06, 0.06]
yverts = 0.883 + [0.065,-0.065,-0.065, 0.065]

polyfill, xverts, yverts, /norm, color=0

plots, [xverts(0:3),xverts(0)], [yverts(0:3),yverts(0)], /norm, color=1

xyouts, .8, .92, /norm, charsize=1.2, color=colortab(0), 'Pixel 1'
xyouts, .8, .89, /norm, charsize=1.2, color=colortab(1), 'Pixel 2'
xyouts, .8, .86, /norm, charsize=1.2, color=colortab(2), 'Pixel 3'
xyouts, .8, .83, /norm, charsize=1.2, color=colortab(3), 'Pixel 4'

if (out ne 'x') then device, /close


return
end
