import numpy as np
import matplotlib.pyplot as plt
from scipy import stats
from scipy.stats import t as t_dist
from datetime import datetime, timedelta
import glob
import os

def plot_biasdrift_pct_9levs(debug_level=0):
    """
    Generates bias drift timeseries plot for 9 levels plus total column
    Adapted from IDL code originally by Merritt Deeter circa 03.2022
    Modifications by Sara Martinez-Alonso 08.2024
    
    Parameters
    ----------
    debug_level : int, optional
        Verbosity level for debug output (default=0)
        0 = No debug output
        1 = High-level progress
        2 = Medium-level detail
        3 = Full detail
    """
    
    # Helper function for conditional debug printing
    def dprint(message, level=1, indent=0):
        """Conditional debug print function"""
        if debug_level >= level:
            prefix = "  " * indent
            print(f"{prefix}{message}")
    
    dprint("=" * 60, level=1)
    dprint("Starting plot_biasdrift_pct_9levs()", level=1)
    dprint(f"DEBUG_LEVEL = {debug_level}", level=1)
    dprint("=" * 60, level=1)
    
    # Configuration parameters
    ngd_min = 5
    dprint(f"ngd_min = {ngd_min}", level=2)
    
    # Output file settings
    psfile = 'plot_biasdrift_pct_9levs.L2V17.9x.1.opt10.noaa2018.allcld.dy.eps'
    outfile = 'plot_biasdrift_pct_9levs.L2V17.9x.1.opt10.noaa2018.allcld.dy.dat'
    dprint(f"Output file: {psfile}", level=2)
    dprint(f"Output data file: {outfile}", level=2)
    
    out_format = 'eps'
    
    # Site codes and colors
    sitecodes = ['aao', 'acg', 'act', 'bne', 'car', 'cma', 'crv', 'dnd', 'esp', 
                 'etl', 'haa', 'hfm', 'hil', 'lef', 'nha', 'pfa', 'rta', 'sca', 
                 'sgp', 'tgc', 'thd', 'tom', 'wbi', 'wgc']
    
    nsites = len(sitecodes)
    site_colors = [120] * nsites
    sitesyms = [4] * nsites
    
    dprint(f"Processing {nsites} sites: {sitecodes}", level=2)
    
    # Date range setup
    jday1 = datetime(2000, 1, 1)
    jday2 = datetime(2020, 1, 1)
    
    # Create date array from jday1 to jday2
    dates = np.arange(jday1, jday2, timedelta(days=1)).astype(datetime)
    ndates = len(dates)
    dmy_data = np.zeros(ndates)
    
    dprint(f"Date range: {jday1} to {jday2}, ndates = {ndates}", level=2)
    
    # Calculate number of years for axis ticks
    nyrs = (jday2.year - jday1.year) + 1
    dprint(f"Number of years: {nyrs}", level=2)
    
    # Plot 9 levels plus total column
    ilev_plot = [8, 7, 6, 5, 4, 3, 2, 1, 0, -1]
    lvl_lbl = ['200 hPa', '300 hPa', '400 hPa', '500 hPa', '600 hPa', 
               '700 hPa', '800 hPa', '900 hPa', 'Surface', 'Column']
    
    ymin = [-40., -40., -40., -40., -40., -40., -40., -40., -40., -1.e18]
    ymax = [40., 40., 40., 40., 40., 40., 40., 40., 40., 1.e18]
    
    fit_label_y2 = [-33.3, -33.3, -33.3, -33.3, -33.3, -33.3, -33.3, -33.3, -33.3, -0.82e18]
    
    nlevs = len(ilev_plot)
    
    dprint(f"Number of levels to plot: {nlevs}", level=2)
    dprint(f"Level indices: {ilev_plot}", level=3)
    
    # Create figure with subplots (2 columns, 5 rows)
    fig, axes = plt.subplots(5, 2, figsize=(8, 8))
    axes = axes.flatten()
    dprint(f"Created figure with {len(axes)} subplots", level=2)
    
    # Initialize statistics arrays
    drift_str = [''] * nlevs
    drift_uncy_str = [''] * nlevs
    pct_drift_str = ''
    pct_drift_uncy_str = ''
    
    # Main level loop
    for ilev in range(nlevs):
        dprint(f"\nProcessing level {ilev}/{nlevs-1} (ilev_plot={ilev_plot[ilev]}, label='{lvl_lbl[ilev]}')", level=1)
        
        init_stats = 0
        ax = axes[ilev]
        
        # Initialize regression arrays for this level
        logvmrbias_regrs = np.array([])
        colm_bias_regrs = np.array([])
        jdy_regrs = np.array([])
        
        # Set up the subplot
        if ilev_plot[ilev] == -1:
            ax.set_ylabel('CO Total Colm Bias (mol/cm$^2$)')
        else:
            ax.set_ylabel('Relative Bias (%)')
        
        ax.set_xlabel('Year')
        ax.set_ylim(ymin[ilev], ymax[ilev])
        ax.grid(True, alpha=0.3)
        
        # Site loop
        for isite in range(nsites):
            dprint(f"Processing site {isite}/{nsites-1} ({sitecodes[isite]})", level=2, indent=1)
            
            # File pattern
            allfiles = f'/home/buchholz/MOPITTv10/MOPITT_Validation/validation_pairing/val_L2_v10.L2V19.9.2.{sitecodes[isite]}.*.50km.dat'
            dprint(f"File pattern: {allfiles}", level=3, indent=1)
            
            # Find matching files
            valfiles = glob.glob(allfiles)
            dprint(f"Found {len(valfiles)} matching files", level=2, indent=1)
            
            if len(valfiles) < 1:
                dprint(f"No files found for site {sitecodes[isite]}, skipping", level=2, indent=1)
                continue
            
            # Initialize arrays for this site
            nvalfiles = len(valfiles)
            valjdy = np.zeros(nvalfiles, dtype='datetime64[D]')
            logvmrbias = np.full(nvalfiles, -999., dtype=float)
            
            if ilev_plot[ilev] == -1:
                colm_bias_frac = np.full(nvalfiles, -999., dtype=float)
            else:
                colm_bias_frac = None  # FIX 1: Initialize for non-column case
            
            # File loop
            for ival in range(nvalfiles):
                if ilev == 0:
                    dprint(f"Processing file {ival}/{nvalfiles-1}: {valfiles[ival]}", level=3, indent=2)
                
                try:
                    # Extract date from filename
                    filename_parts = os.path.basename(valfiles[ival]).split('.')
                    ntmp = len(filename_parts)
                    # Date string is at ntmp-3 for expts or ntmp-4 for OPS
                    # Adjust based on your actual filename format
                    datestr = filename_parts[ntmp - 3]
                    
                    valyr = int(datestr[0:4])
                    valmo = int(datestr[4:6])
                    valdy = int(datestr[6:8])
                    
                    dprint(f"Date: {valyr}-{valmo:02d}-{valdy:02d}", level=3, indent=2)
                    
                    # Convert to datetime and numpy datetime64
                    try:
                        date_obj = datetime(valyr, valmo, valdy)
                        valjdy[ival] = np.datetime64(date_obj)
                    except ValueError as e:
                        dprint(f"Error parsing date {datestr}: {e}", level=2, indent=2)
                        logvmrbias[ival] = -999.
                        continue
                    
                    # Count lines in file
                    with open(valfiles[ival], 'r') as f:
                        nlines = sum(1 for _ in f)
                    
                    nmatch = (nlines - 1) // 6
                    
                    if nmatch < 1:
                        dprint(f"nmatch={nmatch} < 1, skipping file", level=2, indent=2)
                        logvmrbias[ival] = -999.
                        continue
                    
                    dprint(f"File has {nlines} lines, calculated nmatch = {nmatch}", level=3, indent=2)
                    
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
                    
                    # Read data file
                    with open(valfiles[ival], 'r') as f:
                        # Read profile info line
                        profinfo = np.array(f.readline().split(), dtype=float)
                        proflat = profinfo[0]
                        
                        dprint(f"Profile latitude = {proflat:.4f}", level=3, indent=2)
                        
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
                    
                    # Data analysis
                    if ilev_plot[ilev] == -1:
                        # Column data
                        tmp1 = 1.e-18 * rtvcolm
                        tmp2 = 1.e-18 * simcolm
                    else:
                        # Level-specific data
                        tmp1 = alldat[0, ilev_plot[ilev], :]
                        tmp2 = alldat[1, ilev_plot[ilev], :]
                    
                    # Filter good data: daytime only (solza < 80)
                    igd = np.where((tmp1 > 0) & (tmp2 > 0) & (solza < 80.))[0]
                    ngd = len(igd)
                    
                    dprint(f"Found {ngd} good data points (ngd_min={ngd_min})", level=2, indent=2)
                    
                    if ngd < ngd_min:
                        dprint(f"ngd={ngd} < ngd_min={ngd_min}, skipping", level=2, indent=2)
                        logvmrbias[ival] = -999.
                        continue
                    
                    # Calculate statistics
                    if ilev_plot[ilev] == -1:
                        # Column bias in 10^18 mol/cm2
                        stats_result = np.mean(tmp1[igd] - tmp2[igd])
                        logvmrbias[ival] = 1.e18 * stats_result
                        
                        # Column bias fraction
                        stats_frac = np.mean(100.0 * (tmp1[igd] - tmp2[igd]) / tmp2[igd])
                        colm_bias_frac[ival] = stats_frac
                        
                        dprint(f"logvmrbias[{ival}] = {logvmrbias[ival]:.6e}", level=3, indent=2)
                    else:
                        # VMR bias
                        stats_result = np.mean(tmp1[igd] - tmp2[igd])
                        logvmrbias[ival] = stats_result
                        
                        dprint(f"logvmrbias[{ival}] = {logvmrbias[ival]:.6f}", level=3, indent=2)
                    
                    # Plot point
                    date_float = valjdy[ival].astype('datetime64[D]').astype(int) / 365.25 + 1970.0  # FIX 2: Convert datetime64 to year
                    if ilev_plot[ilev] == -1:
                        ax.scatter(date_float, logvmrbias[ival], marker='x', 
                                 color=f'C{site_colors[isite]}', s=100)
                    else:
                        # Convert to percentage
                        bias_pct = (100. / 0.4343) * logvmrbias[ival]
                        ax.scatter(date_float, bias_pct, marker='x', 
                                 color=f'C{site_colors[isite]}', s=100)
                
                except Exception as e:
                    dprint(f"Error processing file: {e}", level=2, indent=2)
                    logvmrbias[ival] = -999.
                    continue
            
            # Filter valid data points from this site
            valid_indices = np.where(logvmrbias != -999.)[0]
            
            # Also exclude early 'phase 1' period (before 2001-09-01)
            phase1_date = np.datetime64('2001-09-01')
            phase2_indices = np.where((logvmrbias != -999.) & (valjdy > phase1_date))[0]
            
            if len(phase2_indices) < 1:
                dprint(f"No valid phase 2 data for site {sitecodes[isite]}, skipping", level=2, indent=1)
                continue
            
            dprint(f"Found {len(phase2_indices)} valid phase 2 data points", level=2, indent=1)
            
            # Convert datetime64 to years (decimal)
            valjdy_years = valjdy[phase2_indices].astype('datetime64[D]').astype(float)
            valjdy_years = valjdy_years / 365.25 + 1970.0  # FIX 3: Proper year conversion
            
            # Accumulate data for regression
            if ilev_plot[ilev] == -1:
                if init_stats == 0:
                    jdy_regrs = valjdy_years
                    logvmrbias_regrs = logvmrbias[phase2_indices]
                    colm_bias_regrs = colm_bias_frac[phase2_indices]
                    init_stats = 1
                else:
                    jdy_regrs = np.concatenate([jdy_regrs, valjdy_years])
                    logvmrbias_regrs = np.concatenate([logvmrbias_regrs, logvmrbias[phase2_indices]])
                    colm_bias_regrs = np.concatenate([colm_bias_regrs, colm_bias_frac[phase2_indices]])
            else:
                if init_stats == 0:
                    jdy_regrs = valjdy_years
                    logvmrbias_regrs = logvmrbias[phase2_indices]
                    init_stats = 1
                else:
                    jdy_regrs = np.concatenate([jdy_regrs, valjdy_years])
                    logvmrbias_regrs = np.concatenate([logvmrbias_regrs, logvmrbias[phase2_indices]])
        
        # Post-processing for this level
        dprint(f"\nPost-processing level {ilev}, init_stats={init_stats}", level=2, indent=1)
        
        if len(jdy_regrs) < 2:
            dprint(f"Not enough data points for regression (n={len(jdy_regrs)})", level=2, indent=1)
            continue
        
        # jdy_regrs is already in years (decimal)
        jdy_years = jdy_regrs
        
        if ilev_plot[ilev] == -1:
            # Column data processing
            dprint(f"Performing COLUMN data post-processing", level=2, indent=1)
            
            # Fit polynomial (linear regression)
            try:
                # FIX 4: Proper covariance extraction for uncertainty
                coeffs = np.polyfit(jdy_years, logvmrbias_regrs, 1)
                poly_cov = np.polyfit(jdy_years, logvmrbias_regrs, 1, cov=True)
                sigma = np.sqrt(np.diag(poly_cov[1]))  # Standard deviations of coefficients
                
                dprint(f"Polyfit coefficients: {coeffs}", level=3, indent=1)
                dprint(f"Coefficient uncertainties: {sigma}", level=3, indent=1)
                
                # Plot fit line
                plotx = np.array([jday1.year, jday2.year])
                ploty = coeffs[0] + coeffs[1] * plotx
                ax.plot(plotx, ploty, 'k--', linewidth=2)
                
                # Expected TC bias on jday2
                bias_on_jday2 = coeffs[0] + coeffs[1] * jday2.year
                dprint(f"Expected TC bias on {jday2.date()} = {bias_on_jday2:.6e}", level=2, indent=1)
                
                # Express slope in 10^17 mol/cm2/yr
                slope = 365.0 * 1.e-17 * coeffs[1]
                slopeuncy = 365.0 * 1.e-17 * sigma[1]
                
                drift_str[ilev] = f"{slope:.3f}"
                drift_uncy_str[ilev] = f"{slopeuncy:.3f}"
                
                dprint(f"slope = {slope:.6f} (10^17) mol/cm2/yr", level=2, indent=1)
                dprint(f"slopeuncy = {slopeuncy:.6f}", level=2, indent=1)
                
                # Fit percentage drift
                coeffs_pct = np.polyfit(jdy_years, colm_bias_regrs, 1)
                poly_cov_pct = np.polyfit(jdy_years, colm_bias_regrs, 1, cov=True)
                sigma_pct = np.sqrt(np.diag(poly_cov_pct[1]))
                
                slope_pct = 365.0 * coeffs_pct[1]
                slopeuncy_pct = 365.0 * sigma_pct[1]
                
                pct_drift_str = f"{slope_pct:.3f}"
                pct_drift_uncy_str = f"{slopeuncy_pct:.3f}"
                
                # Add text to plot
                text_y = fit_label_y2[ilev]
                ax.text(jday1.year + 1, text_y, 
                       f"Bias Drift = {drift_str[ilev]} ± {drift_uncy_str[ilev]} (10$^{{17}}$) mol/cm$^2$/yr",
                       fontsize=8)
                
                # Calculate and print p-value
                r = np.corrcoef(jdy_years, logvmrbias_regrs)[0, 1]
                df = len(jdy_years) - 2
                t_stat = r / np.sqrt((1.0 - r * r) / float(df))
                p_val = 2.0 * (1.0 - t_dist.cdf(abs(t_stat), df))
                
                dprint(f"{lvl_lbl[ilev]}; p-value = {p_val:.6f}", level=2, indent=1)
            
            except Exception as e:
                dprint(f"Error in column fitting: {e}", level=2, indent=1)
                continue
        
        else:
            # VMR data processing
            dprint(f"Performing VMR data post-processing", level=2, indent=1)
            
            try:
                # Convert to percentage
                logvmrbias_pct = (100.0 / 0.4343) * logvmrbias_regrs
                
                # Fit polynomial
                coeffs = np.polyfit(jdy_years, logvmrbias_pct, 1)
                poly_cov = np.polyfit(jdy_years, logvmrbias_pct, 1, cov=True)
                sigma = np.sqrt(np.diag(poly_cov[1]))
                
                dprint(f"Polyfit coefficients: {coeffs}", level=3, indent=1)
                
                # Plot fit line
                plotx = np.array([jday1.year, jday2.year])
                ploty = coeffs[0] + coeffs[1] * plotx
                ax.plot(plotx, ploty, 'k--', linewidth=2)
                
                slopepct = 365.0 * coeffs[1]
                slopepctuncy = 365.0 * sigma[1]
                
                drift_str[ilev] = f"{slopepct:.3f}"
                drift_uncy_str[ilev] = f"{slopepctuncy:.3f}"
                
                dprint(f"slopepct = {slopepct:.6f} %/yr", level=2, indent=1)
                dprint(f"slopepctuncy = {slopepctuncy:.6f}", level=2, indent=1)
                
                # Add text to plot
                text_y = fit_label_y2[ilev]
                ax.text(jday1.year + 1, text_y,
                       f"Bias Drift = {drift_str[ilev]} ± {drift_uncy_str[ilev]} %/yr",
                       fontsize=8)
                
                # Projected bias on 1/1/2000
                biaspct_0 = coeffs[0] + coeffs[1] * 2000.0
                dprint(f"{lvl_lbl[ilev]}; biaspct(1/1/2000) = {biaspct_0:.6f}; biasdrift = {slopepct:.6f}", level=2, indent=1)
                
                # Calculate p-values
                r = np.corrcoef(jdy_years, logvmrbias_regrs)[0, 1]
                df = len(jdy_years) - 2
                if df > 0:
                    t_stat = r / np.sqrt((1.0 - r * r) / float(df))
                    p_val = 2.0 * (1.0 - t_dist.cdf(abs(t_stat), df))
                    dprint(f"{lvl_lbl[ilev]}; corr coeff-based p-value = {p_val:.6f}", level=2, indent=1)
                    
                    # Slope-based p-value
                    if slopepctuncy != 0:
                        t_slope = slopepct / slopepctuncy
                        p_slope = 2.0 * (1.0 - t_dist.cdf(abs(t_slope), df))
                        dprint(f"{lvl_lbl[ilev]}; slope-based p-value = {p_slope:.6f}", level=2, indent=1)
                    else:
                        dprint(f"{lvl_lbl[ilev]}; slope uncertainty is zero", level=2, indent=1)
            
            except Exception as e:
                dprint(f"Error in VMR fitting: {e}", level=2, indent=1)
                continue
        
        # Add level label to plot
        label_y = 0.75 * (ymax[ilev] - ymin[ilev]) + ymin[ilev]
        ax.text(jday1.year + 0.5, label_y, lvl_lbl[ilev], fontsize=10, fontweight='bold')
    
    # Format the figure
    plt.suptitle('CO Bias Drift Analysis (9 Levels + Total Column)', fontsize=14)
    plt.tight_layout()
    
    # Save figure
    dprint(f"\nSaving figure as {psfile}", level=2)
    if out_format == 'eps':
        plt.savefig(psfile, format='eps', dpi=150)
        dprint(f"Successfully saved as EPS", level=2)
    elif out_format == 'ps':
        plt.savefig(psfile, format='ps', dpi=150)
        dprint(f"Successfully saved as PS", level=2)
    else:
        plt.show()
    
    plt.close()
    
    # Write output file
    dprint(f"Writing output data file: {outfile}", level=2)
    try:
        with open(outfile, 'w') as f:
            for ilev in range(nlevs):
                f.write(f"{drift_str[ilev]:8s}  {drift_uncy_str[ilev]:8s}\n")
        dprint(f"Successfully wrote output file", level=2)
    except Exception as e:
        dprint(f"Error writing output file: {e}", level=2)
    
    # Print LaTeX-formatted table
    print("\n" + "=" * 80)
    print("LaTeX-formatted output:")
    print("=" * 80)
    
    latex_output = (
        f"{{}}    & {{drift}} & {{{drift_str[9]} $\\pm$ {drift_uncy_str[9]} "
        f"({pct_drift_str} $\\pm$ {pct_drift_uncy_str})}} "
        f"& {{{drift_str[8]} $\\pm$ {drift_uncy_str[8]}}} "
        f"& {{{drift_str[6]} $\\pm$ {drift_uncy_str[6]}}} "
        f"& {{{drift_str[4]} $\\pm$ {drift_uncy_str[4]}}} "
        f"& {{{drift_str[2]} $\\pm$ {drift_uncy_str[2]}}} "
        f"& {{{drift_str[0]} $\\pm$ {drift_uncy_str[0]}}}\\\\"
    )
    print(latex_output)
    
    dprint("\n" + "=" * 60, level=1)
    dprint("Function completed successfully", level=1)
    dprint("=" * 60, level=1)

if __name__ == "__main__":
    """
    USAGE INSTRUCTIONS
    ==================
    
    This script generates bias drift timeseries plots from MOPITT CO validation data.
    
    To run with different debug levels:
    
    1. NO DEBUG OUTPUT (Silent, for production):
       python plot_biasdrift_pct_9levs.py
       
    2. HIGH-LEVEL PROGRESS ONLY (Quick verification):
       Uncomment the line with debug_level=1
       python plot_biasdrift_pct_9levs.py
       
    3. MEDIUM DETAIL (Typical debugging):
       Uncomment the line with debug_level=2
       python plot_biasdrift_pct_9levs.py
       
    4. FULL DETAIL (Deep debugging):
       Uncomment the line with debug_level=3
       python plot_biasdrift_pct_9levs.py
    
    Alternatively, import and call directly:
    
       from plot_biasdrift_pct_9levs import plot_biasdrift_pct_9levs
       
       # Silent run (default)
       plot_biasdrift_pct_9levs()
       
       # Show progress
       plot_biasdrift_pct_9levs(debug_level=1)
       
       # Show medium detail
       plot_biasdrift_pct_9levs(debug_level=2)
       
       # Full debugging
       plot_biasdrift_pct_9levs(debug_level=3)
    
    OUTPUT
    ======
    Generates an EPS file: plot_biasdrift_pct_9levs.L2V17.9x.1.opt10.noaa2018.allcld.dy.eps
    Generates a data file: plot_biasdrift_pct_9levs.L2V17.9x.1.opt10.noaa2018.allcld.dy.dat
    Contains 10 scatter plots (9 pressure levels + 1 total column) with trend lines
    Prints LaTeX-formatted table for publication
    """
    
    # Example usage with different debug levels
    
    # No debug output (default)
    plot_biasdrift_pct_9levs(debug_level=0)
    
    # High-level progress only
    # plot_biasdrift_pct_9levs(debug_level=1)
    
    # Medium detail
    # plot_biasdrift_pct_9levs(debug_level=2)
    
    # Full detail
    # plot_biasdrift_pct_9levs(debug_level=3)
