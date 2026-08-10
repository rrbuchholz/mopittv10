'''
Code to load and compare aircraft profiles of carbon monoxide
collated and harmonized for validation against MOPITT v10
retrievals of CO.

  Filter definitons:
  - aircraft profile must start below 750 hPa (850 hPa for NOAA sites sgp, lef, esp, or 700 hPa for NOAA rta), and the profile must end higher than 450 hPa (500 hPa for NOAA rta, 550 hPa for NOAA sgp, lef, esp). Additionally, the aircraft profiles must contain 5 or more flask measurements.
  - MOPITT retrievals must be within a 50 km radius for NOAA locations, (200 km radius for HIPPO and ATom), and MOPITT retrieval time must be within +/- 12 hrs of the observation. Finally, there must be 5 or more MOPITT profiles per aircraft profile.

  To use on mopfl2012:
  > python3.12 pair_mopitt_noaa_v10.py

  Steps in process:
  #--- load aircraft files
  #--- aircraft filters
  #--- load coincident MOPITT file
  #--- MOPITT spatiotemporal filters
  #--- adjust aircraft to 10 layers
  #--- use MERRA2 water vapor

--- rrb 2026-05-29
'''


#library
import glob # for listing files
import pandas as pd
import numpy as np
#import xarray as xr
from scipy import interpolate              # for vertical interpolation
import re   # Fore regular expression matching
import h5py # to open MOPITT he5 file
import sys  # for sys.exit()


# ========================================================================
# user definitions and configuration parameters
# ========================================================================

#--- NOAA file location
#--- all data (https://doi.org/10.5281/zenodo.20147785)
noaa_folder = '/home/buchholz/MOPITTv10/MOPITT_Validation/mopittv10_python/sample_data/NOAA/'
#noaa_folder = '/home/buchholz/MOPITTv10/MOPITT_Validation/aircraft_profile_CO_data/NOAA/'
aircraft_files = sorted(glob.glob(noaa_folder+"/*/*.asc"))

#--- MOPITTv10 file location
mopitt_folder = '/MOPITT/V10T/Archive/L2/'
#mopitt_folder = '/MOPITT/VALIDATION/ArchiveV10T/L2_9/'

#--- MERRA2 file location
merra_folder = '/MOPITT/project/datasets/merra2-nc4/Rebecca/3D/'

#--- Outfile name template
outfile_name_prefix = '/home/buchholz/MOPITTv10/MOPITT_Validation/mopittv10_python/validation/validation_pairing/val_L2_v10.L2V19.9.2.'

#--- Filter thresholds
#--- Minimum number of aircraft measurements in average profile
nflaskmin = 5.

#---- Default aircraft pressure thresholds (can vary by site)
p_top_thr = 450.
p_bot_thr = 750.

#--- Coarse MOPITT spatial range acceptance
dlatmax = 2.5
dlonmax = 2.5

#--- Fine MOPITT spatiotemporal range acceptance
distmax = 50.
dthrsmax = 12.

# ========================================================================
# functions
# ========================================================================

def get_location_name(datafile):
    '''
    Function to define a unique location name with station or campaign name,
    combined with UTC date and time ID-YYYY-MM-DD-HHMM
    
    datafile (str): string path to file containing data
  
    returns: location_ID (str) is a string unique to the profile file being used
    
    '''

    filename = pd.read_csv(datafile, header=None, nrows=1)

    location_meta_temp = filename.iloc[0].str.split('_')
    location_meta_temp_2 = location_meta_temp.str[-1].str.split('.')
    location_date_UTC = location_meta_temp_2.str[0]
    location_time_UTC = location_meta_temp_2.str[1]

    location_meta_temp_3 = filename.iloc[0].str.split('/')
    location_name = location_meta_temp_3.str[14]

    concat_info = location_name+'-'+location_date_UTC+'-'+location_time_UTC
    location_ID = str(concat_info.values[0])

    return location_ID


def load_profiles(datafile):
    
    '''
    Function that collects aircraft profiles from harmonized interpolated
    files and joins into a pandas dataframe
    
    datafile (str): string path to file containing data
    
    returns: aircraft_array (float) is a data array of CO values
    in a format to join to a pandas DataFrame
    
    '''
    location_ID = get_location_name(datafile)
    aircraft_array = pd.read_csv(datafile, header=4, sep='\\s+', index_col=0)
    aircraft_array.columns = [location_ID]

    return aircraft_array


def load_meta(datafile):
    
    '''
    Function that collects meta data associated with aircraft profiles
    from harmonized interpolated files and joins into a pandas dataframe
    
    datafile (str): string path to file containing data
    
    returns: aircraft_meta_array (str) is an array of location information
    values in a format to join to a pandas DataFrame
    
    '''

    location_ID = get_location_name(datafile)
    location_meta = pd.read_csv(datafile, header=None, skiprows=1, nrows=1, sep='\\s+')
    aircraft_meta_array = pd.DataFrame(columns=[location_ID])
    aircraft_meta_array.loc['lat'] = location_meta.iloc[0,0]
    aircraft_meta_array.loc['lon'] = location_meta.iloc[0,1]
    #--- correct for longitude values > 180.
    if (aircraft_meta_array.loc['lon'].values > 180.):
        aircraft_meta_array.loc['lon'] = aircraft_meta_array.loc['lon'] - 360.
    aircraft_meta_array.loc['presmax'] = location_meta.iloc[0,2]
    aircraft_meta_array.loc['presmin'] = location_meta.iloc[0,3]
    aircraft_meta_array.loc['N'] = location_meta.iloc[0,4]
    aircraft_meta_array.loc['fname'] = datafile

    return aircraft_meta_array


def calc_moist_vmr(datafile):
    
    '''
    Function that loads and uses MERRA2 data to create wet CO profiles
    from the aircraft profile
    
    '''


def distance(lat1, lon1, reflat, reflon):
    
    '''
    Function that calculates a radius of coincidence around an aircraft location
    based on a distance threshold
    
    lat1, lon1, lat2, lon2 : float
        Latitude and longitude in degrees
    
    Returns
    -------
    float
        Distance in kilometers
    '''

    from math import radians, sin, cos, sqrt, atan2
    
    lat1_r, lon1_r, reflat_r, reflon_r = map(radians, [lat1, lon1, reflat, reflon])
    dlat = reflat_r - lat1_r
    dlon = reflon_r - lon1_r
    a = sin(dlat/2)**2 + cos(lat1_r) * cos(reflat_r) * sin(dlon/2)**2
    c = 2 * atan2(sqrt(a), sqrt(1-a))
    R = 6371.0  # Earth radius in km
    return R * c


def vertical_regrid(input_press, input_values, output_press):
    '''
    This function uses interp1d to regrid vertical layers into a 3D array
    
    Function requires:
        input_press = input pressure levels in hPa and same dimensions as input_values (alt)
        input_values = Dataarray of input values to be regridded (alt)
        output_press = output pressure levels in hPa, dimensions are the different to input values, except for the altitude (new alt, mopitt retrieval number)
        
    Function Returns:
        regrid_array = the data regridded to the new pressure levels

    '''
    regrid_array = np.full_like(output_press, np.nan)
    # loop through number of MOPITT retrievals
    for n in range (output_press.shape[0]):
        f = interpolate.interp1d(input_press, input_values, kind='linear', fill_value="extrapolate")
        xnew = output_press[n]
        regrid_array[n,:] = f(xnew)
          
    return regrid_array


# ========================================================================
# begin the comparison
# ========================================================================
#--- load aircraft files
count = 0

for file in aircraft_files[0:5]:
#for file in aircraft_files:
    profile_ID = get_location_name(file)

    if count == 0:
        #print('collecting first aircraft profile record: '+profile_ID)
        aircraft_full_array = load_profiles(file)
        aircraft_full_meta = load_meta(file)
        count += 1
    else:
        #print('collecting aircraft profile: '+profile_ID)
        temp = aircraft_full_array
        newdata = load_profiles(file)

        temp2 = aircraft_full_meta
        newdata2 = load_meta(file)

        aircraft_full_array = pd.concat([temp, newdata], axis=1)
        aircraft_full_meta = pd.concat([temp2, newdata2], axis=1)

#DEBUG
#print('**************')
#print(aircraft_full_array)
#print(aircraft_full_meta)

#---------------------------------
#--- apply aircraft filters
cols_to_drop = aircraft_full_meta.columns[
                      (aircraft_full_meta.loc['N'] < nflaskmin) | 
                      (aircraft_full_meta.loc['presmax'] < p_bot_thr) |
                      (aircraft_full_meta.loc['presmin'] > p_top_thr) ]

aircraft_meta_filtered = aircraft_full_meta.drop(columns=cols_to_drop)
aircraft_filtered = aircraft_full_array.drop(columns=cols_to_drop)

#DEBUG
#print('**************')
#print(aircraft_filtered)
#print(aircraft_meta_filtered)

#--- Begin using MOPITT data
MOPITT_downtime = []
MERRA_missing = []
coarse_filter = []
fine_time_filter = []
fine_spatial_filter = []
compared_profile = []

for profile in aircraft_filtered:
    print(profile)
    proflat = aircraft_meta_filtered[profile].loc['lat']
    proflon = aircraft_meta_filtered[profile].loc['lon']
    #--- load coincident MOPITT file
    #--- ID-YYYY-MM-DD-HHMM
    #---[0]-[1]-[2]-[3]-[4]
    name_meta = profile.split('-')
    profyr = name_meta[1]
    profmo = name_meta[2]
    profdy = name_meta[3]

    MOPITT_file = sorted(glob.glob(mopitt_folder+
                         str(name_meta[1])+str(name_meta[2])+'/'+
                         str(name_meta[2])+str(name_meta[3])+'/*.he5'))

    #---------------------------------
    #--- MOPITT spatiotemporal filters

    if MOPITT_file == [] :
        print('No MOPITT file for '+ profile)
        MOPITT_downtime.append(profile)
        print('---------------')
        continue

    #--- load the MOPITT data
    he5_load = h5py.File(MOPITT_file[0], mode='r')

    #--- read in dimensions
    moplat = he5_load['/HDFEOS/SWATHS/MOP02/Geolocation Fields/Latitude'][:]
    moplon = he5_load['/HDFEOS/SWATHS/MOP02/Geolocation Fields/Longitude'][:]

    #--- coarse filter
    coarse_ibox = np.where((abs(moplat - proflat) < dlatmax)
                          &(abs(moplon - proflon) < dlonmax))[0]
    nbox = np.size(coarse_ibox)
    
    if nbox < 1 :
        print('No coincident MOPITT data within threshold radius ( +/-' +
               str(dlatmax) +' lat, '+ str(dlonmax) + ' lon degrees) for '+ profile)
        coarse_filter.append(profile)
        print('---------------')
        continue

    # DEBUG
    #print('**************')
    #print(moplon[coarse_ibox])
    #print(proflon)

    #--- read MOPITT time
    mopsecs = he5_load['/HDFEOS/SWATHS/MOP02/Geolocation Fields/SecondsinDay'][:]

    #--- fine filter --> time threshold
    profhhmm = re.findall(f'.{{1,{2}}}', name_meta[4])
    profhr = profhhmm[0]
    profmn = profhhmm[1]

    dthrs = abs(mopsecs[coarse_ibox]/3600. - 
                (float(profhhmm[0]) + 
                 float(profhhmm[1])/60.))
    mopitt_timefilter = np.where(dthrs < dthrsmax)

    if np.size(mopitt_timefilter) == 0 :
        print('All MOPITT data outside fine time threshold ( +/-' +
               str(dlatmax) +') hhmm,  for '+ profile)
        print('---------------')
        fine_time_filter.append(profile)
        continue

    #--- fine filter -->  spatial threshold
    mopitt_colocated = []
    dist_colocated = []
    for j in range(nbox):
        jpx = coarse_ibox[j]
        dist = distance(moplat[jpx], moplon[jpx], proflat, proflon)

        # Check proximity constraints
        if dist > distmax:
            continue
        else:
            mopitt_colocated.append(coarse_ibox[j])
            dist_colocated.append(float(dist))

    if np.size(mopitt_colocated) == 0 :
        print('All MOPITT data outside fine spatial threshold ( +/-' +
               str(distmax) +') km,  for '+ profile)
        print('---------------')
        fine_spatial_filter.append(profile)
        continue

    print(np.mean(dist_colocated))

    #--- read all required HDF5 MOPITT data select on fine spatial threshold
    try:
        # --- load metadata ---
        pxsttrk = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/SwathIndex'][mopitt_colocated]
        isfc = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/SurfaceIndex'][mopitt_colocated]
        icld = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/CloudDescription'][mopitt_colocated]
        psfc = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/SurfacePressure'][mopitt_colocated]
        sza = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/SolarZenithAngle'][mopitt_colocated]
        wvcolm = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/WaterVaporColumn'][mopitt_colocated]
        dfs = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/DegreesofFreedomforSignal'][mopitt_colocated]
        rads_errs = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/Level1RadiancesandErrors'][mopitt_colocated]
        anom_flags = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/RetrievalAnomalyDiagnostic'][mopitt_colocated]

        # --- load CO retrieval info ---
        prs = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/PressureGrid'][:]
        rtvcolm = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/RetrievedCOTotalColumn'][mopitt_colocated]
        apcolm = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/APrioriCOTotalColumn'][mopitt_colocated]
        rtvsfvmr = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/RetrievedCOSurfaceMixingRatio'][mopitt_colocated]
        rtvprof = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/RetrievedCOMixingRatioProfile'][mopitt_colocated]
        apsfvmr = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/APrioriCOSurfaceMixingRatio'][mopitt_colocated]
        approf = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/APrioriCOMixingRatioProfile'][mopitt_colocated]
        ak_rowsum = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/AveragingKernelRowSums'][mopitt_colocated]
        avkrn = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/RetrievalAveragingKernelMatrix'][mopitt_colocated]
        colm_avkrn = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/TotalColumnAveragingKernel'][mopitt_colocated]

                                
    except KeyError as e:
        print(f"Missing required dataset: {e}")
        continue

    # Read cloud diagnostics (V9/V10 only)
    try:
        modiscld = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/MODISCloudDiagnostics'][mopitt_colocated]
        mopcldratio = he5_load['/HDFEOS/SWATHS/MOP02/Data Fields/MOPCldRadRatio'][mopitt_colocated]
        # Cloud clear fraction from index 4
        modisclrfrac = modiscld[:, 4] / 100.
    except KeyError:
        dprint(f"Missing cloud diagnostic datasets", level=2, indent=2)
        mopcldratio = np.full(len(psfc), missing_val)
        modisclrfrac = np.full(len(psfc), missing_val)


    # close after loading all data
    he5_load.close()

    #---------------------------------
    # Extract radiance channel errors
    rad_5A = rads_errs[:,3,0]    # Band 5A radiance
    rad_uncy_5A = rads_errs[:,3,1]
    rad_6A = rads_errs[:,9,0]    # Band 6A radiance
    rad_uncy_6A = rads_errs[:,9,1]
    rad_6D = rads_errs[:,11,0]   # Band 6D radiance
    rad_uncy_6D = rads_errs[:,11,1]
    # Calculate SNR (signal-to-noise ratio)
    snr5a = np.where(rad_uncy_5A > 0, rad_5A / rad_uncy_5A, -999.)
    snr6a = np.where(rad_uncy_6A > 0, rad_6A / rad_uncy_6A, -999.)
#!!!!!!!!!!!!!!!!!!!!!!!!!!- is this correct?---------------------
# ****** was written like this in IDL code
    snr6r = np.where(rad_uncy_6D > 0, rad_6A / rad_uncy_6D, -999.)
                                
    # Mark nighttime (negative radiances) as invalid
    snr6a[rad_6A < 0.] = -999.
    snr6r[rad_6A < 0.] = -999.

    #---------------------------------
    #--- process each matched pixel
    # convert both retrieval and a priori profile to log-VMR

    rtv_vmrprof = np.column_stack((rtvsfvmr[:, 0], rtvprof[:,0:10,0]))
    rtv_logprof = np.log10(rtv_vmrprof)

    ap_vmrprof = np.column_stack((apsfvmr[:, 0], approf[:,0:10,0]))
    ap_logprof = np.log10(ap_vmrprof)

    #---------------------------------
    #--- Build pressure profile array
    sat_pressure_array = np.full_like(colm_avkrn, np.nan)
    sat_pressure_array[:,0] = psfc
    sat_pressure_array[:,1:10] = prs

    #---------------------------------
    #--- use MERRA2 water vapor

    MERRA_file = sorted(glob.glob(merra_folder +
                         'svc_MERRA2_*.inst6_3d_ana_Np.' +
                         str(name_meta[1])+str(name_meta[2]) +
                         str(name_meta[3])+'.nc4'))

    if MERRA_file == [] :
        print('No MERRA file for '+ profile)
        MERRA_missing.append(profile)
        print('---------------')
        continue

    #---------------------------------
    #--- adjust aircraft to 10 layers
    #--- calculate base column
    press_in = aircraft_filtered[profile].index
# --- TODO
    moist_VMR = aircraft_filtered[profile]
# --- TODO
    #print(moist_VMR)
    air_vert_regrid = vertical_regrid(press_in, moist_VMR, sat_pressure_array)
    air_logprof = np.log10(air_vert_regrid)
    #print(air_logprof)

    #---------------------------------
    #--- calculate simulated column
    #--- i.e. smoothed aircraft column
    # ---- TO DO
    colm_sim = np.full_like(mopitt_colocated, np.nan)
    simprof = np.full_like(air_logprof, np.nan)
    sim_logprof = np.full_like(air_logprof, np.nan)

    for d in range(len(mopitt_colocated)):
        colm_sim[d] = apcolm[d] + colm_avkrn[d] @ (air_logprof[d] - ap_logprof[d])
        sim_logprof[d] = ap_logprof[d] + avkrn[d] @ (air_logprof[d] - ap_logprof[d])
    #sys.exit()


    # ========================================================================
    # Write out file
    # ========================================================================
    outfile = outfile_name_prefix+profile+f'.{distmax:.0f}km.dat'

    '''
    Write aircraft details as file header
    '''
    with open(outfile, 'w') as out_f:
        out_f.write(f"{proflat:8.1f}{proflon:8.1f}{int(profyr):6d}{int(profmo):6d}"
                    f"{int(profdy):6d}{int(profhr):6d}{int(profmn):6d}\n")
    print(outfile)

    '''
    Then write a pixel-by-pixel comparison to output file
    ---------------------------------
    Output format (6 lines per match):
    Line 1: Metadata (pixel num, surface info, column relevant data, quality and cloud flags)
    Line 2: Retrieved log(VMR) profile (10 levels)
    Line 3: Simulated log(VMR) profile (with AK applied to in-situ)
    Line 4: A priori log(VMR) profile
    Line 5: In-situ log(VMR) profile ???
    Line 6: Averaging kernel row sums (sensitivity)
    '''

    # ====================================================================
    # Build MOPITT column and metadata line
    # ====================================================================
    # Column format: [1]pixel_number [2]ISTR [3]surface_type [4]cloud_flag [5]surface_pressure
    #                [6] SZA [7] dist_from_aircraft [8] retrieved_column [9] simulated_column
    #                [10] a_priori_column [11] water_vapor_column [12] DFS [13] SNR5A [14] SNR6A 
    #                [15] SNR6R [16-20] five_anomaly_flags [21-22] two_cloud_diagnostics

    for d in range(len(mopitt_colocated)):
        print(d)
        metadata_line = (
            f"{pxsttrk[d][0]:4d}"
            f"{pxsttrk[d][1]:4d}"
            f"{int(isfc[d]):4d}"
            f"{int(icld[d]):4d}"
            f"{psfc[d]:8.1f}"
            f"{sza[d]:8.1f}"
            f"{dist_colocated[d]:8.1f}"
            f"{rtvcolm[d][0]:11.3e}"
            f"{colm_sim[d]:11.3e}"
            f"{apcolm[d]:11.3e}"
            f"{wvcolm[d]:11.3e}"
            f"{dfs[d]:7.4f}"
            f"{snr5a[d]:11.3e}"
            f"{snr6a[d]:11.3e}"
            f"{snr6r[d]:11.3e}"
            )

        # Add anomaly flags (5 flags)
        for i in range(5):
            metadata_line += f"{int(anom_flags[d][i]):3d}"

        # V9/V10: Include MODIS clear fraction and MOPITT cloud ratio
        metadata_line += f" {modisclrfrac[d]:9.4f}"
        metadata_line += f" {mopcldratio[d]:9.4f}"

        with open(outfile, 'a') as out_f:
            # Line 1: Metadata
            out_f.write(metadata_line + "\n")

            # ====================================================================
            # Add profile information
            # ====================================================================
            # Line 2: Retrieved log(VMR) profile
            out_f.write(" ")
            out_f.write(" ".join([f"{v:9.4f}" for v in rtv_logprof[d]]) + "\n")
    
            # Line 3: Simulated log(VMR) profile (with AK applied to in-situ)
            out_f.write(" ")
            out_f.write(" ".join([f"{v:9.4f}" for v in sim_logprof[d]]) + "\n")

            # Line 4: A priori log(VMR) profile
            out_f.write(" ")
            out_f.write(" ".join([f"{v:9.4f}" for v in ap_logprof[d]]) + "\n")

            # Line 5: In-situ log(VMR) profile
            out_f.write(" ")
            out_f.write(" ".join([f"{v:9.4f}" for v in air_logprof[d]]) + "\n")
    
            # Line 6: Averaging kernel row sums (sensitivity)
            out_f.write(" ")
            out_f.write(" ".join([f"{v:9.4f}" for v in ak_rowsum[d]]) + "\n")


    print(profile + ' compared')
    print('---------------')
    compared_profile.append(aircraft_meta_filtered[profile].loc['fname'])

# ========================================================================
#--- print filter results
# ========================================================================
print('####################################')
print('Filtering resulted in removed comparisons for some aircraft profiles.')
print('(1)    Aircraft profile filtering removed '+ str(cols_to_drop.shape[0]) + ' profiles')
print(cols_to_drop.values)
print('(2)    Missing ' + str(len(MOPITT_downtime)) + ' MOPITT files, specifically corresponding with profiles: ')
print(MOPITT_downtime)
print('(2a)    Missing ' + str(len(MERRA_missing)) + ' MERRA files for moist air calcs, specifically corresponding with profiles: ')
print(MERRA_missing)
print('(3)    Coarse spatial alignment removed '+str(len(coarse_filter))+' profiles ')
print(coarse_filter)
print('(4)    Fine temporal alignment removed '+str(len(fine_time_filter))+' profiles ')
print(fine_time_filter)
print('(5)    Fine spatial alignment removed '+str(len(fine_spatial_filter))+' profiles ')
print(fine_spatial_filter)
print('####################################')


# ========================================================================
# write out list of aircraft files compared
# ========================================================================

print('Compared ' + str(len(compared_profile)) + ' aircraft profiles out of a total of ' + str(len(aircraft_files)) + ' available.')

