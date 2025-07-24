#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}

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
    type: File
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
    type: File
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

# We probably need an extra step for uploading the data to the SDL

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


---- above new, below old ---

  ST740302:
    doc: "Forward dynamic rupture simulations."
    in:
      PreprocessedData: ST740301/PreprocessedData
    run:
      class: Workflow
      inputs:
        PreprocessedData: Directory
      outputs:
        SimulatedRuptureResult: Directory
      steps:
        SS7401:
          doc: "SeisSol: Simulate complex earthquake scenarios with high-precission."
          in:
            PreprocessedData: PreprocessedData
          run:
            class: Operation
            inputs:
              PreprocessedData: Directory
            outputs:
              SimulatedRupture: Directory
          out:
            - SimulatedRupture
       
        CombineResults:
          doc: "Combines results from SS7401, SS7405, and SS7406."
          in:
            SimulatedRupture: SS7401/SimulatedRupture
            SimulatedWaveforms: SS7405/SimulatedWaveforms
            SimulatedCrustalStress: SS7406/SimulatedCrustalStress
          run:
            class: Operation
            inputs:
              SimulatedRupture: Directory
              SimulatedWaveforms: Directory
              SimulatedCrustalStress: Directory
            outputs:
              SimulatedRuptureResult: Directory
          out:
            - SimulatedRuptureResult
    out:
      - SimulatedRuptureResult

  ST740303:
    doc: "Create ensemble rupture scenarios."
    in:
      SimulatedRuptureResult: ST740302/SimulatedRuptureResult
    run:
      class: Operation
      inputs:
        SimulatedRuptureResult: Directory
      outputs:
        DT7407: Directory
    out:
      - DT7407

  ST740304:
    doc: "Additional Seismic and Geodetic data."
    in:
      SeismicGeodeticDataAdd: DT7408
    run:
      class: Operation
      inputs:
        SeismicGeodeticDataAdd: Directory
      outputs:
        PreprocessedAddData: Directory
    out:
      - PreprocessedAddData   

  ST740305:
    doc: "Generate shake map from selected scenario."
    in:
      EnsembleOutput: ST740303/DT7407
      PreprocessedAddData: ST740304/PreprocessedAddData
    run:
      class: Operation
      inputs:
        EnsembleOutput: Directory
        PreprocessedAddData: Directory
      outputs:
        DT7409: Directory
    out:
      - DT7409
