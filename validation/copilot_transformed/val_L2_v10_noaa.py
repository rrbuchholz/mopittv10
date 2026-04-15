import numpy as np
import h5py
import netCDF4 as nc
from datetime import datetime, timedelta
import glob
import os
from scipy.interpolate import interp1d
import sys

def distance(lat1, lon1, lat2, lon2):
    """
    Calculate great circle distance between two points in kilometers
    Using simplified haversine formula
    
    Parameters
    ----------
    lat1, lon1, lat2, lon2 : float
        Latitude and longitude in degrees
    
    Returns
    -------
    float
        Distance in kilometers
    """
    from math import radians, sin, cos, sqrt, atan2
    
    lat1_r, lon1_r, lat2_r, lon2_r = map(radians, [lat1, lon1, lat2, lon2])
    dlat = lat2_r - lat1_r
    dlon = lon2_r - lon1_r
    a = sin(dlat/2)**2 + cos(lat1_r) * cos(lat2_r) * sin(dlon/2)**2
    c = 2 * atan2(sqrt(a), sqrt(1-a))
    R = 6371.0  # Earth radius in km
    return R * c


def val_L2_v10_noaa(debug_level=0):
    """
    MOPITT CO Retrieval Validation against NOAA Ground Sites
    
    Matches MOPITT satellite CO retrievals with in-situ flask measurements
    from NOAA validation sites and writes comparison data files.
    
    Original IDL code by:
        - Merritt Deeter (circa 03.2022)
        - Sara Martinez-Alonso (08.2024)
        - Rebecca Buchholz (12.2025)
    
    Python conversion: 2025
    
    Parameters
    ----------
    debug_level : int, optional
        Verbosity level (0=silent, 1=progress, 2=detail, 3=full)
    """
    
    def dprint(message, level=1, indent=0):
        """Conditional debug print"""
        if debug_level >= level:
            prefix = "  " * indent
            print(f"{prefix}{message}", file=sys.stdout)
            sys.stdout.flush()
    
    dprint("=" * 80, level=1)
    dprint("Starting val_L2_v10_noaa() - MOPITT L2 Validation", level=1)
    dprint("=" * 80, level=1)
    
    # ========================================================================
    # CONFIGURATION PARAMETERS
    # ========================================================================
    
    nflaskmin = 5
    dprint(f"nflaskmin = {nflaskmin}", level=2)
    
    # V10 validation sites (hip and nsa missing from V9 list)
    sitecodes = ['aao', 'acg', 'act', 'bne', 'car', 'cma', 'crv', 'dnd', 'esp', 
                 'etl', 'haa', 'hfm', 'hil', 'lef', 'nha', 'pfa', 'rta', 'sca', 
                 'sgp', 'tgc', 'thd', 'tom', 'wbi', 'wgc']
    
    nsites = len(sitecodes)
    V8mode = 'F'  # Process V9/V10 files (not V8)
    missing_val = -999.
    
    dprint(f"Processing {nsites} sites", level=2)
    dprint(f"V8mode = {V8mode} (process V9/V10 cloud diagnostics)", level=2)
    
    # Thresholds for accepting MOPITT retrievals
    dlatmax = 2.5
    dlonmax = 2.5
    distmax = 50.  # km
    dthrsmax = 12.  # hours
    
    dprint(f"Spatial threshold: ±{dlatmax}° lat/lon, {distmax} km distance", level=2)
    dprint(f"Temporal threshold: ±{dthrsmax} hours", level=2)
    
    # ========================================================================
    # BEGIN SITE PROCESSING LOOP
    # ========================================================================
    
    for isite in range(nsites):
        sitecode = sitecodes[isite]
        dprint(f"\n{'='*80}", level=1)
        dprint(f"Processing site: {sitecode} ({isite+1}/{nsites})", level=1)
        dprint(f"{'='*80}", level=1)
        
        # Default pressure thresholds (can vary by site)
        p_top_thr = 450.
        p_bot_thr = 750.
        
        # Site-specific pressure thresholds
        if sitecode == 'rta':
            p_top_thr = 500.
            p_bot_thr = 700.
        elif sitecode in ['sgp', 'lef', 'esp']:
            p_top_thr = 550.
            p_bot_thr = 850.
        
        dprint(f"Pressure thresholds: top={p_top_thr} hPa, bottom={p_bot_thr} hPa", 
              level=2)
        
        # ====================================================================
        # Find NOAA validation profile files
        # ====================================================================
        
        profile_pattern = (f'/net/mopfl2021/MOPITT/project/mopsips/data/val/cmdl/profile/'
                          f'PROFILES_FOR_V9_VALIDATION/INTERPOLATED_PROFILES/{sitecode}/*.asc')
        
        valfiles = sorted(glob.glob(profile_pattern))
        nvalfiles = len(valfiles)
        
        dprint(f"Found {nvalfiles} profile files", level=2)
        
        if nvalfiles < 1:
            dprint(f"No profile files found for {sitecode}, skipping", level=1)
            continue
        
        # ====================================================================
        # LOOP OVER PROFILE FILES
        # ====================================================================
        
        for ivalfile in range(nvalfiles):
            dprint(f"\nProfile file {ivalfile+1}/{nvalfiles}", level=2, indent=1)
            
            valfile = valfiles[ivalfile]
            
            # ================================================================
            # Extract date/time from filename
            # ================================================================
            
            try:
                # Filename format: ...YYYY_MM_DD_HH_MM.asc
                basename = os.path.basename(valfile)
                filename_parts = basename.replace('.asc', '').split('_')
                
                # Get last 5 parts (YYYY, MM, DD, HH, MM)
                profyr = int(filename_parts[-5])
                profmo = int(filename_parts[-4])
                profdy = int(filename_parts[-3])
                profhr = int(filename_parts[-2])
                profmn = int(filename_parts[-1])
            
            except (ValueError, IndexError) as e:
                dprint(f"Error parsing filename date: {e}", level=1, indent=1)
                continue
            
            dprint(f"Profile: {profyr}-{profmo:02d}-{profdy:02d} {profhr:02d}:{profmn:02d}", 
                  level=2, indent=1)
            
            # ================================================================
            # Date filtering: 2010-2015 only
            # ================================================================
            
            if profyr < 2010 or profyr > 2015:
                dprint(f"Date outside range (2010-2015), skipping", level=2, indent=1)
                continue
            
            # ================================================================
            # Read in-situ profile
            # ================================================================
            
            try:
                with open(valfile, 'r') as f:
                    lines = f.readlines()
                
                if len(lines) < 7:
                    dprint(f"Insufficient header lines, skipping", level=2, indent=1)
                    continue
                
                # Parse header line (line 2, 0-indexed line 1)
                header_line = lines[1].split()
                proflat = float(header_line[0])
                proflon = float(header_line[1])
                p_obs_bot = float(header_line[2])
                p_obs_top = float(header_line[3])
                nflask = int(header_line[4])
                
                # Correct for longitude > 180°
                if proflon > 180.:
                    proflon = proflon - 360.
                
                dprint(f"Location: lat={proflat:.2f}°, lon={proflon:.2f}°, "
                      f"nflask={nflask}", level=2, indent=1)
                
                # Check quality thresholds
                if (p_obs_top > p_top_thr or p_obs_bot < p_bot_thr or 
                    nflask < nflaskmin):
                    dprint(f"QA check failed: p_top={p_obs_top:.1f}, p_bot={p_obs_bot:.1f}, "
                          f"nflask={nflask} (min={nflaskmin})", level=2, indent=1)
                    continue
                
                # Read profile data (pressure, VMR pairs)
                profile_data = []
                for line in lines[6:]:
                    if line.strip():
                        parts = line.split()
                        if len(parts) >= 2:
                            try:
                                profile_data.append([float(parts[0]), float(parts[1])])
                            except ValueError:
                                continue
                
                if len(profile_data) < 1:
                    dprint(f"No profile data read, skipping", level=2, indent=1)
                    continue
                
                profile_data = np.array(profile_data)
                valprs = profile_data[:, 0]  # Pressure (hPa)
                valvmr = profile_data[:, 1]  # CO VMR (ppv)
                
                dprint(f"Profile: {len(valprs)} levels, {valprs.min():.1f}-{valprs.max():.1f} hPa", 
                      level=2, indent=1)
            
            except Exception as e:
                dprint(f"Error reading profile file: {e}", level=1, indent=1)
                continue
            
            # ================================================================
            # Get MERRA-2 water vapor data
            # ================================================================
            
            try:
                dprint(f"Reading MERRA-2 data...", level=2, indent=1)
                
                # MERRA-2 file path pattern
                merra_dir = f'/MOPITT/project/datasets/merra2-nc4/{profyr:04d}{profmo:02d}/'
                merra_pattern = (f'{merra_dir}svc_MERRA2_*.inst6_3d_ana_Np.'
                                f'{profyr:04d}{profmo:02d}{profdy:02d}.nc4')
                
                merra_files = glob.glob(merra_pattern)
                if not merra_files:
                    dprint(f"MERRA-2 file not found", level=2, indent=1)
                    continue
                
                ncfile = merra_files[0]
                dprint(f"MERRA-2: {os.path.basename(ncfile)}", level=3, indent=1)
                
                # Read MERRA-2 data
                with nc.Dataset(ncfile, 'r') as ds:
                    lev = ds.variables['lev'][:]      # Pressure levels (42 levels, 1000-0.1 hPa)
                    lat = ds.variables['lat'][:]      # Latitude (361 points, -90 to 90)
                    lon = ds.variables['lon'][:]      # Longitude (576 points, -180 to 179.375)
                    spechum = ds.variables['QV'][:]   # Specific humidity (kg/kg), shape: (lon, lat, lev, time)
                
                nlev = len(lev)
                
                # Find nearest grid point to profile location
                dlat = np.abs(lat - proflat)
                ilat = np.argmin(dlat)
                
                dlon = np.abs(lon - proflon)
                ilon = np.argmin(dlon)
                
                dprint(f"MERRA-2 grid: lat={lat[ilat]:.2f}°, lon={lon[ilon]:.2f}°", 
                      level=3, indent=1)
                
                # Extract specific humidity profile at nearest point
                # spechum shape: (nlon, nlat, nlev, ntime)
                spechum_profile = spechum[ilon, ilat, :, :]
                
                # Check for missing values
                if np.any(spechum_profile < 0.):
                    dprint(f"Negative specific humidity found, skipping", level=2, indent=1)
                    continue
                
                # Compute daily mean H2O VMR profile (ppv)
                # Average first 4 times of day (0, 6, 12, 18 UTC)
                vmr = np.zeros(nlev)
                for ilev_m in range(nlev):
                    # Get first 4 time slices
                    tmp = spechum_profile[ilev_m, 0:4]
                    # Filter valid values (0 <= q < 0.1)
                    valid = tmp[(tmp >= 0.) & (tmp < 0.1)]
                    if len(valid) > 0:
                        # Convert specific humidity to VMR
                        # VMR = q / (1 - q) * (1/0.622) ≈ q / 0.622
                        vmr[ilev_m] = np.mean(valid) / 0.622
                    else:
                        vmr[ilev_m] = 0.
                
                vmr_valid = vmr[vmr > 0.]
                if len(vmr_valid) > 0:
                    dprint(f"MERRA-2 H2O VMR: {np.min(vmr_valid):.6f}-{np.max(vmr):.6f} ppv", 
                          level=3, indent=1)
                
                # Interpolate H2O VMR to in-situ profile levels
                # Only interpolate up to first 32 levels to avoid extrapolation issues
                if len(valprs) > 32:
                    valprs32 = valprs[0:32]
                else:
                    valprs32 = valprs
                
                # Create interpolation function (pressure must be monotonic)
                # MERRA-2 levels: pressure decreases from ~1000 hPa to ~0.1 hPa
                f_vmr = interp1d(lev, vmr, kind='linear', bounds_error=False, 
                                fill_value='extrapolate')
                vmrh2o = f_vmr(valprs32)
                vmrh2o = np.clip(vmrh2o, 0., None)  # Ensure non-negative
                
                # Convert dry-air VMR to moist-air VMR
                # moist_VMR = dry_VMR * (1 - H2O_VMR)
                valvmr_orig = valvmr.copy()
                for jlev in range(len(valprs32)):
                    valvmr[jlev] = valvmr_orig[jlev] * (1. - vmrh2o[jlev])
                
                # Apply same H2O correction to remaining levels using last H2O value
                if len(valprs) > 32:
                    for jlev in range(32, len(valprs)):
                        valvmr[jlev] = valvmr_orig[jlev] * (1. - vmrh2o[-1])
                
                dprint(f"Converted dry-air to moist-air VMR", level=3, indent=1)
            
            except Exception as e:
                dprint(f"Error reading MERRA-2 data: {e}", level=1, indent=1)
                continue
            
            # ================================================================
            # Find matching MOPITT L2 files
            # ================================================================
            
            l2_pattern = (f'/MOPITT/VALIDATION/ArchiveV10T/L2_9/'
                         f'{profyr:04d}{profmo:02d}/{profmo:02d}{profdy:02d}/MOP02T-*L2V28.0.1.he5')
            
            l2files = sorted(glob.glob(l2_pattern))
            nl2files = len(l2files)
            
            dprint(f"Found {nl2files} MOPITT L2 files", level=2, indent=1)
            
            if nl2files < 1:
                dprint(f"No MOPITT L2 files found, skipping", level=2, indent=1)
                continue
            
            # ================================================================
            # Create output file
            # ================================================================
            
            outfile = (f'/home/buchholz/MOPITTv10/MOPITT_Validation/validation_pairing/'
                      f'val_L2_v10.L2V19.9.2.{sitecode}.{profyr:04d}{profmo:02d}{profdy:02d}.'
                      f'{profhr:02d}{profmn:02d}.50km.dat')
            
            # Ensure output directory exists
            outdir = os.path.dirname(outfile)
            os.makedirs(outdir, exist_ok=True)
            
            dprint(f"Output: {os.path.basename(outfile)}", level=2, indent=1)
            
            # ================================================================
            # LOOP OVER L2 FILES AND EXTRACT DATA
            # ================================================================
            
            nmatch_total = 0
            
            try:
                with open(outfile, 'w') as out_f:
                    # Write header line
                    out_f.write(f"{proflat:8.1f}{proflon:8.1f}{profyr:6d}{profmo:6d}"
                               f"{profdy:6d}{profhr:6d}{profmn:6d}\n")
                    
                    # Loop over L2 files
                    for il2file in range(nl2files):
                        l2file = l2files[il2file]
                        
                        if debug_level >= 3:
                            dprint(f"Reading L2 {il2file+1}/{nl2files}: "
                                  f"{os.path.basename(l2file)}", level=3, indent=2)
                        
                        try:
                            # ================================================
                            # Read HDF5 L2 file
                            # ================================================
                            
                            with h5py.File(l2file, 'r') as hdf:
                                # Read geolocation data
                                try:
                                    moplat = hdf['/HDFEOS/SWATHS/MOP02/Geolocation Fields/Latitude'][:]
                                    moplon = hdf['/HDFEOS/SWATHS/MOP02/Geolocation Fields/Longitude'][:]
                                except KeyError:
                                    dprint(f"Missing geolocation fields, skipping L2 file", 
                                          level=2, indent=2)
                                    continue
                                
                                # Find pixels in 5°×5° box around validation site
                                ibox = np.where((np.abs(moplat - proflat) < dlatmax) & 
                                              (np.abs(moplon - proflon) < dlonmax))[0]
                                
                                if len(ibox) < 1:
                                    continue
                                
                                dprint(f"Found {len(ibox)} pixels in search box", 
                                      level=3, indent=2)
                                
                                # Read all required HDF5 datasets
                                try:
                                    secs = hdf['/HDFEOS/SWATHS/MOP02/Geolocation Fields/SecondsinDay'][:]
                                    pxsttrk = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/SwathIndex'][:]
                                    isfc = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/SurfaceIndex'][:]
                                    prs = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/PressureGrid'][:]
                                    psfc = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/SurfacePressure'][:]
                                    sza = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/SolarZenithAngle'][:]
                                    dfs = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/DegreesofFreedomforSignal'][:]
                                    approfl = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/APrioriCOMixingRatioProfile'][:]
                                    apsfcmr = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/APrioriCOSurfaceMixingRatio'][:]
                                    rtvprofl = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/RetrievedCOMixingRatioProfile'][:]
                                    rtvsfcmr = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/RetrievedCOSurfaceMixingRatio'][:]
                                    rtvcolm = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/RetrievedCOTotalColumn'][:]
                                    apcolm = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/APrioriCOTotalColumn'][:]
                                    avkrn = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/RetrievalAveragingKernelMatrix'][:]
                                    colm_avkrn = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/TotalColumnAveragingKernel'][:]
                                    avkrn_sums = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/AveragingKernelRowSums'][:]
                                    rads_errs = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/Level1RadiancesandErrors'][:]
                                    wvcolm = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/WaterVaporColumn'][:]
                                    anom_flags = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/RetrievalAnomalyDiagnostic'][:]
                                    icld = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/CloudDescription'][:]
                                
                                except KeyError as e:
                                    dprint(f"Missing required dataset: {e}", level=2, indent=2)
                                    continue
                                
                                # Read cloud diagnostics (V9/V10 only)
                                if V8mode != 'T':
                                    try:
                                        modiscld = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/MODISCloudDiagnostics'][:]
                                        mopcldratio = hdf['/HDFEOS/SWATHS/MOP02/Data Fields/MOPCldRadRatio'][:]
                                        # Cloud clear fraction from index 4
                                        modisclrfrac = modiscld[4, :] / 100.
                                    except KeyError:
                                        dprint(f"Missing cloud diagnostic datasets", level=2, indent=2)
                                        modisclrfrac = np.full(len(psfc), missing_val)
                                        mopcldratio = np.full(len(psfc), missing_val)
                                
                                # ================================================
                                # Handle HDF5 array shapes (h5py uses C-ordering)
                                # ================================================
                                
                                # HDF5 datasets are read in C-order (row-major)
                                # Multi-dimensional arrays need reshaping
                                
                                # avkrn: shape (npix, 10, 10) from h5py
                                # Need to transpose for pixel indexing to work correctly
                                avkrn = np.moveaxis(avkrn, 0, -1)  # (10, 10, npix)
                                
                                # approfl: shape (npix, 10) -> (10, npix)
                                approfl = approfl.T
                                rtvprofl = rtvprofl.T
                                
                                # anom_flags: shape (npix, 5) -> (5, npix)
                                anom_flags = anom_flags.T
                                
                                # colm_avkrn: shape (npix, 10) -> (10, npix)
                                colm_avkrn = colm_avkrn.T
                                
                                # avkrn_sums: shape (npix, 10) -> (10, npix)
                                avkrn_sums = avkrn_sums.T
                                
                                # rads_errs: shape (npix, nbands, 2) -> (nbands, 2, npix)
                                rads_errs = np.moveaxis(rads_errs, 0, -1)
                                
                                # ================================================
                                # Calculate SNR from radiances
                                # ================================================
                                
                                rad_5A = rads_errs[3, 0, :]    # Band 5A radiance
                                rad_uncy_5A = rads_errs[3, 1, :]
                                rad_6A = rads_errs[9, 0, :]    # Band 6A radiance
                                rad_uncy_6A = rads_errs[9, 1, :]
                                rad_6D = rads_errs[11, 0, :]   # Band 6D radiance
                                rad_uncy_6D = rads_errs[11, 1, :]
                                
                                # Calculate SNR (signal-to-noise ratio)
                                snr5a = np.where(rad_uncy_5A > 0, rad_5A / rad_uncy_5A, -999.)
                                snr6a = np.where(rad_uncy_6A > 0, rad_6A / rad_uncy_6A, -999.)
                                snr6r = np.where(rad_uncy_6D > 0, rad_6A / rad_uncy_6D, -999.)
                                
                                # Mark nighttime (negative radiances) as invalid
                                snr6a[rad_6A < 0.] = -999.
                                snr6r[rad_6A < 0.] = -999.
                                
                                # ================================================
                                # Process each matched pixel
                                # ================================================
                                
                                for j in range(len(ibox)):
                                    jpx = ibox[j]
                                    
                                    # Calculate distance and time offset
                                    dist = distance(moplat[jpx], moplon[jpx], 
                                                   proflat, proflon)
                                    
                                    dthrs = secs[jpx] / 3600. - (profhr + profmn / 60.)
                                    
                                    # Check proximity constraints
                                    if dist > distmax or abs(dthrs) > dthrsmax:
                                        continue
                                    
                                    dprint(f"Match: dist={dist:.1f} km, dthrs={dthrs:.2f} h", 
                                          level=3, indent=3)
                                    
                                    # ============================================
                                    # CASE 1: psfc > 900 mb (use all 10 levels)
                                    # ============================================
                                    
                                    if psfc[jpx] > prs[0]:
                                        prtv = np.concatenate([[psfc[jpx]], prs[0:9]])
                                        ak1 = avkrn[0:10, 0:10, jpx].T
                                        
                                        # Extract and check a priori and retrieval profiles
                                        ap_vals = np.concatenate([[apsfcmr[0, jpx]], 
                                                                  approfl[0:9, jpx]])
                                        rtv_vals = np.concatenate([[rtvsfcmr[0, jpx]], 
                                                                   rtvprofl[0:9, jpx]])
                                        
                                        if np.any(ap_vals <= 0.) or np.any(rtv_vals <= 0.):
                                            dprint(f"Negative VMR in a priori or retrieval", 
                                                  level=3, indent=3)
                                            continue
                                        
                                        # Convert to log-VMR (log10)
                                        ap1 = np.log10(ap_vals)
                                        rtv1 = np.log10(rtv_vals)
                                        
                                        # Average in-situ VMR to satellite pressure levels
                                        valvmrint = np.full(10, -999.)
                                        
                                        for ilev in range(9):
                                            # Find in-situ levels between satellite levels
                                            ilyr = np.where((valprs <= prtv[ilev]) & 
                                                          (valprs > prtv[ilev+1]))[0]
                                            if len(ilyr) < 1:
                                                # Use closest level above
                                                ilyr = np.where(valprs > prtv[ilev])[0]
                                            if len(ilyr) > 0:
                                                valvmrint[ilev] = np.mean(valvmr[ilyr])
                                        
                                        # 100 hPa level = 50-100 hPa layer average
                                        ilyr100 = np.where((valprs > 50.) & 
                                                          (valprs <= 100.))[0]
                                        if len(ilyr100) > 0:
                                            valvmrint[9] = np.mean(valvmr[ilyr100])
                                        
                                        if np.any(valvmrint <= 0.):
                                            continue
                                        
                                        logvalvmr = np.log10(valvmrint)
                                        
                                        # Apply averaging kernel to in-situ data
                                        # simprof = ap1 + AK @ (logvalvmr - ap1)
                                        simprof = ap1 + ak1 @ (logvalvmr - ap1)
                                        
                                        # Simulated column
                                        colm_ap = apcolm[jpx]
                                        ak_colm = colm_avkrn[0:10, jpx]
                                        colm_sim = colm_ap + ak_colm @ (logvalvmr - ap1)
                                        
                                        akrowsum = avkrn_sums[0:10, jpx]
                                        
                                        # Write output
                                        write_match(out_f, jpx, pxsttrk, isfc, icld, psfc, 
                                                   sza, dist, rtvcolm, colm_sim, apcolm, 
                                                   wvcolm, dfs, snr5a, snr6a, snr6r, 
                                                   anom_flags, V8mode, modisclrfrac, 
                                                   mopcldratio, missing_val, rtv1, simprof, 
                                                   ap1, logvalvmr, akrowsum)
                                        
                                        nmatch_total += 1
                                    
                                    # ============================================
                                    # CASE 2: 800 < psfc <= 900 mb (use 9 levels)
                                    # ============================================
                                    
                                    elif psfc[jpx] < prs[0] and psfc[jpx] > prs[1]:
                                        prtv = np.concatenate([[psfc[jpx]], prs[1:9]])
                                        ak1 = avkrn[1:10, 1:10, jpx].T
                                        
                                        ap_vals = np.concatenate([[apsfcmr[0, jpx]], 
                                                                  approfl[1:9, jpx]])
                                        rtv_vals = np.concatenate([[rtvsfcmr[0, jpx]], 
                                                                   rtvprofl[1:9, jpx]])
                                        
                                        if np.any(ap_vals <= 0.) or np.any(rtv_vals <= 0.):
                                            continue
                                        
                                        ap1 = np.log10(ap_vals)
                                        rtv1 = np.log10(rtv_vals)
                                        
                                        valvmrint = np.full(9, -999.)
                                        
                                        for ilev in range(8):
                                            ilyr = np.where((valprs <= prtv[ilev]) & 
                                                          (valprs > prtv[ilev+1]))[0]
                                            if len(ilyr) < 1:
                                                ilyr = np.where(valprs > prtv[ilev])[0]
                                            if len(ilyr) > 0:
                                                valvmrint[ilev] = np.mean(valvmr[ilyr])
                                        
                                        ilyr100 = np.where((valprs > 50.) & 
                                                          (valprs <= 100.))[0]
                                        if len(ilyr100) > 0:
                                            valvmrint[8] = np.mean(valvmr[ilyr100])
                                        
                                        if np.any(valvmrint <= 0.):
                                            continue
                                        
                                        logvalvmr = np.log10(valvmrint)
                                        simprof = ap1 + ak1 @ (logvalvmr - ap1)
                                        
                                        colm_ap = apcolm[jpx]
                                        ak_colm = colm_avkrn[1:10, jpx]
                                        colm_sim = colm_ap + ak_colm @ (logvalvmr - ap1)
                                        
                                        # Pad to 10 levels for output
                                        rtv1_10lv = np.concatenate([[rtv1[0]], [-9.999], rtv1[1:9]])
                                        simprof_10lv = np.concatenate([[simprof[0]], [-9.999], 
                                                                       simprof[1:9]])
                                        ap1_10lv = np.concatenate([[ap1[0]], [-9.999], ap1[1:9]])
                                        logvalvmr_10lv = np.concatenate([[logvalvmr[0]], [-9.999], 
                                                                         logvalvmr[1:9]])
                                        akrowsum_10lv = np.concatenate([[avkrn_sums[1, jpx]], 
                                                                        [-9.999], 
                                                                        avkrn_sums[2:10, jpx]])
                                        
                                        write_match(out_f, jpx, pxsttrk, isfc, icld, psfc, 
                                                   sza, dist, rtvcolm, colm_sim, apcolm, 
                                                   wvcolm, dfs, snr5a, snr6a, snr6r, 
                                                   anom_flags, V8mode, modisclrfrac, 
                                                   mopcldratio, missing_val, rtv1_10lv, 
                                                   simprof_10lv, ap1_10lv, logvalvmr_10lv, 
                                                   akrowsum_10lv)
                                        
                                        nmatch_total += 1
                                    
                                    # ============================================
                                    # CASE 3: 700 < psfc <= 800 mb (use 8 levels)
                                    # ============================================
                                    
                                    elif psfc[jpx] < prs[1] and psfc[jpx] > prs[2]:
                                        prtv = np.concatenate([[psfc[jpx]], prs[2:9]])
                                        ak1 = avkrn[2:10, 2:10, jpx].T
                                        
                                        ap_vals = np.concatenate([[apsfcmr[0, jpx]], 
                                                                  approfl[2:9, jpx]])
                                        rtv_vals = np.concatenate([[rtvsfcmr[0, jpx]], 
                                                                   rtvprofl[2:9, jpx]])
                                        
                                        if np.any(ap_vals <= 0.) or np.any(rtv_vals <= 0.):
                                            continue
                                        
                                        ap1 = np.log10(ap_vals)
                                        rtv1 = np.log10(rtv_vals)
                                        
                                        valvmrint = np.full(8, -999.)
                                        
                                        for ilev in range(7):
                                            ilyr = np.where((valprs <= prtv[ilev]) & 
                                                          (valprs > prtv[ilev+1]))[0]
                                            if len(ilyr) < 1:
                                                ilyr = np.where(valprs > prtv[ilev])[0]
                                            if len(ilyr) > 0:
                                                valvmrint[ilev] = np.mean(valvmr[ilyr])
                                        
                                        ilyr100 = np.where((valprs > 50.) & 
                                                          (valprs <= 100.))[0]
                                        if len(ilyr100) > 0:
                                            valvmrint[7] = np.mean(valvmr[ilyr100])
                                        
                                        if np.any(valvmrint <= 0.):
                                            continue
                                        
                                        logvalvmr = np.log10(valvmrint)
                                        simprof = ap1 + ak1 @ (logvalvmr - ap1)
                                        
                                        colm_ap = apcolm[jpx]
                                        ak_colm = colm_avkrn[2:10, jpx]
                                        colm_sim = colm_ap + ak_colm @ (logvalvmr - ap1)
                                        
                                        # Pad to 10 levels for output
                                        rtv1_10lv = np.concatenate([[rtv1[0]], [-9.999, -9.999], 
                                                                    rtv1[1:8]])
                                        simprof_10lv = np.concatenate([[simprof[0]], 
                                                                       [-9.999, -9.999], 
                                                                       simprof[1:8]])
                                        ap1_10lv = np.concatenate([[ap1[0]], [-9.999, -9.999], 
                                                                   ap1[1:8]])
                                        logvalvmr_10lv = np.concatenate([[logvalvmr[0]], 
                                                                         [-9.999, -9.999], 
                                                                         logvalvmr[1:8]])
                                        akrowsum_10lv = np.concatenate([[avkrn_sums[2, jpx]], 
                                                                        [-9.999, -9.999], 
                                                                        avkrn_sums[3:10, jpx]])
                                        
                                        write_match(out_f, jpx, pxsttrk, isfc, icld, psfc, 
                                                   sza, dist, rtvcolm, colm_sim, apcolm, 
                                                   wvcolm, dfs, snr5a, snr6a, snr6r, 
                                                   anom_flags, V8mode, modisclrfrac, 
                                                   mopcldratio, missing_val, rtv1_10lv, 
                                                   simprof_10lv, ap1_10lv, logvalvmr_10lv, 
                                                   akrowsum_10lv)
                                        
                                        nmatch_total += 1
                        
                        except Exception as e:
                            dprint(f"Error reading L2 file: {e}", level=2, indent=2)
                            continue
            
            except Exception as e:
                dprint(f"Error writing output file: {e}", level=1, indent=1)
                continue
            
            # ================================================================
            # Remove empty output files
            # ================================================================
            
            try:
                with open(outfile, 'r') as f:
                    nlines = len(f.readlines())
                
                if nlines <= 2:  # Only header, no data
                    os.remove(outfile)
                    dprint(f"Removed empty file (only {nlines} lines)", level=2, indent=1)
                else:
                    dprint(f"Output file: {nlines} lines, {nmatch_total} matches", 
                          level=1, indent=1)
            except Exception as e:
                dprint(f"Error checking output file: {e}", level=2, indent=1)
    
    # ========================================================================
    # FINISHED
    # ========================================================================
    
    dprint("\n" + "=" * 80, level=1)
    dprint("Validation processing completed", level=1)
    dprint("=" * 80, level=1)


def write_match(out_f, jpx, pxsttrk, isfc, icld, psfc, sza, dist, rtvcolm, colm_sim, 
               apcolm, wvcolm, dfs, snr5a, snr6a, snr6r, anom_flags, V8mode, 
               modisclrfrac, mopcldratio, missing_val, rtv1, simprof, ap1, logvalvmr, 
               akrowsum):
    """
    Write a single pixel comparison to output file
    
    Output format (6 lines per match):
    Line 1: Metadata (pixel, surface, pressure, angles, quality flags, cloud diagnostics)
    Line 2: Retrieved log(VMR) profile (10 levels)
    Line 3: Simulated log(VMR) profile (with AK applied to in-situ)
    Line 4: A priori log(VMR) profile
    Line 5: In-situ log(VMR) profile
    Line 6: Averaging kernel row sums (sensitivity)
    
    Parameters
    ----------
    out_f : file object
        Open output file
    jpx : int
        Pixel index
    pxsttrk : ndarray
        Pixel/swath tracking info, shape (2, npix)
    isfc : ndarray
        Surface index, shape (npix,)
    icld : ndarray
        Cloud description, shape (npix,)
    psfc : ndarray
        Surface pressure, shape (npix,)
    sza : ndarray
        Solar zenith angle, shape (npix,)
    dist : float
        Distance from validation site (km)
    rtvcolm : ndarray
        Retrieved CO total column, shape (npix,)
    colm_sim : float
        Simulated CO total column
    apcolm : ndarray
        A priori CO total column, shape (npix,)
    wvcolm : ndarray
        Water vapor column, shape (npix,)
    dfs : ndarray
        Degrees of freedom for signal, shape (npix,)
    snr5a : ndarray
        Signal-to-noise ratio band 5A, shape (npix,)
    snr6a : ndarray
        Signal-to-noise ratio band 6A, shape (npix,)
    snr6r : ndarray
        Signal-to-noise ratio 6A/6D, shape (npix,)
    anom_flags : ndarray
        Anomaly diagnostic flags, shape (5, npix)
    V8mode : str
        'T' for V8 files, 'F' for V9/V10
    modisclrfrac : ndarray
        MODIS cloud clear fraction, shape (npix,)
    mopcldratio : ndarray
        MOPITT cloud radiance ratio, shape (npix,)
    missing_val : float
        Missing value indicator
    rtv1 : ndarray
        Retrieved log(VMR) profile (10 levels)
    simprof : ndarray
        Simulated log(VMR) profile (10 levels)
    ap1 : ndarray
        A priori log(VMR) profile (10 levels)
    logvalvmr : ndarray
        In-situ log(VMR) profile (10 levels)
    akrowsum : ndarray
        Averaging kernel row sums (10 levels)
    """
    
    # Extract pixel indices from pxsttrk
    # pxsttrk shape: (2, npix) where [0,:] = pixel, [1,:] = swath
    pxl = int(pxsttrk[0, jpx])
    str_arr = int(pxsttrk[1, jpx])
    
    # ====================================================================
    # Build metadata line
    # ====================================================================
    
    # Ensure values are within expected ranges
    psfc_val = float(psfc[jpx])
    sza_val = float(sza[jpx])
    dfs_val = int(dfs[jpx])
    wvcolm_val = float(wvcolm[jpx])
    rtvcolm_val = float(rtvcolm[jpx])
    apcolm_val = float(apcolm[jpx])
    
    # Format: IPXL ISTR ISFC ICLD PSFC SZA DIST RTVCOLM COLM_SIM APCOLM WVCOLM DFS SNR5A SNR6A SNR6R FLAGS CLOUD_DIAG
    
    metadata_line = (
        f"{pxl:4d}"
        f"{str_arr:4d}"
        f"{int(isfc[jpx]):4d}"
        f"{int(icld[jpx]):4d}"
        f"{psfc_val:8.1f}"
        f"{sza_val:8.1f}"
        f"{dist:8.1f}"
        f"{rtvcolm_val:11.3e}"
        f"{colm_sim:11.3e}"
        f"{apcolm_val:11.3e}"
        f"{wvcolm_val:11.3e}"
        f"{dfs_val:7.4f}"
    )
    
    # Add SNR values
    metadata_line += f" {snr5a[jpx]:10.3e}"
    metadata_line += f" {snr6a[jpx]:10.3e}"
    metadata_line += f" {snr6r[jpx]:10.3e}"
    
    # Add anomaly flags (5 flags)
    for i in range(5):
        metadata_line += f"{int(anom_flags[i, jpx]):3d}"
    
    # Add cloud diagnostics based on V8mode
    if V8mode != 'T':
        # V9/V10: Include MODIS clear fraction and MOPITT cloud ratio
        metadata_line += f" {modisclrfrac[jpx]:9.4f}"
        metadata_line += f" {mopcldratio[jpx]:9.4f}"
    else:
        # V8: Use missing values for cloud diagnostics
        metadata_line += f" {missing_val:9.4f}"
        metadata_line += f" {missing_val:9.4f}"
    
    # Write metadata line
    out_f.write(metadata_line + "\n")
    
    # ====================================================================
    # Write profile data lines
    # ====================================================================
    
    # Line 2: Retrieved log(VMR) profile
    out_f.write(" ".join([f"{v:10.4f}" for v in rtv1]) + "\n")
    
    # Line 3: Simulated log(VMR) profile (with AK applied to in-situ)
    out_f.write(" ".join([f"{v:10.4f}" for v in simprof]) + "\n")
    
    # Line 4: A priori log(VMR) profile
    out_f.write(" ".join([f"{v:10.4f}" for v in ap1]) + "\n")
    
    # Line 5: In-situ log(VMR) profile
    out_f.write(" ".join([f"{v:10.4f}" for v in logvalvmr]) + "\n")
    
    # Line 6: Averaging kernel row sums (sensitivity)
    out_f.write(" ".join([f"{v:10.4f}" for v in akrowsum]) + "\n")


if __name__ == "__main__":
    """
    MOPITT CO Retrieval Validation Processing
    
    Usage:
        python val_L2_v10_noaa.py
    
    Debug levels:
        0 = Silent (default, for production runs)
        1 = High-level progress
        2 = Medium detail
        3 = Full detail (verbose)
    
    Examples:
        # Production run (no output)
        python val_L2_v10_noaa.py
        
        # With progress messages
        # Modify debug_level in call below to 1, then:
        python val_L2_v10_noaa.py
        
        # Or call from another script:
        from val_L2_v10_noaa import val_L2_v10_noaa
        val_L2_v10_noaa(debug_level=2)
    """
    
    # Run with specified debug level
    val_L2_v10_noaa(debug_level=1)
