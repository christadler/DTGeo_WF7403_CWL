#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

label: Rapid Response Part of DT-Geo WF7403.

# metadata
s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0002-9293-0306
    s:email: mailto:iris.christadler@lmu.de	
    s:name: Iris Christadler
s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0001-7883-8397
    s:email: mailto:mmarchandon@lmu.de
    s:name: Mathilde Marchandon
s:codeRepository: https://github.com/christadler/DTGeo_WF7403_CWL/tree/main/Docker
s:dateCreated: "2026-08-06"
s:programmingLanguage: Python

requirements:
  MultipleInputFeatureRequirement: {} 
  SubworkflowFeatureRequirement: {} #only if subworkflows are used
  # Preparation for LISTENER MODULE that would output 
  # the date and time of the workflow
  # InitialWorkDirRequirement will stage input files in the output dir
  #InitialWorkDirRequirement:
    #listing:
      #- entryname: download_TABOO_waveforms.sh
        #entry: |-
          #CMD='python3 download_TABOO_waveforms.py'
          #OUTPUT_FOLDER='TABOO_waveforms'
          #DURATION= '60'
          #MSG="\${CMD} $(inputs.EQ_time) \${OUTPUT_FOLDER} \${DURATION}" 
          #echo \${MSG}
      #- entryname: search_catalog_for_best_fit_model.sh
        #entry: |-
          #CMD='python3 search_catalog_for_best_fit_model.py'
          ## connected to downloaded waveforms from first command
          #OBSDIR='TABOO_waveforms'
          ## connect with SDL download
          #ENSEMBE_DIR= 'AltoTiberinaCatalog'
          #MSG="\${CMD} $(inputs.EQ_time) \${OBSDIR} \${ENSEMBE_DIR}"
          #echo \${MSG}


inputs:
  SDL_AltoTiberina_Catalog:
    doc: "SDL AltoTiberina_Catalog."
    type: Directory
  #EQ_time: string #preparation for listener module

outputs:
  #Event_Time:
    #doc: "Event time."
    #type: string
    #outputSource: ST74030401/Event_Time
  Waveforms:
    doc: "Downloaded waveforms."
    type: Directory
    outputSource: RapidResponse/Waveforms
  Closest_Match:
    doc: "OutputFile."
    type: File
    outputSource: RapidResponse/Closest_Match

steps:
  # The docker image combines everything in one step:
  # docker will automatically call detect_event.py
  # detect_event.py will call download_TABOO_waveforms.py 
  # and search_best_fit.py if an event is detected.
  RapidResponse:
    doc: "Docker: Detect event, download waveforms and output best fit."
    in: 
      SDL_AltoTiberina_Catalog: SDL_AltoTiberina_Catalog
    run:
      class: CommandLineTool
      baseCommand: ["sh", "-c"]
      hints:
        DockerRequirement:
          dockerPull: christadler/dtgeo_wf7403_rr:weekly
      #Docker run –v $(pwd)/logs:/app/logs --name mein_container mein_image
      #until docker ...; do sleep 60; done
      arguments: ["until docker run \
                   -v $(pwd)/TABOO_waveforms:/app/TABOO_waveforms
                   -v $(pwd)/Scenario_Misfit:/app/Scenario_Misfit
                   --name christadler/dtgeo_wf7403_rr:weekly \
                   do sleep 60; done "]
      stdout: closest_match.txt

      inputs:
        SDL_AltoTiberina_Catalog: 
          type: Directory
      outputs:
        #Event_Time: string #we would need to filter this from the output
        Waveforms:
          type: Directory
          outputBinding:
            glob: $(pwd)/download_waveforms/ #TODO
        Closest_Match:
          type: File
          outputBinding:
            glob: closest_match.txt
    out:
      #- Event_Time
      - Waveforms
      - Closest_Match

