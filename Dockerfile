
FROM fluent/fluentd:latest

# --->
# ---> elasticsearch is the log aggregator destination
# ---> so we install fluentd's elasticsearch plugin
# --->

RUN gem install fluent-plugin-elasticsearch

# --->
# ---> Copy the fluentd configuration file
# --->

COPY fluentd-logs.conf /fluentd/etc/fluentd-logs.conf
