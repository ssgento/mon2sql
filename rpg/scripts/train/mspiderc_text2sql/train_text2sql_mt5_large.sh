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
    --seed 1234 \
    --save_path "/workspace/model/private/xrj/rpg/rpg-base-resdsql-seed1234" \
    --tensorboard_save_path "/workspace/model/private/xrj/tensorboard_log/rpg-base-resdsql-seed1234" \
    --model_name_or_path "/workspace/model/pretrained/plm/mt5/mt5-large" \
    --use_adafactor \
    --mode train \
    --train_filepath "./graphix/data_all_in/data/resdsql_train_mspider_l.json"\
    --graphix_dataset "./graphix/data_all_in/data/output/seq2seq_train_dataset.json"\
    --graphix_graph_pedia "./graphix/data_all_in/data/output/graph_pedia_total.bin"

# select the best text2sql-mt5-large (MSpider-t version) ckpt
python -u evaluate_text2sql_ckpts.py \
    --batch_size 12 \
    --device "0" \
    --seed 42 \
    --save_path "/workspace/model/private/xrj/rpg/rpg-base-resdsql-seed1234" \
    --eval_results_path "/workspace/model/private/xrj/rpg/eval_results/rpg-base-resdsql-seed1234" \
    --mode eval \
    --dev_filepath "./graphix/data_all_in/data/resdsql_dev_mspider_l.json" \
    --original_dev_filepath "./data/mspider/dev.json" \
    --db_path "/workspace/dataset/private/MSpider/spider/database" \
    --num_beams 8 \
    --num_return_sequences 8 \
    --target_type "sql" \
    --graphix_dataset "./graphix/data_all_in/data/output/seq2seq_dev_dataset.json" \
    --graphix_graph_pedia "./graphix/data_all_in/data/output/graph_pedia_total.bin"