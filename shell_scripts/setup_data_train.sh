#!/bin/bash
##echo "Source link - https://tensorflow-object-detection-api-tutorial.readthedocs.io/en/latest/training.html"

echo "Note : Re-run this if it fails at any step"
ORG_PATH=$PWD

CONFIG_FILE="vars.config"
if [ -f "$CONFIG_FILE" ]; then
    echo "config file found"
    source vars.config

    varset=$([[ -v TF_INSTALL_PATH ]]; echo $?)
    if [ "$varset" -eq 0 ]; then
        read -p "Enter tensorflow object detection path (ending in /Tensorflow) : " -i "$TF_INSTALL_PATH" -e TF_INSTALL_PATH
    else
        echo "Sample tensorflow path :"
        cat sample_tensorflow_path.txt
        read -p "Enter tensorflow object detection path (ending in /Tensorflow) : "  TF_INSTALL_PATH
    fi

    varset=$([[ -v ENV_PATH ]]; echo $?)
    if [ "$varset" -eq 0 ]; then
        read -p "Enter python virtual environment path : " -i "$ENV_PATH" -e ENV_PATH
    else
        read -p "Enter python virtual environment path : "  ENV_PATH  
    fi
else
    echo "Sample tensorflow path :"
    cat sample_tensorflow_path.txt
    read -p "Enter tensorflow object detection path (ending in /Tensorflow) : "  TF_INSTALL_PATH
    read -p "Enter python virtual environment path : "  ENV_PATH
fi

source $ENV_PATH"/bin/activate"

echo "Models zoo page - https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/tf2_detection_zoo.md"
model_link="http://download.tensorflow.org/models/object_detection/tf2/20200711/ssd_mobilenet_v2_fpnlite_320x320_coco17_tpu-8.tar.gz"
read -p "Enter model url (tar.gz) : " -i "$model_link" -e model_link

cd "$TF_INSTALL_PATH"

rm -rf workspace # cleanup

mkdir -p workspace/training_demo

cd workspace/training_demo
mkdir -p annotations exported-models images models pre-trained-models
cd ../../

read -p "Enter path of images and xmls : "  indir  
indir=$(realpath $indir)

## Setup feature labels into label_map.pbtxt
read -p "Enter feature labels (separated by space) : "  labels
rm -f workspace/training_demo/annotations/label_map.pbtxt

counter=1
for label in $labels
do
echo "
item {
    id: $counter
    name: '$label'
}" >> workspace/training_demo/annotations/label_map.pbtxt
counter=$((counter+1))
done
count_labels=$((counter-1))
echo "count_labels = ""$count_labels"

python scripts/preprocessing/partition_dataset.py -x -i "$indir" -r 0.1 -o workspace/training_demo/images/
python scripts/preprocessing/generate_tfrecord.py -x workspace/training_demo/images/train -l workspace/training_demo/annotations/label_map.pbtxt -o workspace/training_demo/annotations/train.record
python scripts/preprocessing/generate_tfrecord.py -x workspace/training_demo/images/test -l workspace/training_demo/annotations/label_map.pbtxt -o workspace/training_demo/annotations/test.record
rm -rf workspace/training_demo/images/

cd workspace/training_demo/pre-trained-models/

wget "$model_link"
model_fname=$(basename "$model_link")
model_extracteddir=$(echo $model_fname | awk -F"." '{print $1}')
mkdir -p $model_extracteddir
tar -xzf "$model_fname" -C $model_extracteddir --strip-components=1
rm "$model_fname"

mkdir -p ../models/my_model

cp "$model_extracteddir"/pipeline.config ../models/my_model/

pipeline_config=$(dirname $PWD)"/models/my_model/pipeline.config"

python ../../../scripts/preprocessing/edit_pipeline.py "$pipeline_config" "$model_extracteddir" "$count_labels"

echo "pipeline config file edited - ""$pipeline_config"
read -p "Please edit further if needed and press return when ready, any other to quit here : "  choice
if [ "$choice" != '' ]; then
    exit 1
fi

cd ../../training_demo/
cp ../../../Tensorflow/models/research/object_detection/exporter_main_v2.py .
cp ../../models/research/object_detection/model_main_tf2.py .
TF_TRAIN_PATH="$PWD"

cd "$ORG_PATH"

# Setup save bash script
echo "source ""$ENV_PATH""/bin/activate" > save_model.sh
echo "cd ""$TF_TRAIN_PATH" >> save_model.sh
echo "python exporter_main_v2.py --input_type image_tensor --pipeline_config_path models/my_model/pipeline.config --trained_checkpoint_dir models/my_model/ --output_directory exported-models/my_model" >> save_model.sh
echo "====> To save model after modelling, simply run - 'bash save_model.sh'"

# Setup mobile version model creation bash script
echo "source ""$ENV_PATH""/bin/activate" > create_mobile_optimized_model.sh
echo "cd ""$TF_TRAIN_PATH" >> create_mobile_optimized_model.sh
echo "tensorflowjs_converter --input_format=tf_saved_model --output_node_names='MobilenetV2/Predictions/Reshape_1' --saved_model_tags=serve 'exported-models/my_model/saved_model' web_model" >> create_mobile_optimized_model.sh
echo "====> To save as a mobile optimized version, after modelling, simply run - 'bash create_mobile_optimized_model.sh'"
read -n 1 -p "Press any key to proceed" nullvar

cd "$TF_TRAIN_PATH"
python model_main_tf2.py --model_dir=models/my_model --pipeline_config_path=models/my_model/pipeline.config

exit 0
