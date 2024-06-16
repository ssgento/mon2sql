#!/bin/bash
set -e

# train schema item classifier (CSpider version)
source /root/anaconda3/bin/activate resdsql
cd algorithm/resdsql
python -u schema_item_classifier.py \
    --batch_size 8 \
    --gradient_descent_step 1 \
    --device "0" \
    --learning_rate 1e-5 \
    --gamma 2.0 \
    --alpha 0.75 \
    --epochs 128 \
    --patience 16 \
    --seed 42 \
    --save_path "/workspace/model/private/xrj/resdsql/xlmrobertalarge-mnc" \
    --tensorboard_save_path "/workspace/model/private/xrj/tensorboard_log/xlmrobertalarge-mnc" \
    --train_filepath "./data/preprocessed_data/preprocessed_train_mspiderc.json" \
    --dev_filepath "./data/preprocessed_data/preprocessed_dev_mspiderc.json" \
    --model_name_or_path "/workspace/model/pretrained/plm/xlmroberta/xlmroberta-large" \
    --use_contents \
    --add_fk_info \
    --mode "train"