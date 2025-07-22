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
    doc: "Input of rupture forecast data and constraints."
    in:
      InputData: DT7406
    run:
      class: Operation
      inputs:
          InputData: Directory
      outputs:
          PreprocessedData: Directory
    out:
      - PreprocessedData

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
        SS7405:
          doc: "SPECFEM3D: Seismic wavepropagation in different coordinate systems."
          in:
            PreprocessedData: PreprocessedData
          run:
            class: Operation
            inputs:
              PreprocessedData: Directory
            outputs:
              SimulatedWaveforms: Directory
          out:
            - SimulatedWaveforms
        SS7406:
          doc: "H-MEC: Hydro-Mechanical Earthquake Cycles."
          in:
            PreprocessedData: PreprocessedData
          run:
            class: Operation
            inputs:
              PreprocessedData: Directory
            outputs:
              SimulatedCrustalStress: Directory
          out:
            - SimulatedCrustalStress
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
