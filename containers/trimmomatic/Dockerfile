FROM app-bio/base-java


RUN apt-get update -y && \
    apt-get install -y trimmomatic && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*