
# Docker Logs to Fluentd and Elasticsearch

This use case is about ***fluentd** pumping docker logs from one or more containers on your laptop (localhost) to a local ***docker elasticsearch container***. These logs can then be viewed via a local **Kibana docker** container.

## Startup ElasticSearch and Kibana

Let's create a baseline by ***removing all docker containers and images*** from our machine.

```bash
docker rm -vf $(docker ps -aq)
docker rmi $(docker images -aq) --force

docker pull docker.elastic.co/elasticsearch/elasticsearch-platinum:6.0.0

docker pull docker.elastic.co/kibana/kibana:6.0.0

docker run -d --rm -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e "transport.host=127.0.0.1" -e ELASTIC_PASSWORD=secret --name elastic-db docker.elastic.co/elasticsearch/elasticsearch-platinum:6.0.0 && sleep 20

docker run -d --rm --link elastic-db -e "ELASTICSEARCH_URL=http://elastic-db:9200" -e ELASTICSEARCH_PASSWORD="secret"  -p 5601:5601 --name kibana docker.elastic.co/kibana/kibana:6.0.0 && sleep 20

curl "http://localhost:9200/_count" -u 'elastic:secret' && echo

curl -XPUT http://localhost:9200/sanity-check-index/movie/1  -u 'elastic:secret' -d '{"director": "Burton, Tim", "genre": ["Comedy","Sci-Fi"], "year": 1996, "actor": ["Jack Nicholson","Pierce Brosnan","Sarah Jessica Parker"], "title": "Mars Attacks!"}' -H 'Content-Type: application/json' && echo

docker ps -a

docker images -a
```

Now that we have data in elasticsearch we can login to Kibana with

- url **`http://localhost:5601`**
- username **`elastic`**
- password **`secret`**


## Push Jenkins Logs into ElasticSearch

***Let's run Jenkins locally and set its log driver to a fluentd docker container that we've started locally and configured to push to the local elasticsearch container started above.***


```bash
cd /directory/containing/fluentd-config.conf

docker build --rm --tag fluent4me .

docker run -it            \
    --name fluentd.logs   \
    --publish 24224:24224 \
    --env FLUENTD_CONF=fluentd-logs.conf \
    --volume $PWD/fluentd-logs.conf:/fluentd/etc/fluentd-logs.conf \
    fluent/fluentd:latest

docker run -it            \
    --name fluentd.logs   \
    --publish 24224:24224 \
    --env FLUENTD_CONF=fluentd-logs.conf \
    --volume $PWD/fluentd-logs.conf:/fluentd/etc/fluentd-logs.conf \
    fluent4me

docker run --tty --privileged --detach \
    --log-driver fluentd \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume /usr/bin/docker:/usr/bin/docker \
    --publish 8080:8080       \
    --name jenkins-2.0     \
    devops4me/jenkins-2.0

curl "http://localhost:9200/_count" -u 'elastic:secret' && echo
```

Keep repeating the curl count and note the ***increasing* record count**.

## Dockerfile | fluentd elasticserch

We add the elasticsearch plugin to fluentd using this small Dockerfile which is built with **`docker build --rm --tag fluent4me .`**.

```
FROM fluent/fluentd:latest
RUN gem install fluent-plugin-elasticsearch
```

## Fluentd ElasticSearch Configuration

These directives tell fluentd where to post the logs. They also detail the credentials of the elasticsearch database user.

```conf
<match **>
    @type elasticsearch
    logstash_format true
    host localhost
    port 9200
    user elastic
    password secret
    index_name index-jenkins-log
    type_name type-jenkins-log
</match>
```



```bash
curl -XPUT 'localhost:9200/get-together/group/1?pretty' -u 'elastic:secret' -d '{
"name": "Elasticsearch Denver",
"organizer": "Lee"
}' -H 'Content-Type: application/json'

```



curl -XPUT 'localhost:9200/get-together/group/1?pretty' -u 'elastic:secret' -d '{
"name": "Elasticsearch Denver",
"organizer": "Lee"
}' -H 'Content-Type: application/json'


curl 'localhost:9200/get-together/_mapping/group?pretty' -u 'elastic:secret'


curl 'localhost:9200/_search?q=jenkins&pretty' -u 'elastic:secret'



curl 'localhost:9200/_cat/indices?v&pretty' -u 'elastic:secret'



health status index                           uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   get-together                    FaoyBodITkayeVXwLRj5yQ   5   1          1            0      5.3kb          5.3kb
yellow open   .watcher-history-6-2019.01.19   LS2cge7KR7OfEu3m_NCtbg   1   1       3731            0        4mb            4mb
yellow open   .triggered_watches              mwqTUX2nSVqzRKef1rE2ew   1   1          0            0      168kb          168kb
yellow open   .kibana                         mRgeMZ7aTSG7MaQjMDdXbg   1   1          1            0        4kb            4kb
yellow open   log-elk-stack-18205-1708        LmfnsMY_Qz27HRffTYZnoQ   5   1          1            0      7.1kb          7.1kb
yellow open   .monitoring-kibana-6-2019.01.19 d76foAzzRzWRjLQozy2GwA   1   1       3194            0   1018.3kb       1018.3kb
yellow open   .monitoring-alerts-6            bnCh8W05TI65vekMt90zkQ   1   1          1            0      6.5kb          6.5kb
yellow open   .monitoring-es-6-2019.01.19     WaIEoUsPTmmUMwFMrveXkw   1   1      38572          204     16.4mb         16.4mb
yellow open   .watches                        h3PALkRZSnizq9pIOhd0iQ   1   1          5            0     33.3kb         33.3kb


curl 'localhost:9200/get-together/_search?q=*&pretty' -u 'elastic:secret'


curl 'localhost:9200/.monitoring-es-6-2019.01.19/_search?q=*&pretty' -u 'elastic:secret'



curl 'localhost:9200/.watcher-history-6-2019.01.19/_search?q=*&pretty' -u 'elastic:secret'




## ElasticSearch and S3

#### excellent information

https://www.fluentd.org/guides/recipes/elasticsearch-and-s3





https://raw.githubusercontent.com/fluent/fluentd-docker-image/master/v1.3/alpine-onbuild/fluent.conf


## THE BEST sIMPLEST DOCKER LOGGING

https://www.fluentd.org/guides/recipes/docker-logging





Docker Logging

    Home Guides & Recipes Here 

The following article describes how to implement an unified logging system for your Docker containers. Any production application requires to register certain events or problems during runtime. The old fashion way is to write these messages to a log file, but that inherits certain problems specifically when we try to perform some analysis over the registers, or in the other side, if the application have multiple instances running, the scenario becomes even more complex.

On Docker v1.6, the concept of logging drivers was introduced, basically the Docker engine is aware about output interfaces that manage the application messages. For Docker v1.8, we have implemented a native Fluentd logging driver, now you are able to have an unified and structured logging system with the simplicity and high performance Fluentd.
Getting Started

Using the Docker logging mechanism with Fluentd is a straightforward step, to get started make sure you have the following prerequisites:

    A basic understanding of Fluentd
    Docker v1.8
    Docker container

Step 1: Create the Fluentd configuration file

The first step is to prepare Fluentd to listen for the messsages that will receive from the Docker containers, for demonstration purposes we will instruct Fluentd to write the messages to the standard output; In a later step you will find how to accomplish the same aggregating the logs into a MongoDB instance.

Create a simple file called in_docker.conf which contains the following entries:

<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

<match *.*>
  @type stdout
</match>

Step 2: Start Fluentd

With this simple command start an instance of Fluentd:

$ fluentd -c in_docker.conf

If the service started you should see an output like this:

$ fluentd -c in_docker.conf
2015-09-01 15:07:12 -0600 [info]: reading config file path="in_docker.conf"
2015-09-01 15:07:12 -0600 [info]: starting fluentd-0.12.15
2015-09-01 15:07:12 -0600 [info]: gem 'fluent-plugin-mongo' version '0.7.10'
2015-09-01 15:07:12 -0600 [info]: gem 'fluentd' version '0.12.15'
2015-09-01 15:07:12 -0600 [info]: adding match pattern="*.*" type="stdout"
2015-09-01 15:07:12 -0600 [info]: adding source type="forward"
2015-09-01 15:07:12 -0600 [info]: using configuration file: <ROOT>
  <source>
    @type forward
    port 24224
    bind 0.0.0.0
  </source>
  <match docker.*>
    @type stdout
  </match>
</ROOT>
2015-09-01 15:07:12 -0600 [info]: listening fluent socket on 0.0.0.0:24224

Step 3: Start Docker container with Fluentd driver

By default, the Fluentd logging driver will try to find a local Fluentd instance (step #2) listening for connections on the TCP port 24224, note that the container will not start if it cannot connect to the Fluentd instance.

The following command will run a base Ubuntu container and print some messages to the standard output, note that we have launched the container specifying the Fluentd logging driver:

$ docker run --log-driver=fluentd ubuntu echo "Hello Fluentd!"
Hello Fluentd!

Step 4: Confirm

Now on the Fluentd output, you will see the incoming message from the container, e.g:

2015-09-01 15:10:40 -0600 docker.3fd8678d487e: {"source":"stdout","log":"Hello Fluentd!","container_id":"3fd8678d487e540c7a303e1613101e746c5012f3317434eda93f24351c1928f7","container_name":"/angry_kalam"}

At this point you will notice something interesting, the incoming messages have a timestamp, are tagged with the container_id and contains general information from the source container along the message, everything in JSON format.
Additional Step 1: Parse log message

Application log is stored into "log" field in the record. You can parse this log by using filter_parser filter before send to destinations.

<filter docker.**>
  @type parser
  format json # apache2, nginx, etc...
  key_name log
  reserve_data true
</filter

Original event:

2015-09-01 15:10:40 -0600 docker.3fd8678d487e: {"source":"stdout","log":"{\"key\":\"value\"}","container_id":"3fd8678d487e540c7a303e1613101e746c5012f3317434eda93f24351c1928f7","container_name":"/angry_kalam"}

Filtered event:

2015-09-01 15:10:40 -0600 docker.3fd8678d487e: {"source":"stdout","log":"{\"key\":\"value\"}","container_id":"3fd8678d487e540c7a303e1613101e746c5012f3317434eda93f24351c1928f7","container_name":"/angry_kalam","key":"value"}

Additional Step 2: Concatenate multiple lines log messages

Application log is stored into "log" field in the records. You can concatenate these logs by using fluent-plugin-concat filter before send to destinations.

<filter docker.**>
  @type concat
  key log
  stream_identity_key container_id
  multiline_start_regexp /^-e:2:in `\/'/
  multiline_end_regexp /^-e:4:in/
</filter>

Original events:

2016-04-13 14:45:55 +0900 docker.28cf38e21204: {"container_id":"28cf38e212042225f5f80a56fac08f34c8f0b235e738900c4e0abcf39253a702","container_name":"/romantic_dubinsky","source":"stdout","log":"-e:2:in `/'"}
2016-04-13 14:45:55 +0900 docker.28cf38e21204: {"source":"stdout","log":"-e:2:in `do_division_by_zero'","container_id":"28cf38e212042225f5f80a56fac08f34c8f0b235e738900c4e0abcf39253a702","container_name":"/romantic_dubinsky"}
2016-04-13 14:45:55 +0900 docker.28cf38e21204: {"source":"stdout","log":"-e:4:in `<main>'","container_id":"28cf38e212042225f5f80a56fac08f34c8f0b235e738900c4e0abcf39253a702","container_name":"/romantic_dubinsky"}

Filtered events:

2016-04-13 14:45:55 +0900 docker.28cf38e21204: {"container_id":"28cf38e212042225f5f80a56fac08f34c8f0b235e738900c4e0abcf39253a702","container_name":"/romantic_dubinsky","source":"stdout","log":"-e:2:in `/'\n-e:2:in `do_division_by_zero'\n-e:4:in `<main>'"}

Driver options

The Fluentd logging driver support more options through the --log-opt Docker command line argument:

    fluentd-address
    fluentd-tag

fluentd-address

Specify an optional address for Fluentd, it allows to set the host and TCP port, e.g:

$ docker run --log-driver=fluentd --log-opt fluentd-address=192.168.2.4:24225 ubuntu echo "..."

fluentd-tag

Tags are a major requirement on Fluentd, they allows to identify the incoming data and take routing decisions. By default the Fluentd logging driver uses the container_id as a tag (64 character ID), you can change it value with the fluentd-tag option as follows:

$ docker run --log-driver=fluentd --log-opt fluentd-tag=docker.my_new_tag ubuntu echo "..."

Additionally this option allows to specify some internal variables: {{.ID}}, {{.FullID}} or {{.Name}}. e.g:

$ docker run --log-driver=fluentd --log-opt fluentd-tag=docker.{{.ID}} ubuntu echo "..."

Production Environments

In a more serious environment, you would want to use something other than the Fluentd standard output to store Docker containers messages, such as Elasticsearch, MongoDB, HDFS, S3, Google Cloud Storage and so on. This can be done by installing the necessary Fluentd plugins and configuring fluent.conf appropriately for <match docker.all>...</match> section.

