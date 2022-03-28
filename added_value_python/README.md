# Added value Python scripts
Python added value scripts kindly shared by Christian Stassen.

Currently only plots/analyses Central/Eastern Australia (Western Australia is cut off due to BARPA?). 

May be some issues with AV calculation, does not square root the GDD/RCM difference with OBS, in lib_added_value.py, see:
def AVse(X_obs, X_gdd, X_rcm):