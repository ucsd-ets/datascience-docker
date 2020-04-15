ARG BASE_CONTAINER=jupyter/datascience-notebook:hub-1.1.0
ARG DATAHUB_CONTAINER=ucsdets/datahub-base-notebook:2020.2-stable

# # force rebuild
FROM $DATAHUB_CONTAINER as datahub
FROM $BASE_CONTAINER

MAINTAINER UC San Diego ITS/ETS-EdTech-Ecosystems <acms-compinf@ucsd.edu>

COPY --from=datahub /usr/share/datahub/scripts/* /usr/share/datahub/scripts/
COPY --from=datahub /usr/share/datahub/tests /usr/share/datahub/tests
RUN /usr/share/datahub/scripts/install-all.sh

# Install OKpy for DSC courses
# downgrade pip temporarily and upgrade to fix issue with okpy install
RUN pip install --upgrade --force-reinstall pip==9.0.3
RUN pip install okpy --disable-pip-version-check
RUN pip install --upgrade pip

RUN pip install dpkt \
                nose \
                datascience

# Pregenerate matplotlib cache
RUN python -c 'import matplotlib.pyplot'

RUN conda clean -tipsy

# Run container integration tests
USER root
ENV TESTDIR=/usr/share/datahub/tests
ARG DATASCIENCE_TESTDIR=${TESTDIR}/datascience-notebook
COPY tests ${DATASCIENCE_TESTDIR}
RUN chmod -R +x ${TESTDIR}
RUN for f in ${TESTDIR}/**/*.sh; do bash $f; done

# change the owner back
RUN chown -R 1000:1000 /home/jovyan
USER $NB_UID
RUN  bash -c 'find /opt/julia -type f -a -name "*.ji" -a \! -perm /005 | xargs chmod og+rX'
ENV SHELL=/bin/bash

COPY --from=datahub /run_jupyter.sh /
