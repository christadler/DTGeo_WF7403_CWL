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

outputs:
  SDL_AltoTiberina_Catalog:
    doc: "SDL AltoTiberina_Catalog."
    type: Directory
    outputSource: ST740303/SDL_AltoTiberina_Catalog

steps:
  ST740301:
    doc: "Use CSV File to build directory with input files."
    in:
      InputData: DT740601_csv #CSV File
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
      MeshAsagi: DT740603_mesh                      #SDL AltoTiberina_Inputs (mesh+asagi)
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

