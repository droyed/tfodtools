import sys
import tensorflow as tf
from google.protobuf import text_format
from object_detection.protos import pipeline_pb2

def read_config(pipeline_config_filepath):
    pipeline = pipeline_pb2.TrainEvalPipelineConfig()                                                                                                                                                                                                          
    with tf.io.gfile.GFile(pipeline_config_filepath, "r") as f:                                                                                                                                                                                                                     
        proto_str = f.read()                                                                                                                                                                                                                                          
        text_format.Merge(proto_str, pipeline)
    return pipeline

def write_config(pipeline, pipeline_config_filepath):
    config_text = text_format.MessageToString(pipeline)                                                                                                                                                                                                        
    with tf.io.gfile.GFile(pipeline_config_filepath, "wb") as f:                                                                                                                                                                                                                       
        f.write(config_text)

def modify_config(pipeline, pretrained_model_name, num_classes):
    pipeline.model.ssd.num_classes = num_classes
    pipeline.train_config.fine_tune_checkpoint_type = 'detection'

    pipeline.train_config.fine_tune_checkpoint = 'pre-trained-models/' + pretrained_model_name + '/checkpoint/ckpt-0'

    pipeline.train_config.batch_size = 8

    pipeline.train_input_reader.label_map_path = "annotations/label_map.pbtxt" # Path to label map file
    pipeline.train_input_reader.tf_record_input_reader.input_path[0] = "annotations/train.record" # Path to training TFRecord file

    pipeline.eval_input_reader[0].label_map_path = "annotations/label_map.pbtxt" # Path to label map file
    pipeline.eval_input_reader[0].tf_record_input_reader.input_path[0] = "annotations/test.record" # Path to testing TFRecord

    return pipeline


def setup_pipeline(pipeline_config_filepath, pretrained_model_name, num_classes):
    pipeline = read_config(pipeline_config_filepath)
    pipeline = modify_config(pipeline, pretrained_model_name, num_classes)
    write_config(pipeline, pipeline_config_filepath)

print('--> Debugging inside edit_pipeline ...')
numargs = len(sys.argv)
if numargs<4:
    raise Exception('Add in the pipeline config filepath, pre-trained model name and number of classes as the arguments.')

pipeline_config_fpath = sys.argv[1]
print('    pipeline filepath : ' + pipeline_config_fpath)

pretrained_model_name = sys.argv[2]
print('    pipeline pretrained_model_name : ' + pretrained_model_name)

num_classes = int(sys.argv[3])
print('    num_classes : ' + str(num_classes))

setup_pipeline(pipeline_config_fpath, pretrained_model_name, num_classes)
print('--> Done.')
