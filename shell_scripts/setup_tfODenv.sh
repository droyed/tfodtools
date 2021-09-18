#!/bin/bash

bash cleanup.sh
echo "Note : Re-run this if it fails at any step"

# Setup input paths
read -p "Enter path where python virtual environment would be created : "  ENV_PATH  
if [ -d "$ENV_PATH" ] 
then
	read -n 1 -p "Directory "$ENV_PATH" already exists. Remove and proceed? (y/n) : "  choice
	echo ""
	if [ "$choice" == 'y' ]; then
		#echo "Removing : ""$ENV_PATH"
		rm -rf "$ENV_PATH"
	else
		#echo "Exiting."
		exit 1
	fi
fi

read -p "Enter path where tensorflow object detection would be created and setup : "  INSTALL_PATH  
if [ -d "$INSTALL_PATH" ] 
then
	read -n 1 -p "Directory "$INSTALL_PATH" already exists. Remove and proceed? (y/n) : "  choice
	echo ""
	if [ "$choice" == 'y' ]; then
		#echo "Removing : ""$INSTALL_PATH"
		rm -rf "$INSTALL_PATH"
	else
		#echo "Exiting."
		exit 1
	fi
fi

echo "protobuf releases page - https://github.com/protocolbuffers/protobuf/releases/"
protobuf_setup_url=https://github.com/protocolbuffers/protobuf/releases/download/v3.17.3/protoc-3.17.3-linux-x86_64.zip
read -p "Enter protobuf_setup_url : " -i "$protobuf_setup_url" -e protobuf_setup_url

pip_requirements="$PWD"/pip_requirements.txt 

ORG_PATH=$PWD

# Regularize paths
ENV_PATH=$(realpath $ENV_PATH)
INSTALL_PATH=$(realpath $INSTALL_PATH)

# Setup additional paths
tf_PATH=$INSTALL_PATH"/Tensorflow"
tf_research_PATH=$tf_PATH"/models/research/"
tf_scripts_preprocess="$tf_PATH""/scripts/preprocessing"

# Setup venv
mkdir -p $ENV_PATH
cd $ENV_PATH
python3 -m venv .
source bin/activate

# Pip install packlages
pip install -U pip
pip install -r $pip_requirements

# Setup tf
mkdir -p $INSTALL_PATH
mkdir -p $tf_PATH
cd $tf_PATH
wget https://github.com/tensorflow/models/archive/master.zip
unzip -q master.zip 
rm master.zip 
mv models-master/ models/

# Setup tf git way - NOT USED
#git clone https://github.com/tensorflow/models.git
#cd models/

# Setup protoc
cd $INSTALL_PATH
wget $protobuf_setup_url
protobuf_setup_filename=$(basename $protobuf_setup_url)
unzip -q $protobuf_setup_filename
rm $protobuf_setup_filename
export PATH=$PATH:$PWD/bin/

cd $tf_research_PATH
protoc object_detection/protos/*.proto --python_out=.

# Setup cocoapi
cd $INSTALL_PATH
git clone https://github.com/cocodataset/cocoapi.git
cd cocoapi/PythonAPI
make
cp -r pycocotools $tf_research_PATH

# Setup object detection api
cd $tf_research_PATH
cp object_detection/packages/tf2/setup.py .
python -m pip install --use-feature=2020-resolver .
python object_detection/builders/model_builder_tf2_test.py

mkdir -p "$tf_scripts_preprocess"
cp "$ORG_PATH"/edit_pipeline.py "$tf_scripts_preprocess"

wget https://tensorflow-object-detection-api-tutorial.readthedocs.io/en/latest/_downloads/d0e545609c5f7f49f39abc7b6a38cec3/partition_dataset.py -P "$tf_scripts_preprocess"
wget https://tensorflow-object-detection-api-tutorial.readthedocs.io/en/latest/_downloads/da4babe668a8afb093cc7776d7e630f3/generate_tfrecord.py -P "$tf_scripts_preprocess"

#echo "Note : alias/command to activate python virtual environment later on -"
#echo "alias ""'""ss1=source ""$ENV_PATH""/bin/activate""'"

cd "$ORG_PATH"
echo 'Saving paths and configurations to vars.config that can be used in later steps ...'
echo "## ---- " $(date) " ----"  > vars.config
echo "ENV_PATH=""$ENV_PATH" >> vars.config
echo "INSTALL_PATH=""$INSTALL_PATH" >> vars.config
echo "TF_INSTALL_PATH=""$INSTALL_PATH/Tensorflow" >> vars.config

exit 0
