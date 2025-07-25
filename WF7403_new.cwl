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
    #outputSource: ST740303/SDL_AltoTiberina_Catalog
    outputSource: ST7403_catalogCreation/SDL_AltoTiberina_Catalog
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
  ST7403_Catalog__Creation:
    doc: "Catalog Creation Workflow."
    in_:
      csv_File: DT740601_csv #CSV File
      MeshAsagi: DT740603_mesh     #SDL AltoTiberina_Inputs (mesh+asagi)
    run:
      class: Workflow
      inputs:
          csv_File: File
          MeshAsagi: Directory
      outputs:
          SDL_AltoTiberina_Catalog: Directory
      steps:
        ST740301:
          doc: "Use CSV File to build directory with input files."
          in:
            csv_File: csv_File #CSV File
          run:
            class: Operation
            inputs:
                csv_File: File
            outputs:
                SeisSolInputFiles: Directory
          out:
            - SeisSolInputFiles
        ST740302:
          doc: "Use SeisSol to generate catalog entries."
          in:
            SeisSolInputFiles: ST740301/SeisSolInputFiles #Output from step before
            MeshAsagi: MeshAsagi     #SDL AltoTiberina_Inputs (mesh+asagi)
          run:
            class: Operation         #Use SeisSol with slurm scripts
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
    out:
      - SDL_AltoTiberina_Catalog


  #ST740301:
    #doc: "Use CSV File to build directory with input files."
    #in:
      #csv_File: DT740601_csv #CSV File
    #run:
      #class: Operation
      #inputs:
          #csv_File: File
      #outputs:
          #SeisSolInputFiles: Directory
    #out:
      #- SeisSolInputFiles
  #ST740302:
    #doc: "Use SeisSol to generate catalog entries."
    #in:
      #SeisSolInputFiles: ST740301/SeisSolInputFiles #Output from step before
      #MeshAsagi: DT740603_mesh     #SDL AltoTiberina_Inputs (mesh+asagi)
    #run:
      #class: Operation             #Use SeisSol with slurm scripts
      #inputs:
          #SeisSolInputFiles: Directory
          #MeshAsagi: Directory
      #outputs:
          #FullSeisSolOutput: Directory
    #out:
      #- FullSeisSolOutput
  #ST740303:
    #doc: "Postprocessing of Outputs."
    #in:
      #FullSeisSolOutput: ST740302/FullSeisSolOutput #Output from step before
    #run:
      #class: Operation             #Use Postprocessing script and prepare Upload for SDL
      #inputs:
          #FullSeisSolOutput: Directory
      #outputs:
          #SDL_AltoTiberina_Catalog: Directory
    #out:
      #- SDL_AltoTiberina_Catalog


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
      SDL_AltoTiberina_Catalog: ST7403_catalogCreation/SDL_AltoTiberina_Catalog #SDL AltoTiberina_Catalog
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

