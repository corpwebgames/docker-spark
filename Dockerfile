FROM dpatriot/docker-awscli-java8
MAINTAINER Shago Vyacheslav <v.shago@corpwebgames.com>

RUN \
	curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.6.0-bin-hadoop2.4.tgz | tar -xz -C /usr/local/ \
	&& cd /usr/local \
	&& ln -s spark-1.6.0-bin-hadoop2.4 spark

RUN \
	curl -s http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.38/mysql-connector-java-5.1.38.jar -o /usr/local/spark/lib/mysql-connector-java.jar \
	&& curl -s http://central.maven.org/maven2/com/databricks/spark-csv_2.11/1.3.0/spark-csv_2.11-1.3.0.jar -o /usr/local/spark/lib/spark-csv_2.11-1.3.0.jar \
	&& curl -s http://central.maven.org/maven2/org/apache/commons/commons-csv/1.2/commons-csv-1.2.jar -o /usr/local/spark/lib/commons-csv-1.2.jar \
	&& curl -s https://s3.amazonaws.com/redshift-downloads/drivers/RedshiftJDBC41-1.1.10.1010.jar -o /usr/local/spark/lib/RedshiftJDBC41-1.1.10.1010.jar \
	&& curl -s http://central.maven.org/maven2/com/databricks/spark-redshift_2.10/0.6.0/spark-redshift_2.10-0.6.0.jar -o /usr/local/spark/lib/spark-redshift.jar \
	&& curl -s http://central.maven.org/maven2/org/apache/spark/spark-streaming-kinesis-asl-assembly_2.11/1.6.0/spark-streaming-kinesis-asl-assembly_2.11-1.6.0.jar -o /usr/local/spark/lib/spark-streaming-kinesis-asl.jar \
	&& curl -s http://central.maven.org/maven2/com/databricks/spark-avro_2.10/2.0.1/spark-avro_2.10-2.0.1.jar -o /usr/local/spark/lib/spark-avro.jar \
	&& curl -s http://central.maven.org/maven2/com/databricks/spark-csv_2.11/1.3.0/spark-csv_2.11-1.3.0.jar -o /usr/local/spark/lib/spark-csv.jar

ADD scripts/start-master.sh /start-master.sh
ADD scripts/start-worker /start-worker.sh
ADD scripts/spark-shell.sh  /spark-shell.sh
ADD scripts/spark-defaults.conf /spark-defaults.conf
ADD scripts/remove_alias.sh /remove_alias.sh
ADD scripts/docker-run-spark-env.sh /usr/local/bin/docker-run-spark-env.sh
ADD scripts/script-runner.sh /usr/local/bin/script-runner.sh

RUN apt-get update \
	&& apt-get install -y python-pandas \
	&& rm -rf /var/lib/apt/lists/*

RUN pip install elasticsearch zdesk

ENV SPARK_HOME /usr/local/spark

ENV SPARK_DRIVER_CLASSPATH="/usr/local/spark/lib/mysql-connector-java.jar"

ENV SPARK_JARS="/usr/local/spark/lib/spark-avro.jar,/usr/local/spark/lib/spark-redshift.jar,/usr/local/spark/lib/spark-csv_2.11-1.3.0.jar,/usr/local/spark/lib/commons-csv-1.2.jar,/usr/local/spark/lib/RedshiftJDBC41-1.1.10.1010.jar,/usr/local/spark/lib/spark-streaming-kinesis-asl.jar"

ENV SPARK_MASTER_OPTS="-Dspark.driver.port=7001 -Dspark.fileserver.port=7002 -Dspark.broadcast.port=7003 -Dspark.replClassServer.port=7004 -Dspark.blockManager.port=7005 -Dspark.executor.port=7006 -Dspark.ui.port=4040 -Dspark.broadcast.factory=org.apache.spark.broadcast.HttpBroadcastFactory"
ENV SPARK_WORKER_OPTS="-Dspark.driver.port=7001 -Dspark.fileserver.port=7002 -Dspark.broadcast.port=7003 -Dspark.replClassServer.port=7004 -Dspark.blockManager.port=7005 -Dspark.executor.port=7006 -Dspark.ui.port=4040 -Dspark.broadcast.factory=org.apache.spark.broadcast.HttpBroadcastFactory"

ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8080
ENV SPARK_WORKER_PORT 8888
ENV SPARK_WORKER_WEBUI_PORT 8081
ENV DRIVER_MEMORY 1G

EXPOSE 8080 7077 8888 8081 4040 7001 7002 7003 7004 7005 7006

ENTRYPOINT ["script-runner.sh"]
