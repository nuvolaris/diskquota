FROM pgvector/pgvector:pg14

COPY . /tmp/diskquota
RUN cd /tmp/diskquota
RUN mkdir build

RUN apt-get update && \
            apt-mark hold locales && \
            apt-get install -y --no-install-recommends build-essential git postgresql-server-dev-14

RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null

RUN apt-get update && apt-get install -y cmake

RUN cd /tmp/diskquota/build
RUN cmake -S /tmp/diskquota -D PG_CONFIG=/usr/bin/pg_config
RUN make install 

RUN mkdir /usr/share/doc/diskquota && \
            cp LICENSE README.md SECURITY.md VERSiON /usr/share/doc/diskquota && \
            rm -r /tmp/diskquota && \
            apt-get remove -y build-essential postgresql-server-dev-$PG_MAJOR && \
            apt-get autoremove -y && \
            apt-mark unhold locales && \
            rm -rf /var/lib/apt/lists/*    