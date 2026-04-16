;Original by Merritt Deeter circa 03.2022
;modifications by Sara Martinez-Alonso 08.2024
;

pro plot_biasdrift_pct_9levs

  ; generates bias drift timeseries plot for 9 levels plus total column

  ;ngd_min = 10
  ;ngd_min = 12
  ;ngd_min = 15
  ngd_min = 5
  ;ngd_min = 2

  ;latmin = -90.
  ;latmax = 90.

  ; first validation-mode run (radfix optimization run 8), no cloud filtering
  ;psfile = 'plot_biasdrift_pct_9levs.L2V17.9x.1.opt8.noaa2018.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.L2V17.9x.1.opt8.noaa2018.allcld.dy.eps'
  ;outfile = 'plot_biasdrift_pct_9levs.L2V17.9x.1.opt8.noaa2018.allcld.dy.dat'
  ;psfile = 'plot_biasdrift_pct_9levs.L2V17.9x.1.opt9.noaa2018.allcld.dy.eps'
  ;outfile = 'plot_biasdrift_pct_9levs.L2V17.9x.1.opt9.noaa2018.allcld.dy.dat'
  psfile = 'plot_biasdrift_pct_9levs.L2V17.9x.1.opt10.noaa2018.allcld.dy.eps'
  outfile = 'plot_biasdrift_pct_9levs.L2V17.9x.1.opt10.noaa2018.allcld.dy.dat'
  ;
  ; TIR-only tests, no cloud filtering
  ;psfile = 'plot_biasdrift_pct_9levs.v7t_ops.noaa2018.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v7t_ops.noaa2018.allcld.dy.evenyrs.eps'


  ;psfile = 'test.eps'
  ; NIR-only tests, no cloud filtering
  ;psfile = 'plot_biasdrift_pct_9levs.v7n_ops.noaa2018.allcld.dy.eps'
  ; JNT tests, no cloud filtering
  ;psfile = 'plot_biasdrift_pct_9levs.v7j_ops.noaa2018.allcld.dy.eps'

  ; NIR-only tests, no cloud filtering
  ;psfile = 'plot_biasdrift_pct_9levs.L2V17.9x.2.opt1_modis6.noaa2018.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.L2V17.9x.2.opt2_modis6.noaa2018.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.L2V17.9x.2.opt3_modis6.noaa2018.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.L2V17.9x.2.opt4_modis6.noaa2018.allcld.dy.eps'

  ; JNT tests, no cloud filtering
  ;psfile = 'plot_biasdrift_pct_9levs.L2V17.9x.3.opt1_modis6.noaa2018.allcld.dy.eps'

  ;;;;;;;;;;;;;;;;;;;;; V8 OPS ;;;;;;;;;;;;;;;;;

  ;psfile = 'test.eps'
  ;psfile = 'testv7.psfcall.eps'
  ;psfile = 'testv7.psfc900min.eps'
  ;psfile = 'testv8.psfc900min.eps'

  ; TIR-only, no cloud filtering
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.noaa.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.noaa.allcld.dy_land.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.test.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.noaa.allcld.2008_2017.dy.eps'

  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.noaa.allcld.dy.allyrs.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.noaa.allcld.dy.evenyrs.eps'


  ;psfile = 'plot_biasdrift_pct_9levs.v8t_mopfas_corr.noaa18.dy.evenyrs.eps'


  ; NIR-only, no cloud filtering
  ;psfile = 'plot_biasdrift_pct_9levs.v8n_ops.noaa.allcld.dy.eps'
  ; JNT, no cloud filtering
  ;psfile = 'plot_biasdrift_pct_9levs.v8j_ops.noaa.allcld.dy.eps'

  ; single-validation site plots
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.noaa_rta_50km.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.noaa_rta_200km.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.noaa_haa_50km.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.noaa_haa_200km.allcld.dy.eps'

  ;psfile = 'plot_biasdrift_pct_9levs.v7t_ops.hippo_atom_200km.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom_200km.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom123_200km.allcld.dy.eps'


  ;latmin = -90.
  ;latmax = 90.
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom1234_200km.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v7t_ops.hippo_atom1234_200km.allcld.dy.eps'

  ; optimization expts
  ;latmin = -90.
  ;latmax = 90.
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom.100km.250hPa.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom.200km.250hPa.dy.eps'


  ;latmin = 30.
  ;latmax = 60.
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom_200km.n_midlat.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom123_200km.n_midlat.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom1234_200km.n_midlat.allcld.dy.eps'

  ;latmin = 0.
  ;latmax = 30.
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom_200km.n_trop.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom123_200km.n_trop.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom1234_200km.n_trop.allcld.dy.eps'

  ;latmin = -30.
  ;latmax = 0.
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom_200km.s_trop.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom123_200km.s_trop.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom124_200km.s_trop.allcld.dy.eps'


  ;latmin = -60.
  ;latmax = -30.
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom_200km.s_midlat.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom123_200km.s_midlat.allcld.dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.hippo_atom1234_200km.s_midlat.allcld.dy.eps'


  ;psfile = 'plot_biasdrift_pct_9levs.v8t_ops.jalali_dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8n_ops.jalali_dy.eps'
  ;psfile = 'plot_biasdrift_pct_9levs.v8j_ops.jalali_dy.eps'

  ;psfile = 'plot_biasdrift_pct_9levs_comprv9.noaa.v8t_ops.dy.eps'
  ;outfile = 'plot_biasdrift_pct_9levs_comprv9.noaa.v8t_ops.dy.dat'
  ;psfile = 'plot_biasdrift_pct_9levs_comprv9.noaa.v8n_ops.dy.eps'
  ;outfile = 'plot_biasdrift_pct_9levs_comprv9.noaa.v8n_ops.dy.dat'
  ;psfile = 'plot_biasdrift_pct_9levs_comprv9.noaa.v8j_ops.dy.eps'
  ;outfile = 'plot_biasdrift_pct_9levs_comprv9.noaa.v8j_ops.dy.dat'


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;out = 'ps'
  out = 'eps'

  ; sites in updated 'validation-mode' list (July, 2018)
  sitecodes = ['aao','bne','car','cma','dnd','esp','etl','haa','hfm','hil','hip','lef','nha','nsa','pfa','rta','sca','sgp','tgc','thd','tom','wbi','wgc']

  ; for MOPFAS PMC correction experiments
  ;sitecodes = ['bne','car','cma','dnd','esp','etl','haa','hil','lef','nha','pfa','rta','sca','sgp','tgc','thd','wbi','wgc']
  ;sitecodes = ['bne','car','cma','dnd','esp','etl','haa','hfm','hil','lef','nha','pfa','rta','sca','sgp','tgc','thd','wbi','wgc']

  ; RTA only
  ;sitecodes = ['rta']
  ; HAA only
  ;sitecodes = ['haa']

  ; HIPPO and ATom
  ;sitecodes = ['2009hippo1qcls','2009hippo2qcls','2010hippo3qcls','2011hippo4qcls','2011hippo5qcls','AToM_QCLS_2016','AToM_QCLS_2017']
  ; ATom 1, 2, and 3
  ;sitecodes = ['2009hippo1qcls','2009hippo2qcls','2010hippo3qcls','2011hippo4qcls','2011hippo5qcls','ATom_QCLS_2016','ATom_QCLS_2017a','ATom_QCLS_2017b']
  ;sitecodes = ['2009hippo1qcls','2009hippo2qcls','2010hippo3qcls','2011hippo4qcls','2011hippo5qcls','ATom_QCLS_2016_tmp','ATom_QCLS_2017a_tmp','ATom_QCLS_2017b_tmp','ATom_QCLS_2018_tmp']

  ; for Ali Jalali

  ;sitecodes = ['pfa','etl']
  ;site_colors = [40,220]

  ; identical set used for V9 validation
  ;sitecodes = ['aao','bne','car','cma','dnd','esp','etl','haa','hfm','hil','lef','nha','pfa','rta','sca','sgp','tgc','thd','wbi','wgc']


  nsites = n_elements(sitecodes)

  site_colors = make_array(nsites, /integer, value=120)
  sitesyms = make_array(nsites, /integer, value=4)


  !p.font = 0
  ;!p.charsize=0.8
  !p.charsize=1.3
  ;!p.symsize=0.4
  !p.symsize=0.8
  !p.thick = 3.
  !x.thick = 3.
  !y.thick = 3.
  !p.multi = [0,2,5]

  if (out eq 'ps') then begin
    set_plot, 'ps'
    ;  device, filename=psfile, /portrait, $
    ;       /inches, ysize=8.0, xsize=7.0, yoffset=1.0, xoffset=0.5
    ;  device, filename=psfile, /portrait, /color, /helvetica, $
    ;        /inches, ysize=9., xsize=6., yoffset=1., xoffset=1.25
    device, filename=psfile, /landscape, /color, /helvetica, $
      /inches, ysize=6.0, xsize=9.0
  endif
  ;
  if (out eq 'eps') then begin
    set_plot, 'ps'
    ;  device, filename=psfile, /portrait, /encapsulated, $
    ;       /inches, ysize=7.0, xsize=4.5
    ;  device, filename=psfile, /portrait, /color, /encapsulated, /helvetica, $
    ;        /inches, ysize=9., xsize=6.
    device, filename=psfile, /portrait, /color, /helvetica, /encapsulated, $
      /inches, ysize=8., xsize=8.
    ;  device, filename=psfile, /landscape, /color, /encapsulated, /helvetica, $
    ;        /inches, ysize=6.0, xsize=9.0
  endif

  loadct, 39

  jday1 = julday(1,1,2000)
  ;jday1 = julday(1,1,2008)
  ;jday2 = julday(1,1,2012)
  ;jday2 = julday(1,1,2014)
  ;jday2 = julday(1,1,2016)
  ;jday2 = julday(1,1,2018)
  jday2 = julday(1,1,2020)

  dates = timegen(start=jday1,final=jday2,units='Days')
  ndates = n_elements(dates)
  dmy_data = fltarr(ndates)
  dmy_data(*) = 0.

  ; Create format strings for a two-level axis:

  ;dummy = LABEL_DATE(DATE_FORMAT=['%M%Y'])
  dummy = LABEL_DATE(DATE_FORMAT=['%Y'])

  ;;;;;;;;;;;;; 9 levs plus total column ;;;;;;;;;;;;;

  ilev_plot = [8,7,6,5,4,3,2,1,0,-1]

  lvl_lbl = ['200 hPa','300 hPa','400 hPa','500 hPa','600 hPa','700 hPa','800 hPa','900 hPa','Surface','Column']

  ;ymin = [-0.4,-0.4,-0.4,-0.4,-0.4,-0.4,-0.4,-0.4,-0.4,-1.]
  ;ymax = [ 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 1.]
  ;ymin = [-40.,-40.,-40.,-40.,-40.,-40.,-40.,-40.,-40.,-1.]
  ;ymax = [ 40., 40., 40., 40., 40., 40., 40., 40., 40., 1.]
  ymin = [-40.,-40.,-40.,-40.,-40.,-40.,-40.,-40.,-40.,-1.e18]
  ymax = [ 40., 40., 40., 40., 40., 40., 40., 40., 40., 1.e18]

  ;fit_label_y2 = [-0.333,-0.333,-0.333,-0.333,-0.333,-0.333,-0.333,-0.333,-0.333,-0.82]
  ;fit_label_y2 = [-33.3,-33.3,-33.3,-33.3,-33.3,-33.3,-33.3,-33.3,-33.3,-0.82]
  fit_label_y2 = [-33.3,-33.3,-33.3,-33.3,-33.3,-33.3,-33.3,-33.3,-33.3,-0.82e18]

  nlevs = n_elements(ilev_plot)

  ;;;;;;;;;;;;;; plot log-VMR retrieval bias at surface

  drift_str = strarr(nlevs)
  drift_uncy_str = strarr(nlevs)

  for ilev = 0, nlevs-1 do begin

    init_stats = 0

    if (ilev_plot(ilev) eq -1) then begin

      ;    plot, dates, dmy_data, yrange=[ymin(ilev),ymax(ilev)], ystyle=1, ytitle='CO total column bias', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = nyrs, xminor = 12, /nodata
      plot, dates, dmy_data, yrange=[ymin(ilev),ymax(ilev)], ystyle=1, ytitle='CO Total Colm Bias (mol/cm!U2!N)', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = nyrs, xminor = 12, /nodata

    endif else begin

      ;    plot, dates, dmy_data, yrange=[ymin(ilev),ymax(ilev)], ystyle=1, ytitle='log(VMR) bias', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = nyrs, xminor = 12, /nodata
      plot, dates, dmy_data, yrange=[ymin(ilev),ymax(ilev)], ystyle=1, ytitle='Relative Bias (%)', XTICKUNITS = ['Time'], xtickformat='LABEL_DATE', xticks = nyrs, xminor = 12, /nodata

    endelse

    for isite = 0, nsites-1 do begin

      ; first validation-mode run (radfix optimization run 8)
      ;    allfiles = 'val_L2_radfix_optmz/opt8/val_L2_v7.L2V17.9x.1.' + sitecodes(isite) + '.*.50km.dat'
      ;    allfiles = 'val_L2_radfix_optmz/opt9/val_L2_v8.L2V17.9x.1.' + sitecodes(isite) + '.*.50km.dat'
      allfiles = 'val_L2_radfix_optmz/opt10/val_L2_v8.L2V17.9x.1.' + sitecodes(isite) + '.*.50km.dat'

      ; TIR-only V7 OPS
      ;    allfiles = 'val_L2_radfix_optmz/v7t_ops/val_L2_v7.L2V17.8.1.' + sitecodes(isite) + '.*.50km.dat'
      ;    allfiles = 'val_L2_ops/v7t_ops/val_L2_v8.L2V17.x.1.' + sitecodes(isite) + '.*.50km.dat'

      ; NIR-only V7 OPS
      ;    allfiles = 'val_L2_radfix_optmz/v7n_ops/val_L2_v7.L2V17.8.2.' + sitecodes(isite) + '.*.50km.dat'
      ; JNT V7 OPS
      ;    allfiles = 'val_L2_radfix_optmz/v7j_ops/val_L2_v7.L2V17.8.3.' + sitecodes(isite) + '.*.50km.dat'

      ; NIR-only radfix tests
      ;    allfiles = 'val_L2_radfix_optmz/radfix_nir_opt1_thr1.000_modis6/val_L2_v7.L2V17.9x.2.' + sitecodes(isite) + '.*.50km.dat'
      ;    allfiles = 'val_L2_radfix_optmz/radfix_nir_opt2_thr1.000_modis6/val_L2_v7.L2V17.9x.2.' + sitecodes(isite) + '.*.50km.dat'
      ;    allfiles = 'val_L2_radfix_optmz/radfix_nir_opt3_thr1.000_modis6/val_L2_v7.L2V17.9x.2.' + sitecodes(isite) + '.*.50km.dat'
      ;    allfiles = 'val_L2_radfix_optmz/radfix_nir_opt4_thr1.000_modis6/val_L2_v7.L2V17.9x.2.' + sitecodes(isite) + '.*.50km.dat'

      ; JNT radfix tests
      ;    allfiles = 'val_L2_radfix_optmz/radfix_jnt_opt1_thr1.000_modis6/val_L2_v7.L2V17.9x.3.' + sitecodes(isite) + '.*.50km.dat'

      ;;;;;;;;;;;;;;;;;;;;; V8 OPS ;;;;;;;;;;;;;;;;;

      ; NOAA
      ;    allfiles = 'val_L2_ops/v8t_ops/val_L2_v8.L2V18.0.1.' + sitecodes(isite) + '.*.50km.dat'
      ;    allfiles = 'val_L2_ops/v8n_ops/val_L2_v8.L2V18.0.2.' + sitecodes(isite) + '.*.50km.dat'
      ;    allfiles = 'val_L2_ops/v8j_ops/val_L2_v8.L2V18.0.3.' + sitecodes(isite) + '.*.50km.dat'

      ; HIPPO, ATom, RTA, ...
      ;     allfiles = 'val_L2_ops/v7t_ops/val_L2_v7.L2V17.x.1.' + sitecodes(isite) + '.*.200km.dat'
      ;     allfiles = 'val_L2_ops/v8t_ops/val_L2_v8.L2V18.0.1.' + sitecodes(isite) + '.*.200km.dat'
      ;     allfiles = 'val_L2_ops/v8t_ops*/val_L2_v8.L2V18.0.1.' + sitecodes(isite) + '.*.200km.dat'
      ;     allfiles = 'val_L2_ops/v7t_ops*/val_L2_v*.L2V*.' + sitecodes(isite) + '.*.200km.dat'

      ; optimization expts
      ;     allfiles = 'val_L2_ops/v8t_ops/val_L2_v8.L2V18.0.1.' + sitecodes(isite) + '.*.100km.250hPa.dat'
      ;     allfiles = 'val_L2_ops/v8t_ops/val_L2_v8.L2V18.0.1.' + sitecodes(isite) + '.*.200km.250hPa.dat'

      ; MOPFAS PMC correction experiments

      ;    allfiles = 'val_L2_mopfas_corr/v8t/val_L2_v8.L2V18.1.1.' + sitecodes(isite) + '.*.50km.dat'

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      if (file_test(allfiles) eq 0) then continue

      spawn, ('ls ' + allfiles), valfiles

      nvalfiles = n_elements(valfiles)

      valjdy = lonarr(nvalfiles)
      logvmrbias = fltarr(nvalfiles)
      logvmrbias(*) = -999.

      if (ilev_plot(ilev) eq -1) then begin
        colm_bias_frac = fltarr(nvalfiles)
        colm_bias_frac(*) = -999.
      endif

      for ival = 0, nvalfiles-1 do begin

        if (ilev eq 0) then print, valfiles(ival)

        ; get julian day from filename

        tmp = strsplit(valfiles(ival),'.',/extract)
        ntmp = n_elements(tmp)

        ; slightly different filename formats for expts and OPS runs

        ; expts (HHMM field missing in filename)
        datestr = tmp(ntmp-3)
        ; OPS
        ;      datestr = tmp(ntmp-4)

        ; optimization experiments (extra '.' at end of filename)
        ;      datestr = tmp(ntmp-5)

        valyr = strmid(datestr,0,4)
        valmo = strmid(datestr,4,2)
        valdy = strmid(datestr,6,2)

        ;print, fix(valmo),fix(valdy),fix(valyr)

        ; exclude years not in period from 2008 to 2015 (for comparing w/ IASI)

        ;      if (valyr lt 2008 or valyr gt 2015) then continue
        ;      if (valyr lt 2008 or valyr gt 2017) then continue

        ; even years only

        ;      if ((fix(valyr) mod 2) eq 1) then continue

        valjdy(ival) = julday(fix(valmo),fix(valdy),fix(valyr))

        spawn, ('wc -l ' + valfiles(ival)), returnstring

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

        ;      print, min(isfc), max(isfc)
        ;      print, min(icld), max(icld)
        ;      print, min(dfs), max(dfs)

        ;;;;;;;;;;;;; begin data analysis ;;;;;;;;;;;

        if (ilev_plot(ilev) eq -1) then begin
          tmp1 = 1.e-18*rtvcolm
          tmp2 = 1.e-18*simcolm
        endif else begin
          tmp1 = reform(alldat(0,ilev_plot(ilev),*))
          tmp2 = reform(alldat(1,ilev_plot(ilev),*))
        endelse

        ; use L3 filtering rules (exclude pixel 3, and pixels where 5A SNR <
        ; 1000 AND 6A SNR < 400)

        ;    igd = where(tmp1 gt 0. and tmp2 gt 0. and pxl ne 3 and solza lt 90. and (snr5a ge 1000. or snr6a ge 400.), ngd)

        ; daytime and nighttime
        ;      igd = where(tmp1 gt 0. and tmp2 gt 0., ngd)
        ; daytime only
        igd = where(tmp1 gt 0. and tmp2 gt 0. and solza lt 80., ngd)
        ; nighttime only
        ;      igd = where(tmp1 gt 0. and tmp2 gt 0. and solza ge 80., ngd)

        ; daytime/land only
        ;      igd = where(tmp1 gt 0. and tmp2 gt 0. and solza lt 80. and isfc eq 1, ngd)

        ; MODIS clear only (icld = 2 or 3)
        ; daytime and nighttime
        ;      igd = where(rtv gt 0. and val gt 0. and ap gt 0. and (icld eq 2 or icld eq 3), ngd)
        ; daytime only
        ;      igd = where(rtv gt 0. and val gt 0. and ap gt 0. and solza lt 80. and (icld eq 2 or icld eq 3), ngd)
        ;      igd = where(rtv gt 0. and val gt 0. and ap gt 0. and solza lt 80. and (icld eq 2), ngd)
        ;      igd = where(rtv gt 0. and val gt 0. and ap gt 0. and solza lt 80. and icld gt -1, ngd)
        ; nighttime only
        ;      igd = where(rtv gt 0. and val gt 0. and ap gt 0. and solza ge 80. and (icld eq 2 or icld eq 3), ngd)

        ; daytime only, psfc > 900
        ;      igd = where(tmp1 gt 0. and tmp2 gt 0. and solza lt 80. and psfc gt 900., ngd)

        ;;; debugging section ;;;;

        ;      if (ilev eq 0) then begin
        ;        print, sitecodes(isite), valfiles(ival), nmatch, ngd
        ;      endif

        ;;;;;;

        ;      if (proflat lt latmin or proflat gt latmax) then continue

        if (ngd lt ngd_min) then continue

        ;    if (ngd gt 1) then begin

        if (ilev_plot(ilev) eq -1) then begin
          stats = moment(tmp1(igd) - tmp2(igd))
          stats1 = moment(100.*(tmp1(igd) - tmp2(igd))/tmp2(igd))
          ;        logvmrbias(ival) = stats(0)
          logvmrbias(ival) = 1.e18*stats(0)
          colm_bias_frac(ival) = stats1(0)
        endif else begin
          stats = moment(tmp1(igd) - tmp2(igd))
          logvmrbias(ival) = stats(0)
        endelse

        ;      plots, valjdy(ival), logvmrbias(ival), psym=sitesyms(isite), color=site_colors(isite), noclip=0

        if (ilev_plot(ilev) eq -1) then begin
          plots, valjdy(ival), logvmrbias(ival), psym=sitesyms(isite), color=site_colors(isite), noclip=0
        endif else begin
          plots, valjdy(ival), (100./0.4343)*logvmrbias(ival), psym=sitesyms(isite), color=site_colors(isite), noclip=0
          ;        plots, valjdy(ival), (100./0.4343)*logvmrbias(ival), psym=7, color=20, noclip=0
          ;          print, valjdy(ival), (100./0.4343)*logvmrbias(ival)
        endelse

        ;    endif

      endfor

      ;  ip2 = where(logvmrbias ne -999., np2)

      ; exclude early 'phase 1' period from analysis
      ip2 = where(logvmrbias ne -999. and valjdy gt julday(9,1,2001), np2)

      if (np2 lt 1) then continue

      if (ilev_plot(ilev) eq -1) then begin

        if (init_stats eq 0) then begin
          jdy_regrs = valjdy(ip2)
          logvmrbias_regrs = logvmrbias(ip2)
          colm_bias_regrs = colm_bias_frac(ip2)
          init_stats = 1
        endif else begin
          jdy_regrs = [jdy_regrs,valjdy(ip2)]
          logvmrbias_regrs = [logvmrbias_regrs,logvmrbias(ip2)]
          colm_bias_regrs = [colm_bias_regrs,colm_bias_frac(ip2)]
        endelse

      endif else begin

        if (init_stats eq 0) then begin
          jdy_regrs = valjdy(ip2)
          logvmrbias_regrs = logvmrbias(ip2)
          init_stats = 1
        endif else begin
          jdy_regrs = [jdy_regrs,valjdy(ip2)]
          logvmrbias_regrs = [logvmrbias_regrs,logvmrbias(ip2)]
        endelse

      endelse

    endfor

    ; calculate mean ph. 2 values and phase 2 trends for all data

    ;print, n_elements(jdy_regrs)

    if (n_elements(jdy_regrs) lt 2) then continue

    if (ilev_plot(ilev) eq -1) then begin

      ;fit_parms = poly_fit(jdy_regrs,logvmrbias_regrs,1,SIGMA=sigma)

      fit_parms = poly_fit(jdy_regrs,logvmrbias_regrs,1,SIGMA=sigma)

      ;print, lvl_lbl(ilev), fit_parms(0)+fit_parms(1)*julday(1,1,2000), fit_parms(1)

      plotx = [jday1,jday2]
      ploty = fit_parms(0) + fit_parms(1)*plotx

      oplot, plotx, ploty, linestyle=2


      ; print expected TC bias on jday2

      print, 'expected TC bias (from best-fit line) on jday2 = ', ploty(1)

      ; express slope and slope uncy for total column in 10^17 mol/cm2/yr
      ;slope = 10.*365.*fit_parms(1)
      ;slopeuncy = 10.*365.*sigma(1)
      slope = 365.*1.e-17*fit_parms(1)
      slopeuncy = 365.*1.e-17*sigma(1)

      ;print, slope
      ;print, slopeuncy

      ;slopestr = string(slope,format='(f7.4)')
      ;slopestr = strtrim(string(slope,format='(f6.3)'),2)
      ;slopeuncystr = strtrim(string(slopeuncy,format='(f6.3)'),2)
      drift_str(ilev) = strtrim(string(slope,format='(f6.3)'),2)
      drift_uncy_str(ilev) = strtrim(string(slopeuncy,format='(f6.3)'),2)

      ; express slope and slope uncy for total column in %/yr

      fit_parms = poly_fit(jdy_regrs,colm_bias_regrs,1,SIGMA=sigma)

      slope = 365.*fit_parms(1)
      slopeuncy = 365.*sigma(1)

      pct_drift_str = strtrim(string(slope,format='(f6.3)'),2)
      pct_drift_uncy_str = strtrim(string(slopeuncy,format='(f6.3)'),2)

      ;xyouts, julday(1,1,2001), fit_label_y2(ilev), 'Bias Drift = ' + slopestr + '!9 ' + String("261B) + ' !X' + slopeuncystr + ' (10!U17!N) mol/cm!U2!N/yr', charsize=0.8
      xyouts, julday(1,1,2001), fit_label_y2(ilev), 'Bias Drift = ' + drift_str(ilev) + '!9 ' + String("261B) + ' !X' + drift_uncy_str(ilev) + ' (10!U17!N) mol/cm!U2!N/yr', charsize=0.8

      ; calculate and print p values

      ;    r = correlate(val_save,rtv_save)
      r = correlate(jdy_regrs,logvmrbias_regrs)
      ;    df = n_elements(val_save) - 2
      df = n_elements(jdy_regrs) - 2
      t = r/sqrt((1.0-r*r)/FLOAT(df))
      p = 2.0 * (1.0 - T_PDF(ABS(t), df))

      print, lvl_lbl(ilev),'; p value = ', p


    endif else begin

      stats = moment(logvmrbias_regrs)

      biaspct = stats(0)*(100./0.4343)

      ;fit_parms = poly_fit(jdy_regrs,logvmrbias_regrs,1,SIGMA=sigma)
      fit_parms = poly_fit(jdy_regrs,(100./0.4343)*logvmrbias_regrs,1,SIGMA=sigma)

      ;print, lvl_lbl(ilev), fit_parms(0)+fit_parms(1)*julday(1,1,2000), fit_parms(1)

      plotx = [jday1,jday2]
      ploty = fit_parms(0) + fit_parms(1)*plotx

      oplot, plotx, ploty, linestyle=2

      ;slopepct = 365.*fit_parms(1)*(100./0.4343)
      ;slopepctuncy = 365.*sigma(1)*(100./0.4343)
      slopepct = 365.*fit_parms(1)
      slopepctuncy = 365.*sigma(1)

      ;slopepctstr = strtrim(string(slopepct,format='(f7.2)'),2)
      ;slopepctuncystr = strtrim(string(slopepctuncy,format='(f7.2)'),2)
      ;drift_str(ilev) = strtrim(string(slopepct,format='(f7.2)'),2)
      ;drift_uncy_str(ilev) = strtrim(string(slopepctuncy,format='(f7.2)'),2)
      drift_str(ilev) = strtrim(string(slopepct,format='(f8.3)'),2)
      drift_uncy_str(ilev) = strtrim(string(slopepctuncy,format='(f8.3)'),2)

      ;xyouts, julday(1,1,2001), fit_label_y2(ilev), 'Bias Drift = ' + slopepctstr + '!9 ' + String("261B) + ' !X' + slopepctuncystr + ' %/yr', charsize=0.8
      xyouts, julday(1,1,2001), fit_label_y2(ilev), 'Bias Drift = ' + drift_str(ilev) + '!9 ' + String("261B) + ' !X' + drift_uncy_str(ilev) + ' %/yr', charsize=0.8

      ; print fitting params in form logbias = logbias(1,1,2000) + dlogbias*(jday - jday(1,1,2000))

      logbias2000 = fit_parms(0) + fit_parms(1)*julday(1,1,2000)
      dlogbias = fit_parms(1)

      ;print, lvl_lbl(ilev), logbias2000, dlogbias

      ; print projected bias on 1/1/2000 (in %) and bias drift (in %/yr)

      ;biaspct_0 = (100./0.4343)*(fit_parms(0)+fit_parms(1)*julday(1,1,2000))
      biaspct_0 = fit_parms(0)+fit_parms(1)*julday(1,1,2000)

      print, lvl_lbl(ilev), '  biaspct(1/1/2000) = ', biaspct_0, '  biasdrift = ', slopepct

      ; calculate and print p values

      ;    r = correlate(val_save,rtv_save)
      r = correlate(jdy_regrs,logvmrbias_regrs)
      ;    df = n_elements(val_save) - 2
      df = n_elements(jdy_regrs) - 2
      t = r/sqrt((1.0-r*r)/FLOAT(df))
      p = 2.0 * (1.0 - T_PDF(ABS(t), df))

      print, lvl_lbl(ilev),'; corr coeff-based p value = ', p

      ; now calculate p value based on t test on the slope

      df = n_elements(jdy_regrs) - 2
      t = slopepct/slopepctuncy
      p = 2.0 * (1.0 - T_PDF(ABS(t), df))

      print, lvl_lbl(ilev),'; slope-based p value = ', p


    endelse

    ;xyouts, julday(5,1,2001), (0.833*(ymax(ilev) - ymin(ilev)) + ymin(ilev)), lvl_lbl(ilev), charsize=1.1
    xyouts, julday(1,1,2001), (0.75*(ymax(ilev) - ymin(ilev)) + ymin(ilev)), lvl_lbl(ilev), charsize=1.0

  endfor

  if (out ne 'x') then device, /close

  ; new code for generating latex-formatted table, e.g.,
  ;{}   & {drift} & {0.002 $\pm$ 0.001 (0.07 $\pm$ 0.07)} & {-0.27 $\pm$ 0.05} & {-0.40 $\pm$ 0.06} & {-0.04 $\pm$ 0.07} & {0.75 $\pm$ 0.09} & {0.72 $\pm$ 0.07}\\

  print, '{}    & {drift} & {' $
    + drift_str(9) + ' $\pm$ ' + drift_uncy_str(9) $
    + ' (' + pct_drift_str + ' $\pm$ ' + pct_drift_uncy_str + ')}' $
    + ' & {' + drift_str(8) + ' $\pm$ ' + drift_uncy_str(8) + '}' $
    + ' & {' + drift_str(6) + ' $\pm$ ' + drift_uncy_str(6) + '}' $
    + ' & {' + drift_str(4) + ' $\pm$ ' + drift_uncy_str(4) + '}' $
    + ' & {' + drift_str(2) + ' $\pm$ ' + drift_uncy_str(2) + '}' $
    + ' & {' + drift_str(0) + ' $\pm$ ' + drift_uncy_str(0) + '}\\'

    ; print to output file

    openw, 1, outfile

  for ilev = 0, nlevs-1 do begin

    printf, 1, format='(a8,2x,a8)', drift_str(ilev), drift_uncy_str(ilev)

  endfor

  close, 1


  return
end
 
