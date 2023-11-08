FROM python:3.11-bookworm

# Glacio01 kører python 3.8.5
# Glacio101 IP: 172.23.251.95

RUN apt -y update; apt -y install gcc gfortran

RUN git clone -b release https://gitlab.com/petsc/petsc /work/petsc

RUN apt-get -y update; apt-get -y install openmpi-bin openmpi-common libopenmpi-dev
WORKDIR /work/petsc
RUN pip install numpy ipython
RUN pip install cython

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
  python3-dev \
  python3-netcdf4 \
  python3-nose \
  python3-numpy \
  python3-pyproj \
  python3-scipy \
  swig

# Install petsc using apt-get
#RUN apt-get -y install petsc-dev 
#ENV PETSC_DIR=/usr/lib/petsc

RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1001 ubuntu
USER ubuntu

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
RUN make install

ENV PYTHONPATH=$PYTHONPATH:$PETSC_PREFIX/lib/
#RUN echo 'export PYTHONPATH=$PYTHONPATH:'${PETSC_PREFIX}/lib/ >> /home/ubuntu/.bashrc


RUN make PETSC_DIR=/home/ubuntu/local/petsc PETSC_ARCH="" check


#RUN useradd -ms /bin/bash newuser
#USER newuser
#RUN make PETSC_DIR=/work/petsc PETSC_ARCH=arch-linux-c-opt install

#ENV PETSC_DIR=/work/petsc/
#ENV PETSC_ARCH=arch-linux-c-opt
#ENV PATH=$PETSC_DIR/$PETSC_ARCH/bin/:$PATH

# Build 
#RUN git clone https://github.com/pism/pism.git /work/pism-stable
#RUN mkdir /work/pism-stable/build
#WORKDIR /work/pism-stable/build
#RUN cmake -DCMAKE_INSTALL_PREFIX=~/pism ..



#RUN  mpi4py slepc4py
# RUN ./configure --with-cc=gcc --with-cxx=g++ --with-fc=gfortran --download-mpich --download-fblaslapack
#RUN ./configure \
#  --prefix=${pwd} \
#  --with-cc=mpicc \
#  --with-cxx=mpicxx \
#  --with-fc=mpifort \
#  --with-shared-libraries \
#  --with-debugging=0 \
#  --with-petsc4py \
#  --download-f2cblaslapacki

