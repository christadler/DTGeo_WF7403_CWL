# Dockerfile for executable Rapid Response Workflow

This directory contains a Dockerfile to generate a docker image
that will allow to execute the workflow WF7403a.cwl

## Generate the dockerfile, test and upload it

```bash
# Build the Dockerfile
docker build -t dtgeo_wf7403_rr .

# Check the image (size)
docker images dtgeo_wf7403_rr

# Interactively run the docker image
# to check if scripts and data work together
docker run -i -t dtgeo_wf7403_rr /bin/bash

docker login -u <username>
# Use your password (WP) or alternatively a docker personal access token (PAT)

# Set a tag for the image
docker tag dtgeo_wf7403_rr christadler/dtgeo_wf7403_rr:latest

# push the image to hub.docker.com
docker push christadler/dtgeo_wf7403_rr:latest

# to simply download the image use
docker pull christadler/dtgeo_wf7403_rr:latest
```

## How to use the dockerimage

Since the dockerfile contains all three scripts and the data, the workflow boils down to just executing the docker image. This means, this workflow should run every hour and will check for earthquakes within the last hour.

## Future work

### Listener module

Alternatively, it would be possible to trigger the second ('download_TABOO_waveforms.py') and third step ('search_catalog_for_best_fit_model.py') by a listener module. The listener module would replace 'detect_event.py' and start the workflow only if an earthquake is detected. Both scripts allow to call them directly with the time of the earthquake in 'UTCDateTime'.

It might be necessary to adjust the 'RUN' command in the Dockerfile and pass the EQ time in UTCDateTime to both scripts.

```python
# Compute time of earthquake with highest magnitude
toe= cat[0].origins[0].time #time of EQ in UTCDateTime
eq_time=f"'{toe.year},{toe.month},{toe.day},{toe.hour},{toe.minute},{toe.second}'"

# call download_TABOO_waveforms.py with eq_time, output_folder and duration
os.system(f"python3 download_TABOO_waveforms.py {eq_time} TABOO_waveforms 60 ")

# call search_catalog_for_best_fit_model.py with eq_time, waveform folder and catalog
os.system(f"python3 search_catalog_for_best_fit_model.py {eq_time} TABOO_waveforms AltoTiberinaCatalog ")
```

### Mount catalog as volume

For the future we might want to mount the SDL AltoTiberina\_Catalog as a volume, so that we could always use the latest catalog or choose a catalog for this region. This should be adapted once a cwl blueprint for an SDL download software step is available. 

```bash
# make sure to mount the VOLUME properly in the Dockerfile
docker run -v /local/path/to/data:/app/AltoTiberinaCatalog
```

### Capture the output

So far the workflow will only capture STDOUT of 'search_catalog_for_best_fit_model.py'. If more is needed (e.g. the downloaded waveforms or the misfit computations), those need to be mounted as volumes, too.
