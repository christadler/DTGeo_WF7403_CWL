# WF: Workflow
#   WF740301: catalog creation part
# SS: Software Step
#   SS?: SeisSol_ParamStudies
#   SS7401: SeisSol 
#   SS?: SeisSol_Postprocessing
# ST: Simulation Step (following gitlab entries)
#   ST740301 is currently Link to SDL AltoTiberina_Inputs (would actually be a DT)
#   ST740302 Assemble Input Parameters and Slurm Files (uses SeisSol_ParamStudies)
#   ST740303 Postprocessing of Catalog Data uses SeisSol_Postprocessing
#   ST74030302? Uploading of Catalog Data to the SDL
# DT: Data
#   DT740601: CSV File
#   DT740602: Directory with Input files and slurm scripts for all runs
#   DT740603: SDL AltoTiberina_Inputs (Mesh, asagi, change?)
#   DT740701: Full SeisSol outputs
#   DT740702: SDL AltoTiberina_Catalog  
# catalog creation part produces catalog that is needed for rapid-response-part
WF740301 input to WF740302
'''

## WF740301: Catalog Creation Part
# Block3.1 Geological and Geophysical Constraints
ST740301
DT7406 (I would suggest to rename to DT740301
should actually be the building of the input parameters 

Step ST740301:
  Use CSV File to build directory with input files
  Software:
    SeisSol_ParamStudy
  Input: 
    DT740601 CSV-File
  Output:
    DT740602 Directory with Input Files

# Block3.2 Forward Dynamic Simulations (the SeisSol simulations)
ST740302

Step ST740302:
  Use SeisSol to run the full catalog
  Software SS7401:
    SeisSol 
  Input:
    DT7406 Directory with Input Files
    DT SDL AltoTiberina_Inputs (do we need to download them first?)
  Output:
    DT740701 Full SeisSol_Output

# Block3.3 Postprocessing of Outputs (was "Ensemble Scenarios"?)    
ST740303
DT740701/02

ST740303:
  Use Postprocessing scripts and upload the data to SDL
  Software: 
    https://github.com/christadler/SeisSol_Postprocessing
  Input:
    DT740701 Full SeisSol_Output
  Output:
    DT740702: SDL AltoTiberina_Catalog

Remark: Do we need an extra Step to Up- & Download Data from SDL?
    


# WF: Workflow
#   WF740302: rapid response part
# SS: Software Step
#   SS??: https://github.com/marcmath/download_TABOO_waveforms
#   SS??: https://github.com/NicoSchlw/search_SeisSol_ensemble
# ST: Simulation Step (following gitlab entries)
#   ST74030401 detect event
#   ST74030402 download Taboo waveforms
#   ST740305 Find closest match
# DT: Data
#   DT740801 EventTime
#   DT7407 SDL AltoTiberina_Catalog
#   DT7408 dowloaded waveforms
#   DT7409 closest match


ST74030401:
# detect event
  Software: 
    detect_event.py
  Input:
    Current time
  Output:
    DT740801 Event_time

ST74030402:
# download waveforms
  Software: 
    download_TABOO_waveforms.py
  Input:
    DT740801 Event_time
  Output:
    DT7408 dowloaded waveforms

ST740305:
# Find closest match
  Software:
    search_SeisSol_ensemble.py
  Input:
    DT740801 Event_time
    DT7408 downloaded waveforms
    DT740701 SDL AltoTiberina_Catalog
  Output:
    DT7409 closest match



WF740301 input to WF740302

