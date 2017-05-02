#!/bin/bash
read -ra arr <<<"$ARGS"
if [ $arr ] ; then
        separator=' --hiveconf '
        params=$(printf "${separator}%s" "${arr[@]}")
fi
docker-run-spark-env.sh $SPARK_HOME/bin/spark-sql -f $1 $params
