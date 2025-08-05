#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

requirements:
  MultipleInputFeatureRequirement: {} 
  SubworkflowFeatureRequirement: {} #only if subworkflows are used

inputs:
  SDL_AltoTiberina_Catalog:
    doc: "SDL AltoTiberina_Catalog."
    type: Directory

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
      #Docker run –v $(pwd)/logs:/app/logs --name mein_container mein_image
      #until docker ...; do sleep 60; done
      arguments: ["until docker run \
                   -v $(pwd)/download_waveforms:/app/download_waveforms
                   -v SDL_AltoTiberina_Catalog:/app/AltoTiberinaCatalog
                   --name christadler/dtgeo_wf7403_rr:latest \
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

