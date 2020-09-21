FROM mrtrix3/base:0.0.1

ENV ANTSPATH="/opt/ants/bin/"
ENV ARTHOME="/opt/art"
ENV FREESURFER_HOME="/opt/freesurfer"
ENV FSLDIR="/opt/fsl"
ENV LD_LIBRARY_PATH="/opt/ants/lib"
ENV PATH="/opt/mrtrix3/bin:$ANTSPATH:$ARTHOME/bin:$FSLDIR/bin:$PATH"

# Configure to be immediately ready to work on MRtrix3 
RUN mkdir /opt/mrtrix3
WORKDIR /opt/mrtrix3

# Script for compiling and running tests
COPY entrypoint.sh /entrypoint.sh

# git commitish to be checked out provided as argument upon execution of container
ENTRYPOINT ["bash", "-c", "source /opt/fsl/etc/fslconf/fsl.sh && /entrypoint.sh $0"]

