import numpy as np
import matplotlib.pyplot as plt
from scipy import stats
import glob
import os

def plot_vald_dlog_9levs_v10(debug_level=0):
    """
    Adapted to read output of val_L2_v9_hippo.pro
    Cleaned-up scatterplot code 2/1/18, plots 9 levels plus total column
    Generates validation scatterplots of (x_rtv - x_a)
    
    Parameters
    ----------
    debug_level : int, optional
        Verbosity level for debug output (default=0)
        0 = No debug output
        1 = High-level progress (function start/end, level processing)
        2 = Medium-level detail (files, statistics, plot operations)
        3 = Full detail (all data processing steps, array values)
    
    Debug Level System
    ------------------
    
    debug_level=0 (Default - Silent)
    - No debug output
    - Use this for production runs
    
    debug_level=1 (High-level)
    - Function start/end messages
    - Level processing progress
    - File save status
    - Use for quick verification that script runs
    
    debug_level=2 (Medium detail)
    - All from level 1, plus:
    - Site processing progress
    - File counts and data statistics
    - Plot initialization and point plotting
    - Correlation, bias, and standard deviation values
    - Use for typical debugging
    
    debug_level=3 (Full detail)
    - All from level 1-2, plus:
    - File patterns and date extraction
    - Array initialization details
    - Individual data point statistics
    - Array shapes and values
    - Polyfit coefficients
    - Use when deep debugging is needed
    
    Usage Examples
    --------------
    
    # Silent run (default)
    plot_vald_dlog_9levs_v10()
    
    # Just show progress
    plot_vald_dlog_9levs_v10(debug_level=1)
    
    # Show medium detail
    plot_vald_dlog_9levs_v10(debug_level=2)
    
    # Full debugging
    plot_vald_dlog_9levs_v10(debug_level=3)
    """
    
    # Helper function for conditional debug printing
    def dprint(message, level=1, indent=0):
        """
        Conditional debug print function
        
        Parameters
        ----------
        message : str
            Message to print
        level : int
            Minimum debug_level required to print this message
        indent : int
            Number of spaces to indent (0=base, 1=site loop, 2=file loop)
        """
        if debug_level >= level:
            prefix = "  " * indent
            print(f"{prefix}{message}")
    
    # DEBUG: Print start of function
    dprint("=" * 60, level=1)
    dprint("Starting plot_vald_dlog_9levs_v10()", level=1)
    dprint(f"DEBUG_LEVEL = {debug_level}", level=1)
    dprint("=" * 60, level=1)
    
    # Configuration parameters
    ngd_min = 5
    log10e = np.log10(np.e)
    dprint(f"ngd_min = {ngd_min}, log10e = {log10e:.6f}", level=2)
    
    # Site codes and colors
    sitecodes = ['etl', 'hfm']
    nsites = len(sitecodes)
    site_colors = [120] * nsites
    dprint(f"Processing {nsites} sites: {sitecodes}", level=2)
    dprint(f"Site colors: {site_colors}", level=2)
    
    # V8 OPS - TIR-only, no cloud filtering
    psfile = 'plot_vald_dlog_9levs.v10_ops_rebecca_test.noaa.eps'
    dprint(f"Output file: {psfile}", level=2)
    
    # Plot 9 levels plus total column
    ilev_plot = [8, 7, 6, 5, 4, 3, 2, 1, 0, -1]
    lvl_lbl = ['200 hPa', '300 hPa', '400 hPa', '500 hPa', '600 hPa', 
               '700 hPa', '800 hPa', '900 hPa', 'Surface', 'Column']
    
    plottitle = ''
    nlevs = len(ilev_plot)
    dprint(f"Number of levels to plot: {nlevs}", level=2)
    dprint(f"Level indices: {ilev_plot}", level=3)
    dprint(f"Level labels: {lvl_lbl}", level=3)
    
    # Plot settings
    out_format = 'eps'
    dlogvmrmax = 0.4
    dcolmax = 2.e18
    dprint(f"Output format: {out_format}", level=2)
    dprint(f"dlogvmrmax = {dlogvmrmax}, dcolmax = {dcolmax:.2e}", level=3)
    
    # Create figure with subplots (2 columns, 5 rows)
    fig, axes = plt.subplots(5, 2, figsize=(8, 8))
    axes = axes.flatten()
    dprint(f"Created figure with {len(axes)} subplots", level=2)
    
    bias_str = [''] * nlevs
    sdev_str = [''] * nlevs
    r_str = [''] * nlevs
    dprint(f"Initialized statistics arrays", level=3)
    
    # Main loop over levels
    for ilev in range(nlevs):
        dprint("\n" + "=" * 60, level=1)
        dprint(f"Processing level {ilev}/{nlevs-1} (ilev_plot={ilev_plot[ilev]}, label='{lvl_lbl[ilev]}')", level=1)
        dprint("=" * 60, level=1)
        
        nval = 0  # Counter for number of valid data points collected for this level
        iplot = 0  # Flag to initialize plot only once per level
        ax = axes[ilev]
        
        # Initialize saving arrays for this level
        rtv_save = []
        rtverr_save = []
        val_save = []
        dfs_save = []
        dprint(f"Initialized empty save arrays for level {ilev}", level=3)
        
        for isite in range(nsites):
            dprint(f"\nProcessing site {isite}/{nsites-1} ({sitecodes[isite]})", level=2, indent=1)
            
            # NOAA profiles file pattern
            allfiles = f'/IASI/home/buchholz/MOPITTv10/MOPITT_Validation/validation_pairing/val_L2_v10.L2V19.9.2.{sitecodes[isite]}.*.50km.dat'
            dprint(f"File pattern: {allfiles}", level=3, indent=1)
            
            # Find matching files
            valfiles = glob.glob(allfiles)
            dprint(f"Found {len(valfiles)} matching files", level=2, indent=1)
            
            if len(valfiles) < 1:
                dprint(f"No files found for site {sitecodes[isite]}, skipping", level=2, indent=1)
                continue
            
            for ival in range(len(valfiles)):
                dprint(f"Processing file {ival}/{len(valfiles)-1}: {valfiles[ival]}", level=3, indent=2)
                
                # Extract date from filename
                tmp = valfiles[ival].split('.')
                ntmp = len(tmp)
                datestr = tmp[ntmp - 4]
                valmo = datestr[4:6]
                dprint(f"Date string = {datestr}, month = {valmo}", level=3, indent=2)
                
                # Count lines in file to determine number of matches
                try:
                    with open(valfiles[ival], 'r') as f:
                        nlines = sum(1 for _ in f)
                    nmatch = (nlines - 1) // 6
                    dprint(f"File has {nlines} lines, calculated nmatch = {nmatch}", level=3, indent=2)
                except Exception as e:
                    dprint(f"Error counting lines: {e}", level=2, indent=2)
                    continue
                
                if nmatch < 1:
                    dprint(f"nmatch={nmatch} < 1, skipping file", level=2, indent=2)
                    continue
                
                # Initialize arrays
                alldat = np.zeros((5, 10, nmatch))
                rtvcolm = np.zeros(nmatch)
                simcolm = np.zeros(nmatch)
                apcolm = np.zeros(nmatch)
                wvcolm = np.zeros(nmatch)
                
                pxl = np.zeros(nmatch, dtype=int)
                str_arr = np.zeros(nmatch, dtype=int)
                isfc = np.zeros(nmatch, dtype=int)
                icld = np.zeros(nmatch, dtype=int)
                
                psfc = np.zeros(nmatch)
                solza = np.zeros(nmatch)
                dfs = np.zeros(nmatch)
                
                snr5a = np.zeros(nmatch)
                snr6a = np.zeros(nmatch)
                snr6r = np.zeros(nmatch)
                
                dprint(f"Initialized arrays for {nmatch} matches", level=3, indent=2)
                
                nheader = 20
                
                # Read data file
                try:
                    with open(valfiles[ival], 'r') as f:
                        # Read profile info line
                        profinfo = np.array(f.readline().split(), dtype=float)
                        proflat = profinfo[0]
                        dprint(f"Profile latitude = {proflat}", level=3, indent=2)
                        
                        # Read match data
                        for imatch in range(nmatch):
                            # Read header line
                            header = np.array(f.readline().split(), dtype=float)
                            
                            pxl[imatch] = int(header[0])
                            str_arr[imatch] = int(header[1])
                            isfc[imatch] = int(header[2])
                            icld[imatch] = int(header[3])
                            
                            psfc[imatch] = header[4]
                            solza[imatch] = header[5]
                            
                            rtvcolm[imatch] = header[7]
                            simcolm[imatch] = header[8]
                            apcolm[imatch] = header[9]
                            wvcolm[imatch] = header[10]
                            
                            dfs[imatch] = header[11]
                            snr5a[imatch] = header[12]
                            snr6a[imatch] = header[13]
                            snr6r[imatch] = header[14]
                            
                            # Read 5 lines of data (10 values each)
                            for irow in range(5):
                                tmp10 = np.array(f.readline().split(), dtype=float)
                                alldat[irow, 0:10, imatch] = tmp10[0:10]
                        
                        dprint(f"Successfully read {nmatch} match records", level=3, indent=2)
                
                except Exception as e:
                    dprint(f"Error reading {valfiles[ival]}: {e}", level=2, indent=2)
                    continue
                
                # Data analysis
                dprint(f"Analyzing data for ilev_plot={ilev_plot[ilev]}", level=3, indent=2)
                if ilev_plot[ilev] == -1:
                    # Column data analysis
                    rtv = rtvcolm.copy()
                    val = simcolm.copy()
                    ap = apcolm.copy()
                    dfs1 = dfs.copy()
                    dprint(f"Using column data (ilev_plot=-1)", level=3, indent=2)
                else:
                    # Level-specific data analysis
                    rtv = alldat[0, ilev_plot[ilev], :].copy()
                    val = alldat[1, ilev_plot[ilev], :].copy()
                    ap = alldat[2, ilev_plot[ilev], :].copy()
                    dprint(f"Using level {ilev_plot[ilev]} data", level=3, indent=2)
                
                # Filter good data: daytime and nighttime, ocean and land
                igd = np.where((rtv > 0) & (val > 0) & (ap > 0))[0]
                ngd = len(igd)
                dprint(f"Found {ngd} good data points (ngd_min={ngd_min})", level=2, indent=2)
                
                if ngd < ngd_min:
                    dprint(f"ngd={ngd} < ngd_min={ngd_min}, skipping", level=2, indent=2)
                    continue
                
                # Calculate statistics
                val_diff = val[igd] - ap[igd]
                val_mn = np.mean(val_diff)
                val_sd = np.std(val_diff)
                
                rtv_diff = rtv[igd] - ap[igd]
                rtv_mn = np.mean(rtv_diff)
                rtv_sd = np.std(rtv_diff)
                
                dprint(f"val_mn={val_mn:.6f}, val_sd={val_sd:.6f}", level=3, indent=2)
                dprint(f"rtv_mn={rtv_mn:.6f}, rtv_sd={rtv_sd:.6f}", level=3, indent=2)
                
                if ilev_plot[ilev] == -1:
                    # Column data plotting
                    dprint(f"Processing COLUMN data for plotting", level=3, indent=2)
                    if iplot == 0:
                        dprint(f"Initializing plot for level {ilev}", level=2, indent=2)
                        ax.set_xlim(-dcolmax, dcolmax)
                        ax.set_ylim(-dcolmax, dcolmax)
                        ax.set_xlabel('ΔCO total column, in-situ')
                        ax.set_ylabel('ΔCO total column, MOPITT')
                        ax.text(-0.85*dcolmax, 0.5*dcolmax, lvl_lbl[9], fontsize=10)
                        iplot = 1
                    
                    ax.scatter(val_mn, rtv_mn, marker='x', color=f'C{site_colors[isite]}', s=100)
                    ax.errorbar(val_mn, rtv_mn, yerr=rtv_sd, fmt='none', 
                               color=f'C{site_colors[isite]}', capsize=5)
                    dprint(f"Plotted point for site {isite}", level=3, indent=2)
                    
                    dfs_mn = np.mean(dfs1[igd])
                    dprint(f"dfs_mn = {dfs_mn:.6f}", level=3, indent=2)
                    
                    rtv_save.append(rtv_mn)
                    rtverr_save.append(rtv_sd)
                    val_save.append(val_mn)
                    dfs_save.append(dfs_mn)
                    nval += 1
                    dprint(f"Added to save arrays, nval={nval}", level=3, indent=2)
                
                else:
                    # VMR data plotting
                    dprint(f"Processing VMR data for plotting", level=3, indent=2)
                    if iplot == 0:
                        dprint(f"Initializing plot for level {ilev}", level=2, indent=2)
                        ax.set_xlim(-dlogvmrmax, dlogvmrmax)
                        ax.set_ylim(-dlogvmrmax, dlogvmrmax)
                        ax.set_xlabel('Δlog(VMR), in-situ')
                        ax.set_ylabel('Δlog(VMR), MOPITT')
                        ax.text(-0.85*dlogvmrmax, 0.5*dlogvmrmax, lvl_lbl[ilev], fontsize=10)
                        iplot = 1
                    
                    ax.scatter(val_mn, rtv_mn, marker='x', color=f'C{site_colors[isite]}', s=100)
                    ax.errorbar(val_mn, rtv_mn, yerr=rtv_sd, fmt='none',
                               color=f'C{site_colors[isite]}', capsize=5)
                    dprint(f"Plotted point for site {isite}", level=3, indent=2)
                    
                    rtv_save.append(rtv_mn)
                    rtverr_save.append(rtv_sd)
                    val_save.append(val_mn)
                    nval += 1
                    dprint(f"Added to save arrays, nval={nval}", level=3, indent=2)
        
        # Post-processing for each level
        dprint(f"\nPost-processing level {ilev}, nval={nval}", level=2, indent=1)
        if nval > 0:
            rtv_save = np.array(rtv_save)
            val_save = np.array(val_save)
            rtverr_save = np.array(rtverr_save)
            
            dprint(f"Converted save arrays to numpy arrays", level=3, indent=1)
            dprint(f"rtv_save shape: {rtv_save.shape}, val_save shape: {val_save.shape}", level=3, indent=1)
            
            if ilev_plot[ilev] == -1:
                # Column plot post-processing
                dprint(f"Performing COLUMN plot post-processing", level=2, indent=1)
                ax.plot([-dcolmax, dcolmax], [-dcolmax, dcolmax], 'k--', alpha=0.5)
                d10pct = 2.e17
                ax.plot([-dcolmax, dcolmax - d10pct], [-dcolmax + d10pct, dcolmax], 'k--', alpha=0.5)
                ax.plot([-dcolmax + d10pct, dcolmax], [-dcolmax, dcolmax - d10pct], 'k--', alpha=0.5)
                dprint(f"Plotted reference lines", level=3, indent=1)
                
                # Calculate correlation
                r = np.corrcoef(val_save, rtv_save)[0, 1]
                r_str[ilev] = f"{r:.2f}"
                dprint(f"Correlation r = {r:.4f}", level=2, indent=1)
                
                # Least squares fit
                try:
                    coeffs = np.polyfit(val_save, rtv_save, 1, w=1/rtverr_save)
                    dprint(f"Polyfit coefficients: {coeffs}", level=3, indent=1)
                    lsqx = np.linspace(-dcolmax, dcolmax, 100)
                    lsqy = coeffs[0] * lsqx + coeffs[1]
                    ax.plot(lsqx, lsqy, 'k--', linewidth=2)
                    dprint(f"Plotted least-squares fit line", level=3, indent=1)
                except Exception as e:
                    dprint(f"Error in polyfit: {e}", level=2, indent=1)
                
                # Bias in 10^17 mol/cm2
                bias_colm = np.mean(1.e-17 * (rtv_save - val_save))
                sdev_colm = np.std(1.e-17 * (rtv_save - val_save))
                bias_str[ilev] = f"{bias_colm:.1f}"
                sdev_str[ilev] = f"{sdev_colm:.1f}"
                dprint(f"bias_colm = {bias_colm:.4f} (10^17), sdev_colm = {sdev_colm:.4f}", level=2, indent=1)
                
                ax.text(0.25*dcolmax, -0.28*dcolmax, f"r = {r_str[ilev]}", fontsize=8)
                ax.text(0.25*dcolmax, -0.55*dcolmax, f"bias = {bias_str[ilev]} (10^17)", fontsize=8)
                ax.text(0.25*dcolmax, -0.82*dcolmax, f"sdev = {sdev_str[ilev]} (10^17)", fontsize=8)
            
            else:
                # VMR plot post-processing
                dprint(f"Performing VMR plot post-processing", level=2, indent=1)
                ax.plot([-dlogvmrmax, dlogvmrmax], [-dlogvmrmax, dlogvmrmax], 'k--', alpha=0.5)
                d10pct = 0.0414
                ax.plot([-dlogvmrmax, dlogvmrmax - d10pct], [-dlogvmrmax + d10pct, dlogvmrmax], 'k--', alpha=0.5)
                ax.plot([-dlogvmrmax + d10pct, dlogvmrmax], [-dlogvmrmax, dlogvmrmax - d10pct], 'k--', alpha=0.5)
                dprint(f"Plotted reference lines", level=3, indent=1)
                
                # Calculate correlation
                r = np.corrcoef(val_save, rtv_save)[0, 1]
                r_str[ilev] = f"{r:.2f}"
                dprint(f"Correlation r = {r:.4f}", level=2, indent=1)
                
                # Least squares fit
                try:
                    coeffs = np.polyfit(val_save, rtv_save, 1, w=1/rtverr_save)
                    dprint(f"Polyfit coefficients: {coeffs}", level=3, indent=1)
                    lsqx = np.linspace(-0.4, 0.4, 100)
                    lsqy = coeffs[0] * lsqx + coeffs[1]
                    ax.plot(lsqx, lsqy, 'k--', linewidth=2)
                    dprint(f"Plotted least-squares fit line", level=3, indent=1)
                except Exception as e:
                    dprint(f"Error in polyfit: {e}", level=2, indent=1)
                
                # Bias in percent
                bias_pct = 100.0 * np.mean(rtv_save - val_save) / log10e
                sdev_pct = 100.0 * np.std(rtv_save - val_save) / log10e
                bias_str[ilev] = f"{bias_pct:.1f}"
                sdev_str[ilev] = f"{sdev_pct:.1f}"
                dprint(f"bias_pct = {bias_pct:.4f}%, sdev_pct = {sdev_pct:.4f}%", level=2, indent=1)
                
                ax.text(0.4*dlogvmrmax, -0.28*dlogvmrmax, f"r = {r_str[ilev]}", fontsize=8)
                ax.text(0.4*dlogvmrmax, -0.55*dlogvmrmax, f"bias = {bias_str[ilev]} %", fontsize=8)
                ax.text(0.4*dlogvmrmax, -0.82*dlogvmrmax, f"sdev = {sdev_str[ilev]} %", fontsize=8)
        else:
            dprint(f"No valid data collected for level {ilev} (nval=0)", level=2, indent=1)
        
        ax.grid(True, alpha=0.3)
    
    # Add overall title
    dprint(f"\nAdding figure title and finalizing", level=2)
    fig.suptitle(plottitle, fontsize=14)
    plt.tight_layout()
    
    # Save figure
    dprint(f"Saving figure as {psfile}", level=2)
    if out_format == 'eps':
        plt.savefig(psfile, format='eps')
        dprint(f"Successfully saved as EPS", level=2)
    elif out_format == 'ps':
        plt.savefig(psfile, format='ps')
        dprint(f"Successfully saved as PS", level=2)
    else:
        plt.show()
    
    plt.close()
    
    dprint("\n" + "=" * 60, level=1)
    dprint("Function completed successfully", level=1)
    dprint("=" * 60, level=1)

if __name__ == "__main__":
    """
    USAGE INSTRUCTIONS
    ==================
    
    This script generates validation scatterplots from MOPITT CO retrieval data.
    
    To run with different debug levels:
    
    1. NO DEBUG OUTPUT (Silent, for production):
       python plot_vald_dlog_9levs_v10.py
       
    2. HIGH-LEVEL PROGRESS ONLY (Quick verification):
       Uncomment the line with debug_level=1
       python plot_vald_dlog_9levs_v10.py
       
    3. MEDIUM DETAIL (Typical debugging):
       Uncomment the line with debug_level=2
       python plot_vald_dlog_9levs_v10.py
       
    4. FULL DETAIL (Deep debugging):
       Uncomment the line with debug_level=3
       python plot_vald_dlog_9levs_v10.py
    
    Alternatively, import and call directly:
    
       from plot_vald_dlog_9levs_v10 import plot_vald_dlog_9levs_v10
       
       # Silent run (default)
       plot_vald_dlog_9levs_v10()
       
       # Show progress
       plot_vald_dlog_9levs_v10(debug_level=1)
       
       # Show medium detail
       plot_vald_dlog_9levs_v10(debug_level=2)
       
       # Full debugging
       plot_vald_dlog_9levs_v10(debug_level=3)
    
    OUTPUT
    ======
    Generates an EPS file: plot_vald_dlog_9levs.v10_ops_rebecca_test.noaa.eps
    Contains 10 scatter plots (9 pressure levels + 1 total column)
    
    DEBUG OUTPUT EXAMPLES
    ====================
    
    Level 0 (Silent):
       (No output)
    
    Level 1 (High-level):
       ============================================================
       Starting plot_vald_dlog_9levs_v10()
       DEBUG_LEVEL = 1
       ============================================================
       ============================================================
       Processing level 0/9 (ilev_plot=8, label='200 hPa')
       ============================================================
       ...
       ============================================================
       Function completed successfully
       ============================================================
    
    Level 2 (Medium detail):
       (All from level 1, plus:)
       Processing 2 sites: ['etl', 'hfm']
       Site colors: [120, 120]
       Output file: plot_vald_dlog_9levs.v10_ops_rebecca_test.noaa.eps
       
       Processing site 0/1 (etl)
       Found 3 matching files
       Processing file 0/2: /IASI/home/.../val_L2_v10.L2V19.9.2.etl.20140101.50km.dat
       Found 45 good data points (ngd_min=5)
       val_mn=0.012345, val_sd=0.067890
       rtv_mn=0.098765, rtv_sd=0.054321
       Plotted point for site 0
       Added to save arrays, nval=1
       
       Post-processing level 0, nval=1
       Performing VMR plot post-processing
       Correlation r = 0.8567
       bias_pct = 9.8765%, sdev_pct = 5.4321%
       ...
    
    Level 3 (Full detail):
       (All from level 1-2, plus:)
       File pattern: /IASI/home/.../val_L2_v10.L2V19.9.2.etl.*.50km.dat
       Date string = 20140101, month = 01
       File has 271 lines, calculated nmatch = 45
       Initialized arrays for 45 matches
       Profile latitude = 42.5234
       Using level 8 data
       val_mn=0.012345, val_sd=0.067890
       rtv_mn=0.098765, rtv_sd=0.054321
       Polyfit coefficients: [0.9876 0.0123]
       ...
    """
    
    # Example usage with different debug levels
    
    # No debug output (default)
    plot_vald_dlog_9levs_v10(debug_level=0)
    
    # High-level progress only
    # plot_vald_dlog_9levs_v10(debug_level=1)
    
    # Medium detail
    # plot_vald_dlog_9levs_v10(debug_level=2)
    
    # Full detail
    # plot_vald_dlog_9levs_v10(debug_level=3)
