# Miniconda Baseimage
# installed into the /opt/conda folder user has conda command in their path
FROM continuumio/miniconda3

# Update conda
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
RUN conda update -n base -c defaults conda

# Install curl and vi
RUN apt-get update && apt-get install -y curl
RUN apt-get update && apt-get install -y vim

# This dockerfile mainly follows the instructions from
# https://github.com/marcmath/download_TABOO_waveforms/README.md

# Install environment from https://github.com/marcmath/download_TABOO_waveforms/
# but do not create a special environment for it
# simplest thing is to install only the python modules that are necessar
RUN conda install -c conda-forge obspy --yes
RUN conda install cartopy --yes
RUN conda install pytest --yes
RUN conda install -c conda-forge pytest-json-report --yes

# set Workdir
WORKDIR /app

# download the three scripts
RUN curl -o /app/detect_event.py https://raw.githubusercontent.com/marcmath/download_TABOO_waveforms/main/detect_event.py
RUN curl -o /app/download_TABOO_waveforms.py https://raw.githubusercontent.com/marcmath/download_TABOO_waveforms/main/download_TABOO_waveforms.py
RUN curl -o /app/search_catalog_for_best_fit_model.py https://raw.githubusercontent.com/NicoSchlw/search_SeisSol_ensemble/main/search_catalog_for_best_fit_model.py

#chmod u+x /app/detect_event.py
RUN chmod u+x /app/*.py

# Create empty 'TABOO_waveforms' directory
RUN mkdir -p /app/TABOO_waveforms

# Add AltoTiberina_Catalog 
# currently not directly from SDL since the SDL has problems to download the full catalog
# could be later mounted as VOLUME but this needs more time 
# In the meantime COPY ALTO_TIBERINA_CATALOG TO THE DOCKER DIR
COPY AltoTiberinaCatalog /app/AltoTiberinaCatalog

# RUN detect_event.py (needs to be called by the .cwl file)
#python3 ./detect_event.py >> RapidResponse.log 2>> RapidResponse.err
# Optional: setze den Befehl, der beim Start ausgeführt wird
#CMD ["python", "dein_script.py"]
#CMD ["python3", "detect_event.py"]

# It is possible to mount data when starting the container (as VOLUME)
# docker run -v /local/path/to/data:/app/AltoTiberinaCatalog

