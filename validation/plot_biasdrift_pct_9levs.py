#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue May 19 12:29:20 2026

@author: pauljeffery
"""

import numpy as np
import matplotlib.pyplot as plt
import glob
from datetime import datetime
from subprocess import check_output
from scipy.stats import t as t_dist

def wc(filename):
    '''define a function to check the length of the match files
    inputs:
        -filename: the file to be checked (string)
        
    returns:
        -number of lines in the file (integer)
    '''
    return int(check_output(["wc", "-l", filename]).split()[0])

def filter_site_codes(site_codes, site_info_file, lat_min = -90, lat_max = 90):
    '''define a function to check desired latitude band and filter the stations included in the analysis to just those within the band.
    inputs:
        -lat_min: the minimum latitude of the band (float/integer)
        -lat_max: the maximum latitude of the band (float/integer)
        -site_codes: list of all the site codes (string)
        -site_info_file: the csv file containing the site information (string)
        
    returns:
        -new_sites: a revised list of site codes that eliminates all outside of the band (string)
        -lat_str: a naming string for use specifying the latitude band used (string)
    '''
    if ((lat_min != -90) & (lat_max!=90)):
        site_name, site_lat = np.loadtxt(site_info_file, dtype='U3, float', delimiter =',', usecols=(0,1), unpack = True, skiprows=1)
        band_ind = np.where((site_lat >= lat_min) & (site_lat <= lat_max))[0]
        band_sites = site_name[band_ind]
        
        new_sites = []
        for site in site_codes:
            if len(np.where(site == band_sites)[0]) == 1:
                new_sites.append(site)
        site_codes = new_sites
            
    if ((lat_min == -90) & (lat_max==90)):
        lat_str =''
    elif ((lat_min == -90) & (lat_max==-60)):
        lat_str ='_s_pole'
    elif ((lat_min == -60) & (lat_max==-30)):
        lat_str ='_s_mlat'
    elif ((lat_min == -30) & (lat_max==0)):
        lat_str ='_s_trop'
    elif ((lat_min == -30) & (lat_max==30)):
        lat_str ='_tropic'
    elif ((lat_min == 0) & (lat_max==30)):
        lat_str ='_n_trop'
    elif ((lat_min == 30) & (lat_max==60)):
        lat_str ='_n_mlat'
    elif ((lat_min == 60) & (lat_max==30)):
        lat_str ='_n_pole'  
    
    return site_codes, lat_str

def plot_biasdrift_main(mop_prod, file_loc, file_str, site_codes, site_info_file, ngd_min, plot_type, weight_std_do, lat_str, igd_flag, relbias_max=40, colbias_max=1e18, mop_version = 'V10'): #plot 9 levels plus total column
    '''define main function for plotting the correlation
    inputs: 
        -mop_prod: the mopitt product to be examined (string)
        -file_loc: the location of the matched data (string)
        -file_str: the string format to match for the files (string)
        -site_codes: the list of site codes to be used for the analysis (string)
        -ngd_min: the minimum number of matches needed in a file for incorperation into the analysis (integer)
        -plot_type: the desired output file type (such as eps or png) (string)
        -weight_std_do: use the inverse square of the stdev as the weight for the drift calculation (string)
        -lat_str: a naming string for use specifying the latitude band used (string)
        -relbias_max: plot bounds for the relative bias, default is 40 (integer/float)
        -colbias_max: plot bounds for the column bias, default is 1e18 (integer/float)
        -mop_version: version of the MOPITT data used, only for the title (string)

    returns:
        -drift_arr: a np array with the drift at each of the 10 levels (200:900 hPa, surface, column), only valid for column (float)
        -drift_unc_arr: a np array with the standard error of the drift at each of the 10 levels (200:900 hPa, surface, column), only valid for column (float)
        -drift_perc_arr: a np array with the % drift at each of the 10 levels (200:900 hPa, surface, column) (float)
        -drift_perc_unc_arr: a np array with the standard error of the % drift at each of the 10 levels (200:900 hPa, surface, column) (float)
        -p_val_corr_arr: a np array with the p-value calculated for the data's correlation at each of the 10 levels (200:900 hPa, surface, column) (float)
        -p_val_slope_arr: a np array with the p_value calculated for the data's slope at each of the 10 levels (200:900 hPa, surface, column) (float)
    
    outputs:
        -10 panel plot of the correlation(eps/png figure)
        -.dat file with Latex formated table of drift (text file)
        
    other function dependencies: 
        -wc
        -filter_site_codes
    '''
    #define plot settings (levels)
    ilev_plot = [8,7,6,5,4,3,2,1,0,-1]
    lvl_lbl = ['200 hPa','300 hPa','400 hPa','500 hPa','600 hPa','700 hPa','800 hPa','900 hPa','Surface','Column']
    nlevs = len(ilev_plot)

    #define as both a datetime object and as a year fraction float the minimum plot date, the maximum plot date, and the transition point between the phase 1 (both sides) and phase 2 (side A) data
    min_date = datetime(2000, 1, 1)
    min_date_year_frac = int(min_date.year) + ((min_date-datetime(min_date.year, 1, 1)).days)/((datetime(min_date.year+1, 1, 1)-datetime(min_date.year, 1, 1)).days)
    max_date = datetime(2025, 3, 1)
    max_date_year_frac = int(max_date.year) + ((max_date-datetime(max_date.year, 1, 1)).days)/((datetime(max_date.year+1, 1, 1)-datetime(max_date.year, 1, 1)).days)
    phase_1_date = datetime(2001, 9, 1)
    phase_1_year_frac = int(phase_1_date.year) + ((phase_1_date-datetime(phase_1_date.year, 1, 1)).days)/((datetime(phase_1_date.year+1, 1, 1)-datetime(phase_1_date.year, 1, 1)).days)
      
    #define a vector for the fitted lines
    fit_x_dat = np.array([min_date.year, 1 + max_date.year])
    
    #define site code derived info (can toggle between each site being uniquely colored)
    n_sites = len(site_codes)
    #site_colors = plt.cm.hsv(np.linspace(0,1,n_sites)) #different colors per site  
    site_colors = plt.cm.hsv([0.44])    #uniform site colors
    
    #define naming convention for output file (first block is MOPITT product)
    if mop_prod == 'TIR':
        fname_key = 't'
    elif mop_prod == 'NIR':
        fname_key = 'n'
    elif mop_prod == 'Joint':
        fname_key = 'j'
    elif mop_prod == 'Trop':
        fname_key = 'tr'      
         
    #define figure details (name, panels, size) and output file
    if len(site_codes) > 1:
        fig_name = 'plot_biasdrift_pct_9levs.v10' + fname_key + lat_str + '.noaa.allcld.' + plot_type
        out_file = 'plot_biasdrift_pct_9levs.v10' + fname_key + lat_str + '.noaa.allcld.dat'
    else: #for single validation site
        fig_name = 'plot_biasdrift_pct_9levs.v10' + fname_key + lat_str + '.noaa.' + site_codes[0] + '.allcld.' + plot_type
        out_file = 'plot_biasdrift_pct_9levs.v10' + fname_key + lat_str + '.noaa.' + site_codes[0] + '.allcld.dat'        
    fig, axes = plt.subplots(5, 2, figsize=(8, 11))
    axes = axes.flatten()        
        
    #initialize arrays to hold data for return 
    drift_arr = np.zeros(nlevs)
    drift_unc_arr = np.empty(nlevs)
    drift_perc_arr = np.empty(nlevs)
    drift_perc_unc_arr = np.empty(nlevs)    
    p_val_corr_arr = np.zeros(nlevs)  
    p_val_slope_arr = np.zeros(nlevs)  

    #begin analysis, with the loop for the plot levels 
    for i_lev in range(nlevs):
        #initialize iterators for number of data points per level (nval), plot features (iplot), and init_stats (initiated stats arrays)
        nval = 0
        iplot = 0
        init_stats = 0
        
        #loop for each site
        for i_site in range(n_sites):
            #find the site files matching the site 
            site_filelist = sorted(glob.glob(file_loc + '/' + file_str + site_codes[i_site] + '.*.50km.dat'))
            
            #skip this iteration of the loop if no files found, otherwise find how many there are
            if len(site_filelist) < 1:
                continue
            else:
                nvalfiles = len(site_filelist)
                
            #set arrays to hold the mean and stdev of the log(vmr) bias of each file, as well as the year fraction for the file. for the column data this is not the log(vmr) bias but the column bias
            abs_bias_hold = np.ones(nvalfiles) * -999
            abs_bias_std_hold = np.ones(nvalfiles) * -999
            year_frac = np.zeros(nvalfiles)

            #set array to hold the mean and stdev of the column relative bias (the column absolute bias is stored in abs_bias_hold)
            if ilev_plot[i_lev] == -1:
                rel_bias_hold = np.ones(nvalfiles) * -999
                rel_bias_std_hold = np.ones(nvalfiles) * -999
    
            for i_file in range(nvalfiles):
                #find the number of matches within the file, abort loop if less than 1
                n_match = int((wc(site_filelist[i_file]) - 1) / 6)

                if n_match < 1:
                    continue 
            
                # Initialize arrays for all the data
                alldat = np.zeros((5, 10, n_match))
                rtvcolm = np.zeros(n_match)
                simcolm = np.zeros(n_match)
                apcolm = np.zeros(n_match)
                wvcolm = np.zeros(n_match)
                
                pxl = np.zeros(n_match, dtype=int)
                str_arr = np.zeros(n_match, dtype=int)
                isfc = np.zeros(n_match, dtype=int)
                icld = np.zeros(n_match, dtype=int)
                
                psfc = np.zeros(n_match)
                solza = np.zeros(n_match)
                dfs = np.zeros(n_match)
                
                snr5a = np.zeros(n_match)
                snr6a = np.zeros(n_match)
                snr6r = np.zeros(n_match)

                #read info from file and extract profile info
                with open(site_filelist[i_file], 'r') as f:
                    #extract latitude and time info (latitude not needed in this version but maintained)
                    prof_info = np.array(f.readline().split(), dtype = float)
                    #prof_lat = prof_info[0]
                    prof_yr = int(prof_info[2])
                    prof_mn = int(prof_info[3])
                    prof_dy = int(prof_info[4])
                    
                    #create year fraction for this file
                    year_frac[i_file] = prof_yr + ((datetime(prof_yr, prof_mn, prof_dy)-datetime(prof_yr, 1, 1)).days)/((datetime(prof_yr+1, 1, 1)-datetime(prof_yr, 1, 1)).days)
                    
                    #loop for number of matches and extract data from file
                    for i_match in range(n_match):
                        header = np.array(f.readline().split(), dtype = float)
                        
                        pxl[i_match] = int(header[0])
                        str_arr[i_match] = int(header[1])
                        isfc[i_match] = int(header[2])
                        icld[i_match] = int(header[3])
                        
                        psfc[i_match] = header[4]
                        solza[i_match] = header[5]
                        
                        rtvcolm[i_match] = header[7]
                        simcolm[i_match] = header[8]
                        apcolm[i_match] = header[9]
                        wvcolm[i_match] = header[10]
                        
                        dfs[i_match] = header[11]
                        snr5a[i_match] = header[12]
                        snr6a[i_match] = header[13]
                        snr6r[i_match] = header[14]

                        #read all the lines of the data field in
                        for i_row in range(5):
                            alldat[i_row, :, i_match] = np.array(f.readline().split(), dtype = float)
                
                #pull data for the level of interest, handling differently the column and profile info. The apriori (ap) is unused but read in for consistecny 
                if ilev_plot[i_lev] == -1:
                    rtv = rtvcolm * 1e-18
                    sim = simcolm * 1e-18
                    ap = apcolm 
                else:
                    rtv = alldat[0, ilev_plot[i_lev], :]
                    sim = alldat[1, ilev_plot[i_lev], :]
                    ap = alldat[2, ilev_plot[i_lev], :]
                
                #filter data based on specified filter flag 
                if igd_flag == 'sza':
                    #apply quality filter for daytime and nighttime, ocean and land, needs non-zero values for retrieval, simulated and a solar zenith angle less than 80 degrees
                    igd = np.where((rtv > 0) & (sim > 0) & (solza < 80))[0]                    
                
                elif igd_flag == 'basic':
                    #apply quality filter for daytime and nighttime, ocean and land, needs non-zero values for retrieval, simulated and a solar zenith angle less than 80 degrees
                    igd = np.where((rtv > 0) & (sim > 0) & (ap > 0))[0]
                
                elif igd_flag == 'both':
                    #apply quality filter for daytime and nighttime, ocean and land, needs non-zero values for retrieval, simulated and a solar zenith angle less than 80 degrees
                    igd = np.where((rtv > 0) & (sim > 0) & (solza < 80) & ((ap > 0)))[0] 
                
                else:
                    #apply quality filter for daytime and nighttime, ocean and land, needs non-zero values for retrieval, simulated and a solar zenith angle less than 80 degrees
                    igd = np.where((rtv > 0) & (sim > 0))[0]                    

                #check if there's enough good data points
                if len(igd) < ngd_min:
                    continue
                
                #calculate mean and stdev for the file data. If column data get the mean and stdev of the absilute and relative diff, otherwise just the absolute difference 
                if ilev_plot[i_lev] == -1:
                    abs_bias_hold[i_file] = 1e18 * np.mean(rtv[igd] - sim[igd])
                    abs_bias_std_hold[i_file] = 1e18 * np.std(rtv[igd] - sim[igd])
                    rel_bias_hold[i_file] = np.mean(100 * (rtv[igd] - sim[igd]) / sim[igd])
                    rel_bias_std_hold[i_file] = np.std(100 * (rtv[igd] - sim[igd]) / sim[igd])
                else:
                    abs_bias_hold[i_file] = np.mean(rtv[igd] - sim[igd])
                    abs_bias_std_hold[i_file] = np.std(rtv[igd] - sim[igd])
                
                #currently unused iterator, but keeps track of the number of matched files per vertical level with sufficient data points (igd) 
                nval += 1            

            #having now read in all the data for the site, plot the data. 
            #First if it's column data then if its profile data
            if ilev_plot[i_lev] == -1:
                #setup figure limits, axis ticks, and labels if first site to plot
                if iplot == 0:
                    axes[i_lev].set_xlim(min_date.year, max_date.year+1)
                    axes[i_lev].set_ylim(-colbias_max, colbias_max)
                    axes[i_lev].set_xlabel('Year')
                    axes[i_lev].set_ylabel('Total column bias (molec/cm$^{-2}$)')
                    axes[i_lev].tick_params(axis='x', which = 'both', top=True)
                    axes[i_lev].tick_params(axis='y',  which = 'both', right=True)
                    axes[i_lev].set_xticks(ticks = np.arange(min_date.year, max_date.year), minor=True)
                    axes[i_lev].set_yticks(ticks = np.arange(-colbias_max, colbias_max, 0.1e18), minor=True)
                    
                    #update iterator to stop repeating this setup
                    iplot += 1

                #plot data (commented out line adds errorbars)
                axes[i_lev].scatter(year_frac, abs_bias_hold, marker = 'D', color = site_colors[i_site], s = 50)
                #axes[i_lev].errorbar(year_frac, abs_bias_hold, yerr = abs_bias_std_hold, fmt = 'none', color = site_colors[i_site], capsize = 5)

            #plot for the profile
            else:
                #setup figure limits and labels
                if iplot == 0:
                    axes[i_lev].set_xlim(min_date.year, max_date.year+1)
                    axes[i_lev].set_ylim(-relbias_max, relbias_max)
                    axes[i_lev].set_xlabel('Year')
                    axes[i_lev].set_ylabel('Relative bias (%)')
                    axes[i_lev].tick_params(axis='x', which = 'both', top=True)
                    axes[i_lev].tick_params(axis='y',  which = 'both', right=True)
                    axes[i_lev].set_xticks(ticks = np.arange(min_date.year, max_date.year), minor=True)
                    axes[i_lev].set_yticks(ticks = np.arange(-relbias_max, relbias_max, 5), minor=True)
                    
                    #update iterator to stop repeating this setup
                    iplot += 1
                
                #plot data (commented out line adds errorbars). NOTE the scaling factor to change this data to a percent difference between the two sets of data (see Deeter et al. 2017)
                axes[i_lev].scatter(year_frac, abs_bias_hold * 100 / (np.log10(np.e)), marker = 'D', color = site_colors[i_site], s = 50)
                #axes[i_lev].errorbar(year_frac, abs_bias_hold, yerr = abs_bias_std_hold * 100 / (np.log10(np.e)), fmt = 'none', color = site_colors[i_site], capsize = 5)

            #the drift will only be calculated for the phase 2 data, so find the phase 2 data that's not a fill value (-999)
            v_ind = np.where((year_frac > phase_1_year_frac) & (abs_bias_hold != -999))[0]
            
            #if there's no phase 2 good data skip the following data assignment steps of the loop 
            if len(v_ind)<1:
                continue
            
            #if this is the first assignement of data between sites, initialize arrays to hold the good data, otherwise just concatenate them 
            if init_stats == 0:
                year_frac_all = year_frac[v_ind]
                abs_bias_all = abs_bias_hold[v_ind]
                abs_bias_std_all = abs_bias_std_hold[v_ind]
                if ilev_plot[i_lev] == -1:
                    rel_bias_all = rel_bias_hold[v_ind]
                    rel_bias_std_all = rel_bias_std_hold[v_ind]
                init_stats += 1
            else:
                year_frac_all = np.concatenate([year_frac_all, year_frac[v_ind]])
                abs_bias_all = np.concatenate([abs_bias_all, abs_bias_hold[v_ind]])
                abs_bias_std_all = np.concatenate([abs_bias_std_all, abs_bias_std_hold[v_ind]])
                if ilev_plot[i_lev] == -1:
                    rel_bias_all = np.concatenate([rel_bias_all, rel_bias_hold[v_ind]])
                    rel_bias_std_all = np.concatenate([rel_bias_std_all, rel_bias_std_hold[v_ind]])

        #skip rest of loop (calculation of drift and p-value) if less than 2 good data points
        if len(year_frac_all) < 2:
            continue
        
        #do caluclations for the column
        if ilev_plot[i_lev] == -1:
            #fit the data to calculate drift in terms of 10^17 mol/cm2 per year . use weigths if flagged to do so, assigned as inverse of the std bias. pval has the fit coefficients and covariance
            if weight_std_do == 'yes':
                pval = np.polyfit(year_frac_all, abs_bias_all * 1e-17, 1, w=1 / (abs_bias_std_all * 1e-17), cov=True)
            else:
                pval = np.polyfit(year_frac_all, abs_bias_all * 1e-17, 1, cov=True)

            #assign and scale the fit coefficients (to coeffs) and caluc;ate and scale the error of the fit (fit_err). Print them out
            coeffs = pval[0] * 1e17
            fit_err = np.sqrt(np.diag(pval[1])) * 1e17
            print(f"Polyfit coefficients for absolute (10^17 mol/cm2) drift: {coeffs} +- {fit_err}")
            
            #plot a zero line and then the fit of the drift
            axes[i_lev].plot(fit_x_dat, [0, 0], color = 'k', alpha = 0.4)
            axes[i_lev].plot(fit_x_dat, coeffs[0] * fit_x_dat + coeffs[1], color = 'k', linestyle = '--')
            
            #for consistency with IDL program, calculate and print the expected bias at the start and end of the period 
            min_date_bias = (min_date_year_frac * coeffs[0] + coeffs[1]) * 1e-17
            max_date_bias = (max_date_year_frac * coeffs[0] + coeffs[1]) * 1e-17
            print(f"Expected bias on {min_date} is {min_date_bias:.3f} x10^17 mol/cm2.")
            print(f"Expected bias on {max_date} is {max_date_bias:.3f} x10^17 mol/cm2.")
            print(f"Drift is {1e-17 * coeffs[0]:.3f} +- {1e-17 * fit_err[0]:.3f} x10^17 mol/cm2/yr.")
            
            #express slope and its uncertainty for the total column in 10^17 mol/cm2 per year format, store for output
            drift_arr[i_lev] = 1e-17 * coeffs[0]
            drift_unc_arr[i_lev] = 1e-17 * fit_err[0]
            
            #add to the plot the drift  and add the label for the vertical level as well as numberof points
            axes[i_lev].text(phase_1_year_frac, -0.82 * colbias_max, f'Bias drift = {drift_arr[i_lev]:.3f} $\pm$ {drift_unc_arr[i_lev]:.3f} x10$^{{17}}$ molec cm$^{{-2}}$ yr$^{{-1}}$', fontsize=8)
            axes[i_lev].text(phase_1_year_frac, 0.7 * colbias_max, lvl_lbl[i_lev], fontsize=12)
            axes[i_lev].text(phase_1_year_frac, 0.45 * colbias_max, f'N = {nval}', fontsize=10)


            #repeat the above calculation for drift for a percent difference
            if weight_std_do == 'yes':
                pval = np.polyfit(year_frac_all, rel_bias_all, 1, w=1 / rel_bias_std_all, cov=True)
            else:
                pval = np.polyfit(year_frac_all, rel_bias_all, 1, cov=True)

            #assign the fit coefficients (to coeffs) and caluclate the error of the fit (fit_err). Print them out
            coeffs = pval[0]
            fit_err = np.sqrt(np.diag(pval[1]))    
            print(f"Polyfit coefficients for relative (%) drift: {coeffs} +- {fit_err}")

            #for consistency with IDL program, calculate and print the expected bias at the start and end of the period as a %
            min_date_bias = (min_date_year_frac * coeffs[0] + coeffs[1]) 
            max_date_bias = (max_date_year_frac * coeffs[0] + coeffs[1]) 
            print(f"Expected bias on {min_date} is {min_date_bias:.3f} %.")
            print(f"Expected bias on {max_date} is {max_date_bias:.3f} %")
            print(f"Drift is {coeffs[0]:.3f} +- {fit_err[0]:.3f} % yr$^{{-1}}")

            #express slope and its standard error for the total column in % per year format, store for output
            drift_perc_arr[i_lev] = coeffs[0]
            drift_perc_unc_arr[i_lev] = fit_err[0]
            
            #calculate and print the p value for the correlation. Assign p value to output array
            r = np.corrcoef(year_frac_all, abs_bias_all*1e-17)[0,1]
            df = len(year_frac_all) - 2
            t_stat = r * np.sqrt((df) / (1-(r**2)))
            p = 2 * (1 - t_dist.cdf(abs(t_stat), df))
            print(f"{lvl_lbl[i_lev]}: p-value of correlation is {p:.3f}")
            p_val_corr_arr[i_lev] = p
            
            #calculate and print p value based on t test of slope. Assign p value to output array
            t_stat = drift_arr[i_lev] / drift_unc_arr[i_lev]
            p = 2 * (1 - t_dist.cdf(abs(t_stat), df))
            print(f"{lvl_lbl[i_lev]}: p-value of slope is {p:.3f}")     
            p_val_slope_arr[i_lev] = p
            
        else:
            #fit the data to calculate drift in terms of % per year . use weigths if flagged to do so, assigned as inverse of the std bias. pval has the fit coefficients and covariance. data are sclaed following Deeter et al (2017) for a % diff
            if weight_std_do == 'yes':
                pval = np.polyfit(year_frac_all, abs_bias_all * 100 / (np.log10(np.e)), 1, w=1 / (abs_bias_std_all * 100 / (np.log10(np.e))), cov=True)
            else:
                pval = np.polyfit(year_frac_all, abs_bias_all * 100 / (np.log10(np.e)), 1, cov=True)

            #assign the fit coefficients (to coeffs) and caluclate the error of the fit (fit_err). Print them out
            coeffs = pval[0]
            fit_err = np.sqrt(np.diag(pval[1]))
            print(f"Polyfit coefficients for relative (%) drift {coeffs} +- {fit_err}")

            #plot a zero line and then the fit of the drift
            axes[i_lev].plot(fit_x_dat, [0, 0], color = 'k', alpha = 0.4)
            axes[i_lev].plot(fit_x_dat, coeffs[0] * fit_x_dat + coeffs[1], color = 'k', linestyle = '--')
            
            #for consistency with IDL program, calculate and print the expected bias at the start and end of the period 
            min_date_bias = (min_date_year_frac * coeffs[0] + coeffs[1])
            max_date_bias = (max_date_year_frac * coeffs[0] + coeffs[1])
            print(f"Expected bias on {min_date} is {min_date_bias:.3f} %.")
            print(f"Expected bias on {max_date} is {max_date_bias:.3f} %")
            print(f"Drift is {coeffs[0]:.3f} +- {fit_err[0]:.3f} % yr$^{{-1}}$")

            #express slope and its uncertainty for the total column in % per year format, store for output
            drift_perc_arr[i_lev] = coeffs[0]
            drift_perc_unc_arr[i_lev] = fit_err[0]            
            
            #add to the plot the drift  and add the label for the vertical level as well as number o fpoints
            axes[i_lev].text(phase_1_year_frac, -0.82 * relbias_max, f'Bias drift = {drift_perc_arr[i_lev]:.3f} $\pm$ {drift_perc_unc_arr[i_lev]:.3f} % yr$^{{-1}}$', fontsize=10)
            axes[i_lev].text(phase_1_year_frac, 0.7 * relbias_max, lvl_lbl[i_lev], fontsize=12)
            axes[i_lev].text(phase_1_year_frac, 0.45 * relbias_max, f'n = {nval}', fontsize=10)

            #calculate and print the p value for the correlation. Assign p value to output array
            r = np.corrcoef(year_frac_all, abs_bias_all)[0,1]
            df = len(year_frac_all) - 2
            t_stat = r * np.sqrt((df) / (1-(r**2)))
            p = 2 * (1 - t_dist.cdf(abs(t_stat), df))
            print(f"{lvl_lbl[i_lev]}: p-value of correlation is {p:.3f}")
            p_val_corr_arr[i_lev] = p

            #calculate and print p value based on t test of slope. Assign p value to output array
            t_stat = coeffs[0] / fit_err[0]
            p = 2 * (1 - t_dist.cdf(abs(t_stat), df))
            print(f"{lvl_lbl[i_lev]}: p-value of slope is {p:.3f}")     
            p_val_slope_arr[i_lev] = p

    #add figure title and save figure
    fig.suptitle(mop_version + ' ' + mop_prod, fontsize = 18)
    plt.tight_layout()
    plt.savefig(fig_name, format = plot_type)
    plt.close()
   
    #print LaTeX formatted table to output file 
    with open(out_file, 'w') as f:
        f.write(f"N = {nval}\n")
        f.write('\n\n\n')

        f.write("Level & Drift & p-value\\\\ \n")
        f.write("\\hline \n")
        for i_lev in range(nlevs):
            if ilev_plot[i_lev] == -1:
                f.write(f"{lvl_lbl[i_lev]} & {drift_perc_arr[i_lev]:.3f} $\\pm$ {drift_perc_unc_arr[i_lev]:.3f} \% yr$^{{-1}}$ & {p_val_slope_arr[i_lev]:.3f} \\\\ \n")
                f.write(f"{lvl_lbl[i_lev]} & {drift_arr[i_lev]:.3f} $\\pm$ {drift_unc_arr[i_lev]:.3f} x10$^{{17}}$ molec cm$^{{-2}}$ yr$^{{-1}}$ & {p_val_slope_arr[i_lev]:.3f} \\\\ \n")
            else:
                f.write(f"{lvl_lbl[i_lev]} & {drift_perc_arr[i_lev]:.3f} $\\pm$ {drift_perc_unc_arr[i_lev]:.3f} \% yr$^{{-1}}$ & {p_val_slope_arr[i_lev]:.3f} \\\\ \n")
    
        f.write('\n\n\n')
        f.write(" & Column & Surface & 800 hPa & 600 hPa & 400 hPa & 200 hPa \\\\ \n")
        f.write("\\hline \n")
        f.write(f" Drift & {drift_arr[9]:.2f} x10$^{{17}}$ molec cm$^{{-2}}$ yr$^{{-1}}$  & {drift_perc_arr[8]:.2f} \% yr$^{{-1}}$ & {drift_perc_arr[6]:.2f} \% yr$^{{-1}}$ & {drift_perc_arr[4]:.2f} \% yr$^{{-1}}$ & {drift_perc_arr[2]:.2f} \% yr$^{{-1}}$ & {drift_perc_arr[0]:.2f} \% yr$^{{-1}}$ \\\\ \n")
        f.write(f" Drift Unc & {drift_unc_arr[9]:.2f} x10$^{{17}}$ molec cm$^{{-2}}$ yr$^{{-1}}$  & {drift_perc_unc_arr[8]:.2f} \% yr$^{{-1}}$ & {drift_perc_unc_arr[6]:.2f} \% yr$^{{-1}}$ & {drift_perc_unc_arr[4]:.2f} \% yr$^{{-1}}$ & {drift_perc_unc_arr[2]:.2f} \% yr$^{{-1}}$ & {drift_perc_unc_arr[0]:.2f} \% yr$^{{-1}}$ \\\\ \n")

    #return output arrays
    return drift_arr, drift_unc_arr, drift_perc_arr, drift_perc_unc_arr, p_val_corr_arr, p_val_slope_arr

if __name__ == "__main__":
    '''generates bias drift plots for 9 levels plus total column'''
    
    #define mopitt product to use and the file location and formatting
    mop_prod = 'TIR'
    file_loc = '/Users/pauljeffery/Downloads/mopittv10-main/sample_pairing'
    file_str = 'val_L2_v10.L2V19.9.2.'
    
    #file of noaa site information (can leave blank if lat_min and lat_max are +- 90)
    site_info_file = '/Users/pauljeffery/Downloads/NOAA_locations.csv'
    
    #define site code list and resulting values
    site_codes = ['bne']
    
    #running parameters for the number of matches within each file needed 
    ngd_min = 5    
    
    #define figure details for output
    plot_type = 'png' #should be eps for publication
    
    #select whether or not to use weights (assigned as the inverse stdev of the data) in fitting the data, originally not done 
    weight_std_do = 'yes'
    
    #outside of the ngd_min filter, there is a second filter for data. For example, it has been used for cloud filtering. For the correlation IDL program default was nonzero retrieved column, nonzero simulated column, and nonzero a priori. 
    #This bias program defaulted to nonzero retrieved column, nonzero simulated column, and solar zenith angle (solza) less than 80 deg. Here we create a flag for this to try to ensure both programs are run identically. 
    #The options so far are 'sza' (nonzero retrieved column, nonzero simulated column, solza less than 80), 'basic' (nonzero retrieved column, nonzero simulated column, nonzero a priori), and 'both' (all four previous conditions) 
    igd_flag = 'basic' #'basic', 'both'
    
    #function to trim the site_codes to only those within a desired band
    site_codes, lat_str = filter_site_codes(site_codes, site_info_file)
    
    #main plotting and drift calculation code
    drift_arr, drift_unc_arr, drift_perc_arr, drift_perc_unc_arr, p_val_corr_arr, p_val_slope_arr = plot_biasdrift_main(mop_prod, file_loc, file_str, site_codes, site_info_file, ngd_min, plot_type, weight_std_do, lat_str, igd_flag)
    
    
    
    
    
      

    



    
    

    





