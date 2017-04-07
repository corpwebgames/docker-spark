#!/bin/bash
DOCKER_HOSTNAME=127.0.0.1
#`curl -s http://169.254.169.254/latest/meta-data/public-hostname`
export SPARK_MASTER_PORT=7077
export  SPARK_MASTER_WEBUI_PORT=8080
export SPARK_WORKER_PORT=8888
export SPARK_WORKER_WEBUI_PORT=8081
#export SPECIAL_SPARK_OPTS="-Dspark.driver.port=57001 -Dspark.fileserver.port=57002 -Dspark.broadcast.port=57003 -Dspark.replClassServer.port=57004 -Dspark.blockManager.port=57005 -Dspark.executor.port=57006 -Dspark.ui.port=54040 -Dspark.broadcast.factory=org.apache.spark.broadcast.HttpBroadcastFactory $SPECIAL_SPARK_OPTS"

#export SPARK_MASTER_OPTS="$SPECIAL_SPARK_OPTS"
#export SPARK_WORKER_OPTS="$SPECIAL_SPARK_OPTS"
#export SPARK_JAVA_OPTS="$SPECIAL_SPARK_OPTS"

export SPARK_MASTER_IP=$DOCKER_HOSTNAME
export SPARK_LOCAL_IP=$DOCKER_HOSTNAME
export SPARK_LOCAL_HOSTNAME=$DOCKER_HOSTNAME

#cat /usr/local/spark/conf/template-core-site.xml | m4 -DAWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -DAWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY > /usr/local/spark/conf/core-site.xml
aws s3 cp s3://$S3_BUCKET_CONF/hive/config/core-site.xml /usr/local/spark/conf/core-site.xml > /dev/null
aws s3 cp s3://$S3_BUCKET_CONF/hive/config/hive-site.xml /usr/local/spark/conf/hive-site.xml > /dev/null
aws s3 cp --recursive --exclude "*" --include "*.jar" s3://$S3_BUCKET_CONF/hive/config/udf/ /usr/local/spark/jars/ > /dev/null
env | grep SPARK | awk '{print "export \"" $0 "\""}' > /usr/local/spark/conf/spark-env.sh
export CLASSPATH="/usr/local/spark/jars/mysql-connector-java.jar"
export PATH="$PATH:/usr/local/spark/bin"
exec $@
