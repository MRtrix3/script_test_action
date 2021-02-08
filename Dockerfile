ARG DEBIAN_FRONTEND="noninteractive"

FROM buildpack-deps:buster as base

# Download minified ART ACPCdetect (V2.0).
FROM base as acpcdetect-installer
WORKDIR /opt/art
RUN curl -fsSL https://osf.io/73h5s/download \
    | tar xz --strip-components 1

# Download minified ANTs (2.3.4).
FROM base as ants-installer
WORKDIR /opt/ants
RUN curl -fsSL https://osf.io/3ad69/download \
    | tar xz --strip-components 1

# Download FreeSurfer files.
FROM base as freesurfer-installer
WORKDIR /opt/freesurfer
RUN curl -fsSLO https://raw.githubusercontent.com/freesurfer/freesurfer/v7.1.1/distribution/FreeSurferColorLUT.txt

# Download minified FSL (6.0.4)
FROM base as fsl-installer
WORKDIR /opt/fsl
RUN curl -fsSL https://osf.io/dv258/download \
    | tar xz --strip-components 1

# Build final image.
FROM base AS final

# Install build & runtime dependencies.
RUN apt-get -qq update \
    && apt-get install -yq --no-install-recommends \
        dc \
        libeigen3-dev \
        libfftw3-dev \
        libgomp1 \
        liblapack-dev \
        libpng-dev \
        libquadmath0 \
        libtiff5-dev \
        python3-distutils \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=acpcdetect-installer /opt/art /opt/art
COPY --from=ants-installer /opt/ants /opt/ants
COPY --from=freesurfer-installer /opt/freesurfer /opt/freesurfer
COPY --from=fsl-installer /opt/fsl /opt/fsl

ENV ANTSPATH="/opt/ants/bin" \
    ARTHOME="/opt/art" \
    FREESURFER_HOME="/opt/freesurfer" \
    FSLDIR="/opt/fsl" \
    FSLOUTPUTTYPE="NIFTI_GZ" \
    FSLMULTIFILEQUIT="TRUE" \
    FSLTCLSH="/opt/fsl/bin/fsltclsh" \
    FSLWISH="/opt/fsl/bin/fslwish" \
    LD_LIBRARY_PATH="/opt/ants/lib:/opt/fsl/lib:$LD_LIBRARY_PATH" \
    PATH="/opt/mrtrix3/bin:/opt/ants/bin:/opt/art/bin:/opt/fsl/bin:$PATH"

# Configure to be immediately ready to work on MRtrix3 
RUN mkdir /opt/mrtrix3
WORKDIR /opt/mrtrix3

# Script for compiling and running tests
COPY entrypoint.sh /entrypoint.sh

# git commitish to be checked out provided as argument upon execution of container
ENTRYPOINT ["bash", "-c", "/entrypoint.sh $0"]

