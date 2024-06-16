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
    --save_path "/workspace/model/private/xrj/rpg/rpg-mspidert" \
    --tensorboard_save_path "/workspace/model/private/xrj/tensorboard_log/rpg-mspidert" \
    --model_name_or_path "/workspace/model/pretrained/plm/mt5/mt5-large" \
    --use_adafactor \
    --mode train \
    --train_filepath "./graphix/data_all_in/data/resdsql_train_mspider.json"\
    --graphix_dataset "./graphix/data_all_in/data/output/seq2seq_train_dataset_mspidert.json"\
    --model_type 'mt5'\
    --graphix_graph_pedia "./graphix/data_all_in/data/output/graph_pedia_total_mspidert.bin"

# select the best text2sql-mt5-large (MSpider-t version) ckpt
python -u evaluate_text2sql_ckpts.py \
    --batch_size 12 \
    --device "0" \
    --seed 42 \
    --save_path "/workspace/model/private/xrj/rpg/rpg-mspidert" \
    --eval_results_path "/workspace/model/private/xrj/rpg/eval_results/rpg-mspidert" \
    --mode eval \
    --dev_filepath "./graphix/data_all_in/data/resdsql_dev_mspider.json" \
    --original_dev_filepath "./data/mspider/dev.json" \
    --db_path "/workspace/dataset/private/MSpider/spider/database" \
    --num_beams 8 \
    --num_return_sequences 8 \
    --target_type "sql" \
    --graphix_dataset "./graphix/data_all_in/data/output/seq2seq_dev_dataset_mspidert.json" \
    --graphix_graph_pedia "./graphix/data_all_in/data/output/graph_pedia_total_mspidert.bin"