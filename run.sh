#!/bin/bash

#MODEL_URL="https://raw.githubusercontent.com/google-coral/edgetpu/master/test_data/ssd_mobilenet_v2_coco_quant_postprocess.tflite"
MODEL_URL="https://raw.githubusercontent.com/google-coral/test_data/master/efficientdet_lite3_512_ptq_edgetpu.tflite"
LABELS_URL="https://github.com/google-coral/edgetpu/raw/master/test_data/coco_labels.txt"
LOG=$true
echo $MODEL_URL
echo $LABELS_URL
MODEL_FILE=`echo ${MODEL_URL} | sed 's:.*/::'`
LABELS_FILE=`echo ${LABELS_URL} | sed 's:.*/::'`
echo $MODEL_FILE
echo $LABELS_FILE

mkdir -p /config
rm -f /app/coral.log
if $LOG; then
  touch /config/coral_access.log
  ln -s /config/coral_access.log /app/coral.log
  echo "Logging to /config/coral_access.log"
else
  echo "Logging to /dev/null"
  ln -s /dev/null /app/coral.log
fi


mkdir -p /app/models

wget -q ${MODEL_URL} -O /app/models/${MODEL_FILE}
wget -q ${LABELS_URL} -O /app/models/${LABELS_FILE}

cd /app

echo "Starting the server..."
exec python3 /app/coral-app.py --model  "${MODEL_FILE}" --labels "${LABELS_FILE}" --models_directory "/app/models/"

