FROM app-bio/base


RUN apt-get update -y && \
    apt-get install -y hisat2 && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*