set -e
source /root/anaconda3/bin/activate rpg
cd algorithm/rpg
# train schema item classifier
python -u schema_item_classifier.py \
    --batch_size 16 \
    --gradient_descent_step 2 \
    --device "0" \
    --learning_rate 1e-5 \
    --gamma 2.0 \
    --alpha 0.75 \
    --epochs 128 \
    --patience 16 \
    --seed 42 \
    --save_path "/workspace/model/private/xrj/classifier/classifier-mt5-large-en" \
    --tensorboard_save_path "/workspace/model/private/xrj/tensorboard_log/classifier-mt5-large-en" \
    --train_filepath "./data/preprocessed_data/respider_preprocessed_train.json" \
    --dev_filepath "./data/preprocessed_data/respider_preprocessed_dev.json" \
    --model_name_or_path "/workspace/model/pretrained/plm/mt5/mt5-large" \
    --use_contents \
    --add_fk_info \
    --mt5 \
    --mode "train"