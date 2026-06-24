# MOPITT V10 Validation
Code developed for this project includes algorithms to validate version 10 MOPITT carbon monoxide (CO) retrievals against aircraft-measured profiles.

To cite this codebase, please use:
> **Code DOI**: 

Latest version: TBD

Aircraft profiles are from NOAA, HIPPO and ATom, harmonized, altered and extended from raw experimental profiles.
> **Data DOI**: Martínez-Alonso, S., Deeter, M. N., Emmons, L., Tang, W., Mao, D., Ziskin, D., Buchholz, R. R., Jeffery, P., & Worden, H. M. (2026). Aircraft-measured carbon monoxide profiles for MOPITT V10 validation [Data set]. Zenodo. https://doi.org/10.5281/zenodo.20147785

## Methodology

Data processing and analysis is separated into several sections.

| Name | Description |
|:---------:|:------------:|
| [plotting](https://github.com/rrbuchholz/mopittv10/tree/main/plotting) | Folder containing code for generalized plotting. |
| [sample_data](https://github.com/rrbuchholz/mopittv10/tree/main/sample_data)  | Folder containing sample aircraft measurements from NOAA, HIPPO1 and ATom-1. On harmonized 35 layers.| 
| [sample_pairing](https://github.com/rrbuchholz/mopittv10/tree/main/sample_pairing)  | Folder containing sample pairing (smoothed) profiles between MOPITT and aircraft . On MOPITT 10 layers, and total column.| 
| [validation](https://github.com/rrbuchholz/mopittv10/tree/main/validation)  | Folder containing code to perform validation. | 


Validation code description.

| Name | Description |
|:---------:|:------------:|
| [original_IDL](https://github.com/rrbuchholz/mopittv10/tree/main/validation/original_IDL) | Folder: IDL code for test stations used for converting to python framework (val_L2_v10_noaa_test.pro, distance.pro). This location also houses a subfolder called SOFTWARE, that archives original IDL code used to validate previous versions of MOPITT. 
| [copilot_transformed](https://github.com/rrbuchholz/mopittv10/tree/main/validation/copilot_transformed) | Folder: Copilot transformation of IDL code as a starting point for refactoring code. | 
| [plot_vald_dlog_9levs_v10_v2.py](https://github.com/rrbuchholz/mopittv10/blob/main/validation/plot_vald_dlog_9levs_v10_v2.py) | Plot correlation plots of smoothed aircraft values against retrieved MOPITT values. Several layers and total column. | 

Plotting code description.

| Name | Description |
|:---------:|:------------:|
| [plot_aircraft_profiles_ATom.py](https://github.com/rrbuchholz/mopittv10/blob/main/plotting/plot_aircraft_profiles_ATom.py)  | Plot an average of ATom CO profiles. | 
| [plot_aircraft_profiles_HIPPO.py](https://github.com/rrbuchholz/mopittv10/blob/main/plotting/plot_aircraft_profiles_HIPPO.py) | Plot an average of HIPPO CO profiles. | 
|  [plot_aircraft_profiles_NOAA.py](https://github.com/rrbuchholz/mopittv10/blob/main/plotting/plot_aircraft_profiles_NOAA.py) | Plot an average of NOAA CO profiles. | 
