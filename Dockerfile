#FROM python:3.11-bookworm
FROM python:3.8-bookworm
# Glacio01 kører python 3.8.5
# Glacio101 IP: 172.23.251.95

RUN apt -y update; apt -y install gcc gfortran

RUN apt-get -y install cmake \
  g++ \
  git \
  libfftw3-dev \
  libgsl-dev \
  libnetcdf-dev \
  libudunits2-dev \
  netcdf-bin \
  cdo \
  cmake-curses-gui \
  libpnetcdf-dev \
  libproj-dev \
  libx11-dev \
  nco \
  ncview \
  #python3-dev \
  #python3-netcdf4 \
  #python3-nose \
  #python3-numpy \
  #python3-pyproj \
  #python3-scipy \
  swig
RUN apt-get -y update; apt-get -y install openmpi-bin openmpi-common libopenmpi-dev

# Install petsc using apt-get
#RUN apt-get -y install petsc-dev 
#ENV PETSC_DIR=/usr/lib/petsc

RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1001 ubuntu
USER ubuntu

RUN pip install numpy ipython
RUN pip install cython


ENV PETSC_DIR=/home/ubuntu/work/petsc
ENV PETSC_ARCH=arch-linux-c-opt
#ENV PETSC_ARCH=linux-opt
ENV PETSC_PREFIX=/home/ubuntu/local/petsc

RUN git clone -b release https://gitlab.com/petsc/petsc $PETSC_DIR
WORKDIR /home/ubuntu/work/petsc
# Using the samme commit id as glacio01
RUN git reset --hard a8c140145f21fed7fd2b7d6b0eadef4d94cee6ca


# Build PETSc from source
RUN ./configure \
  --prefix=$PETSC_PREFIX \
  --with-cc=mpicc \
  --with-cxx=mpicxx \
  --with-fc=mpifort \
  --with-shared-libraries \
  --witdebugging=0 \
  --with-petsc4py \
  --download-f2cblaslapack

RUN make all

RUN pip install 'cython<3'
RUN make install

ENV PYTHONPATH=$PYTHONPATH:$PETSC_PREFIX/lib/

ENV PATH=$PETSC_DIR/$PETSC_ARCH/bin/:$PATH
ENV OMPI_MCA_btl=^openib

# The last line is some voodoo fix dealing with potential openmpi problems. ASO recommended adding the line; both she and SHL have used it to bypass openmpi problems.

## Installing PISM
ENV PISM_DIR=/home/ubuntu/work/pism-stable
ENV PISM_INSTALL_PREFIX=/home/ubuntu/Models/PISM/pism
RUN git clone https://github.com/pism/pism.git $PISM_DIR
RUN mkdir $PISM_DIR/build
WORKDIR $PISM_DIR/build
ENV CC=mpicc
ENV CXX=mpicxx
RUN cmake -DPism_USE_PROJ=ON -DPism_BUILD_EXTRA_EXECS=ON -DCMAKE_INSTALL_PREFIX=$PISM_INSTALL_PREFIX ..
RUN make -j install

ENV PATH=$PATH:$PISM_INSTALL_PREFIX/bin

RUN pip install netcdf4 matplib

# Glacio01 is using pismr version: stable v2.0.6






