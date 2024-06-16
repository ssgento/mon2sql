#!/bin/bash
set -e

# train schema item classifier (CSpider version)
source /root/anaconda3/bin/activate rpg
cd /workspace/algorithm/rpg
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
    --save_path "/workspace/model/private/xrj/classifier/classifier-mt5-large-mnt" \
    --tensorboard_save_path "/workspace/model/private/xrj/tensorboard_log/classifier-mt5-large-mnt" \
    --train_filepath "./data/preprocessed_data/mspidert_preprocessed_train.json" \
    --dev_filepath "./data/preprocessed_data/mspidert_preprocessed_dev.json" \
    --model_name_or_path "/workspace/model/pretrained/plm/mt5/mt5-large" \
    --use_contents \
    --add_fk_info \
    --mode "train"

