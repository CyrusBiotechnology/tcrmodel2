FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

# Install base utilities
RUN apt-get update \
    && apt-get install -y build-essential \
    && apt-get install -y wget \
    && apt-get clean \
    && apt-get install python3.9 -y\
    && apt-get install python3-pip -y\
    && apt-get install -y git\
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip

ENV PATH="${PATH}:/hh-suite/build/bin/"

RUN apt-get update \
    && apt-get install -y vim


# Install miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda

# Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH
RUN conda install -qy conda==23.5.0 \
    && conda install -y -c conda-forge -c bioconda \
      python=3.9 \
      openmm=7.5.1 \
      cudatoolkit=11.2 \
      pdbfixer \
      pip \
      mock \
      anarci \
      absl-py=0.13.0 \
      && conda clean --all --force-pkgs-dirs --yes

RUN pip install pandas scipy ml-collections dm-haiku dm-tree tensorflow MDAnalysis

RUN apt-get update && apt-get -y install cmake
RUN git clone https://github.com/soedinglab/hh-suite.git\
    && mkdir -p hh-suite/build && cd hh-suite/build\
    && cmake -DCMAKE_INSTALL_PREFIX=. ..\
    && make -j 4 && make install

ENV PATH="${PATH}:/hh-suite/build/bin/"

RUN conda install bioconda::kalign2

COPY . /tcrmodel2/
