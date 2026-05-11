#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon May  4 11:33:31 2026

@author: pauljeffery
"""

import numpy as np
import matplotlib.pyplot as plt
import glob
from subprocess import check_output

'''define a function to check the length of the match files
inputs:
    -filename: the file to be checked
    
returns:
    -number of lines in the file
'''
def wc(filename):
    return int(check_output(["wc", "-l", filename]).split()[0])

'''define main function for plotting the correlation
inputs: 
    -mop_prod: the mopitt product to be examined
    -file_loc: the location of the matched data
    -file_str: the string format to match for the files
    -site_codes: the list of site codes to be used for the analysis
    -ngd_min: the minimum number of matches needed in a file for incorperation into the analysis
    -plot_type: the desired output file type (such as eps or png)

returns:
    -bias_mean_arr: a np array with the mean bias at each of the 10 levels (200:900 hPa, surface, column)
    -bias_stdev_arr: a np array with the syandard deviation of the bias at each of the 10 levels (200:900 hPa, surface, column)
    -r_arr: a np array with correlation (r) at each of the 10 levels (200:900 hPa, surface, column)

outputs:
    -10 panel plot of the correlation 
    
other function dependencies: 
    -wc
'''
def plot_vald_main(mop_prod, file_loc, file_str, site_codes, ngd_min, plot_type): #plot 9 levels plus total column
    
    #define naming convention for output file
    if mop_prod == 'TIR':
        fname_key = 't'
    elif mop_prod == 'NIR':
        fname_key = 'n'
    elif mop_prod == 'Joint':
        fname_key = 'j'
    elif mop_prod == 'Trop':
        fname_key = 'tr'
    
    #define site code derived info (can toggle between each site being uniquely colored)
    n_sites = len(site_codes)
    #site_colors = plt.cm.hsv(np.linspace(0,1,n_sites)) #different colors per site  
    site_colors = plt.cm.hsv([0.44])    #uniform site colors

    #define log10e for percent deviation 
    log10e = np.log10(np.e)

    #define figure details (name, panels, size)
    fig_name = 'plot_vald_dlog_9levs.v10' + fname_key + '.noaa.' + plot_type
    fig, axes = plt.subplots(5, 2, figsize=(8, 11))
    axes = axes.flatten()
      
    #define plot settings (levels)
    ilev_plot = [8,7,6,5,4,3,2,1,0,-1]
    lvl_lbl = ['200 hPa','300 hPa','400 hPa','500 hPa','600 hPa','700 hPa','800 hPa','900 hPa','Surface','Column']
    nlevs = len(ilev_plot)

    #define plot limits for axes
    dlogvmrmax = 0.4
    dcolmax = 2.e18

    #initialize arrays to hold data for return 
    bias_mean_arr = np.empty(nlevs)
    bias_stdev_arr = np.empty(nlevs)
    r_arr = np.empty(nlevs)
     
    #loop for the plot levels 
    for i_lev in range(nlevs):
        #initialize iterators
        nval = 0
        iplot = 0
        
        #initialize arrays to hold data (retrieved mean, retrieved standard deviation, aircraft mean, dofs) for this level
        rtv_mean_hold = []
        rtv_stdev_hold = []
        val_mean_hold = []
        dfs_hold = []

        #loop for the sites
        for i_site in range(n_sites):
            #find site files, abort loop if none
            site_filelist = sorted(glob.glob(file_loc + '/' + file_str + site_codes[i_site] + '.*.50km.dat'))
            
            if len(site_filelist) < 1:
                continue
            else:
                nvalfiles = len(site_filelist)
                
            #loop for the files for the site
            for i_file in range(nvalfiles):
                #extract month from filename (not needed in this version, but maintained regardless)
                date_str = site_filelist[i_file].split(site_codes[i_site]+'.')[1].split('.')[0]
                mon_str = date_str[4:6]
                
                #find the number of matches within the file, abort loop if less than 1
                n_match = int((wc(site_filelist[i_file]) - 1) / 6)

                if n_match < 1:
                    continue 
                
                # Initialize arrays for the data
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
                
                #these flags don't appear to be used for anything, but their pressence is maintained in code
                #flag1 = np.zeros(n_match, dtype=int)
                #flag2 = np.zeros(n_match, dtype=int)
                #flag3 = np.zeros(n_match, dtype=int)
                #flag4 = np.zeros(n_match, dtype=int)                
                #flag5 = np.zeros(n_match, dtype=int)  
                                
                #read info from file and extract profile info
                with open(site_filelist[i_file], 'r') as f:
                    prof_info = np.array(f.readline().split(), dtype = float)
                    prof_lat = prof_info[0]

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
                        
                        #flag1[i_match] = header[15]
                        #flag2[i_match] = header[16]
                        #flag3[i_match] = header[17]
                        #flag4[i_match] = header[18]
                        #flag5[i_match] = header[19]
                        
                        for i_row in range(5):
                            alldat[i_row, :, i_match] = np.array(f.readline().split(), dtype = float)
                
                #pull data for the level of interest, handling differently the column and profile info
                if ilev_plot[i_lev] == -1:
                    rtv = rtvcolm
                    val = simcolm
                    ap = apcolm
                else:
                    rtv = alldat[0, ilev_plot[i_lev], :]
                    val = alldat[1, ilev_plot[i_lev], :]
                    ap = alldat[2, ilev_plot[i_lev], :]

                #apply quality filter for daytime and nighttime, ocean and land, needs non-zero values for retrieval, aircraft and a priori profiles  
                igd = np.where((rtv > 0) & (val > 0) & (ap > 0))[0]
                
                #check if there's enough good data points
                if len(igd) < ngd_min:
                    continue
                
                #begin data analysis, analyzes (aircraft profile - a priori) and (retrievals - a priori) per Deeter et al 2017
                val_mean = np.mean(val[igd] - ap[igd])
                val_stdev = (np.std(val[igd] - ap[igd]))
                                
                rtv_mean = np.mean(rtv[igd] - ap[igd])
                rtv_stdev = (np.std(rtv[igd] - ap[igd]))
                
                #plot for the column
                if ilev_plot[i_lev] == -1:
                    #setup figure limits and labels
                    if iplot == 0:
                        axes[i_lev].set_xlim(-dcolmax, dcolmax)
                        axes[i_lev].set_ylim(-dcolmax, dcolmax)
                        axes[i_lev].set_xlabel('$\Delta$CO total column, in situ')
                        axes[i_lev].set_ylabel('$\Delta$CO total column, MOPITT')
                        axes[i_lev].text(-0.85*dcolmax, 0.6*dcolmax, lvl_lbl[9], fontsize=12)
                        iplot += 1

                    #plot data
                    axes[i_lev].scatter(val_mean, rtv_mean, marker = 'D', color = site_colors[i_site], s = 50)
                    axes[i_lev].errorbar(val_mean, rtv_mean, yerr = rtv_stdev, fmt = 'none', color = site_colors[i_site], capsize = 5)
                    
                    #append for calculation later
                    rtv_mean_hold.append(rtv_mean)
                    rtv_stdev_hold.append(rtv_stdev)
                    val_mean_hold.append(val_mean)
                    dfs_hold.append(np.mean(dfs[igd]))
                #plot for the profile
                else:
                    #setup figure limits and labels
                    if iplot == 0:
                        axes[i_lev].set_xlim(-dlogvmrmax, dlogvmrmax)
                        axes[i_lev].set_ylim(-dlogvmrmax, dlogvmrmax)
                        axes[i_lev].set_xlabel('$\Delta$CO log(VMR), in situ')
                        axes[i_lev].set_ylabel('$\Delta$CO log(VMR), MOPITT')
                        axes[i_lev].text(-0.85*dlogvmrmax, 0.6*dlogvmrmax, lvl_lbl[i_lev], fontsize=12)
                        iplot += 1
                    
                    #plot data 
                    axes[i_lev].scatter(val_mean, rtv_mean, marker = 'D', color = site_colors[i_site], s = 50)
                    axes[i_lev].errorbar(val_mean, rtv_mean, yerr = rtv_stdev, fmt = 'none', color = site_colors[i_site], capsize = 5)
                    
                    #append for calculation later
                    rtv_mean_hold.append(rtv_mean)
                    rtv_stdev_hold.append(rtv_stdev)
                    val_mean_hold.append(val_mean)
                    
                nval += 1

        #process the plots, first by converting list to np array     
        rtv_mean_hold = np.array(rtv_mean_hold)
        rtv_stdev_hold = np.array(rtv_stdev_hold)   
        val_mean_hold = np.array(val_mean_hold) 
        
        #column post-processing
        print(f"Current plot: {lvl_lbl[i_lev]}")
        if ilev_plot[i_lev] == -1:
            #plot +- 10 % bars, the 10 % is predefined to be consistent with older plots
            d10pct = 2.e17
            axes[i_lev].plot([-dcolmax, dcolmax], [-dcolmax, dcolmax], 'k--', alpha=0.5)
            axes[i_lev].plot([-dcolmax, dcolmax - d10pct], [-dcolmax + d10pct, dcolmax], 'k--', alpha=0.5)
            axes[i_lev].plot([-dcolmax + d10pct, dcolmax], [-dcolmax, dcolmax - d10pct], 'k--', alpha=0.5)

            #calculate r
            r = np.corrcoef(val_mean_hold, rtv_mean_hold)[0,1]
            r_arr[i_lev] = np.round(r, 2)
            print(f'Correlation r = {r:.2f}')
            
            #calculate least squares fit (it is the same to machine accuracy for curve_fit or polyfit), do the calculation at 1e-16 for machine error handling
            coeffs = np.polyfit(val_mean_hold*1e-16, rtv_mean_hold*1e-16, 1, w=1/rtv_stdev_hold*1e-16)
            coeffs[1] *= 1e16
            print(f"Polyfit coefficients {coeffs}")
            
            #plot least squares line
            axes[i_lev].plot(np.linspace(-dcolmax, dcolmax, 100), np.linspace(-dcolmax, dcolmax, 100) * coeffs[0] + coeffs[1], 'k--')
            
            #calculate bias in 10^17 mol/cm2   
            bias_mean = np.mean(1e-17*(rtv_mean_hold - val_mean_hold))
            bias_stdev = np.std(1e-17*(rtv_mean_hold - val_mean_hold))
            
            bias_mean_arr[i_lev] = np.round(bias_mean, 1)
            bias_stdev_arr[i_lev] = np.round(bias_stdev, 1)

            print(f"Column mean bias = {bias_mean:.1f} (x 1e17), stdev =  {bias_stdev:.1f} (x 1e17)")
            
            #add to plots
            
            axes[i_lev].text(-0.85*dcolmax, 0.33*dcolmax, f'n = {nval}', fontsize=8)
            axes[i_lev].text(-0.85*dcolmax, 0.06*dcolmax, f'dofs = {np.mean(np.array(dfs_hold)):.2f}', fontsize=8)
            axes[i_lev].text(0.25*dcolmax, -0.38*dcolmax, f'r = {r:.2f}', fontsize=8)
            axes[i_lev].text(0.25*dcolmax, -0.65*dcolmax, f'bias = {bias_mean:.1f} x10$^{1}$$^{7}$', fontsize=8)
            axes[i_lev].text(0.25*dcolmax, -0.92*dcolmax, f'stdev = {bias_stdev:.1f} x10$^{1}$$^{7}$', fontsize=8)
 
        #profile post-processing
        else:
            #plot +- 10 % bars, the 10 % is predefined to be consistent with older plots
            d10pct = 0.0414
            axes[i_lev].plot([-dlogvmrmax, dlogvmrmax], [-dlogvmrmax, dlogvmrmax], 'k--', alpha=0.5)
            axes[i_lev].plot([-dlogvmrmax, dlogvmrmax - d10pct], [-dlogvmrmax + d10pct, dlogvmrmax], 'k--', alpha=0.5)
            axes[i_lev].plot([-dlogvmrmax + d10pct, dlogvmrmax], [-dlogvmrmax, dlogvmrmax - d10pct], 'k--', alpha=0.5)

            #calculate r
            r = np.corrcoef(val_mean_hold, rtv_mean_hold)[0,1]
            r_arr[i_lev] = np.round(r, 2)
            print(f'Correlation r = {r:.2f}')
            
            #calculate least squares fit (it is the same to machine accuracy for curve_fit or polyfit)
            coeffs = np.polyfit(val_mean_hold, rtv_mean_hold, 1, w=1/rtv_stdev_hold)
            print(f"Polyfit coefficients {coeffs}")
            
            #plot least squares line
            axes[i_lev].plot(np.linspace(-dlogvmrmax, dlogvmrmax, 100), np.linspace(-dlogvmrmax, dlogvmrmax, 100) * coeffs[0] + coeffs[1], 'k--')
            
            #calculate bias in percent
            bias_mean = 100*np.mean((rtv_mean_hold - val_mean_hold))/log10e
            bias_stdev = 100*np.std((rtv_mean_hold - val_mean_hold))/log10e
            
            bias_mean_arr[i_lev] = np.round(bias_mean, 1)
            bias_stdev_arr[i_lev] = np.round(bias_stdev, 1)

            print(f"Column mean bias = {bias_mean:.1f} (%), stdev =  {bias_stdev:.1f} (%)")
            
            #add to plots
            axes[i_lev].text(-0.85*dlogvmrmax, 0.33*dlogvmrmax, f'n = {nval}', fontsize=8)
            axes[i_lev].text(0.25*dlogvmrmax, -0.38*dlogvmrmax, f'r = {r:.2f}', fontsize=8)
            axes[i_lev].text(0.25*dlogvmrmax, -0.65*dlogvmrmax, f'bias = {bias_mean:.1f} %', fontsize=8)
            axes[i_lev].text(0.25*dlogvmrmax, -0.92*dlogvmrmax, f'stdev = {bias_stdev:.1f} %', fontsize=8)
        
        #add grid to plots to enhance visibility
        axes[i_lev].grid(True, alpha=0.2)
    
    #add figure title and save figure
    fig.suptitle('V10 ' + mop_prod, fontsize = 18)
    plt.tight_layout()
    plt.savefig(fig_name, format = plot_type)
    plt.close()
    
    return bias_mean_arr, bias_stdev_arr, r_arr 
     
if __name__ == "__main__":
    '''generates validation scatterplots of (x_rtv - x_a) vs (x_val - x_a)'''
    
    #define mopitt product to use and the file location and formatting
    mop_prod = 'TIR'
    file_loc = '/Users/pauljeffery/Downloads/mopittv10-main 2/sample_pairing'
    file_str = 'val_L2_v10.L2V19.9.2.'
    
    #define site code list and resulting values
    site_codes = ['bne']

    #running parameters for the number of matches within each file needed 
    ngd_min = 5

    #define figure details for output
    plot_type = 'png' #should be eps
    
    #run main function, return mean bias, bias standard deviation, and the correlation 
    bias_mean_arr, bias_stdev_arr, r_arr  = plot_vald_main(mop_prod, file_loc, file_str, site_codes, ngd_min, plot_type)

   

    
    
