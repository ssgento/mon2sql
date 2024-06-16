#!/bin/bash
set -e
source /root/anaconda3/bin/activate rpg
cd /workspace/algorithm/rpg
# train text2sql-mt5-large (MSpider-t version) model
python -u text2sql_graphix.py \
    --batch_size 8 \
    --gradient_descent_step 1 \
    --device "0" \
    --learning_rate 5e-5 \
    --epochs 128 \
    --seed 42 \
    --save_path "/workspace/model/private/xrj/rpg/respider-rpg-mt5large-enhance" \
    --tensorboard_save_path "/workspace/model/private/xrj/tensorboard_log/respider-rpg-mt5large-enhance" \
    --model_name_or_path "/workspace/model/private/xrj/enhance/mt5-large-enhanced-en" \
    --use_adafactor \
    --mode train \
    --train_filepath "./graphix/data_all_in/data/respider_train.json"\
    --graphix_dataset "./graphix/data_all_in/data/output/seq2seq_train_dataset_respider.json"\
    --model_type 'mt5'\
    --graphix_graph_pedia "./graphix/data_all_in/data/output/graph_pedia_total_respider.bin"

# select the best text2sql-mt5-large (MSpider-t version) ckpt
python -u evaluate_text2sql_ckpts.py \
    --batch_size 12 \
    --device "0" \
    --seed 42 \
    --save_path "/workspace/model/private/xrj/rpg/respider-rpg-mt5large-enhance" \
    --eval_results_path "/workspace/model/private/xrj/rpg/eval_results/respider-rpg-mt5large-enhance" \
    --mode eval \
    --dev_filepath "./graphix/data_all_in/data/respider_dev.json" \
    --original_dev_filepath "./data/respider/dev.json" \
    --db_path "/workspace/dataset/private/MSpider/spider/database" \
    --num_beams 8 \
    --num_return_sequences 8 \
    --target_type "sql" \
    --graphix_dataset "./graphix/data_all_in/data/output/seq2seq_dev_dataset_respider.json" \
    --graphix_graph_pedia "./graphix/data_all_in/data/output/graph_pedia_total_respider.bin"