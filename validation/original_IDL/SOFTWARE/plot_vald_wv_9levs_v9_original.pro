;Original by Merritt Deeter circa 03.2022
;modifications by Sara Martinez-Alonso 08.2024
;

pro plot_vald_wv_9levs_v9

  ; generates plots of retrieval bias vs water vapor total column

  ; cleaned-up scatterplot code 2/1/18, plots 9 levels plus total column

  ; generates validation scatterplots of (x_rtv - x_a)

  ;ngd_min = 10
  ;ngd_min = 12
  ;ngd_min = 15
  ngd_min = 5
  ;ngd_min = 2

  log10e = alog10(exp(1.))

  ; order CMDL sites from N to S

  ; plots based on All CMDL/CCGG stations

  ;sitecodes = ['2009hippo1qcls','2009hippo2qcls','2010hippo3qcls','2011hippo4qcls','2011hippo5qcls','ACRIDICON']
  ;site_colors = [40,80,120,220,250,1]
  ;site_labels = ['H1','H2','H3','H4','H5','AC']

  ;sitecodes = ['2009hippo1qcls','2009hippo2qcls','2010hippo3qcls','2011hippo4qcls','2011hippo5qcls']
  ;site_colors = [40,80,120,220,250]
  ;site_labels = ['H1','H2','H3','H4','H5']

  ; ATOM (phases 1 and 2)
  ;sitecodes = ['AToM_QCLS_2016','AToM_QCLS_2017']
  ;site_colors = [40,80]
  ;site_labels = ['ATOM-1 QCLS','ATOM-2 QCLS']

  ; sites in updated 'validation-mode' list (July, 2018)
  ;sitecodes = ['aao','bne','car','cma','dnd','esp','etl','haa','hfm','hil','hip','lef','nha','nsa','pfa','rta','sca','sgp','tgc','thd','tom','wbi','wgc']

  ; V9 radfix-optimization validation

  ;sitecodes = ['2009hippo1qcls','2009hippo2qcls','2010hippo3qcls','2011hippo4qcls','2011hippo5qcls','ATom_QCLS_2016_tmp','ATom_QCLS_2017a_tmp','ATom_QCLS_2017b_tmp','ATom_QCLS_2018_tmp']
  ;site_colors = [40,80,120,220,250]
  ;site_labels = ['H1','H2','H3','H4','H5']

  sitecodes = ['2009hippo1qcls','2009hippo2qcls','2010hippo3qcls','2011hippo4qcls','2011hippo5qcls','ATom_QCLS_2016_tmp','ATom_QCLS_2017a_tmp','ATom_QCLS_2017b_tmp','ATom_QCLS_2018_tmp']
  ;site_colors = [40,80,120,220]

  nsites = n_elements(sitecodes)

  ;site_colors = make_array(nsites, /integer, value=120)
  site_colors = intarr(9)
  site_colors(0:4) = 40
  site_colors(5:8) = 250


  sitesyms = make_array(nsites, /integer, value=4)

  ;psfile = 'plot_vald_wv_9levs.L2V17.9x.1.opt8.hippo_ac.allcld.dy.eps'
  ;psfile = 'plot_vald_wv_9levs.L2V17.9x.1.opt9.hippo_ac.allcld.dy.eps'
  ;psfile = 'plot_vald_wv_9levs.L2V17.9x.1.opt9.hippo_ac.clr_23.dy.eps'
  ;psfile = 'plot_vald_wv_9levs.L2V17.9x.1.opt10.hippo_ac.allcld.dy.eps'
  ;psfile = 'plot_vald_wv_9levs.L2V17.9x.1.opt10.hippo_ac.clr_23.dy.eps'

  ; V7T OPS
  ;psfile = 'plot_vald_wv_9levs.L2V17.8.1.noaa.allcld.dy.eps'
  ; V7N OPS
  ;psfile = 'plot_vald_wv_9levs.L2V17.8.2.noaa.allcld.dy.eps'
  ; V7J OPS
  ;psfile = 'plot_vald_wv_9levs.L2V17.8.3.noaa.allcld.dy.eps'

  ; NIR-only tests, no cloud filtering
  ;psfile = 'plot_vald_wv_9levs.L2V17.9x.2.opt3_modis6.noaa2018.allcld.dy.eps'

  ;;;;;;;;;;;;;;;;;;;;; V7 OPS ;;;;;;;;;;;;;;;;;

  ; TIR-only, no cloud filtering
  ;psfile = 'plot_vald_wv_9levs.v7t_ops.hippo.allcld.dy.eps'

  ;;;;;;;;;;;;;;;;;;;;; V8 OPS ;;;;;;;;;;;;;;;;;

  ; TIR-only, no cloud filtering
  ;psfile = 'plot_vald_wv_9levs.v8t_ops.hippo_ac.allcld.dy.eps'
  ;psfile = 'plot_vald_wv_9levs.v8t_ops.hippo.allcld.dy.eps'
  ;psfile = 'plot_vald_wv_9levs.v8t_ops.atom_12.allcld.dy.eps'

  ; experiments to find best thresholds for HIPPO validation

  ; 'reference' case
  ;psfile = 'plot_vald_wv_9levs.v8t_ops.hippo.200km.400hPa.dy.eps'
  ; change thresh for highest level in profile to 250 hPa
  ;psfile = 'plot_vald_wv_9levs.v8t_ops.hippo.200km.250hPa.dy.eps'
  ; change thresh for collocation distance to 100 km
  ;psfile = 'plot_vald_wv_9levs.v8t_ops.hippo.100km.250hPa.dy.eps'


  ; V9

  ;psfile = 'plot_vald_wv_9levs_v9.L2V19.5.1.hippo_atom.200km.allcld.dy.eps'
  ;psfile = 'plot_vald_wv_9levs_v9_radfix3.L2V19.5.1.hippo_atom.200km.allcld.dy.eps'

  ;psfile = 'plot_vald_wv_9levs_v9.L2V18.0.1.hippo_atom.200km.allcld.dy.eps'
  ;psfile = 'plot_val_wv_9levs_v9_L2V19.9.1c.hippo.200km.allcld.dy.eps'
  ;psfile = 'plot_val_wv_9levs_v9_L2V19.9.1c.ATom.200km.allcld.dy.eps'
  ;psfile = 'plot_val_wv_9levs_v9_L2V19.9.1c.hippo_ATom.200km.allcld.dy.eps'

  ; V8 reference
  ;psfile = 'plot_val_wv_9levs_v9_L2V18.0.1.hippo_ATom.200km.allcld.dy.eps'


  ; V9 OPS
  psfile = 'plot_vald_wv_9levs_v9.L2V19.9.1.hippo_v_atom.200km.allcld.dy.eps'


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


  ;dlogvmrmax = 0.2
  pctvmrmax = 40.

  dcolmax = 4.e17
  wvcolm_max = 2.5e23

  ;;;;;;;;;;;;;;;;;;;;;;; first plot log(VMR) scatterplots ;;;;;;;;;;;;;;;;;;;;;;

  for ilev = 0, nlevs-1 do begin

    nval = 0
    iplot = 0

    for isite = 0, nsites-1 do begin

      ;  print, sitecodes(isite)

      ;;;;;;;;;;;;;;;; select source of validation files ;;;;;;;;;;;;;;;;

      ; HIPPO/AC
      ;    allfiles = 'val_L2_radfix_optmz/opt8/val_L2_v7.L2V17.9x.1.' + sitecodes(isite) + '.*.200km.dat'
      ;    allfiles = 'val_L2_radfix_optmz/opt9/val_L2_v8.L2V17.9x.1.' + sitecodes(isite) + '.*.200km.dat'
      ;    allfiles = 'val_L2_radfix_optmz/opt10/val_L2_v8.L2V17.9x.1.' + sitecodes(isite) + '.*.200km.dat'

      ; V7T OPS / NOAA
      ;    allfiles = 'val_L2_radfix_optmz/v7t_ops/val_L2_v7.L2V17.8.1.' + sitecodes(isite) + '.*.50km.dat'
      ; V7N OPS / NOAA
      ;    allfiles = 'val_L2_radfix_optmz/v7n_ops/val_L2_v7.L2V17.8.2.' + sitecodes(isite) + '.*.50km.dat'
      ; V7J OPS / NOAA
      ;    allfiles = 'val_L2_radfix_optmz/v7j_ops/val_L2_v7.L2V17.8.3.' + sitecodes(isite) + '.*.50km.dat'

      ; NIR-only radfix tests
      ;    allfiles = 'val_L2_radfix_optmz/radfix_nir_opt3_thr1.000_modis6/val_L2_v7.L2V17.9x.2.' + sitecodes(isite) + '.*.50km.dat'

      ;;;;;;;;;;;;;;;;;;;;; V7 OPS ;;;;;;;;;;;;;;;;;

      ;    allfiles = 'val_L2_ops/v7t_ops/val_L2_v7.L2V17.x.1.' + sitecodes(isite) + '.*.200km.dat'

      ;;;;;;;;;;;;;;;;;;;;; V8 OPS ;;;;;;;;;;;;;;;;;

      ;    allfiles = 'val_L2_ops/v8t_ops/val_L2_v8.L2V18.0.1.' + sitecodes(isite) + '.*.200km.dat'
      ;    allfiles = 'val_L2_ops/v8t_ops/val_L2_v8.L2V18.0.1.' + sitecodes(isite) + '.*.*km.dat'

      ; HIPPO and ATom expts to optimize thresholds
      ;    allfiles = 'val_L2_ops/v8t_ops/val_L2_v8.L2V18.0.1.' + sitecodes(isite) + '.*.200km.250hPa.dat'
      ;    allfiles = 'val_L2_ops/v8t_ops/val_L2_v8.L2V18.0.1.' + sitecodes(isite) + '.*.100km.250hPa.dat'

      ; V9 radfix optimization experiments

      ;  HIPPO + ATom profiles
      ;     allfiles = 'val_L2_v9_radfix2/L2V19.5.1/val_L2_v9.L2V19.5.1.' + sitecodes(isite) + '.*.200km.dat'
      ;     allfiles = 'val_L2_v9_radfix3/L2V19.5.1/val_L2_v9.L2V19.5.1.' + sitecodes(isite) + '.*.200km.dat'

      ;    allfiles = 'val_L2_v9_xpt1/V8T_ops/val_L2_v9.L2V18.0.1.' + sitecodes(isite) + '.*.200km.dat'
      ;    allfiles = 'val_L2_ops/L2V19.9.1/val_L2_v9.L2V19.9.1.' + sitecodes(isite) + '.*.200km.dat'

      ; Archival V9
      ;     allfiles = 'val_L2_ops/L2V19.9.1c_fullmission/val_L2_v9.L2V19.9.1.' + sitecodes(isite) + '.*.200km.dat'
      ; V8 reference
      ;     allfiles = 'val_L2_ops/L2V18.0.1/val_L2_v9.L2V18.0.1.' + sitecodes(isite) + '.*.200km.dat'

      ; V9T OPS
      allfiles = 'val_L2_ops/v9t_ops/val_L2_v9.L2V19.9.1.' + sitecodes(isite) + '.*.200km.dat'

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      if (file_test(allfiles) eq 0) then continue

      spawn, ('ls ' + allfiles), valfiles

      ;print, valfiles

      nvalfiles = n_elements(valfiles)

      ;print, nvalfiles

      if (nvalfiles lt 1) then continue

      wvcolm_mn = fltarr(nvalfiles)
      logvmrbias = fltarr(nvalfiles)
      logvmrbias(*) = -999.

      for ival = 0, nvalfiles-1 do begin

        ;      print, valfiles(ival)

        ; extract month from filename

        tmp = strsplit(valfiles(ival),'.',/extract)
        ntmp = n_elements(tmp)
        datestr = tmp(ntmp-4)
        ;      valyr = strmid(datestr,0,4)
        valmo = strmid(datestr,4,2)
        ;      valdy = strmid(datestr,6,2)

        spawn, 'wc -l ' + valfiles(ival), returnstring

        ; no AK row sum values in validation files
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

        ;      nheader = 20
        ;
        ; for V9, added two diagnostics to header (modis clear frac and MOP radratio)
        nheader = 22

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
          rtv = 1.e-18*rtvcolm
          val = 1.e-18*simcolm
          ap = apcolm
          ;        dfs1 = dfs
        endif else begin
          rtv = reform(alldat(0,ilev_plot(ilev),*))
          val = reform(alldat(1,ilev_plot(ilev),*))
          ap =  reform(alldat(2,ilev_plot(ilev),*))
        endelse

        ; daytime and nighttime
        ;      igd = where(rtv gt 0. and val gt 0. and ap gt 0., ngd)
        ; daytime only
        igd = where(rtv gt 0. and val gt 0. and ap gt 0. and solza lt 80., ngd)
        ; nighttime only
        ;      igd = where(rtv gt 0. and val gt 0. and ap gt 0. and solza ge 80., ngd)

        ; MODIS clear only (icld = 2 or 3)
        ; daytime and nighttime
        ;      igd = where(rtv gt 0. and val gt 0. and ap gt 0. and (icld eq 2 or icld eq 3), ngd)
        ; daytime only
        ;      igd = where(rtv gt 0. and val gt 0. and ap gt 0. and solza lt 80. and (icld eq 2 or icld eq 3), ngd)
        ;      igd = where(rtv gt 0. and val gt 0. and ap gt 0. and solza lt 80. and (icld eq 2), ngd)
        ;      igd = where(rtv gt 0. and val gt 0. and ap gt 0. and solza lt 80. and icld gt -1, ngd)
        ; nighttime only
        ;      igd = where(rtv gt 0. and val gt 0. and ap gt 0. and solza ge 80. and (icld eq 2 or icld eq 3), ngd)

        ;      print, ngd

        if (ngd lt ngd_min) then continue

        if (ilev_plot(ilev) eq -1) then begin
          stats = moment(rtv(igd) - val(igd))
        endif else begin
          stats = moment(rtv(igd) - val(igd))
        endelse

        logvmrbias(ival) = stats(0)

        wvcolm_mn(ival) = mean(wvcolm(igd))

        ;if (ilev eq 0) then print, valfiles(ival), wvcolm_mn(ival)

        if (ilev_plot(ilev) eq -1) then begin

          if (iplot eq 0) then begin
            plot, wvcolm_mn, 1.e18*logvmrbias, xrange=[0.,wvcolm_max], yrange=dcolmax*[-1.,1.], xstyle=1, ystyle=1, xtitle='Water Vapor Total Column (mol/cm!U2!N)', ytitle='CO total colm bias (mol/cm!U2!N)', xticks=5, yticks=4, xminor=5, yminor=2, /nodata
            xyouts, 0.75*wvcolm_max, -0.75*dcolmax, lvl_lbl(9), charsize=1.
            iplot = 1
          endif

          ;        plots, wvcolm_mn(ival), 1.e18*logvmrbias(ival), psym=4, color=site_colors(isite)
          plots, wvcolm_mn(ival), 1.e18*logvmrbias(ival), psym=4, color=site_colors(isite), symsize=0.25

          ;
          ;        if (rtv_sd gt 1.e18) then print, valfiles(ival)
          ;
          if (nval eq 0) then begin
            bias_save = [1.e18*logvmrbias(ival)]
            wv_save = [wvcolm_mn(ival)]
            nval = nval + 1
          endif else begin
            bias_save = [bias_save,1.e18*logvmrbias(ival)]
            wv_save = [wv_save,wvcolm_mn(ival)]
          endelse

        endif else begin

          if (iplot eq 0) then begin
            ;          plot, wvcolm_mn, logvmrbias, xrange=[0.,wvcolm_max], yrange=[-1*dlogvmrmax,dlogvmrmax], xstyle=1, xticks=5, xminor= 5, ystyle=1, yticks=4, yminor=2, xtitle='Water Vapor Total Column (mol/cm!U2!N)', ytitle='log(VMR) bias', /nodata
            plot, wvcolm_mn, logvmrbias, xrange=[0.,wvcolm_max], yrange=[-1*pctvmrmax,pctvmrmax], xstyle=1, xticks=5, xminor= 5, ystyle=1, xtitle='Water Vapor Total Column (mol/cm!U2!N)', ytitle='Relative Bias (%)', /nodata
            ;          xyouts, 0.75*wvcolm_max, -0.75*dlogvmrmax, lvl_lbl(ilev), charsize=1.
            ;          xyouts, 0.07*wvcolm_max, 0.6*dlogvmrmax, lvl_lbl(ilev), charsize=1.
            xyouts, 0.07*wvcolm_max, 0.6*pctvmrmax, lvl_lbl(ilev), charsize=1.
            iplot = 1
          endif

          ;        plots, val_mn, rtv_mn, psym=4, color=site_colors(isite)
          ;        errplot, val_mn, rtv_mn-rtv_sd, rtv_mn+rtv_sd, color=site_colors(isite)
          ;        plots, wvcolm_mn(ival), logvmrbias(ival), psym=4, color=site_colors(isite)
          ;        plots, wvcolm_mn(ival), (100./0.4343)*logvmrbias(ival), psym=4, color=site_colors(isite)
          plots, wvcolm_mn(ival), (100./0.4343)*logvmrbias(ival), psym=4, color=site_colors(isite), symsize=0.25

          if (nval eq 0) then begin
            ;          bias_save = [logvmrbias(ival)]
            bias_save = [(100./0.4343)*logvmrbias(ival)]
            wv_save = [wvcolm_mn(ival)]
            nval = nval + 1
          endif else begin
            ;          bias_save = [bias_save,logvmrbias(ival)]
            bias_save = [bias_save,(100./0.4343)*logvmrbias(ival)]
            wv_save = [wv_save,wvcolm_mn(ival)]
          endelse

        endelse

      endfor

      ;    if (ilev eq 0) then begin
      ;      xyouts, 0.22, 0.05-isite*0.08, site_labels(isite), color=site_colors(isite),charsize=1.2
      ;      xyouts, 0.65*dlogvmrmax, dlogvmrmax*(-0.1-isite*0.22), site_labels(isite), color=site_colors(isite),charsize=1.1
      ;    endif

    endfor


    if (ilev_plot(ilev) eq -1) then begin

      ;    plots, dcolmax*[-1.,1.],dcolmax*[-1.,1.], linestyle=1, clip=dcolmax*[-2.,-2.,2.,2.], noclip=0
      ;    d10pct = 2.e17
      ;    plots, [-1.*dcolmax,dcolmax-d10pct],[-1.*dcolmax+d10pct,dcolmax], linestyle=1
      ;    plots, [-1.*dcolmax+d10pct,dcolmax],[-1.*dcolmax,dcolmax-d10pct], linestyle=1

      corr_str = strtrim(string(correlate(1.e-23*wv_save,1.e-17*bias_save),format='(f7.2)'),2)

      ; plot least-squares fit

      ;    lsqfit = poly_fit(wv_save,bias_save,1,measure_errors=rtverr_save)
      lsqfit = poly_fit(wv_save,bias_save,1,SIGMA=sigma)
      lsqx = wvcolm_max*(findgen(2))
      lsqy = lsqfit(0) + lsqfit(1)*lsqx

      ;    print, lsqx, lsqy

      oplot, lsqx, lsqy, linestyle=2

      slope = lsqfit(1)
      slopeuncy = sigma(1)

      slopestr = strtrim(string(slope,format='(e10.2)'),2)
      ;    slopeuncystr = strtrim(string(slopeuncy,format='(e10.1)'),2)
      slopeuncystr = strtrim(string(slopeuncy,format='(e10.2)'),2)

      ;    xyouts, 0.07*wvcolm_max, -0.8*dlogvmrmax, 'Slope = ' + slopepctstr + '!9 ' + String("261B) + ' !X' + slopepctuncystr + ' %/(mol/cm!U2!N)', charsize=0.8
      xyouts, 0.07*wvcolm_max, -0.8*dcolmax, 'Slope = ' + slopestr + '!9 ' + String("261B) + ' !X' + slopeuncystr + '', charsize=0.8

      ; calculate overall bias (weighted mean) in mol/cm2

      ;    tmp = moment(1.e-18*(bias_save-wv_save))
      ;    bias_colm = tmp(0)
      ;    sdev_colm = sqrt(tmp(1))

      ;    bias_str = strtrim(string(bias_colm,format='(f7.2)'),2)
      ;    sdev_str = strtrim(string(sdev_colm,format='(f7.2)'),2)

      xyouts, 0.75*wvcolm_max, 0.6*dcolmax, ('r = ' + corr_str), charsize=0.8
      ;    xyouts, 0.25*dcolmax, -0.55*dcolmax, ('bias = ' + bias_str + ' (10!U18!N)'), charsize=0.8
      ;    xyouts, 0.25*dcolmax, -0.82*dcolmax, ('sdev = ' + sdev_str + ' (10!U18!N)'), charsize=0.8

      ; now calculate p value based on t test on the slope for drift in total colm

      df = n_elements(wv_save) - 2
      t = slope/slopeuncy
      p = 2.0 * (1.0 - T_PDF(ABS(t), df))

      print, lvl_lbl(ilev),'; slope-based p value = ', p

    endif else begin

      ;;    plots, [-0.4,0.4],[-0.4,0.4], linestyle=1
      ;    plots, dlogvmrmax*[-1.,1.],dlogvmrmax*[-1.,1.], linestyle=1
      ;; plot +/- 10 percent lines
      ;    d10pct = 0.0414
      ;    plots, [-1.*dlogvmrmax,dlogvmrmax-d10pct],[-1.*dlogvmrmax+d10pct,dlogvmrmax], linestyle=1
      ;    plots, [-1.*dlogvmrmax+d10pct,dlogvmrmax],[-1.*dlogvmrmax,dlogvmrmax-d10pct], linestyle=1

      corr_str = strtrim(string(correlate(1.e-23*wv_save,bias_save),format='(f7.2)'),2)

      ;    lsqfit = poly_fit(wv_save,bias_save,1,measure_errors=rtverr_save)
      lsqfit = poly_fit(wv_save,bias_save,1,SIGMA=sigma)
      lsqx = wvcolm_max*(findgen(2))
      lsqy = lsqfit(0) + lsqfit(1)*lsqx

      ;    print, lsqx, lsqy

      oplot, lsqx, lsqy, linestyle=2

      ;    slopepct = lsqfit(1)*(100./0.4343)
      ;    slopepctuncy = sigma(1)*(100./0.4343)
      slopepct = lsqfit(1)
      slopepctuncy = sigma(1)

      slopepctstr = strtrim(string(slopepct,format='(e10.2)'),2)
      ;    slopepctuncystr = strtrim(string(slopepctuncy,format='(e10.1)'),2)
      slopepctuncystr = strtrim(string(slopepctuncy,format='(e10.2)'),2)

      ;    xyouts, 0.07*wvcolm_max, -0.8*dlogvmrmax, 'Slope = ' + slopepctstr + '!9 ' + String("261B) + ' !X' + slopepctuncystr + ' %/(mol/cm!U2!N)', charsize=0.8
      xyouts, 0.07*wvcolm_max, -0.8*pctvmrmax, 'Slope = ' + slopepctstr + '!9 ' + String("261B) + ' !X' + slopepctuncystr + ' %/(mol/cm!U2!N)', charsize=0.8

      ;    tmp = moment(bias_save-wv_save)
      ;    bias_pct = 100.*tmp(0)/log10e
      ;    sdev_pct = 100.*sqrt(tmp(1))/log10e

      ;    bias_str = strtrim(string(bias_pct,format='(f7.1)'),2)
      ;    sdev_str = strtrim(string(sdev_pct,format='(f7.1)'),2)

      ;    xyouts, 0.75*wvcolm_max, 0.6*dlogvmrmax, ('r = ' + corr_str), charsize=0.8
      xyouts, 0.75*wvcolm_max, 0.6*pctvmrmax, ('r = ' + corr_str), charsize=0.8
      ;    xyouts, 0.4*dlogvmrmax, -0.55*dlogvmrmax, ('bias = ' + bias_str + ' %'), charsize=0.8
      ;    xyouts, 0.4*dlogvmrmax, -0.82*dlogvmrmax, ('sdev = ' + sdev_str + ' %'), charsize=0.8

      ; now calculate p value based on t test on the slope for drift at levels

      df = n_elements(wv_save) - 2
      t = slopepct/slopepctuncy
      p = 2.0 * (1.0 - T_PDF(ABS(t), df))

      print, lvl_lbl(ilev),'; slope-based p value = ', p

    endelse

  endfor


  ;print, 'N. Overpasses = ' + strtrim(n_elements(dfs_save),2)
  ;print, 'DFS mean = ' + strtrim(mean(dfs_save),2)

  ;xyouts, 0.5, 0.99, /norm, align=0.5, plottitle

  if (out ne 'x') then device, /close

  return
end

