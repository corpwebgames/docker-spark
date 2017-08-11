#!/bin/bash
path=$1
file=$(basename $path)
cd /usr/local/spark/bin/
if aws s3 cp $1 $file ; then
chmod +x $file

if [ "$LIB_PATH" ]; then
    if aws s3 cp s3://$LIB_PATH lib.zip ; then
        unzip -o lib.zip
    else
        echo "Lib $LIB_PATH not found"
    fi
fi

docker-run-spark-env.sh $SPARK_HOME/bin/spark-submit \
--master local[*] \
--driver-memory $DRIVER_MEMORY \
--driver-class-path $SPARK_DRIVER_CLASSPATH \
--jars $SPARK_JARS \
$file $ARGS 2>&1 | tee $file-$ID.out

_status=${PIPESTATUS[0]}
_output=`cat $file-$ID.out | head -c65535`

times=$(date +"%Y%m%d%H%M")
  if [ "$S3_LOG_BUCKET" ]; then aws s3 cp $file-$ID.out s3://$S3_LOG_BUCKET/docker/$CATEGORY/$ID/$file-$times.out; fi
echo "status $_status"
  exit $_status

else
  send "File $1 not found" "255"
fi