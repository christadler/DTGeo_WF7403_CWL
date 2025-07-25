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
  DT740602:
    doc: "Directory with SeisSol input files and slurm scripts"
    type: Directory
  DT740603:
    doc: "SDL-Data AltoTiberina_Inputs contains mesh and asagi for SeisSol"
    type: Directory
  DT740701:
    doc: "Full SeisSol outputs for all rupture scenarios"
    type: Directory
  DT740702:
    doc: "SDL-Data AltoTiberina_Catalog of (postprocessed) rupture scenarios."
    type: Directory
  DT740801:
    doc: "Event time."
    type: String
  DT7408:
    doc: "Downloaded waveforms and station list."
    type: Directory

outputs:
  DT740602:
    doc: "Directory with SeisSol Input Files."
    type: Directory
    outputSource: ST740301/DT740602
  DT740701:
    doc: "Full SeisSol_Output."
    type: Directory
    outputSource: ST740302/DT740701
  DT740702:
    doc: "SDL AltoTiberina_Catalog."
    type: Directory
    outputSource: ST740303/DT740702
  DT740801:
    doc: "Event time."
    type: String
    outputSource: ST74030401/DT740801
  DT7408:
    doc: "Downloaded waveforms."
    type: Directory
    outputSource: ST74030402/DT7408
  DT7409:
    doc: "Single dynamic rupture scenario."
    type: Directory
    outputSource: ST740305/DT7409

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
    run:
      class: Operation             #detect_event.py
      inputs:
          InputData: Directory
      outputs:
          Event_time: String
    out:
      - Event_time

  ST74030402:
    doc: "Download Waveforms."
    in:
      Event_time: ST74030401/Event_time    #Event_time
    run:
      class: Operation             #download_TABOO_waveforms.py
      inputs:
          InputData: Directory
      outputs:
          Waveforms: Directory
    out:
      - Waveforms

  ST740305:
    doc: "Find closest match."
    in:
      AT_Catalog: DT740702               #SDL AltoTiberina_Catalog
      Event_time: ST74030401/Event_time  #Event_time
      Waveforms: ST74030402/Waveforms    #Downloaded Waveforms
    run:
      class: Operation             #search_SeisSol_ensemble.py
      inputs:
          AT_Catalog: Directory
          Event_time: String       # Date?
          Waveforms: Directory
      outputs:
          SDL_AltoTiberina_Catalog: Directory
    out:
      - SDL_AltoTiberina_Catalog

