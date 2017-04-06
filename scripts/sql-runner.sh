#!/bin/bash
docker-run-spark-env.sh $SPARK_HOME/bin/spark-sql -f $1
