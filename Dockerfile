FROM neurodebian:nd18.04-non-free

# Command-line arguments for `./configure`
ARG MRTRIX3_CONFIGURE_FLAGS=""
# Command-line arguments for `./build`
ARG MRTRIX3_BUILD_FLAGS=""

# Prevent programs like `apt-get` from presenting interactive prompts.
ARG DEBIAN_FRONTEND="noninteractive"

ENV FSLDIR="/opt/fsl"
ENV FREESURFER_HOME="/opt/freesurfer"
ENV PATH="/opt/mrtrix3/bin:/opt/fsl/bin:$PATH"

# Install MRtrix3 compile-time dependencies.
RUN apt-get -qq update \
    && apt-get install -yq --no-install-recommends \
          $OTHER_TEMP_DEPS \
          bc \
          ca-certificates \
          curl \
          dc \
          file \
          g++-7 \
          git \
          libeigen3-dev \
          libfftw3-dev \
          libgl1-mesa-dev \
          libpng-dev \
          libqt5opengl5-dev \
          libqt5svg5-dev \
          libtiff5-dev \
          python \
          qt5-default \
          wget \
          zlib1g-dev

# Install ANTs.
RUN apt-get -qq update \
    && apt-get install -yq --no-install-recommends "ants"

# Install FSL.
RUN wget -q http://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py -O /fslinstaller.py \
    && chmod 775 /fslinstaller.py \
    && python2 /fslinstaller.py -d /opt/fsl -V 6.0.4 -q \
    && rm -f /fslinstaller.py \
    && ( which immv || ( rm -rf /opt/fsl/fslpython && /opt/fsl/etc/fslconf/fslpython_install.sh -f /opt/fsl || ( cat /tmp/fslpython*/fslpython_miniconda_installer.log && exit 1 ) ) )

# Grab dummy FreeSrfer lookup table file necessary for testing "5ttgen hsvs"
RUN mkdir /opt/freesurfer
COPY FSLUT.txt /opt/freesurfer/FreeSurferColorLUT.txt

# Configure to be immediately ready to work on MRtrix3 
RUN mkdir /opt/mrtrix3
WORKDIR /opt/mrtrix3

# Script for compiling and running tests
COPY entrypoint.sh /entrypoint.sh

# git commitish to be checked out provided as argument upon execution of container
ENTRYPOINT ["bash", "-c", "source /opt/fsl/etc/fslconf/fsl.sh && /entrypoint.sh $1"]

