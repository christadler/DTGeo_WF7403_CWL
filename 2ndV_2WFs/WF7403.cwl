#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

requirements:
  MultipleInputFeatureRequirement: {} 
  SubworkflowFeatureRequirement: {} #only if subworkflows are used

inputs:
  DT740601_csv:
    doc: "CSV File to generate input files for catalog"
    type: File
  DT740603_mesh:
    doc: "SDL-Data AltoTiberina_Inputs contains mesh and asagi for SeisSol"
    type: Directory
  Current_Time:
    doc: "Current Time since ST74030401 needs at least one input parameter"
    type: string

outputs:
  SDL_AltoTiberina_Catalog:
    doc: "SDL AltoTiberina_Catalog."
    type: Directory
    outputSource: ST7403_Catalog_Creation/SDL_AltoTiberina_Catalog
  Event_Time:
    doc: "Event time."
    type: string
    outputSource: ST7403_Rapid_Response/Event_Time
  Waveforms:
    doc: "Downloaded waveforms."
    type: Directory
    outputSource: ST7403_Rapid_Response/Waveforms
  Closest_Match:
    doc: "Single dynamic rupture scenario."
    type: File
    outputSource: ST7403_Rapid_Response/Closest_Match

steps:
  ST7403_Catalog_Creation:
    doc: "Catalog Creation Workflow."
    in:
      DT740601_csv: DT740601_csv       #CSV File
      DT740603_mesh: DT740603_mesh     #SDL AltoTiberina_Inputs (mesh+asagi)
    out:
      - SDL_AltoTiberina_Catalog
    run: WF7403a.cwl

  ST7403_Rapid_Response:
    doc: "Rapid Response Workflow."
    in:
      Current_Time: Current_Time
      SDL_AltoTiberina_Catalog: ST7403_Catalog_Creation/SDL_AltoTiberina_Catalog
    out:
      - Event_Time
      - Waveforms
      - Closest_Match
    run: WF7403b.cwl

