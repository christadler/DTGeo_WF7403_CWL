#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

requirements:
  MultipleInputFeatureRequirement: {} 
  SubworkflowFeatureRequirement: {} #only if subworkflows are used

inputs:
  Current_Time:
    doc: "Current Time since ST74030401 needs at least one input parameter"
    type: string
  SDL_AltoTiberina_Catalog:
    doc: "SDL AltoTiberina_Catalog."
    type: Directory

outputs:
  Event_Time:
    doc: "Event time."
    type: string
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
  ST74030401:
    doc: "Detect Event."
    in: #no input data (only current time needed)
      InputData: Current_Time
    run:
      class: Operation             #detect_event.py
      inputs:
          InputData: string
      outputs:
          Event_Time: string         #string?
    out:
      - Event_Time

  ST74030402:
    doc: "Download Waveforms."
    in:
      Event_Time: ST74030401/Event_Time    #Event_Time
    run:
      class: Operation             #download_TABOO_waveforms.py
      inputs:
          Event_Time: string
      outputs:
          Waveforms: Directory
    out:
      - Waveforms

  ST740305:
    doc: "Find closest match."
    in:
      SDL_AltoTiberina_Catalog: SDL_AltoTiberina_Catalog #SDL AltoTiberina_Catalog
      Event_Time: ST74030401/Event_Time  #Event_Time
      Waveforms: ST74030402/Waveforms    #Downloaded Waveforms
    run:
      class: Operation             #search_SeisSol_ensemble.py
      inputs:
          SDL_AltoTiberina_Catalog: Directory
          Event_Time: string
          Waveforms: Directory
      outputs:
          Closest_Match: File
    out:
      - Closest_Match

