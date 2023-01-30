FROM bioconductor/bioconductor_docker

RUN apt-get -y update && \
    apt-get -y install sqlite3

RUN R -e 'BiocManager::install(c("tidyverse", "Spectra", "MsBackendMassbank", "DBI", "RSQLite"))'

COPY mzvault /scripts/mzvault
COPY sqlite /scripts/sqlite

RUN cd /scripts/sqlite && \
    mkdir -p ~/.ssh && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
    git clone https://github.com/dumblob/mysql2sqlite.git && \
    git clone https://github.com/idelsink/b-log.git