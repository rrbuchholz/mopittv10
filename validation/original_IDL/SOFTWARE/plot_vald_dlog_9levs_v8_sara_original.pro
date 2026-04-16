pro plot_vald_dlog_9levs_v8_sara

; adapted to read output of val_L2_v9_hippo.pro
  
; cleaned-up scatterplot code 2/1/18, plots 9 levels plus total column  

; generates validation scatterplots of (x_rtv - x_a)

;ngd_min = 10
;ngd_min = 12
;ngd_min = 15
ngd_min = 5
;ngd_min = 3
;ngd_min = 2

log10e = alog10(exp(1.))

; new complete list of NOAA sites (as of Nov., 2016)
;sitecodes = ['aao','bne','car','cma','crv','dnd','esp','etl','haa','hfm','hil','lef','nha','pfa','rta','sca','sgp','tgc','thd','wbi','wgc']
;site_colors =
;[120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120]

sitecodes = ['sgp']

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

nsites = n_elements(sitecodes)
site_colors = make_array(nsites, /integer, value=120)

;;;;;;;;;;;;;;;;;;;;; V8 OPS ;;;;;;;;;;;;;;;;;

; TIR-only, no cloud filtering

psfile = 'plot_vald_dlog_9levs.v8t_ops_sara_test.noaa.eps'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; plot 9 levels plus total column

ilev_plot = [8,7,6,5,4,3,2,1,0,-1]

lvl_lbl = ['200 hPa','300 hPa','400 hPa','500 hPa','600 hPa','700 hPa','800 hPa','900 hPa','Surface','Column']

plottitle=''

nlevs = n_elements(ilev_plot)

;out = 'ps'
out = 'eps'
;

!p.font = 0
!p.multi = [0,2,5]

!p.charsize= 1.3
!p.symsize = .8
!p.thick = 3.0
!x.thick = 3.0
!y.thick = 3.0

if (out eq 'ps') then begin
  set_plot, 'ps'
;  device, filename=psfile, /portrait, $
;       /inches, ysize=9.0, xsize=7.5, yoffset=1.0, xoffset=0.5
  device, filename=psfile, /portrait, /color, /helvetica, $
        /inches, ysize=8.0, xsize=8.0, yoffset=1.0, xoffset=1.0
;  device, filename=psfile, /landscape, /color, /helvetica, $
;        /inches, ysize=8.0, xsize=8.0
  loadct, 39
endif
;
if (out eq 'eps') then begin
  set_plot, 'ps'
  device, filename=psfile, /portrait, /color, /helvetica, /encapsulated, $
        /inches, ysize=8., xsize=8.
  loadct, 39
;  device, filename=psfile, /landscape, /encapsulated, $
;       /inches, ysize=10., xsize=6.
endif


dlogvmrmax = 0.4
dcolmax = 2.e18

;;;;;;;;;;;;;;;;;;;;;;; first plot log(VMR) scatterplots ;;;;;;;;;;;;;;;;;;;;;;

bias_str = strarr(nlevs)
sdev_str = strarr(nlevs)
r_str = strarr(nlevs)


for ilev = 0, nlevs-1 do begin

  nval = 0
  iplot = 0

  for isite = 0, nsites-1 do begin

;  print, sitecodes(isite)

; NOAA profiles
     
    allfiles = 'val_L2_ops/v8t_ops_sara/val_L2_v8.L2V18.0.1.' + sitecodes(isite) + '.*.50km.dat'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    if (file_test(allfiles) eq 0) then continue

    spawn, ('ls ' + allfiles), valfiles

;print, valfiles
    
    nvalfiles = n_elements(valfiles)

;print, nvalfiles
    
    if (nvalfiles lt 1) then continue

    for ival = 0, nvalfiles-1 do begin

;      print, valfiles(ival)

; extract month from filename

      tmp = strsplit(valfiles(ival),'.',/extract)
      ntmp = n_elements(tmp)

; OPS validation filenames only
      datestr = tmp(ntmp-4)

;      valyr = strmid(datestr,0,4)
      valmo = strmid(datestr,4,2)
;      valdy = strmid(datestr,6,2)
     
      spawn, 'wc -l ' + valfiles(ival), returnstring

      nmatch = (fix(returnstring(0)) - 1)/6

      if (nmatch lt 1) then continue

      alldat = fltarr(5,10,nmatch)
      rtvcolm = fltarr(nmatch)
      simcolm = fltarr(nmatch)
      apcolm = fltarr(nmatch)
      wvcolm = fltarr(nmatch)

      pxl = intarr(nmatch)
      str = intarr(nmatch)
      isfc = intarr(nmatch)
      icld = intarr(nmatch)

      psfc = fltarr(nmatch)
      solza = fltarr(nmatch)
      dfs = fltarr(nmatch)

      snr5a = fltarr(nmatch)
      snr6a = fltarr(nmatch)
      snr6r = fltarr(nmatch)

; retrieval anomaly flags at end of header line
      flag1 = intarr(nmatch)
      flag2 = intarr(nmatch)
      flag3 = intarr(nmatch)
      flag4 = intarr(nmatch)
      flag5 = intarr(nmatch)

      profinfo = fltarr(7)

; number of data fields in header line      
      nheader = 20

      header = fltarr(nheader)

      tmp10 = fltarr(10)

      j = -1

      openr, 1, valfiles(ival)

      readf, 1, profinfo

      proflat = profinfo(0)

      for imatch = 0, nmatch-1 do begin

        j = j + 1
        readf, 1, header

        pxl(j) = fix(header(0))
        str(j) = fix(header(1))
        isfc(j) = fix(header(2))
        icld(j) = fix(header(3))
        
        psfc(j) = header(4)
        solza(j) = header(5)
        
        rtvcolm(j) = header(7)
        simcolm(j) = header(8)
        apcolm(j) = header(9)
        wvcolm(j) = header(10)

        dfs(j) = header(11)
        snr5a(j) = header(12)
        snr6a(j) = header(13)
        snr6r(j) = header(14)

        readf, 1, tmp10
        alldat(0,0:9,j) = tmp10(0:9)
        readf, 1, tmp10
        alldat(1,0:9,j) = tmp10(0:9)
        readf, 1, tmp10
        alldat(2,0:9,j) = tmp10(0:9)
        readf, 1, tmp10
        alldat(3,0:9,j) = tmp10(0:9)
        readf, 1, tmp10
        alldat(4,0:9,j) = tmp10(0:9)

      endfor

      close, 1

;;;;;;;;;;;;; begin data analysis ;;;;;;;;;;;

      if (ilev_plot(ilev) eq -1) then begin
        rtv = rtvcolm
        val = simcolm
        ap = apcolm
        dfs1 = dfs
      endif else begin
        rtv = reform(alldat(0,ilev_plot(ilev),*))
        val = reform(alldat(1,ilev_plot(ilev),*))
        ap =  reform(alldat(2,ilev_plot(ilev),*))
      endelse

; daytime and nighttime, ocean and land    
      igd = where(rtv gt 0. and val gt 0. and ap gt 0., ngd)
; daytime only
;      igd = where(rtv gt 0. and val gt 0. and ap gt 0. and solza lt 80., ngd)
; daytime / land
;      igd = where(rtv gt 0. and val gt 0. and ap gt 0. and solza lt 80. and isfc eq 1, ngd)
; nighttime only
;      igd = where(rtv gt 0. and val gt 0. and ap gt 0. and solza ge 80., ngd)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;      

      if (ngd lt ngd_min) then continue

      tmp_stats = moment(val(igd) - ap(igd))
      val_mn = tmp_stats(0)
      val_sd = sqrt(tmp_stats(1))

      tmp_stats = moment(rtv(igd) - ap(igd))
      rtv_mn = tmp_stats(0)
      rtv_sd = sqrt(tmp_stats(1))

      if (ilev_plot(ilev) eq -1) then begin

        if (iplot eq 0) then begin
          plot, val(igd), rtv(igd), xrange=dcolmax*[-1.,1.], yrange=dcolmax*[-1.,1.], xstyle=1, ystyle=1, xtitle='!9D!X CO total column, in-situ', ytitle='!9D!X CO total colm, MOPITT', xticks=4, yticks=4, xminor=2, yminor=2, /nodata        
          xyouts, -0.85*dcolmax, 0.5*dcolmax, lvl_lbl(9), charsize=1.
         iplot = 1
        endif

        plots, val_mn, rtv_mn, psym=4, color=site_colors(isite)
        errplot, val_mn, rtv_mn-rtv_sd, rtv_mn+rtv_sd, color=site_colors(isite)
;
;        if (rtv_sd gt 1.e18) then print, valfiles(ival)
;
        dfs_mn = mean(dfs1(igd))
        
        if (nval eq 0) then begin
          rtv_save = [rtv_mn]
          rtverr_save = [rtv_sd]
          val_save = [val_mn]
          dfs_save = [dfs_mn]
          nval = nval + 1
        endif else begin
          rtv_save = [rtv_save,rtv_mn]
          rtverr_save = [rtverr_save,rtv_sd]
          val_save = [val_save,val_mn]
          dfs_save = [dfs_save,dfs_mn]
        endelse

      endif else begin

        if (iplot eq 0) then begin
          plot, val(igd), rtv(igd), xrange=[-1*dlogvmrmax,dlogvmrmax], yrange=[-1*dlogvmrmax,dlogvmrmax], xstyle=1, xticks=4, xminor= 2, ystyle=1, yticks=4, yminor=2, xtitle='!9D!X log(VMR), in-situ', ytitle='!9D!X log(VMR), MOPITT', /nodata
          xyouts, -0.85*dlogvmrmax, 0.5*dlogvmrmax, lvl_lbl(ilev), charsize=1.
          iplot = 1
        endif

        plots, val_mn, rtv_mn, psym=4, color=site_colors(isite)
        errplot, val_mn, rtv_mn-rtv_sd, rtv_mn+rtv_sd, color=site_colors(isite)

        if (nval eq 0) then begin
          rtv_save = [rtv_mn]
          rtverr_save = [rtv_sd]
          val_save = [val_mn]
          nval = nval + 1
        endif else begin
          rtv_save = [rtv_save,rtv_mn]
          rtverr_save = [rtverr_save,rtv_sd]
          val_save = [val_save,val_mn]
        endelse

      endelse

    endfor

  endfor

  if (ilev_plot(ilev) eq -1) then begin

    plots, dcolmax*[-1.,1.],dcolmax*[-1.,1.], linestyle=1, clip=dcolmax*[-2.,-2.,2.,2.], noclip=0
    d10pct = 2.e17
    plots, [-1.*dcolmax,dcolmax-d10pct],[-1.*dcolmax+d10pct,dcolmax], linestyle=1
    plots, [-1.*dcolmax+d10pct,dcolmax],[-1.*dcolmax,dcolmax-d10pct], linestyle=1

;    corr_str = strtrim(string(correlate(val_save,rtv_save),format='(f7.2)'),2)
    r_str(ilev) = strtrim(string(correlate(val_save,rtv_save),format='(f7.2)'),2)

; plot least-squares fit

    lsqfit = poly_fit(val_save,rtv_save,1,measure_errors=rtverr_save)
;    lsqfit = poly_fit(val_save,rtv_save,1)
    lsqx = dcolmax*(findgen(3) - 1)
    lsqy = lsqfit(0) + lsqfit(1)*lsqx

    oplot, lsqx, lsqy, linestyle=2

; calculate overall bias (weighted mean) in mol/cm2

;    tmp = moment(1.e-18*(rtv_save-val_save))
    
; for V8 paper, report colm bias and SD in 10^17 mol/cm2    
    tmp = moment(1.e-17*(rtv_save-val_save))
    bias_colm = tmp(0)
    sdev_colm = sqrt(tmp(1))

;    bias_str = strtrim(string(bias_colm,format='(f7.2)'),2)
;    sdev_str = strtrim(string(sdev_colm,format='(f7.2)'),2)
    bias_str(ilev) = strtrim(string(bias_colm,format='(f7.1)'),2)
    sdev_str(ilev) = strtrim(string(sdev_colm,format='(f7.1)'),2)

;    xyouts, 0.25*dcolmax, -0.28*dcolmax, ('r = ' + corr_str), charsize=0.8
;    xyouts, 0.25*dcolmax, -0.55*dcolmax, ('bias = ' + bias_str + ' (10!U18!N)'), charsize=0.8
;    xyouts, 0.25*dcolmax, -0.82*dcolmax, ('sdev = ' + sdev_str + ' (10!U18!N)'), charsize=0.8
    xyouts, 0.25*dcolmax, -0.28*dcolmax, ('r = ' + r_str(ilev)), charsize=0.8
;    xyouts, 0.25*dcolmax, -0.55*dcolmax, ('bias = ' + bias_str(ilev) + ' (10!U18!N)'), charsize=0.8
;    xyouts, 0.25*dcolmax, -0.82*dcolmax, ('sdev = ' + sdev_str(ilev) + ' (10!U18!N)'), charsize=0.8
    xyouts, 0.25*dcolmax, -0.55*dcolmax, ('bias = ' + bias_str(ilev) + ' (10!U17!N)'), charsize=0.8
    xyouts, 0.25*dcolmax, -0.82*dcolmax, ('sdev = ' + sdev_str(ilev) + ' (10!U17!N)'), charsize=0.8
    
  endif else begin

;    plots, [-0.4,0.4],[-0.4,0.4], linestyle=1
    plots, dlogvmrmax*[-1.,1.],dlogvmrmax*[-1.,1.], linestyle=1
; plot +/- 10 percent lines
    d10pct = 0.0414
    plots, [-1.*dlogvmrmax,dlogvmrmax-d10pct],[-1.*dlogvmrmax+d10pct,dlogvmrmax], linestyle=1
    plots, [-1.*dlogvmrmax+d10pct,dlogvmrmax],[-1.*dlogvmrmax,dlogvmrmax-d10pct], linestyle=1

;    corr_str = strtrim(string(correlate(val_save,rtv_save),format='(f7.2)'),2)
    r_str(ilev) = strtrim(string(correlate(val_save,rtv_save),format='(f7.2)'),2)

    lsqfit = poly_fit(val_save,rtv_save,1,measure_errors=rtverr_save)
;    lsqfit = poly_fit(val_save,rtv_save,1)
    lsqx = -0.4 + 0.1*findgen(9)
    lsqy = lsqfit(0) + lsqfit(1)*lsqx

    oplot, lsqx, lsqy, linestyle=2

    tmp = moment(rtv_save-val_save)
    bias_pct = 100.*tmp(0)/log10e
    sdev_pct = 100.*sqrt(tmp(1))/log10e

;    bias_str = strtrim(string(bias_pct,format='(f7.1)'),2)
;    sdev_str = strtrim(string(sdev_pct,format='(f7.1)'),2)
    bias_str(ilev) = strtrim(string(bias_pct,format='(f7.1)'),2)
    sdev_str(ilev) = strtrim(string(sdev_pct,format='(f7.1)'),2)

;    xyouts, 0.4*dlogvmrmax, -0.28*dlogvmrmax, ('r = ' + corr_str), charsize=0.8
;    xyouts, 0.4*dlogvmrmax, -0.55*dlogvmrmax, ('bias = ' + bias_str + ' %'), charsize=0.8
;    xyouts, 0.4*dlogvmrmax, -0.82*dlogvmrmax, ('sdev = ' + sdev_str + ' %'), charsize=0.8
    xyouts, 0.4*dlogvmrmax, -0.28*dlogvmrmax, ('r = ' + r_str(ilev)), charsize=0.8
    xyouts, 0.4*dlogvmrmax, -0.55*dlogvmrmax, ('bias = ' + bias_str(ilev) + ' %'), charsize=0.8
    xyouts, 0.4*dlogvmrmax, -0.82*dlogvmrmax, ('sdev = ' + sdev_str(ilev) + ' %'), charsize=0.8

 endelse

endfor

;print, 'N. Overpasses = ' + strtrim(n_elements(dfs_save),2)
;print, 'DFS mean = ' + strtrim(mean(dfs_save),2)

xyouts, 0.5, 0.99, /norm, align=0.5, plottitle

if (out ne 'x') then device, /close

return
end
