#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jun  1 21:51:01 2026

@author: pauljeffery
"""

import geopandas as gpd
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
from shapely.geometry import LineString
from shapely.ops import split
from shapely.affinity import translate
from shapely import MultiPolygon

def pull_site_info(site_info_file):
    '''define a function to pull desired latitude and longitude info for the stations included in the analysis 
    inputs:
        -site_info_file: the csv file containing the site information (string)
        
    returns:
        -site_info: a pandas dataframe with the station/flight lat/lon and other info not needed for this (dataframe)
    '''
    site_info = pd.read_csv(site_info_file, header = 0)
    site_info['lon'][site_info['lon']>180] = site_info['lon'][site_info['lon']>180]-360 #correct longitude from deg E to deg E/W
    return site_info

def shift_map(world, shift):
    '''define  function to shift the geopandas world map (made of polygons) to center on the pacific for logical data visualization
    Based on code from: https://stackoverflow.com/questions/58750837/set-centre-of-geopandas-map
    inputs:
        -world_data: world data from geopandas (dataframe)
        -shift: the desired shift in centered longitude (float/integer)

    returns:
        -moved_map: a shifted world map (dataframe)
    '''
    #define containers for map data, and the line to split the data at for the shift
    shift -= 180
    moved_map = []
    split_map = []
    split_line = LineString([(shift,90),(shift,-90)])
    
    #split the geometry 
    for row in world["geometry"]:
        split_map.append(split(row, split_line))
        
    #shift the geometry accoridngly, dealing with each polygon item at a time
    for row in split_map:
        items = list(row.geoms)      
        moved_items = []
        
        for item in items:
            minx, miny, maxx, maxy = item.bounds              
            if minx >= shift:
                moved_items.append(translate(item, xoff=-180-shift))
            else:
                moved_items.append(translate(item, xoff=180-shift))    
        
        #combine multipolygons for output 
        if len(items)>1:
            moved_map.append(MultiPolygon(moved_items))
        else:
            moved_map.append(moved_items[0])
           
    return moved_map

def shift_data(in_data, shift):
    ''' define a function to shift the data to align with the shifted world map
    inputs:
        -in_data: data to shift (float)
        -shift: the desired shift in centered longitude (float/integer)

    returns:
        -shifted_data: the shifted data (float)
    '''
    shifted_data = in_data['lon'] + lon_shift
    shifted_data[shifted_data>180] = shifted_data[shifted_data>180] - 360  
    shifted_data[shifted_data<-180] = shifted_data[shifted_data<-180] + 360
    
    return shifted_data

def plot_noaa_sites(site_info, lon_shift, save_dir):
    '''define a fucntion to plot the noaa data on two plots, one for the entire globe and one for just the part of North America with dense station coverage
    inputs:
        -site_info_file: a pandas dataframe with the station/flight lat/lon and other info not needed for this (dataframe)
        -save_dir: a directory to save the plot(s) to (string)
        
    output:
        -global plot of stations (png/eps figure)
        -plot of north american stations (png/eps figure)
    
    other function dependencies: 
        -shift_map
        -shift_data
    
    Note: The gpd package has deprecated gpd.datasets. If using an updated version of gpd, the line should instead be the commented out line just below it (switch the comment)
    '''
    
    #create the figure for the global plot
    fig, ax=plt.subplots(figsize=[8, 4])

    #use gpd for the world map
    world = gpd.read_file(gpd.datasets.get_path('naturalearth_lowres')) #get_datasets functional
    #world = gpd.read_file("https://naciscdn.org/naturalearth/110m/cultural/ne_110m_admin_0_countries.zip") #get_datasets deprecated
    
    #shift the world map and plot it
    if lon_shift != 0:
        world['geometry']  = shift_map(world, lon_shift)
    world.plot(ax=ax, alpha = 0.3) #https://geopandas.org/en/stable/docs/user_guide/mapping.html

    #shift the data for this plot
    shifted_lon = shift_data(site_info, lon_shift)

    #plot the flight data
    plt.scatter(shifted_lon, site_info['lat'], color = 'red', s=10)

    #loop through the stations and add labels to the data points. Shift acg and nsa for visibility
    for n_iter in range(len(site_info['sitename'])):
        if site_info['sitename'][n_iter] == 'acg':
            plt.annotate(site_info['sitename'][n_iter], (shifted_lon[n_iter]-15, site_info['lat'][n_iter]), color='black')
        elif site_info['sitename'][n_iter] == 'nsa':
            plt.annotate(site_info['sitename'][n_iter], (shifted_lon[n_iter]+2, site_info['lat'][n_iter]+2), color='black')
        else:
            plt.annotate(site_info['sitename'][n_iter], (shifted_lon[n_iter]+2, site_info['lat'][n_iter]), color='black')
        
    #adjust plot limits, grid, title and yticks
    plt.xlim(-180, 180)
    plt.ylim(-90, 90)
    plt.title("NOAA aircraft profile locations")
    plt.grid(alpha=0.3)
    plt.yticks([-60, -30, 0, 30, 60], labels = ['60$\degree{}$ S' , '30$\degree{}$ S', '0$\degree{}$', '30$\degree{}$ N', '60$\degree{}$ N'])

    #logical handling of x tick labels based on lon_shift
    xt_array_base = np.array([-120, -60, 0, 60, 120])
    xt_array_trans = xt_array_base + lon_shift
    xt_array_trans[xt_array_trans>180] = xt_array_trans[xt_array_trans>180] - 360
    xt_array_trans[xt_array_trans<-180] = xt_array_trans[xt_array_trans<-180] + 360    
    xt_label=[]
    for xt in xt_array_trans:
        if xt == 0:
            xt_label.append('0$\degree{}$')
        elif xt == 180:
            xt_label.append('180$\degree{}$')
        elif xt > 0:
            xt_label.append(str(abs(xt)) + '$\degree{}$ E')
        else:
            xt_label.append(str(abs(xt)) + '$\degree{}$ W')

    plt.xticks(xt_array_base, labels = xt_label)
            
    #save plot as eps or png then close plot
    plt.savefig(save_dir +  'NOAA_aircraft_location' +  '.png', format='png', bbox_inches='tight')
    plt.savefig(save_dir +  'NOAA_aircraft_location' +  '.eps', format='eps', bbox_inches='tight')
    plt.close()
    
    #create the figure for the north american plot
    fig, ax=plt.subplots(figsize=[8, 4])
    
    #reload the world map using gpd for the world map and plot it 
    world = gpd.read_file(gpd.datasets.get_path('naturalearth_lowres')) #get_datasets functional
    #world = gpd.read_file("https://naciscdn.org/naturalearth/110m/cultural/ne_110m_admin_0_countries.zip") #get_datasets deprecated
    world.plot(ax=ax, alpha = 0.3) 
    
    #plot the station location
    plt.scatter(site_info['lon'], site_info['lat'], color = 'red', s=10)

    #loop through the stations and add labels to the data points. Shift multiple for visibility
    for n_iter in range(len(site_info['sitename'])):
        if site_info['sitename'][n_iter] == 'acg':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]-15, site_info['lat'][n_iter]), color='black')
        elif site_info['sitename'][n_iter] == 'nsa':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]+0.5, site_info['lat'][n_iter]+2), color='black')
        elif site_info['sitename'][n_iter] == 'mrc':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]-4, site_info['lat'][n_iter]), color='black')
        elif site_info['sitename'][n_iter] == 'how':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]+0.5, site_info['lat'][n_iter]-1), color='black')
        elif site_info['sitename'][n_iter] == 'hfm':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]-4, site_info['lat'][n_iter]), color='black')
        elif site_info['sitename'][n_iter] == 'bao':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]+0.5, site_info['lat'][n_iter]-1), color='black')
        elif site_info['sitename'][n_iter] == 'cob':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]-3, site_info['lat'][n_iter]), color='black')
        elif site_info['sitename'][n_iter] == 'lef':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]-1, site_info['lat'][n_iter]+0.5), color='black')
        elif site_info['sitename'][n_iter] == 'fwi':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]+0.5, site_info['lat'][n_iter]-0.75), color='black')
        elif site_info['sitename'][n_iter] == 'bne':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]-1, site_info['lat'][n_iter]-1.5), color='black')        
        elif site_info['sitename'][n_iter] == 'bgi':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]-3, site_info['lat'][n_iter]-0.5), color='black')
        elif site_info['sitename'][n_iter] == 'wbi':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]-1, site_info['lat'][n_iter]+0.5), color='black')
        elif site_info['sitename'][n_iter] == 'act':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]-1, site_info['lat'][n_iter]-1.5), color='black')
        elif site_info['sitename'][n_iter] == 'inx':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]-1, site_info['lat'][n_iter]-1.5), color='black')   
        elif site_info['sitename'][n_iter] == 'mci':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]-3.5, site_info['lat'][n_iter]-1), color='black')
        elif site_info['sitename'][n_iter] == 'oil':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter], site_info['lat'][n_iter]+0.5), color='black')            
        elif site_info['sitename'][n_iter] == 'aao':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]-2.5, site_info['lat'][n_iter]-1.75), color='black')
        elif site_info['sitename'][n_iter] == 'hil':
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter], site_info['lat'][n_iter]+0.5), color='black')               
        else:
            plt.annotate(site_info['sitename'][n_iter], (site_info['lon'][n_iter]+0.5, site_info['lat'][n_iter]), color='black')
        
    #adjust plot limits, ticks, grid and title
    plt.xlim(-130, -60)
    plt.ylim(25, 65)  
    plt.title("NOAA aircraft profile locations")
    plt.xticks([-120, -100, -80, -60], labels = ['120$\degree{}$ W' , '100$\degree{}$ W', '80$\degree{}$ W', '60$\degree{}$ W'])
    plt.yticks([30, 40, 50, 60], labels = ['30$\degree{}$ N' , '40$\degree{}$ N', '50$\degree{}$ N', '60$\degree{}$ N'])
    plt.grid(alpha=0.3)    
    
    #save plot as eps or png then close plot
    plt.savefig(save_dir +  'NOAA_aircraft_location_zoomed' +  '.png', format='png', bbox_inches='tight')
    plt.savefig(save_dir +  'NOAA_aircraft_location_zoomed' +  '.eps', format='eps', bbox_inches='tight')
    plt.close()

def plot_flight_sites(site_info, camp_name, save_dir):
    '''define a fucntion to plot the atom/hippo data
    inputs:
        -site_info_file: a pandas dataframe with the flight lat/lon and other info not needed for this (dataframe)
        -save_dir: a directory to save the plot(s) (string)
        -camp_name: name of the campaign (HIPPO or ATom) (string)
            
    output:
        -global plot of flights (png/eps figure)
    
    other function dependencies: 
        -shift_map
        -shift_data
        
    Note: The gpd package has deprecated gpd.datasets. If using an updated version of gpd, the line should instead be the commented out line just below it (switch the comment)
    '''
    #create the figure for the global plot
    fig, ax=plt.subplots(figsize=[8, 4])

    #use gpd for the world map
    world = gpd.read_file(gpd.datasets.get_path('naturalearth_lowres')) #get_datasets functional
    #world = gpd.read_file("https://naciscdn.org/naturalearth/110m/cultural/ne_110m_admin_0_countries.zip") #get_datasets deprecated
    
    #shift the world map and plot it
    if lon_shift != 0:
        world['geometry']  = shift_map(world, lon_shift)
    world.plot(ax=ax, alpha = 0.3) #https://geopandas.org/en/stable/docs/user_guide/mapping.html

    #shift the data for this plot
    shifted_lon = shift_data(site_info, lon_shift)

    #subdivide the flight data based on the flight number and save indicies to a dictionary
    flight_list = []
    flight_index_list = []
    flight_dict = {}
    for n_iter in range(len(site_info['location'])):
        if n_iter ==0:
            flight_list.append(site_info['location'][n_iter].split('-20')[0])
            flight_index_list.append(n_iter)
        else:
            if site_info['location'][n_iter].split('-20')[0] == flight_list[-1]:
                flight_index_list.append(n_iter)
            else:
                
                flight_dict[flight_list[-1]] = np.array(flight_index_list)
                flight_index_list = []
                flight_list.append(site_info['location'][n_iter].split('-20')[0])
                flight_index_list.append(n_iter)
        if n_iter == len(site_info['location'])-1:
            flight_dict[flight_list[-1]] = np.array(flight_index_list)

    #define a colour scheme based on dictionary 
    n_flights = len(flight_dict)
    color_set = mpl.cm.plasma(np.linspace(0,1, n_flights))
    
    #plot the flight, with a spare point being used for the label handling. Also cases for hippo/atom for proper labels
    for f_iter in range(n_flights):
        if camp_name.upper() == 'HIPPO':
            plt.scatter(shifted_lon[flight_dict[flight_list[f_iter]][0]], site_info['lat'][flight_dict[flight_list[f_iter]][0]], color = color_set[f_iter], s=20, marker = 'D', label = flight_list[f_iter].upper(), edgecolors='black', linewidth=0.5)
        else:        
            plt.scatter(shifted_lon[flight_dict[flight_list[f_iter]][0]], site_info['lat'][flight_dict[flight_list[f_iter]][0]], color = color_set[f_iter], s=20, marker = 'D', label = flight_list[f_iter], edgecolors='black', linewidth=0.5)
        plt.scatter(shifted_lon[flight_dict[flight_list[f_iter]]], site_info['lat'][flight_dict[flight_list[f_iter]]], color = color_set[f_iter], s=20, marker = 'D', edgecolors='black', linewidth=0.5)
      
    #add legend info and adjust plot limits, ticks, grid and title. legend is handled based on hippo/atom  case
    if camp_name.upper() == 'HIPPO':
        plt.legend(ncol = n_flights, loc='lower center')
    else:        
        plt.legend(ncol = int(n_flights/2), loc='upper left')

    plt.xlim(-180, 180)
    plt.ylim(-90, 90)
    plt.title(camp_name + " flight track locations")
    plt.yticks([-60, -30, 0, 30, 60], labels = ['60$\degree{}$ S' , '30$\degree{}$ S', '0$\degree{}$', '30$\degree{}$ N', '60$\degree{}$ N'])
    plt.grid(alpha=0.3)
        
    #logical handling of x tick labels based on lon_shift
    xt_array_base = np.array([-120, -60, 0, 60, 120])
    xt_array_trans = xt_array_base + lon_shift
    xt_array_trans[xt_array_trans>180] = xt_array_trans[xt_array_trans>180] - 360
    xt_array_trans[xt_array_trans<-180] = xt_array_trans[xt_array_trans<-180] + 360    
    xt_label=[]
    for xt in xt_array_trans:
        if xt == 0:
            xt_label.append('0$\degree{}$')
        elif xt == 180:
            xt_label.append('180$\degree{}$')
        elif xt > 0:
            xt_label.append(str(abs(xt)) + '$\degree{}$ E')
        else:
            xt_label.append(str(abs(xt)) + '$\degree{}$ W')

    plt.xticks(xt_array_base, labels = xt_label)
    
    #save plot as eps and png then close plot
    plt.savefig(save_dir +  camp_name + '_flight_location' +  '.png', format='png', bbox_inches='tight')
    plt.savefig(save_dir +  camp_name + '_flight_location' +  '.eps', format='eps', bbox_inches='tight')
    plt.close()

if __name__ == "__main__":
    '''plots the locations for the noaa, Atom and hippo validation profiles'''
    
    #user input required for program, namely file of noaa/hippo/atom site information and a directory to save the plot(s) to
    noaa_info_file = '/Users/pauljeffery/Downloads/NOAA_locations.csv'
    hippo_info_file = '/Users/pauljeffery/Downloads/HIPPO_locations.csv'
    atom_info_file = '/Users/pauljeffery/Downloads/ATom_locations.csv'
    save_dir = '/Users/pauljeffery/Desktop/'
    
    #define a longitude shift for ease of data visualization
    lon_shift = 180
    
    #load the data for the three files
    noaa_info = pull_site_info(noaa_info_file)
    hippo_info = pull_site_info(hippo_info_file)
    atom_info = pull_site_info(atom_info_file)

    #plot the data 
    plot_noaa_sites(noaa_info, lon_shift, save_dir)
    plot_flight_sites(hippo_info, 'HIPPO', save_dir)
    plot_flight_sites(atom_info, 'ATom', save_dir)
    
    
    
    
    
    