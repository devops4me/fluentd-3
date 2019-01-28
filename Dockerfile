
FROM fluent/fluentd:latest

# --->
# ---> elasticsearch and S3 are the log persistence
# ---> stores so we install their fluent plugins.
# --->

RUN gem install fluent-plugin-elasticsearch
RUN gem install fluent-plugin-s3

# --->
# ---> Copy the fluentd configuration file  as long
# ---> as it does not contain sensitive information
# --->

COPY fluentd-logs.conf /fluentd/etc/fluentd-logs.conf
