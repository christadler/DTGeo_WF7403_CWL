#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Latest changes: 2025-07-15

@author: iris.christadler@lmu.de
"""


from obspy.clients.fdsn import Client
from obspy.clients.fdsn.header import FDSNNoDataException
from obspy import UTCDateTime
import sys
import os


# #################################################################################
# Exit Codes
# Exit Code   0: No Earthquake happened
# Exit Code   1: 1 EQ  happened -> launch Step4/5
# Exit Code   n: n EQs happened -> launch Step 4/5 with max magnitude EQ, send mail
# Exit Code 255: Some error happened, send email to check script 
# #################################################################################
#DEBUG=True
DEBUG=False

# Get current time 
t = UTCDateTime()

# TODO: Adjust timeframe and magnitude before going live 
# Set timeframe to 24 hours to check daily 
# or adjust to match the cronjob repeat rate 
# (1hour=60sec/min*60min) 
timeframe_hours= 24*7
#timeframe_hours= 1
timeframe= t-(timeframe_hours*3600)

# connect to client
client = Client("https://www.seismicportal.eu")

# try general event list
cat = client.get_events(starttime=timeframe)
#cat.plot(projection="global")
#cat.plot()

try:
    # #################################################################
    # catch events in the area (AltoTiberina, adjust for other areas)
    # #################################################################
    cat = client.get_events(starttime=timeframe, 
                            minlongitude=11.8,
                            maxlongitude=13.2,
                            minlatitude=41.9,
                            maxlatitude=43.8,
                            #eventtype="earthquake",
                            minmagnitude=2.0,
                            orderby="magnitude")
except FDSNNoDataException:
    print(f"{t}:No EQ reported since {timeframe}")
    sys.exit(0)
except Exception as e:
    print(f"{t}: Something bad happened (exception: {e} ), exiting with -1")    
    sys.exit(255)


# ######################
# Output
# ######################
if DEBUG: cat.plot() 
num_events= cat.count()
print(f"{t}: We found {num_events} events with the following timestamps: ")
print(cat) 
for event in cat:
    if DEBUG: print(event)  



# ###############################################
# call download_TABOO_waveforms.py/sh for cat[0]
# ###############################################

toe= cat[0].origins[0].time #time of EQ in UTCDateTime
eq_time=f"'{toe.year},{toe.month},{toe.day},{toe.hour},{toe.minute},{toe.second}'"

print(f"{t}: download_TABOO_waveforms called for EQ with highest magnitude ({eq_time}): ")
print(cat[0]) # EQ with highest magnitude

# delete folder content to only compare waveforms from the current earthquake
os.system(f"rm -f TABOO_waveforms/*.mseed")
os.system(f"rm -f TABOO_waveforms/*.xml")
# call download_TABOO_waveforms.py with eq_time, output_folder and duration
os.system(f"python3 download_TABOO_waveforms.py {eq_time} TABOO_waveforms 60 ")



# #########################################################
# call search_catalog_for_best_fit_model.py/sh for cat[0]
# #########################################################

print(f"{t}: search_catalog_for_best_fit_model.py called for EQ with highest magnitude ({eq_time}): ")
# call download_TABOO_waveforms.py with eq_time, output_folder and duration
ensemble_dir="AltoTiberinaCatalog"
os.system(f"python3 search_catalog_for_best_fit_model.py {eq_time} TABOO_waveforms {ensemble_dir} ")

# rerun model with higher resolution on supermuc?

sys.exit(num_events)

