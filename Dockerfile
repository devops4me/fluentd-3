
FROM fluent/fluentd:latest

# --->
# ---> elasticsearch and S3 are the log persistence
# ---> stores so we install their fluent plugins.
# --->

RUN gem install fluent-plugin-elasticsearch
RUN gem install fluent-plugin-s3

# --->
# ---> Copy all the configuration files with directives
# ---> that can be set via environment variables.
# --->
# ---> The file that will be used is set in the
# ---> fluentd docker run command.
# --->

COPY fluentd-elasticsearch-local.conf /fluentd/etc/fluentd-elasticsearch-local.conf
COPY fluentd-elasticsearch-s3.conf /fluentd/etc/fluentd-elasticsearch-s3.conf
