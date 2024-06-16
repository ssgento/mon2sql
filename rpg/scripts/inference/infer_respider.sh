source /root/anaconda3/bin/activate rpg
cd /workspace/algorithm/rpg

python preprocessing.py \
    --mode "test" \
    --table_path './data/respider/tables.json' \
    --input_dataset_path './data/respider/test.json' \
    --output_dataset_path "./data/preprocessed_data/respider_preprocessed_test.json" \
    --db_path '/workspace/dataset/private/MSpider/spider/database' \
    --target_type "sql"

# predict probability for each schema item
python schema_item_classifier.py \
    --batch_size 32 \
    --device '0' \
    --seed 42 \
    --save_path "/workspace/model/private/xrj/resdsql/xlm-roberta-large-en" \
    --dev_filepath "./data/preprocessed_data/respider_preprocessed_test.json" \
    --output_filepath "./data/preprocessed_data/respider_test_with_probs.json" \
    --use_contents \
    --add_fk_info \
    --mode "test"

# generate text2sql test set
python text2sql_data_generator.py \
    --input_dataset_path "./data/preprocessed_data/respider_test_with_probs.json" \
    --output_dataset_path "./graphix/data_all_in/data/respider_test.json" \
    --topk_table_num 4 \
    --topk_column_num 5 \
    --mode "test" \
    --use_contents \
    --add_fk_info \
    --output_skeleton \
    --target_type "sql"

# inference using the best text2sql ckpt
python text2sql_graphix.py \
    --batch_size 12 \
    --device 0 \
    --seed 42 \
    --save_path '/workspace/model/private/xrj/sota/respider/rpg_enhanced/checkpoint-60950' \
    --mode "test" \
    --dev_filepath "./graphix/data_all_in/data/respider_test.json" \
    --original_dev_filepath "./data/respider/test.json" \
    --db_path '/workspace/dataset/private/MSpider/spider/database' \
    --num_beams 8 \
    --num_return_sequences 8 \
    --target_type "sql" \
    --output './test/pred.sql'\
    --graphix_dataset "./graphix/data_all_in/data/output/seq2seq_test_dataset_respider.json"\
    --graphix_graph_pedia "./graphix/data_all_in/data/output/graph_pedia_test_respider.bin"

python text2sql_graphix.py \
    --batch_size 12 \
    --device 0 \
    --seed 42 \
    --save_path '/workspace/model/private/xrj/sota/respider/rpg_enhanced/checkpoint-57293' \
    --mode "test" \
    --dev_filepath "./graphix/data_all_in/data/respider_dev.json" \
    --original_dev_filepath "./data/respider/dev.json" \
    --db_path '/workspace/dataset/private/MSpider/spider/database' \
    --num_beams 8 \
    --num_return_sequences 8 \
    --target_type "sql" \
    --output './test/pred.sql'\
    --graphix_dataset "./graphix/data_all_in/data/output/seq2seq_dev_dataset_respider.json"\
    --graphix_graph_pedia "./graphix/data_all_in/data/output/graph_pedia_total_respider.bin"

python text2sql_graphix.py \
    --batch_size 12 \
    --device 0 \
    --seed 42 \
    --save_path '/workspace/model/private/xrj/sota/respider/rpg_wq/checkpoint-46322' \
    --mode "test" \
    --dev_filepath "./graphix/data_all_in/data/respider_test.json" \
    --original_dev_filepath "./data/respider/test.json" \
    --db_path '/workspace/dataset/private/MSpider/spider/database' \
    --num_beams 8 \
    --num_return_sequences 8 \
    --target_type "sql" \
    --output './test/pred.sql'\
    --graphix_dataset "./graphix/data_all_in/data/output/seq2seq_test_dataset_respider_wq.json"\
    --graphix_graph_pedia "./graphix/data_all_in/data/output/graph_pedia_test_respider_wq.bin"


python text2sql_graphix.py \
    --batch_size 12 \
    --device 0 \
    --seed 42 \
    --save_path '/workspace/model/private/xrj/sota/respider/rpg_wq_enhanced/checkpoint-62169' \
    --mode "test" \
    --dev_filepath "./graphix/data_all_in/data/respider_dev.json" \
    --original_dev_filepath "./data/respider/dev.json" \
    --db_path '/workspace/dataset/private/MSpider/spider/database' \
    --num_beams 8 \
    --num_return_sequences 8 \
    --target_type "sql" \
    --output './test/pred.sql'\
    --graphix_dataset "./graphix/data_all_in/data/output/seq2seq_dev_dataset_respider_wq.json"\
    --graphix_graph_pedia "./graphix/data_all_in/data/output/graph_pedia_total_respider_wq.bin"