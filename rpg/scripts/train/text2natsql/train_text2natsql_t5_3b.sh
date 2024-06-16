set -e

source /root/anaconda3/bin/activate rpg
cd /workspace/algorithm/rpg
# train graphix text2natsql-t5-3b model
python -u text2sql_graphix.py \
    --batch_size 8 \
    --gradient_descent_step 12 \
    --device "0" \
    --learning_rate 5e-5 \
    --epochs 192 \
    --seed 42 \
    --save_path "/workspace/model/private/xrj/rpg/rpg-base-resdsql-t53b-192" \
    --tensorboard_save_path "/workspace/model/private/xrj/tensorboard_log/rpg-base-resdsql-t53b-192" \
    --model_name_or_path "/workspace/model/pretrained/plm/t5/t5-3b" \
    --use_adafactor \
    --mode train \
    --train_filepath "./graphix/data_all_in/data/resdsql_train_spider_natsql.json"\
    --graphix_dataset "./graphix/data_all_in/data/output/seq2seq_train_dataset.json"\
    --graphix_graph_pedia "./graphix/data_all_in/data/output/graph_pedia_total.bin"
# select the best text2natsql-t5-3b ckpt
python -u evaluate_text2sql_ckpts.py \
    --batch_size 8 \
    --device "0" \
    --seed 42 \
    --save_path "/workspace/model/private/xrj/rpg/rpg-base-resdsql-t53b-192" \
    --eval_results_path "/workspace/model/private/xrj/rpg/eval_result/rpg-base-resdsql-t53b-192" \
    --mode eval \
    --dev_filepath "./graphix/data_all_in/data/resdsql_dev_natsql.json" \
    --original_dev_filepath "./data/spider/dev.json" \
    --db_path "/workspace/dataset/private/MSpider/spider/database" \
    --tables_for_natsql "./data/preprocessed_data/tables_for_natsql.json" \
    --num_beams 8 \
    --num_return_sequences 8 \
    --target_type "natsql"\
    --graphix_dataset "./graphix/data_all_in/data/output/seq2seq_dev_dataset.json" \
    --graphix_graph_pedia "./graphix/data_all_in/data/output/graph_pedia_total.bin"
