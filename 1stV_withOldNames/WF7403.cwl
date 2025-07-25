#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

requirements:
  MultipleInputFeatureRequirement: {} 
  SubworkflowFeatureRequirement: {} #only if subworkflows are used

inputs:
  DT740601:
    doc: "CSV File to generate input files for catalog"
    type: File
  DT740603:
    doc: "SDL-Data AltoTiberina_Inputs contains mesh and asagi for SeisSol"
    type: Directory
  Current_Time:
    doc: "Current Time since ST74030401 needs at least one input parameter"
    type: File

outputs:
  SDL_AltoTiberina_Catalog:
    doc: "SDL AltoTiberina_Catalog."
    type: Directory
    outputSource: ST740303/SDL_AltoTiberina_Catalog
  Event_Time:
    doc: "Event time."
    type: File
    outputSource: ST74030401/Event_Time
  Waveforms:
    doc: "Downloaded waveforms."
    type: Directory
    outputSource: ST74030402/Waveforms
  Closest_Match:
    doc: "Single dynamic rupture scenario."
    type: File
    outputSource: ST740305/Closest_Match

steps:
  ST740301:
    doc: "Use CSV File to build directory with input files."
    in:
      InputData: DT740601 #CSV File
    run:
      class: Operation
      inputs:
          InputData: File
      outputs:
          SeisSolInputFiles: Directory
    out:
      - SeisSolInputFiles

  ST740302:
    doc: "Use SeisSol to generate catalog entries."
    in:
      SeisSolInputFiles: ST740301/SeisSolInputFiles #Output from step before
      MeshAsagi: DT740603                           #SDL AltoTiberina_Inputs (mesh+asagi)
    run:
      class: Operation             #Use SeisSol with slurm scripts
      inputs:
          SeisSolInputFiles: Directory
          MeshAsagi: Directory
      outputs:
          FullSeisSolOutput: Directory
    out:
      - FullSeisSolOutput


  ST740303:
    doc: "Postprocessing of Outputs."
    in:
      FullSeisSolOutput: ST740302/FullSeisSolOutput #Output from step before
    run:
      class: Operation             #Use Postprocessing script and prepare Upload for SDL
      inputs:
          FullSeisSolOutput: Directory
      outputs:
          SDL_AltoTiberina_Catalog: Directory
    out:
      - SDL_AltoTiberina_Catalog

  ST74030401:
    doc: "Detect Event."
    in: #no input data (only current time needed)
      InputData: Current_Time
    run:
      class: Operation             #detect_event.py
      inputs:
          InputData: File
      outputs:
          Event_Time: File         #string?
    out:
      - Event_Time

  ST74030402:
    doc: "Download Waveforms."
    in:
      Event_Time: ST74030401/Event_Time    #Event_Time
    run:
      class: Operation             #download_TABOO_waveforms.py
      inputs:
          Event_Time: File
      outputs:
          Waveforms: Directory
    out:
      - Waveforms

  ST740305:
    doc: "Find closest match."
    in:
      SDL_AltoTiberina_Catalog: ST740303/SDL_AltoTiberina_Catalog #SDL AltoTiberina_Catalog
      Event_Time: ST74030401/Event_Time  #Event_Time
      Waveforms: ST74030402/Waveforms    #Downloaded Waveforms
    run:
      class: Operation             #search_SeisSol_ensemble.py
      inputs:
          SDL_AltoTiberina_Catalog: Directory
          Event_Time: File
          Waveforms: Directory
      outputs:
          Closest_Match: File
    out:
      - Closest_Match

