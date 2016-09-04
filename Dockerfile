FROM erlang:18-slim

RUN apt-get -y update && \
      apt-get -y install sudo make gcc g++ git && \
      git clone https://github.com/dalmatinerdb/dalmatinerdb.git && \
      cd dalmatinerdb && \
      make all rel && \
      make package || true && \
      cp -r rel/pkg/deploy/dalmatinerdb /opt && \
      apt-get purge -y make gcc g++ git && \
      apt-get autoremove -y && \
      apt-get clean && \
      cd / && rm -rf /dalmatinerdb

# Run it as root
RUN sed -ie 's/RUNNER_USER=dalmatiner/RUNNER_USER=root/' /opt/dalmatinerdb/bin/ddb

# Create the data directory
RUN mkdir -p /data/dalmatinerdb/etc

# Install default config file
RUN cp /opt/dalmatinerdb/etc/dalmatinerdb.conf.example /data/dalmatinerdb/etc/dalmatinerdb.conf

# Don't daemonise on startup
RUN sed -ie 's/$ERTS_PATH\/run_erl -daemon $PIPE_DIR/$ERTS_PATH\/run_erl $PIPE_DIR/' /opt/dalmatinerdb/bin/ddb

EXPOSE 5555
CMD ["/opt/dalmatinerdb/bin/ddb", "start"]
