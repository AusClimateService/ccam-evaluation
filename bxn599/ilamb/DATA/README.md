Scripts for preparing data for ILAMB

`prep_era5.py` and `submit_prep_era5.sh` concatenates ERA5 data from `/g/data/rt52` for specific variables
Note that rainfall (`tp`) needs to be converted to mm using `cdo -b F64 -mulc,1000. -setattribute,pr@units=mm`

`link_data.sh` makes the softlinks for icclim indices